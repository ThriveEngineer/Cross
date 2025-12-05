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
  Widget build(BuildContext context) {
    return AppBar(
        actions: [
          IconButton(
          onPressed: () {}, 
          icon: Icon(
            IconsaxPlusLinear.menu,
            ),
          ),
          SizedBox(width: 15,),
        ]
      );
  }
}