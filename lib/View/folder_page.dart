import 'package:cross/Controller/todo_list.dart';
import 'package:cross/view/folder_detail_page.dart';
import 'package:cross/widgets/fab.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

// ValueNotifier for folders list
final ValueNotifier<List<Map<String, dynamic>>> foldersList =
    ValueNotifier<List<Map<String, dynamic>>>([
  {'name': 'Inbox', 'icon': IconsaxPlusLinear.directbox_notif, 'isDefault': true},
  {'name': 'Important', 'icon': IconsaxPlusLinear.heart, 'isDefault': true},
  {'name': 'Completed', 'icon': IconsaxPlusLinear.tick_square, 'isDefault': true},
]);

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _folderController = TextEditingController();

  void _navigateToFolder(String folderName, IconData folderIcon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailPage(
          folderName: folderName,
          folderIcon: folderIcon,
        ),
      ),
    );
  }

  void showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            controller: _folderController,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _folderController.clear();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_folderController.text.trim().isNotEmpty) {
                  createFolder(_folderController.text.trim());
                  Navigator.pop(context);
                  _folderController.clear();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void createFolder(String folderName) {
    final newList = List<Map<String, dynamic>>.from(foldersList.value);
    newList.add({
      'name': folderName,
      'icon': IconsaxPlusLinear.folder,
      'isDefault': false,
    });
    foldersList.value = newList;
  }

  void _deleteFolder(int index) {
    final newList = List<Map<String, dynamic>>.from(foldersList.value);
    newList.removeAt(index);
    foldersList.value = newList;
  }

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Fab(
        onSave: () {},
        isOnFoldersPage: true,
        onCreateFolder: showCreateFolderDialog,
        foldersList: foldersList,
      ),
      body: Column(
        // header
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 25),
            child: Row(
              children: [
                const Text(
                  "Folders",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: foldersList,
              builder: (context, folders, _) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final folderName = folder['name'] as String;
                    final folderIcon = folder['icon'] as IconData;
                    final isDefault = folder['isDefault'] as bool;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: InkWell(
                        onTap: () => _navigateToFolder(folderName, folderIcon),
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 243, 243, 243),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(folderIcon, size: 24),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  folderName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                                Icon(
                                  IconsaxPlusLinear.arrow_right_3, size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}