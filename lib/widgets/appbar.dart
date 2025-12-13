import 'package:cross/View/settings_page.dart';
import 'package:cross/widgets/vertical_menu.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/view_settings.dart';
import 'package:cross/Controller/todo_list.dart'; // Ensure this is imported for toDoList
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key});

  @override
  State<AppbarWidget> createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  @override
  final GlobalKey _buttonKey = GlobalKey();
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: selectionMode,
      builder: (context, inSelectionMode, _) {
        if (inSelectionMode) {
          return AppBar(
            leadingWidth: 80,
            leading: TextButton(
              onPressed: () {
                selectionMode.value = false;
                selectedTasks.value = Set<List<dynamic>>.from({}); // Clear selected tasks
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Select all tasks from the main list
                  final allTasks = Set<List<dynamic>>.from(toDoList.value);
                  selectedTasks.value = allTasks;
                },
                child: Text(
                  'Select All',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                ),
              ),
              SizedBox(width: 15),
            ],
          );
        } else {
          return AppBar(
            actions: [
              IconButton(
                key: _buttonKey,
                onPressed: () {
                  showCustomMenu(
                    context,
                    _buttonKey,
                    [
                      MenuItem(
                        label: "View",
                        icon: IconsaxPlusLinear.setting_3,
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            enableDrag: true,
                            showDragHandle: true,
                            backgroundColor: Color.fromARGB(255, 242, 242, 247),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            context: context,
                            builder: (context) => ViewSettings(),
                          );
                        },
                      ),
                      MenuItem(
                        label: "Select",
                        icon: IconsaxPlusLinear.mouse_square,
                        onTap: () {
                          Navigator.pop(context);
                          selectionMode.value = true; // Enter selection mode
                        },
                      ),
                      MenuItem(
                        label: "Settings", 
                        icon: IconsaxPlusLinear.setting, 
                        onTap: () {
                          Navigator.pop(context);
                          showCupertinoSheet(
                            enableDrag: true,
                            context: context,
                            builder: (context) => Material(
                                color: Color.fromARGB(255, 242, 242, 247),
                                child: SettingsPage()
                            ),
                          );
                        }
                        ),
                    ],
                  );
                },
                icon: Icon(IconsaxPlusLinear.menu),
              ),
              SizedBox(width: 15),
            ],
          );
        }
      },
    );
  }
}