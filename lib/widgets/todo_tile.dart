import 'package:flutter/material.dart';

class TodoTile extends StatefulWidget {

  final String taskName;
  final bool taskCompleted;
  final Function(bool?) onChanged;

  const TodoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        child: Row(
          children: [
            Checkbox(value: widget.taskCompleted, onChanged: widget.onChanged),
            SizedBox(width: 5,),
            Text(
              widget.taskName,
              style: TextStyle(
                color: widget.taskCompleted ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
              ),
          ],
        ),
      ),
    );
  }
}