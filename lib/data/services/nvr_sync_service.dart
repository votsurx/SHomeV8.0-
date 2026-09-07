/// Сервис синхронизации камер между LegionNVR и SHome
library;

import 'dart:async';
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../../domain/models/nvr_models.dart';
import '../../domain/repositories/device_repository.dart';
import 'nvr_api_client.dart';

class NvrSyncService {
  final DeviceRepository _deviceRepo;
  final Talker _talker;
  final NvrApiClient _apiClient;
  Timer? _timer;
  bool _isSyncing = false;

  NvrSyncService({
    required DeviceRepository deviceRepo,
    required Talker talker,
    required NvrApiClient apiClient,
  })  : _deviceRepo = deviceRepo,
        _talker = talker,
        _apiClient = apiClient;

  /// Запустить периодическую синхронизацию
  void start({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => sync());
    _talker.info('🔄 NVR Sync started (interval: ${interval.inSeconds}s)');
  }

  /// Остановить синхронизацию
  void stop() {
    _timer?.cancel();
    _timer = null;
    _talker.info('🔄 NVR Sync stopped');
  }

  /// Выполнить синхронизацию
  Future<void> sync() async {
    if (_isSyncing) {
      return;
    }
    _isSyncing = true;

    try {
      final isAlive = await _apiClient.isAlive();
      if (!isAlive) {
        _talker.warning('⚠️ NVR недоступен, синхронизация отложена');
        return;
      }

      _talker.debug('🔄 Syncing cameras from NVR...');

      final nvrCameras = await _apiClient.getCameras();
      final localDevices = await _deviceRepo.getAllDevices();

      // ============================================================
      // 1. ДОБАВЛЯЕМ НОВЫЕ КАМЕРЫ
      // ============================================================
      for (final nvrCam in nvrCameras) {
        final exists = localDevices.any(
              (d) => d.deviceId == 'nvr_${nvrCam.id}',
        );

        if (!exists) {
          final device = await _nvrToDevice(nvrCam);
          await _deviceRepo.saveDevice(device);
          _talker.info('✅ Добавлена камера: ${nvrCam.name} (ID: ${nvrCam.id})');
        }
      }

      // ============================================================
      // 2. ОБНОВЛЯЕМ СУЩЕСТВУЮЩИЕ
      // ============================================================
      // ✅ Объявляем localNvrDevices ЗДЕСЬ
      final localNvrDevices = localDevices
          .where((d) => d.properties['cameraType'] == 'nvr')
          .toList();

      for (final device in localNvrDevices) {
        final nvrId = device.properties['nvrId'] as int?;
        if (nvrId == null) continue;

        NvrCamera? nvrCam;
        for (final cam in nvrCameras) {
          if (cam.id == nvrId) {
            nvrCam = cam;
            break;
          }
        }

        if (nvrCam == null) {
          await _deviceRepo.deleteDevice(device.id);
          _talker.info('🗑️ Удалена камера: ${device.name} (ID: $nvrId)');
        } else {
          final updated = await _nvrToDevice(nvrCam);
          if (_hasChanges(device, updated)) {
            await _deviceRepo.saveDevice(updated);
            _talker.debug('🔄 Обновлена камера: ${nvrCam.name}');
          }
        }
      }

      _talker.debug('✅ NVR Sync complete (${nvrCameras.length} cameras)');
    } catch (e, stack) {
      _talker.error('❌ NVR Sync error', e, stack);
    } finally {
      _isSyncing = false;
    }
  }

  /// Преобразует NvrCamera в Device (SHome модель)
  Device _nvrToDevice(NvrCamera nvrCam) {
    // ✅ Просто используем enabled из NVR
    final isOnline = nvrCam.enabled;

    return Device(
      id: 'nvr_${nvrCam.id}',
      name: nvrCam.name,
      type: DeviceType.camera,
      roomId: 'other',
      isOnline: isOnline,
      state: isOnline ? DeviceState.online : DeviceState.offline,
      deviceId: 'nvr_${nvrCam.id}',
      address: _apiClient.host,
      properties: {
        'cameraType': 'nvr',
        'nvrId': nvrCam.id,
        'rtspUrl': nvrCam.rtspMain,
        'enabled': nvrCam.enabled,
        'streamEnabled': nvrCam.streamEnabled,
        'motionEnabled': nvrCam.motionEnabled,
        'recordEnabled': nvrCam.recordEnabled,
        'mjpegUrl': _apiClient.getMjpegUrl(nvrCam.id),
        'hlsUrl': _apiClient.getHlsUrl(nvrCam.id),
        'motionThreshold': nvrCam.motionThreshold,
        'motionCooldown': nvrCam.motionCooldown,
        'retentionDays': nvrCam.retentionDays,
        'locationId': nvrCam.locationId,
        'locationName': nvrCam.locationName,
        'hasMotion': false,
        'isRecording': false,
      },
    );
  }

  /// Проверяет, изменилось ли устройство
  bool _hasChanges(Device oldDevice, Device newDevice) {
    return oldDevice.name != newDevice.name ||
        oldDevice.isOnline != newDevice.isOnline ||
        oldDevice.properties['recordEnabled'] != newDevice.properties['recordEnabled'] ||
        oldDevice.properties['motionEnabled'] != newDevice.properties['motionEnabled'] ||
        oldDevice.properties['rtspUrl'] != newDevice.properties['rtspUrl'];
  }

  /// Принудительная синхронизация
  Future<void> syncNow() => sync();
}