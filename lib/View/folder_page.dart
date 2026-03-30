import 'package:cross/Controller/todo_list.dart';
import 'package:cross/view/folder_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

// foldersList is now imported from todo_list.dart

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _folderController = TextEditingController();

  void _navigateToFolder(String folderName, IconData folderIcon) {
    if (selectionMode.value) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FolderDetailPage(folderName: folderName, folderIcon: folderIcon),
      ),
    );
  }

  void _toggleFolderSelection(int index) {
    final currentSelection = Set<int>.from(selectedFolders.value);
    if (currentSelection.contains(index)) {
      currentSelection.remove(index);
    } else {
      currentSelection.add(index);
    }
    selectedFolders.value = currentSelection;
  }

  void _clearFolderSelection() {
    selectedFolders.value = {};
  }

  @override
  void initState() {
    super.initState();
    // Listen to selection mode changes to clear folder selection when it's turned off
    selectionMode.addListener(_onSelectionModeChanged);
  }

  void _onSelectionModeChanged() {
    if (!selectionMode.value) {
      _clearFolderSelection();
    }
  }

  @override
  void dispose() {
    selectionMode.removeListener(_onSelectionModeChanged);
    _folderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: selectionMode,
      builder: (context, inSelectionMode, _) {
        return Column(
          // header
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, bottom: 25),
              child: Row(
                children: [
                  const Text(
                    "Folders",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: foldersList,
                builder: (context, folders, _) {
                  return ValueListenableBuilder<Set<int>>(
                    valueListenable: selectedFolders,
                    builder: (context, selectedIndices, _) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        itemCount: folders.length,
                        itemBuilder: (context, index) {
                          final folder = folders[index];
                          final folderName = folder['name'] as String;
                          final folderIcon = folder['icon'] as IconData;
                          final isDefault = folder['isDefault'] as bool;
                          final isSelected = selectedIndices.contains(index);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: InkWell(
                              onTap: () {
                                if (inSelectionMode) {
                                  if (!isDefault) {
                                    _toggleFolderSelection(index);
                                  }
                                } else {
                                  _navigateToFolder(folderName, folderIcon);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: isSelected && inSelectionMode
                                      ? Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.2)
                                      : const Color.fromARGB(
                                          255,
                                          243,
                                          243,
                                          243,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    if (inSelectionMode)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: Icon(
                                          isSelected
                                              ? IconsaxPlusBold.tick_circle
                                              : (isDefault
                                                    ? Icons.lock_outline
                                                    : Icons.circle_outlined),
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : (isDefault
                                                    ? Colors.grey
                                                    : Colors.grey.shade400),
                                          size: 24,
                                        ),
                                      ),
                                    Icon(folderIcon, size: 24),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        folderName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (!inSelectionMode)
                                      Icon(
                                        IconsaxPlusLinear.arrow_right_3,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
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
        );
      },
    );
  }
}
