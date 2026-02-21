import 'package:cross/Controller/dates.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/services/notion_auto_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  // Filter out completed tasks
  List<List<dynamic>> _getIncompleteTasks(List<List<dynamic>> allTasks) {
    return allTasks.where((task) {
      if (task.length > 2) {
        return task[2] != 'Completed';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger immediate sync from Notion
          await NotionAutoSyncService.instance.triggerImmediateSync();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  SizedBox(width: 25),

                  Text(
                    "Today",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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

                  SizedBox(width: 25),
                ],
              ),

              // Tasks (content of the page)
              ValueListenableBuilder<bool>(
                valueListenable: showCompletedInToday,
                builder: (context, showCompletedFlag, _) {
                  return ValueListenableBuilder<List<List<dynamic>>>(
                    valueListenable: toDoList,
                    builder: (context, list, _) {
                      final openTasks = _getIncompleteTasks(list);
                      final completedTasks = list
                          .where(
                            (task) => task.length > 2 && task[2] == 'Completed',
                          )
                          .toList();

                      // When the setting is OFF, keep previous behavior: show only open tasks (with placeholder if empty)
                      if (!showCompletedFlag) {
                        if (openTasks.isEmpty) {
                          return Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Relax, you don't have anything left",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "todo.",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: TodoList(showCompleted: false),
                          ),
                        );
                      }

                      // When the setting is ON, show two sections: Open and Completed
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            left: 16,
                            right: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Open section header
                              Row(
                                children: [
                                  SizedBox(width: 16),
                                  Icon(IconsaxPlusBold.close_square, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Open',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Open tasks container
                              Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 242, 242, 247),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 26),
                                height:
                                    MediaQuery.of(context).size.height * 0.28,
                                child: openTasks.isEmpty
                                    ? Center(child: Text('No open tasks'))
                                    : TodoList(showCompleted: false),
                              ),

                              SizedBox(height: 18),

                              // Completed section header
                              Row(
                                children: [
                                  SizedBox(width: 16),
                                  Icon(IconsaxPlusBold.tick_square, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Completed tasks container
                              Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.32,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 242, 242, 247),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 26),
                                child: completedTasks.isEmpty
                                    ? Center(child: Text('No completed tasks'))
                                    : TodoList(showCompleted: true),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
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
