import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

// Use a ValueNotifier so changes to the list notify listeners and rebuild UI.
final ValueNotifier<List<List<dynamic>>> toDoList =
  ValueNotifier<List<List<dynamic>>>([
]);

// Controls whether the Today page shows completed tasks.
// Default: false => do not show completed tasks in Today.
final ValueNotifier<bool> showCompletedInToday = ValueNotifier<bool>(false);

class TodoList extends StatefulWidget {
  final bool showCompleted; // Flag: true => only completed, false => only non-completed
  final bool showAll; // If true, show all tasks regardless of completion

  const TodoList({super.key, this.showCompleted = false, this.showAll = false});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  // checks if task is completed and moves to Completed folder
  void checkBoxChanged(bool? value, int index, List<List<dynamic>> filteredList) {
    // Find the actual task in the main list
    final taskToUpdate = filteredList[index];
    final mainListIndex = toDoList.value.indexOf(taskToUpdate);
    
    if (mainListIndex != -1) {
      final newList = List<List<dynamic>>.from(toDoList.value);
      final currentTask = newList[mainListIndex];
      final currentCompleted = (currentTask.length > 1) ? (currentTask[1] as bool) : false;
      final newCompletedStatus = !currentCompleted;

      final taskName = currentTask[0];
      final currentFolder = currentTask.length > 2 ? currentTask[2] as String : 'Inbox';
      final storedPreviousFolder = currentTask.length > 3 ? currentTask[3] as String : null;

      if (newCompletedStatus) {
        // Marking as completed: store current folder in index 3 and set folder to 'Completed'
        newList[mainListIndex] = [
          taskName,
          true,
          'Completed',
          currentFolder,
        ];
      } else {
        // Marking as not completed: restore previous folder if stored, otherwise try to use currentFolder (if not 'Completed'), else 'Inbox'
        String restoreFolder = 'Inbox';
        if (storedPreviousFolder != null && storedPreviousFolder.isNotEmpty) {
          restoreFolder = storedPreviousFolder;
        } else if (currentFolder != 'Completed') {
          restoreFolder = currentFolder;
        }

        newList[mainListIndex] = [
          taskName,
          false,
          restoreFolder,
        ];
      }
      toDoList.value = newList;
    }
  }

  // Filter tasks based on showCompleted flag
  List<List<dynamic>> _getFilteredTasks(List<List<dynamic>> allTasks) {
    if (widget.showAll) {
      // Show all tasks (used by Today view when user enables showing completed tasks)
      return List<List<dynamic>>.from(allTasks);
    }

    if (widget.showCompleted) {
      // Show only completed tasks (for Completed folder)
      return allTasks.where((task) {
        if (task.length > 2) {
          return task[2] == 'Completed';
        }
        return false;
      }).toList();
    } else {
      // Show only non-completed tasks (for other pages)
      return allTasks.where((task) {
        if (task.length > 2) {
          return task[2] != 'Completed';
        }
        return true; // Show old tasks without folder assignment
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<List<dynamic>>>(
      valueListenable: toDoList,
      builder: (context, list, _) {
        final filteredList = _getFilteredTasks(list);
        
        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return TodoTile(
              taskName: filteredList[index][0],
              folderName: filteredList[index].length > 2 ? filteredList[index][2] : 'Inbox', // Pass folder name
              taskCompleted: filteredList[index][1],
              onChanged: (value) => checkBoxChanged(value, index, filteredList),
            );
          },
        );
      },
    );
  }
}