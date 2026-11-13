import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../application/state/devices_provider.dart';
import '../../widgets/stats/stat_card.dart';
import '../../widgets/stats/uptime_bar.dart';

class StatsOverviewTab extends ConsumerStatefulWidget {
  const StatsOverviewTab({super.key});
  @override
  ConsumerState<StatsOverviewTab> createState() => _StatsOverviewTabState();
}

class _StatsOverviewTabState extends ConsumerState<StatsOverviewTab> {
  int _days = 7;
  bool _loading = true;
  Map<String, int> _totals = const {};
  List<Map<String, Object?>> _worst = const [];

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

    final totals = await AppDatabase.getStatsTotals(fromDate: fromDate, toDate: toDate);
    final uptime = await AppDatabase.getDeviceUptime(fromDate: fromDate, toDate: toDate);

    final worst = uptime
        .where((r) => r['uptime_ratio'] != null && (r['uptime_ratio'] as double) < 1.0)
        .take(3)
        .toList();

    if (!mounted) return;
    setState(() {
      _totals = totals;
      _worst = worst;
      _loading = false;
    });
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    String nameOf(String id) {
      for (final d in devices) {
        if (d.id == id) return d.name;
      }
      return id;
    }

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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.9,
              children: [
                StatCard(
                  label: 'Алерты',
                  value: '${_totals['alerts'] ?? 0}',
                  icon: Icons.warning_amber,
                  color: Colors.red,
                  subtitle: 'за $_days дн.',
                ),
                StatCard(
                  label: 'Действия',
                  value: '${_totals['actions'] ?? 0}',
                  icon: Icons.touch_app,
                  color: Colors.blue,
                  subtitle: 'за $_days дн.',
                ),
                StatCard(
                  label: 'Offline',
                  value: '${_totals['offline'] ?? 0}',
                  icon: Icons.wifi_off,
                  color: Colors.grey,
                  subtitle: 'за $_days дн.',
                ),
                StatCard(
                  label: 'Online',
                  value: '${_totals['online'] ?? 0}',
                  icon: Icons.wifi,
                  color: Colors.green,
                  subtitle: 'за $_days дн.',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_worst.isNotEmpty) ...[
              Text('Проблемные устройства', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._worst.map((r) {
                final id = r['device_id'] as String;
                final ratio = r['uptime_ratio'] as double?;
                final name = nameOf(id);
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: UptimeBar(ratio: ratio),
                    ),
                    trailing: Text(
                      ratio == null ? '—' : '${(ratio * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет проблемных устройств за период 👍'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}