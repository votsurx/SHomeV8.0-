import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/state/devices_provider.dart';
import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';
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

    final rows = await AppDatabase.getDeviceUptime(
      fromDate: _formatDate(from),
      toDate: _formatDate(now),
    );

    if (!mounted) return;

    setState(() {
      _rows = rows;
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
    final devices = ref.watch(devicesProvider);

    String nameOf(String id) {
      for (final device in devices) {
        if (device.id == id) return device.name;
      }
      return id;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<int>(
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
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _rows.isEmpty
              ? Center(
            child: Text(l10n.statsNoDeviceDataPeriod),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _rows.length,
            itemBuilder: (context, index) {
              final row = _rows[index];
              final id = row['device_id'] as String;
              final ratio =
              (row['uptime_ratio'] as num?)?.toDouble();
              final alerts =
                  (row['alerts'] as num?)?.toInt() ?? 0;
              final actions =
                  (row['actions'] as num?)?.toInt() ?? 0;
              final offline =
                  (row['offline'] as num?)?.toInt() ?? 0;
              final deviceName = nameOf(id);

              return Card(
                child: ListTile(
                  title: Text(deviceName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      UptimeBar(ratio: ratio),
                      const SizedBox(height: 4),
                      Text(
                        l10n.statsDeviceEventCounts(
                          offline,
                          alerts,
                          actions,
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    ratio == null
                        ? '—'
                        : '${(ratio * 100).toStringAsFixed(0)}%',
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
                  onTap: () => _openDetail(
                    context,
                    id,
                    deviceName,
                    l10n,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(
      BuildContext context,
      String id,
      String name,
      AppLocalizations l10n,
      ) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: _days - 1));

    final series = await AppDatabase.getDeviceDailySeries(
      deviceId: id,
      fromDate: _formatDate(from),
      toDate: _formatDate(now),
    );

    if (!context.mounted) return;

    final alertsSeries = series
        .map((entry) => (entry['alert_count'] as num?)?.toDouble() ?? 0)
        .toList();
    final offlineSeries = series
        .map((entry) => (entry['offline_count'] as num?)?.toDouble() ?? 0)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.statsAlertsForDays(_days),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Sparkline(
              values: alertsSeries,
              color: Colors.red,
              height: 60,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.statsOfflineForDays(_days),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Sparkline(
              values: offlineSeries,
              color: Colors.grey,
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}