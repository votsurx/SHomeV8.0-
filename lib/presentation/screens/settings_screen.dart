import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';

import '../../application/services/update_service.dart';
import '../../data/local/database.dart';
import '../../data/services/adaptive_poller.dart';
import '../../data/services/config_service.dart';
import 'documents/legal_documents_screen.dart';
import 'screen_settings_screen.dart';

typedef StatsSettingReader = Future<String?> Function(String key);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.statsSettingReader,
  });

  /// Позволяет подменить чтение настроек в widget-тестах.
  /// В обычном приложении используется AppDatabase.
  final StatsSettingReader? statsSettingReader;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _pollIntervalMs = AdaptivePoller.defaultIntervalMs;

  late Future<String?> _eventsRetentionFuture;
  late Future<String?> _electricityTariffFuture;

  Future<String?> _readStatsSetting(String key) {
    final reader = widget.statsSettingReader;
    if (reader != null) {
      return reader(key);
    }

    return AppDatabase.getStatsSetting(key);
  }

  @override
  void initState() {
    super.initState();

    // Кешируем Future, чтобы build() не запускал новые запросы к SQLite.
    _eventsRetentionFuture =
        _readStatsSetting('events_retention_days');
    _electricityTariffFuture =
        _readStatsSetting('electricity_tariff_rub_per_kwh');

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final ms = await AdaptivePoller.readIntervalMs();
    if (!mounted) return;

    setState(() {
      _pollIntervalMs = ms;
    });
  }

  Future<void> _refreshEventsRetention() async {
    setState(() {
      _eventsRetentionFuture =
          _readStatsSetting('events_retention_days');
    });
  }

  Future<void> _refreshElectricityTariff() async {
    setState(() {
      _electricityTariffFuture =
          _readStatsSetting('electricity_tariff_rub_per_kwh');
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
        const SnackBar(
          content: Text('✅ Конфиг готов к отправке'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $error')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ИМПОРТ
  // ═══════════════════════════════════════════════════════════════

  Future<void> _importConfig() async {
    try {
      await ConfigService.importConfig();

      if (!mounted) return;

      final restart = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('✅ Импорт выполнен'),
          content: const Text(
            'Данные восстановлены.\n\n'
                'Рекомендуется перезапустить приложение, '
                'чтобы все настройки (VK, облако, устройства) применились.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Позже'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Перезапустить'),
            ),
          ],
        ),
      );

      if (restart == true) {
        await Restart.restartApp();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: $error')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ДИАЛОГ РЕЗЕРВНОГО КОПИРОВАНИЯ
  // ═══════════════════════════════════════════════════════════════

  void _showBackupDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Резервное копирование'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              _exportConfig();
            },
            child: const ListTile(
              leading: Icon(Icons.upload, color: Colors.blue),
              title: Text('Экспортировать'),
              subtitle: Text(
                'Поделиться через облако, почту, Telegram',
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              _importConfig();
            },
            child: const ListTile(
              leading: Icon(Icons.download, color: Colors.green),
              title: Text('Импортировать'),
              subtitle: Text(
                'Выбрать файл на устройстве или в облаке',
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ИНТЕРВАЛ ОПРОСА
  // ═══════════════════════════════════════════════════════════════

  Future<void> _selectPollInterval() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Интервал опроса'),
        children: AdaptivePoller.intervalOptions.entries
            .map(
              (entry) => SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext, entry.key);
            },
            child: Text(entry.value),
          ),
        )
            .toList(),
      ),
    );

    if (!mounted || selected == null) return;

    await AdaptivePoller.writeIntervalMs(selected);
    if (!mounted) return;

    setState(() {
      _pollIntervalMs = selected;
    });

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

  // ═══════════════════════════════════════════════════════════════
  // ХРАНЕНИЕ СОБЫТИЙ
  // ═══════════════════════════════════════════════════════════════

  Future<void> _selectEventsRetention() async {
    final current =
        await AppDatabase.getStatsSetting('events_retention_days') ?? '30';

    if (!mounted) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Хранить события'),
        children: [30, 60, 90, 365]
            .map(
              (days) => SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext, days);
            },
            child: Row(
              children: [
                if (days.toString() == current)
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text('$days дней'),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );

    if (selected == null) return;

    await AppDatabase.setStatsSetting(
      'events_retention_days',
      '$selected',
    );

    if (!mounted) return;
    await _refreshEventsRetention();
  }

  // ═══════════════════════════════════════════════════════════════
  // ТАРИФ ЭЛЕКТРОЭНЕРГИИ
  // ═══════════════════════════════════════════════════════════════

  Future<void> _editElectricityTariff() async {
    final current = await AppDatabase.getStatsSetting(
      'electricity_tariff_rub_per_kwh',
    );

    if (!mounted) return;

    final controller = TextEditingController(text: current ?? '5.5');

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Тариф ₽/кВт·ч'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(hintText: '5.5'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null || result.isEmpty) return;

    final parsed = double.tryParse(result.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return;

    await AppDatabase.setStatsSetting(
      'electricity_tariff_rub_per_kwh',
      result,
    );

    if (!mounted) return;
    await _refreshElectricityTariff();
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Интервал опроса
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.timer,
                color: Colors.orange,
              ),
              title: const Text('Интервал опроса'),
              subtitle: Text(
                AdaptivePoller.formatIntervalMs(_pollIntervalMs),
              ),
              onTap: _selectPollInterval,
            ),
          ),
          const SizedBox(height: 12),

          // Настройки экрана
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.display_settings,
                color: Colors.blue,
              ),
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

          // Хранение событий
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.auto_delete,
                color: Colors.grey,
              ),
              title: const Text('Хранить события'),
              subtitle: FutureBuilder<String?>(
                future: _eventsRetentionFuture,
                builder: (context, snapshot) {
                  return Text('${snapshot.data ?? '30'} дней');
                },
              ),
              onTap: _selectEventsRetention,
            ),
          ),
          const SizedBox(height: 12),

          // Тариф электроэнергии
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.payments,
                color: Colors.amber,
              ),
              title: const Text('Тариф электроэнергии'),
              subtitle: FutureBuilder<String?>(
                future: _electricityTariffFuture,
                builder: (context, snapshot) {
                  return Text('${snapshot.data ?? '5.5'} ₽/кВт·ч');
                },
              ),
              onTap: _editElectricityTariff,
            ),
          ),
          const SizedBox(height: 12),

          // Резервное копирование
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.backup,
                color: Colors.blue,
              ),
              title: const Text('Резервное копирование'),
              subtitle: const Text('Экспорт / Импорт'),
              onTap: _showBackupDialog,
            ),
          ),
          const SizedBox(height: 12),

          // Настройки MQTT
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.settings_ethernet,
                color: Colors.teal,
              ),
              title: const Text('Настройки MQTT'),
              subtitle: const Text('Брокер для Zigbee2MQTT'),
              onTap: () => context.push('/mqtt_broker_settings'),
            ),
          ),
          const SizedBox(height: 12),

          // Проверка обновлений
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.update,
                color: Colors.green,
              ),
              title: const Text('Проверить обновления'),
              subtitle: const Text('Проверить наличие новой версии'),
              onTap: () => UpdateService.checkForUpdates(context),
            ),
          ),
          const SizedBox(height: 12),

          // Информация
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Информация'),
              subtitle: const Text('Лицензии и соглашения'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
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