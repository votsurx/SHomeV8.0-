import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    final fromDate = _formatDate(from);
    final toDate = _formatDate(now);

    final stats = await AppDatabase.getSceneStats(
      fromDate: fromDate,
      toDate: toDate,
    );
    final forgotten = await AppDatabase.getForgottenScenes(
      fromDate: fromDate,
      toDate: toDate,
    );

    if (!mounted) return;

    setState(() {
      _sceneStats = stats;
      _forgotten = forgotten;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
          else ...[
            if (_sceneStats.isNotEmpty) ...[
              Text(
                l10n.statsScenesTop,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 220,
                    child: _SceneBarChart(
                      data: _sceneStats,
                      l10n: l10n,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ..._sceneStats.entries.map(
                    (entry) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.movie,
                      color: Colors.purple,
                    ),
                    // Названия сцен — пользовательские данные, не переводим.
                    title: Text(entry.key),
                    trailing: Text(
                      l10n.statsScenesRuns(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.statsScenesNoRunsPeriod),
                ),
              ),

            if (_forgotten.isNotEmpty) ...[
              Text(
                l10n.statsScenesForgottenTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ..._forgotten.map(
                    (name) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                    ),
                    // Имя сцены задаёт пользователь — оставляем как есть.
                    title: Text(name),
                    subtitle: Text(l10n.statsScenesDeleteCandidate),
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

class _SceneBarChart extends StatelessWidget {
  const _SceneBarChart({
    required this.data,
    required this.l10n,
  });

  final Map<String, int> data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();
    final maxY = top.isEmpty ? 1.0 : top.first.value.toDouble() * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: top.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: Colors.purple,
                width: 20,
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
                if (index < 0 || index >= top.length) {
                  return const SizedBox.shrink();
                }

                // Подпись на графике — имя сцены пользователя.
                final sceneName = top[index].key;
                final label = sceneName.length > 8
                    ? '${sceneName.substring(0, 8)}…'
                    : sceneName;

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 9),
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