/// Сервис синхронизации камер MyiSpy через MQTT
library;

import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../../domain/models/nvr_models.dart';
import '../../domain/repositories/device_repository.dart';
import 'mqtt_bridge.dart';
import '../../application/state/devices_provider.dart';
import '../../application/constants/debug_config.dart';

class IspySyncService {
  final DeviceRepository _deviceRepo;
  final Talker _talker;
  final DevicesNotifier _devicesNotifier;

  // Кэш хэшей конфигов (cameraId -> hash)
  final Map<int, String> _configHashes = {};

  IspySyncService({
    required DeviceRepository deviceRepo,
    required Talker talker,
    required DevicesNotifier devicesNotifier,  // ← НОВЫЙ ПАРАМЕТР
  })  : _deviceRepo = deviceRepo,
        _talker = talker,
        _devicesNotifier = devicesNotifier;

  /// Привязать MQTT мост и начать слушать события MyiSpy
  void attachMqttBridge(MqttBridge bridge) {

    // При получении конфига камеры — создаём/обновляем с проверкой хэша
    bridge.onIspyCameraConfig = (config) {
      _onIspyCameraConfig(config);
    };

    // При детекции YOLO — обновляем статус
    bridge.onIspyDetection = (event) {
      _onIspyDetection(event);
    };

    // При изменении статуса — обновляем онлайн
    bridge.onStatusEvent = (cameraId, isOnline) {
      _onStatusUpdate(cameraId, isOnline);
    };

    // При записи — обновляем статус записи
    bridge.onRecordingEvent = (cameraId, isRecording) {
      _onRecordingUpdate(cameraId, isRecording);
    };

    _talker.info('📡 IspySyncService привязан к MQTT мосту');
  }

  // ============================================================
  // 📡 КОНФИГ КАМЕРЫ (RTSP URL + хэш)
  // ============================================================

  void _onIspyCameraConfig(IspyCameraConfig config) {
    final cameraId = config.cameraId;
    final newHash = config.hash;

    // Проверяем — изменился ли конфиг?
    if (_configHashes.containsKey(cameraId) && _configHashes[cameraId] == newHash) {
      _talker.debug('📡 Конфиг камеры $cameraId не изменился (hash: $newHash), игнорируем');
      return;
    }

    // Сохраняем новый хэш
    if (newHash != null) {
      _configHashes[cameraId] = newHash;
    }

    _talker.info('📡 Обновлён конфиг камеры $cameraId: ${config.cameraName} (hash: $newHash)');

    // Создаём или обновляем камеру
    _upsertCameraFromConfig(config);
  }

  Future<void> _upsertCameraFromConfig(IspyCameraConfig config) async {
    try {
      final deviceId = 'ispy_${config.cameraId}';
      final devices = await _deviceRepo.getAllDevices();
      final existing = devices.firstWhereOrNull((d) => d.deviceId == deviceId);

      if (existing == null) {
        // Создаём новую камеру с RTSP URL
        final device = Device(
          id: 'ispy_${DateTime.now().millisecondsSinceEpoch}',
          name: config.cameraName,
          type: DeviceType.camera,
          roomId: 'other',
          isOnline: true,
          state: DeviceState.online,
          deviceId: deviceId,
          address: config.rtspUrl ?? 'rtsp',
          properties: {
            'cameraType': 'ispy',
            'cameraId': config.cameraId,
            'cameraName': config.cameraName,
            'rtspUrl': config.rtspUrl,
            'resolution': config.resolution,
            'fps': config.fps,
            'yoloEnabled': config.yoloEnabled,
            'hasMotion': false,
            'isRecording': false,
            'lastDetection': null,
            'lastDetectionTime': null,
            'snapshotAvailable': false,
          },
        );
        await _deviceRepo.saveDevice(device);
        _talker.info('✅ Создана камера MyiSpy: ${config.cameraName} (ID: ${config.cameraId})');
      } else {
        // Обновляем существующую (только если изменился хэш)
        final updated = existing.copyWith(
          name: config.cameraName,
          address: config.rtspUrl ?? existing.address,
          isOnline: true,
          properties: {
            ...existing.properties,
            'rtspUrl': config.rtspUrl,
            'resolution': config.resolution,
            'fps': config.fps,
            'yoloEnabled': config.yoloEnabled,
          },
        );
        await _deviceRepo.saveDevice(updated);
        _talker.debug('🔄 Обновлена камера MyiSpy: ${config.cameraName}');
      }
    } catch (e) {
      _talker.error('❌ Ошибка создания/обновления камеры из конфига', e);
    }
  }

  // ============================================================
  // 🧠 ДЕТЕКЦИЯ YOLO
  // ============================================================

  Future<void> _onIspyDetection(IspyDetectionEvent event) async {
    try {
      final deviceId = 'ispy_${event.cameraId}';
      final devices = await _deviceRepo.getAllDevices();
      final existing = devices.firstWhereOrNull((d) => d.deviceId == deviceId);

      if (existing == null) {
        // Камеры нет в БД — создаём базовую (без RTSP URL, ждём конфиг)
        final device = Device(
          id: 'ispy_${DateTime.now().millisecondsSinceEpoch}',
          name: event.cameraName,
          type: DeviceType.camera,
          roomId: 'other',
          isOnline: true,
          state: DeviceState.online,
          deviceId: deviceId,
          address: 'mqtt',
          properties: {
            'cameraType': 'ispy',
            'cameraId': event.cameraId,
            'cameraName': event.cameraName,
            'rtspUrl': null,  // Будет заполнено когда придёт конфиг
            'hasMotion': false,
            'isRecording': false,
            'lastDetection': event.objectsSummary,
            'lastDetectionTime': event.timestamp.toIso8601String(),
            'snapshotAvailable': event.snapshotAvailable,
          },
        );
        await _deviceRepo.saveDevice(device);
        _talker.info('✅ Добавлена камера MyiSpy (без RTSP): ${event.cameraName} (ID: ${event.cameraId})');
      } else {
        // Обновляем существующую
        final updated = existing.copyWith(
          isOnline: true,
          properties: {
            ...existing.properties,
            'lastDetection': event.objectsSummary,
            'lastDetectionTime': event.timestamp.toIso8601String(),
            'snapshotAvailable': event.snapshotAvailable,
          },
        );
        await _deviceRepo.saveDevice(updated);
        // === ОБНОВЛЯЕМ UI ===
        _devicesNotifier.updateOnlineState(existing.id, true); // Статус онлайн
        _devicesNotifier.updateDeviceProperties(existing.id, updated.properties); // Свойства
        // ====================

        _talker.debug('🔄 Обновлена камера MyiSpy: ${event.cameraName} → ${event.objectsSummary}');
      }
    } catch (e) {
      _talker.error('❌ Ошибка обработки детекции MyiSpy', e);
    }
  }

  // ============================================================
  // 📡 СТАТУС ОНЛАЙН
  // ============================================================

  Future<void> _onStatusUpdate(int cameraId, bool isOnline) async {
    try {
      final deviceId = 'ispy_$cameraId';
      final devices = await _deviceRepo.getAllDevices();
      final existing = devices.firstWhereOrNull((d) => d.deviceId == deviceId);

      if (existing != null) {
        final updated = existing.copyWith(
          isOnline: isOnline,
          state: isOnline ? DeviceState.online : DeviceState.offline,
        );
        await _deviceRepo.saveDevice(updated);

        // Обновляем UI напрямую!
        _devicesNotifier.updateOnlineState(existing.id, isOnline);
        if (DebugConfig.showDebug) {
        }

        _talker.debug('📡 MyiSpy Camera $cameraId: ${isOnline ? "ONLINE" : "OFFLINE"}');
      }
    } catch (e) {
      _talker.error('❌ Ошибка обновления статуса MyiSpy', e);
    }
  }

  // ============================================================
  // 📼 ЗАПИСЬ
  // ============================================================

  Future<void> _onRecordingUpdate(int cameraId, bool isRecording) async {
    try {
      final deviceId = 'ispy_$cameraId';
      final devices = await _deviceRepo.getAllDevices();
      final existing = devices.firstWhereOrNull((d) => d.deviceId == deviceId);

      if (existing != null) {
        final updated = existing.copyWith(
          properties: {
            ...existing.properties,
            'isRecording': isRecording,
          },
        );
        await _deviceRepo.saveDevice(updated);
        _talker.debug('📼 MyiSpy Camera $cameraId recording: $isRecording');
      }
    } catch (e) {
      _talker.error('❌ Ошибка обновления записи MyiSpy', e);
    }
  }
}

// Вспомогательный метод
extension FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}