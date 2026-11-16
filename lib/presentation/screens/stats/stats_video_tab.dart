import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/local/database.dart';

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
    final fromDate = _fmt(from);
    final toDate = _fmt(now);

    final byLabel = await AppDatabase.getFrigateDetectionsByLabel(fromDate: fromDate, toDate: toDate);
    final byCamera = await AppDatabase.getFrigateDetectionsByCamera(fromDate: fromDate, toDate: toDate);
    final hourly = await AppDatabase.getFrigateHourlyHeatmap(fromDate: fromDate, toDate: toDate);

    if (!mounted) return;
    setState(() {
      _byLabel = byLabel;
      _byCamera = byCamera;
      _hourly = hourly;
      _loading = false;
    });
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('24ч')),
              ButtonSegment(value: 7, label: Text('7д')),
              ButtonSegment(value: 30, label: Text('30д')),
            ],
            selected: {_days},
            onSelectionChanged: (s) {
              setState(() => _days = s.first);
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
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет детекций за период'),
              ),
            )
          else ...[
              // ─── Детекции по типам (donut) ───
              if (_byLabel.isNotEmpty) ...[
                Text('По типам', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 200,
                      child: _DetectionDonut(data: _byLabel),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ─── По камерам (bar chart) ───
              if (_byCamera.isNotEmpty) ...[
                Text('По камерам', style: Theme.of(context).textTheme.titleMedium),
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

              // ─── Тепловая карта по часам ───
              if (_hourly.isNotEmpty) ...[
                Text('Активность по часам', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _HourHeatmap(data: _hourly),
                  ),
                ),
              ],
            ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ВИДЖЕТ: DetectionDonut (круговой график по типам)
// ═══════════════════════════════════════════════════════════

class _DetectionDonut extends StatelessWidget {
  final Map<String, int> data;
  const _DetectionDonut({required this.data});

  static const _colors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: entries.asMap().entries.map((e) {
                final idx = e.key;
                final entry = e.value;
                final percent = total == 0 ? 0.0 : entry.value * 100 / total;
                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  title: '${percent.toStringAsFixed(0)}%',
                  color: _colors[idx % _colors.length],
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: _colors[idx % _colors.length]),
                  const SizedBox(width: 6),
                  Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 11)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ВИДЖЕТ: CameraBarChart (столбцы по камерам)
// ═══════════════════════════════════════════════════════════

class _CameraBarChart extends StatelessWidget {
  final Map<String, int> data;
  const _CameraBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxY = entries.isEmpty ? 1.0 : entries.first.value.toDouble() * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(entries[idx].key, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ВИДЖЕТ: HourHeatmap (тепловая карта день × час)
// ═══════════════════════════════════════════════════════════

class _HourHeatmap extends StatelessWidget {
  final List<Map<String, Object?>> data;
  const _HourHeatmap({required this.data});

  @override
  Widget build(BuildContext context) {
    // data: [{date, hour, count}]
    // группируем по date → Map<date, Map<hour, count>>
    final byDate = <String, Map<int, int>>{};
    for (final row in data) {
      final date = row['date'] as String;
      final hour = (row['hour'] as num).toInt();
      final count = (row['count'] as num).toInt();
      byDate.putIfAbsent(date, () => {});
      byDate[date]![hour] = count;
    }

    final dates = byDate.keys.toList()..sort();
    final maxCount = data.fold<int>(1, (m, r) => (r['count'] as num).toInt() > m ? (r['count'] as num).toInt() : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // заголовок часов
        Row(
          children: [
            const SizedBox(width: 60),
            ...List.generate(24, (h) => Expanded(
              child: Text(h.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 8, color: Colors.grey), textAlign: TextAlign.center),
            )),
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
                  child: Text(date.substring(5), style: const TextStyle(fontSize: 10)),
                ),
                ...List.generate(24, (h) {
                  final count = hours[h] ?? 0;
                  final intensity = count == 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
                  return Expanded(
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        color: count == 0
                            ? Colors.grey.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.2 + intensity * 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: count == 0
                          ? null
                          : Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
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
        const Text('Чем темнее — тем больше детекций', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}