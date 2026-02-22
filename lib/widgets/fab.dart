import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/tick_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'dart:async';

// Selected folder notifier
final ValueNotifier<String> selectedFolder = ValueNotifier<String>('Inbox');

// Selected date notifier (null means no specific date selected)
final ValueNotifier<DateTime?> selectedDate = ValueNotifier<DateTime?>(null);

class Fab extends StatefulWidget {
  final VoidCallback onSave;
  final bool isOnFoldersPage;
  final VoidCallback? onCreateFolder;
  final ValueNotifier<List<Map<String, dynamic>>>? foldersList;

  const Fab({
    super.key,
    required this.onSave,
    this.isOnFoldersPage = false,
    this.onCreateFolder,
    this.foldersList,
  });

  @override
  State<Fab> createState() => _FabState();
}

class _FabState extends State<Fab> {
  void _showFolderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Select Folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: widget.foldersList!,
                  builder: (context, folders, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: selectedFolder,
                      builder: (context, currentFolder, _) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: folders.length,
                          itemBuilder: (context, index) {
                            final folder = folders[index];
                            return _buildFolderOption(
                              context,
                              folder['name'],
                              folder['icon'] as IconData,
                              currentFolder,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  String _getDateLabel(DateTime? date) {
    if (date == null) {
      return "No Date";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return "Today";
    } else if (dateOnly == tomorrow) {
      return "Tomorrow";
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${months[date.month - 1]} ${date.day}";
    }
  }

  Widget _buildFolderOption(
    BuildContext context,
    String folderName,
    IconData icon,
    String currentFolder,
  ) {
    final isSelected = currentFolder == folderName;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(icon),
        ),
        title: Text(folderName),
        trailing: AnimatedScale(
          scale: isSelected ? 1.0 : 0.0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(Icons.check, color: Theme.of(context).primaryColor),
        ),
        onTap: () {
          selectedFolder.value = folderName;
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectionMode,
      builder: (context, inSelectionMode, _) {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: RotationTransition(
                turns: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: inSelectionMode
              ? FloatingActionButton(
                  elevation: 0,
                  key: ValueKey(widget.isOnFoldersPage ? 'folder' : 'timer'),
                  onPressed: () {
                    if (widget.isOnFoldersPage) {
                      if (widget.onCreateFolder != null) {
                        widget.onCreateFolder!();
                      }
                    } else {
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return _FocusTimerSheet();
                        },
                      );
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.isOnFoldersPage
                        ? IconsaxPlusLinear.folder_add
                        : IconsaxPlusLinear.clock_1,
                  ),
                )
              : FloatingActionButton(
                  elevation: 0,
                  key: ValueKey('add'),
                  onPressed: () {
                    if (widget.isOnFoldersPage) {
                      if (widget.onCreateFolder != null) {
                        widget.onCreateFolder!();
                      }
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SizedBox(
                              height: 175,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 17,
                                      top: 30,
                                      right: 17,
                                      bottom: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            autofocus: true,
                                            controller: titleController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Task title',
                                              hintStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 12),
                                        TickButton(onPressed: widget.onSave),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 22,
                                      top: 5,
                                    ),
                                    child: Row(
                                      children: [
                                        ValueListenableBuilder<String>(
                                          valueListenable: selectedFolder,
                                          builder: (context, folder, _) {
                                            return TweenAnimationBuilder<
                                              double
                                            >(
                                              tween: Tween(
                                                begin: 1.0,
                                                end: 1.0,
                                              ),
                                              duration: Duration(
                                                milliseconds: 100,
                                              ),
                                              builder: (context, scale, child) {
                                                return Transform.scale(
                                                  scale: scale,
                                                  child: child,
                                                );
                                              },
                                              child: GestureDetector(
                                                onTapDown: (_) {},
                                                onTapUp: (_) {},
                                                onTap: () =>
                                                    _showFolderSelector(
                                                      context,
                                                    ),
                                                child: SizedBox(
                                                  height: 33,
                                                  child: Chip(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                        ),
                                                    labelPadding:
                                                        EdgeInsets.zero,
                                                    side: BorderSide(
                                                      width: 0.5,
                                                      color: Color.fromARGB(
                                                        255,
                                                        179,
                                                        179,
                                                        179,
                                                      ),
                                                    ),
                                                    label: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          IconsaxPlusLinear
                                                              .directbox_notif,
                                                          size: 22,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(folder),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: 12),
                                        ValueListenableBuilder<DateTime?>(
                                          valueListenable: selectedDate,
                                          builder: (context, date, _) {
                                            return TweenAnimationBuilder<
                                              double
                                            >(
                                              tween: Tween(
                                                begin: 1.0,
                                                end: 1.0,
                                              ),
                                              duration: Duration(
                                                milliseconds: 100,
                                              ),
                                              builder: (context, scale, child) {
                                                return Transform.scale(
                                                  scale: scale,
                                                  child: child,
                                                );
                                              },
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _showDatePicker(context),
                                                child: SizedBox(
                                                  width: 112,
                                                  height: 36,
                                                  child: Chip(
                                                    padding: EdgeInsets.zero,
                                                    labelPadding:
                                                        EdgeInsets.zero,
                                                    side: BorderSide(
                                                      width: 0.5,
                                                      color: Color.fromARGB(
                                                        255,
                                                        179,
                                                        179,
                                                        179,
                                                      ),
                                                    ),
                                                    label: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Icon(
                                                          IconsaxPlusLinear
                                                              .calendar,
                                                          size: 22,
                                                        ),
                                                        SizedBox(width: 10),
                                                        AnimatedSwitcher(
                                                          duration: Duration(
                                                            milliseconds: 200,
                                                          ),
                                                          child: Text(
                                                            _getDateLabel(date),
                                                            key: ValueKey(date),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // SizedBox(width: 12),
                                        // TickButton(onPressed: widget.onSave),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.isOnFoldersPage
                        ? IconsaxPlusLinear.folder_add
                        : IconsaxPlusLinear.add,
                  ),
                ),
        );
      },
    );
  }
}

class _FocusTimerSheet extends StatefulWidget {
  const _FocusTimerSheet({Key? key}) : super(key: key);

  @override
  State<_FocusTimerSheet> createState() => _FocusTimerSheetState();
}

class _FocusTimerSheetState extends State<_FocusTimerSheet>
    with SingleTickerProviderStateMixin {
  int totalSeconds = 45 * 60;
  bool isTimerRunning = false;
  late int remainingSeconds;
  Timer? timer;
  late AnimationController controller;
  late Animation<double> animation;
  bool _animationInitialized = false;

  @override
  void initState() {
    super.initState();
    remainingSeconds = totalSeconds;

    // Animation controller
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize animation only once
    if (!_animationInitialized) {
      animation =
          Tween<double>(
              begin: 242,
              end: MediaQuery.of(context).size.height,
            ).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            )
            ..addListener(() {
              setState(() {});
            });

      _animationInitialized = true;
    }
  }

  void adjustTime(int minutes) {
    setState(() {
      totalSeconds += minutes * 60;
      if (totalSeconds < 60) totalSeconds = 60;
      if (totalSeconds > 180 * 60) totalSeconds = 180 * 60;
      remainingSeconds = totalSeconds;
    });
  }

  void startTimer() {
    setState(() {
      isTimerRunning = true;
      remainingSeconds = totalSeconds;
    });

    // Start the animation when timer starts
    controller.forward();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        stopTimer();
      }
    });

    // Wait for animation to complete before going fullscreen
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted && isTimerRunning) {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            pageBuilder: (context, animation, secondaryAnimation) =>
                _FullscreenTimer(
                  remainingSeconds: remainingSeconds,
                  onStop: stopTimer,
                  onClose: closeTimer,
                  formatTime: formatTime,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: Duration(milliseconds: 200),
          ),
        );
      }
    });
  }

  void stopTimer() {
    timer?.cancel();

    // Close fullscreen overlay if open
    if (isTimerRunning && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Change state first, then animate
    setState(() {
      isTimerRunning = false;
      remainingSeconds = totalSeconds;
    });

    // Reset animation controller
    controller.reset();
  }

  void closeTimer() {
    timer?.cancel();

    // Close fullscreen overlay
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTimerRunning) {
      // Setup view - small box
      return Container(
        height: 242,
        width: 365,
        decoration: BoxDecoration(
          color: ColorScheme.of(context).primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: _buildSetupView(context),
      );
    } else {
      // Timer running view - animated expanding box
      final progress = _animationInitialized ? controller.value : 0.0;

      return Container(
        width: _animationInitialized ? animation.value : 365,
        height: _animationInitialized ? animation.value : 242,
        decoration: BoxDecoration(
          color: ColorScheme.of(context).primary,
          borderRadius: BorderRadius.circular(24 * (1 - progress)),
        ),
        child: SafeArea(child: _buildTimerView(context)),
      );
    }
  }

  Widget _buildSetupView(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => adjustTime(-5),
              icon: Icon(
                IconsaxPlusLinear.minus,
                color: ColorScheme.of(context).onPrimary,
                size: 32,
              ),
            ),
            SizedBox(width: 30),
            Text(
              formatTime(totalSeconds),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 72,
                color: ColorScheme.of(context).onPrimary,
              ),
            ),
            SizedBox(width: 30),
            IconButton(
              onPressed: () => adjustTime(5),
              icon: Icon(
                IconsaxPlusLinear.add,
                color: ColorScheme.of(context).onPrimary,
                size: 32,
              ),
            ),
          ],
        ),
        SizedBox(height: 25),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: ColorScheme.of(context).surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          onPressed: startTimer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 75),
            child: Text("Start Focus Session"),
          ),
        ),
        SizedBox(height: 17),
      ],
    );
  }

  Widget _buildTimerView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: closeTimer,
                icon: Icon(
                  IconsaxPlusLinear.close_square,
                  color: ColorScheme.of(context).onPrimary,
                  size: 24,
                ),
              ),
              Text(
                'Focus Session',
                style: TextStyle(
                  color: ColorScheme.of(context).onPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 48),
            ],
          ),
        ),
        Spacer(),
        Text(
          formatTime(remainingSeconds),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 96,
            color: ColorScheme.of(context).onPrimary,
          ),
        ),
        SizedBox(height: 60),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: ColorScheme.of(context).surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
          ),
          onPressed: stopTimer,
          child: Text("Stop Session"),
        ),
        Spacer(),
      ],
    );
  }
}

final TextEditingController titleController = TextEditingController();

// Fullscreen timer overlay widget
class _FullscreenTimer extends StatefulWidget {
  final int remainingSeconds;
  final VoidCallback onStop;
  final VoidCallback onClose;
  final String Function(int) formatTime;

  const _FullscreenTimer({
    required this.remainingSeconds,
    required this.onStop,
    required this.onClose,
    required this.formatTime,
  });

  @override
  State<_FullscreenTimer> createState() => _FullscreenTimerState();
}

class _FullscreenTimerState extends State<_FullscreenTimer> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.remainingSeconds;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        widget.onStop();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      IconsaxPlusLinear.close_square,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Focus Session',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
            Spacer(),
            Text(
              widget.formatTime(_remainingSeconds),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 96,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(height: 60),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
              ),
              onPressed: widget.onStop,
              child: Text("Stop Session"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
