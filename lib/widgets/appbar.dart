import 'package:cross/View/settings_page.dart';
import 'package:cross/widgets/vertical_menu.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/view_settings.dart';
import 'package:cross/services/notion_auto_sync_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  State<AppbarWidget> createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  @override
  final GlobalKey _buttonKey = GlobalKey();
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: selectionMode,
      builder: (context, inSelectionMode, _) {
        if (inSelectionMode) {
          return AppBar(
            leadingWidth: 80,
            leading: TextButton(
              onPressed: () {
                selectionMode.value = false;
                selectedTasks.value = Set<List<dynamic>>.from({}); // Clear selected tasks
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Select all tasks from the main list
                  final allTasks = Set<List<dynamic>>.from(toDoList.value);
                  selectedTasks.value = allTasks;
                },
                child: Text(
                  'Select All',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                ),
              ),
              SizedBox(width: 15),
            ],
          );
        } else {
          return AppBar(
            actions: [
              SyncStatusIndicator(),
              SizedBox(width: 8),
              IconButton(
                key: _buttonKey,
                onPressed: () {
                  showCustomMenu(
                    context,
                    _buttonKey,
                    [
                      MenuItem(
                        label: "View",
                        icon: IconsaxPlusLinear.setting_3,
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            enableDrag: true,
                            showDragHandle: true,
                            backgroundColor: Color.fromARGB(255, 242, 242, 247),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            context: context,
                            builder: (context) => ViewSettings(),
                          );
                        },
                      ),
                      MenuItem(
                        label: "Select",
                        icon: IconsaxPlusLinear.mouse_square,
                        onTap: () {
                          Navigator.pop(context);
                          selectionMode.value = true; // Enter selection mode
                        },
                      ),
                      MenuItem(
                        label: "Settings", 
                        icon: IconsaxPlusLinear.setting, 
                        onTap: () {
                          Navigator.pop(context);
                          showCupertinoSheet(
                            enableDrag: true,
                            context: context,
                            builder: (context) => Material(
                                color: Color.fromARGB(255, 242, 242, 247),
                                child: SettingsPage()
                            ),
                          );
                        }
                        ),
                    ],
                  );
                },
                icon: Icon(IconsaxPlusLinear.menu),
              ),
              SizedBox(width: 15),
            ],
          );
        }
      },
    );
  }
}

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SyncState>(
      valueListenable: NotionAutoSyncService.instance.syncState,
      builder: (context, syncState, _) {
        // Don't show icon if Notion is not connected
        if (syncState == SyncState.disabled) {
          return SizedBox.shrink();
        }

        // Determine icon and color based on sync state
        IconData icon;
        Color color;

        switch (syncState) {
          case SyncState.syncing:
            icon = IconsaxPlusLinear.cloud;
            color = Colors.blue;
            break;
          case SyncState.success:
            icon = IconsaxPlusLinear.cloud_change;
            color = Colors.green;
            break;
          case SyncState.error:
            icon = IconsaxPlusLinear.cloud_cross;
            color = Colors.red;
            break;
          case SyncState.idle:
          default:
            icon = IconsaxPlusLinear.cloud;
            color = Colors.grey;
            break;
        }

        return IconButton(
          icon: syncState == SyncState.syncing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, color: color, size: 22),
          tooltip: _getTooltipText(syncState),
          onPressed: () => _showSyncDetails(context),
        );
      },
    );
  }

  String _getTooltipText(SyncState syncState) {
    switch (syncState) {
      case SyncState.syncing:
        return 'Syncing to Notion...';
      case SyncState.success:
        return 'Synced to Notion';
      case SyncState.error:
        return 'Sync failed - tap for details';
      case SyncState.idle:
        return 'Notion connected';
      case SyncState.disabled:
        return 'Notion not connected';
    }
  }

  void _showSyncDetails(BuildContext context) {
    final autoSync = NotionAutoSyncService.instance;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notion Sync Status'),
        content: ValueListenableBuilder<SyncState>(
          valueListenable: autoSync.syncState,
          builder: (context, state, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow('Status:', _getStatusText(state)),
                SizedBox(height: 8),
                ValueListenableBuilder<String?>(
                  valueListenable: autoSync.lastSyncTime,
                  builder: (context, lastSync, _) {
                    if (lastSync != null) {
                      try {
                        final syncTime = DateTime.parse(lastSync);
                        final timeAgo = _getTimeAgo(syncTime);
                        return _buildStatusRow('Last synced:', timeAgo);
                      } catch (e) {
                        return SizedBox.shrink();
                      }
                    }
                    return _buildStatusRow('Last synced:', 'Never');
                  },
                ),
                SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: autoSync.syncedTasksCount,
                  builder: (context, count, _) {
                    if (count > 0) {
                      return _buildStatusRow('Tasks synced:', '$count');
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Text(value),
      ],
    );
  }

  String _getStatusText(SyncState state) {
    switch (state) {
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.success:
        return 'Up to date';
      case SyncState.error:
        return 'Failed';
      case SyncState.idle:
        return 'Ready';
      case SyncState.disabled:
        return 'Disabled';
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
}