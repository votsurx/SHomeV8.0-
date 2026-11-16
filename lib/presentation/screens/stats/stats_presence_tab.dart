import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../widgets/stats/stat_card.dart';

class StatsPresenceTab extends ConsumerStatefulWidget {
  const StatsPresenceTab({super.key});
  @override
  ConsumerState<StatsPresenceTab> createState() => _StatsPresenceTabState();
}

class _StatsPresenceTabState extends ConsumerState<StatsPresenceTab> {
  int _days = 7;
  bool _loading = true;
  Map<String, int> _totals = const {};

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

    final totals = await AppDatabase.getPresenceTotals(fromDate: fromDate, toDate: toDate);

    if (!mounted) return;
    setState(() {
      _totals = totals;
      _loading = false;
    });
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtSec(int sec) {
    if (sec == 0) return '0';
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    if (h > 0) return '$hч $mм';
    return '$mм';
  }

  @override
  Widget build(BuildContext context) {
    final totalSec = _totals.values.fold<int>(0, (a, b) => a + b);
    final homePct = totalSec == 0 ? 0 : (_totals['home'] ?? 0) * 100 ~/ totalSec;

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
          else if (totalSec == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет данных присутствия за период'),
              ),
            )
          else ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.9,
                children: [
                  StatCard(
                    label: 'Дома',
                    value: '$homePct%',
                    icon: Icons.home,
                    color: Colors.green,
                    subtitle: _fmtSec(_totals['home'] ?? 0),
                  ),
                  StatCard(
                    label: 'Рядом',
                    value: _fmtSec(_totals['near'] ?? 0),
                    icon: Icons.near_me,
                    color: Colors.orange,
                    subtitle: 'за $_days дн.',
                  ),
                  StatCard(
                    label: 'Ушёл',
                    value: _fmtSec(_totals['away'] ?? 0),
                    icon: Icons.directions_walk,
                    color: Colors.blueGrey,
                    subtitle: 'за $_days дн.',
                  ),
                  StatCard(
                    label: 'Неизвестно',
                    value: _fmtSec(_totals['unknown'] ?? 0),
                    icon: Icons.help_outline,
                    color: Colors.grey,
                    subtitle: 'за $_days дн.',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud, color: Colors.blue),
                  title: const Text('Fallback на облако'),
                  subtitle: const Text('Сколько раз heartbeat не сработал'),
                  trailing: Text(
                    '${_totals['cloud'] ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}