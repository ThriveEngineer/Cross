import 'dart:io';

import 'package:cross/Controller/todo_list.dart';
import 'package:cross/services/widget_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class WidgetSettingsPage extends StatefulWidget {
  const WidgetSettingsPage({super.key});

  @override
  State<WidgetSettingsPage> createState() => _WidgetSettingsPageState();
}

class _WidgetSettingsPageState extends State<WidgetSettingsPage> {
  String _taskFolder = 'Inbox';

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    // Migrate old shared key if needed
    final oldFolder = await HomeWidget.getWidgetData<String>('widget_selected_folder');
    final existingTask = await HomeWidget.getWidgetData<String>('widget_task_folder');

    if (oldFolder != null && existingTask == null) {
      await HomeWidget.saveWidgetData<String>('widget_task_folder', oldFolder);
      await HomeWidget.saveWidgetData<String?>('widget_selected_folder', null);
      if (mounted) {
        setState(() {
          _taskFolder = oldFolder;
        });
      }
      await WidgetService.syncWidgetData();
      return;
    }

    if (mounted) {
      setState(() {
        _taskFolder = existingTask ?? 'Inbox';
      });
    }
  }

  Future<void> _saveTaskFolder(String folder) async {
    setState(() => _taskFolder = folder);
    await HomeWidget.saveWidgetData<String>('widget_task_folder', folder);
    await WidgetService.syncWidgetData();
  }

  Future<void> _requestPinWidget(String qualifiedName) async {
    if (!Platform.isAndroid) return;
    try {
      await HomeWidget.requestPinWidget(
        qualifiedAndroidName: qualifiedName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add widget. Try adding it from your home screen.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 242, 242, 247)),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(IconsaxPlusLinear.arrow_left_1),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.28),
                const Text("Widgets", style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 25),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Task List Folder Selection ──
                    ClipPath(
                      clipper: ShapeBorderClipper(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        width: 353,
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Task List Folder",
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _showFolderPicker(
                                context,
                                currentFolder: _taskFolder,
                                onSelected: _saveTaskFolder,
                              ),
                              child: Row(
                                children: [
                                  const Icon(IconsaxPlusLinear.task_square, size: 20),
                                  const SizedBox(width: 13),
                                  Text(_taskFolder),
                                  const Spacer(),
                                  const Icon(IconsaxPlusLinear.arrow_right_3),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "The Task List widget will show tasks from this folder.",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ── Add Widgets ──
                    ClipPath(
                      clipper: ShapeBorderClipper(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        width: 353,
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Add Widgets",
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            _WidgetItem(
                              icon: IconsaxPlusLinear.task_square,
                              title: "Task List",
                              subtitle: "View and tick off tasks from a folder",
                              onAdd: () => _requestPinWidget(
                                'thrive.cross.widgets.TaskListWidgetReceiver',
                              ),
                            ),
                            const Divider(height: 0.5, color: Color.fromARGB(255, 194, 194, 194)),
                            _WidgetItem(
                              icon: IconsaxPlusLinear.calendar_1,
                              title: "Due Today",
                              subtitle: "Tasks due today with checkboxes",
                              onAdd: () => _requestPinWidget(
                                'thrive.cross.widgets.DueTodayWidgetReceiver',
                              ),
                            ),
                            const Divider(height: 0.5, color: Color.fromARGB(255, 194, 194, 194)),
                            _WidgetItem(
                              icon: IconsaxPlusLinear.folder_open,
                              title: "Folder Overview",
                              subtitle: "See all folders with task counts",
                              onAdd: () => _requestPinWidget(
                                'thrive.cross.widgets.FolderOverviewWidgetReceiver',
                              ),
                            ),
                            const Divider(height: 0.5, color: Color.fromARGB(255, 194, 194, 194)),
                            _WidgetItem(
                              icon: IconsaxPlusLinear.add_square,
                              title: "Quick Add",
                              subtitle: "One tap to open the app",
                              onAdd: () => _requestPinWidget(
                                'thrive.cross.widgets.QuickAddWidgetReceiver',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "You can also add widgets by long-pressing your home screen and selecting Cross from the widgets list.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderPicker(
    BuildContext context, {
    required String currentFolder,
    required ValueChanged<String> onSelected,
  }) {
    showCupertinoSheet(
      context: context,
      builder: (context) => Material(
        color: const Color.fromARGB(255, 242, 242, 247),
        child: _FolderPickerSheet(
          currentFolder: currentFolder,
          onSelected: (folder) {
            onSelected(folder);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _WidgetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  const _WidgetItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderPickerSheet extends StatelessWidget {
  final String currentFolder;
  final ValueChanged<String> onSelected;

  const _FolderPickerSheet({
    required this.currentFolder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Color.fromARGB(255, 242, 242, 247)),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(IconsaxPlusLinear.arrow_left_1),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.22),
                const Text("Select Folder", style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: foldersList,
                builder: (context, folders, _) {
                  return ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: ColorScheme.of(context).surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: folders.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 0.5,
                          color: Color.fromARGB(255, 194, 194, 194),
                        ),
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final name = folder['name'] as String;
                          final icon = folder['icon'] as IconData;
                          final isSelected = name == currentFolder;

                          return InkWell(
                            onTap: () => onSelected(name),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Icon(icon, size: 20),
                                  const SizedBox(width: 13),
                                  Text(name),
                                  const Spacer(),
                                  if (isSelected)
                                    const Icon(
                                      IconsaxPlusBold.tick_circle,
                                      color: Color(0xFF1D1D1D),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
