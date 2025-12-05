import 'package:cross/Controller/dates.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
          if (toDoList.isEmpty)
          Expanded(
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
          )
          else
          Expanded(
            child: TodoList(),
          ),
        ],
      );
  }
}