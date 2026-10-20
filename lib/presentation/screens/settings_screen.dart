import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../application/services/update_service.dart';
import '../../data/services/config_service.dart';
import 'documents/legal_documents_screen.dart';
import 'package:restart_app/restart_app.dart';

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

  // ═══════════════════════════════════════════════════════════════
  // ЭКСПОРТ
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // ИМПОРТ — с диалогом перезапуска
  // ═══════════════════════════════════════════════════════════════

  Future<void> _importConfig() async {
    try {
      await ConfigService.importConfig();
      if (!mounted) return;

      final restart = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('✅ Импорт выполнен'),
          content: const Text(
            'Данные восстановлены.\n\n'
                'Рекомендуется перезапустить приложение, '
                'чтобы все настройки (VK, облако, устройства) применились.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Позже'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Перезапустить'),
            ),
          ],
        ),
      );

      if (restart == true) {
        await Restart.restartApp();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $e')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ДИАЛОГ БЕКАПА
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

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

          // ⚙️ НАСТРОЙКИ MQTT
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_ethernet, color: Colors.teal),
              title: const Text('Настройки MQTT'),
              subtitle: const Text('Брокер для Zigbee2MQTT'),
              onTap: () => context.push('/mqtt_broker_settings'),
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

          // ℹ️ Информация
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