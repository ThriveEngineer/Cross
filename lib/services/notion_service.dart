import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for integrating with Notion API
class NotionService {
  static const String _apiKeyKey = 'notion_api_key';
  static const String _databaseIdKey = 'notion_database_id';
  static const String _notionApiVersion = '2022-06-28';
  static const String _notionApiBase = 'https://api.notion.com/v1';

  /// Save Notion credentials
  static Future<void> saveCredentials(String apiKey, String databaseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, apiKey);
      await prefs.setString(_databaseIdKey, databaseId);
    } catch (e) {
      print('Failed to save Notion credentials: $e');
      rethrow;
    }
  }

  /// Get saved API key
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_apiKeyKey);
    } catch (e) {
      print('Failed to get Notion API key: $e');
      return null;
    }
  }

  /// Get saved database ID
  static Future<String?> getDatabaseId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_databaseIdKey);
    } catch (e) {
      print('Failed to get Notion database ID: $e');
      return null;
    }
  }

  /// Check if Notion is connected
  static Future<bool> isConnected() async {
    final apiKey = await getApiKey();
    final databaseId = await getDatabaseId();
    return apiKey != null && apiKey.isNotEmpty &&
           databaseId != null && databaseId.isNotEmpty;
  }

  /// Disconnect from Notion
  static Future<void> disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
      await prefs.remove(_databaseIdKey);
    } catch (e) {
      print('Failed to disconnect Notion: $e');
      rethrow;
    }
  }

  /// Create a new task in Notion and return the page ID
  static Future<String?> createTask({
    required String taskName,
    required bool isCompleted,
    required String folder,
    String? dueDate,
  }) async {
    try {
      final apiKey = await getApiKey();
      final databaseId = await getDatabaseId();

      if (apiKey == null || databaseId == null) {
        throw Exception('Notion not configured');
      }

      final url = Uri.parse('$_notionApiBase/pages');

      // Parse the due date if it exists
      DateTime? parsedDate;
      if (dueDate != null && dueDate.isNotEmpty) {
        try {
          parsedDate = DateTime.parse(dueDate);
        } catch (e) {
          print('Failed to parse date: $dueDate');
        }
      }

      final body = {
        'parent': {'database_id': databaseId},
        'properties': {
          'Name': {
            'title': [
              {
                'text': {'content': taskName}
              }
            ]
          },
          'Status': {
            'status': {'name': isCompleted ? 'Done' : 'Not started'}
          },
          'Folder': {
            'select': {'name': folder}
          },
          if (parsedDate != null)
            'Due Date': {
              'date': {'start': parsedDate.toIso8601String().split('T')[0]}
            },
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Notion-Version': _notionApiVersion,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'] as String;
      } else {
        print('Notion API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Failed to create task in Notion: $e');
      return null;
    }
  }

  /// Update an existing task in Notion
  static Future<bool> updateTask({
    required String pageId,
    required String taskName,
    required bool isCompleted,
    required String folder,
    String? dueDate,
  }) async {
    try {
      final apiKey = await getApiKey();

      if (apiKey == null) {
        throw Exception('Notion not configured');
      }

      final url = Uri.parse('$_notionApiBase/pages/$pageId');

      // Parse the due date if it exists
      DateTime? parsedDate;
      if (dueDate != null && dueDate.isNotEmpty) {
        try {
          parsedDate = DateTime.parse(dueDate);
        } catch (e) {
          print('Failed to parse date: $dueDate');
        }
      }

      // Build properties object - only include properties that exist
      final Map<String, dynamic> properties = {
        'Name': {
          'title': [
            {
              'text': {'content': taskName}
            }
          ]
        },
      };

      // Only add Status if the property exists in the database
      try {
        properties['Status'] = {
          'status': {'name': isCompleted ? 'Done' : 'Not started'}
        };
      } catch (e) {
        print('Status property may not exist: $e');
      }

      // Only add Folder if the property exists
      try {
        properties['Folder'] = {
          'select': {'name': folder}
        };
      } catch (e) {
        print('Folder property may not exist: $e');
      }

      // Add or clear Due Date
      if (parsedDate != null) {
        properties['Due Date'] = {
          'date': {'start': parsedDate.toIso8601String().split('T')[0]}
        };
      }

      final body = {'properties': properties};

      print('Updating task "$taskName" (Page ID: $pageId)');
      print('Request body: ${jsonEncode(body)}');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Notion-Version': _notionApiVersion,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Successfully updated task: $taskName');
        return true;
      } else {
        print('Notion API error updating "$taskName":');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Failed to update task "$taskName" in Notion: $e');
      return false;
    }
  }

  /// Sync all tasks to Notion
  /// Returns updated tasks list with Notion page IDs and sync statistics
  static Future<Map<String, dynamic>> syncAllTasks(List<List<dynamic>> tasks) async {
    int successCount = 0;
    int failCount = 0;
    int updatedCount = 0;
    int createdCount = 0;
    List<String> errors = [];
    List<List<dynamic>> updatedTasks = [];

    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      if (task.isEmpty) {
        updatedTasks.add(task);
        continue;
      }

      try {
        final taskName = task[0] as String;
        final isCompleted = task.length > 1 ? (task[1] as bool) : false;
        final folder = task.length > 2 ? (task[2] as String) : 'Inbox';
        final dueDate = task.length > 4 ? task[4] as String? : null;
        final existingPageId = task.length > 5 ? task[5] as String? : null;

        if (existingPageId != null && existingPageId.isNotEmpty) {
          // Update existing task in Notion
          final success = await updateTask(
            pageId: existingPageId,
            taskName: taskName,
            isCompleted: isCompleted,
            folder: folder,
            dueDate: dueDate,
          );

          if (success) {
            successCount++;
            updatedCount++;
            updatedTasks.add(task); // Keep existing page ID
          } else {
            failCount++;
            errors.add('Update failed: $taskName');
            updatedTasks.add(task);
          }
        } else {
          // Create new task in Notion
          final pageId = await createTask(
            taskName: taskName,
            isCompleted: isCompleted,
            folder: folder,
            dueDate: dueDate,
          );

          if (pageId != null) {
            successCount++;
            createdCount++;
            // Add page ID to task
            final updatedTask = List<dynamic>.from(task);
            // Ensure we have all indices filled
            while (updatedTask.length < 5) {
              updatedTask.add(null);
            }
            if (updatedTask.length == 5) {
              updatedTask.add(pageId); // Add page ID at index 5
            } else {
              updatedTask[5] = pageId; // Update existing page ID
            }
            updatedTasks.add(updatedTask);
          } else {
            failCount++;
            errors.add('Create failed: $taskName');
            updatedTasks.add(task);
          }
        }
      } catch (e) {
        failCount++;
        errors.add('Error: $e');
        updatedTasks.add(task);
      }
    }

    return {
      'success': successCount,
      'failed': failCount,
      'created': createdCount,
      'updated': updatedCount,
      'errors': errors,
      'updatedTasks': updatedTasks,
    };
  }

  /// Test the Notion connection
  static Future<bool> testConnection() async {
    try {
      final apiKey = await getApiKey();
      final databaseId = await getDatabaseId();

      if (apiKey == null || databaseId == null) {
        return false;
      }

      final url = Uri.parse('$_notionApiBase/databases/$databaseId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Notion-Version': _notionApiVersion,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
