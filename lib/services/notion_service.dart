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

      // Extract the 32-character database ID from a Notion URL if pasted
      String cleanDatabaseId = databaseId.trim();

      // Typical URL format: https://www.notion.so/workspace/Database-Name-1234567890abcdef1234567890abcdef?v=...
      // Or: https://notion.so/1234567890abcdef1234567890abcdef?v=...
      final urlRegExp = RegExp(
        r'notion\.so/(?:[^/]+/)?(?:[^-]+-)?([a-fA-F0-9]{32})(?:\?|$)',
      );
      final match = urlRegExp.firstMatch(cleanDatabaseId);

      if (match != null && match.groupCount >= 1) {
        cleanDatabaseId = match.group(1)!;
      } else if (cleanDatabaseId.length > 32) {
        // Just try to grab any 32 char hex string as a fallback
        final fallbackMatch = RegExp(
          r'([a-fA-F0-9]{32})',
        ).firstMatch(cleanDatabaseId);
        if (fallbackMatch != null) {
          cleanDatabaseId = fallbackMatch.group(1)!;
        }
      }

      await prefs.setString(_apiKeyKey, apiKey.trim());
      await prefs.setString(_databaseIdKey, cleanDatabaseId);
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
    return apiKey != null &&
        apiKey.isNotEmpty &&
        databaseId != null &&
        databaseId.isNotEmpty;
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
                'text': {'content': taskName},
              },
            ],
          },
          'Status': {
            'status': {'name': isCompleted ? 'Done' : 'Not started'},
          },
          'Folder': {
            'select': {'name': folder},
          },
          if (parsedDate != null)
            'Due Date': {
              'date': {'start': parsedDate.toIso8601String().split('T')[0]},
            },
        },
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
        String errorMsg = 'Unknown error';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          }
        } catch (_) {}
        print('Notion API error: ${response.statusCode} - ${response.body}');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Failed to create task in Notion: $e');
      rethrow;
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
              'text': {'content': taskName},
            },
          ],
        },
      };

      // Only add Status if the property exists in the database
      try {
        properties['Status'] = {
          'status': {'name': isCompleted ? 'Done' : 'Not started'},
        };
      } catch (e) {
        print('Status property may not exist: $e');
      }

      // Only add Folder if the property exists
      try {
        properties['Folder'] = {
          'select': {'name': folder},
        };
      } catch (e) {
        print('Folder property may not exist: $e');
      }

      // Add or clear Due Date
      if (parsedDate != null) {
        properties['Due Date'] = {
          'date': {'start': parsedDate.toIso8601String().split('T')[0]},
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
        String errorMsg = 'Unknown error';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          }
        } catch (_) {}
        print('Notion API error updating "$taskName":');
        print('Status: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Failed to update task "$taskName" in Notion: $e');
      rethrow;
    }
  }

  /// Sync all tasks to Notion
  /// Returns updated tasks list with Notion page IDs and sync statistics
  static Future<Map<String, dynamic>> syncAllTasks(
    List<List<dynamic>> tasks,
  ) async {
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

      if (apiKey == null ||
          databaseId == null ||
          apiKey.isEmpty ||
          databaseId.isEmpty) {
        throw Exception('API Key or Database ID is missing');
      }

      if (databaseId.length != 32) {
        throw Exception(
          'Database ID must be 32 characters long. Provided ID length: ${databaseId.length}',
        );
      }

      final url = Uri.parse('$_notionApiBase/databases/$databaseId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Notion-Version': _notionApiVersion,
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        String errorMsg = 'Database connection failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMsg = errorData['message'];
          }
        } catch (_) {}

        if (response.statusCode == 404) {
          throw Exception(
            'Database not found. Did you share the database with your integration?',
          );
        } else if (response.statusCode == 401) {
          throw Exception('Unauthorized. Is your API key correct?');
        } else {
          throw Exception('$errorMsg (HTTP ${response.statusCode})');
        }
      }
    } catch (e) {
      print('Connection test failed: $e');
      rethrow;
    }
  }

  /// Query all tasks from Notion database
  /// Returns list of Notion pages with their properties
  static Future<List<Map<String, dynamic>>> queryAllTasks() async {
    try {
      final apiKey = await getApiKey();
      final databaseId = await getDatabaseId();

      if (apiKey == null || databaseId == null) {
        throw Exception('Notion not configured');
      }

      final url = Uri.parse('$_notionApiBase/databases/$databaseId/query');

      // Query body - fetch all pages, no filter
      final body = {
        'page_size': 100, // Notion max is 100 per request
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

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final results = responseData['results'] as List;

        // Parse results into simplified format
        final tasks = <Map<String, dynamic>>[];
        for (final page in results) {
          tasks.add(_parseNotionPage(page));
        }

        // Handle pagination if there are more than 100 tasks
        String? nextCursor = responseData['next_cursor'];
        bool hasMore = responseData['has_more'] as bool? ?? false;

        while (hasMore && nextCursor != null) {
          final nextBody = {'page_size': 100, 'start_cursor': nextCursor};

          final nextResponse = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Notion-Version': _notionApiVersion,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(nextBody),
          );

          if (nextResponse.statusCode == 200) {
            final nextData = jsonDecode(nextResponse.body);
            final nextResults = nextData['results'] as List;
            for (final page in nextResults) {
              tasks.add(_parseNotionPage(page));
            }
            nextCursor = nextData['next_cursor'];
            hasMore = nextData['has_more'] as bool? ?? false;
          } else {
            print('Pagination failed: ${nextResponse.statusCode}');
            break;
          }
        }

        print('Fetched ${tasks.length} tasks from Notion');
        return tasks;
      } else {
        print('Notion query error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Failed to query Notion tasks: $e');
      return [];
    }
  }

  /// Parse a Notion page into simplified task format
  static Map<String, dynamic> _parseNotionPage(Map<String, dynamic> page) {
    final props = page['properties'] as Map<String, dynamic>;

    // Extract task name from Title property
    String taskName = '';
    if (props['Name'] != null && props['Name']['title'] != null) {
      final titleArray = props['Name']['title'] as List;
      if (titleArray.isNotEmpty) {
        taskName = titleArray[0]['text']['content'] as String? ?? '';
      }
    }

    // Extract completion status from Status property
    bool isCompleted = false;
    if (props['Status'] != null && props['Status']['status'] != null) {
      final statusName =
          props['Status']['status']['name'] as String? ?? 'Not started';
      isCompleted = statusName == 'Done';
    }

    // Extract folder from Select property
    String folder = 'Inbox';
    if (props['Folder'] != null && props['Folder']['select'] != null) {
      final notionFolder =
          props['Folder']['select']['name'] as String? ?? 'Inbox';
      // Validate folder exists locally - if not, default to Inbox
      folder = notionFolder; // Validation will happen during sync
    }

    // Extract due date from Date property
    String? dueDate;
    if (props['Due Date'] != null && props['Due Date']['date'] != null) {
      dueDate = props['Due Date']['date']['start'] as String?;
    }

    // Extract page ID
    final pageId = page['id'] as String;

    // Extract last edited time from Notion (this is our Notion-side timestamp)
    final lastEdited = page['last_edited_time'] as String;

    return {
      'id': pageId,
      'name': taskName,
      'completed': isCompleted,
      'folder': folder,
      'dueDate': dueDate,
      'lastModified': lastEdited, // Notion's timestamp
    };
  }
}
