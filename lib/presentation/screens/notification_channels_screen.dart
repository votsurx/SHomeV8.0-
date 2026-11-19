import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'sms_settings_screen.dart';
import 'vk_settings_screen.dart';

class NotificationChannelsScreen extends StatelessWidget {
  const NotificationChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationChannelsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text('VK Bot'),
              subtitle: Text(l10n.notificationVkSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const VkSettingsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sms, color: Colors.green),
              title: const Text('SMS'),
              subtitle: Text(l10n.notificationSmsSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SmsSettingsScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}