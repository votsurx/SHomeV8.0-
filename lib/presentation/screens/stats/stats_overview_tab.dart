import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/state/devices_provider.dart';
import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final fromDate = _formatDate(from);
    final toDate = _formatDate(now);

    final totals = await AppDatabase.getStatsTotals(
      fromDate: fromDate,
      toDate: toDate,
    );
    final uptime = await AppDatabase.getDeviceUptime(
      fromDate: fromDate,
      toDate: toDate,
    );

    final worst = uptime
        .where(
          (row) =>
      row['uptime_ratio'] != null &&
          (row['uptime_ratio'] as double) < 1.0,
    )
        .take(3)
        .toList();

    if (!mounted) return;

    setState(() {
      _totals = totals;
      _worst = worst;
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.25,
              children: [
                StatCard(
                  label: l10n.statsOverviewAlerts,
                  value: '${_totals['alerts'] ?? 0}',
                  icon: Icons.warning_amber,
                  color: Colors.red,
                  subtitle: l10n.statsOverviewPeriod(_days),
                ),
                StatCard(
                  label: l10n.statsOverviewActions,
                  value: '${_totals['actions'] ?? 0}',
                  icon: Icons.touch_app,
                  color: Colors.blue,
                  subtitle: l10n.statsOverviewPeriod(_days),
                ),
                StatCard(
                  label: l10n.statsOverviewOffline,
                  value: '${_totals['offline'] ?? 0}',
                  icon: Icons.wifi_off,
                  color: Colors.grey,
                  subtitle: l10n.statsOverviewPeriod(_days),
                ),
                StatCard(
                  label: l10n.statsOverviewOnline,
                  value: '${_totals['online'] ?? 0}',
                  icon: Icons.wifi,
                  color: Colors.green,
                  subtitle: l10n.statsOverviewPeriod(_days),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_worst.isNotEmpty) ...[
              Text(
                l10n.statsOverviewWorstDevices,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._worst.map((row) {
                final id = row['device_id'] as String;
                final ratio = row['uptime_ratio'] as double?;

                return Card(
                  child: ListTile(
                    title: Text(nameOf(id)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: UptimeBar(ratio: ratio),
                    ),
                    trailing: Text(
                      ratio == null
                          ? '—'
                          : '${(ratio * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ] else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.statsOverviewNoProblems),
                ),
              ),
          ],
        ],
      ),
    );
  }
}