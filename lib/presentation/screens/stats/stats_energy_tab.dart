import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/stats/stat_card.dart';

class StatsEnergyTab extends ConsumerStatefulWidget {
  const StatsEnergyTab({super.key});

  @override
  ConsumerState<StatsEnergyTab> createState() => _StatsEnergyTabState();
}

class _StatsEnergyTabState extends ConsumerState<StatsEnergyTab> {
  int _days = 7;
  bool _loading = true;
  Map<String, double> _deviceTotals = const {};
  double _totalKwh = 0;
  double _tariff = 5.5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final tariffString = await AppDatabase.getStatsSetting(
      'electricity_tariff_rub_per_kwh',
    );
    final data = await AppDatabase.getEnergyStats(days: _days);

    final totals = <String, double>{};
    var totalKwh = 0.0;

    for (final row in data) {
      final name = row['deviceName'] as String? ?? '—';
      final kwh = (row['totalEnergy'] as num?)?.toDouble() ?? 0;

      totals[name] = (totals[name] ?? 0) + kwh;
      totalKwh += kwh;
    }

    if (!mounted) return;

    setState(() {
      _tariff = double.tryParse(tariffString ?? '5.5') ?? 5.5;
      _deviceTotals = totals;
      _totalKwh = totalKwh;
      _loading = false;
    });
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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  label: l10n.statsEnergyConsumption,
                  value: l10n.statsEnergyKwh(
                    _totalKwh.toStringAsFixed(2),
                  ),
                  icon: Icons.bolt,
                  color: Colors.amber,
                  subtitle: l10n.statsEnergyPeriod(_days),
                ),
                StatCard(
                  label: l10n.statsEnergyCost,
                  value: l10n.statsEnergyRubles(
                    (_totalKwh * _tariff).toStringAsFixed(0),
                  ),
                  icon: Icons.payments,
                  color: Colors.green,
                  subtitle: l10n.statsEnergyTariff(
                    _tariff.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_deviceTotals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.statsEnergyNoData),
                ),
              )
            else ...[
              Text(
                l10n.statsEnergyByDevice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...(_deviceTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
                  .map(
                    (entry) => Card(
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text(
                      l10n.statsEnergyRubles(
                        (entry.value * _tariff).toStringAsFixed(0),
                      ),
                    ),
                    trailing: Text(
                      l10n.statsEnergyKwh(
                        entry.value.toStringAsFixed(2),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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