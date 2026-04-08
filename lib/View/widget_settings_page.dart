import 'dart:io';

import 'package:cross/Controller/todo_list.dart';
import 'package:cross/services/widget_service.dart';
import 'package:cross/widgets/settings_ui.dart';
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
    final oldFolder = await HomeWidget.getWidgetData<String>(
      'widget_selected_folder',
    );
    final existingTask = await HomeWidget.getWidgetData<String>(
      'widget_task_folder',
    );

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
      await HomeWidget.requestPinWidget(qualifiedAndroidName: qualifiedName);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not add widget. Try adding it from your home screen.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.82,
        width: double.infinity,
        color: kSettingsBackgroundColor,
        child: Column(
          children: [
            const SettingsPageHeader(title: 'Widgets'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: [
                    SettingsSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task List Folder',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _showFolderPicker(
                              context,
                              currentFolder: _taskFolder,
                              onSelected: _saveTaskFolder,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    IconsaxPlusLinear.task_square,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _taskFolder,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    IconsaxPlusLinear.arrow_right_3,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'The Task List widget will show tasks from this folder.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingsSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Widgets',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _WidgetItem(
                            icon: IconsaxPlusLinear.task_square,
                            title: 'Task List',
                            subtitle: 'View and tick off tasks from a folder',
                            onAdd: () => _requestPinWidget(
                              'thrive.cross.widgets.TaskListWidgetReceiver',
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          _WidgetItem(
                            icon: IconsaxPlusLinear.calendar_1,
                            title: 'Due Today',
                            subtitle: 'Tasks due today with checkboxes',
                            onAdd: () => _requestPinWidget(
                              'thrive.cross.widgets.DueTodayWidgetReceiver',
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          _WidgetItem(
                            icon: IconsaxPlusLinear.folder_open,
                            title: 'Folder Overview',
                            subtitle: 'See all folders with task counts',
                            onAdd: () => _requestPinWidget(
                              'thrive.cross.widgets.FolderOverviewWidgetReceiver',
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          _WidgetItem(
                            icon: IconsaxPlusLinear.add_square,
                            title: 'Quick Add',
                            subtitle: 'One tap to open the app',
                            onAdd: () => _requestPinWidget(
                              'thrive.cross.widgets.QuickAddWidgetReceiver',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        'You can also add widgets by long-pressing your home screen and selecting Cross from the widgets list.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
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
        color: kSettingsBackgroundColor,
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
        height: MediaQuery.of(context).size.height * 0.65,
        width: double.infinity,
        color: kSettingsBackgroundColor,
        child: Column(
          children: [
            const SettingsPageHeader(title: 'Select Folder'),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: foldersList,
                builder: (context, folders, _) {
                  return SettingsSectionCard(
                    child: ListView.separated(
                      itemCount: folders.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        final name = folder['name'] as String;
                        final icon = folder['icon'] as IconData;
                        final isSelected = name == currentFolder;

                        return InkWell(
                          onTap: () => onSelected(name),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(icon, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
