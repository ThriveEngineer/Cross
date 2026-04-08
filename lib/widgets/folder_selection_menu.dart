import 'package:cross/Controller/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

enum FolderSelectionAction { deleteFolder }

Future<void> showFolderSelectionMenu({
  required BuildContext context,
  required int folderIndex,
  required bool isDefault,
  required Offset anchor,
}) async {
  selectFolderForActions(folderIndex: folderIndex, isDefault: isDefault);
  if (isDefault) return;

  final action = await _showFolderPopupAt(context, anchor);
  if (!context.mounted || action == null) return;
  _runFolderAction(context, action);
}

Future<void> showSelectedFoldersActionMenu(BuildContext context) async {
  if (selectedFolders.value.isEmpty) return;

  final action = await showModalBottomSheet<FolderSelectionAction>(
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
              leading: const Icon(IconsaxPlusLinear.trash, color: Colors.red),
              title: const Text('Delete folder'),
              onTap: () => Navigator.pop(
                menuContext,
                FolderSelectionAction.deleteFolder,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (!context.mounted || action == null) return;
  _runFolderAction(context, action);
}

Future<FolderSelectionAction?> _showFolderPopupAt(
  BuildContext context,
  Offset anchor,
) {
  final screen = MediaQuery.of(context).size;
  final menuTop = anchor.dy + 12;

  return showMenu<FolderSelectionAction>(
    context: context,
    position: RelativeRect.fromLTRB(
      anchor.dx,
      menuTop,
      screen.width - anchor.dx,
      screen.height - menuTop,
    ),
    items: const [
      PopupMenuItem<FolderSelectionAction>(
        value: FolderSelectionAction.deleteFolder,
        child: Row(
          children: [
            Icon(IconsaxPlusLinear.trash, size: 20, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete folder'),
          ],
        ),
      ),
    ],
  );
}

void _runFolderAction(BuildContext context, FolderSelectionAction action) {
  switch (action) {
    case FolderSelectionAction.deleteFolder:
      _showDeleteFoldersConfirmation(context);
      break;
  }
}

void _showDeleteFoldersConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Folders'),
        content: Text(
          'Are you sure you want to delete ${selectedFolders.value.length} folder${selectedFolders.value.length > 1 ? 's' : ''}? Tasks in these folders will be moved to Inbox.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteSelectedFoldersAndMoveTasksToInbox();
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}
