import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/monetization_service.dart';
import '../../services/update_service.dart';

Future<void> openExternal(BuildContext context, String url) async {
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {}
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Unable to open this link. Please check your connection and try again.',
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final ads = MonetizationService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ads,
          builder: (context, _) => ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => openExternal(context, privacyPolicyUrl),
              ),
              if (ads.privacyRequired)
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Privacy Choices'),
                  onTap: () async {
                    final success = await ads.showPrivacyChoices();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Privacy choices are unavailable. Please try again later.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text('Support'),
                subtitle: const Text('support@wolftrailstudio.com'),
                onTap: () =>
                    openExternal(context, 'mailto:support@wolftrailstudio.com'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
