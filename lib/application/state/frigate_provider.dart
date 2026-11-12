/// Riverpod-провайдер для Frigate (камеры, события, статистика).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/frigate_models.dart';
import '../../data/services/frigate_service.dart';
import '../../data/services/frigate_bridge.dart';
import '../../di/injection.dart';

/// Настройки Frigate (интервал статистики, фильтры уведомлений).
final frigateSettingsProvider =
StateProvider<FrigateSettings>((ref) {
  return FrigateSettings.defaults();
});

/// Список камер.
final frigateCamerasProvider =
StateNotifierProvider<FrigateCamerasNotifier, List<FrigateCamera>>((ref) {
  return FrigateCamerasNotifier();
});

/// Список последних событий.
final frigateEventsProvider =
StateNotifierProvider<FrigateEventsNotifier, List<FrigateEvent>>((ref) {
  return FrigateEventsNotifier();
});

/// Статистика (CPU, RAM).
final frigateStatsProvider = StateProvider<FrigateStats?>((ref) => null);

class FrigateSettings {
  final int statsInterval;  // секунды
  final Set<String> notifyLabels;  // какие события отправлять
  final String? rtspPassword;

  FrigateSettings({
    required this.statsInterval,
    required this.notifyLabels,
    this.rtspPassword,
  });

  factory FrigateSettings.defaults() {
    return FrigateSettings(
      statsInterval: 5,
      notifyLabels: {'person', 'car'},
    );
  }

  FrigateSettings copyWith({
    int? statsInterval,
    Set<String>? notifyLabels,
    String? rtspPassword,
  }) {
    return FrigateSettings(
      statsInterval: statsInterval ?? this.statsInterval,
      notifyLabels: notifyLabels ?? this.notifyLabels,
      rtspPassword: rtspPassword ?? this.rtspPassword,
    );
  }
}

class FrigateCamerasNotifier extends StateNotifier<List<FrigateCamera>> {
  final FrigateService _service = getIt<FrigateService>();

  FrigateCamerasNotifier() : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    final cameras = await _service.getCameras();
    state = cameras;
  }

  void addCamera(FrigateCamera camera) {
    state = [...state, camera];
  }

  void removeCamera(String name) {
    state = state.where((c) => c.name != name).toList();
  }
}

class FrigateEventsNotifier extends StateNotifier<List<FrigateEvent>> {
  final FrigateBridge _bridge = getIt<FrigateBridge>();

  FrigateEventsNotifier() : super([]) {
    _bridge.onEvent = (event) {
      state = [event, ...state].take(100).toList();
    };
  }

  void clear() => state = [];
}