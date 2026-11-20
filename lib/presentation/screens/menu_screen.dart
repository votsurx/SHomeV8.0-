/// Главный экран меню с адаптивной сеткой плиток.
/// Плитки можно перетаскивать long-press'ом (как устройства на главном экране).
/// Порядок сохраняется в SharedPreferences ('menu_order').
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../../application/state/order_storage.dart';
import '../../application/state/theme_provider.dart';
import '../../l10n/generated/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════
// ОПИСАНИЕ ПЛИТОК
// ═══════════════════════════════════════════════════════════════

class _MenuTileSpec {
  final String id;
  final IconData Function(ThemeNotifier themeNotifier) icon;
  final String Function(AppLocalizations l10n) label;
  final Color Function(bool isDark) color;
  final void Function(BuildContext context, ThemeNotifier themeNotifier) onTap;

  const _MenuTileSpec({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

// Функции-обёртки для label (чтобы const-список не тащил AppLocalizations).
String _lDevices(AppLocalizations l) => l.menuDevices;
String _lEnergy(AppLocalizations l) => l.menuEnergy;
String _lScenes(AppLocalizations l) => l.menuScenes;
String _lScanTuya(AppLocalizations l) => l.menuScanTuya;
String _lZigbee(AppLocalizations l) => l.menuZigbee;
String _lFrigate(AppLocalizations l) => l.menuFrigate;
String _lRooms(AppLocalizations l) => l.menuRooms;
String _lStatistics(AppLocalizations l) => l.menuStatistics;
String _lTimers(AppLocalizations l) => l.menuTimers;
String _lEvents(AppLocalizations l) => l.menuEvents;
String _lCloud(AppLocalizations l) => l.menuCloud;
String _lNotifications(AppLocalizations l) => l.menuNotifications;
String _lPresence(AppLocalizations l) => l.menuPresence;
String _lSettings(AppLocalizations l) => l.menuSettings;

// ⚠️ Плитка темы — особый случай: label зависит от текущей темы.
// Поэтому у неё label-функция получает и l10n, и themeNotifier.
typedef _ThemeLabelFn = String Function(AppLocalizations l10n, ThemeMode mode);

// Список плиток — порядок по умолчанию.
// id должны совпадать с _defaultOrder ниже!
const _menuTileSpecs = <_MenuTileSpec>[
  _MenuTileSpec(
    id: 'devices',
    icon: _iconDevices,
    label: _lDevices,
    color: _colorDevices,
    onTap: _tapDevices,
  ),
  _MenuTileSpec(
    id: 'energy',
    icon: _iconEnergy,
    label: _lEnergy,
    color: _colorEnergy,
    onTap: _tapEnergy,
  ),
  _MenuTileSpec(
    id: 'scenes',
    icon: _iconScenes,
    label: _lScenes,
    color: _colorScenes,
    onTap: _tapScenes,
  ),
  _MenuTileSpec(
    id: 'scan_tuya',
    icon: _iconScanTuya,
    label: _lScanTuya,
    color: _colorScanTuya,
    onTap: _tapScanTuya,
  ),
  _MenuTileSpec(
    id: 'zigbee',
    icon: _iconZigbee,
    label: _lZigbee,
    color: _colorZigbee,
    onTap: _tapZigbee,
  ),
  _MenuTileSpec(
    id: 'frigate',
    icon: _iconFrigate,
    label: _lFrigate,
    color: _colorFrigate,
    onTap: _tapFrigate,
  ),
  // ── Плитка темы ──
  _MenuTileSpec(
    id: 'theme',
    icon: _iconTheme,
    label: _labelTheme, // особый случай, см. _ThemeLabelFn
    color: _colorTheme,
    onTap: _tapTheme,
  ),
  _MenuTileSpec(
    id: 'rooms',
    icon: _iconRooms,
    label: _lRooms,
    color: _colorRooms,
    onTap: _tapRooms,
  ),
  _MenuTileSpec(
    id: 'statistics',
    icon: _iconStatistics,
    label: _lStatistics,
    color: _colorStatistics,
    onTap: _tapStatistics,
  ),
  _MenuTileSpec(
    id: 'timers',
    icon: _iconTimers,
    label: _lTimers,
    color: _colorTimers,
    onTap: _tapTimers,
  ),
  _MenuTileSpec(
    id: 'events',
    icon: _iconEvents,
    label: _lEvents,
    color: _colorEvents,
    onTap: _tapEvents,
  ),
  _MenuTileSpec(
    id: 'cloud',
    icon: _iconCloud,
    label: _lCloud,
    color: _colorCloud,
    onTap: _tapCloud,
  ),
  _MenuTileSpec(
    id: 'notifications',
    icon: _iconNotifications,
    label: _lNotifications,
    color: _colorNotifications,
    onTap: _tapNotifications,
  ),
  _MenuTileSpec(
    id: 'presence',
    icon: _iconPresence,
    label: _lPresence,
    color: _colorPresence,
    onTap: _tapPresence,
  ),
  _MenuTileSpec(
    id: 'settings',
    icon: _iconSettings,
    label: _lSettings,
    color: _colorSettings,
    onTap: _tapSettings,
  ),
];

// ── Иконки ──
IconData _iconDevices(ThemeNotifier _) => Icons.devices;
IconData _iconEnergy(ThemeNotifier _) => Icons.bolt;
IconData _iconScenes(ThemeNotifier _) => Icons.movie;
IconData _iconScanTuya(ThemeNotifier _) => Icons.search;
IconData _iconZigbee(ThemeNotifier _) => Icons.hub;
IconData _iconFrigate(ThemeNotifier _) => Icons.videocam;
IconData _iconTheme(ThemeNotifier n) => n.themeIcon;
IconData _iconRooms(ThemeNotifier _) => Icons.meeting_room;
IconData _iconStatistics(ThemeNotifier _) => Icons.bar_chart;
IconData _iconTimers(ThemeNotifier _) => Icons.timer;
IconData _iconEvents(ThemeNotifier _) => Icons.notifications;
IconData _iconCloud(ThemeNotifier _) => Icons.cloud;
IconData _iconNotifications(ThemeNotifier _) => Icons.notifications_active;
IconData _iconPresence(ThemeNotifier _) => Icons.location_on;
IconData _iconSettings(ThemeNotifier _) => Icons.settings;

// ── Цвета ──
Color _colorDevices(bool _) => Colors.blue;
Color _colorEnergy(bool _) => Colors.amber;
Color _colorScenes(bool _) => Colors.purple;
Color _colorScanTuya(bool _) => Colors.teal;
Color _colorZigbee(bool _) => Colors.purple;
Color _colorFrigate(bool _) => Colors.red;
Color _colorTheme(bool isDark) => isDark ? Colors.indigo : Colors.orange;
Color _colorRooms(bool _) => Colors.brown;
Color _colorStatistics(bool _) => Colors.green;
Color _colorTimers(bool _) => Colors.deepOrange;
Color _colorEvents(bool _) => Colors.red;
Color _colorCloud(bool _) => Colors.lightBlue;
Color _colorNotifications(bool _) => Colors.orange;
Color _colorPresence(bool _) => Colors.cyan;
Color _colorSettings(bool _) => Colors.grey;

// ── Label для темы (зависит от текущего ThemeMode) ──
String _labelTheme(AppLocalizations l10n) {
  // Переопределяется в _MenuScreenState.build через themeMode,
  // но для совместимости с _MenuTileSpec.label возвращаем системный.
  return l10n.menuThemeSystem;
}

// ── Навигация ──
void _tapDevices(BuildContext c, ThemeNotifier _) => c.go('/');
void _tapEnergy(BuildContext c, ThemeNotifier _) => c.push('/energy');
void _tapScenes(BuildContext c, ThemeNotifier _) => c.push('/scenes');
void _tapScanTuya(BuildContext c, ThemeNotifier _) => c.push('/scan');
void _tapZigbee(BuildContext c, ThemeNotifier _) => c.push('/zigbee_scan');
void _tapFrigate(BuildContext c, ThemeNotifier _) => c.push('/frigate');
void _tapTheme(BuildContext c, ThemeNotifier n) => n.toggle();
void _tapRooms(BuildContext c, ThemeNotifier _) => c.push('/rooms');
void _tapStatistics(BuildContext c, ThemeNotifier _) => c.push('/statistics');
void _tapTimers(BuildContext c, ThemeNotifier _) => c.push('/timers');
void _tapEvents(BuildContext c, ThemeNotifier _) => c.push('/events');
void _tapCloud(BuildContext c, ThemeNotifier _) => c.push('/cloud');
void _tapNotifications(BuildContext c, ThemeNotifier _) => c.push('/notifications');
void _tapPresence(BuildContext c, ThemeNotifier _) => c.push('/presence');
void _tapSettings(BuildContext c, ThemeNotifier _) => c.push('/settings');

// ═══════════════════════════════════════════════════════════════
// ХРАНЕНИЕ ПОРЯДКА
// ═══════════════════════════════════════════════════════════════

const _storageKey = 'menu_order';

final _defaultOrder = <String>[
  'devices',
  'energy',
  'scenes',
  'scan_tuya',
  'zigbee',
  'frigate',
  'theme',
  'rooms',
  'statistics',
  'timers',
  'events',
  'cloud',
  'notifications',
  'presence',
  'settings',
];

// ═══════════════════════════════════════════════════════════════
// ЭКРАН
// ═══════════════════════════════════════════════════════════════

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  List<String> _order = List<String>.from(_defaultOrder);

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final loaded = await OrderStorage.load(_storageKey, _defaultOrder);
    if (!mounted) return;
    setState(() => _order = loaded);
  }

  void _onReorder(int oldIndex, int newIndex) {
    final updated = OrderStorage.reorder(_order, oldIndex, newIndex);
    setState(() => _order = updated);
    OrderStorage.save(_storageKey, updated);
  }

  Future<void> _resetOrder(AppLocalizations l10n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.menuResetOrderTitle),
        content: Text(l10n.menuResetOrderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.menuResetOrderConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await OrderStorage.clear(_storageKey);
    if (!mounted) return;
    setState(() => _order = List<String>.from(_defaultOrder));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeNotifier = ref.watch(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Label и icon для плитки темы зависят от themeMode — вычисляем здесь.
    String themeLabelFor(ThemeMode mode) => switch (mode) {
      ThemeMode.system => l10n.menuThemeSystem,
      ThemeMode.light => l10n.menuThemeLight,
      ThemeMode.dark => l10n.menuThemeDark,
    };

    final byId = {for (final s in _menuTileSpecs) s.id: s};
    final specs = _order
        .map((id) => byId[id])
        .whereType<_MenuTileSpec>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: l10n.menuResetOrderTitle,
            onPressed: () => _resetOrder(l10n),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount =
          width > 600 ? 4 : (width > 400 ? 3 : 2);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ReorderableGridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                for (final spec in specs)
                  RepaintBoundary(
                    key: ValueKey(spec.id),
                    child: _MenuTile(
                      spec: spec,
                      l10n: l10n,
                      themeNotifier: themeNotifier,
                      themeMode: themeMode,
                      isDark: isDark,
                      themeLabelFor: themeLabelFor,
                    ),
                  ),
              ],
              onReorder: _onReorder,
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ПЛИТКА
// ═══════════════════════════════════════════════════════════════

class _MenuTile extends StatelessWidget {
  final _MenuTileSpec spec;
  final AppLocalizations l10n;
  final ThemeNotifier themeNotifier;
  final ThemeMode themeMode;
  final bool isDark;
  final String Function(ThemeMode) themeLabelFor;

  const _MenuTile({
    required this.spec,
    required this.l10n,
    required this.themeNotifier,
    required this.themeMode,
    required this.isDark,
    required this.themeLabelFor,
  });

  @override
  Widget build(BuildContext context) {
    final icon = spec.icon(themeNotifier);
    final label = spec.id == 'theme'
        ? themeLabelFor(themeMode)
        : spec.label(l10n);
    final color = spec.color(isDark);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => spec.onTap(context, themeNotifier),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}