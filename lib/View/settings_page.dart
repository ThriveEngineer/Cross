import 'package:cross/View/follow_us_page.dart';
import 'package:cross/View/integrations_page.dart';
import 'package:cross/View/widget_settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width * 1,
        decoration: BoxDecoration(color: Color.fromARGB(255, 242, 242, 247)),
        child: Column(
          children: [
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(IconsaxPlusLinear.arrow_left_1),
                ),

                SizedBox(width: MediaQuery.of(context).size.width * 0.32),

                Text("Settings", style: TextStyle(fontWeight: FontWeight.w500)),

                Spacer(),
              ],
            ),

            SizedBox(height: 25),

            // ── Support Us Section ──
            ClipPath(
              clipper: ShapeBorderClipper(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                width: 353,
                height: 67,
                decoration: BoxDecoration(
                  color: ColorScheme.of(context).primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('https://buymeacoffee.com/thrive.dev'), mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Support Us",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Buy us a coffee",
                            style: TextStyle(
                              color: Color.fromARGB(255, 242, 242, 247),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 21, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDD00),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text("Donate",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 36),

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
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(IconsaxPlusLinear.global),
                          SizedBox(width: 13),
                          Text("Language | Coming soon!"),
                          Spacer(),
                          ValueListenableBuilder<bool>(
                            valueListenable: showFolderNames,
                            builder: (context, value, _) {
                              return IconButton(
                                onPressed: () {},
                                icon: Icon(IconsaxPlusLinear.arrow_right_3),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 0.5,
                      color: Color.fromARGB(255, 194, 194, 194),
                    ),

                    InkWell(
                      onTap: () {
                        showCupertinoSheet(
                          context: context,
                          builder: (context) => Material(
                            color: Color.fromARGB(255, 242, 242, 247),
                            child: IntegrationsPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(IconsaxPlusLinear.component),
                          SizedBox(width: 13),
                          Text("Integrations"),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              showCupertinoSheet(
                                context: context,
                                builder: (context) => Material(
                                  color: Color.fromARGB(255, 242, 242, 247),
                                  child: IntegrationsPage(),
                                ),
                              );
                            },
                            icon: Icon(IconsaxPlusLinear.arrow_right_3),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 0.5,
                      color: Color.fromARGB(255, 194, 194, 194),
                    ),

                    InkWell(
                      onTap: () {
                        showCupertinoSheet(
                          context: context,
                          builder: (context) => Material(
                            color: Color.fromARGB(255, 242, 242, 247),
                            child: WidgetSettingsPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(IconsaxPlusLinear.mobile),
                          SizedBox(width: 13),
                          Text("Widgets"),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              showCupertinoSheet(
                                context: context,
                                builder: (context) => Material(
                                  color: Color.fromARGB(255, 242, 242, 247),
                                  child: WidgetSettingsPage(),
                                ),
                              );
                            },
                            icon: Icon(IconsaxPlusLinear.arrow_right_3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 35),

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
                    /* Row(
                      children: [
                        Icon(IconsaxPlusBold.like_1),
                        SizedBox(width: 13),
                        Text("Feedback"),
                        Spacer(),
                        ValueListenableBuilder<bool>(
                          valueListenable: showCompletedInToday,
                          builder: (context, value, _) {
                            return IconButton(
                              onPressed: () {},
                              icon: Icon(IconsaxPlusLinear.arrow_right_3),
                            );
                          },
                        ),
                      ],
                    ),

                    Divider(
                      height: 0.5,
                      color: Color.fromARGB(255, 194, 194, 194),
                    ),
                    */
                    InkWell(
                      onTap: () {
                        showCupertinoSheet(
                          context: context,
                          builder: (context) => Material(
                            color: Color.fromARGB(255, 242, 242, 247),
                            child: FollowUsPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(IconsaxPlusBold.messages_2),
                          SizedBox(width: 13),
                          Text("Follow us"),
                          Spacer(),
                          ValueListenableBuilder<bool>(
                            valueListenable: showFolderNames,
                            builder: (context, value, _) {
                              return IconButton(
                                onPressed: () {
                                  showCupertinoSheet(
                                    context: context,
                                    builder: (context) => Material(
                                      color: Color.fromARGB(255, 242, 242, 247),
                                      child: IntegrationsPage(),
                                    ),
                                  );
                                },
                                icon: Icon(IconsaxPlusLinear.arrow_right_3),
                              );
                            },
                          ),
                        ],
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
}
