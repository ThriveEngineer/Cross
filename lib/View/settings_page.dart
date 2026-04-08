import 'package:cross/View/follow_us_page.dart';
import 'package:cross/View/integrations_page.dart';
import 'package:cross/View/widget_settings_page.dart';
import 'package:cross/widgets/settings_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _openSupportLink() async {
    await launchUrl(
      Uri.parse('https://buymeacoffee.com/thrive.dev'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openIntegrations(BuildContext context) {
    showCupertinoSheet(
      context: context,
      builder: (context) => const Material(
        color: kSettingsBackgroundColor,
        child: IntegrationsPage(),
      ),
    );
  }

  void _openWidgetSettings(BuildContext context) {
    showCupertinoSheet(
      context: context,
      builder: (context) => const Material(
        color: kSettingsBackgroundColor,
        child: WidgetSettingsPage(),
      ),
    );
  }

  void _openFollowUs(BuildContext context) {
    showCupertinoSheet(
      context: context,
      builder: (context) => const Material(
        color: kSettingsBackgroundColor,
        child: FollowUsPage(),
      ),
    );
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
            const SettingsPageHeader(title: 'Settings'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: [
                    _SupportCard(
                      onTap: () {
                        _openSupportLink();
                      },
                    ),
                    const SizedBox(height: 16),
                    SettingsSectionCard(
                      child: Column(
                        children: [
                          const SettingsActionRow(
                            leading: Icon(IconsaxPlusLinear.global, size: 20),
                            title: 'Language',
                            subtitle: 'Coming soon',
                            enabled: false,
                            showChevron: false,
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          SettingsActionRow(
                            leading: const Icon(
                              IconsaxPlusLinear.component,
                              size: 20,
                            ),
                            title: 'Integrations',
                            onTap: () => _openIntegrations(context),
                          ),
                          const Divider(height: 1, color: Color(0xFFE5E5E5)),
                          SettingsActionRow(
                            leading: const Icon(
                              IconsaxPlusLinear.mobile,
                              size: 20,
                            ),
                            title: 'Widgets',
                            onTap: () => _openWidgetSettings(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingsSectionCard(
                      child: SettingsActionRow(
                        leading: const Icon(
                          IconsaxPlusBold.messages_2,
                          size: 20,
                        ),
                        title: 'Follow us',
                        onTap: () => _openFollowUs(context),
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

class _SupportCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SupportCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Support Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Buy us a coffee',
                  style: TextStyle(color: Color(0xFFCFCFCF), fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDD00),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Donate',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
