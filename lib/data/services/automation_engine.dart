/// Движок автоматизации.
///
/// Для сцены «Никого нет дома»:
/// - если все телефоны достоверно away — ждёт настроенный таймаут «Ушёл»;
/// - если есть unknown, но нет home, показывает предупреждение;
/// - общая недоступность облака блокирует запуск.
/// Статус unknown не подменяется на away.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import '../../application/services/notification_settings_service.dart';
import '../../application/services/presence_warning_controller.dart';
import '../../data/services/presence_detector.dart';
import '../../data/services/vk_notification_service.dart';
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';

typedef AwayTimeoutReader = Future<int> Function();
typedef AutomationClock = DateTime Function();

class AutomationEngine {
  AutomationEngine(
      this._sceneRepository,
      this._talker, {
        PresenceDetector? presenceDetector,
        PresenceWarningController? warningController,
        AwayTimeoutReader? awayTimeoutReader,
        AutomationClock? clock,
        this.presenceWarningDuration = const Duration(minutes: 5),
        this.presenceWarningTickInterval = const Duration(seconds: 1),
      })  : _presenceDetector = presenceDetector,
        _warningController =
            warningController ?? PresenceWarningController(),
        _awayTimeoutReader = awayTimeoutReader ?? _readAwayTimeoutMinutes,
        _clock = clock ?? DateTime.now;

  static const Duration _maxPresenceResultAge = Duration(seconds: 90);

  final SceneRepository _sceneRepository;
  final Talker _talker;
  final PresenceDetector? _presenceDetector;
  final PresenceWarningController _warningController;
  final AwayTimeoutReader _awayTimeoutReader;
  final AutomationClock _clock;

  /// По умолчанию предупреждение длится пять минут.
  /// В тестах можно передать короткий интервал.
  final Duration presenceWarningDuration;

  /// Интервал обновления отображаемого обратного отсчёта.
  final Duration presenceWarningTickInterval;

  Timer? _timer;
  DateTime? _lastCheck;

  final Map<String, DateTime> _sceneLastRun = {};
  final Map<String, Timer> _pendingScenes = {};

  final Map<String, DateTime> _allAwaySince = {};
  final Map<String, Timer> _allAwayTimers = {};
  final Set<String> _allAwayScheduling = {};
  final Set<String> _completedAllAwayEpisodes = {};

  Timer? _unknownWarningTimer;
  DateTime? _unknownWarningDeadline;
  Set<String> _unknownWarningSceneIds = {};
  final Set<String> _cancelledUnknownEpisodes = {};
  final Set<String> _completedUnknownEpisodes = {};

  PresenceCycleResult? _lastPresenceCycle;
  bool _presenceCycleProcessing = false;
  bool _unknownWarningFinishing = false;
  bool _started = false;

  PresenceWarningController get warningController => _warningController;

  @visibleForTesting
  Future<void> checkTimeTriggers() => _checkTimeTriggers();

  @visibleForTesting
  Future<void> processPresenceCycle(PresenceCycleResult result) {
    return _handlePresenceCycle(result);
  }

  Future<void> _handlePresenceCycle(PresenceCycleResult result) async {
    if (_presenceCycleProcessing) return;
    _presenceCycleProcessing = true;

    try {
      _lastPresenceCycle = result;

      final scenes = await _sceneRepository.getAllScenes();
      final nobodyHomeScenes = scenes.where((scene) {
        final trigger = scene.trigger;
        return trigger?.type == TriggerType.presence &&
            trigger?.presenceEvent == PresenceEvent.nobodyHome;
      }).toList();

      if (nobodyHomeScenes.isEmpty || result.hasHome) {
        // Подтверждённый home завершает эпизод отсутствия.
        _resetNobodyHomeState();
        return;
      }

      if (!result.cloudAvailable) {
        // Сбой облака отменяет активные отсчёты, но не стирает защиту
        // от повторного запуска в текущем эпизоде.
        _pauseNobodyHomeState();
        return;
      }

      final eligibleScenes = nobodyHomeScenes.where((scene) {
        final trigger = scene.trigger!;
        return _matchConditions(trigger) &&
            !_isCooldown(scene.id, trigger);
      }).toList();

      if (eligibleScenes.isEmpty) {
        _pauseNobodyHomeState();
        return;
      }

      if (result.allAway) {
        // Смена unknown → away не должна запускать уже выполненную сцену
        // повторно и не должна сбрасывать пользовательскую отмену.
        _cancelUnknownWarning(clearSuppression: false);

        final eligibleIds = eligibleScenes.map((scene) => scene.id).toSet();
        _cancelAllAwayTimersExcept(eligibleIds);

        for (final scene in eligibleScenes) {
          if (_completedAllAwayEpisodes.contains(scene.id) ||
              _completedUnknownEpisodes.contains(scene.id) ||
              _cancelledUnknownEpisodes.contains(scene.id)) {
            continue;
          }

          _startOrCheckAllAwayEpisode(scene, result);
        }

        return;
      }

      if (result.hasUnknown) {
        // Переход away → unknown отменяет таймер подтверждённого ухода,
        // но не стирает отметки о сценах, уже выполненных в этом эпизоде.
        _cancelAllAwayTimers();

        final pendingScenes = eligibleScenes.where((scene) {
          return !_completedAllAwayEpisodes.contains(scene.id) &&
              !_completedUnknownEpisodes.contains(scene.id) &&
              !_cancelledUnknownEpisodes.contains(scene.id);
        }).toList();

        if (pendingScenes.isEmpty) {
          _cancelUnknownWarning(clearSuppression: false);
          return;
        }

        _startOrUpdateUnknownWarning(pendingScenes, result);
        return;
      }

      // Пустой или неопределённый результат не доказывает отсутствие.
      _pauseNobodyHomeState();
    } catch (error, stackTrace) {
      _talker.error('Error processing presence cycle', error, stackTrace);
    } finally {
      _presenceCycleProcessing = false;
    }
  }

  void start() {
    if (_started) return;

    _started = true;
    _talker.info('AutomationEngine started');
    _lastCheck = _clock().subtract(const Duration(minutes: 1));

    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => unawaited(_checkTimeTriggers()),
    );

    final detector = _presenceDetector;
    if (detector != null) {
      detector.onStatusChanged = _onPresenceChanged;
      detector.onCheckCompleted = _onPresenceCheckCompleted;
    }

    _warningController.setCancelHandler(_cancelUnknownWarningByUser);
  }

  // ─── ВРЕМЕННЫЕ ТРИГГЕРЫ ─────────────────────────────────────

  Future<void> _checkTimeTriggers() async {
    try {
      final now = _clock();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';

      final scenes = await _sceneRepository.getAllScenes();

      for (final scene in scenes) {
        final trigger = scene.trigger;
        if (trigger == null || trigger.type != TriggerType.time) continue;

        if (trigger.time == currentTime &&
            (_lastCheck == null || !_isSameMinute(_lastCheck!, now))) {
          _talker.info(
            'Executing time-triggered scene: ${scene.name} at $currentTime',
          );
          await _sceneRepository.executeScene(scene);
          await _sendSceneNotification(scene);
        }
      }

      _lastCheck = now;
    } catch (error, stackTrace) {
      _talker.error('Error checking time triggers', error, stackTrace);
    }
  }

  // ─── ИНДИВИДУАЛЬНЫЕ ТРИГГЕРЫ ПРИСУТСТВИЯ ────────────────────

  void _onPresenceChanged(
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      ) {
    unawaited(
      _processIndividualPresenceChange(phoneId, oldStatus, newStatus),
    );
  }

  void _onPresenceCheckCompleted(PresenceCycleResult result) {
    unawaited(_handlePresenceCycle(result));
  }

  Future<void> _processIndividualPresenceChange(
      String phoneId,
      PhonePresenceStatus oldStatus,
      PhonePresenceStatus newStatus,
      ) async {
    _talker.info('Presence changed: $phoneId $oldStatus → $newStatus');

    try {
      final scenes = await _sceneRepository.getAllScenes();

      for (final scene in scenes) {
        final trigger = scene.trigger;
        if (trigger == null ||
            trigger.type != TriggerType.presence ||
            trigger.presenceEvent == PresenceEvent.nobodyHome) {
          // nobodyHome обрабатывается только по полному снимку телефонов.
          continue;
        }

        if (!_matchPresenceEvent(trigger, phoneId, oldStatus, newStatus)) {
          continue;
        }
        if (!_matchPresenceChannel(trigger, phoneId)) continue;
        if (!_matchConditions(trigger)) continue;

        if (_isCooldown(scene.id, trigger)) {
          _talker.info('Scene ${scene.name}: cooldown is active');
          continue;
        }

        if (trigger.presenceDelayMin > 0) {
          _scheduleScene(scene, trigger.presenceDelayMin);
        } else {
          await _executeScene(scene);
        }
      }
    } catch (error, stackTrace) {
      _talker.error(
        'Error processing individual presence trigger',
        error,
        stackTrace,
      );
    }
  }

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
        return oldStatus != PhonePresenceStatus.home &&
            newStatus == PhonePresenceStatus.home;

      case PresenceEvent.nobodyHome:
        return false;

      case PresenceEvent.allHome:
        final phones = _presenceDetector?.phones.values;
        return phones != null &&
            phones.isNotEmpty &&
            phones.every(
                  (phone) => phone.status == PhonePresenceStatus.home,
            ) &&
            newStatus == PhonePresenceStatus.home;

      case PresenceEvent.phoneArrived:
        return trigger.presencePhoneId == phoneId &&
            oldStatus != PhonePresenceStatus.home &&
            newStatus == PhonePresenceStatus.home;

      case PresenceEvent.phoneLeft:
        return trigger.presencePhoneId == phoneId &&
            oldStatus == PhonePresenceStatus.home &&
            newStatus == PhonePresenceStatus.away;

      case PresenceEvent.phoneUnknown:
        return trigger.presencePhoneId == phoneId &&
            newStatus == PhonePresenceStatus.unknown;
    }
  }

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

  // ─── СЦЕНЫ «НИКОГО НЕТ ДОМА» ────────────────────────────────

  void _startOrCheckAllAwayEpisode(
      Scene scene,
      PresenceCycleResult result,
      ) {
    final sceneId = scene.id;

    if (_completedAllAwayEpisodes.contains(sceneId) ||
        _completedUnknownEpisodes.contains(sceneId) ||
        _cancelledUnknownEpisodes.contains(sceneId) ||
        _allAwayScheduling.contains(sceneId) ||
        _allAwayTimers.containsKey(sceneId)) {
      return;
    }

    final startedAt = _allAwaySince.putIfAbsent(sceneId, _clock);
    unawaited(_scheduleOrRunAllAwayScene(scene, result, startedAt));
  }

  Future<void> _scheduleOrRunAllAwayScene(
      Scene scene,
      PresenceCycleResult initialResult,
      DateTime startedAt,
      ) async {
    final sceneId = scene.id;
    if (_allAwayScheduling.contains(sceneId)) return;
    _allAwayScheduling.add(sceneId);

    try {
      final timeoutMinutes = await _readAwayTimeoutSafely();
      final timeout = Duration(minutes: timeoutMinutes);
      final elapsed = _clock().difference(startedAt);
      final remaining = timeout - elapsed;

      final latest = _lastPresenceCycle;
      if (latest == null ||
          !latest.cloudAvailable ||
          !latest.allAway ||
          latest.hasHome ||
          _clock().difference(latest.checkedAt) > _maxPresenceResultAge) {
        _cancelAllAwayScene(sceneId);
        return;
      }

      if (remaining <= Duration.zero) {
        await _executeAllAwaySceneIfStillValid(scene);
        return;
      }

      _talker.info(
        'Scene ${scene.name}: all phones away; '
            'waiting ${remaining.inSeconds}s',
      );

      _allAwayTimers[sceneId] = Timer(remaining, () {
        _allAwayTimers.remove(sceneId);
        unawaited(_executeAllAwaySceneIfStillValid(scene));
      });
    } finally {
      _allAwayScheduling.remove(sceneId);
    }
  }

  Future<void> _executeAllAwaySceneIfStillValid(Scene originalScene) async {
    final latest = _lastPresenceCycle;
    if (latest == null ||
        !latest.cloudAvailable ||
        !latest.allAway ||
        latest.hasHome ||
        _clock().difference(latest.checkedAt) > _maxPresenceResultAge) {
      _cancelAllAwayScene(originalScene.id);
      return;
    }

    try {
      final scenes = await _sceneRepository.getAllScenes();
      final scene = _findScene(scenes, originalScene.id);
      if (scene == null) {
        _cancelAllAwayScene(originalScene.id);
        return;
      }

      final trigger = scene.trigger;
      if (trigger == null ||
          trigger.type != TriggerType.presence ||
          trigger.presenceEvent != PresenceEvent.nobodyHome ||
          !_matchConditions(trigger) ||
          _isCooldown(scene.id, trigger)) {
        _cancelAllAwayScene(scene.id);
        return;
      }

      final current = _lastPresenceCycle;
      if (current == null ||
          !current.cloudAvailable ||
          !current.allAway ||
          current.hasHome ||
          _clock().difference(current.checkedAt) > _maxPresenceResultAge) {
        _cancelAllAwayScene(scene.id);
        return;
      }

      _completedAllAwayEpisodes.add(scene.id);
      _allAwaySince.remove(scene.id);

      _talker.info(
        'Executing nobody-home scene after away timeout: ${scene.name}',
      );
      await _executeScene(scene);
    } catch (error, stackTrace) {
      _talker.error('Error executing nobody-home scene', error, stackTrace);
    }
  }

  void _startOrUpdateUnknownWarning(
      List<Scene> scenes,
      PresenceCycleResult result,
      ) {
    if (scenes.isEmpty) {
      _cancelUnknownWarning(clearSuppression: true);
      return;
    }

    final sceneIds = scenes.map((scene) => scene.id).toSet();
    final unknownNames = result.unknownPhones
        .map((phone) => phone.phoneName)
        .toList(growable: false);

    if (_unknownWarningTimer != null) {
      _unknownWarningSceneIds = sceneIds;
      _updateWarningPhoneNames(result);
      return;
    }

    if (_unknownWarningSceneIds.isEmpty ||
        !_unknownWarningSceneIds.containsAll(sceneIds)) {
      _completedUnknownEpisodes.removeAll(sceneIds);
      _cancelledUnknownEpisodes.removeAll(sceneIds);
    }

    _unknownWarningSceneIds = sceneIds;
    _unknownWarningDeadline = _clock().add(presenceWarningDuration);

    final firstScene = scenes.first;
    _warningController.show(
      sceneId: firstScene.id,
      sceneName: firstScene.name,
      unknownPhoneNames: unknownNames,
      remainingSeconds: presenceWarningDuration.inSeconds,
    );

    _talker.warning(
      'Unknown presence detected; starting '
          '${presenceWarningDuration.inMinutes}-minute warning.',
    );

    _unknownWarningTimer = Timer.periodic(
      presenceWarningTickInterval,
          (_) => unawaited(_tickUnknownWarning()),
    );
  }

  Future<void> _tickUnknownWarning() async {
    if (_unknownWarningFinishing) return;

    final deadline = _unknownWarningDeadline;
    if (deadline == null) {
      _cancelUnknownWarning(clearSuppression: false);
      return;
    }

    final result = _lastPresenceCycle;
    if (!_isValidUnknownEpisode(result)) {
      _cancelUnknownWarning(clearSuppression: true);
      return;
    }

    final remaining = deadline.difference(_clock());
    if (remaining <= Duration.zero) {
      _unknownWarningFinishing = true;
      try {
        await _finishUnknownWarning();
      } finally {
        _unknownWarningFinishing = false;
      }
      return;
    }

    final seconds = remaining.inSeconds +
        (remaining.inMilliseconds % 1000 == 0 ? 0 : 1);
    _warningController.updateRemainingSeconds(seconds);
  }

  Future<void> _finishUnknownWarning() async {
    final result = _lastPresenceCycle;
    final sceneIds = Set<String>.of(_unknownWarningSceneIds);

    _stopUnknownWarningTimer();
    _warningController.clear();

    if (!_isValidUnknownEpisode(result)) {
      _unknownWarningSceneIds = {};
      return;
    }

    try {
      final scenes = await _sceneRepository.getAllScenes();

      for (final sceneId in sceneIds) {
        final scene = _findScene(scenes, sceneId);
        if (scene == null) continue;

        final trigger = scene.trigger;
        if (trigger == null ||
            trigger.type != TriggerType.presence ||
            trigger.presenceEvent != PresenceEvent.nobodyHome ||
            !_matchConditions(trigger) ||
            _isCooldown(scene.id, trigger)) {
          continue;
        }

        if (!_isValidUnknownEpisode(_lastPresenceCycle)) break;

        _completedUnknownEpisodes.add(scene.id);

        _talker.warning(
          'Executing nobody-home scene after unknown warning: '
              '${scene.name}',
        );
        await _executeScene(scene);
      }
    } catch (error, stackTrace) {
      _talker.error(
        'Error executing scene after presence warning',
        error,
        stackTrace,
      );
    } finally {
      _unknownWarningSceneIds = {};
      _unknownWarningDeadline = null;
    }
  }

  bool _isValidUnknownEpisode(PresenceCycleResult? result) {
    return result != null &&
        result.cloudAvailable &&
        !result.hasHome &&
        result.hasUnknown &&
        !result.allAway &&
        _clock().difference(result.checkedAt) <= _maxPresenceResultAge;
  }

  void _cancelUnknownWarning({
    required bool clearSuppression,
  }) {
    if (_unknownWarningTimer != null) {
      _stopUnknownWarningTimer();
      _warningController.clear();
    }

    // Автоматическое скрытие баннера не является пользовательской отменой.
    if (clearSuppression) {
      _cancelledUnknownEpisodes.clear();
    }

    _unknownWarningSceneIds = {};
    _unknownWarningDeadline = null;
  }

  void _cancelUnknownWarningByUser() {
    if (_unknownWarningTimer == null) return;

    _cancelledUnknownEpisodes.addAll(_unknownWarningSceneIds);
    _stopUnknownWarningTimer();
    _warningController.clear();

    _talker.info('Nobody-home warning cancelled by user');
  }

  void _stopUnknownWarningTimer() {
    _unknownWarningTimer?.cancel();
    _unknownWarningTimer = null;
    _unknownWarningDeadline = null;
  }

  void _updateWarningPhoneNames(PresenceCycleResult result) {
    if (_unknownWarningTimer == null) return;

    _warningController.updateUnknownPhoneNames(
      result.unknownPhones
          .map((phone) => phone.phoneName)
          .toList(growable: false),
    );
  }

  void _cancelAllAwayTimers({
    bool clearCompleted = false,
  }) {
    for (final timer in _allAwayTimers.values) {
      timer.cancel();
    }

    _allAwayTimers.clear();
    _allAwaySince.clear();
    _allAwayScheduling.clear();

    if (clearCompleted) {
      _completedAllAwayEpisodes.clear();
    }
  }

  void _cancelAllAwayTimersExcept(Set<String> keepSceneIds) {
    final removeIds = _allAwayTimers.keys
        .where((sceneId) => !keepSceneIds.contains(sceneId))
        .toList();

    for (final sceneId in removeIds) {
      _allAwayTimers.remove(sceneId)?.cancel();
      _allAwaySince.remove(sceneId);
      _completedAllAwayEpisodes.remove(sceneId);
    }
  }

  void _cancelAllAwayScene(String sceneId) {
    _allAwayTimers.remove(sceneId)?.cancel();
    _allAwaySince.remove(sceneId);
    _allAwayScheduling.remove(sceneId);
    _completedAllAwayEpisodes.remove(sceneId);
  }

  void _resetNobodyHomeState() {
    // Этот метод вызывается, когда подтверждён кто-то дома
    // или сцены «Никого нет дома» больше нет.
    _cancelUnknownWarning(clearSuppression: true);
    _cancelAllAwayTimers(clearCompleted: true);

    _cancelledUnknownEpisodes.clear();
    _completedUnknownEpisodes.clear();
  }

  void _pauseNobodyHomeState() {
    // Сбой облака или временная потеря пригодных данных прерывает активные
    // отсчёты, но не начинает новый эпизод и не снимает защиту от дублей.
    _cancelUnknownWarning(clearSuppression: false);
    _cancelAllAwayTimers();
  }

  Future<int> _readAwayTimeoutSafely() async {
    try {
      final minutes = await _awayTimeoutReader();
      return minutes < 0 ? 0 : minutes;
    } catch (error, stackTrace) {
      _talker.error(
        'Could not read away timeout; using 5 minutes',
        error,
        stackTrace,
      );
      return 5;
    }
  }

  static Future<int> _readAwayTimeoutMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('presence_away_timeout') ?? 5;
  }

  // ─── УСЛОВИЯ И ОБЫЧНЫЕ ОТЛОЖЕННЫЕ СЦЕНЫ ──────────────────

  bool _matchConditions(SceneTrigger trigger) {
    final conditions = trigger.presenceConditions;
    if (conditions == null) return true;

    final now = _clock();

    if (conditions.useTime) {
      final currentMin = now.hour * 60 + now.minute;
      final startMin = conditions.startHour * 60 + conditions.startMinute;
      final endMin = conditions.endHour * 60 + conditions.endMinute;

      if (startMin <= endMin) {
        if (currentMin < startMin || currentMin > endMin) return false;
      } else {
        // Интервал через полночь, например 22:00–06:00.
        if (currentMin < startMin && currentMin > endMin) return false;
      }
    }

    if (conditions.useDays &&
        !conditions.daysOfWeek.contains(now.weekday)) {
      return false;
    }

    // Проверка состояния устройства пока не подключена к DevicesNotifier.
    return true;
  }

  bool _isCooldown(String sceneId, SceneTrigger trigger) {
    final lastRun = _sceneLastRun[sceneId];
    if (lastRun == null) return false;

    return _clock().difference(lastRun).inMinutes <
        trigger.presenceCooldownMin;
  }

  void _scheduleScene(Scene scene, int delayMin) {
    _pendingScenes[scene.id]?.cancel();

    _pendingScenes[scene.id] = Timer(
      Duration(minutes: delayMin),
          () async {
        _pendingScenes.remove(scene.id);

        try {
          final scenes = await _sceneRepository.getAllScenes();
          final actualScene = _findScene(scenes, scene.id) ?? scene;
          final trigger = actualScene.trigger;

          if (trigger == null ||
              !_matchConditions(trigger) ||
              !_matchPresenceEventStillValid(actualScene)) {
            return;
          }

          await _executeScene(actualScene);
        } catch (error, stackTrace) {
          _talker.error('Error executing delayed scene', error, stackTrace);
        }
      },
    );

    _talker.info('Scene ${scene.name} scheduled in $delayMin minute(s)');
  }

  bool _matchPresenceEventStillValid(Scene scene) {
    final trigger = scene.trigger;
    if (trigger == null) return false;

    switch (trigger.presenceEvent) {
      case PresenceEvent.someoneHome:
        return _presenceDetector?.isAnyoneHome ?? false;

      case PresenceEvent.nobodyHome:
        return false;

      case PresenceEvent.allHome:
        final phones = _presenceDetector?.phones.values;
        return phones != null &&
            phones.isNotEmpty &&
            phones.every(
                  (phone) => phone.status == PhonePresenceStatus.home,
            );

      case PresenceEvent.phoneArrived:
        final phone = _presenceDetector?.phones[trigger.presencePhoneId];
        return phone?.status == PhonePresenceStatus.home;

      case PresenceEvent.phoneLeft:
        final phone = _presenceDetector?.phones[trigger.presencePhoneId];
        return phone?.status == PhonePresenceStatus.away;

      case PresenceEvent.phoneUnknown:
        final phone = _presenceDetector?.phones[trigger.presencePhoneId];
        return phone?.status == PhonePresenceStatus.unknown;

      case null:
        return false;
    }
  }

  Scene? _findScene(List<Scene> scenes, String sceneId) {
    for (final scene in scenes) {
      if (scene.id == sceneId) return scene;
    }
    return null;
  }

  Future<void> _executeScene(Scene scene) async {
    _sceneLastRun[scene.id] = _clock();
    _talker.info('Executing presence scene: ${scene.name}');

    await _sceneRepository.executeScene(scene);
    await _sendSceneNotification(scene);
  }

  Future<void> _sendSceneNotification(Scene scene) async {
    try {
      final shouldSend =
      await NotificationSettingsService.shouldSendSceneNotification();
      if (!shouldSend) return;

      final vk = VkNotificationService();
      await vk.loadSettings();
      await vk.sendSceneNotification(
        sceneName: scene.name,
        success: true,
      );
    } catch (error, stackTrace) {
      _talker.error('VK scene notification error', error, stackTrace);
    }
  }

  bool _isSameMinute(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day &&
        first.hour == second.hour &&
        first.minute == second.minute;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _started = false;

    final detector = _presenceDetector;
    if (detector != null) {
      detector.onStatusChanged = null;
      detector.onCheckCompleted = null;
    }

    for (final timer in _pendingScenes.values) {
      timer.cancel();
    }
    _pendingScenes.clear();

    _resetNobodyHomeState();
    _warningController.setCancelHandler(null);

    _talker.info('AutomationEngine stopped');
  }
}