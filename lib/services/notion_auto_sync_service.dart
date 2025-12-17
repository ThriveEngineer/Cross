import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notion_service.dart';
import '../Controller/todo_list.dart';

/// Sync direction enum for tracking sync flow
enum SyncDirection {
  none,          // No sync happening
  toNotion,      // Local → Notion (existing flow)
  fromNotion,    // Notion → Local (new flow)
  bidirectional, // Both directions (full sync)
}

/// Auto-sync service for syncing tasks to Notion automatically
class NotionAutoSyncService {
  // Singleton pattern
  static final NotionAutoSyncService instance = NotionAutoSyncService._();
  NotionAutoSyncService._();

  // State management
  final ValueNotifier<SyncState> syncState = ValueNotifier(SyncState.disabled);
  final ValueNotifier<String?> lastSyncTime = ValueNotifier(null);
  final ValueNotifier<int> syncedTasksCount = ValueNotifier(0);
  final ValueNotifier<SyncDirection> syncDirection = ValueNotifier(SyncDirection.none);

  // Debounce timer
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(seconds: 3);

  // Polling timer for bi-directional sync
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(minutes: 5);
  final ValueNotifier<bool> pollingEnabled = ValueNotifier(true);

  // Retry configuration
  int _consecutiveFailures = 0;
  static const int _maxRetries = 2;
  static const Duration _retryDelay1 = Duration(seconds: 1);
  static const Duration _retryDelay2 = Duration(seconds: 3);

  // SharedPreferences keys
  static const String _lastSyncTimeKey = 'notion_last_sync_time';
  static const String _syncErrorCountKey = 'notion_sync_error_count';
  static const String _syncedTasksCountKey = 'notion_synced_tasks_count';
  static const String _pollingEnabledKey = 'notion_polling_enabled';

  bool _isInitialized = false;
  bool _isSyncing = false;
  bool _suppressNextSync = false; // Prevents infinite sync loops

  /// Initialize the auto-sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load persisted state
    await _loadPersistedState();
    await _loadPollingPreference();

    // Check initial connection status
    final connected = await NotionService.isConnected();
    if (connected) {
      syncState.value = SyncState.idle;
      startPolling(); // Start polling when connected
    } else {
      syncState.value = SyncState.disabled;
    }

    // Listen to task list changes
    toDoList.addListener(_onTasksChanged);

    _isInitialized = true;
    print('NotionAutoSyncService initialized');
  }

  /// Load persisted sync state from SharedPreferences
  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      lastSyncTime.value = prefs.getString(_lastSyncTimeKey);
      _consecutiveFailures = prefs.getInt(_syncErrorCountKey) ?? 0;
      syncedTasksCount.value = prefs.getInt(_syncedTasksCountKey) ?? 0;
    } catch (e) {
      print('Failed to load sync state: $e');
    }
  }

  /// Save sync state to SharedPreferences
  Future<void> _persistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (lastSyncTime.value != null) {
        await prefs.setString(_lastSyncTimeKey, lastSyncTime.value!);
      }
      await prefs.setInt(_syncErrorCountKey, _consecutiveFailures);
      await prefs.setInt(_syncedTasksCountKey, syncedTasksCount.value);
    } catch (e) {
      print('Failed to persist sync state: $e');
    }
  }

  /// Called when tasks change
  void _onTasksChanged() {
    // Check if we should suppress this sync (to prevent loops)
    if (_suppressNextSync) {
      print('Suppressing sync to prevent loop');
      _suppressNextSync = false;
      return;
    }

    _scheduleSyncWithDebounce();
  }

  /// Schedule a sync with debouncing
  void _scheduleSyncWithDebounce() {
    // Cancel existing timer
    _debounceTimer?.cancel();

    // Check if we should sync
    if (syncState.value == SyncState.disabled) {
      // Check if Notion is now connected
      NotionService.isConnected().then((connected) {
        if (connected) {
          syncState.value = SyncState.idle;
          _scheduleSyncWithDebounce();
        }
      });
      return;
    }

    // Don't start a new timer if already syncing
    if (_isSyncing) {
      print('Sync already in progress, will retry after completion');
      return;
    }

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _performSync();
    });
  }

  /// Perform the actual sync (now bidirectional)
  Future<void> _performSync() async {
    // Prevent concurrent syncs
    if (_isSyncing) {
      print('Sync already in progress, skipping');
      return;
    }

    // Check if Notion is connected
    final connected = await NotionService.isConnected();
    if (!connected) {
      print('Notion not connected, skipping sync');
      syncState.value = SyncState.disabled;
      return;
    }

    _isSyncing = true;
    syncState.value = SyncState.syncing;
    syncDirection.value = SyncDirection.bidirectional;

    try {
      // Use bidirectional sync instead of one-way
      final result = await _performBidirectionalSync();

      final localUpdates = result['localUpdates'] as int;
      final localCreates = result['localCreates'] as int;
      final localDeletes = result['localDeletes'] as int;
      final notionUpdates = result['notionUpdates'] as int;
      final notionCreates = result['notionCreates'] as int;
      final errors = result['errors'] as int;

      if (errors > 0) {
        print('Sync completed with errors: $errors failed');
        _handleSyncError('Partial sync: $errors operations failed', retry: true);
      } else {
        print('Bidirectional sync successful:');
        print('  Local: $localCreates created, $localUpdates updated, $localDeletes deleted');
        print('  Notion: $notionCreates created, $notionUpdates updated');
        _handleSyncSuccess(notionCreates, notionUpdates);
      }
    } catch (e) {
      print('Bidirectional sync failed: $e');
      _handleSyncError(e.toString(), retry: true);
    } finally {
      _isSyncing = false;
      syncDirection.value = SyncDirection.none;
    }
  }

  /// Handle successful sync
  void _handleSyncSuccess(int created, int updated) {
    syncState.value = SyncState.success;
    lastSyncTime.value = DateTime.now().toIso8601String();
    syncedTasksCount.value = created + updated;
    _consecutiveFailures = 0;
    _persistState();
  }

  /// Handle sync error with retry logic
  void _handleSyncError(String error, {bool retry = false}) {
    _consecutiveFailures++;
    _persistState();

    if (retry && _consecutiveFailures <= _maxRetries) {
      // Retry with exponential backoff
      final retryDelay = _consecutiveFailures == 1 ? _retryDelay1 : _retryDelay2;
      print('Retrying sync in ${retryDelay.inSeconds}s (attempt $_consecutiveFailures/$_maxRetries)');

      syncState.value = SyncState.syncing;
      Future.delayed(retryDelay, () {
        if (_consecutiveFailures <= _maxRetries) {
          _performSync();
        }
      });
    } else {
      // Max retries reached or retry not requested
      syncState.value = SyncState.error;
      print('Sync failed after $_consecutiveFailures attempts: $error');
    }
  }

  /// Perform bidirectional sync - compares local and Notion tasks
  /// Uses "last modified wins" conflict resolution
  Future<Map<String, dynamic>> _performBidirectionalSync() async {
    print('Starting bidirectional sync...');

    // 1. Fetch all tasks from Notion
    final notionTasks = await NotionService.queryAllTasks();
    print('Found ${notionTasks.length} tasks in Notion');

    // 2. Build maps for comparison
    final localByPageId = <String, List<dynamic>>{};
    final localWithoutPageId = <List<dynamic>>[];

    for (final task in toDoList.value) {
      final pageId = task.length > 5 ? task[5] as String? : null;
      if (pageId != null && pageId.isNotEmpty) {
        localByPageId[pageId] = task;
      } else {
        localWithoutPageId.add(task);
      }
    }

    final notionByPageId = <String, Map<String, dynamic>>{};
    for (final task in notionTasks) {
      notionByPageId[task['id']] = task;
    }

    // 3. Categorize tasks
    final toUpdateInNotion = <List<dynamic>>[];  // Local newer, update Notion
    final toUpdateLocally = <Map<String, dynamic>>[];  // Notion newer, update local
    final toCreateInNotion = List<List<dynamic>>.from(localWithoutPageId);  // No page ID, create in Notion
    final toCreateLocally = <Map<String, dynamic>>[];  // In Notion but not local
    final toDeleteLocally = <String>[];  // Page IDs to delete locally

    // 4. Compare tasks that exist in both places
    for (final entry in localByPageId.entries) {
      final pageId = entry.key;
      final localTask = entry.value;
      final notionTask = notionByPageId[pageId];

      if (notionTask == null) {
        // Task exists locally but not in Notion - it was deleted in Notion
        toDeleteLocally.add(pageId);
      } else {
        // Task exists in both - compare timestamps
        final localTimestamp = TaskTimestamp.getTimestamp(localTask);
        final notionTimestamp = notionTask['lastModified'] as String?;

        final comparison = TaskTimestamp.compare(localTimestamp, notionTimestamp);

        if (comparison > 0) {
          // Local is newer - update Notion
          toUpdateInNotion.add(localTask);
        } else if (comparison < 0) {
          // Notion is newer - update local
          toUpdateLocally.add(notionTask);
        }
        // If equal, no action needed

        // Remove from Notion map (processed)
        notionByPageId.remove(pageId);
      }
    }

    // 5. Remaining Notion tasks don't exist locally - create them locally
    toCreateLocally.addAll(notionByPageId.values);

    print('Sync plan: '
        'Create in Notion: ${toCreateInNotion.length}, '
        'Update in Notion: ${toUpdateInNotion.length}, '
        'Create locally: ${toCreateLocally.length}, '
        'Update locally: ${toUpdateLocally.length}, '
        'Delete locally: ${toDeleteLocally.length}');

    // 6. Execute sync operations
    return await _executeBidirectionalSync(
      toUpdateInNotion: toUpdateInNotion,
      toUpdateLocally: toUpdateLocally,
      toCreateInNotion: toCreateInNotion,
      toCreateLocally: toCreateLocally,
      toDeleteLocally: toDeleteLocally,
    );
  }

  /// Execute bidirectional sync operations
  Future<Map<String, dynamic>> _executeBidirectionalSync({
    required List<List<dynamic>> toUpdateInNotion,
    required List<Map<String, dynamic>> toUpdateLocally,
    required List<List<dynamic>> toCreateInNotion,
    required List<Map<String, dynamic>> toCreateLocally,
    required List<String> toDeleteLocally,
  }) async {
    int localUpdates = 0;
    int localCreates = 0;
    int localDeletes = 0;
    int notionUpdates = 0;
    int notionCreates = 0;
    int errors = 0;

    // Build new local task list
    final newLocalTasks = List<List<dynamic>>.from(toDoList.value);

    // 1. Delete local tasks that were removed from Notion
    for (final pageId in toDeleteLocally) {
      newLocalTasks.removeWhere((task) {
        final id = task.length > 5 ? task[5] as String? : null;
        return id == pageId;
      });
      localDeletes++;
    }

    // 2. Update local tasks with Notion changes
    for (final notionTask in toUpdateLocally) {
      final pageId = notionTask['id'] as String;
      final index = newLocalTasks.indexWhere((task) {
        final id = task.length > 5 ? task[5] as String? : null;
        return id == pageId;
      });

      if (index != -1) {
        // Validate folder exists locally
        final notionFolder = notionTask['folder'] as String;
        final folderExists = foldersList.value.any((f) => f['name'] == notionFolder);
        final folder = folderExists ? notionFolder : 'Inbox';

        if (!folderExists) {
          print('Warning: Notion folder "$notionFolder" not found locally, using Inbox');
        }

        // Update existing local task
        final existingTask = newLocalTasks[index];
        final previousFolder = existingTask.length > 3 ? existingTask[3] : null;

        newLocalTasks[index] = [
          notionTask['name'],
          notionTask['completed'],
          folder,
          previousFolder,
          notionTask['dueDate'],
          pageId,
          notionTask['lastModified'], // Use Notion's timestamp
        ];
        localUpdates++;
      }
    }

    // 3. Create local tasks from Notion
    for (final notionTask in toCreateLocally) {
      // Validate folder exists locally
      final notionFolder = notionTask['folder'] as String;
      final folderExists = foldersList.value.any((f) => f['name'] == notionFolder);
      final folder = folderExists ? notionFolder : 'Inbox';

      if (!folderExists) {
        print('Warning: Notion folder "$notionFolder" not found locally, using Inbox');
      }

      newLocalTasks.add([
        notionTask['name'],
        notionTask['completed'],
        folder,
        null, // previousFolder
        notionTask['dueDate'],
        notionTask['id'], // pageId
        notionTask['lastModified'], // timestamp
      ]);
      localCreates++;
    }

    // 4. Update tasks in Notion (local is newer)
    for (final task in toUpdateInNotion) {
      final pageId = task[5] as String;
      final success = await NotionService.updateTask(
        pageId: pageId,
        taskName: task[0],
        isCompleted: task[1],
        folder: task[2],
        dueDate: task[4],
      );

      if (success) {
        notionUpdates++;
        // Update local timestamp to now (since we just synced to Notion)
        final index = newLocalTasks.indexWhere((t) => t.length > 5 && t[5] == pageId);
        if (index != -1) {
          newLocalTasks[index] = TaskTimestamp.setTimestamp(
            newLocalTasks[index],
            TaskTimestamp.now(),
          );
        }
      } else {
        errors++;
      }
    }

    // 5. Create tasks in Notion (new local tasks)
    for (final task in toCreateInNotion) {
      final pageId = await NotionService.createTask(
        taskName: task[0],
        isCompleted: task.length > 1 ? task[1] : false,
        folder: task.length > 2 ? task[2] : 'Inbox',
        dueDate: task.length > 4 ? task[4] : null,
      );

      if (pageId != null) {
        notionCreates++;
        // Update local task with page ID and timestamp
        final index = newLocalTasks.indexOf(task);
        if (index != -1) {
          final updated = List<dynamic>.from(task);
          while (updated.length < 5) updated.add(null);
          if (updated.length == 5) {
            updated.add(pageId);
          } else {
            updated[5] = pageId;
          }
          newLocalTasks[index] = TaskTimestamp.setTimestamp(
            updated,
            TaskTimestamp.now(),
          );
        }
      } else {
        errors++;
      }
    }

    // 6. Apply changes to local state (single write to prevent sync loops)
    if (localUpdates > 0 || localCreates > 0 || localDeletes > 0 ||
        notionUpdates > 0 || notionCreates > 0) {
      _suppressNextSync = true; // CRITICAL: Prevent sync loop
      toDoList.value = newLocalTasks;
    }

    return {
      'localUpdates': localUpdates,
      'localCreates': localCreates,
      'localDeletes': localDeletes,
      'notionUpdates': notionUpdates,
      'notionCreates': notionCreates,
      'errors': errors,
    };
  }

  /// Force an immediate sync (for manual sync button)
  Future<Map<String, dynamic>> forceSync() async {
    // Cancel any pending debounced sync
    _debounceTimer?.cancel();

    // Check if Notion is connected
    final connected = await NotionService.isConnected();
    if (!connected) {
      throw Exception('Notion not connected');
    }

    // Perform bidirectional sync without retry logic (manual sync should show errors immediately)
    syncState.value = SyncState.syncing;
    syncDirection.value = SyncDirection.bidirectional;
    _isSyncing = true;

    try {
      final result = await _performBidirectionalSync();

      final errors = result['errors'] as int;
      if (errors == 0) {
        _handleSyncSuccess(
          result['notionCreates'] as int,
          result['notionUpdates'] as int,
        );
      } else {
        syncState.value = SyncState.error;
      }

      return result;
    } catch (e) {
      syncState.value = SyncState.error;
      rethrow;
    } finally {
      _isSyncing = false;
      syncDirection.value = SyncDirection.none;
    }
  }

  /// Update sync state when Notion is connected/disconnected
  void updateConnectionState(bool connected) {
    if (connected) {
      if (syncState.value == SyncState.disabled) {
        syncState.value = SyncState.idle;
        startPolling(); // Start polling when connected
      }
    } else {
      syncState.value = SyncState.disabled;
      _debounceTimer?.cancel();
      stopPolling(); // Stop polling when disconnected
    }
  }

  /// Start periodic polling for Notion changes
  void startPolling() {
    if (!pollingEnabled.value) {
      print('Polling is disabled');
      return;
    }

    stopPolling(); // Stop existing timer

    print('Starting Notion polling every ${_pollingInterval.inMinutes} minutes');

    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      // Only poll if app is active and Notion is connected
      if (syncState.value != SyncState.disabled && !_isSyncing) {
        print('Polling Notion for changes...');
        syncDirection.value = SyncDirection.fromNotion;
        await _performBidirectionalSync();
        syncDirection.value = SyncDirection.none;
      }
    });
  }

  /// Stop periodic polling
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('Stopped Notion polling');
  }

  /// Update polling enabled state
  Future<void> setPollingEnabled(bool enabled) async {
    pollingEnabled.value = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pollingEnabledKey, enabled);

    if (enabled) {
      startPolling();
    } else {
      stopPolling();
    }
  }

  /// Load polling preference
  Future<void> _loadPollingPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      pollingEnabled.value = prefs.getBool(_pollingEnabledKey) ?? true;
    } catch (e) {
      print('Failed to load polling preference: $e');
    }
  }

  /// Trigger immediate bidirectional sync (e.g., when app resumes or pull-to-refresh)
  Future<void> triggerImmediateSync() async {
    if (syncState.value == SyncState.disabled || _isSyncing) return;

    print('Triggering immediate sync...');
    syncDirection.value = SyncDirection.bidirectional;

    try {
      await _performBidirectionalSync();
    } catch (e) {
      print('Immediate sync failed: $e');
    } finally {
      syncDirection.value = SyncDirection.none;

      // Restart polling
      if (pollingEnabled.value) {
        startPolling();
      }
    }
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    stopPolling();
    toDoList.removeListener(_onTasksChanged);
    syncState.dispose();
    lastSyncTime.dispose();
    syncedTasksCount.dispose();
    syncDirection.dispose();
    pollingEnabled.dispose();
    _isInitialized = false;
  }
}

/// Sync state enum
enum SyncState {
  idle,      // No sync needed, Notion connected
  syncing,   // Active sync in progress
  success,   // Last sync completed successfully
  error,     // Last sync failed
  disabled   // Notion not connected
}
