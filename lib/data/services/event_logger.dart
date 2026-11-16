/// Сервис логирования событий в журнал с батчингом.
/// Копит события в буфере (500мс или 50 событий), потом — один batch insert.
library;
import 'dart:async';
import 'package:shome/data/services/stats_cache.dart';

import '../local/database.dart';
import '../local/entities/event_entity.dart';
import 'stats_aggregator.dart';

class EventLogger {
  static final _buffer = <EventEntity>[];
  static Timer? _timer;
  static const _maxBatch = 50;
  static const _flushInterval = Duration(milliseconds: 500);

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
    _buffer.add(entity);

    // NEW: добавить в кэш для мгновенного UI
    StatsCache.instance.add(entity);

    if (_buffer.length >= _maxBatch) {
      await _flush();
    } else {
      _timer ??= Timer(_flushInterval, _flush);
    }

    // StatsAggregator — сразу (для реактивности статистики)
    await StatsAggregator.instance.onEvent(
      event: event,
      deviceId: deviceId,
      timestamp: timestamp,
    );
  }

  /// Сброс буфера в БД (batch insert).
  static Future<void> _flush() async {
    _timer?.cancel();
    _timer = null;
    if (_buffer.isEmpty) return;

    final batch = List<EventEntity>.from(_buffer);
    _buffer.clear();

    try {
      final db = await AppDatabase.database;
      final b = db.batch();
      for (final e in batch) {
        b.insert('events', e.toMap());
      }
      await b.commit(noResult: true);
    } catch (e) {
      // при ошибке — вернуть в буфер (не терять)
      _buffer.insertAll(0, batch);
    }
  }

  /// Немедленный сброс (при выходе из приложения, в тестах).
  static Future<void> flushNow() => _flush();
}