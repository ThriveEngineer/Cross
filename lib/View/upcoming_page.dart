import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

class UpcomingPage extends StatefulWidget {
  const UpcomingPage({super.key});

  @override
  State<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  // Group tasks by date
  Map<String, List<List<dynamic>>> _groupTasksByDate(List<List<dynamic>> allTasks) {
    final Map<String, List<List<dynamic>>> grouped = {};

    for (var task in allTasks) {
      // Skip completed tasks
      if (task.length > 2 && task[2] == 'Completed') {
        continue;
      }

      // Get date from task (index 4) - handle null and type casting carefully
      if (task.length > 4 && task[4] != null) {
        final dateValue = task[4];
        if (dateValue is String && dateValue.isNotEmpty) {
          try {
            final date = DateTime.parse(dateValue);
            final dateKey = DateTime(date.year, date.month, date.day).toIso8601String();

            if (!grouped.containsKey(dateKey)) {
              grouped[dateKey] = [];
            }
            grouped[dateKey]!.add(task);
          } catch (e) {
            // Skip tasks with invalid dates
          }
        }
      }
    }

    return grouped;
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    if (date == today) {
      return "Today";
    } else if (date == tomorrow) {
      return "Tomorrow";
    } else {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];

      final weekday = weekdays[date.weekday - 1];
      final month = months[date.month - 1];
      final day = date.day;

      return "$weekday, $month $day";
    }
  }

  void checkBoxChanged(bool? value, List<dynamic> task) {
    final mainListIndex = toDoList.value.indexOf(task);

    if (mainListIndex != -1) {
      final newList = List<List<dynamic>>.from(toDoList.value);
      final currentTask = newList[mainListIndex];
      final currentCompleted = (currentTask.length > 1) ? (currentTask[1] as bool) : false;
      final newCompletedStatus = !currentCompleted;

      final taskName = currentTask[0];
      final currentFolder = currentTask.length > 2 ? currentTask[2] as String : 'Inbox';
      final storedPreviousFolder = currentTask.length > 3 && currentTask[3] != null ? currentTask[3] as String : null;
      final dateValue = currentTask.length > 4 ? currentTask[4] : null;

      if (newCompletedStatus) {
        // Marking as completed: store current folder in index 3 and set folder to 'Completed'
        newList[mainListIndex] = [
          taskName,
          true,
          'Completed',
          currentFolder,
          dateValue,
        ];
      } else {
        // Marking as not completed: restore previous folder if stored
        String restoreFolder = 'Inbox';
        if (storedPreviousFolder != null && storedPreviousFolder.isNotEmpty) {
          restoreFolder = storedPreviousFolder;
        } else if (currentFolder != 'Completed') {
          restoreFolder = currentFolder;
        }

        newList[mainListIndex] = [
          taskName,
          false,
          restoreFolder,
          null,
          dateValue,
        ];
      }
      toDoList.value = newList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 0),
            child: Text(
              "Upcoming",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tasks grouped by date
          Expanded(
            child: ValueListenableBuilder<List<List<dynamic>>>(
              valueListenable: toDoList,
              builder: (context, list, _) {
                final groupedTasks = _groupTasksByDate(list);

                if (groupedTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No upcoming tasks",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Create tasks with dates to see them here",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Sort dates
                final sortedDates = groupedTasks.keys.toList()
                  ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

                return ListView.builder(
                  padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, dateIndex) {
                    final dateKey = sortedDates[dateIndex];
                    final tasks = groupedTasks[dateKey]!;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (dateIndex * 50)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 16),
                          child: Text(
                            _formatDateHeader(dateKey),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Tasks for this date
                        ValueListenableBuilder<bool>(
                          valueListenable: selectionMode,
                          builder: (context, inSelectionMode, _) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 242, 242, 247),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: EdgeInsets.symmetric(vertical: inSelectionMode ? 8 : 12, horizontal: inSelectionMode ? 0 : 0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: tasks.length,
                                itemBuilder: (context, taskIndex) {
                                  final task = tasks[taskIndex];
                                  return ValueListenableBuilder<Set<List<dynamic>>>(
                                    valueListenable: selectedTasks,
                                    builder: (context, selected, _) {
                                      final isSelected = selected.contains(task);
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        child: TodoTile(
                                          taskName: task[0],
                                          folderName: task.length > 2 ? task[2] : 'Inbox',
                                          taskCompleted: task[1],
                                          isSelected: isSelected,
                                          onChanged: (value) {
                                            if (selectionMode.value) {
                                              final newSet = Set<List<dynamic>>.from(selectedTasks.value);
                                              if (isSelected) {
                                                newSet.remove(task);
                                              } else {
                                                newSet.add(task);
                                              }
                                              selectedTasks.value = newSet;
                                            } else {
                                              checkBoxChanged(value, task);
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
