import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/fab.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

enum TaskSelectionAction { focusTimer, moveFolder, deleteTask }

Future<void> showTaskSelectionMenu({
  required BuildContext context,
  required List<dynamic> task,
  required Offset anchor,
}) async {
  selectTaskForActions(task);
  final action = await _showTaskPopupAt(context, anchor);
  if (!context.mounted || action == null) return;
  _runTaskAction(context, action);
}

Future<void> showSelectedTasksActionMenu(BuildContext context) async {
  if (selectedTasks.value.isEmpty) return;

  final action = await showModalBottomSheet<TaskSelectionAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (menuContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(IconsaxPlusLinear.clock_1),
              title: const Text('Focus timer'),
              onTap: () =>
                  Navigator.pop(menuContext, TaskSelectionAction.focusTimer),
            ),
            ListTile(
              leading: const Icon(IconsaxPlusLinear.folder_cross),
              title: const Text('Move task'),
              onTap: () =>
                  Navigator.pop(menuContext, TaskSelectionAction.moveFolder),
            ),
            ListTile(
              leading: const Icon(IconsaxPlusLinear.trash, color: Colors.red),
              title: const Text('Delete task'),
              onTap: () =>
                  Navigator.pop(menuContext, TaskSelectionAction.deleteTask),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (!context.mounted || action == null) return;
  _runTaskAction(context, action);
}

Future<TaskSelectionAction?> _showTaskPopupAt(
  BuildContext context,
  Offset anchor,
) {
  final screen = MediaQuery.of(context).size;
  final menuTop = anchor.dy + 12;

  return showMenu<TaskSelectionAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      anchor.dx,
      menuTop,
      screen.width - anchor.dx,
      screen.height - menuTop,
    ),
    items: const [
      PopupMenuItem<TaskSelectionAction>(
        value: TaskSelectionAction.focusTimer,
        child: Row(
          children: [
            Icon(IconsaxPlusLinear.clock_1, size: 20),
            SizedBox(width: 10),
            Text('Focus timer'),
          ],
        ),
      ),
      PopupMenuItem<TaskSelectionAction>(
        value: TaskSelectionAction.moveFolder,
        child: Row(
          children: [
            Icon(IconsaxPlusLinear.folder_cross, size: 20),
            SizedBox(width: 10),
            Text('Move task'),
          ],
        ),
      ),
      PopupMenuItem<TaskSelectionAction>(
        value: TaskSelectionAction.deleteTask,
        child: Row(
          children: [
            Icon(IconsaxPlusLinear.trash, size: 20, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete task'),
          ],
        ),
      ),
    ],
  );
}

void _runTaskAction(BuildContext context, TaskSelectionAction action) {
  switch (action) {
    case TaskSelectionAction.focusTimer:
      showFocusTimerBottomSheet(context);
      break;
    case TaskSelectionAction.moveFolder:
      _showFolderMoveDialog(context);
      break;
    case TaskSelectionAction.deleteTask:
      _showDeleteConfirmation(context);
      break;
  }
}

void _showFolderMoveDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Move ${selectedTasks.value.length} task${selectedTasks.value.length > 1 ? 's' : ''} to folder',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: foldersList,
              builder: (context, folders, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    return ListTile(
                      leading: Icon(folder['icon'] as IconData),
                      title: Text(folder['name'] as String),
                      onTap: () {
                        moveSelectedTasksToFolder(folder['name'] as String);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

void _showDeleteConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Tasks'),
        content: Text(
          'Are you sure you want to delete ${selectedTasks.value.length} task${selectedTasks.value.length > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteSelectedTasks();
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
