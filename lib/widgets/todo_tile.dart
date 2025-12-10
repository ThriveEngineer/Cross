import 'package:flutter/material.dart';
import 'package:cross/Controller/todo_list.dart';

class TodoTile extends StatefulWidget {

  final String taskName;
  final bool taskCompleted;
  final String folderName;
  final bool isSelected;
  final Function(bool?) onChanged;

  const TodoTile({
    super.key,
    required this.taskName,
    required this.folderName,
    required this.isSelected,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.taskCompleted),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: widget.taskCompleted ? Colors.black : Colors.transparent,
                border: Border.all(
                  color: widget.isSelected ? Theme.of(context).primaryColor : (widget.taskCompleted ? Colors.black : Colors.grey),
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
              SizedBox(width: 15,),
              Text(
                widget.taskName,
                style: TextStyle(
                  color: widget.taskCompleted ? Colors.grey : Colors.black,
                  fontSize: 16,
                ),
                ),
                Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: showFolderNames,
                builder: (context, showFolder, _) {
                  if (!showFolder) return SizedBox.shrink();
                  return Text(
                    widget.folderName,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}