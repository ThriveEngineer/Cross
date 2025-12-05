import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

// List
List<List<dynamic>> toDoList = [
  ["Task 1", false]
];

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  // checks if task is completed
  void checkBoxChanged(bool? value, int index) {
  setState(() {
    toDoList[index][1] = !toDoList[index][1];
  });
}

  @override
  // ListView builder for the tasks
  Widget build(BuildContext context) {
    return ListView.builder(
              itemCount: toDoList.length,
              itemBuilder: (context, index) {
                return TodoTile(
                  taskName: toDoList[index][0],
                  taskCompleted: toDoList[index][1],
                  onChanged: (value) => checkBoxChanged(value, index),
                );
              },
            );
  }
}