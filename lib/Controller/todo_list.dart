import 'dart:convert';
import 'package:cross/widgets/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notion_auto_sync_service.dart';

// Enum for sort options
enum SortOption {
  manual,
  name,
  date,
  folder,
}

// Extension for display names and persistence
extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.manual:
        return 'Manual';
      case SortOption.name:
        return 'Name';
      case SortOption.date:
        return 'Date';
      case SortOption.folder:
        return 'Folder';
    }
  }

  String get key => toString().split('.').last;

  static SortOption fromString(String value) {
    return SortOption.values.firstWhere(
      (e) => e.key == value,
      orElse: () => SortOption.manual,
    );
  }
}

// Use a ValueNotifier so changes to the list notify listeners and rebuild UI.
// Task structure: [taskName, isCompleted, folderName, previousFolder, dateValue, notionPageId]
// Index 0: String - Task name
// Index 1: bool - Completion status
// Index 2: String - Current folder name
// Index 3: String? - Previous folder (for restoration when uncompleted)
// Index 4: String? - Due date (ISO8601 format)
// Index 5: String? - Notion page ID (for sync tracking)
final ValueNotifier<List<List<dynamic>>> toDoList =
  ValueNotifier<List<List<dynamic>>>([
]);

// Controls whether the Today page shows completed tasks.
// Default: false => do not show completed tasks in Today.
final ValueNotifier<bool> showCompletedInToday = ValueNotifier<bool>(false);

// Controls whether to show folder names behind task names.
// Default: true => show folder names.
final ValueNotifier<bool> showFolderNames = ValueNotifier<bool>(true);

// Controls whether the app is in task selection mode.
final ValueNotifier<bool> selectionMode = ValueNotifier<bool>(false);

// Holds the set of currently selected tasks.
final ValueNotifier<Set<List<dynamic>>> selectedTasks = ValueNotifier<Set<List<dynamic>>>({});

// Controls the current sort option for task lists.
final ValueNotifier<SortOption> currentSortOption = ValueNotifier<SortOption>(SortOption.manual);

// Holds all folders (default and user-created)
final ValueNotifier<List<Map<String, dynamic>>> foldersList =
    ValueNotifier<List<Map<String, dynamic>>>([
  {'name': 'Inbox', 'icon': IconsaxPlusLinear.directbox_notif, 'isDefault': true},
  {'name': 'Important', 'icon': IconsaxPlusLinear.heart, 'isDefault': true},
  {'name': 'Completed', 'icon': IconsaxPlusLinear.tick_square, 'isDefault': true},
]);

/// Sorts a list of tasks based on the provided sort option
/// Returns a new sorted list without modifying the original
List<List<dynamic>> sortTasks(List<List<dynamic>> tasks, SortOption sortOption) {
  final sortedList = List<List<dynamic>>.from(tasks);

  switch (sortOption) {
    case SortOption.manual:
      return sortedList; // No sorting - preserve original order

    case SortOption.name:
      sortedList.sort((a, b) {
        final nameA = (a[0] as String).toLowerCase();
        final nameB = (b[0] as String).toLowerCase();
        return nameA.compareTo(nameB);
      });
      break;

    case SortOption.date:
      sortedList.sort((a, b) {
        final dateA = a.length > 4 ? a[4] : null;
        final dateB = b.length > 4 ? b[4] : null;

        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1; // Tasks without dates go last
        if (dateB == null) return -1;

        try {
          final parsedA = DateTime.parse(dateA as String);
          final parsedB = DateTime.parse(dateB as String);
          return parsedA.compareTo(parsedB);
        } catch (e) {
          return 0;
        }
      });
      break;

    case SortOption.folder:
      sortedList.sort((a, b) {
        final folderA = a.length > 2 ? (a[2] as String).toLowerCase() : 'inbox';
        final folderB = b.length > 2 ? (b[2] as String).toLowerCase() : 'inbox';
        return folderA.compareTo(folderB);
      });
      break;
  }

  return sortedList;
}

class TodoList extends StatefulWidget {
  final bool showCompleted; // Flag: true => only completed, false => only non-completed
  final bool showAll; // If true, show all tasks regardless of completion

  const TodoList({super.key, this.showCompleted = false, this.showAll = false});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  // checks if task is completed and moves to Completed folder
  void checkBoxChanged(bool? value, int index, List<List<dynamic>> filteredList) {
    // Find the actual task in the main list
    final taskToUpdate = filteredList[index];
    final mainListIndex = toDoList.value.indexOf(taskToUpdate);

    if (mainListIndex != -1) {
      final newList = List<List<dynamic>>.from(toDoList.value);
      final currentTask = newList[mainListIndex];
      final currentCompleted = (currentTask.length > 1) ? (currentTask[1] as bool) : false;
      final newCompletedStatus = !currentCompleted;

      final taskName = currentTask[0];
      final currentFolder = currentTask.length > 2 ? currentTask[2] as String : 'Inbox';
      final storedPreviousFolder = currentTask.length > 3 && currentTask[3] != null ? currentTask[3] as String : null;
      final dateValue = currentTask.length > 4 ? currentTask[4] : null;
      final notionPageId = currentTask.length > 5 ? currentTask[5] : null; // PRESERVE NOTION PAGE ID

      if (newCompletedStatus) {
        // Marking as completed: move to Completed folder
        newList[mainListIndex] = [
          taskName,
          true,
          'Completed',
          currentFolder, // Store current folder for restoration
          dateValue,
          notionPageId, // PRESERVE NOTION PAGE ID
        ];
      } else {
        // Marking as not completed: restore previous folder if stored, otherwise try to use currentFolder (if not 'Completed'), else 'Inbox'
        String restoreFolder = 'Inbox';
        if (storedPreviousFolder != null && storedPreviousFolder.isNotEmpty) {
          restoreFolder = storedPreviousFolder;
        } else if (currentFolder != 'Completed') {
          restoreFolder = currentFolder;
        }

        newList[mainListIndex] = [
          taskName,
          false,
          restoreFolder,
          null,
          dateValue,
          notionPageId, // PRESERVE NOTION PAGE ID
        ];
      }
      toDoList.value = newList;
    }
  }

  // Filter tasks based on showCompleted flag
  List<List<dynamic>> _getFilteredTasks(List<List<dynamic>> allTasks) {
    List<List<dynamic>> filtered;

    if (widget.showAll) {
      // Show all tasks (used by Today view when user enables showing completed tasks)
      filtered = List<List<dynamic>>.from(allTasks);
    } else if (widget.showCompleted) {
      // Show only completed tasks (for Completed folder)
      filtered = allTasks.where((task) {
        if (task.length > 2) {
          return task[2] == 'Completed';
        }
        return false;
      }).toList();
    } else {
      // Show only non-completed tasks (for other pages)
      filtered = allTasks.where((task) {
        if (task.length > 2) {
          return task[2] != 'Completed';
        }
        return true; // Show old tasks without folder assignment
      }).toList();
    }

    // Apply sorting before returning
    return sortTasks(filtered, currentSortOption.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SortOption>(
      valueListenable: currentSortOption,
      builder: (context, sortOption, _) {
        return ValueListenableBuilder<List<List<dynamic>>>(
          valueListenable: toDoList,
          builder: (context, list, _) {
            final filteredList = _getFilteredTasks(list);

            return ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) { // The builder for each item in the list
                final task = filteredList[index];
                return ValueListenableBuilder<Set<List<dynamic>>>(
                  valueListenable: selectedTasks,
                  builder: (context, selected, _) {
                    final isSelected = selected.contains(task);
                    return TodoTile(
                      taskName: task[0],
                      folderName: task.length > 2 ? task[2] : 'Inbox',
                      taskCompleted: task[1],
                      isSelected: isSelected,
                      onChanged: (value) {
                        if (selectionMode.value) {
                          final newSet = Set<List<dynamic>>.from(selectedTasks.value);
                          if (isSelected) newSet.remove(task);
                          else newSet.add(task);
                          selectedTasks.value = newSet;
                        } else {
                          checkBoxChanged(value, index, filteredList);
                        }
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Handles loading and saving sort preference to persistent storage
class SortPreferences {
  static const String _sortKey = 'task_sort_option';

  /// Load sort preference from SharedPreferences
  static Future<void> loadSortPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sortKey = prefs.getString(_sortKey);
      if (sortKey != null) {
        currentSortOption.value = SortOptionExtension.fromString(sortKey);
      }
    } catch (e) {
      // If preferences fail to load, continue with default (manual)
      print('Failed to load sort preference: $e');
    }
  }

  /// Save sort preference to SharedPreferences
  static Future<void> saveSortPreference(SortOption option) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortKey, option.key);
      currentSortOption.value = option;
    } catch (e) {
      // If preferences fail to save, still update the current value
      print('Failed to save sort preference: $e');
      currentSortOption.value = option;
    }
  }
}

/// Comprehensive data persistence for tasks, folders, and settings
class DataPersistence {
  static const String _tasksKey = 'tasks_list';
  static const String _foldersKey = 'folders_list';
  static const String _showCompletedKey = 'show_completed_in_today';
  static const String _showFolderNamesKey = 'show_folder_names';

  /// Save all tasks to persistent storage
  static Future<void> saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(toDoList.value);
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      print('Failed to save tasks: $e');
    }
  }

  /// Load all tasks from persistent storage
  static Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      if (tasksJson != null) {
        final decoded = jsonDecode(tasksJson) as List;
        toDoList.value = decoded.map((task) => List<dynamic>.from(task)).toList();
      }
    } catch (e) {
      print('Failed to load tasks: $e');
    }
  }

  /// Save all folders to persistent storage
  /// Note: IconData is stored as codePoint and fontFamily for reconstruction
  static Future<void> saveFolders(List<Map<String, dynamic>> folders) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert folders to serializable format
      final serializableFolders = folders.map((folder) {
        final icon = folder['icon'] as IconData;
        return {
          'name': folder['name'],
          'iconCodePoint': icon.codePoint,
          'iconFontFamily': icon.fontFamily,
          'iconFontPackage': icon.fontPackage,
          'isDefault': folder['isDefault'],
        };
      }).toList();

      final foldersJson = jsonEncode(serializableFolders);
      await prefs.setString(_foldersKey, foldersJson);
    } catch (e) {
      print('Failed to save folders: $e');
    }
  }

  /// Load all folders from persistent storage
  static Future<List<Map<String, dynamic>>?> loadFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final foldersJson = prefs.getString(_foldersKey);
      if (foldersJson != null) {
        final decoded = jsonDecode(foldersJson) as List;

        // Reconstruct IconData from stored values
        final folders = decoded.map((folder) {
          final iconData = IconData(
            folder['iconCodePoint'] as int,
            fontFamily: folder['iconFontFamily'] as String?,
            fontPackage: folder['iconFontPackage'] as String?,
          );

          return {
            'name': folder['name'],
            'icon': iconData,
            'isDefault': folder['isDefault'] as bool,
          };
        }).toList();

        return folders;
      }
    } catch (e) {
      print('Failed to load folders: $e');
    }
    return null;
  }

  /// Save all settings to persistent storage
  static Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showCompletedKey, showCompletedInToday.value);
      await prefs.setBool(_showFolderNamesKey, showFolderNames.value);
    } catch (e) {
      print('Failed to save settings: $e');
    }
  }

  /// Load all settings from persistent storage
  static Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final showCompleted = prefs.getBool(_showCompletedKey);
      if (showCompleted != null) {
        showCompletedInToday.value = showCompleted;
      }

      final showFolders = prefs.getBool(_showFolderNamesKey);
      if (showFolders != null) {
        showFolderNames.value = showFolders;
      }
    } catch (e) {
      print('Failed to load settings: $e');
    }
  }

  /// Load all data (tasks, folders, settings, sort preference)
  static Future<void> loadAllData() async {
    await loadTasks();
    await loadSettings();
    await SortPreferences.loadSortPreference();

    // Load folders and set them to foldersList
    final loadedFolders = await loadFolders();
    if (loadedFolders != null && loadedFolders.isNotEmpty) {
      foldersList.value = loadedFolders;
    }
  }

  /// Initialize auto-save listeners for all data
  static void initializeAutoSave() {
    // Auto-save tasks whenever toDoList changes
    toDoList.addListener(() {
      saveTasks();
    });

    // Auto-save folders whenever foldersList changes
    foldersList.addListener(() {
      saveFolders(foldersList.value);
    });

    // Auto-save settings whenever they change
    showCompletedInToday.addListener(() {
      saveSettings();
    });

    showFolderNames.addListener(() {
      saveSettings();
    });

    // Initialize Notion auto-sync
    NotionAutoSyncService.instance.initialize();

    // Note: Sort preference is saved immediately when changed via SortPreferences.saveSortPreference
  }
}