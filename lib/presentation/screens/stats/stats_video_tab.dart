import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';

class StatsVideoTab extends ConsumerStatefulWidget {
  const StatsVideoTab({super.key});

  @override
  ConsumerState<StatsVideoTab> createState() => _StatsVideoTabState();
}

class _StatsVideoTabState extends ConsumerState<StatsVideoTab> {
  int _days = 7;
  bool _loading = true;
  Map<String, int> _byLabel = const {};
  Map<String, int> _byCamera = const {};
  List<Map<String, Object?>> _hourly = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final now = DateTime.now();
    final from = now.subtract(Duration(days: _days - 1));
    final fromDate = _formatDate(from);
    final toDate = _formatDate(now);

    final byLabel = await AppDatabase.getFrigateDetectionsByLabel(
      fromDate: fromDate,
      toDate: toDate,
    );
    final byCamera = await AppDatabase.getFrigateDetectionsByCamera(
      fromDate: fromDate,
      toDate: toDate,
    );
    final hourly = await AppDatabase.getFrigateHourlyHeatmap(
      fromDate: fromDate,
      toDate: toDate,
    );

    if (!mounted) return;

    setState(() {
      _byLabel = byLabel;
      _byCamera = byCamera;
      _hourly = hourly;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _localizedLabel(String label, AppLocalizations l10n) {
    switch (label.toLowerCase()) {
      case 'person':
        return l10n.statsVideoLabelPerson;
      case 'car':
        return l10n.statsVideoLabelCar;
      case 'dog':
        return l10n.statsVideoLabelDog;
      case 'cat':
        return l10n.statsVideoLabelCat;
      case 'bird':
        return l10n.statsVideoLabelBird;
      case 'motorcycle':
        return l10n.statsVideoLabelMotorcycle;
      case 'bicycle':
        return l10n.statsVideoLabelBicycle;
      case 'truck':
        return l10n.statsVideoLabelTruck;
      case 'bus':
        return l10n.statsVideoLabelBus;
      case 'boat':
        return l10n.statsVideoLabelBoat;
      default:
      // Неизвестная метка Frigate — исходное значение.
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 1,
                label: Text(l10n.statsPeriod24h),
              ),
              ButtonSegment(
                value: 7,
                label: Text(l10n.statsPeriod7d),
              ),
              ButtonSegment(
                value: 30,
                label: Text(l10n.statsPeriod30d),
              ),
            ],
            selected: {_days},
            onSelectionChanged: (selection) {
              setState(() => _days = selection.first);
              _load();
            },
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_byLabel.isEmpty && _byCamera.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.statsVideoEmpty),
              ),
            )
          else ...[
              if (_byLabel.isNotEmpty) ...[
                Text(
                  l10n.statsVideoByTypes,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 200,
                      child: _DetectionDonut(
                        data: _byLabel,
                        l10n: l10n,
                        labelBuilder: _localizedLabel,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_byCamera.isNotEmpty) ...[
                Text(
                  l10n.statsVideoByCameras,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 200,
                      child: _CameraBarChart(data: _byCamera),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_hourly.isNotEmpty) ...[
                Text(
                  l10n.statsVideoActivityByHour,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _HourHeatmap(
                      data: _hourly,
                      l10n: l10n,
                    ),
                  ),
                ),
              ],
            ],
        ],
      ),
    );
  }
}

class _DetectionDonut extends StatelessWidget {
  const _DetectionDonut({
    required this.data,
    required this.l10n,
    required this.labelBuilder,
  });

  final Map<String, int> data;
  final AppLocalizations l10n;
  final String Function(String label, AppLocalizations l10n) labelBuilder;

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (sum, count) => sum + count);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entries.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final percent =
                total == 0 ? 0.0 : item.value * 100 / total;

                return PieChartSectionData(
                  value: item.value.toDouble(),
                  title: '${percent.toStringAsFixed(0)}%',
                  color: _colors[index % _colors.length],
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: entries.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      color: _colors[index % _colors.length],
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${labelBuilder(item.key, l10n)}: ${item.value}',
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _CameraBarChart extends StatelessWidget {
  const _CameraBarChart({required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxY =
    entries.isEmpty ? 1.0 : entries.first.value.toDouble() * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: entries.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }

                // Название камеры — пользовательская конфигурация Frigate.
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    entries[index].key,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _HourHeatmap extends StatelessWidget {
  const _HourHeatmap({
    required this.data,
    required this.l10n,
  });

  final List<Map<String, Object?>> data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final byDate = <String, Map<int, int>>{};

    for (final row in data) {
      final date = row['date'] as String;
      final hour = (row['hour'] as num).toInt();
      final count = (row['count'] as num).toInt();

      byDate.putIfAbsent(date, () => {});
      byDate[date]![hour] = count;
    }

    final dates = byDate.keys.toList()..sort();
    final maxCount = data.fold<int>(
      1,
          (maximum, row) {
        final count = (row['count'] as num).toInt();
        return count > maximum ? count : maximum;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 60),
            ...List.generate(
              24,
                  (hour) => Expanded(
                child: Text(
                  hour.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...dates.map((date) {
          final hours = byDate[date]!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    date.substring(5),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                ...List.generate(24, (hour) {
                  final count = hours[hour] ?? 0;
                  final intensity = count == 0
                      ? 0.0
                      : (count / maxCount).clamp(0.0, 1.0);

                  return Expanded(
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: count == 0
                            ? Colors.grey.withValues(alpha: 0.1)
                            : Colors.blue.withValues(
                          alpha: 0.2 + intensity * 0.8,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: count == 0
                          ? null
                          : Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          l10n.statsVideoHeatmapHint,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}