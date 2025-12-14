import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class FolderDetailPage extends StatefulWidget {
  final String folderName;
  final IconData folderIcon;

  const FolderDetailPage({
    super.key,
    required this.folderName,
    required this.folderIcon,
  });

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  // Get tasks for this folder
  List<List<dynamic>> _getTasksForFolder() {
    final tasks = toDoList.value.where((task) {
      // task structure: [taskName, isCompleted, folderName]
      if (task.length > 2) {
        return task[2] == widget.folderName;
      }
      return false;
    }).toList();

    // Apply current sort option
    return sortTasks(tasks, currentSortOption.value);
  }

  void checkBoxChanged(bool? value, int index) {
    final tasks = _getTasksForFolder();
    if (index < tasks.length) {
      final taskToUpdate = tasks[index];
      
      // Find this task in the main list and update it
      final mainListIndex = toDoList.value.indexOf(taskToUpdate);
      if (mainListIndex != -1) {
        final newList = List<List<dynamic>>.from(toDoList.value);
        final newCompletedStatus = !(newList[mainListIndex][1] as bool);
        
        newList[mainListIndex] = [
          newList[mainListIndex][0],
          newCompletedStatus,
          newCompletedStatus ? 'Completed' : (newList[mainListIndex].length > 2 ? newList[mainListIndex][2] : 'Inbox')
        ];
        toDoList.value = newList;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconsaxPlusLinear.arrow_left_1),
          onPressed: () => Navigator.pop(context),
          ),
        title: Row(
          children: [
            Icon(widget.folderIcon),
            SizedBox(width: 10),
            Text(widget.folderName),
          ],
        ),
      ),
      body: ValueListenableBuilder<SortOption>(
        valueListenable: currentSortOption,
        builder: (context, sortOption, _) {
          return ValueListenableBuilder<List<List<dynamic>>>(
            valueListenable: toDoList,
            builder: (context, list, _) {
              final folderTasks = _getTasksForFolder();

              if (folderTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.folderIcon,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No tasks in ${widget.folderName}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                itemCount: folderTasks.length,
                itemBuilder: (context, index) {
                  final task = folderTasks[index];
                  return ValueListenableBuilder<Set<List<dynamic>>>(
                    valueListenable: selectedTasks,
                    builder: (context, selected, _) {
                      final isSelected = selected.contains(task);
                      return TodoTile(
                        taskName: task[0],
                        taskCompleted: task[1],
                        isSelected: isSelected,
                        onChanged: (value) {
                          if (selectionMode.value) {
                            final newSet = Set<List<dynamic>>.from(selectedTasks.value);
                            if (isSelected) newSet.remove(task);
                            else newSet.add(task);
                            selectedTasks.value = newSet;
                          } else {
                            checkBoxChanged(value, index);
                          }
                        },
                        folderName: '',
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}