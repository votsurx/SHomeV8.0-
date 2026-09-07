import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../data/local/entities/event_entity.dart';

class AlarmsTab extends ConsumerStatefulWidget {
  const AlarmsTab({super.key});

  @override
  ConsumerState<AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends ConsumerState<AlarmsTab> {
  List<EventEntity> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      final events = await AppDatabase.getRecentEvents(limit: 100);
      if (!mounted) return;
      final alarms = events.where((e) => e.event.startsWith('alarm_')).toList();
      setState(() {
        _alarms = alarms;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAlarms() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить тревоги?'),
        content: const Text('Все тревоги будут удалены безвозвратно.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Очистить всё'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await AppDatabase.clearEvents();
      setState(() => _alarms = []);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Тревоги очищены')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Ошибка очистки')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_alarms.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.security, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Нет тревог', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Тревоги появятся после подключения Frigate', style: TextStyle(color: Colors.grey)),
        ]),
      );
    }

    return Column(
      children: [
        if (_alarms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearAlarms,
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text('Очистить все тревоги'),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _alarms.length,
            itemBuilder: (context, index) {
              final alarm = _alarms[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.red),
                  title: Text(alarm.deviceName!),
                  subtitle: Text('${alarm.event} | ${alarm.value!}'),
                  trailing: Text(alarm.timestamp),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}