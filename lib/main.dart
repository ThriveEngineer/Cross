import 'package:cross/Controller/theme.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/widgets/bottomnavigationbar.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load all persisted data
  try {
    await DataPersistence.loadAllData();
  } catch (e) {
    print('Could not load persisted data: $e');
  }

  // Initialize auto-save listeners
  DataPersistence.initializeAutoSave();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomnavigationbarWidget(),
      theme: lightTheme,
    );
  }
}