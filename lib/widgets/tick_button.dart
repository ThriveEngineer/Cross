import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class TickButton extends StatelessWidget {
  VoidCallback onPressed;
  TickButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(IconsaxPlusBold.tick_circle, size: 36,),
    );
  }
}