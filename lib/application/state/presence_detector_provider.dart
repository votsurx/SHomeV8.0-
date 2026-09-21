import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/presence_detector.dart';
import 'presence_provider.dart';
import '../../application/models/presence_settings.dart';

/// Глобальный провайдер PresenceDetector.
/// Живёт всё время работы приложения.
final presenceDetectorProvider =
StateNotifierProvider<PresenceDetectorNotifier, PresenceDetector>((ref) {
  return PresenceDetectorNotifier(ref);
});

class PresenceDetectorNotifier extends StateNotifier<PresenceDetector> {
  final Ref ref;

  PresenceDetectorNotifier(this.ref) : super(PresenceDetector()) {
    _init();
  }

  Future<void> _init() async {
    // Ждём загрузки настроек
    await Future.delayed(const Duration(milliseconds: 500));

    final settings = ref.read(presenceSettingsProvider);
    if (settings.enabled && settings.isConfigured) {
      await state.start(settings);
    }

    // Следим за изменениями настроек
    ref.listen(presenceSettingsProvider, (previous, next) {
      _onSettingsChanged(previous, next);
    });
  }

  Future<void> _onSettingsChanged(
      PresenceSettings? previous,
      PresenceSettings next,
      ) async {
    if (next.enabled && next.isConfigured) {
      if (!state.isRunning) {
        await state.start(next);
      } else {
        // Перезапускаем с новыми настройками
        state.stop();
        await state.start(next);
      }
    } else {
      if (state.isRunning) {
        state.stop();
      }
    }
  }

  void stop() {
    state.stop();
  }

  Future<void> restart() async {
    state.stop();
    final settings = ref.read(presenceSettingsProvider);
    if (settings.enabled && settings.isConfigured) {
      await state.start(settings);
    }
  }
}