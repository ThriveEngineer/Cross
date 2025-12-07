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
            GestureDetector(
            onTap: widget.onChanged != null 
              ? () => widget.onChanged!(!widget.taskCompleted)
              : null,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.taskCompleted ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: widget.taskCompleted ? Colors.black : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: widget.taskCompleted
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
            ),
          ),
            SizedBox(width: 15,),
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