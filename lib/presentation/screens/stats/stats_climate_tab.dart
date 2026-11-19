import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';

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

    final stats = await AppDatabase.getClimateStats(
      fromDate: _formatDate(from),
      toDate: _formatDate(now),
    );

    if (!mounted) return;

    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _numberOrDash(double? value, {int decimals = 1}) {
    return value?.toStringAsFixed(decimals) ?? '—';
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
          else if (_stats.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.statsNoClimateData),
              ),
            )
          else ...[
              Text(
                l10n.statsClimateByDevice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._stats.map((row) {
                final name = row['deviceName'] as String? ?? '—';
                final temperatureMin =
                (row['t_min'] as num?)?.toDouble();
                final temperatureMax =
                (row['t_max'] as num?)?.toDouble();
                final temperatureAverage =
                (row['t_avg'] as num?)?.toDouble();

                final humidityMin =
                (row['h_min'] as num?)?.toDouble();
                final humidityMax =
                (row['h_max'] as num?)?.toDouble();
                final humidityAverage =
                (row['h_avg'] as num?)?.toDouble();

                final samples = (row['samples'] as num?)?.toInt() ?? 0;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.thermostat,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.statsSampleCount(samples),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (temperatureAverage != null)
                          Text(
                            l10n.statsTemperatureSummary(
                              _numberOrDash(temperatureMin),
                              _numberOrDash(temperatureMax),
                              _numberOrDash(temperatureAverage),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (humidityAverage != null)
                          Text(
                            l10n.statsHumiditySummary(
                              _numberOrDash(humidityMin, decimals: 0),
                              _numberOrDash(humidityMax, decimals: 0),
                              _numberOrDash(humidityAverage, decimals: 0),
                            ),
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