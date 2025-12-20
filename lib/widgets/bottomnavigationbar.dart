import 'package:cross/Controller/todo_list.dart';
import 'package:cross/View/folder_page.dart';
import 'package:cross/View/today_page.dart';
import 'package:cross/View/upcoming_page.dart';
import 'package:cross/widgets/fab.dart';
import 'package:cross/widgets/tick_button.dart';
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
  final TextEditingController _folderController = TextEditingController();
  IconData _selectedIcon = IconsaxPlusLinear.folder;

  final List<IconData> _availableIcons = [
    IconsaxPlusLinear.folder,
    IconsaxPlusLinear.folder_favorite,
    IconsaxPlusLinear.archive,
    IconsaxPlusLinear.task_square,
    IconsaxPlusLinear.note,
    IconsaxPlusLinear.briefcase,
    IconsaxPlusLinear.home,
    IconsaxPlusLinear.shopping_cart,
    IconsaxPlusLinear.heart,
    IconsaxPlusLinear.star,
    IconsaxPlusLinear.book,
    IconsaxPlusLinear.trend_up,
  ];

  final List<Widget> _tabs = [
    TodayPage(),
    UpcomingPage(),
    FolderPage(),
  ];

  void _showFolderMoveDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
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
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(folder['icon'] as IconData),
                            title: Text(folder['name'] as String),
                            onTap: () {
                              _moveTasksToFolder(folder['name'] as String);
                              Navigator.pop(context);
                            },
                          ),
                        ),
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
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
        ),
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
        final notionPageId = task.length > 5 ? task[5] : null;

        newList[index] = [
          taskName,
          isCompleted,
          targetFolder,
          previousFolder,
          dateValue,
          notionPageId,
          TaskTimestamp.now(), // Add timestamp
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

  void _showCreateFolderDialog() {
    // Reset to default icon
    setState(() {
      _selectedIcon = IconsaxPlusLinear.folder;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 175,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 17,
                        top: 10,
                        right: 17,
                        bottom: 10,
                      ),
                      child: TextField(
                        autofocus: true,
                        controller: _folderController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Folder name',
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
                          GestureDetector(
                            onTap: () => _showIconSelector(context, setModalState),
                            child: Chip(
                              side: BorderSide(
                                color: Color.fromARGB(255, 179, 179, 179),
                              ),
                              label: Row(
                                children: [
                                  Icon(_selectedIcon),
                                  SizedBox(width: 10),
                                  Text('Icon'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          TickButton(
                            onPressed: () {
                              if (_folderController.text.trim().isNotEmpty) {
                                _createFolder(_folderController.text.trim());
                                Navigator.pop(context);
                                _folderController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showIconSelector(BuildContext context, StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Select Icon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = _availableIcons[index];
                    final isSelected = _selectedIcon == icon;

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon;
                          });
                          setModalState(() {
                            _selectedIcon = icon;
                          });
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 32,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ),
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

  void _createFolder(String folderName) {
    final newList = List<Map<String, dynamic>>.from(foldersList.value);
    newList.add({
      'name': folderName,
      'icon': _selectedIcon,
      'isDefault': false,
    });
    foldersList.value = newList;
  }

  void _showDeleteFoldersConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Folders'),
          content: Text('Are you sure you want to delete ${selectedFolders.value.length} folder${selectedFolders.value.length > 1 ? 's' : ''}? Tasks in these folders will be moved to Inbox.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedFolders();
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedFolders() {
    final newList = List<Map<String, dynamic>>.from(foldersList.value);
    final foldersToDelete = <String>[];

    // Collect folder names to delete (in reverse order to maintain indices)
    final sortedIndices = selectedFolders.value.toList()..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndices) {
      if (index < newList.length) {
        final folder = newList[index];
        final isDefault = folder['isDefault'] as bool;

        // Only delete non-default folders
        if (!isDefault) {
          foldersToDelete.add(folder['name'] as String);
          newList.removeAt(index);
        }
      }
    }

    // Move tasks from deleted folders to Inbox
    if (foldersToDelete.isNotEmpty) {
      final taskList = List<List<dynamic>>.from(toDoList.value);
      for (int i = 0; i < taskList.length; i++) {
        final task = taskList[i];
        if (task.length > 2 && foldersToDelete.contains(task[2])) {
          final updatedTask = List<dynamic>.from(task);
          updatedTask[2] = 'Inbox';
          taskList[i] = updatedTask;
        }
      }
      toDoList.value = taskList;
    }

    foldersList.value = newList;
    selectedFolders.value = {};
  }

  @override
  void dispose() {
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: selectionMode,
        builder: (context, inSelectionMode, _) {
          if (inSelectionMode) {
            // Show different UI based on which page we're on
            if (_currentIndex == 2) {
              // Folders page - show folder delete button
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder<Set<int>>(
                    valueListenable: selectedFolders,
                    builder: (context, selected, _) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delete folders button
                            AnimatedScale(
                              scale: selected.isEmpty ? 0.9 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: selected.isEmpty ? null : () {
                                  _showDeleteFoldersConfirmation(context);
                                },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    IconsaxPlusLinear.trash,
                                    key: ValueKey(selected.isEmpty),
                                    color: selected.isEmpty
                                      ? Colors.grey.shade400
                                      : Colors.red,
                                  ),
                                ),
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
                          null,
                          selectedDate.value?.toIso8601String(),
                          null,
                          TaskTimestamp.now(),
                        ]);
                        toDoList.value = newList;
                        titleController.clear();
                        selectedFolder.value = 'Inbox';
                        selectedDate.value = null;
                        Navigator.pop(context);
                      }
                    },
                    foldersList: foldersList,
                    isOnFoldersPage: true,
                    onCreateFolder: _showCreateFolderDialog,
                  ),
                ],
              );
            } else {
              // Today/Upcoming page - show task operations
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete and folder change buttons container
                  ValueListenableBuilder<Set<List<dynamic>>>(
                    valueListenable: selectedTasks,
                    builder: (context, selected, _) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Move to folder button
                            AnimatedScale(
                              scale: selected.isEmpty ? 0.9 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: selected.isEmpty ? null : () {
                                  _showFolderMoveDialog(context);
                                },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    IconsaxPlusLinear.folder_cross,
                                    key: ValueKey(selected.isEmpty),
                                    color: selected.isEmpty
                                      ? Colors.grey.shade400
                                      : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Delete button
                            AnimatedScale(
                              scale: selected.isEmpty ? 0.9 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: selected.isEmpty ? null : () {
                                  _showDeleteConfirmation(context);
                                },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    IconsaxPlusLinear.trash,
                                    key: ValueKey(selected.isEmpty),
                                    color: selected.isEmpty
                                      ? Colors.grey.shade400
                                      : Colors.red,
                                  ),
                                ),
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
                          null,
                          selectedDate.value?.toIso8601String(),
                          null,
                          TaskTimestamp.now(),
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
            }
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
                    null, // notionPageId - will be filled when first synced
                    TaskTimestamp.now(), // Add timestamp
                  ]);
                  toDoList.value = newList;
                  titleController.clear();
                  selectedFolder.value = 'Inbox';
                  selectedDate.value = null;
                  Navigator.pop(context);
                }
              },
              foldersList: foldersList,
              isOnFoldersPage: _currentIndex == 2,
              onCreateFolder: _showCreateFolderDialog,
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