import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local/database.dart';
import '../../application/state/current_room_provider.dart';
import '../../data/services/stats_cache.dart';

class TodayDrawer extends ConsumerStatefulWidget {
  /// Если null — берётся currentRoomIdProvider (реактивно).
  final String? roomId;
  const TodayDrawer({super.key, this.roomId});

  @override
  ConsumerState<TodayDrawer> createState() => _TodayDrawerState();
}

class _TodayDrawerState extends ConsumerState<TodayDrawer> {
  bool _loading = true;
  Map<String, int> _stats = const {};
  Map<String, double> _energy = const {};
  List<Map<String, Object?>> _anomalies = const [];
  int _online = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final roomId = widget.roomId ?? ref.read(currentRoomIdProvider);
    final today = _fmt(DateTime.now());

    final stats = await AppDatabase.getTodayStatsByRoom(date: today, roomId: roomId);
    final energy = await AppDatabase.getTodayEnergyByRoom(date: today, roomId: roomId);
    final anomalies = await AppDatabase.getAnomaliesByRoom(date: today, roomId: roomId);
    final online = await AppDatabase.getOnlineCount(roomId: roomId);
    final total = await AppDatabase.getTotalCount(roomId: roomId);

    if (!mounted) return;
    await StatsCache.instance.refreshAnomalies(roomId: roomId);
    setState(() {
      _stats = stats;
      _energy = energy;
      _anomalies = anomalies;
      _online = online;
      _total = total;
      _loading = false;
    });
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // реактивно: если currentRoomIdProvider поменялся — перезагружаем
    ref.listen<String?>(currentRoomIdProvider, (prev, next) {
      if (next != prev) _load();
    });

    final isPhone = MediaQuery.sizeOf(context).width < 600;

    return Drawer(
      width: isPhone ? MediaQuery.sizeOf(context).width * 0.88 : null,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Icon(Icons.today, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Сегодня', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _load,
                  ),
                ],
              ),
              const Divider(),

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
                  childAspectRatio: 1.5,
                  children: [
                    _MiniCard(
                      label: 'Online',
                      value: '$_online/$_total',
                      icon: Icons.wifi,
                      color: Colors.green,
                    ),
                    _MiniCard(
                      label: 'Алерты',
                      value: '${_stats['alerts'] ?? 0}',
                      icon: Icons.warning_amber,
                      color: Colors.red,
                    ),
                    _MiniCard(
                      label: 'Действия',
                      value: '${_stats['actions'] ?? 0}',
                      icon: Icons.touch_app,
                      color: Colors.blue,
                    ),
                    _MiniCard(
                      label: 'Энергия',
                      value: '${(_energy['kwh'] ?? 0).toStringAsFixed(2)} кВт·ч',
                      icon: Icons.bolt,
                      color: Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _MiniCard(
                  label: 'Средняя температура',
                  value: '${(_energy['avg_temp'] ?? 0).toStringAsFixed(1)}°C',
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),

                const SizedBox(height: 16),

                if (_anomalies.isNotEmpty) ...[
                  Text('⚠️ Аномалии',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.orange)),
                  const SizedBox(height: 8),
                  ..._anomalies.map((a) => Card(
                    child: ListTile(
                      leading: Icon(_anomalyIcon(a['type'] as String),
                          color: Colors.orange),
                      title: Text(a['title'] as String),
                      subtitle: Text(a['subtitle'] as String),
                    ),
                  )),
                ] else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Аномалий нет 👍',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                const SizedBox(height: 16),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.blue),
                    title: const Text('Все события'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/events');
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.purple),
                    title: const Text('Вся статистика'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/stats');
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _anomalyIcon(String type) {
    switch (type) {
      case 'battery':
        return Icons.battery_alert;
      case 'linkquality':
        return Icons.signal_wifi_bad;
      case 'offline':
        return Icons.wifi_off;
      case 'energy':
        return Icons.trending_up;
      case 'temperature':
        return Icons.thermostat;
      default:
        return Icons.warning;
    }
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}