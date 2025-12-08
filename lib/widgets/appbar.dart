import 'package:cross/widgets/vertical_menu.dart';
import 'package:cross/widgets/view_settings.dart';
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
                      backgroundColor: Color.fromARGB(255, 202, 196, 208),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    context: context,
                    builder: (context) => ViewSettings(),
                  );
                  }
                  ),
                  MenuItem(
                  label: "Select", 
                  icon: IconsaxPlusLinear.mouse_square, 
                  onTap: () {}
                  ),
                  MenuItem(
                  label: "Settings", 
                  icon: IconsaxPlusLinear.setting, 
                  onTap: () {}
                  ),
                ],
            );
          }, 
          icon: Icon(
            IconsaxPlusLinear.menu,
            ),
          ),
          SizedBox(width: 15,),
        ]
      );
  }
}