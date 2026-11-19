import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/stats/stat_card.dart';

class StatsPresenceTab extends ConsumerStatefulWidget {
  const StatsPresenceTab({super.key});

  @override
  ConsumerState<StatsPresenceTab> createState() =>
      _StatsPresenceTabState();
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

    final totals = await AppDatabase.getPresenceTotals(
      fromDate: _formatDate(from),
      toDate: _formatDate(now),
    );

    if (!mounted) return;

    setState(() {
      _totals = totals;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds, AppLocalizations l10n) {
    if (seconds <= 0) {
      return l10n.statsPresenceDurationZero;
    }

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return l10n.statsPresenceDurationHoursMinutes(hours, minutes);
    }

    if (minutes > 0) {
      return l10n.statsPresenceDurationMinutes(minutes);
    }

    return l10n.statsPresenceDurationLessMinute;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final totalSeconds = _totals.values.fold<int>(
      0,
          (sum, value) => sum + value,
    );
    final homePercent = totalSeconds == 0
        ? 0
        : (_totals['home'] ?? 0) * 100 ~/ totalSeconds;

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
          else if (totalSeconds == 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.statsPresenceEmpty),
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
                    label: l10n.statsPresenceHome,
                    value: '$homePercent%',
                    icon: Icons.home,
                    color: Colors.green,
                    subtitle: _formatDuration(
                      _totals['home'] ?? 0,
                      l10n,
                    ),
                  ),
                  StatCard(
                    label: l10n.statsPresenceNear,
                    value: _formatDuration(_totals['near'] ?? 0, l10n),
                    icon: Icons.near_me,
                    color: Colors.orange,
                    subtitle: l10n.statsPresencePeriod(_days),
                  ),
                  StatCard(
                    label: l10n.statsPresenceAway,
                    value: _formatDuration(_totals['away'] ?? 0, l10n),
                    icon: Icons.directions_walk,
                    color: Colors.blueGrey,
                    subtitle: l10n.statsPresencePeriod(_days),
                  ),
                  StatCard(
                    label: l10n.statsPresenceUnknown,
                    value: _formatDuration(_totals['unknown'] ?? 0, l10n),
                    icon: Icons.help_outline,
                    color: Colors.grey,
                    subtitle: l10n.statsPresencePeriod(_days),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud, color: Colors.blue),
                  title: Text(l10n.statsPresenceCloudFallback),
                  subtitle: Text(l10n.statsPresenceCloudFallbackSubtitle),
                  trailing: Text(
                    '${_totals['cloud'] ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}