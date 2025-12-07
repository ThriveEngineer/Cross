import 'package:cross/Controller/dates.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/View/folder_page.dart';
import 'package:cross/widgets/fab.dart';
import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

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
      floatingActionButton: Fab(
        onSave: () {
    if (titleController.text.isNotEmpty) {
      final newList = List<List<dynamic>>.from(toDoList.value);
      newList.add([
        titleController.text,
        false,
        selectedFolder.value, // Use the selected folder
      ]);
      toDoList.value = newList;
      titleController.clear();
      selectedFolder.value = 'Inbox'; // Reset to default
      Navigator.pop(context);
    }
  },
  foldersList: foldersList, 
      ),
      body: Column(
          children: [
            // Header
            Row(
              children: [
      
                SizedBox(width: 25,),
      
                Text(
              "Today",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
               ),
              ),
      
              Spacer(),
      
              Column(
                children: [
                  Text(
                    monthNumber,
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
      
                SizedBox(width: 25,),
              ],
            ),
      
            // Tasks (content of the page)
            ValueListenableBuilder<List<List<dynamic>>>(
              valueListenable: toDoList,
              builder: (context, list, _) {
                final incompleteTasks = _getIncompleteTasks(list);
                
                if (incompleteTasks.isEmpty) {
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
      
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: ColorScheme.of(context).primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Create new task",),
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
              },
            ),
          ],
        ),
    );
  }
}