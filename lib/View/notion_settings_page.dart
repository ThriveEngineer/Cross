import 'package:cross/Controller/todo_list.dart';
import 'package:cross/services/notion_service.dart';
import 'package:cross/services/notion_auto_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class NotionSettingsPage extends StatefulWidget {
  const NotionSettingsPage({super.key});

  @override
  State<NotionSettingsPage> createState() => _NotionSettingsPageState();
}

class _NotionSettingsPageState extends State<NotionSettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _databaseIdController = TextEditingController();
  bool _isConnected = false;
  bool _isLoading = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadConnectionStatus();
  }

  Future<void> _loadConnectionStatus() async {
    final connected = await NotionService.isConnected();
    setState(() {
      _isConnected = connected;
    });

    if (connected) {
      final apiKey = await NotionService.getApiKey();
      final databaseId = await NotionService.getDatabaseId();

      if (apiKey != null) {
        _apiKeyController.text = '${apiKey.substring(0, 10)}...';
      }
      if (databaseId != null) {
        _databaseIdController.text = databaseId;
      }
    }
  }

  Future<void> _connectNotion() async {
    if (_apiKeyController.text.isEmpty || _databaseIdController.text.isEmpty) {
      _showMessage('Please enter both API key and Database ID');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await NotionService.saveCredentials(
        _apiKeyController.text,
        _databaseIdController.text,
      );

      final connected = await NotionService.testConnection();

      if (connected) {
        setState(() {
          _isConnected = true;
        });
        // Update auto-sync connection state
        NotionAutoSyncService.instance.updateConnectionState(true);
        _showMessage('Successfully connected to Notion! Auto-sync is now enabled.');
      } else {
        await NotionService.disconnect();
        _showMessage('Failed to connect. Please check your credentials.');
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _disconnectNotion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotionService.disconnect();
      setState(() {
        _isConnected = false;
      });
      // Update auto-sync connection state
      NotionAutoSyncService.instance.updateConnectionState(false);
      _apiKeyController.clear();
      _databaseIdController.clear();
      _showMessage('Disconnected from Notion');
    } catch (e) {
      _showMessage('Error disconnecting: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncToNotion() async {
    if (!_isConnected) {
      _showMessage('Please connect to Notion first');
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await NotionService.syncAllTasks(toDoList.value);

      final success = result['success'] as int;
      final failed = result['failed'] as int;
      final created = result['created'] as int;
      final updated = result['updated'] as int;
      final updatedTasks = result['updatedTasks'] as List<List<dynamic>>;
      final errors = result['errors'] as List<String>;

      // Update toDoList with tasks that now have Notion page IDs
      toDoList.value = updatedTasks;

      String message = 'Sync complete!\n';
      if (created > 0) message += '✓ $created tasks created\n';
      if (updated > 0) message += '✓ $updated tasks updated\n';
      if (failed > 0) {
        message += '✗ $failed failed\n';
        // Show first few errors
        if (errors.isNotEmpty) {
          message += '\nErrors:\n';
          for (int i = 0; i < errors.length && i < 3; i++) {
            message += '• ${errors[i]}\n';
          }
          if (errors.length > 3) {
            message += '• ... and ${errors.length - 3} more';
          }
        }
      }

      _showMessage(message.trim(), duration: Duration(seconds: 6));
    } catch (e) {
      _showMessage('Sync failed: $e', duration: Duration(seconds: 6));
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _showMessage(String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }

  void _showSetupInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notion Setup Instructions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Go to notion.so and sign in\n\n'
                '2. Go to Settings & Members > Integrations\n\n'
                '3. Create a new integration and copy the API key\n\n'
                '4. Create a database in Notion with these properties:\n'
                '   • Name (Title)\n'
                '   • Status (Status)\n'
                '   • Folder (Select)\n'
                '   • Due Date (Date)\n\n'
                '5. Share the database with your integration\n\n'
                '6. Copy the database ID from the URL:\n'
                '   notion.so/[workspace]/[DATABASE_ID]?v=...',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getSyncStateText(SyncState state) {
    switch (state) {
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.success:
        return 'Active';
      case SyncState.error:
        return 'Error';
      case SyncState.idle:
        return 'Active';
      case SyncState.disabled:
        return 'Disabled';
    }
  }

  Color? _getSyncStateColor(SyncState state) {
    switch (state) {
      case SyncState.syncing:
        return Colors.blue;
      case SyncState.success:
      case SyncState.idle:
        return Colors.green;
      case SyncState.error:
        return Colors.red;
      case SyncState.disabled:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _databaseIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 242, 242, 247),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(IconsaxPlusLinear.arrow_left_1),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                  Text(
                    "Notion Integration",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: _showSetupInstructions,
                    icon: Icon(IconsaxPlusLinear.info_circle),
                  ),
                ],
              ),

              SizedBox(height: 25),

              // Connection Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                width: 353,
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isConnected
                          ? IconsaxPlusBold.tick_circle
                          : IconsaxPlusLinear.info_circle,
                      color: _isConnected ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: 13),
                    Text(
                      _isConnected ? 'Connected' : 'Not connected',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              // Auto-sync Status (when connected)
              if (_isConnected) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  width: 353,
                  decoration: BoxDecoration(
                    color: ColorScheme.of(context).surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(IconsaxPlusLinear.autobrightness, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Auto-sync',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ValueListenableBuilder<SyncState>(
                        valueListenable: NotionAutoSyncService.instance.syncState,
                        builder: (context, state, _) {
                          return _buildInfoRow(
                            'Status',
                            _getSyncStateText(state),
                            color: _getSyncStateColor(state),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder<String?>(
                        valueListenable: NotionAutoSyncService.instance.lastSyncTime,
                        builder: (context, lastSync, _) {
                          if (lastSync != null) {
                            try {
                              final syncTime = DateTime.parse(lastSync);
                              final timeAgo = _getTimeAgo(syncTime);
                              return _buildInfoRow('Last synced', timeAgo);
                            } catch (e) {
                              return _buildInfoRow('Last synced', 'Never');
                            }
                          }
                          return _buildInfoRow('Last synced', 'Never');
                        },
                      ),
                      SizedBox(height: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: NotionAutoSyncService.instance.syncedTasksCount,
                        builder: (context, count, _) {
                          return _buildInfoRow('Tasks synced', '$count');
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
              ],

              // Configuration
              if (!_isConnected) ...[
                Container(
                  padding: EdgeInsets.all(20),
                  width: 353,
                  decoration: BoxDecoration(
                    color: ColorScheme.of(context).surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Key',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          hintText: 'secret_...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(255, 250, 250, 250),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Database ID',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _databaseIdController,
                        decoration: InputDecoration(
                          hintText: 'abc123...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(255, 250, 250, 250),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _connectNotion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorScheme.of(context).primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Connect to Notion'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Sync Actions (when connected)
              if (_isConnected) ...[
                Container(
                  padding: EdgeInsets.all(20),
                  width: 353,
                  decoration: BoxDecoration(
                    color: ColorScheme.of(context).surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isSyncing ? null : _syncToNotion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorScheme.of(context).primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isSyncing
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(IconsaxPlusLinear.refresh),
                          label: Text(_isSyncing ? 'Syncing...' : 'Force Sync Now'),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _disconnectNotion,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Disconnect'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 25),

              // Info Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _isConnected
                      ? 'Auto-sync is enabled. Your tasks will automatically sync to Notion within 3 seconds of any changes.'
                      : 'Your tasks will be synced to your Notion database with their folder and due date information.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
