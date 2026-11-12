/// Экран статистики с тремя вкладками.
/// Устройства — график вкл/выкл за всё время.
/// Датчики — заглушка (будет показывать графики температуры/влажности).
/// Энергия — потребление kWh по устройствам за 7 дней из energy_log.
library;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/local/database.dart';
//import 'dart:math';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  /// Собирает статистику вкл/выкл из журнала событий.
  Future<List<Map<String, dynamic>>> _getDeviceStats() async {
    final events = await AppDatabase.getRecentEvents(limit: 1000);
    final stats = <String, Map<String, dynamic>>{};

    for (final event in events) {
      if (event.event == 'turnOn' || event.event == 'turnOff') {
        final name = event.deviceName ?? 'Неизвестно';
        stats.putIfAbsent(name, () => {'name': name, 'count': 0});
        stats[name]!['count'] = (stats[name]!['count'] as int) + 1;
      }
    }

    return stats.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Устройства', icon: Icon(Icons.devices)),
            Tab(text: 'Датчики', icon: Icon(Icons.thermostat)),
            Tab(text: 'Энергия', icon: Icon(Icons.bolt)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDevicesTab(),
          _buildSensorsTab(),
          _buildEnergyTab(),
        ],
      ),
    );
  }

  /// Вкладка "Устройства" — столбчатая диаграмма вкл/выкл.
  Widget _buildDevicesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getDeviceStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return const Center(child: Text('Нет данных'));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: (e.value['count'] as int).toDouble())],
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...data.map((d) => ListTile(
                title: Text(d['name'] as String),
                subtitle: Text('Вкл/Выкл: ${d['count']} раз(а)'),
              )),
            ],
          ),
        );
      },
    );
  }

  /// Вкладка "Датчики" — графики.
  Widget _buildSensorsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AppDatabase.getSensorData(days: 7),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        if (data.isEmpty) return const Center(child: Text('Нет данных датчиков'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Температура за 7 дней', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 10,
                    maxY: 35,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data
                            .where((d) => d['temperature'] != null)
                            .map((d) => FlSpot(
                          DateTime.parse(d['timestamp'] as String).millisecondsSinceEpoch.toDouble(),
                          (d['temperature'] as num).toDouble(),
                        ))
                            .toList(),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 86400000, // 1 день в мс
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            return Text('${date.day}.${date.month}', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Влажность за 7 дней', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minY: 30,
                    maxY: 90,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data
                            .where((d) => d['humidity'] != null)
                            .map((d) => FlSpot(
                          DateTime.parse(d['timestamp'] as String).millisecondsSinceEpoch.toDouble(),
                          (d['humidity'] as num).toDouble(),
                        ))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 86400000,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            return Text('${date.day}.${date.month}', style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Вкладка "Энергия" — потребление kWh за 7 дней.
  Widget _buildEnergyTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AppDatabase.getEnergyStats(days: 7),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty) return const Center(child: Text('Нет данных энергопотребления'));

        final deviceTotals = <String, double>{};
        for (final row in data) {
          final name = row['deviceName'] as String;
          deviceTotals[name] = (deviceTotals[name] ?? 0) + (row['totalEnergy'] as num).toDouble();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('За 7 дней:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...deviceTotals.entries.map((e) => Card(
              child: ListTile(
                title: Text(e.key),
                trailing: Text('${e.value.toStringAsFixed(3)} kWh', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )),
          ],
        );
      },
    );
  }
}