import 'package:cross/widgets/tick_button.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class Fab extends StatelessWidget {
  VoidCallback onSave;
  Fab({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final keyboardSize = MediaQuery.of(context).viewInsets.bottom;
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(context: context, isScrollControlled: true, builder:(context) {
          return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
            child: Container(
              height: 175,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 17, top: 10, right: 17, bottom: 10),
                    child: TextField(
                      autofocus: true,
                      controller: titleController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Task title',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        )
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 22, top: 30),
                    child: Row(
                      children: [
                        Chip(
                          side: BorderSide(color: Color.fromARGB(255, 179, 179, 179)),
                          label: Row(
                            children: [
                              Icon(IconsaxPlusLinear.directbox_notif),
                              SizedBox(width: 10,),
                              Text("Inbox"),
                            ],
                          ),
                          ),
                    
                          SizedBox(width: 12,),
                    
                      Chip(
                        side: BorderSide(color: Color.fromARGB(255, 179, 179, 179)),
                      label: Row(
                        children: [
                          Icon(IconsaxPlusLinear.calendar),
                          SizedBox(width: 10,),
                          Text("Today"),
                        ],
                      ),
                      ),

                      SizedBox(width: 12,),

                      TickButton(onPressed: onSave
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: Icon(IconsaxPlusLinear.add),
      );
  }
}

final TextEditingController titleController = TextEditingController();