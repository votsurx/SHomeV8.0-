import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
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
    final tariffStr = await AppDatabase.getStatsSetting('electricity_tariff_rub_per_kwh');
    final data = await AppDatabase.getEnergyStats(days: _days);

    final totals = <String, double>{};
    double sum = 0;
    for (final row in data) {
      final name = row['deviceName'] as String? ?? '—';
      final kwh = (row['totalEnergy'] as num?)?.toDouble() ?? 0;
      totals[name] = (totals[name] ?? 0) + kwh;
      sum += kwh;
    }

    if (!mounted) return;
    setState(() {
      _tariff = double.tryParse(tariffStr ?? '5.5') ?? 5.5;
      _deviceTotals = totals;
      _totalKwh = sum;
      _loading = false;
    });
  }

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
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
              children: [
                StatCard(
                  label: 'Потребление',
                  value: '${_totalKwh.toStringAsFixed(2)} кВт·ч',
                  icon: Icons.bolt,
                  color: Colors.amber,
                  subtitle: 'за $_days дн.',
                ),
                StatCard(
                  label: 'Стоимость',
                  value: '${(_totalKwh * _tariff).toStringAsFixed(0)} ₽',
                  icon: Icons.payments,
                  color: Colors.green,
                  subtitle: 'тариф $_tariff ₽/кВт·ч',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_deviceTotals.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Нет данных энергопотребления за период'),
                ),
              )
            else ...[
              Text('По устройствам', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...(_deviceTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value))
              ).map((e) => Card(
                child: ListTile(
                  title: Text(e.key),
                  subtitle: Text('${(e.value * _tariff).toStringAsFixed(0)} ₽'),
                  trailing: Text(
                    '${e.value.toStringAsFixed(2)} кВт·ч',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ],
          ],
        ],
      ),
    );
  }
}