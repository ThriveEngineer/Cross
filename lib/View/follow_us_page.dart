import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:cross/Controller/todo_list.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowUsPage extends StatefulWidget {
  const FollowUsPage({super.key});

  @override
  State<FollowUsPage> createState() => _FollowUsPageState();
}

class _FollowUsPageState extends State<FollowUsPage> {
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
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

              Text("Follow us", style: TextStyle(fontWeight: FontWeight.w500)),

              Spacer(),
            ],
          ),

          SizedBox(height: 25),
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
                    onTap: () => _launchUrl(
                      'https://www.threads.com/@luis.journey.hello',
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 13),
                        Text("Threads (Personal)"),
                        Spacer(),
                        IconButton(
                          onPressed: () => _launchUrl(
                            'https://www.threads.com/@luis.journey.hello',
                          ),
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
                    onTap: () =>
                        _launchUrl('https://www.threads.com/@cross.task'),
                    child: Row(
                      children: [
                        SizedBox(width: 13),
                        Text("Threads (Cross)"),
                        Spacer(),
                        ValueListenableBuilder<bool>(
                          valueListenable: showFolderNames,
                          builder: (context, value, _) {
                            return IconButton(
                              onPressed: () => _launchUrl(
                                'https://www.threads.com/@cross.task',
                              ),
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
                    onTap: () => _launchUrl('https://x.com/Cross_tasks'),
                    child: Row(
                      children: [
                        SizedBox(width: 13),
                        Text("X/Twitter (Cross)"),
                        Spacer(),
                        IconButton(
                          onPressed: () =>
                              _launchUrl('https://x.com/Cross_tasks'),
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
                    onTap: () => _launchUrl('https://x.com/Kres73752231'),
                    child: Row(
                      children: [
                        SizedBox(width: 13),
                        Text("X/Twitter (Personal)"),
                        Spacer(),
                        IconButton(
                          onPressed: () =>
                              _launchUrl('https://x.com/Kres73752231'),
                          icon: Icon(IconsaxPlusLinear.arrow_right_3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}
