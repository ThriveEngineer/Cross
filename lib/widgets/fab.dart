import 'package:cross/widgets/tick_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

// Import the folders list - you'll need to export this from your folder page
// For now, we'll reference it here
// Make sure foldersList is accessible from your folder page

// Selected folder notifier
final ValueNotifier<String> selectedFolder = ValueNotifier<String>('Inbox');

class Fab extends StatelessWidget {
  final VoidCallback onSave;
  final bool isOnFoldersPage;
  final VoidCallback? onCreateFolder;
  final ValueNotifier<List<Map<String, dynamic>>>? foldersList;

  Fab({
    super.key,
    required this.onSave,
    this.isOnFoldersPage = false,
    this.onCreateFolder,
    this.foldersList,
  });

  void _showFolderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Folder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: foldersList!,
                  builder: (context, folders, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: selectedFolder,
                      builder: (context, currentFolder, _) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: folders.length,
                          itemBuilder: (context, index) {
                            final folder = folders[index];
                            return _buildFolderOption(
                              context,
                              folder['name'],
                              folder['icon'] as IconData,
                              currentFolder,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFolderOption(BuildContext context, String folderName, IconData icon, String currentFolder) {
    final isSelected = currentFolder == folderName;
    
    return ListTile(
      leading: Icon(icon),
      title: Text(folderName),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        selectedFolder.value = folderName;
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (isOnFoldersPage) {
          // Call the create folder callback
          if (onCreateFolder != null) {
            onCreateFolder!();
          }
        } else {
          // Show task creation bottom sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: 175,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 17, top: 10, right: 17, bottom: 10),
                        child: TextField(
                          autofocus: true,
                          controller: titleController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Task title',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22, top: 30),
                        child: Row(
                          children: [
                            ValueListenableBuilder<String>(
                              valueListenable: selectedFolder,
                              builder: (context, folder, _) {
                                return GestureDetector(
                                  onTap: () => _showFolderSelector(context),
                                  child: Chip(
                                    side: BorderSide(
                                        color: Color.fromARGB(255, 179, 179, 179)),
                                    label: Row(
                                      children: [
                                        Icon(IconsaxPlusLinear.directbox_notif),
                                        SizedBox(width: 10),
                                        Text(folder),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 12),
                            Chip(
                              side: BorderSide(
                                  color: Color.fromARGB(255, 179, 179, 179)),
                              label: Row(
                                children: [
                                  Icon(IconsaxPlusLinear.calendar),
                                  SizedBox(width: 10),
                                  Text("Today"),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            TickButton(onPressed: onSave),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: Icon(isOnFoldersPage ? IconsaxPlusLinear.folder_add : IconsaxPlusLinear.add),
    );
  }
}

final TextEditingController titleController = TextEditingController();