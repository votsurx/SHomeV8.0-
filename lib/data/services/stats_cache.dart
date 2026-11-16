/// Кэш последних N событий + счётчик аномалий в памяти.
/// БД — источник правды, StatsCache — кэш для чтения (мгновенный UI).
library;
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../local/database.dart';
import '../local/entities/event_entity.dart';

class StatsCache extends ChangeNotifier {
  StatsCache._();
  static final StatsCache instance = StatsCache._();

  static const _maxEvents = 200;

  final _recentEvents = <EventEntity>[];
  int _anomalyCount = 0;
  bool _loaded = false;
  Timer? _anomalyDebounce;

  List<EventEntity> get recentEvents => List.unmodifiable(_recentEvents);
  int get anomalyCount => _anomalyCount;
  bool get isLoaded => _loaded;

  /// Загрузка последних 200 событий из БД при старте.
  Future<void> loadFromDb() async {
    if (_loaded) return;
    try {
      final events = await AppDatabase.getRecentEvents(limit: _maxEvents);
      // getRecentEvents возвращает от новых к старым → разворачиваем
      _recentEvents
        ..clear()
        ..addAll(events.reversed);
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('StatsCache.loadFromDb error: $e');
    }
  }

  /// Добавить событие в кэш (вызывается из EventLogger.log).
  void add(EventEntity event) {
    _recentEvents.add(event);
    if (_recentEvents.length > _maxEvents) {
      _recentEvents.removeAt(0);
    }
    notifyListeners();

    // Пересчёт аномалий — только для релевантных событий, с debounce
    if (_isRelevantForAnomalies(event.event)) {
      _scheduleAnomalyRefresh();
    }
  }

  bool _isRelevantForAnomalies(String? event) {
    if (event == null) return false;
    return event == 'online' || event == 'offline';
  }

  void _scheduleAnomalyRefresh() {
    _anomalyDebounce?.cancel();
    _anomalyDebounce = Timer(
      const Duration(milliseconds: 500),
          () => refreshAnomalies(),
    );
  }

  /// Пересчитать аномалии (из БД). Вызывать при смене комнаты / pull-to-refresh.
  Future<void> refreshAnomalies({String? roomId}) async {
    try {
      final today = _fmt(DateTime.now());
      final anomalies = await AppDatabase.getAnomaliesByRoom(
        date: today,
        roomId: roomId,
      );
      _anomalyCount = anomalies.length;
      notifyListeners();
    } catch (e) {
      debugPrint('StatsCache.refreshAnomalies error: $e');
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}