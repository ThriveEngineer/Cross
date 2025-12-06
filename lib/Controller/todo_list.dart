import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

// Use a ValueNotifier so changes to the list notify listeners and rebuild UI.
final ValueNotifier<List<List<dynamic>>> toDoList =
    ValueNotifier<List<List<dynamic>>>([
]);

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  // checks if task is completed
  void checkBoxChanged(bool? value, int index) {
    // Create a new list copy and toggle the value so ValueNotifier notifies.
    final newList = List<List<dynamic>>.from(toDoList.value);
    newList[index] = [newList[index][0], !(newList[index][1] as bool)];
    toDoList.value = newList;
  }

  @override
  // ListView builder for the tasks
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<List<dynamic>>>(
      valueListenable: toDoList,
      builder: (context, list, _) {
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return TodoTile(
              taskName: list[index][0],
              taskCompleted: list[index][1],
              onChanged: (value) => checkBoxChanged(value, index),
            );
          },
        );
      },
    );
  }
}