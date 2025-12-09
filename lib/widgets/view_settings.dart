import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:cross/Controller/todo_list.dart';

class ViewSettings extends StatefulWidget {
  const ViewSettings({super.key});

  @override
  State<ViewSettings> createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 242, 242, 247),
                        ),
                        child: Column(children: [
                          ClipPath(
                            clipper: ShapeBorderClipper(
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              width: 353,
                              decoration: BoxDecoration(
                                color: ColorScheme.of(context).surface,
                                borderRadius: BorderRadius.circular(18)
                              ),
                              child: Column(
                                children: [

                                  Row(
                                    children: [
                                      Icon(IconsaxPlusBold.tick_circle),
                                      SizedBox(width: 13,),
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
                                      SizedBox(width: 13,),
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
                                        }
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),

                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              width: 353,
                              decoration: BoxDecoration(
                                color: ColorScheme.of(context).surface,
                                borderRadius: BorderRadius.circular(18)
                              ),
                                    child: Row(
                                      children: [
                                        Icon(IconsaxPlusBold.sort),
                                        SizedBox(width: 13,),
                                        Text("Sort"),
                                        Spacer(),
                                        Text("Manual"),
                                        SizedBox(width: 5,),
                                        Icon(IconsaxPlusBold.arrow_down)
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 25,),

                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              width: 353,
                              decoration: BoxDecoration(
                                color: ColorScheme.of(context).surface,
                                borderRadius: BorderRadius.circular(18)
                              ),
                                    child: Row(
                                      children: [
                                        Icon(IconsaxPlusBroken.category),
                                        SizedBox(width: 13,),
                                        Text("Group"),
                                        Spacer(),
                                        Text("None"),
                                        SizedBox(width: 5,),
                                        Icon(IconsaxPlusBold.arrow_down)
                                      ],
                                    ),
                                  ),
                        ],
                        ),
                      );
  }
}