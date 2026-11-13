import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../application/state/devices_provider.dart';
import '../../widgets/stats/sparkline.dart';
import '../../widgets/stats/uptime_bar.dart';

class StatsDevicesTab extends ConsumerStatefulWidget {
  const StatsDevicesTab({super.key});
  @override
  ConsumerState<StatsDevicesTab> createState() => _StatsDevicesTabState();
}

class _StatsDevicesTabState extends ConsumerState<StatsDevicesTab> {
  int _days = 7;
  bool _loading = true;
  List<Map<String, Object?>> _rows = const [];

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
    final rows = await AppDatabase.getDeviceUptime(fromDate: fromDate, toDate: toDate);
    if (!mounted) return;
    setState(() {
      _rows = rows;
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<int>(
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
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _rows.isEmpty
              ? const Center(child: Text('Нет данных за период'))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _rows.length,
            itemBuilder: (context, i) {
              final r = _rows[i];
              final id = r['device_id'] as String;
              final ratio = r['uptime_ratio'] as double?;
              final alerts = (r['alerts'] as num?)?.toInt() ?? 0;
              final actions = (r['actions'] as num?)?.toInt() ?? 0;
              final offline = (r['offline'] as num?)?.toInt() ?? 0;
              return Card(
                child: ListTile(
                  title: Text(nameOf(id)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      UptimeBar(ratio: ratio),
                      const SizedBox(height: 4),
                      Text(
                        'offline: $offline · alerts: $alerts · actions: $actions',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Text(
                    ratio == null ? '—' : '${(ratio * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ratio == null
                          ? Colors.grey
                          : ratio >= 0.95
                          ? Colors.green
                          : ratio >= 0.80
                          ? Colors.orange
                          : Colors.red,
                    ),
                  ),
                  onTap: () => _openDetail(id, nameOf(id)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(String id, String name) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: _days - 1));
    final series = await AppDatabase.getDeviceDailySeries(
      deviceId: id,
      fromDate: _fmt(from),
      toDate: _fmt(now),
    );
    if (!mounted) return;

    final alertsSeries = series.map((e) => (e['alert_count'] as num).toDouble()).toList();
    final offlineSeries = series.map((e) => (e['offline_count'] as num).toDouble()).toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Алерты за $_days дн.', style: const TextStyle(fontWeight: FontWeight.bold)),
            Sparkline(values: alertsSeries, color: Colors.red, height: 60),
            const SizedBox(height: 16),
            Text('Offline за $_days дн.', style: const TextStyle(fontWeight: FontWeight.bold)),
            Sparkline(values: offlineSeries, color: Colors.grey, height: 60),
          ],
        ),
      ),
    );
  }
}