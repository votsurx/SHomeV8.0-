/// Адаптивный опрос устройств — заменяет HeartbeatService и UdpListener.
/// Опрашивает все устройства параллельно через TuyaProtocol.getStatus().
/// Адаптивный интервал: 2с → 1мин → 5мин при ошибках.
/// Обнаруживает изменения состояния и обновляет UI через колбэки.
/// Поддерживает одноканальные, многоканальные устройства, датчики и робот-пылесос.
library;
import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../protocols/tuya_protocol.dart';
import 'event_logger.dart';
import '../../di/injection.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/models/scene.dart';
import '../../application/constants/debug_config.dart';
import '../../data/services/vk_notification_service.dart';
import '../../application/services/notification_settings_service.dart';

class AdaptivePoller {
  final TuyaProtocol _tuyaProtocol;
  final Talker _talker;
  final void Function(String deviceId, bool isOn) _onStateChanged;
  final void Function(String deviceId, bool isOnline) _onOnlineChanged;
  final void Function(String deviceId, List<bool> states) _onStatesChanged;
  final void Function(String deviceId, Map<String, dynamic> properties)? onSensorUpdate;

  static const slowInterval = Duration(minutes: 1);
  static const verySlowInterval = Duration(minutes: 5);
  static const maxErrorsBeforeSlowdown = 3;

  final Duration _normalInterval;
  final Map<String, _DevicePollState> _states = {};
  final Map<String, Completer<void>> _pollCompleters = {};
  Timer? _timer;
  List<Device> _devices = [];

  AdaptivePoller(
      this._tuyaProtocol,
      this._talker,
      this._onStateChanged,
      this._onOnlineChanged,
      this._onStatesChanged, {
        this.onSensorUpdate,
        Duration normalInterval = const Duration(seconds: 2),
      }) : _normalInterval = normalInterval;

  Future<void> pollOnce(String deviceId) {
    final completer = Completer<void>();
    _pollCompleters[deviceId] = completer;
    forceReset(deviceId);
    return completer.future;
  }

  void start() {
    _talker.info('AdaptivePoller started (interval: ${_normalInterval.inSeconds}s)');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    _tick();
  }

  void updateDevices(List<Device> devices) {
    _devices = devices;
    _states.removeWhere((id, _) => !devices.any((d) => d.id == id));
  }

  void forceReset(String deviceId) {
    final state = _states[deviceId];
    if (state != null) {
      state.reset();
    }
  }

  void _tick() {
    final now = DateTime.now();
    for (final device in _devices) {
      final cameraType = device.properties['cameraType'] as String? ?? '';

      // ✅ Пропускаем NVR-камеры (LegionNVR)
      if (cameraType == 'nvr') continue;

      // ✅ Пропускаем MyiSpy камеры (обновляются через MQTT)
      if (cameraType == 'ispy') continue;

      // ✅ Пропускаем RTSP камеры
      if (cameraType == 'rtsp') continue;

      // ✅ Пропускаем MJPEG камеры
      if (cameraType == 'mjpeg') continue;

      if (device.deviceId == null || device.address == null) continue;
      final state = _states.putIfAbsent(device.id, () => _DevicePollState(_normalInterval));
      if (now.isAfter(state.nextPollAt)) {
        _pollDevice(device, state);
      }
    }
  }

  void _updateDeviceInList(Device updated) {
    final idx = _devices.indexWhere((d) => d.id == updated.id);
    if (idx != -1) _devices[idx] = updated;
  }

  Future<void> _pollDevice(Device device, _DevicePollState state) async {
    if (state.polling) return;
    state.polling = true;

    try {
      final result = await _tuyaProtocol.getStatus(device);
      if (DebugConfig.showDebug) {
        _talker.debug('Status result for ${device.name}: $result');
      }

      if (result != null && result['dps'] != null) {
        state.onSuccess();
        _onOnlineChanged(device.id, true);
        final isFirstPoll = !state.firstPollDone;
        if (isFirstPoll) {
          state.firstPollDone = true;
        }

        final dps = result['dps'] as Map<String, dynamic>;

        // --- Составные устройства (dps_map) ---
        final dpsMap = device.properties['dps_map'] as Map<String, dynamic>?;
        if (dpsMap != null && dpsMap.isNotEmpty) {
          final newProperties = <String, dynamic>{...device.properties};

          dpsMap.forEach((key, config) {
            final cfg = config as Map<String, dynamic>;
            final type = cfg['type'] as String? ?? 'value';
            final propKey = 'dps_$key';

            final raw = dps[key] ?? dps[key.toString()];

            if (raw == null) return;

            switch (type) {
              case 'bool':
                newProperties[propKey] = raw == true || raw == 1;
                break;
              case 'value':
              case 'slider':
                final divider = (cfg['divider'] as num?)?.toDouble() ?? 1.0;
                final numValue = raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0.0;
                newProperties[propKey] = divider > 1 ? numValue / divider : numValue;
                break;
              case 'enum':
                newProperties[propKey] = raw.toString();
                break;
            }
          });

          // Синхронизируем isOn с dps_1 если есть
          if (newProperties.containsKey('dps_1')) {
            newProperties['isOn'] = newProperties['dps_1'];
          }

          final updated = device.copyWith(properties: newProperties);
          _updateDeviceInList(updated);
          onSensorUpdate?.call(device.id, newProperties);
          // Отправляем уведомление об изменениях
          if (!isFirstPoll) {
            await _sendCompoundChangesNotification(device, newProperties);
          }
        }

        // --- Многоканальные устройства ---
        final channels = device.properties['channels'] as int?
            ?? (device.type == DeviceType.switch3 ? 3
                : device.type == DeviceType.switch2 ? 2
                : null);
        if (channels != null && channels > 1) {
          final currentStates = List<bool>.from(device.properties['states'] ?? List.filled(channels, false));
          var changed = false;

          for (var i = 1; i <= channels; i++) {
            final val = dps['$i'];
            if (val != null) {
              final isOn = val == true || val == 1;
              if (i - 1 < currentStates.length && currentStates[i - 1] != isOn) {
                currentStates[i - 1] = isOn;
                changed = true;
              }
            }
          }

          if (changed) {
            final updatedDevice = device.copyWith(
              properties: {...device.properties, 'states': currentStates, 'isOn': currentStates.any((s) => s)},
            );
            _updateDeviceInList(updatedDevice);
            _talker.info('Multi-channel state changed: $currentStates');
            _onStatesChanged(device.id, currentStates);
            if (!isFirstPoll) {
              await _sendMultiChannelNotification(device, currentStates);
            }
          }
        } else if (device.type != DeviceType.compound) {
          // --- Одноканальные устройства (кроме универсальных устройств) ---
          final dpsIndex = device.dpsIndex ?? 1;
          final rawValue = dps['$dpsIndex'];

          if (rawValue != null) {
            final realIsOn = rawValue == true || rawValue == 1;
            final currentIsOn = device.properties['isOn'] == true;

            if (realIsOn != currentIsOn) {
              _onStateChanged(device.id, realIsOn);
              if (!isFirstPoll) {
                await _sendSimpleDeviceNotification(
                  device,
                  realIsOn ? 'Включено' : 'Выключено',
                  true,
                );
              }
              try {
                EventLogger.log(deviceId: device.id, deviceName: device.name, event: realIsOn ? 'turnOn' : 'turnOff');
              } catch (_) {}
            }
          }
          // --- Датчики ---
          if (device.type == DeviceType.sensor) {
            final sensorDps = device.properties['sensorDps'] ?? device.dpsIndex ?? 21;
            final divider = (device.properties['sensorDivider'] as num?)?.toDouble() ?? 10.0;
            final sensorType = device.properties['sensorType'] as String?;
            final rawSensorValue = dps[sensorDps] ?? dps[sensorDps.toString()];

            if (rawSensorValue != null) {
              final value = (rawSensorValue as num).toDouble() / divider;

              final updatedProperties = {
                ...device.properties,
                if (sensorType == 'temperature') 'temperature': value,
                if (sensorType == 'humidity') 'humidity': value,
                if (sensorType == 'power') 'power': value,
                if (sensorType == 'current') 'current': value,
                if (sensorType == 'voltage') 'voltage': value,
              };

              final updated = device.copyWith(properties: updatedProperties);
              _updateDeviceInList(updated);
              onSensorUpdate?.call(device.id, updatedProperties);
              _checkSensorTriggers(device, dps);
            }
          }
        }
      } else {
        state.onError();
        _onOnlineChanged(device.id, false);
      }
    } catch (e) {
      state.onError();
      _onOnlineChanged(device.id, false);
    } finally {
      state.polling = false;
      _pollCompleters.remove(device.id)?.complete();
    }
  }

  void stop() => _timer?.cancel();
}

Future<void> _sendMultiChannelNotification(
    Device device,
    List<bool> states,
    ) async {
  try {
    final shouldSend = await NotificationSettingsService.shouldSendDeviceNotification();
    if (!shouldSend) return;

    final changes = <String, String>{};
    for (var i = 0; i < states.length; i++) {
      changes['Канал ${i + 1}'] = states[i] ? 'Включен' : 'Выключен';
    }

    final vk = VkNotificationService();
    await vk.loadSettings();
    await vk.sendCompoundNotification(
      deviceName: device.name,
      changes: changes,
    );
  } catch (e) {
    getIt<Talker>().error('VK multi-channel notification error', e);
  }
}

Future<void> _sendSimpleDeviceNotification(
    Device device,
    String action,
    bool success,
    ) async {
  try {
    final shouldSend = await NotificationSettingsService.shouldSendDeviceNotification();
    if (!shouldSend) return;

    final vk = VkNotificationService();
    await vk.loadSettings();
    await vk.sendDeviceNotification(
      deviceName: device.name,
      action: action,
      success: success,
    );
  } catch (e) {
    getIt<Talker>().error('VK device notification error', e);
  }
}

Future<void> _sendCompoundChangesNotification(
    Device device,
    Map<String, dynamic> newProperties,
    ) async {
  try {
    final shouldSend = await NotificationSettingsService.shouldSendDeviceNotification();
    if (!shouldSend) return;

    final dpsMap = device.properties['dps_map'] as Map<String, dynamic>? ?? {};
    final changes = <String, String>{};

    dpsMap.forEach((key, config) {
      final cfg = config as Map<String, dynamic>;
      final role = cfg['role'] ?? '';
      if (role == 'info' || role == 'status') return;

      final label = cfg['label'] ?? 'DPS $key';
      final oldValue = device.properties['dps_$key']?.toString() ?? '';
      final newValue = newProperties['dps_$key']?.toString() ?? '';
      if (oldValue != newValue) {
        changes[label] = newValue;
      }
    });

    if (changes.isNotEmpty) {
      final vk = VkNotificationService();
      await vk.loadSettings();
      await vk.sendCompoundNotification(
        deviceName: device.name,
        changes: changes,
      );
    }
  } catch (e) {
    getIt<Talker>().error('VK compound notification error', e);
  }
}

Future<void> _checkSensorTriggers(Device sensorDevice, Map<String, dynamic> dps) async {
  try {
    final sceneRepo = getIt<SceneRepository>();
    final scenes = await sceneRepo.getAllScenes();

    final tempDps = sensorDevice.properties['sensorDps'] ?? sensorDevice.dpsIndex ?? 21;
    final divider = sensorDevice.properties['sensorDivider'] ?? 10;
    final rawValue = dps[tempDps] ?? dps[tempDps.toString()];

    if (rawValue == null) return;

    final currentValue = (rawValue as num).toDouble() / divider;
    final sensorType = sensorDevice.properties['sensorType'] as String?;
    final now = DateTime.now();

    for (final scene in scenes) {
      final trigger = scene.trigger;
      if (trigger == null ||
          trigger.sensorDeviceId != sensorDevice.id ||
          trigger.type != TriggerType.deviceState) {
        continue;
      }

      bool shouldExecute = false;

      if (sensorType == 'temperature' || (trigger.sensorCondition?.contains('temperature') ?? false)) {
        if (trigger.sensorCondition == 'temperature_above' && currentValue > (trigger.sensorThreshold ?? 30)) {
          shouldExecute = true;
        } else if (trigger.sensorCondition == 'temperature_below' && currentValue < (trigger.sensorThreshold ?? 18)) {
          shouldExecute = true;
        }
      } else if (sensorType == 'humidity' || (trigger.sensorCondition?.contains('humidity') ?? false)) {
        if (trigger.sensorCondition == 'humidity_above' && currentValue > (trigger.sensorThreshold ?? 80)) {
          shouldExecute = true;
        } else if (trigger.sensorCondition == 'humidity_below' && currentValue < (trigger.sensorThreshold ?? 40)) {
          shouldExecute = true;
        }
      }

      if (shouldExecute) {
        final lastExecuted = trigger.lastExecuted != null ? DateTime.tryParse(trigger.lastExecuted!) : null;
        if (lastExecuted == null || now.difference(lastExecuted).inMinutes >= 5) {
          final talker = getIt<Talker>();
          talker.info('Sensor trigger activated: ${scene.name} (value: $currentValue, threshold: ${trigger.sensorThreshold})');
          await sceneRepo.executeScene(scene);

          // Отправляем VK-уведомление
          await _sendSceneNotification(scene);

          final updatedScene = scene.copyWith(
            trigger: scene.trigger?.copyWith(lastExecuted: now.toIso8601String()),
          );
          await sceneRepo.saveScene(updatedScene);
        }
      }
    }
  } catch (e, stackTrace) {
    final talker = getIt<Talker>();
    talker.error('Error checking sensor triggers', e, stackTrace);
  }
}
Future<void> _sendSceneNotification(Scene scene) async {
  try {
    final shouldSend = await NotificationSettingsService.shouldSendSceneNotification();
    if (shouldSend) {
      final vk = VkNotificationService();
      await vk.loadSettings();
      await vk.sendSceneNotification(sceneName: scene.name, success: true);
    }
  } catch (e) {
    getIt<Talker>().error('VK scene notification error', e);
  }
}

class _DevicePollState {
  int errorCount = 0;
  Duration interval;
  final Duration _normalInterval;
  DateTime nextPollAt = DateTime.now();
  bool polling = false;
  bool firstPollDone = false;

  _DevicePollState(Duration normalInterval)
      : interval = normalInterval,
        _normalInterval = normalInterval;

  void onSuccess() {
    errorCount = 0;
    interval = _normalInterval;
    nextPollAt = DateTime.now().add(interval);
  }

  void onError() {
    errorCount++;
    if (errorCount >= AdaptivePoller.maxErrorsBeforeSlowdown * 2) {
      interval = AdaptivePoller.verySlowInterval;
    } else if (errorCount >= AdaptivePoller.maxErrorsBeforeSlowdown) {
      interval = AdaptivePoller.slowInterval;
    }
    nextPollAt = DateTime.now().add(interval);
  }

  void reset() {
    errorCount = 0;
    interval = _normalInterval;
    nextPollAt = DateTime.now();
    polling = false;
    firstPollDone = false;
  }
}