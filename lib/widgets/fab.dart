import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class Fab extends StatefulWidget {
  const Fab({super.key});

  @override
  State<Fab> createState() => _FabState();
}

class _FabState extends State<Fab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      child: Icon(IconsaxPlusLinear.add),
      );
  }
}