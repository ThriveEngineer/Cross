import 'package:cross/View/notion_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:cross/Controller/todo_list.dart';

class IntegrationsPage extends StatefulWidget {
  const IntegrationsPage({super.key});

  @override
  State<IntegrationsPage> createState() => _IntegrationsPageState();
}

class _IntegrationsPageState extends State<IntegrationsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 242, 242, 247),
                        ),
                        child: Column(children: [

                          SizedBox(height: 5),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                }, 
                                icon: Icon(IconsaxPlusLinear.arrow_left_1,)
                                ),

                                SizedBox(width: MediaQuery.of(context).size.width * 0.32,),

                              Text(
                              "Integrations", style: TextStyle(fontWeight: FontWeight.w500),
                              ),

                              Spacer(),
                              ]),

                          SizedBox(height: 25,),
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

                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NotionSettingsPage(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Image(
                                            image: AssetImage(
                                              'lib/assets/Notion-logo.svg.png',
                                              )
                                             )
                                            ),
                                        SizedBox(width: 13,),
                                        Text("Notion"),
                                        Spacer(),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => NotionSettingsPage(),
                                              ),
                                            );
                                          },
                                          icon: Icon(IconsaxPlusLinear.arrow_right_3)
                                        ),
                                      ],
                                    ),
                                  ),

                                  Divider(
                                    height: 0.5,
                                    color: Color.fromARGB(255, 194, 194, 194),
                                  ),

                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Image(
                                          image: AssetImage(
                                            'lib/assets/2023_Obsidian_logo.svg.png',
                                            )
                                           )
                                          ),
                                      SizedBox(width: 13,),
                                      Text("Obsidian"),
                                      Spacer(),
                                      ValueListenableBuilder<bool>(
                                        valueListenable: showFolderNames,
                                        builder: (context, value, _) {
                                          return IconButton(
                                            onPressed: () {}, 
                                            icon: Icon(IconsaxPlusLinear.arrow_right_3),
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
                        ],
                        ),
                      );
  }
}