import 'package:cross/Controller/todo_list.dart';
import 'package:cross/View/folder_detail_page.dart';
import 'package:cross/View/folder_page.dart';
import 'package:cross/View/today_page.dart';
import 'package:cross/View/upcoming_page.dart';
import 'package:cross/main.dart';
import 'package:cross/widgets/folder_selection_menu.dart';
import 'package:cross/widgets/fab.dart';
import 'package:cross/widgets/task_selection_menu.dart';
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
        builder: (_) =>
            FolderDetailPage(folderName: folderName, folderIcon: icon),
      ),
    );
  }

  @override
  State<BottomnavigationbarWidget> createState() =>
      _BottomnavigationbarWidgetState();
}

class _BottomnavigationbarWidgetState extends State<BottomnavigationbarWidget> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  final TextEditingController _folderController = TextEditingController();
  IconData _selectedIcon = IconsaxPlusLinear.folder;

  static const Map<String, IconData> _allIcons = {
    // Productivity
    'task': IconsaxPlusLinear.task,
    'task_square': IconsaxPlusLinear.task_square,
    'note': IconsaxPlusLinear.note,
    'clipboard': IconsaxPlusLinear.clipboard,
    'calendar': IconsaxPlusLinear.calendar,
    'clock': IconsaxPlusLinear.clock,
    'timer': IconsaxPlusLinear.timer,
    'alarm': IconsaxPlusLinear.alarm,
    'kanban': IconsaxPlusLinear.kanban,
    'diagram': IconsaxPlusLinear.diagram,
    // Files & Docs
    'folder': IconsaxPlusLinear.folder,
    'folder_open': IconsaxPlusLinear.folder_open,
    'folder_favorite': IconsaxPlusLinear.folder_favorite,
    'archive': IconsaxPlusLinear.archive,
    'document': IconsaxPlusLinear.document,
    'document_text': IconsaxPlusLinear.document_text,
    'book': IconsaxPlusLinear.book,
    'bookmark': IconsaxPlusLinear.bookmark,
    'paperclip': IconsaxPlusLinear.paperclip,
    // Finance
    'money': IconsaxPlusLinear.money,
    'wallet': IconsaxPlusLinear.wallet,
    'coin': IconsaxPlusLinear.coin,
    'bill': IconsaxPlusLinear.bill,
    'card': IconsaxPlusLinear.card,
    'receipt': IconsaxPlusLinear.receipt,
    'bank': IconsaxPlusLinear.bank,
    'chart': IconsaxPlusLinear.chart,
    'trend_up': IconsaxPlusLinear.trend_up,
    'trend_down': IconsaxPlusLinear.trend_down,
    // Communication
    'message': IconsaxPlusLinear.message,
    'message_circle': IconsaxPlusLinear.message_circle,
    'call': IconsaxPlusLinear.call,
    'sms': IconsaxPlusLinear.sms,
    'directbox_notif': IconsaxPlusLinear.directbox_notif,
    'notification': IconsaxPlusLinear.notification,
    'send': IconsaxPlusLinear.send,
    // Media
    'musicnote': IconsaxPlusLinear.musicnote,
    'headphone': IconsaxPlusLinear.headphone,
    'speaker': IconsaxPlusLinear.speaker,
    'video': IconsaxPlusLinear.video,
    'camera': IconsaxPlusLinear.camera,
    'gallery': IconsaxPlusLinear.gallery,
    'image': IconsaxPlusLinear.image,
    'play': IconsaxPlusLinear.play,
    'microphone': IconsaxPlusLinear.microphone,
    'radio': IconsaxPlusLinear.radio,
    // People
    'user': IconsaxPlusLinear.user,
    'profile': IconsaxPlusLinear.profile,
    'people': IconsaxPlusLinear.people,
    'man': IconsaxPlusLinear.man,
    'woman': IconsaxPlusLinear.woman,
    'teacher': IconsaxPlusLinear.teacher,
    'personalcard': IconsaxPlusLinear.personalcard,
    // Technology
    'mobile': IconsaxPlusLinear.mobile,
    'monitor': IconsaxPlusLinear.monitor,
    'devices': IconsaxPlusLinear.devices,
    'cpu': IconsaxPlusLinear.cpu,
    'keyboard': IconsaxPlusLinear.keyboard,
    'code': IconsaxPlusLinear.code,
    'wifi': IconsaxPlusLinear.wifi,
    'bluetooth': IconsaxPlusLinear.bluetooth,
    'data': IconsaxPlusLinear.data,
    'external_drive': IconsaxPlusLinear.external_drive,
    // Navigation & UI
    'home': IconsaxPlusLinear.home,
    'setting': IconsaxPlusLinear.setting,
    'search_normal': IconsaxPlusLinear.search_normal,
    'menu': IconsaxPlusLinear.menu,
    'filter': IconsaxPlusLinear.filter,
    'sort': IconsaxPlusLinear.sort,
    'refresh': IconsaxPlusLinear.refresh,
    'link': IconsaxPlusLinear.link,
    'share': IconsaxPlusLinear.share,
    'export': IconsaxPlusLinear.export,
    // Design & Creative
    'brush': IconsaxPlusLinear.brush,
    'pen_tool': IconsaxPlusLinear.pen_tool,
    'magicpen': IconsaxPlusLinear.magicpen,
    'crop': IconsaxPlusLinear.crop,
    'color_swatch': IconsaxPlusLinear.color_swatch,
    'paintbucket': IconsaxPlusLinear.paintbucket,
    'edit': IconsaxPlusLinear.edit,
    'eraser': IconsaxPlusLinear.eraser,
    'scissor': IconsaxPlusLinear.scissor,
    // Health & Wellness
    'health': IconsaxPlusLinear.health,
    'heart': IconsaxPlusLinear.heart,
    'hospital': IconsaxPlusLinear.hospital,
    'microscope': IconsaxPlusLinear.microscope,
    'pet': IconsaxPlusLinear.pet,
    'weight': IconsaxPlusLinear.weight,
    // Travel & Transport
    'airplane': IconsaxPlusLinear.airplane,
    'car': IconsaxPlusLinear.car,
    'truck': IconsaxPlusLinear.truck,
    'bus': IconsaxPlusLinear.bus,
    'ship': IconsaxPlusLinear.ship,
    'map': IconsaxPlusLinear.map,
    'location': IconsaxPlusLinear.location,
    'gps': IconsaxPlusLinear.gps,
    'gas_station': IconsaxPlusLinear.gas_station,
    // Nature & Weather
    'sun': IconsaxPlusLinear.sun,
    'moon': IconsaxPlusLinear.moon,
    'cloud': IconsaxPlusLinear.cloud,
    'wind': IconsaxPlusLinear.wind,
    'drop': IconsaxPlusLinear.drop,
    'tree': IconsaxPlusLinear.tree,
    'flash': IconsaxPlusLinear.flash,
    // Shopping
    'shopping_cart': IconsaxPlusLinear.shopping_cart,
    'shopping_bag': IconsaxPlusLinear.shopping_bag,
    'shop': IconsaxPlusLinear.shop,
    'bag': IconsaxPlusLinear.bag,
    'gift': IconsaxPlusLinear.gift,
    'ticket': IconsaxPlusLinear.ticket,
    'discount_circle': IconsaxPlusLinear.discount_circle,
    // Security
    'security': IconsaxPlusLinear.security,
    'shield': IconsaxPlusLinear.shield,
    'lock': IconsaxPlusLinear.lock,
    'unlock': IconsaxPlusLinear.unlock,
    'key': IconsaxPlusLinear.key,
    'password_check': IconsaxPlusLinear.password_check,
    'finger_scan': IconsaxPlusLinear.finger_scan,
    'eye': IconsaxPlusLinear.eye,
    // Social & Fun
    'star': IconsaxPlusLinear.star,
    'award': IconsaxPlusLinear.award,
    'crown': IconsaxPlusLinear.crown,
    'medal': IconsaxPlusLinear.medal,
    'like': IconsaxPlusLinear.like,
    'flag': IconsaxPlusLinear.flag,
    'emoji_happy': IconsaxPlusLinear.emoji_happy,
    'game': IconsaxPlusLinear.game,
    'ghost': IconsaxPlusLinear.ghost,
    'magic_star': IconsaxPlusLinear.magic_star,
    // Misc
    'coffee': IconsaxPlusLinear.coffee,
    'cake': IconsaxPlusLinear.cake,
    'milk': IconsaxPlusLinear.milk,
    'glass': IconsaxPlusLinear.glass,
    'lamp': IconsaxPlusLinear.lamp,
    'briefcase': IconsaxPlusLinear.briefcase,
    'building': IconsaxPlusLinear.building,
    'courthouse': IconsaxPlusLinear.courthouse,
    'global': IconsaxPlusLinear.global,
    'translate': IconsaxPlusLinear.translate,
    'info_circle': IconsaxPlusLinear.info_circle,
    'danger': IconsaxPlusLinear.danger,
    'trash': IconsaxPlusLinear.trash,
    'tag': IconsaxPlusLinear.tag,
  };

  final List<Widget> _tabs = [TodayPage(), UpcomingPage(), FolderPage()];

  @override
  void initState() {
    super.initState();
    currentTabIndex.value = _currentIndex;
    openAddTaskSheet.addListener(_onAddTaskSignal);
    currentTabIndex.addListener(_onExternalTabChange);
  }

  void _setCurrentIndex(int index, {bool syncNotifier = true}) {
    if (index == _currentIndex) return;
    if (index < 0 || index >= _tabs.length) return;
    if (!mounted) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    if (syncNotifier && currentTabIndex.value != index) {
      currentTabIndex.value = index;
    }
  }

  void _onExternalTabChange() {
    final newIndex = currentTabIndex.value;
    _setCurrentIndex(newIndex, syncNotifier: false);
  }

  void _onAddTaskSignal() {
    if (openAddTaskSheet.value) {
      openAddTaskSheet.value = false;
      // Ensure we're on the Today tab and show the add-task sheet
      _setCurrentIndex(0);
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
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
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
                child: Text(
                  'Select Folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(icon),
                                title: Text(name),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).primaryColor,
                                      )
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
                  padding: const EdgeInsets.only(
                    left: 17,
                    top: 30,
                    right: 17,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          controller: titleController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Task title',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TickButton(
                        onPressed: () {
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                labelPadding: EdgeInsets.zero,
                                side: const BorderSide(
                                  width: 0.5,
                                  color: Color.fromARGB(255, 179, 179, 179),
                                ),
                                label: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      IconsaxPlusLinear.directbox_notif,
                                      size: 22,
                                    ),
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
                                side: const BorderSide(
                                  width: 0.5,
                                  color: Color.fromARGB(255, 179, 179, 179),
                                ),
                                label: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      IconsaxPlusLinear.calendar,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Text(
                                        _getDateLabel(date),
                                        key: ValueKey(date),
                                      ),
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
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 36),
                      const Spacer(),
                      const Text(
                        'Select Icon',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    onChanged: (v) {
                      final q = v.toLowerCase();
                      setSheetState(() {
                        entries = q.isEmpty
                            ? _allIcons.entries.toList()
                            : _allIcons.entries
                                  .where((e) => e.key.contains(q))
                                  .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search icons...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        IconsaxPlusLinear.search_normal,
                        size: 20,
                      ),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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

  @override
  void dispose() {
    openAddTaskSheet.removeListener(_onAddTaskSignal);
    currentTabIndex.removeListener(_onExternalTabChange);
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isForward = _currentIndex >= _previousIndex;
    final double direction = isForward ? 1.0 : -1.0;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 245),

      /*
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
              // Task actions are shown via long-press popup menu.
              return const SizedBox.shrink();
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
      */
      appBar: AppbarWidget(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final childIndex = child.key is ValueKey<int>
              ? (child.key as ValueKey<int>).value
              : _currentIndex;
          final isIncoming = childIndex == _currentIndex;
          final beginX = isIncoming ? 0.045 * direction : -0.045 * direction;

          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(beginX, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _tabs[_currentIndex],
        ),
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: selectionMode,
            builder: (context, inSelectionMode, _) {
              final navSelectedIndex = _currentIndex == 2 ? 2 : 0;
              final centerButton = Container(
                width: 93,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.88,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    inSelectionMode ? IconsaxPlusLinear.menu_1 : Icons.add,
                    key: ValueKey<bool>(inSelectionMode),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              );

              return NavigationBar(
                backgroundColor: Color.fromARGB(255, 247, 247, 245),
                height: 55,
                selectedIndex: navSelectedIndex,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                indicatorColor: Colors.transparent,
                onDestinationSelected: (int index) {
                  if (index == 1) {
                    if (inSelectionMode) {
                      if (_currentIndex == 2) {
                        showSelectedFoldersActionMenu(context);
                      } else {
                        showSelectedTasksActionMenu(context);
                      }
                    } else {
                      if (_currentIndex == 2) {
                        _showCreateFolderDialog();
                      } else {
                        _showAddTaskSheet();
                      }
                    }
                    return;
                  }
                  _setCurrentIndex(index);
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(IconsaxPlusLinear.calendar_1, size: 30),
                    selectedIcon: Icon(IconsaxPlusBold.calendar_1, size: 32),
                    label: '',
                  ),
                  NavigationDestination(
                    icon: centerButton,
                    selectedIcon: centerButton,
                    label: '',
                  ),
                  NavigationDestination(
                    icon: Icon(IconsaxPlusLinear.folder, size: 25),
                    selectedIcon: Icon(IconsaxPlusBold.folder, size: 30),
                    label: '',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
