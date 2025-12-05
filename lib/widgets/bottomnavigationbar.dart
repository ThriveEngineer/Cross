import 'package:cross/View/folder_page.dart';
import 'package:cross/View/today_page.dart';
import 'package:cross/View/upcoming_page.dart';
import 'package:cross/widgets/fab.dart';
import 'package:flutter/material.dart';
import 'package:cross/widgets/appbar.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class BottomnavigationbarWidget extends StatefulWidget {
  const BottomnavigationbarWidget({super.key});

  @override
  State<BottomnavigationbarWidget> createState() => _BottomnavigationbarWidgetState();
}

class _BottomnavigationbarWidgetState extends State<BottomnavigationbarWidget> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    TodayPage(),
    UpcomingPage(),
    FolderPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Fab(),
      appBar: AppbarWidget(),
      body: _tabs[_currentIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar_1, size: 28,), label: "", activeIcon: Icon(IconsaxPlusBold.calendar_1, size: 30,)),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar, size: 28,), label: "", activeIcon: Icon(IconsaxPlusBold.calendar, size: 30,)),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.folder, size: 28,), label: "", activeIcon: Icon(IconsaxPlusBold.folder, size: 30,)),
            ]),
      ),
    );
  }
}