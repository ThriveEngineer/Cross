import 'package:cross/View/notion_settings_page.dart';
import 'package:cross/widgets/settings_ui.dart';
import 'package:flutter/material.dart';

class IntegrationsPage extends StatelessWidget {
  const IntegrationsPage({super.key});

  void _openNotion(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotionSettingsPage()),
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
            const SettingsPageHeader(title: 'Integrations'),
            const SizedBox(height: 16),
            SettingsSectionCard(
              child: Column(
                children: [
                  SettingsActionRow(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'lib/assets/Notion-logo.svg.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: 'Notion',
                    subtitle: 'Bi-directional sync',
                    onTap: () => _openNotion(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E5E5)),
                  SettingsActionRow(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        'lib/assets/2023_Obsidian_logo.svg.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: 'Obsidian',
                    subtitle: 'Coming soon',
                    enabled: false,
                    showChevron: false,
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
