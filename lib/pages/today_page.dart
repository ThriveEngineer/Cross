import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {}, 
          icon: Icon(Iconsax.menu),
          ),
      ),

      body: Column(
        children: [
          Text(
            "Today",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
             ),
            ),
        ],
      ),
    );
  }
}