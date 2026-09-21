import 'package:flutter/material.dart';
import 'vk_settings_screen.dart';
import 'sms_settings_screen.dart';

class NotificationChannelsScreen extends StatelessWidget {
  const NotificationChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text('VK Bot'),
              subtitle: const Text('Уведомления в VK'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VkSettingsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sms, color: Colors.green),
              title: const Text('SMS'),
              subtitle: const Text('Уведомления по SMS'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmsSettingsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}