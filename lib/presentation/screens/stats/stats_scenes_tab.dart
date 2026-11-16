import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/local/database.dart';

class StatsScenesTab extends ConsumerStatefulWidget {
  const StatsScenesTab({super.key});
  @override
  ConsumerState<StatsScenesTab> createState() => _StatsScenesTabState();
}

class _StatsScenesTabState extends ConsumerState<StatsScenesTab> {
  int _days = 7;
  bool _loading = true;
  Map<String, int> _sceneStats = const {};
  List<String> _forgotten = const [];

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

    final stats = await AppDatabase.getSceneStats(fromDate: fromDate, toDate: toDate);
    final forgotten = await AppDatabase.getForgottenScenes(fromDate: fromDate, toDate: toDate);

    if (!mounted) return;
    setState(() {
      _sceneStats = stats;
      _forgotten = forgotten;
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
          else ...[
            // Топ сцен
            if (_sceneStats.isNotEmpty) ...[
              Text('Топ сцен', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 220,
                    child: _SceneBarChart(data: _sceneStats),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._sceneStats.entries.map((e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.movie, color: Colors.purple),
                  title: Text(e.key),
                  trailing: Text(
                    '${e.value} раз',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет срабатываний сцен за период'),
                ),
              ),

            // Забытые сцены
            if (_forgotten.isNotEmpty) ...[
              Text('Забытые сцены (0 срабатываний)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.orange)),
              const SizedBox(height: 8),
              ..._forgotten.map((name) => Card(
                child: ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.orange),
                  title: Text(name),
                  subtitle: const Text('Кандидат на удаление'),
                ),
              )),
            ],
          ],
        ],
      ),
    );
  }
}

class _SceneBarChart extends StatelessWidget {
  final Map<String, int> data;
  const _SceneBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    final maxY = top.isEmpty ? 1.0 : top.first.value.toDouble() * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: top.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value.toDouble(),
                color: Colors.purple,
                width: 20,
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
                if (idx < 0 || idx >= top.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    top[idx].key.length > 8 ? '${top[idx].key.substring(0, 8)}…' : top[idx].key,
                    style: const TextStyle(fontSize: 9),
                  ),
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