/// Сервис логирования событий в журнал.
library;
import 'package:talker/talker.dart';
import '../../di/injection.dart';
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
    final timestamp = DateTime.now().toIso8601String();
    final entity = EventEntity(
      event: event,
      deviceId: deviceId,
      deviceName: deviceName,
      value: value,
      sceneName: sceneName,
      roomName: roomName,
      timerName: timerName,
      timestamp: timestamp,
    );

    // 1. Запись в журнал — критично, ошибку логируем
    try {
      await AppDatabase.insertEvent(entity);
    } catch (e, st) {
      getIt<Talker>().error('❌ EventLogger.insertEvent failed: $event', e, st);
      return; // без записи нет смысла агрегировать
    }

    // 2. Агрегация статистики — некритично, ошибку логируем, но не роняем log()
    try {
      await StatsAggregator.instance.onEvent(
        event: event,
        deviceId: deviceId,
        timestamp: timestamp,
      );
    } catch (e, st) {
      getIt<Talker>().error('❌ EventLogger.aggregate failed: $event', e, st);
    }
  }
}