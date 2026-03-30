import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:cross/Controller/todo_list.dart';

class ViewSettings extends StatefulWidget {
  const ViewSettings({super.key});

  @override
  State<ViewSettings> createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {
  final GlobalKey _sortButtonKey = GlobalKey();

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.manual:
        return IconsaxPlusBold.blend;
      case SortOption.name:
        return IconsaxPlusBold.text;
      case SortOption.date:
        return IconsaxPlusBold.calendar;
      case SortOption.folder:
        return IconsaxPlusBold.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 1,
      decoration: BoxDecoration(color: Color.fromARGB(255, 242, 242, 247)),
      child: Column(
        children: [
          ClipPath(
            clipper: ShapeBorderClipper(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              width: 353,
              decoration: BoxDecoration(
                color: ColorScheme.of(context).surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(IconsaxPlusBold.tick_circle),
                      SizedBox(width: 13),
                      Text("Completed tasks"),
                      Spacer(),
                      ValueListenableBuilder<bool>(
                        valueListenable: showCompletedInToday,
                        builder: (context, value, _) {
                          return Switch(
                            value: value,
                            onChanged: (v) => showCompletedInToday.value = v,
                            activeTrackColor: ColorScheme.of(context).primary,
                          );
                        },
                      ),
                    ],
                  ),

                  Divider(
                    height: 0.5,
                    color: Color.fromARGB(255, 194, 194, 194),
                  ),

                  Row(
                    children: [
                      Icon(IconsaxPlusBold.folder),
                      SizedBox(width: 13),
                      Text("Folder"),
                      Spacer(),
                      ValueListenableBuilder<bool>(
                        valueListenable: showFolderNames,
                        builder: (context, value, _) {
                          return Switch(
                            value: value,
                            onChanged: (v) => showFolderNames.value = v,
                            activeTrackColor: ColorScheme.of(context).primary,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25),

          GestureDetector(
            key: _sortButtonKey,
            onTap: () {
              // Get button position for menu placement on the right
              final RenderBox button =
                  _sortButtonKey.currentContext!.findRenderObject()
                      as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final Offset buttonPosition = button.localToGlobal(
                Offset.zero,
                ancestor: overlay,
              );
              final Size buttonSize = button.size;

              // Position menu aligned to the right edge of the button
              final RelativeRect position = RelativeRect.fromLTRB(
                buttonPosition.dx, // left
                buttonPosition.dy + buttonSize.height, // top (below button)
                overlay.size.width -
                    (buttonPosition.dx + buttonSize.width), // right
                overlay.size.height -
                    (buttonPosition.dy + buttonSize.height), // bottom
              );

              // Show popup menu
              showMenu<SortOption>(
                context: context,
                position: position,
                elevation: 0.1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                items: SortOption.values.map((option) {
                  final isSelected = currentSortOption.value == option;
                  return PopupMenuItem<SortOption>(
                    value: option,
                    child: Row(
                      children: [
                        Icon(
                          _getSortIcon(option),
                          color: isSelected
                              ? ColorScheme.of(context).primary
                              : null,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Text(
                          option.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? ColorScheme.of(context).primary
                                : null,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          Spacer(),
                          Icon(
                            IconsaxPlusBold.tick_circle,
                            color: ColorScheme.of(context).primary,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ).then((selectedOption) async {
                if (selectedOption != null) {
                  await SortPreferences.saveSortPreference(selectedOption);
                  // Allow menu to fully dismiss before closing the sheet
                  if (mounted) {
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (mounted && context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              width: 353,
              decoration: BoxDecoration(
                color: ColorScheme.of(context).surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(IconsaxPlusBold.sort),
                  SizedBox(width: 13),
                  Text("Sort"),
                  Spacer(),
                  ValueListenableBuilder<SortOption>(
                    valueListenable: currentSortOption,
                    builder: (context, sortOption, _) {
                      return Text(sortOption.displayName);
                    },
                  ),
                  SizedBox(width: 5),
                  Icon(IconsaxPlusBold.arrow_down),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
