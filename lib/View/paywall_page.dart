import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Presents a donation page encouraging users to support the app
/// via Buy Me a Coffee.
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  static const String _donateUrl = 'https://buymeacoffee.com/thrive.dev';

  /// Convenience method to present the donation page.
  static Future<bool> show(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaywallPage()),
    );
    return result ?? false;
  }

  void _openDonateLink() {
    launchUrl(Uri.parse(_donateUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 242, 247),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Support Cross',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All features are completely free.\nIf you enjoy the app, consider buying us a coffee!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _openDonateLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDD00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Buy Me a Coffee',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
