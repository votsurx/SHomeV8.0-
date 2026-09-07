/// Движок автоматизации — выполняет сцены по временным триггерам.
/// Каждые 30 секунд проверяет, не пора ли выполнить сцену с trigger.type = time.
/// Защита от повторного выполнения в одну и ту же минуту.
library;
import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';

class AutomationEngine {
  final SceneRepository _sceneRepository;
  final Talker _talker;
  /// Таймер проверки time-триггеров (каждые 30 секунд)
  Timer? _timer;
  /// Время последней проверки (для защиты от повторного выполнения)
  DateTime? _lastCheck;

  AutomationEngine(this._sceneRepository, this._talker);

  /// Запускает периодическую проверку time-триггеров.
  void start() {
    _talker.info('AutomationEngine started');
    _lastCheck = DateTime.now().subtract(const Duration(minutes: 1));
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkTimeTriggers());
  }

  /// Проверяет все сцены с time-триггерами.
  /// Если текущее время совпадает с trigger.time и сцена ещё не выполнялась
  /// в эту минуту — выполняет её.
  Future<void> _checkTimeTriggers() async {
    try {
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final scenes = await _sceneRepository.getAllScenes();

      for (final scene in scenes) {
        if (scene.trigger != null && scene.trigger!.type == TriggerType.time) {
          final triggerTime = scene.trigger!.time;

          // Время совпадает и мы ещё не выполняли в эту минуту
          if (triggerTime == currentTime &&
              (_lastCheck == null || !_isSameMinute(_lastCheck!, now))) {
            _talker.info('Executing time-triggered scene: ${scene.name} at $currentTime');
            await _sceneRepository.executeScene(scene);
          }
        }
      }

      _lastCheck = now;
    } catch (e, stackTrace) {
      _talker.error('Error checking time triggers', e, stackTrace);
    }
  }

  /// Проверяет, принадлежат ли две даты одной минуте.
  bool _isSameMinute(DateTime a, DateTime b) {
    return a.hour == b.hour && a.minute == b.minute;
  }

  /// Останавливает движок автоматизации.
  void stop() {
    _timer?.cancel();
    _talker.info('AutomationEngine stopped');
  }
}