import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';
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
    final fromDate = _formatDate(from);
    final toDate = _formatDate(now);

    final totals = await AppDatabase.getNotificationTotals(
      fromDate: fromDate,
      toDate: toDate,
    );
    final byCategory = await AppDatabase.getNotificationByCategory(
      fromDate: fromDate,
      toDate: toDate,
    );
    final byChannel = await AppDatabase.getNotificationByChannel(
      fromDate: fromDate,
      toDate: toDate,
    );

    if (!mounted) return;

    setState(() {
      _totals = totals;
      _byCategory = byCategory;
      _byChannel = byChannel;
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

    final sent = _totals['sent'] ?? 0;
    final suppressed = _totals['suppressed'] ?? 0;
    final total = sent + suppressed;
    final suppressedPercent =
    total == 0 ? 0 : suppressed * 100 ~/ total;

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
          else if (total == 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.statsNotificationsEmpty),
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
                    label: l10n.statsNotificationsSent,
                    value: '$sent',
                    icon: Icons.send,
                    color: Colors.green,
                    subtitle: l10n.statsNotificationsPeriod(_days),
                  ),
                  StatCard(
                    label: l10n.statsNotificationsSuppressed,
                    value: '$suppressed',
                    icon: Icons.block,
                    color: Colors.orange,
                    subtitle: l10n.statsNotificationsCooldownPercent(
                      suppressedPercent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_byChannel.isNotEmpty) ...[
                Text(
                  l10n.statsNotificationsByChannel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: _byChannel.entries.map((entry) {
                        final channel = entry.key.toUpperCase();
                        final channelSent = entry.value['sent'] ?? 0;
                        final channelSuppressed =
                            entry.value['suppressed'] ?? 0;
                        final isVk = channel == 'VK';

                        return ListTile(
                          leading: Icon(
                            isVk ? Icons.forum : Icons.sms,
                            color: isVk ? Colors.blue : Colors.orange,
                          ),
                          title: Text(channel),
                          subtitle: Text(
                            l10n.statsNotificationsChannelSuppressed(
                              channelSuppressed,
                            ),
                          ),
                          trailing: Text(
                            '$channelSent',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_byCategory.isNotEmpty) ...[
                Text(
                  l10n.statsNotificationsByCategory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 220,
                      child: _CategoryBarChart(
                        data: _byCategory,
                        l10n: l10n,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ..._byCategory.map((row) {
                  final category = row['category'] as String;
                  final categorySent = (row['sent'] as num).toInt();
                  final categorySuppressed =
                  (row['suppressed'] as num).toInt();

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: Colors.blue,
                      ),
                      title: Text(_categoryLabel(category, l10n)),
                      subtitle: Text(
                        l10n.statsNotificationsChannelSuppressed(
                          categorySuppressed,
                        ),
                      ),
                      trailing: Text(
                        '$categorySent',
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

  String _categoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'water_leak':
        return l10n.statsNotificationsCategoryWaterLeak;
      case 'smoke':
        return l10n.statsNotificationsCategorySmoke;
      case 'gas':
        return l10n.statsNotificationsCategoryGas;
      case 'motion':
        return l10n.statsNotificationsCategoryMotion;
      case 'contact':
        return l10n.statsNotificationsCategoryContact;
      case 'person':
        return l10n.statsNotificationsCategoryPerson;
      case 'car':
        return l10n.statsNotificationsCategoryCar;
      case 'offline':
        return l10n.statsNotificationsCategoryOffline;
      case 'low_battery':
        return l10n.statsNotificationsCategoryLowBattery;
      case 'state_changed':
        return l10n.statsNotificationsCategoryStateChanged;
      default:
        return l10n.statsNotificationsCategoryUnknown;
    }
  }
}

class _CategoryBarChart extends StatelessWidget {
  const _CategoryBarChart({
    required this.data,
    required this.l10n,
  });

  final List<Map<String, Object?>> data;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final top = data.take(6).toList();

    final maxY = top.isEmpty
        ? 1.0
        : top
        .map((row) => (row['sent'] as num).toInt())
        .reduce((a, b) => a > b ? a : b)
        .toDouble() *
        1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: top.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value['sent'] as num).toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= top.length) {
                  return const SizedBox.shrink();
                }

                final category = top[index]['category'] as String;
                final label = _categoryLabel(category, l10n);
                final shortLabel =
                label.length > 8 ? '${label.substring(0, 8)}…' : label;

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    shortLabel,
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  String _categoryLabel(String category, AppLocalizations l10n) {
    switch (category) {
      case 'water_leak':
        return l10n.statsNotificationsCategoryWaterLeak;
      case 'smoke':
        return l10n.statsNotificationsCategorySmoke;
      case 'gas':
        return l10n.statsNotificationsCategoryGas;
      case 'motion':
        return l10n.statsNotificationsCategoryMotion;
      case 'contact':
        return l10n.statsNotificationsCategoryContact;
      case 'person':
        return l10n.statsNotificationsCategoryPerson;
      case 'car':
        return l10n.statsNotificationsCategoryCar;
      case 'offline':
        return l10n.statsNotificationsCategoryOffline;
      case 'low_battery':
        return l10n.statsNotificationsCategoryLowBattery;
      case 'state_changed':
        return l10n.statsNotificationsCategoryStateChanged;
      default:
        return l10n.statsNotificationsCategoryUnknown;
    }
  }
}