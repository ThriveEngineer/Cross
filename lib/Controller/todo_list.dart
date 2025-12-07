import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

// Use a ValueNotifier so changes to the list notify listeners and rebuild UI.
final ValueNotifier<List<List<dynamic>>> toDoList =
    ValueNotifier<List<List<dynamic>>>([
]);

class TodoList extends StatefulWidget {
  final bool showCompleted; // Flag to show or hide completed tasks

  const TodoList({super.key, this.showCompleted = false});

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
      final newCompletedStatus = !(newList[mainListIndex][1] as bool);
      
      // Update task: toggle completion and move to Completed folder if completed
      newList[mainListIndex] = [
        newList[mainListIndex][0], // task name
        newCompletedStatus, // new completion status
        newCompletedStatus ? 'Completed' : (newList[mainListIndex].length > 2 ? newList[mainListIndex][2] : 'Inbox')
      ];
      toDoList.value = newList;
    }
  }

  // Filter tasks based on showCompleted flag
  List<List<dynamic>> _getFilteredTasks(List<List<dynamic>> allTasks) {
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
              taskCompleted: filteredList[index][1],
              onChanged: (value) => checkBoxChanged(value, index, filteredList),
            );
          },
        );
      },
    );
  }
}