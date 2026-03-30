import 'package:cross/Controller/todo_list.dart';
import 'package:cross/View/folder_detail_page.dart';
import 'package:cross/View/folder_page.dart';
import 'package:cross/View/today_page.dart';
import 'package:cross/View/upcoming_page.dart';
import 'package:cross/main.dart';
import 'package:cross/widgets/fab.dart';
import 'package:cross/widgets/tick_button.dart';
import 'package:flutter/material.dart';
import 'package:cross/widgets/appbar.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class BottomnavigationbarWidget extends StatefulWidget {
  const BottomnavigationbarWidget({super.key});

  /// Navigate to a specific folder (called from widget deep links).
  static void openFolder(BuildContext context, String folderName) {
    // Find the folder's icon from the current folders list.
    IconData icon = IconsaxPlusLinear.folder;
    for (final f in foldersList.value) {
      if (f['name'] == folderName) {
        icon = f['icon'] as IconData;
        break;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderDetailPage(
          folderName: folderName,
          folderIcon: icon,
        ),
      ),
    );
  }

  @override
  State<BottomnavigationbarWidget> createState() =>
      _BottomnavigationbarWidgetState();
}

class _BottomnavigationbarWidgetState extends State<BottomnavigationbarWidget> {
  int _currentIndex = 0;
  final TextEditingController _folderController = TextEditingController();
  IconData _selectedIcon = IconsaxPlusLinear.folder;

  static const Map<String, IconData> _allIcons = {
    // Productivity
    'task': IconsaxPlusLinear.task, 'task_square': IconsaxPlusLinear.task_square, 'note': IconsaxPlusLinear.note, 'clipboard': IconsaxPlusLinear.clipboard, 'calendar': IconsaxPlusLinear.calendar, 'clock': IconsaxPlusLinear.clock, 'timer': IconsaxPlusLinear.timer, 'alarm': IconsaxPlusLinear.alarm, 'kanban': IconsaxPlusLinear.kanban, 'diagram': IconsaxPlusLinear.diagram,
    // Files & Docs
    'folder': IconsaxPlusLinear.folder, 'folder_open': IconsaxPlusLinear.folder_open, 'folder_favorite': IconsaxPlusLinear.folder_favorite, 'archive': IconsaxPlusLinear.archive, 'document': IconsaxPlusLinear.document, 'document_text': IconsaxPlusLinear.document_text, 'book': IconsaxPlusLinear.book, 'bookmark': IconsaxPlusLinear.bookmark, 'paperclip': IconsaxPlusLinear.paperclip,
    // Finance
    'money': IconsaxPlusLinear.money, 'wallet': IconsaxPlusLinear.wallet, 'coin': IconsaxPlusLinear.coin, 'bill': IconsaxPlusLinear.bill, 'card': IconsaxPlusLinear.card, 'receipt': IconsaxPlusLinear.receipt, 'bank': IconsaxPlusLinear.bank, 'chart': IconsaxPlusLinear.chart, 'trend_up': IconsaxPlusLinear.trend_up, 'trend_down': IconsaxPlusLinear.trend_down,
    // Communication
    'message': IconsaxPlusLinear.message, 'message_circle': IconsaxPlusLinear.message_circle, 'call': IconsaxPlusLinear.call, 'sms': IconsaxPlusLinear.sms, 'directbox_notif': IconsaxPlusLinear.directbox_notif, 'notification': IconsaxPlusLinear.notification, 'send': IconsaxPlusLinear.send,
    // Media
    'musicnote': IconsaxPlusLinear.musicnote, 'headphone': IconsaxPlusLinear.headphone, 'speaker': IconsaxPlusLinear.speaker, 'video': IconsaxPlusLinear.video, 'camera': IconsaxPlusLinear.camera, 'gallery': IconsaxPlusLinear.gallery, 'image': IconsaxPlusLinear.image, 'play': IconsaxPlusLinear.play, 'microphone': IconsaxPlusLinear.microphone, 'radio': IconsaxPlusLinear.radio,
    // People
    'user': IconsaxPlusLinear.user, 'profile': IconsaxPlusLinear.profile, 'people': IconsaxPlusLinear.people, 'man': IconsaxPlusLinear.man, 'woman': IconsaxPlusLinear.woman, 'teacher': IconsaxPlusLinear.teacher, 'personalcard': IconsaxPlusLinear.personalcard,
    // Technology
    'mobile': IconsaxPlusLinear.mobile, 'monitor': IconsaxPlusLinear.monitor, 'devices': IconsaxPlusLinear.devices, 'cpu': IconsaxPlusLinear.cpu, 'keyboard': IconsaxPlusLinear.keyboard, 'code': IconsaxPlusLinear.code, 'wifi': IconsaxPlusLinear.wifi, 'bluetooth': IconsaxPlusLinear.bluetooth, 'data': IconsaxPlusLinear.data, 'external_drive': IconsaxPlusLinear.external_drive,
    // Navigation & UI
    'home': IconsaxPlusLinear.home, 'setting': IconsaxPlusLinear.setting, 'search_normal': IconsaxPlusLinear.search_normal, 'menu': IconsaxPlusLinear.menu, 'filter': IconsaxPlusLinear.filter, 'sort': IconsaxPlusLinear.sort, 'refresh': IconsaxPlusLinear.refresh, 'link': IconsaxPlusLinear.link, 'share': IconsaxPlusLinear.share, 'export': IconsaxPlusLinear.export,
    // Design & Creative
    'brush': IconsaxPlusLinear.brush, 'pen_tool': IconsaxPlusLinear.pen_tool, 'magicpen': IconsaxPlusLinear.magicpen, 'crop': IconsaxPlusLinear.crop, 'color_swatch': IconsaxPlusLinear.color_swatch, 'paintbucket': IconsaxPlusLinear.paintbucket, 'edit': IconsaxPlusLinear.edit, 'eraser': IconsaxPlusLinear.eraser, 'scissor': IconsaxPlusLinear.scissor,
    // Health & Wellness
    'health': IconsaxPlusLinear.health, 'heart': IconsaxPlusLinear.heart, 'hospital': IconsaxPlusLinear.hospital, 'microscope': IconsaxPlusLinear.microscope, 'pet': IconsaxPlusLinear.pet, 'weight': IconsaxPlusLinear.weight,
    // Travel & Transport
    'airplane': IconsaxPlusLinear.airplane, 'car': IconsaxPlusLinear.car, 'truck': IconsaxPlusLinear.truck, 'bus': IconsaxPlusLinear.bus, 'ship': IconsaxPlusLinear.ship, 'map': IconsaxPlusLinear.map, 'location': IconsaxPlusLinear.location, 'gps': IconsaxPlusLinear.gps, 'gas_station': IconsaxPlusLinear.gas_station,
    // Nature & Weather
    'sun': IconsaxPlusLinear.sun, 'moon': IconsaxPlusLinear.moon, 'cloud': IconsaxPlusLinear.cloud, 'wind': IconsaxPlusLinear.wind, 'drop': IconsaxPlusLinear.drop, 'tree': IconsaxPlusLinear.tree, 'flash': IconsaxPlusLinear.flash,
    // Shopping
    'shopping_cart': IconsaxPlusLinear.shopping_cart, 'shopping_bag': IconsaxPlusLinear.shopping_bag, 'shop': IconsaxPlusLinear.shop, 'bag': IconsaxPlusLinear.bag, 'gift': IconsaxPlusLinear.gift, 'ticket': IconsaxPlusLinear.ticket, 'discount_circle': IconsaxPlusLinear.discount_circle,
    // Security
    'security': IconsaxPlusLinear.security, 'shield': IconsaxPlusLinear.shield, 'lock': IconsaxPlusLinear.lock, 'unlock': IconsaxPlusLinear.unlock, 'key': IconsaxPlusLinear.key, 'password_check': IconsaxPlusLinear.password_check, 'finger_scan': IconsaxPlusLinear.finger_scan, 'eye': IconsaxPlusLinear.eye,
    // Social & Fun
    'star': IconsaxPlusLinear.star, 'award': IconsaxPlusLinear.award, 'crown': IconsaxPlusLinear.crown, 'medal': IconsaxPlusLinear.medal, 'like': IconsaxPlusLinear.like, 'flag': IconsaxPlusLinear.flag, 'emoji_happy': IconsaxPlusLinear.emoji_happy, 'game': IconsaxPlusLinear.game, 'ghost': IconsaxPlusLinear.ghost, 'magic_star': IconsaxPlusLinear.magic_star,
    // Misc
    'coffee': IconsaxPlusLinear.coffee, 'cake': IconsaxPlusLinear.cake, 'milk': IconsaxPlusLinear.milk, 'glass': IconsaxPlusLinear.glass, 'lamp': IconsaxPlusLinear.lamp, 'briefcase': IconsaxPlusLinear.briefcase, 'building': IconsaxPlusLinear.building, 'courthouse': IconsaxPlusLinear.courthouse, 'global': IconsaxPlusLinear.global, 'translate': IconsaxPlusLinear.translate, 'info_circle': IconsaxPlusLinear.info_circle, 'danger': IconsaxPlusLinear.danger, 'trash': IconsaxPlusLinear.trash, 'tag': IconsaxPlusLinear.tag,
  };

  final List<Widget> _tabs = [TodayPage(), UpcomingPage(), FolderPage()];

  @override
  void initState() {
    super.initState();
    openAddTaskSheet.addListener(_onAddTaskSignal);
  }

  void _onAddTaskSignal() {
    if (openAddTaskSheet.value) {
      openAddTaskSheet.value = false;
      // Ensure we're on the Today tab and show the add-task sheet
      setState(() => _currentIndex = 0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddTaskSheet();
      });
    }
  }

  String _getDateLabel(DateTime? date) {
    if (date == null) return "No Date";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == today) return "Today";
    if (dateOnly == tomorrow) return "Tomorrow";
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return "${months[date.month - 1]} ${date.day}";
  }

  Future<void> _pickDate(BuildContext ctx) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: selectedDate.value ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate.value = picked;
  }

  void _pickFolder(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Select Folder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Expanded(
                child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: foldersList,
                  builder: (context, folders, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: selectedFolder,
                      builder: (context, currentFolder, _) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: folders.length,
                          itemBuilder: (context, index) {
                            final folder = folders[index];
                            final name = folder['name'] as String;
                            final icon = folder['icon'] as IconData;
                            final isSelected = currentFolder == name;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(icon),
                                title: Text(name),
                                trailing: isSelected
                                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                                    : null,
                                onTap: () {
                                  selectedFolder.value = name;
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: 175,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 17, top: 30, right: 17, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          controller: titleController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Task title',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TickButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final newList = List<List<dynamic>>.from(toDoList.value);
                            newList.add([
                              titleController.text,
                              false,
                              selectedFolder.value,
                              null,
                              selectedDate.value?.toIso8601String(),
                              null,
                              TaskTimestamp.now(),
                            ]);
                            toDoList.value = newList;
                            titleController.clear();
                            selectedFolder.value = 'Inbox';
                            selectedDate.value = null;
                            Navigator.pop(sheetContext);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 22, top: 5),
                  child: Row(
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: selectedFolder,
                        builder: (context, folder, _) {
                          return GestureDetector(
                            onTap: () => _pickFolder(sheetContext),
                            child: SizedBox(
                              height: 33,
                              child: Chip(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                labelPadding: EdgeInsets.zero,
                                side: const BorderSide(width: 0.5, color: Color.fromARGB(255, 179, 179, 179)),
                                label: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(IconsaxPlusLinear.directbox_notif, size: 22),
                                    const SizedBox(width: 10),
                                    Text(folder),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<DateTime?>(
                        valueListenable: selectedDate,
                        builder: (context, date, _) {
                          return GestureDetector(
                            onTap: () => _pickDate(sheetContext),
                            child: SizedBox(
                              width: 112,
                              height: 36,
                              child: Chip(
                                padding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.zero,
                                side: const BorderSide(width: 0.5, color: Color.fromARGB(255, 179, 179, 179)),
                                label: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(IconsaxPlusLinear.calendar, size: 22),
                                    const SizedBox(width: 10),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(_getDateLabel(date), key: ValueKey(date)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFolderMoveDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  'Move ${selectedTasks.value.length} task${selectedTasks.value.length > 1 ? 's' : ''} to folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: foldersList,
                builder: (context, folders, _) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(folder['icon'] as IconData),
                            title: Text(folder['name'] as String),
                            onTap: () {
                              _moveTasksToFolder(folder['name'] as String);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text('Delete Tasks'),
            content: Text(
              'Are you sure you want to delete ${selectedTasks.value.length} task${selectedTasks.value.length > 1 ? 's' : ''}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _deleteSelectedTasks();
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _moveTasksToFolder(String targetFolder) {
    final newList = List<List<dynamic>>.from(toDoList.value);

    for (final task in selectedTasks.value) {
      final index = newList.indexOf(task);
      if (index != -1) {
        final taskName = task[0];
        final isCompleted = task.length > 1 ? task[1] : false;
        final previousFolder = task.length > 3 && task[3] != null
            ? task[3]
            : null;
        final dateValue = task.length > 4 ? task[4] : null;
        final notionPageId = task.length > 5 ? task[5] : null;

        newList[index] = [
          taskName,
          isCompleted,
          targetFolder,
          previousFolder,
          dateValue,
          notionPageId,
          TaskTimestamp.now(), // Add timestamp
        ];
      }
    }

    toDoList.value = newList;
    selectedTasks.value = Set<List<dynamic>>.from({});
    selectionMode.value = false;
  }

  void _deleteSelectedTasks() {
    final newList = List<List<dynamic>>.from(toDoList.value);
    newList.removeWhere((task) => selectedTasks.value.contains(task));
    toDoList.value = newList;
    selectedTasks.value = Set<List<dynamic>>.from({});
    selectionMode.value = false;
  }

  void _showCreateFolderDialog() {
    // Reset to default icon
    setState(() {
      _selectedIcon = IconsaxPlusLinear.folder;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _showIconSelector(context, setModalState),
                          child: Icon(_selectedIcon, size: 28),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            controller: _folderController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Folder name',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        TickButton(
                          onPressed: () {
                            if (_folderController.text.trim().isNotEmpty) {
                              _createFolder(_folderController.text.trim());
                              Navigator.pop(context);
                              _folderController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showIconSelector(BuildContext context, StateSetter setModalState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      builder: (context) {
        var entries = _allIcons.entries.toList();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final primary = Theme.of(context).primaryColor;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 36),
                      const Spacer(),
                      const Text(
                        'Select Icon',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          IconsaxPlusBold.tick_circle,
                          color: primary,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    onChanged: (v) {
                      final q = v.toLowerCase();
                      setSheetState(() {
                        entries = q.isEmpty
                            ? _allIcons.entries.toList()
                            : _allIcons.entries.where((e) => e.key.contains(q)).toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search icons...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(IconsaxPlusLinear.search_normal, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final icon = entries[index].value;
                      final isSelected = _selectedIcon == icon;
                      return RepaintBoundary(
                        child: Material(
                          color: isSelected
                              ? primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedIcon = icon);
                              setModalState(() => _selectedIcon = icon);
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Icon(
                                icon,
                                size: 24,
                                color: isSelected ? primary : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createFolder(String folderName) {
    final newList = List<Map<String, dynamic>>.from(foldersList.value);
    newList.add({
      'name': folderName,
      'icon': _selectedIcon,
      'isDefault': false,
    });
    foldersList.value = newList;
  }

  void _showDeleteFoldersConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Folders'),
          content: Text(
            'Are you sure you want to delete ${selectedFolders.value.length} folder${selectedFolders.value.length > 1 ? 's' : ''}? Tasks in these folders will be moved to Inbox.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedFolders();
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedFolders() {
    final newList = List<Map<String, dynamic>>.from(foldersList.value);
    final foldersToDelete = <String>[];

    // Collect folder names to delete (in reverse order to maintain indices)
    final sortedIndices = selectedFolders.value.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndices) {
      if (index < newList.length) {
        final folder = newList[index];
        final isDefault = folder['isDefault'] as bool;

        // Only delete non-default folders
        if (!isDefault) {
          foldersToDelete.add(folder['name'] as String);
          newList.removeAt(index);
        }
      }
    }

    // Move tasks from deleted folders to Inbox
    if (foldersToDelete.isNotEmpty) {
      final taskList = List<List<dynamic>>.from(toDoList.value);
      for (int i = 0; i < taskList.length; i++) {
        final task = taskList[i];
        if (task.length > 2 && foldersToDelete.contains(task[2])) {
          final updatedTask = List<dynamic>.from(task);
          updatedTask[2] = 'Inbox';
          taskList[i] = updatedTask;
        }
      }
      toDoList.value = taskList;
    }

    foldersList.value = newList;
    selectedFolders.value = {};
  }

  @override
  void dispose() {
    openAddTaskSheet.removeListener(_onAddTaskSignal);
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: selectionMode,
        builder: (context, inSelectionMode, _) {
          if (inSelectionMode) {
            // Show different UI based on which page we're on
            if (_currentIndex == 2) {
              // Folders page - show folder delete button
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder<Set<int>>(
                    valueListenable: selectedFolders,
                    builder: (context, selected, _) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Delete folders button
                            AnimatedScale(
                              scale: selected.isEmpty ? 0.9 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: selected.isEmpty
                                    ? null
                                    : () {
                                        _showDeleteFoldersConfirmation(context);
                                      },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    IconsaxPlusLinear.trash,
                                    key: ValueKey(selected.isEmpty),
                                    color: selected.isEmpty
                                        ? Colors.grey.shade400
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  // Timer FAB
                  Fab(
                    onSave: () {
                      if (titleController.text.isNotEmpty) {
                        final newList = List<List<dynamic>>.from(
                          toDoList.value,
                        );
                        newList.add([
                          titleController.text,
                          false,
                          selectedFolder.value,
                          null,
                          selectedDate.value?.toIso8601String(),
                          null,
                          TaskTimestamp.now(),
                        ]);
                        toDoList.value = newList;
                        titleController.clear();
                        selectedFolder.value = 'Inbox';
                        selectedDate.value = null;
                        Navigator.pop(context);
                      }
                    },
                    foldersList: foldersList,
                    isOnFoldersPage: true,
                    onCreateFolder: _showCreateFolderDialog,
                  ),
                ],
              );
            } else {
              // Today/Upcoming page - show task operations
              return ValueListenableBuilder<bool>(
                valueListenable: timerSheetVisible,
                builder: (context, timerOpen, _) {
                  if (timerOpen) return const SizedBox.shrink();
                  return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete and folder change buttons container
                  ValueListenableBuilder<Set<List<dynamic>>>(
                    valueListenable: selectedTasks,
                    builder: (context, selected, _) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Move to folder button
                            AnimatedScale(
                              scale: selected.isEmpty ? 0.9 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: selected.isEmpty
                                    ? null
                                    : () {
                                        _showFolderMoveDialog(context);
                                      },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    IconsaxPlusLinear.folder_cross,
                                    key: ValueKey(selected.isEmpty),
                                    color: selected.isEmpty
                                        ? Colors.grey.shade400
                                        : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Delete button
                            AnimatedScale(
                              scale: selected.isEmpty ? 0.9 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: IconButton(
                                onPressed: selected.isEmpty
                                    ? null
                                    : () {
                                        _showDeleteConfirmation(context);
                                      },
                                icon: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 200),
                                  child: Icon(
                                    IconsaxPlusLinear.trash,
                                    key: ValueKey(selected.isEmpty),
                                    color: selected.isEmpty
                                        ? Colors.grey.shade400
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  // Timer FAB
                  Fab(
                    onSave: () {
                      if (titleController.text.isNotEmpty) {
                        final newList = List<List<dynamic>>.from(
                          toDoList.value,
                        );
                        newList.add([
                          titleController.text,
                          false,
                          selectedFolder.value,
                          null,
                          selectedDate.value?.toIso8601String(),
                          null,
                          TaskTimestamp.now(),
                        ]);
                        toDoList.value = newList;
                        titleController.clear();
                        selectedFolder.value = 'Inbox';
                        selectedDate.value = null;
                        Navigator.pop(context);
                      }
                    },
                    foldersList: foldersList,
                  ),
                ],
              );
                },
              );
            }
          } else {
            return Fab(
              onSave: () {
                if (titleController.text.isNotEmpty) {
                  final newList = List<List<dynamic>>.from(toDoList.value);
                  newList.add([
                    titleController.text,
                    false,
                    selectedFolder.value,
                    null, // previousFolder placeholder
                    selectedDate.value?.toIso8601String(), // date as ISO string
                    null, // notionPageId - will be filled when first synced
                    TaskTimestamp.now(), // Add timestamp
                  ]);
                  toDoList.value = newList;
                  titleController.clear();
                  selectedFolder.value = 'Inbox';
                  selectedDate.value = null;
                  Navigator.pop(context);
                }
              },
              foldersList: foldersList,
              isOnFoldersPage: _currentIndex == 2,
              onCreateFolder: _showCreateFolderDialog,
            );
          }
        },
      ),
      appBar: AppbarWidget(),
      body: _tabs[_currentIndex],

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 0.5, color: Color(0xFFCACACA)),
          NavigationBar(
            height: 55,
            selectedIndex: _currentIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            indicatorColor: Colors.black,
            onDestinationSelected: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(IconsaxPlusLinear.calendar_1, size: 25),
                selectedIcon: Icon(
                  IconsaxPlusBold.calendar_1,
                  size: 25,
                  color: Colors.white,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(IconsaxPlusLinear.calendar, size: 25),
                selectedIcon: Icon(
                  IconsaxPlusBold.calendar,
                  size: 25,
                  color: Colors.white,
                ),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(IconsaxPlusLinear.folder, size: 25),
                selectedIcon: Icon(
                  IconsaxPlusBold.folder,
                  size: 25,
                  color: Colors.white,
                ),
                label: '',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
