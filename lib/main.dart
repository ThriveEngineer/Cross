import 'package:cross/Controller/theme.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:cross/services/notion_auto_sync_service.dart';
import 'package:cross/services/posthog_service.dart';
import 'package:cross/services/widget_service.dart';
import 'package:cross/widgets/bottomnavigationbar.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Signal to open the add-task sheet from a widget deep link.
final ValueNotifier<bool> openAddTaskSheet = ValueNotifier<bool>(false);

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

  // Initialize home screen widgets
  await WidgetService.initialize();

  // Initialize PostHog analytics
  await PosthogService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForAddTaskIntent();
  }

  Future<void> _checkForAddTaskIntent() async {
    try {
      final pending =
          await HomeWidget.getWidgetData<String>('widget_pending_deep_link');
      if (pending != null && pending.isNotEmpty) {
        await HomeWidget.saveWidgetData<String?>('widget_pending_deep_link', null);
        if (pending.contains('addTask')) {
          // Small delay to ensure the Scaffold is ready
          Future.delayed(const Duration(milliseconds: 400), () {
            openAddTaskSheet.value = true;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Check if Quick Add widget triggered an "add task" action
      _checkForAddTaskIntent();

      // App came to foreground - trigger immediate sync & reload tasks
      // (widget may have toggled a task while the app was backgrounded)
      DataPersistence.loadTasks().then((_) {
        NotionAutoSyncService.instance.triggerImmediateSync();
        WidgetService.syncWidgetData();
      });
    } else if (state == AppLifecycleState.paused) {
      // App went to background - stop polling to save battery
      NotionAutoSyncService.instance.stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomnavigationbarWidget(),
      theme: lightTheme,
    );
  }
}
