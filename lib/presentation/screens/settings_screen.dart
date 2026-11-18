import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../application/services/update_service.dart';
import '../../data/services/adaptive_poller.dart';
import '../../data/services/config_service.dart';
import 'documents/legal_documents_screen.dart';
import 'package:restart_app/restart_app.dart';
import '../../data/local/database.dart';
import 'package:shome/presentation/screens/screen_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _pollIntervalMs = AdaptivePoller.defaultIntervalMs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final ms = await AdaptivePoller.readIntervalMs();
    if (!mounted) return;
    setState(() {
      _pollIntervalMs = ms;
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
              subtitle: Text(AdaptivePoller.formatIntervalMs(_pollIntervalMs)),
              onTap: () async {
                final selected = await showDialog<int>(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: const Text('Интервал опроса'),
                    children: AdaptivePoller.intervalOptions.entries
                        .map((e) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, e.key),
                      child: Text(e.value),
                    ))
                        .toList(),
                  ),
                );
                if (!context.mounted) return;
                if (selected != null) {
                  await AdaptivePoller.writeIntervalMs(selected);
                  if (!context.mounted) return;
                  setState(() => _pollIntervalMs = selected);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Интервал изменён на '
                            '${AdaptivePoller.formatIntervalMs(selected)}. '
                            'Перезапустите приложение.',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // 🖥️ Настройки экрана
          Card(
            child: ListTile(
              leading: const Icon(Icons.display_settings, color: Colors.blue),
              title: const Text('Настройки экрана'),
              subtitle: const Text('Заставка и отображение'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ScreenSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 🗑️ Хранить события
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_delete, color: Colors.grey),
              title: const Text('Хранить события'),
              subtitle: FutureBuilder<String?>(
                future: AppDatabase.getStatsSetting('events_retention_days'),
                builder: (ctx, snap) =>
                    Text('${snap.data ?? '30'} дней'),
              ),
              onTap: () async {
                final current = await AppDatabase.getStatsSetting('events_retention_days') ?? '30';
                if (!context.mounted) return;
                final selected = await showDialog<int>(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: const Text('Хранить события'),
                    children: [30, 60, 90, 365].map((d) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, d),
                      child: Row(
                        children: [
                          if (d.toString() == current)
                            const Icon(Icons.check, color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Text('$d дней'),
                        ],
                      ),
                    )).toList(),
                  ),
                );
                if (selected != null) {
                  await AppDatabase.setStatsSetting('events_retention_days', '$selected');
                  if (mounted) setState(() {});
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // 💰 Тариф электроэнергии
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments, color: Colors.amber),
              title: const Text('Тариф электроэнергии'),
              subtitle: FutureBuilder<String?>(
                future: AppDatabase.getStatsSetting(
                    'electricity_tariff_rub_per_kwh'),
                builder: (ctx, snap) =>
                    Text('${snap.data ?? '5.5'} ₽/кВт·ч'),
              ),
              onTap: () async {
                final current = await AppDatabase.getStatsSetting(
                    'electricity_tariff_rub_per_kwh');
                final controller =
                TextEditingController(text: current ?? '5.5');

                if (!context.mounted) return;
                final result = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Тариф ₽/кВт·ч'),
                    content: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(hintText: '5.5'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Отмена'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(ctx, controller.text),
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                );
                if (result != null && result.isNotEmpty) {
                  final parsed = double.tryParse(result);
                  if (parsed != null && parsed > 0) {
                    await AppDatabase.setStatsSetting(
                        'electricity_tariff_rub_per_kwh', result);
                    if (mounted) setState(() {});
                  }
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