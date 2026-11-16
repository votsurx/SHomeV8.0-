import 'package:flutter/material.dart';
import 'stats_overview_tab.dart';
import 'stats_devices_tab.dart';
import 'stats_energy_tab.dart';
import 'stats_video_tab.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Обзор'),
            Tab(icon: Icon(Icons.devices), text: 'Устройства'),
            Tab(icon: Icon(Icons.bolt), text: 'Энергия'),
            Tab(icon: Icon(Icons.videocam), text: 'Видео'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          StatsOverviewTab(),
          StatsDevicesTab(),
          StatsEnergyTab(),
          StatsVideoTab(),
        ],
      ),
    );
  }
}