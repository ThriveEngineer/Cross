import 'package:cross/Controller/todo_list.dart';
import 'package:cross/View/folder_page.dart';
import 'package:cross/View/folder_page.dart' as folder_page;
import 'package:cross/View/today_page.dart';
import 'package:cross/View/upcoming_page.dart';
import 'package:cross/widgets/fab.dart';
import 'package:flutter/material.dart';
import 'package:cross/widgets/appbar.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class BottomnavigationbarWidget extends StatefulWidget {
  const BottomnavigationbarWidget({super.key});

  @override
  State<BottomnavigationbarWidget> createState() => _BottomnavigationbarWidgetState();
}

class _BottomnavigationbarWidgetState extends State<BottomnavigationbarWidget> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    TodayPage(),
    UpcomingPage(),
    FolderPage(),
  ];

  void _showFolderMoveDialog(BuildContext context) {
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
                  'Move ${selectedTasks.value.length} task${selectedTasks.value.length > 1 ? 's' : ''} to folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
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
                          _moveTasksToFolder(folder['name'] as String);
                          Navigator.pop(context);
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
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Tasks'),
          content: Text('Are you sure you want to delete ${selectedTasks.value.length} task${selectedTasks.value.length > 1 ? 's' : ''}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedTasks();
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _moveTasksToFolder(String targetFolder) {
    final newList = List<List<dynamic>>.from(toDoList.value);

    for (final task in selectedTasks.value) {
      final index = newList.indexOf(task);
      if (index != -1) {
        final taskName = task[0];
        final isCompleted = task.length > 1 ? task[1] : false;
        final previousFolder = task.length > 3 && task[3] != null ? task[3] : null;
        final dateValue = task.length > 4 ? task[4] : null;

        newList[index] = [
          taskName,
          isCompleted,
          targetFolder,
          previousFolder,
          dateValue,
        ];
      }
    }

    toDoList.value = newList;
    selectedTasks.value = Set<List<dynamic>>.from({});
    selectionMode.value = false;
  }

  void _deleteSelectedTasks() {
    final newList = List<List<dynamic>>.from(toDoList.value);
    newList.removeWhere((task) => selectedTasks.value.contains(task));
    toDoList.value = newList;
    selectedTasks.value = Set<List<dynamic>>.from({});
    selectionMode.value = false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: selectionMode,
        builder: (context, inSelectionMode, _) {
          if (inSelectionMode) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Delete and folder change buttons container
                ValueListenableBuilder<Set<List<dynamic>>>(
                  valueListenable: selectedTasks,
                  builder: (context, selected, _) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Move to folder button
                          IconButton(
                            onPressed: selected.isEmpty ? null : () {
                              _showFolderMoveDialog(context);
                            },
                            icon: Icon(
                              IconsaxPlusLinear.folder_cross,
                              color: selected.isEmpty 
                                ? Colors.grey.shade400 
                                : Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(width: 8),
                          // Delete button
                          IconButton(
                            onPressed: selected.isEmpty ? null : () {
                              _showDeleteConfirmation(context);
                            },
                            icon: Icon(
                              IconsaxPlusLinear.trash,
                              color: selected.isEmpty 
                                ? Colors.grey.shade400 
                                : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(width: 16),
                // Timer FAB
                Fab(
                  onSave: () {
                    if (titleController.text.isNotEmpty) {
                      final newList = List<List<dynamic>>.from(toDoList.value);
                      newList.add([
                        titleController.text,
                        false,
                        selectedFolder.value,
                        null, // previousFolder placeholder
                        selectedDate.value?.toIso8601String(), // date as ISO string
                      ]);
                      toDoList.value = newList;
                      titleController.clear();
                      selectedFolder.value = 'Inbox';
                      selectedDate.value = null;
                      Navigator.pop(context);
                    }
                  },
                  foldersList: foldersList,
                ),
              ],
            );
          } else {
            return Fab(
              onSave: () {
                if (titleController.text.isNotEmpty) {
                  final newList = List<List<dynamic>>.from(toDoList.value);
                  newList.add([
                    titleController.text,
                    false,
                    selectedFolder.value,
                    null, // previousFolder placeholder
                    selectedDate.value?.toIso8601String(), // date as ISO string
                  ]);
                  toDoList.value = newList;
                  titleController.clear();
                  selectedFolder.value = 'Inbox';
                  selectedDate.value = null;
                  Navigator.pop(context);
                }
              },
              foldersList: foldersList,
            );
          }
        },
      ),
      appBar: AppbarWidget(),
      body: _tabs[_currentIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Color.fromARGB(255, 202, 202, 202), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar_1, size: 28,), label: "", activeIcon: Icon(IconsaxPlusBold.calendar_1, size: 30,)),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar, size: 28,), label: "", activeIcon: Icon(IconsaxPlusBold.calendar, size: 30,)),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.folder, size: 28,), label: "", activeIcon: Icon(IconsaxPlusBold.folder, size: 30,)),
            ]),
      ),
    );
  }
}