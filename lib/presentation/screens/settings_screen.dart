import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../application/services/update_service.dart';
import '../../data/services/config_service.dart';
import 'documents/legal_documents_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _pollInterval = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pollInterval = prefs.getInt('poll_interval') ?? 2;
    });
  }

  Future<void> _exportConfig() async {
    try {
      await ConfigService.exportConfig();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Конфиг готов к отправке')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  Future<void> _importConfig() async {
    try {
      await ConfigService.importConfig();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Импорт выполнен!')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Резервное копирование'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _exportConfig();
            },
            child: const ListTile(
              leading: Icon(Icons.upload, color: Colors.blue),
              title: Text('Экспортировать'),
              subtitle: Text('Поделиться через облако, почту, Telegram'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(ctx);
              _importConfig();
            },
            child: const ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Импортировать'),
              subtitle: Text('Выбрать файл на устройстве или в облаке'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ⏱️ Интервал опроса
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.orange),
              title: const Text('Интервал опроса'),
              subtitle: Text('$_pollInterval сек'),
              onTap: () async {
                final selected = await showDialog<int>(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: const Text('Интервал опроса'),
                    children: [2, 5, 10, 30]
                        .map((s) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, s),
                      child: Text('$s секунд'),
                    ))
                        .toList(),
                  ),
                );
                if (!context.mounted) return;
                if (selected != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('poll_interval', selected);
                  if (!context.mounted) return;
                  setState(() => _pollInterval = selected);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Интервал изменён на $selected сек. Перезапустите приложение.',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // 💾 Резервное копирование
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: const Text('Резервное копирование'),
              subtitle: const Text('Экспорт / Импорт'),
              onTap: () => _showBackupDialog(context),
            ),
          ),
          const SizedBox(height: 12),

          // 🖥️ NVR
          Card(
            child: ListTile(
              leading: const Icon(Icons.security, color: Colors.red),
              title: const Text('Видео NVR'),
              subtitle: const Text('Настройка подключения к LegionNVR'),
              onTap: () => context.push('/nvr_settings'),
            ),
          ),
          const SizedBox(height: 12),

          // 📡 MyiSpy MQTT
          Card(
            child: ListTile(
              leading: const Icon(Icons.wifi_tethering, color: Colors.orange),
              title: const Text('Видео MyiSpy'),
              subtitle: const Text('Настройка подключения к MQTT брокеру MyiSpy'),
              onTap: () => context.push('/mqtt_settings'),
            ),
          ),
          const SizedBox(height: 12),

          // ℹ️ Обновление
          Card(
            child: ListTile(
              leading: const Icon(Icons.update, color: Colors.green),
              title: const Text('Проверить обновления'),
              subtitle: const Text('Проверить наличие новой версии'),
              onTap: () => UpdateService.checkForUpdates(context),
            ),
          ),
          const SizedBox(height: 12),

          // ℹ️ О приложении
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Информация'),
              subtitle: const Text('Лицензии и соглашения'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalDocumentsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}