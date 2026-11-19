import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';

import '../../application/services/update_service.dart';
import '../../data/local/database.dart';
import '../../data/services/adaptive_poller.dart';
import '../../data/services/config_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../presentation/widgets/language_selector_tile.dart';
import 'documents/legal_documents_screen.dart';
import 'screen_settings_screen.dart';

typedef StatsSettingReader = Future<String?> Function(String key);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.statsSettingReader,
  });

  /// Позволяет подменить чтение настроек в widget-тестах.
  /// В приложении по умолчанию читается AppDatabase.
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

    _eventsRetentionFuture =
        _readStatsSetting('events_retention_days');
    _electricityTariffFuture =
        _readStatsSetting('electricity_tariff_rub_per_kwh');

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final interval = await AdaptivePoller.readIntervalMs();
    if (!mounted) return;

    setState(() => _pollIntervalMs = interval);
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

  String _formatInterval(int milliseconds, AppLocalizations l10n) {
    if (milliseconds >= 60000 && milliseconds % 60000 == 0) {
      return l10n.settingsIntervalMinutes(milliseconds ~/ 60000);
    }

    return l10n.settingsIntervalSeconds(
      (milliseconds / 1000).round(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ЭКСПОРТ / ИМПОРТ
  // ═══════════════════════════════════════════════════════════════

  Future<void> _exportConfig() async {
    final l10n = AppLocalizations.of(context);

    try {
      await ConfigService.exportConfig();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsExportReady)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsError(error.toString()))),
      );
    }
  }

  Future<void> _importConfig() async {
    final l10n = AppLocalizations.of(context);

    try {
      await ConfigService.importConfig();
      if (!mounted) return;

      final restart = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.settingsImportDone),
          content: Text(l10n.settingsImportRestartHint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.settingsLater),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.settingsRestart),
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
        SnackBar(content: Text(l10n.settingsError(error.toString()))),
      );
    }
  }

  void _showBackupDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsBackupDialogTitle),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              _exportConfig();
            },
            child: ListTile(
              leading: const Icon(Icons.upload, color: Colors.blue),
              title: Text(l10n.settingsExport),
              subtitle: Text(l10n.settingsExportSubtitle),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);
              _importConfig();
            },
            child: ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: Text(l10n.settingsImport),
              subtitle: Text(l10n.settingsImportSubtitle),
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
    final l10n = AppLocalizations.of(context);

    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsPollInterval),
        children: AdaptivePoller.intervalOptions.keys.map((milliseconds) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, milliseconds),
            child: Text(_formatInterval(milliseconds, l10n)),
          );
        }).toList(),
      ),
    );

    if (!mounted || selected == null) return;

    await AdaptivePoller.writeIntervalMs(selected);
    if (!mounted) return;

    setState(() => _pollIntervalMs = selected);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.settingsPollIntervalChanged(
            _formatInterval(selected, l10n),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ХРАНЕНИЕ СОБЫТИЙ
  // ═══════════════════════════════════════════════════════════════

  Future<void> _selectEventsRetention() async {
    final l10n = AppLocalizations.of(context);

    final current =
        await AppDatabase.getStatsSetting('events_retention_days') ?? '30';

    if (!mounted) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(l10n.settingsRetentionDialogTitle),
        children: [30, 60, 90, 365].map((days) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, days),
            child: Row(
              children: [
                if (days.toString() == current)
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                Text(l10n.settingsRetentionDays(days)),
              ],
            ),
          );
        }).toList(),
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
    final l10n = AppLocalizations.of(context);

    final current = await AppDatabase.getStatsSetting(
      'electricity_tariff_rub_per_kwh',
    );

    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ElectricityTariffDialog(
        initialValue: current ?? '5.5',
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) return;

    final normalized = result.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);

    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsTariffInvalid)),
      );
      return;
    }

    await AppDatabase.setStatsSetting(
      'electricity_tariff_rub_per_kwh',
      normalized,
    );

    if (!mounted) return;
    await _refreshElectricityTariff();
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.timer,
                color: Colors.orange,
              ),
              title: Text(l10n.settingsPollInterval),
              subtitle: Text(_formatInterval(_pollIntervalMs, l10n)),
              onTap: _selectPollInterval,
            ),
          ),
          const SizedBox(height: 12),

          const LanguageSelectorTile(),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.display_settings,
                color: Colors.blue,
              ),
              title: Text(l10n.screenSettings),
              subtitle: Text(l10n.screenSettingsSubtitle),
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

          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_delete, color: Colors.grey),
              title: Text(l10n.settingsEventsRetention),
              subtitle: FutureBuilder<String?>(
                future: _eventsRetentionFuture,
                builder: (context, snapshot) {
                  final days = int.tryParse(snapshot.data ?? '') ?? 30;
                  return Text(l10n.settingsDays(days));
                },
              ),
              onTap: _selectEventsRetention,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.payments, color: Colors.amber),
              title: Text(l10n.settingsElectricityTariff),
              subtitle: FutureBuilder<String?>(
                future: _electricityTariffFuture,
                builder: (context, snapshot) {
                  final tariff = snapshot.data ?? '5.5';
                  return Text(l10n.settingsCurrencyPerKwh(tariff));
                },
              ),
              onTap: _editElectricityTariff,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: Text(l10n.settingsBackup),
              subtitle: Text(l10n.settingsBackupSubtitle),
              onTap: _showBackupDialog,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.settings_ethernet,
                color: Colors.teal,
              ),
              title: Text(l10n.settingsMqtt),
              subtitle: Text(l10n.settingsMqttSubtitle),
              onTap: () => context.push('/mqtt_broker_settings'),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.update, color: Colors.green),
              title: Text(l10n.settingsCheckUpdates),
              subtitle: Text(l10n.settingsCheckUpdatesSubtitle),
              onTap: () => UpdateService.checkForUpdates(context),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel),
              title: Text(l10n.settingsInformation),
              subtitle: Text(l10n.settingsInformationSubtitle),
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

class _ElectricityTariffDialog extends StatefulWidget {
  const _ElectricityTariffDialog({
    required this.initialValue,
  });

  final String initialValue;

  @override
  State<_ElectricityTariffDialog> createState() =>
      _ElectricityTariffDialogState();
}

class _ElectricityTariffDialogState
    extends State<_ElectricityTariffDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.settingsTariffDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: l10n.settingsTariffHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_controller.text);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}