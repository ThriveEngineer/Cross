import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controller/todo_list.dart';

/// Android widget names (fully qualified receiver class names)
const String _androidTaskListWidget = 'thrive.cross.widgets.TaskListWidgetReceiver';
const String _androidFolderOverviewWidget = 'thrive.cross.widgets.FolderOverviewWidgetReceiver';
const String _androidDueTodayWidget = 'thrive.cross.widgets.DueTodayWidgetReceiver';
const String _androidQuickAddWidget = 'thrive.cross.widgets.QuickAddWidgetReceiver';

/// SharedPreferences/HomeWidget data keys
const String _keyTasks = 'widget_tasks';
const String _keyFolders = 'widget_folders';
const String _keyIsPro = 'widget_is_pro';

/// Service that bridges Flutter app data to native home screen widgets.
class WidgetService {
  static bool _listenersAttached = false;

  /// Initialize: register interactive callback and attach data listeners.
  static Future<void> initialize() async {
    HomeWidget.registerInteractivityCallback(widgetInteractiveCallback);

    if (!_listenersAttached) {
      toDoList.addListener(_onDataChanged);
      foldersList.addListener(_onDataChanged);
      _listenersAttached = true;
    }

    // Sync initial data to widgets.
    await syncWidgetData();
  }

  static void _onDataChanged() {
    syncWidgetData();
  }

  /// Serialize current tasks, folders, and pro status to widget-accessible
  /// storage, then tell the OS to refresh all widgets.
  static Future<void> syncWidgetData() async {
    try {
      // Simplified task list for widgets — includes date for Due Today widget
      final tasks = toDoList.value.asMap().entries.map((e) {
        final t = e.value;
        return {
          'i': e.key,
          'n': t[0] as String,
          'c': t[1] as bool,
          'f': t.length > 2 ? t[2] as String : 'Inbox',
          'd': t.length > 4 ? t[4] : null,
        };
      }).toList();

      final folders =
          foldersList.value.map((f) => f['name'] as String).toList();

      // All features are free — always report Pro as true to widgets
      const isPro = true;

      await Future.wait([
        HomeWidget.saveWidgetData<String>(_keyTasks, jsonEncode(tasks)),
        HomeWidget.saveWidgetData<String>(_keyFolders, jsonEncode(folders)),
        HomeWidget.saveWidgetData<String>(_keyIsPro, isPro.toString()),
      ]);

      await _updateAllWidgets();
    } catch (e) {
      debugPrint('WidgetService.syncWidgetData failed: $e');
    }
  }

  static Future<void> _updateAllWidgets() async {
    await Future.wait([
      HomeWidget.updateWidget(qualifiedAndroidName: _androidTaskListWidget),
      HomeWidget.updateWidget(qualifiedAndroidName: _androidFolderOverviewWidget),
      HomeWidget.updateWidget(qualifiedAndroidName: _androidDueTodayWidget),
      HomeWidget.updateWidget(qualifiedAndroidName: _androidQuickAddWidget),
    ]);
  }
}

// ── Interactive Callback ────────────────────────────────────────────────────
// Must be a top-level function so it survives tree-shaking.

@pragma('vm:entry-point')
FutureOr<void> widgetInteractiveCallback(Uri? data) async {
  if (data == null) return;

  try {
    if (data.host == 'tick') {
      final indexStr = data.queryParameters['index'];
      if (indexStr == null) return;
      final index = int.tryParse(indexStr);
      if (index == null) return;

      // Read current tasks from SharedPreferences (the callback runs in
      // an isolated context without access to the running app's state).
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Ensure we get the latest data in background isolate
      final tasksJson = prefs.getString('tasks_list');
      if (tasksJson == null) return;

      final tasks =
          (jsonDecode(tasksJson) as List).map((t) => List<dynamic>.from(t)).toList();

      if (index < 0 || index >= tasks.length) return;

      final task = tasks[index];
      final isCompleted = task[1] as bool;
      final currentFolder = task.length > 2 ? task[2] as String : 'Inbox';

      if (!isCompleted) {
        // Mark completed
        task[1] = true;
        // Ensure task has enough elements for previousFolder
        while (task.length < 4) task.add(null);
        task[3] = currentFolder; // store previous folder
        task[2] = 'Completed';
      } else {
        // Mark not completed – restore previous folder
        task[1] = false;
        final previousFolder =
            (task.length > 3 && task[3] != null) ? task[3] as String : 'Inbox';
        task[2] = previousFolder;
        if (task.length > 3) task[3] = null;
      }

      // Update timestamp
      final now = DateTime.now().toUtc().toIso8601String();
      while (task.length < 7) {
        task.add(null);
      }
      task[6] = now;

      tasks[index] = task;

      // Persist back to SharedPreferences (the app will pick up changes
      // next time it reads).
      await prefs.setString('tasks_list', jsonEncode(tasks));

      // Also update widget-specific data so the widget refreshes immediately.
      final widgetTasks = tasks.asMap().entries.map((e) {
        final t = e.value;
        return {
          'i': e.key,
          'n': t[0] as String,
          'c': t[1] as bool,
          'f': t.length > 2 ? t[2] as String : 'Inbox',
          'd': t.length > 4 ? t[4] : null,
        };
      }).toList();

      await HomeWidget.saveWidgetData<String>(_keyTasks, jsonEncode(widgetTasks));
      // Update both task-based widgets
      await Future.wait([
        HomeWidget.updateWidget(qualifiedAndroidName: _androidTaskListWidget),
        HomeWidget.updateWidget(qualifiedAndroidName: _androidDueTodayWidget),
        HomeWidget.updateWidget(qualifiedAndroidName: _androidFolderOverviewWidget),
      ]);
    }
  } catch (e) {
    debugPrint('widgetInteractiveCallback error: $e');
  }
}
