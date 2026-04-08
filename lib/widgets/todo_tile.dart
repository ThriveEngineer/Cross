import 'package:flutter/material.dart';
import 'package:cross/Controller/todo_list.dart';

class TodoTile extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  final String folderName;
  final bool isSelected;
  final Function(bool?) onChanged;
  final ValueChanged<Offset>? onLongPress;

  const TodoTile({
    super.key,
    required this.taskName,
    required this.folderName,
    required this.isSelected,
    required this.taskCompleted,
    required this.onChanged,
    this.onLongPress,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isCompletingPreview = false;
  late AnimationController _checkboxController;
  late AnimationController _completionController;
  late AnimationController _dismissController;
  late Animation<double> _checkboxAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _dismissOpacityAnimation;
  late Animation<Offset> _dismissSlideAnimation;

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
      CurvedAnimation(parent: _completionController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _completionController, curve: Curves.easeOut),
    );

    _dismissController = AnimationController(
      duration: Duration(milliseconds: 180),
      vsync: this,
    );
    _dismissOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
    );
    _dismissSlideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.03, 0)).animate(
          CurvedAnimation(parent: _dismissController, curve: Curves.easeOut),
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
      _isCompletingPreview = false;
      _dismissController.reset();
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
    _dismissController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (selectionMode.value) {
      widget.onChanged(!widget.taskCompleted);
      return;
    }

    if (_isCompletingPreview) return;

    if (!widget.taskCompleted) {
      setState(() {
        _isCompletingPreview = true;
      });
      _checkboxController.forward(from: 0);
      _completionController.forward(from: 0);
      await _dismissController.forward(from: 0);
      if (!mounted) return;
      widget.onChanged(true);
      return;
    }

    widget.onChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    // Easter egg: Check if task contains "Stranger Things"
    final bool isStrangerThings = widget.taskName.toLowerCase().contains(
      'stranger things',
    );
    final bool effectiveCompleted =
        widget.taskCompleted || _isCompletingPreview;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: FadeTransition(
        opacity: _dismissOpacityAnimation,
        child: SlideTransition(
          position: _dismissSlideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: (_) {
                  if (_isCompletingPreview) return;
                  setState(() => _isPressed = true);
                },
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                },
                onTapCancel: () {
                  setState(() => _isPressed = false);
                },
                onLongPressStart: (details) {
                  setState(() => _isPressed = false);
                  widget.onLongPress?.call(details.globalPosition);
                },
                onTap: _handleTap,
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
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.2)
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
                                  color: effectiveCompleted
                                      ? Colors.black
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: widget.isSelected
                                        ? Theme.of(context).primaryColor
                                        : (effectiveCompleted
                                              ? Colors.black
                                              : Colors.grey),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: effectiveCompleted
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
                        SizedBox(width: 15),
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            style: TextStyle(
                              color: effectiveCompleted
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                              decoration: effectiveCompleted
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
        ),
      ),
    );
  }
}
