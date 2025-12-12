import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/tick_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'dart:async';

// Selected folder notifier
final ValueNotifier<String> selectedFolder = ValueNotifier<String>('Inbox');

class Fab extends StatelessWidget {
  final VoidCallback onSave;
  final bool isOnFoldersPage;
  final VoidCallback? onCreateFolder;
  final ValueNotifier<List<Map<String, dynamic>>>? foldersList;

  Fab({
    super.key,
    required this.onSave,
    this.isOnFoldersPage = false,
    this.onCreateFolder,
    this.foldersList,
  });

  void _showFolderSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Select Folder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: foldersList!,
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

  Widget _buildFolderOption(BuildContext context, String folderName, IconData icon, String currentFolder) {
    final isSelected = currentFolder == folderName;
    
    return ListTile(
      leading: Icon(icon),
      title: Text(folderName),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        selectedFolder.value = folderName;
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectionMode,
      builder: (context, inSelectionMode, _) {
        if (inSelectionMode) {
        return FloatingActionButton(
          onPressed: () {
            if (isOnFoldersPage) {
              if (onCreateFolder != null) {
                onCreateFolder!();
              }
            } else {
              showBottomSheet(
                context: context, 
                builder: (context) {
                  return _FocusTimerSheet();
                }
              );
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          child: Icon(IconsaxPlusLinear.clock_1),
        );
        } else {
          return FloatingActionButton(
          onPressed: () {
            if (isOnFoldersPage) {
              if (onCreateFolder != null) {
                onCreateFolder!();
              }
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      height: 175,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 17, top: 10, right: 17, bottom: 10),
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
                          Padding(
                            padding: const EdgeInsets.only(left: 22, top: 30),
                            child: Row(
                              children: [
                                ValueListenableBuilder<String>(
                                  valueListenable: selectedFolder,
                                  builder: (context, folder, _) {
                                    return GestureDetector(
                                      onTap: () => _showFolderSelector(context),
                                      child: Chip(
                                        side: BorderSide(
                                            color: Color.fromARGB(255, 179, 179, 179)),
                                        label: Row(
                                          children: [
                                            Icon(IconsaxPlusLinear.directbox_notif),
                                            SizedBox(width: 10),
                                            Text(folder),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 12),
                                Chip(
                                  side: BorderSide(
                                      color: Color.fromARGB(255, 179, 179, 179)),
                                  label: Row(
                                    children: [
                                      Icon(IconsaxPlusLinear.calendar),
                                      SizedBox(width: 10),
                                      Text("Today"),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                TickButton(onPressed: onSave),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          child: Icon(isOnFoldersPage ? IconsaxPlusLinear.folder_add : IconsaxPlusLinear.add),
        );
        }
      }
    );
  }
}

class _FocusTimerSheet extends StatefulWidget {
  const _FocusTimerSheet({Key? key}) : super(key: key);

  @override
  State<_FocusTimerSheet> createState() => _FocusTimerSheetState();
}

class _FocusTimerSheetState extends State<_FocusTimerSheet> {
  int totalSeconds = 45 * 60;
  bool isTimerRunning = false;
  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = totalSeconds;
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
    
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        stopTimer();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isTimerRunning = false;
      remainingSeconds = totalSeconds;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTimerRunning) {
      // Setup view
      return Container(
        height: 242,
        width: 365,
        decoration: BoxDecoration(
          color: ColorScheme.of(context).primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
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
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onPressed: startTimer,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 75),
                child: Text("Start Focus Session"),
              ),
            ),
            SizedBox(height: 17),
          ],
        ),
      );
    } else {
      // Timer running view (fullscreen-like)
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: ColorScheme.of(context).primary,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        stopTimer();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        IconsaxPlusLinear.close_circle,
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
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                ),
                onPressed: stopTimer,
                child: Text("Stop Session"),
              ),
              Spacer(),
            ],
          ),
        ),
      );
    }
  }
}

final TextEditingController titleController = TextEditingController();