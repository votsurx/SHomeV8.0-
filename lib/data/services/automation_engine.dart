/// Движок автоматизации — выполняет сцены по временным триггерам.
/// Каждые 30 секунд проверяет, не пора ли выполнить сцену с trigger.type = time.
/// Защита от повторного выполнения в одну и ту же минуту.
///
/// Также обрабатывает триггеры присутствия (TriggerType.presence):
/// - подписывается на callback PresenceDetector
/// - проверяет события (кто-то пришёл/ушёл, никого нет, все дома)
/// - применяет задержку, антидребезг и условия
library;
import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../data/services/vk_notification_service.dart';
import '../../application/services/notification_settings_service.dart';
import 'presence_detector.dart';

class AutomationEngine {
  final SceneRepository _sceneRepository;
  final Talker _talker;

  /// Опциональный детектор присутствия (может быть null).
  final PresenceDetector? _presenceDetector;

  /// Таймер проверки time-триггеров (каждые 30 секунд)
  Timer? _timer;

  /// Время последней проверки (для защиты от повторного выполнения)
  DateTime? _lastCheck;

  /// Время последнего запуска сцены (для антидребезга триггеров присутствия).
  final Map<String, DateTime> _sceneLastRun = {};

  /// Отложенные запуски сцен (задержка перед выполнением).
  final Map<String, Timer> _pendingScenes = {};

  AutomationEngine(
      this._sceneRepository,
      this._talker, {
        PresenceDetector? presenceDetector,
      }) : _presenceDetector = presenceDetector;

  /// Запускает периодическую проверку time-триггеров
  /// и подписывается на изменения присутствия.
  void start() {
    _talker.info('AutomationEngine started');
    _lastCheck = DateTime.now().subtract(const Duration(minutes: 1));
    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _checkTimeTriggers(),
    );

    // Подписываемся на изменения присутствия
    _presenceDetector?.onStatusChanged = _onPresenceChanged;
  }

  // ═══════════════════════════════════════════════════════
  // TIME TRIGGERS
  // ═══════════════════════════════════════════════════════

  /// Проверяет все сцены с time-триггерами.
  /// Если текущее время совпадает с trigger.time и сцена ещё не выполнялась
  /// в эту минуту — выполняет её.
  Future<void> _checkTimeTriggers() async {
    try {
      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final scenes = await _sceneRepository.getAllScenes();

      for (final scene in scenes) {
        if (scene.trigger != null && scene.trigger!.type == TriggerType.time) {
          final triggerTime = scene.trigger!.time;

          // Время совпадает и мы ещё не выполняли в эту минуту
          if (triggerTime == currentTime &&
              (_lastCheck == null || !_isSameMinute(_lastCheck!, now))) {
            _talker.info(
                'Executing time-triggered scene: ${scene.name} at $currentTime');
            await _sceneRepository.executeScene(scene);
            // Отправляем VK-уведомление
            await _sendSceneNotification(scene);
          }
        }
      }

      _lastCheck = now;
    } catch (e, stackTrace) {
      _talker.error('Error checking time triggers', e, stackTrace);
    }
  }

  // ═══════════════════════════════════════════════════════
  // PRESENCE TRIGGERS
  // ═══════════════════════════════════════════════════════

  /// Callback от PresenceDetector — вызывается при изменении статуса телефона.
  void _onPresenceChanged(
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      ) async {
    _talker.info(
        '📍 Presence changed: $phoneId $oldStatus → $newStatus');

    try {
      final scenes = await _sceneRepository.getAllScenes();

      for (final scene in scenes) {
        final trigger = scene.trigger;
        if (trigger == null || trigger.type != TriggerType.presence) continue;

        // 1. Проверяем событие
        if (!_matchPresenceEvent(trigger, phoneId, oldStatus, newStatus)) {
          continue;
        }

        // 2. Проверяем канал (Wi-Fi / GPS)
        if (!_matchPresenceChannel(trigger, phoneId)) {
          continue;
        }

        // 3. Проверяем условия (время, дни, устройства)
        if (!_matchConditions(trigger)) {
          continue;
        }

        // 4. Проверяем антидребезг
        if (_isCooldown(scene.id, trigger)) {
          _talker.info('⏱ Сцена ${scene.name}: антидребезг');
          continue;
        }

        // 5. Задержка или сразу
        if (trigger.presenceDelayMin > 0) {
          _scheduleScene(scene, trigger.presenceDelayMin);
        } else {
          await _executeScene(scene);
        }
      }
    } catch (e, stackTrace) {
      _talker.error('Error processing presence trigger', e, stackTrace);
    }
  }

  /// Проверяет, соответствует ли событие присутствия.
  bool _matchPresenceEvent(
      SceneTrigger trigger,
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      ) {
    final event = trigger.presenceEvent;
    if (event == null) return false;

    switch (event) {
      case PresenceEvent.someoneHome:
      // Кто-то пришёл (любой телефон)
        return oldStatus != PhonePresenceStatus.home &&
            newStatus == PhonePresenceStatus.home;

      case PresenceEvent.nobodyHome:
      // Последний ушёл (никого не осталось)
        final allAway = _presenceDetector?.isNobodyHome ?? false;
        return oldStatus != PhonePresenceStatus.away &&
            newStatus == PhonePresenceStatus.away &&
            allAway;

      case PresenceEvent.allHome:
      // Все телефоны дома
        final allHome = _presenceDetector?.phones.values
            .every((p) => p.status == PhonePresenceStatus.home) ??
            false;
        return allHome && newStatus == PhonePresenceStatus.home;

      case PresenceEvent.phoneArrived:
      // Конкретный телефон пришёл
        return trigger.presencePhoneId == phoneId &&
            oldStatus != PhonePresenceStatus.home &&
            newStatus == PhonePresenceStatus.home;

      case PresenceEvent.phoneLeft:
      // Конкретный телефон ушёл
        return trigger.presencePhoneId == phoneId &&
            oldStatus == PhonePresenceStatus.home &&
            newStatus != PhonePresenceStatus.home;

      case PresenceEvent.phoneUnknown:
      // Конкретный телефон потерян
        return trigger.presencePhoneId == phoneId &&
            newStatus == PhonePresenceStatus.unknown;
    }
  }

  /// Проверяет канал определения (Wi-Fi / GPS / любой).
  bool _matchPresenceChannel(SceneTrigger trigger, String phoneId) {
    final presence = _presenceDetector?.phones[phoneId];
    if (presence == null) return false;

    switch (trigger.presenceChannel) {
      case PresenceChannel.any:
        return true;
      case PresenceChannel.wifi:
        return presence.viaWifi;
      case PresenceChannel.gps:
        return !presence.viaWifi;
    }
  }

  /// Проверяет условия триггера (время, дни недели, состояние устройства).
  bool _matchConditions(SceneTrigger trigger) {
    final conditions = trigger.presenceConditions;
    if (conditions == null) return true;

    final now = DateTime.now();

    // 1. Время суток
    if (conditions.useTime) {
      final currentMin = now.hour * 60 + now.minute;
      final startMin =
          conditions.startHour * 60 + conditions.startMinute;
      final endMin = conditions.endHour * 60 + conditions.endMinute;

      if (startMin <= endMin) {
        // Обычный интервал (например, 09:00 - 21:00)
        if (currentMin < startMin || currentMin > endMin) return false;
      } else {
        // Ночной интервал (например, 22:00 - 06:00)
        if (currentMin < startMin && currentMin > endMin) return false;
      }
    }

    // 2. Дни недели
    if (conditions.useDays) {
      if (!conditions.daysOfWeek.contains(now.weekday)) return false;
    }

    // 3. Состояние устройства
    if (conditions.useDevice && conditions.deviceId != null) {
      // TODO: проверить состояние устройства через DevicesNotifier
      // Пока пропускаем
    }

    return true;
  }

  /// Проверяет антидребезг — не запускалась ли сцена недавно.
  bool _isCooldown(String sceneId, SceneTrigger trigger) {
    final lastRun = _sceneLastRun[sceneId];
    if (lastRun == null) return false;

    final elapsed = DateTime.now().difference(lastRun).inMinutes;
    return elapsed < trigger.presenceCooldownMin;
  }

  /// Планирует запуск сцены через N минут.
  void _scheduleScene(Scene scene, int delayMin) {
    // Отменяем предыдущий запланированный запуск
    _pendingScenes[scene.id]?.cancel();

    _pendingScenes[scene.id] = Timer(
      Duration(minutes: delayMin),
          () async {
        _pendingScenes.remove(scene.id);

        // Перечитываем сцену — вдруг что-то изменилось
        try {
          final scenes = await _sceneRepository.getAllScenes();
          final actualScene = scenes.firstWhere(
                (s) => s.id == scene.id,
            orElse: () => scene,
          );
          await _executeScene(actualScene);
        } catch (e, stackTrace) {
          _talker.error('Error executing delayed scene', e, stackTrace);
        }
      },
    );

    _talker.info(
        '⏱ Сцена ${scene.name} запланирована через $delayMin мин');
  }

  /// Выполняет сцену и запоминает время запуска.
  Future<void> _executeScene(Scene scene) async {
    _sceneLastRun[scene.id] = DateTime.now();
    _talker.info('🎬 Запуск сцены по присутствию: ${scene.name}');
    await _sceneRepository.executeScene(scene);
    await _sendSceneNotification(scene);
  }

  // ═══════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════

  Future<void> _sendSceneNotification(Scene scene) async {
    try {
      final shouldSend =
      await NotificationSettingsService.shouldSendSceneNotification();
      if (shouldSend) {
        final vk = VkNotificationService();
        await vk.loadSettings();
        await vk.sendSceneNotification(sceneName: scene.name, success: true);
      }
    } catch (e) {
      _talker.error('VK scene notification error', e);
    }
  }

  // ═══════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════

  /// Проверяет, принадлежат ли две даты одной минуте.
  bool _isSameMinute(DateTime a, DateTime b) {
    return a.hour == b.hour && a.minute == b.minute;
  }

  /// Останавливает движок автоматизации.
  void stop() {
    _timer?.cancel();
    _presenceDetector?.onStatusChanged = null;

    // Отменяем все отложенные сцены
    for (final timer in _pendingScenes.values) {
      timer.cancel();
    }
    _pendingScenes.clear();

    _talker.info('AutomationEngine stopped');
  }
}