/// Сервис логирования событий в журнал.
library;
import '../local/database.dart';
import '../local/entities/event_entity.dart';
import 'stats_aggregator.dart';   // ← NEW

class EventLogger {
  static Future<void> log({
    required String event,
    String? deviceId,
    String? deviceName,
    String? value,
    String? sceneName,
    String? roomName,
    String? timerName,
  }) async {
    final timestamp = DateTime.now().toIso8601String();   // ← NEW: вынесли
    final entity = EventEntity(
      event: event,
      deviceId: deviceId,
      deviceName: deviceName,
      value: value,
      sceneName: sceneName,
      roomName: roomName,
      timerName: timerName,
      timestamp: timestamp,                                // ← NEW: та же
    );
    await AppDatabase.insertEvent(entity);

    // ─── NEW: агрегация статистики ───
    await StatsAggregator.instance.onEvent(
      event: event,
      deviceId: deviceId,
      timestamp: timestamp,
    );
  }
}