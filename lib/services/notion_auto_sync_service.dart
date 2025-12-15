import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notion_service.dart';
import '../Controller/todo_list.dart';

/// Auto-sync service for syncing tasks to Notion automatically
class NotionAutoSyncService {
  // Singleton pattern
  static final NotionAutoSyncService instance = NotionAutoSyncService._();
  NotionAutoSyncService._();

  // State management
  final ValueNotifier<SyncState> syncState = ValueNotifier(SyncState.disabled);
  final ValueNotifier<String?> lastSyncTime = ValueNotifier(null);
  final ValueNotifier<int> syncedTasksCount = ValueNotifier(0);

  // Debounce timer
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(seconds: 3);

  // Retry configuration
  int _consecutiveFailures = 0;
  static const int _maxRetries = 2;
  static const Duration _retryDelay1 = Duration(seconds: 1);
  static const Duration _retryDelay2 = Duration(seconds: 3);

  // SharedPreferences keys
  static const String _lastSyncTimeKey = 'notion_last_sync_time';
  static const String _syncErrorCountKey = 'notion_sync_error_count';
  static const String _syncedTasksCountKey = 'notion_synced_tasks_count';

  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Initialize the auto-sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load persisted state
    await _loadPersistedState();

    // Check initial connection status
    final connected = await NotionService.isConnected();
    if (connected) {
      syncState.value = SyncState.idle;
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

  /// Perform the actual sync
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

    try {
      // Get current tasks
      final tasks = List<List<dynamic>>.from(toDoList.value);

      if (tasks.isEmpty) {
        print('No tasks to sync');
        _handleSyncSuccess(0, 0);
        return;
      }

      // Perform sync
      print('Starting auto-sync of ${tasks.length} tasks...');
      final result = await NotionService.syncAllTasks(tasks);

      final success = result['success'] as int;
      final failed = result['failed'] as int;
      final created = result['created'] as int;
      final updated = result['updated'] as int;
      final updatedTasks = result['updatedTasks'] as List<List<dynamic>>;

      // Update local task list with new Notion page IDs
      if (updatedTasks.isNotEmpty) {
        toDoList.value = updatedTasks;
      }

      if (failed > 0) {
        print('Auto-sync completed with errors: $success success, $failed failed');
        _handleSyncError('Partial sync: $failed tasks failed', retry: true);
      } else {
        print('Auto-sync successful: $created created, $updated updated');
        _handleSyncSuccess(created, updated);
      }
    } catch (e) {
      print('Auto-sync failed: $e');
      _handleSyncError(e.toString(), retry: true);
    } finally {
      _isSyncing = false;
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

  /// Force an immediate sync (for manual sync button)
  Future<Map<String, dynamic>> forceSync() async {
    // Cancel any pending debounced sync
    _debounceTimer?.cancel();

    // Check if Notion is connected
    final connected = await NotionService.isConnected();
    if (!connected) {
      throw Exception('Notion not connected');
    }

    // Perform sync without retry logic (manual sync should show errors immediately)
    syncState.value = SyncState.syncing;
    _isSyncing = true;

    try {
      final tasks = List<List<dynamic>>.from(toDoList.value);
      final result = await NotionService.syncAllTasks(tasks);

      final failed = result['failed'] as int;
      final created = result['created'] as int;
      final updated = result['updated'] as int;
      final updatedTasks = result['updatedTasks'] as List<List<dynamic>>;

      // Update local task list with new Notion page IDs
      if (updatedTasks.isNotEmpty) {
        toDoList.value = updatedTasks;
      }

      if (failed == 0) {
        _handleSyncSuccess(created, updated);
      } else {
        syncState.value = SyncState.error;
      }

      return result;
    } catch (e) {
      syncState.value = SyncState.error;
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Update sync state when Notion is connected/disconnected
  void updateConnectionState(bool connected) {
    if (connected) {
      if (syncState.value == SyncState.disabled) {
        syncState.value = SyncState.idle;
      }
    } else {
      syncState.value = SyncState.disabled;
      _debounceTimer?.cancel();
    }
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    toDoList.removeListener(_onTasksChanged);
    syncState.dispose();
    lastSyncTime.dispose();
    syncedTasksCount.dispose();
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
