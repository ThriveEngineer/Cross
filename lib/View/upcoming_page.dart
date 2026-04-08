import 'package:cross/Controller/dates.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/task_selection_menu.dart';
import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

class UpcomingPage extends StatefulWidget {
  const UpcomingPage({super.key});

  @override
  State<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  // Group tasks by date
  Map<String, List<List<dynamic>>> _groupTasksByDate(
    List<List<dynamic>> allTasks,
  ) {
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
            final dateKey = DateTime(
              date.year,
              date.month,
              date.day,
            ).toIso8601String();

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

    // Apply sorting within each date group
    // Note: Date sorting doesn't make sense here since tasks are already grouped by date
    // So we apply other sort options (manual, name, folder) within each date group
    if (currentSortOption.value != SortOption.date) {
      grouped.forEach((dateKey, tasks) {
        grouped[dateKey] = sortTasks(tasks, currentSortOption.value);
      });
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
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

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
      final currentCompleted = (currentTask.length > 1)
          ? (currentTask[1] as bool)
          : false;
      final newCompletedStatus = !currentCompleted;

      final taskName = currentTask[0];
      final currentFolder = currentTask.length > 2
          ? currentTask[2] as String
          : 'Inbox';
      final storedPreviousFolder =
          currentTask.length > 3 && currentTask[3] != null
          ? currentTask[3] as String
          : null;
      final dateValue = currentTask.length > 4 ? currentTask[4] : null;
      final notionPageId = currentTask.length > 5
          ? currentTask[5]
          : null; // PRESERVE NOTION PAGE ID

      if (newCompletedStatus) {
        // Marking as completed: store current folder in index 3 and set folder to 'Completed'
        newList[mainListIndex] = [
          taskName,
          true,
          'Completed',
          currentFolder,
          dateValue,
          notionPageId, // PRESERVE NOTION PAGE ID
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
          notionPageId, // PRESERVE NOTION PAGE ID
        ];
      }
      toDoList.value = newList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 245),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => currentTabIndex.value = 0,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 212, 212, 212),
                    ),
                  ),
                ),
                SizedBox(width: 14),
                GestureDetector(
                  onTap: () => currentTabIndex.value = 1,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    "Upcoming",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),

                Spacer(),

                Column(
                  children: [
                    Text(
                      dayNumber,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      monthNameShort,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 145, 145, 145),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tasks grouped by date
          Expanded(
            child: ValueListenableBuilder<SortOption>(
              valueListenable: currentSortOption,
              builder: (context, sortOption, _) {
                return ValueListenableBuilder<List<List<dynamic>>>(
                  valueListenable: toDoList,
                  builder: (context, list, _) {
                    final groupedTasks = _groupTasksByDate(list);

                    if (groupedTasks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 30,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "No upcoming tasks",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Create tasks with dates to see them here",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 145, 145, 145),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Sort dates
                    final sortedDates = groupedTasks.keys.toList()
                      ..sort(
                        (a, b) =>
                            DateTime.parse(a).compareTo(DateTime.parse(b)),
                      );

                    return ListView.builder(
                      padding: EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        final dateKey = sortedDates[dateIndex];
                        final tasks = groupedTasks[dateKey]!;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 400 + (dateIndex * 50),
                          ),
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
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  bottom: 12,
                                  top: 16,
                                  right: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDateHeader(dateKey),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          237,
                                          237,
                                          237,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${tasks.length}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color.fromARGB(
                                            255,
                                            95,
                                            95,
                                            95,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Tasks for this date
                              ValueListenableBuilder<bool>(
                                valueListenable: selectionMode,
                                builder: (context, inSelectionMode, _) {
                                  return Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: inSelectionMode ? 8 : 12,
                                      horizontal: inSelectionMode ? 0 : 0,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: tasks.length,
                                      itemBuilder: (context, taskIndex) {
                                        final task = tasks[taskIndex];
                                        return ValueListenableBuilder<
                                          Set<List<dynamic>>
                                        >(
                                          valueListenable: selectedTasks,
                                          builder: (context, selected, _) {
                                            final isSelected = selected
                                                .contains(task);
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              child: TodoTile(
                                                key: ObjectKey(task),
                                                taskName: task[0],
                                                folderName: task.length > 2
                                                    ? task[2]
                                                    : 'Inbox',
                                                taskCompleted: task[1],
                                                isSelected: isSelected,
                                                onLongPress: (anchor) =>
                                                    showTaskSelectionMenu(
                                                      context: context,
                                                      task: task,
                                                      anchor: anchor,
                                                    ),
                                                onChanged: (value) {
                                                  if (selectionMode.value) {
                                                    final newSet =
                                                        Set<List<dynamic>>.from(
                                                          selectedTasks.value,
                                                        );
                                                    if (isSelected) {
                                                      newSet.remove(task);
                                                    } else {
                                                      newSet.add(task);
                                                    }
                                                    selectedTasks.value =
                                                        newSet;
                                                  } else {
                                                    checkBoxChanged(
                                                      value,
                                                      task,
                                                    );
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
