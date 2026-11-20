import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';

import '../../application/services/update_service.dart';
import '../../application/state/order_storage.dart';
import '../../data/local/database.dart';
import '../../data/services/adaptive_poller.dart';
import '../../data/services/config_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../presentation/widgets/language_selector_tile.dart';
import 'documents/legal_documents_screen.dart';
import 'screen_settings_screen.dart';

typedef StatsSettingReader = Future<String?> Function(String key);

// ═══════════════════════════════════════════════════════════════
// ОПИСАНИЕ СТРОК НАСТРОЕК
// ═══════════════════════════════════════════════════════════════

/// Базовый тип строки настроек.
/// Каждая строка имеет стабильный [id] (для сортировки),
/// [icon], [title], [subtitle] и [onTap].
/// Подклассы: _CardListTileSpec, _LanguageTileSpec.
sealed class _SettingsRowSpec {
  final String id;
  const _SettingsRowSpec({required this.id});
}

/// Обычная строка в Card с ListTile.
class _CardListTileSpec extends _SettingsRowSpec {
  final IconData icon;
  final Color? iconColor;
  final String Function(AppLocalizations) title;
  final Widget Function(
      BuildContext context,
      AppLocalizations l10n,
      _SettingsScreenState state,
      ) subtitle;
  final void Function(
      BuildContext context,
      AppLocalizations l10n,
      _SettingsScreenState state,
      ) onTap;

  const _CardListTileSpec({
    required super.id,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

/// Строка LanguageSelectorTile (готовый виджет, а не ListTile).
class _LanguageTileSpec extends _SettingsRowSpec {
  const _LanguageTileSpec({required super.id});
}

// ── Функции-обёртки для title ──
String _tPollInterval(AppLocalizations l) => l.settingsPollInterval;
String _tScreenSettings(AppLocalizations l) => l.screenSettings;
String _tEventsRetention(AppLocalizations l) => l.settingsEventsRetention;
String _tElectricityTariff(AppLocalizations l) => l.settingsElectricityTariff;
String _tBackup(AppLocalizations l) => l.settingsBackup;
String _tMqtt(AppLocalizations l) => l.settingsMqtt;
String _tCheckUpdates(AppLocalizations l) => l.settingsCheckUpdates;
String _tInformation(AppLocalizations l) => l.settingsInformation;

// ── Subtitle-билдеры ──
Widget _subPollInterval(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    Text(s._formatInterval(s._pollIntervalMs, l10n));

Widget _subScreenSettings(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    Text(l10n.screenSettingsSubtitle);

Widget _subEventsRetention(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    FutureBuilder<String?>(
      future: s._eventsRetentionFuture,
      builder: (context, snapshot) {
        final days = int.tryParse(snapshot.data ?? '') ?? 30;
        return Text(l10n.settingsDays(days));
      },
    );

Widget _subElectricityTariff(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    FutureBuilder<String?>(
      future: s._electricityTariffFuture,
      builder: (context, snapshot) {
        final tariff = snapshot.data ?? '5.5';
        return Text(l10n.settingsCurrencyPerKwh(tariff));
      },
    );

Widget _subBackup(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    Text(l10n.settingsBackupSubtitle);

Widget _subMqtt(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    Text(l10n.settingsMqttSubtitle);

Widget _subCheckUpdates(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    Text(l10n.settingsCheckUpdatesSubtitle);

Widget _subInformation(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    Text(l10n.settingsInformationSubtitle);

// ── onTap-обёртки ──
void _tapPollInterval(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    s._selectPollInterval();

void _tapScreenSettings(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) {
  Navigator.of(c).push(
    MaterialPageRoute<void>(
      builder: (_) => const ScreenSettingsScreen(),
    ),
  );
}

void _tapEventsRetention(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    s._selectEventsRetention();

void _tapElectricityTariff(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    s._editElectricityTariff();

void _tapBackup(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    s._showBackupDialog();

void _tapMqtt(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    c.push('/mqtt_broker_settings');

void _tapCheckUpdates(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) =>
    UpdateService.checkForUpdates(c);

void _tapInformation(
    BuildContext c,
    AppLocalizations l10n,
    _SettingsScreenState s,
    ) {
  Navigator.of(c).push(
    MaterialPageRoute<void>(
      builder: (_) => const LegalDocumentsScreen(),
    ),
  );
}

// ── Список строк — порядок по умолчанию ──
const _settingsRowSpecs = <_SettingsRowSpec>[
  _CardListTileSpec(
    id: 'poll_interval',
    icon: Icons.timer,
    iconColor: Colors.orange,
    title: _tPollInterval,
    subtitle: _subPollInterval,
    onTap: _tapPollInterval,
  ),
  _LanguageTileSpec(id: 'language'),
  _CardListTileSpec(
    id: 'screen_settings',
    icon: Icons.display_settings,
    iconColor: Colors.blue,
    title: _tScreenSettings,
    subtitle: _subScreenSettings,
    onTap: _tapScreenSettings,
  ),
  _CardListTileSpec(
    id: 'events_retention',
    icon: Icons.auto_delete,
    iconColor: Colors.grey,
    title: _tEventsRetention,
    subtitle: _subEventsRetention,
    onTap: _tapEventsRetention,
  ),
  _CardListTileSpec(
    id: 'electricity_tariff',
    icon: Icons.payments,
    iconColor: Colors.amber,
    title: _tElectricityTariff,
    subtitle: _subElectricityTariff,
    onTap: _tapElectricityTariff,
  ),
  _CardListTileSpec(
    id: 'backup',
    icon: Icons.backup,
    iconColor: Colors.blue,
    title: _tBackup,
    subtitle: _subBackup,
    onTap: _tapBackup,
  ),
  _CardListTileSpec(
    id: 'mqtt',
    icon: Icons.settings_ethernet,
    iconColor: Colors.teal,
    title: _tMqtt,
    subtitle: _subMqtt,
    onTap: _tapMqtt,
  ),
  _CardListTileSpec(
    id: 'check_updates',
    icon: Icons.update,
    iconColor: Colors.green,
    title: _tCheckUpdates,
    subtitle: _subCheckUpdates,
    onTap: _tapCheckUpdates,
  ),
  _CardListTileSpec(
    id: 'information',
    icon: Icons.gavel,
    title: _tInformation,
    subtitle: _subInformation,
    onTap: _tapInformation,
  ),
];

// ═══════════════════════════════════════════════════════════════
// ХРАНЕНИЕ ПОРЯДКА
// ═══════════════════════════════════════════════════════════════

const _settingsStorageKey = 'settings_order';

final _settingsDefaultOrder = <String>[
  'poll_interval',
  'language',
  'screen_settings',
  'events_retention',
  'electricity_tariff',
  'backup',
  'mqtt',
  'check_updates',
  'information',
];

// ═══════════════════════════════════════════════════════════════
// ЭКРАН
// ═══════════════════════════════════════════════════════════════

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

  List<String> _order = List<String>.from(_settingsDefaultOrder);

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
    _loadOrder();
  }

  Future<void> _loadSettings() async {
    final interval = await AdaptivePoller.readIntervalMs();
    if (!mounted) return;

    setState(() => _pollIntervalMs = interval);
  }

  Future<void> _loadOrder() async {
    final loaded =
    await OrderStorage.load(_settingsStorageKey, _settingsDefaultOrder);
    if (!mounted) return;
    setState(() => _order = loaded);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final updated = OrderStorage.reorder(_order, oldIndex, newIndex);
    setState(() => _order = updated);
    OrderStorage.save(_settingsStorageKey, updated);
  }

  Future<void> _resetOrder(AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsResetOrderTitle),
        content: Text(l10n.settingsResetOrderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsResetOrderConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await OrderStorage.clear(_settingsStorageKey);
    if (!mounted) return;
    setState(() => _order = List<String>.from(_settingsDefaultOrder));
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

    final byId = {for (final s in _settingsRowSpecs) s.id: s};
    final rows = _order
        .map((id) => byId[id])
        .whereType<_SettingsRowSpec>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: l10n.settingsResetOrderTitle,
            onPressed: () => _resetOrder(l10n),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        buildDefaultDragHandles: false, // long-press вместо ручки
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final spec = rows[index];

          final Widget child;
          switch (spec) {
            case _LanguageTileSpec():
              child = const LanguageSelectorTile();
            case _CardListTileSpec():
              child = Card(
                child: ListTile(
                  leading: Icon(
                    spec.icon,
                    color: spec.iconColor,
                  ),
                  title: Text(spec.title(l10n)),
                  subtitle: spec.subtitle(context, l10n, this),
                  onTap: () => spec.onTap(context, l10n, this),
                ),
              );
          }

          return ReorderableDelayedDragStartListener(
            key: ValueKey(spec.id),
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          );
        },
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