import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/local/database.dart';
import '../../widgets/stats/stat_card.dart';

class StatsNotificationsTab extends ConsumerStatefulWidget {
  const StatsNotificationsTab({super.key});
  @override
  ConsumerState<StatsNotificationsTab> createState() =>
      _StatsNotificationsTabState();
}

class _StatsNotificationsTabState
    extends ConsumerState<StatsNotificationsTab> {
  int _days = 7;
  bool _loading = true;
  Map<String, int> _totals = const {};
  List<Map<String, Object?>> _byCategory = const [];
  Map<String, Map<String, int>> _byChannel = const {};

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

    final totals =
    await AppDatabase.getNotificationTotals(fromDate: fromDate, toDate: toDate);
    final byCategory = await AppDatabase.getNotificationByCategory(
        fromDate: fromDate, toDate: toDate);
    final byChannel = await AppDatabase.getNotificationByChannel(
        fromDate: fromDate, toDate: toDate);

    if (!mounted) return;
    setState(() {
      _totals = totals;
      _byCategory = byCategory;
      _byChannel = byChannel;
      _loading = false;
    });
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final sent = _totals['sent'] ?? 0;
    final suppressed = _totals['suppressed'] ?? 0;
    final total = sent + suppressed;
    final suppressedPct = total == 0 ? 0 : suppressed * 100 ~/ total;

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
          else if (total == 0)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет уведомлений за период'),
              ),
            )
          else ...[
              // счётчики
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.9,
                children: [
                  StatCard(
                    label: 'Отправлено',
                    value: '$sent',
                    icon: Icons.send,
                    color: Colors.green,
                    subtitle: 'за $_days дн.',
                  ),
                  StatCard(
                    label: 'Подавлено',
                    value: '$suppressed',
                    icon: Icons.block,
                    color: Colors.orange,
                    subtitle: 'cooldown ($suppressedPct%)',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // VK vs SMS
              if (_byChannel.isNotEmpty) ...[
                Text('По каналам',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: _byChannel.entries.map((e) {
                        final ch = e.key.toUpperCase();
                        final chSent = e.value['sent'] ?? 0;
                        final chSupp = e.value['suppressed'] ?? 0;
                        return ListTile(
                          leading: Icon(
                            ch == 'VK' ? Icons.forum : Icons.sms,
                            color: ch == 'VK' ? Colors.blue : Colors.orange,
                          ),
                          title: Text(ch),
                          subtitle: Text('Подавлено: $chSupp'),
                          trailing: Text(
                            '$chSent',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // по категориям
              if (_byCategory.isNotEmpty) ...[
                Text('По категориям',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 220,
                      child: _CategoryBarChart(data: _byCategory),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._byCategory.map((r) {
                  final cat = r['category'] as String;
                  final s = (r['sent'] as num).toInt();
                  final sp = (r['suppressed'] as num).toInt();
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.blue),
                      title: Text(_categoryLabel(cat)),
                      subtitle: Text('Подавлено: $sp'),
                      trailing: Text(
                        '$s',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ],
            ],
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'water_leak':
        return '💧 Протечка';
      case 'smoke':
        return '🔥 Дым';
      case 'gas':
        return '💨 Газ';
      case 'motion':
        return '🏃 Движение';
      case 'contact':
        return '🚪 Контакт';
      case 'person':
        return '🎥 Person';
      case 'car':
        return '🎥 Car';
      case 'offline':
        return '📡 Offline';
      case 'low_battery':
        return '🔋 Батарея';
      case 'state_changed':
        return '🎛 Состояние';
      default:
        return cat;
    }
  }
}

class _CategoryBarChart extends StatelessWidget {
  final List<Map<String, Object?>> data;
  const _CategoryBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final top = data.take(6).toList();
    final maxY = top.isEmpty
        ? 1.0
        : top
        .map((r) => (r['sent'] as num).toInt())
        .reduce((a, b) => a > b ? a : b)
        .toDouble() *
        1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: top.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['sent'] as num).toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= top.length) return const SizedBox.shrink();
                final cat = top[idx]['category'] as String;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    cat.length > 8 ? '${cat.substring(0, 8)}…' : cat,
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}