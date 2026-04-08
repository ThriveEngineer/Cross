import 'package:cross/widgets/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowUsPage extends StatelessWidget {
  const FollowUsPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        width: double.infinity,
        color: kSettingsBackgroundColor,
        child: Column(
          children: [
            const SettingsPageHeader(title: 'Follow us'),
            const SizedBox(height: 16),
            SettingsSectionCard(
              child: Column(
                children: [
                  SettingsActionRow(
                    leading: const Icon(IconsaxPlusBold.messages_2, size: 20),
                    title: 'Threads (Personal)',
                    onTap: () => _launchUrl(
                      'https://www.threads.com/@luis.journey.hello',
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  SettingsActionRow(
                    leading: const Icon(IconsaxPlusBold.messages_2, size: 20),
                    title: 'Threads (Cross)',
                    onTap: () =>
                        _launchUrl('https://www.threads.com/@cross.task'),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  SettingsActionRow(
                    leading: const Icon(IconsaxPlusBold.messages_2, size: 20),
                    title: 'X / Twitter (Cross)',
                    onTap: () => _launchUrl('https://x.com/Cross_tasks'),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  SettingsActionRow(
                    leading: const Icon(IconsaxPlusBold.messages_2, size: 20),
                    title: 'X / Twitter (Personal)',
                    onTap: () => _launchUrl('https://x.com/Kres73752231'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
