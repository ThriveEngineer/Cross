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

  Widget _buildOpenOnlyContent(List<List<dynamic>> openTasks) {
    if (openTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Relax, you don't have anything left",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Text(
              "todo.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: TodoList(showCompleted: false),
    );
  }

  Widget _buildOpenAndCompletedContent(
    BuildContext context,
    List<List<dynamic>> openTasks,
    List<List<dynamic>> completedTasks,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 16),
              Icon(IconsaxPlusBold.close_square, size: 16),
              SizedBox(width: 8),
              Text(
                'Open',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(vertical: 26),
            height: MediaQuery.of(context).size.height * 0.297,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.99, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>('open-${openTasks.length}'),
                child: openTasks.isEmpty
                    ? Center(child: Text('No open tasks'))
                    : TodoList(showCompleted: false),
              ),
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              SizedBox(width: 16),
              Icon(IconsaxPlusBold.tick_square, size: 16),
              SizedBox(width: 8),
              Text(
                'Completed',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3206,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(vertical: 26),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.99, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>('completed-${completedTasks.length}'),
                child: completedTasks.isEmpty
                    ? Center(child: Text('No completed tasks'))
                    : TodoList(showCompleted: true),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 245),
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

                      return Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          transitionBuilder: (child, animation) {
                            final curved = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );
                            return FadeTransition(
                              opacity: curved,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.02),
                                  end: Offset.zero,
                                ).animate(curved),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<bool>(showCompletedFlag),
                            child: SizedBox.expand(
                              child: showCompletedFlag
                                  ? _buildOpenAndCompletedContent(
                                      context,
                                      openTasks,
                                      completedTasks,
                                    )
                                  : _buildOpenOnlyContent(openTasks),
                            ),
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
