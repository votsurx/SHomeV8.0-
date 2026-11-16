import 'package:flutter/material.dart';
import 'stats_overview_tab.dart';
import 'stats_devices_tab.dart';
import 'stats_energy_tab.dart';
import 'stats_video_tab.dart';
import 'stats_scenes_tab.dart';
import 'stats_presence_tab.dart';
import 'stats_climate_tab.dart';
import 'stats_notifications_tab.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    _StatTab(label: 'Обзор', icon: Icons.dashboard),
    _StatTab(label: 'Устройства', icon: Icons.devices),
    _StatTab(label: 'Энергия', icon: Icons.bolt),
    _StatTab(label: 'Видео', icon: Icons.videocam),
    _StatTab(label: 'Сцены', icon: Icons.movie),
    _StatTab(label: 'Присутствие', icon: Icons.location_on),
    _StatTab(label: 'Климат', icon: Icons.thermostat),
    _StatTab(label: 'Уведомления', icon: Icons.notifications),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return const StatsOverviewTab();
      case 1: return const StatsDevicesTab();
      case 2: return const StatsEnergyTab();
      case 3: return const StatsVideoTab();
      case 4: return const StatsScenesTab();
      case 5: return const StatsPresenceTab();
      case 6: return const StatsClimateTab();
      case 7: return const StatsNotificationsTab();
      default: return const StatsOverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _tabs.length,
              itemBuilder: (ctx, i) => _StatTile(
                tab: _tabs[i],
                selected: _selectedIndex == i,
                onTap: () => setState(() => _selectedIndex = i),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

class _StatTab {
  final String label;
  final IconData icon;
  const _StatTab({required this.label, required this.icon});
}

class _StatTile extends StatelessWidget {
  final _StatTab tab;
  final bool selected;
  final VoidCallback onTap;
  const _StatTile({required this.tab, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab.icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}