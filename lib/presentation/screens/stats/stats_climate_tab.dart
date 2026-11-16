import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';

class StatsClimateTab extends ConsumerStatefulWidget {
  const StatsClimateTab({super.key});
  @override
  ConsumerState<StatsClimateTab> createState() => _StatsClimateTabState();
}

class _StatsClimateTabState extends ConsumerState<StatsClimateTab> {
  int _days = 7;
  bool _loading = true;
  List<Map<String, Object?>> _stats = const [];

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

    final stats = await AppDatabase.getClimateStats(fromDate: fromDate, toDate: toDate);

    if (!mounted) return;
    setState(() {
      _stats = stats;
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
          else if (_stats.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет данных датчиков за период'),
              ),
            )
          else ...[
              Text('Климат по устройствам', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._stats.map((r) {
                final name = r['deviceName'] as String? ?? '—';
                final tMin = (r['t_min'] as num?)?.toDouble();
                final tMax = (r['t_max'] as num?)?.toDouble();
                final tAvg = (r['t_avg'] as num?)?.toDouble();
                final hMin = (r['h_min'] as num?)?.toDouble();
                final hMax = (r['h_max'] as num?)?.toDouble();
                final hAvg = (r['h_avg'] as num?)?.toDouble();
                final samples = (r['samples'] as num?)?.toInt() ?? 0;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.thermostat, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const Spacer(),
                            Text('$samples сэмплов', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tAvg != null)
                          Text(
                            '🌡️ ${tMin?.toStringAsFixed(1)}° … ${tMax?.toStringAsFixed(1)}° (сред. ${tAvg.toStringAsFixed(1)}°)',
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (hAvg != null)
                          Text(
                            '💧 ${hMin?.toStringAsFixed(0)}% … ${hMax?.toStringAsFixed(0)}% (сред. ${hAvg.toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
        ],
      ),
    );
  }
}