/// Главный экран меню с адаптивной сеткой плиток.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/state/theme_provider.dart';
import '../../l10n/generated/app_localizations.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeNotifier = ref.watch(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final themeLabel = switch (themeMode) {
      ThemeMode.system => l10n.menuThemeSystem,
      ThemeMode.light => l10n.menuThemeLight,
      ThemeMode.dark => l10n.menuThemeDark,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuTitle),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount =
          width > 600 ? 4 : (width > 400 ? 3 : 2);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _buildTile(
                  icon: Icons.devices,
                  label: l10n.menuDevices,
                  color: Colors.blue,
                  onTap: () => context.go('/'),
                ),
                _buildTile(
                  icon: Icons.bolt,
                  label: l10n.menuEnergy,
                  color: Colors.amber,
                  onTap: () => context.push('/energy'),
                ),
                _buildTile(
                  icon: Icons.movie,
                  label: l10n.menuScenes,
                  color: Colors.purple,
                  onTap: () => context.push('/scenes'),
                ),
                _buildTile(
                  icon: Icons.search,
                  label: l10n.menuScanTuya,
                  color: Colors.teal,
                  onTap: () => context.push('/scan'),
                ),
                _buildTile(
                  icon: Icons.hub,
                  label: l10n.menuZigbee,
                  color: Colors.purple,
                  onTap: () => context.push('/zigbee_scan'),
                ),
                _buildTile(
                  icon: Icons.videocam,
                  label: l10n.menuFrigate,
                  color: Colors.red,
                  onTap: () => context.push('/frigate'),
                ),
                _buildTile(
                  icon: themeNotifier.themeIcon,
                  label: themeLabel,
                  color: isDark ? Colors.indigo : Colors.orange,
                  onTap: () => themeNotifier.toggle(),
                ),
                _buildTile(
                  icon: Icons.meeting_room,
                  label: l10n.menuRooms,
                  color: Colors.brown,
                  onTap: () => context.push('/rooms'),
                ),
                _buildTile(
                  icon: Icons.bar_chart,
                  label: l10n.menuStatistics,
                  color: Colors.green,
                  onTap: () => context.push('/statistics'),
                ),
                _buildTile(
                  icon: Icons.timer,
                  label: l10n.menuTimers,
                  color: Colors.deepOrange,
                  onTap: () => context.push('/timers'),
                ),
                _buildTile(
                  icon: Icons.notifications,
                  label: l10n.menuEvents,
                  color: Colors.red,
                  onTap: () => context.push('/events'),
                ),
                _buildTile(
                  icon: Icons.cloud,
                  label: l10n.menuCloud,
                  color: Colors.lightBlue,
                  onTap: () => context.push('/cloud'),
                ),
                _buildTile(
                  icon: Icons.notifications_active,
                  label: l10n.menuNotifications,
                  color: Colors.orange,
                  onTap: () => context.push('/notifications'),
                ),
                _buildTile(
                  icon: Icons.location_on,
                  label: l10n.menuPresence,
                  color: Colors.cyan,
                  onTap: () => context.push('/presence'),
                ),
                _buildTile(
                  icon: Icons.settings,
                  label: l10n.menuSettings,
                  color: Colors.grey,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
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