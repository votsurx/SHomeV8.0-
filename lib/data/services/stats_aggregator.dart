/// Агрегирует события в дневные счётчики для экрана «Статистика».
/// Синглтон, вызывается из EventLogger.log().
/// При первом запуске делает backfill из существующих events.
library;
import 'package:talker_flutter/talker_flutter.dart';
import '../local/database.dart';

class StatsAggregator {
  StatsAggregator._();
  static final StatsAggregator instance = StatsAggregator._();

  final Talker _talker = Talker();
  bool _backfillRunning = false;

  /// Хук: вызывать после AppDatabase.insertEvent(...).
  Future<void> onEvent({
    required String event,
    String? deviceId,
    String? timestamp,
  }) async {
    final date = _localDate(timestamp ?? DateTime.now().toIso8601String());
    if (date == null) return;

    final cat = _categorize(event);
    try {
      if (deviceId != null && cat != _Cat.unknown) {
        await AppDatabase.upsertDeviceStat(
          deviceId: deviceId,
          date: date,
          online: cat == _Cat.online ? 1 : 0,
          offline: cat == _Cat.offline ? 1 : 0,
          alert: cat == _Cat.alert ? 1 : 0,
          action: cat == _Cat.action ? 1 : 0,
        );
      }
      if (cat == _Cat.error) {
        await AppDatabase.incrementSystemError(date);
      }
    } catch (e, st) {
      _talker.error('StatsAggregator.onEvent', e, st);
    }
  }

  /// Пройтись по всем существующим events при первом запуске.
  Future<void> backfillIfNeeded() async {
    if (_backfillRunning) return;
    _backfillRunning = true;
    try {
      final done = await AppDatabase.getStatsSetting('stats_backfilled');
      if (done == '1') return;

      _talker.info('StatsAggregator: backfill...');
      final events = await AppDatabase.getRecentEvents(limit: 100000);
      for (final e in events) {
        await onEvent(
          event: e.event,
          deviceId: e.deviceId,
          timestamp: e.timestamp,
        );
      }
      await AppDatabase.setStatsSetting('stats_backfilled', '1');
      _talker.info('StatsAggregator: backfill done (${events.length})');
    } catch (e, st) {
      _talker.error('StatsAggregator.backfill', e, st);
    } finally {
      _backfillRunning = false;
    }
  }

  _Cat _categorize(String e) {
    if (e.startsWith('alarm_') || e.startsWith('frigate_')) return _Cat.alert;
    if (const {
      'turnOn', 'turnOff', 'scene', 'roomAdded', 'roomRemoved',
      'timer', 'deviceAdded', 'deviceRemoved', 'sceneCreated', 'sceneDeleted',
    }.contains(e)) return _Cat.action;
    if (e == 'online') return _Cat.online;
    if (e == 'offline') return _Cat.offline;
    if (e == 'error') return _Cat.error;
    return _Cat.unknown;
  }

  String? _localDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }
}

enum _Cat { alert, action, online, offline, error, unknown }