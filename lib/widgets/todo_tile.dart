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

class _TodoTileState extends State<TodoTile> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _checkboxController;
  late AnimationController _completionController;
  late Animation<double> _checkboxAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkboxController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _checkboxAnimation = CurvedAnimation(
      parent: _checkboxController,
      curve: Curves.easeOutBack,
    );

    _completionController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.taskCompleted) {
      _checkboxController.value = 1.0;
      _completionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TodoTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taskCompleted != oldWidget.taskCompleted) {
      if (widget.taskCompleted) {
        _checkboxController.forward();
        _completionController.forward();
      } else {
        _checkboxController.reverse();
        _completionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Easter egg: Check if task contains "Stranger Things"
    final bool isStrangerThings = widget.taskName.toLowerCase().contains('stranger things');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
            },
            onTap: () => widget.onChanged(!widget.taskCompleted),
            child: AnimatedScale(
              scale: _isPressed ? 0.97 : 1.0,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isStrangerThings
                ? Colors.red.withValues(alpha: 0.3)
                : (widget.isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                    : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Easter egg: Show demo_head.png for Stranger Things tasks
                isStrangerThings
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        'lib/assets/demo_head.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.taskCompleted ? Colors.black : Colors.transparent,
                        border: Border.all(
                          color: widget.isSelected
                            ? Theme.of(context).primaryColor
                            : (widget.taskCompleted ? Colors.black : Colors.grey),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: widget.taskCompleted
                        ? ScaleTransition(
                            scale: _checkboxAnimation,
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          )
                        : null,
                    ),
                SizedBox(width: 15,),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      color: widget.taskCompleted ? Colors.grey : Colors.black,
                      fontSize: 16,
                      decoration: widget.taskCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    ),
                    child: Text(widget.taskName),
                  ),
                ),
                SizedBox(width: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: showFolderNames,
                  builder: (context, showFolder, _) {
                    return AnimatedSize(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: showFolder ? 1.0 : 0.0,
                        child: showFolder
                          ? Text(
                              widget.folderName,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                          : SizedBox.shrink(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
        ),
          ),
        );
  }
}
