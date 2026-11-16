/// Точка входа в приложение.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

import 'data/services/heartbeat_server.dart';
import 'di/injection.dart';
import 'domain/models/device.dart';
import 'domain/models/frigate_models.dart';
import 'domain/models/room.dart';
import 'domain/models/scene.dart';
import 'domain/repositories/room_repository.dart';
import 'domain/repositories/scene_repository.dart';
import 'data/services/automation_engine.dart';
import 'data/services/timer_engine.dart';
import 'data/services/event_logger.dart';
import 'data/services/notification_coordinator.dart';
import 'app.dart';
import 'application/state/theme_provider.dart';
import 'application/state/notification_settings_provider.dart';
import 'application/state/sms_settings_provider.dart';
import 'domain/services/mqtt_service_interface.dart';
import 'data/services/zigbee_bridge.dart';
import 'data/services/frigate_bridge.dart';
import 'data/services/frigate_service.dart';
import 'data/local/secure_storage/encrypted_keys.dart';
import 'application/state/devices_provider.dart';
import 'di/global_container.dart';
import 'data/services/stats_aggregator.dart';

/// Глобальный доступ к MQTT сервису (для Zigbee и Frigate)
MqttService? globalMqttService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StatsAggregator.instance.backfillIfNeeded();
  configureDependencies();
  ThemeNotifier.updateAutoCache();

  final serverStarted = await HeartbeatServer.start(port: 7777);
  if (serverStarted) {
    getIt<Talker>().info('📡 HeartbeatServer готов к приёму');
  }

  getIt<TimerEngine>().start();
  getIt<AutomationEngine>().start();

  _addDefaultRooms();

  runApp(
    UncontrolledProviderScope(
      container: globalContainer,
      child: SHomeAppObserver(child: SHomeApp()),
    ),
  );
}

class SHomeAppObserver extends StatefulWidget {
  final Widget child;
  const SHomeAppObserver({required this.child, super.key});

  @override
  State<SHomeAppObserver> createState() => _SHomeAppObserverState();
}

class _SHomeAppObserverState extends State<SHomeAppObserver> {
  Timer? _themeTimer;
  final NotificationCoordinator _notifier = NotificationCoordinator();
  // 🆕 Время старта — игнорируем availability в первые 10 секунд
  final DateTime _startTime = DateTime.now();
  static const _startupGracePeriod = Duration(seconds: 10);

  bool get _isStartupGrace => DateTime.now().difference(_startTime) < _startupGracePeriod;

  @override
  void initState() {
    super.initState();
    _startAutoThemeTimer();
    _connectMqtt();
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    HeartbeatServer.stop();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // АВТОТЕМА
  // ═══════════════════════════════════════════════════════════

  void _startAutoThemeTimer() {
    _themeTimer =
        Timer.periodic(const Duration(minutes: 1), (_) => _checkAutoTheme());
    _checkAutoTheme();
  }

  void _checkAutoTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('auto_theme') ?? false;
    if (!auto) return;

    final hour = DateTime.now().hour;
    final newMode = (hour >= 6 && hour < 18) ? 'light' : 'dark';

    final currentMode = prefs.getString('theme_mode') ?? 'dark';
    if (newMode != currentMode) {
      await prefs.setString('theme_mode', newMode);
      ThemeNotifier.updateAutoCache();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // MQTT + ZIGBEE + FRIGATE
  // ═══════════════════════════════════════════════════════════

  Future<void> _connectMqtt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mqttHost = prefs.getString('mqtt_host') ?? '';
      final mqttPortRaw = prefs.get('mqtt_port');
      final mqttPort = mqttPortRaw is int
          ? mqttPortRaw
          : int.tryParse(mqttPortRaw?.toString() ?? '') ?? 1883;

      if (mqttHost.isEmpty) {
        getIt<Talker>().info('⚠️ MQTT host не настроен — пропускаем');
        return;
      }

      final service = getIt<MqttService>();
      await service.connect(mqttHost, port: mqttPort);
      getIt<Talker>().info('✅ MQTT подключён: $mqttHost:$mqttPort');

      // ═══════════════════════════════════════════════════════════
      // 🐝 ZIGBEE
      // ═══════════════════════════════════════════════════════════
      final zigbeeBridge = getIt<ZigbeeBridge>();

      getIt<Talker>().info('🐝 ZigbeeBridge запущен');

      zigbeeBridge.onState = (friendlyName, newState) {
        _updateZigbeeDeviceState(friendlyName, newState);
      };

      zigbeeBridge.onAvailability = (friendlyName, isOnline) {
        _updateZigbeeAvailability(friendlyName, isOnline);
      };
      await zigbeeBridge.start();

      getIt<Talker>().info('🐝 onState + onAvailability привязаны');

      // ═══════════════════════════════════════════════════════════
      // 🎥 FRIGATE
      // ═══════════════════════════════════════════════════════════
      final frigateBridge = getIt<FrigateBridge>();
      await frigateBridge.start();
      getIt<Talker>().info('🎥 FrigateBridge запущен');

      frigateBridge.onEvent = (event) {
        _onFrigateEvent(event);
      };
      getIt<Talker>().info('🎥 onEvent привязан');

      final frigateHost = prefs.getString('frigate_host') ?? mqttHost;
      final frigatePort = prefs.getInt('frigate_port') ?? 5000;
      final rtspPassword =
          await EncryptedKeys().getFrigateRtspPassword() ?? '';

      final frigateService = getIt<FrigateService>();
      frigateService.configure(
        host: frigateHost,
        port: frigatePort,
        rtspPassword: rtspPassword,
      );
      getIt<Talker>()
          .info('🎥 FrigateService настроен: $frigateHost:$frigatePort');
    } catch (e) {
      getIt<Talker>().error('❌ MQTT init error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ZIGBEE STATE
  // ═══════════════════════════════════════════════════════════

  void _updateZigbeeDeviceState(
      String friendlyName,
      Map<String, dynamic> newState,
      ) {
    debugPrint('🐝 onState: $friendlyName → ${newState.keys.join(", ")}');
    try {
      final devicesNotifier = globalContainer.read(devicesProvider.notifier);
      final devices = globalContainer.read(devicesProvider);

      final device = devices
          .where((d) =>
      d.properties['source'] == 'zigbee' &&
          d.properties['friendly_name'] == friendlyName)
          .firstOrNull;

      if (device == null) {
        getIt<Talker>().debug(
          '🐝 onState для "$friendlyName" пропущен — устройство не добавлено в SHome',
        );
        return;
      }

      // 🆕 Логируем алерты ДО обновления properties,
      // чтобы сравнить old vs new (prevProps — старые)
      _logZigbeeAlerts(device, newState);

      final updatedProperties = <String, dynamic>{
        ...device.properties,
        ...newState,
        'last_seen': DateTime.now().toIso8601String(),
      };

      final updatedDevice = device.copyWith(
        properties: updatedProperties,
        isOnline: true,
        state: DeviceState.online,
      );

      devicesNotifier.updateDeviceLocal(updatedDevice);

      _checkZigbeeSensorTriggers(updatedDevice, newState);

      getIt<Talker>().debug(
        '🐝 onState: $friendlyName → ${newState.keys.join(", ")}',
      );
    } catch (e, st) {
      getIt<Talker>().error('❌ Zigbee state error: $friendlyName', e, st);
    }
  }

  void _updateZigbeeAvailability(String friendlyName, bool isOnline) {
    debugPrint('🐝 availability: $friendlyName → $isOnline');
    try {
      final devicesNotifier = globalContainer.read(devicesProvider.notifier);
      final devices = globalContainer.read(devicesProvider);

      // Устройство не добавлено в SHome — пропускаем тихо
      final device = devices
          .where((d) =>
      d.properties['source'] == 'zigbee' &&
          d.properties['friendly_name'] == friendlyName)
          .firstOrNull;

      if (device == null) {
        getIt<Talker>().debug(
          '🐝 Availability для "$friendlyName" пропущен — устройство не добавлено в SHome',
        );
        return;
      }

      final wasOnline = device.isOnline;

      // Защита: не помечаем offline, если недавно было onState (< 2ч)
      if (!isOnline) {
        final lastSeen = device.properties['last_seen'] as String?;
        if (lastSeen != null) {
          final lastSeenDt = DateTime.tryParse(lastSeen);
          if (lastSeenDt != null &&
              DateTime.now().difference(lastSeenDt).inHours < 2) {
            getIt<Talker>().debug(
              '🐝 availability/offline игнорируется для $friendlyName '
                  '(last_seen < 2ч)',
            );
            return;
          }
        }
      }

      final updatedDevice = device.copyWith(
        isOnline: isOnline,
        state: isOnline ? DeviceState.online : DeviceState.offline,
      );

      devicesNotifier.updateDeviceLocal(updatedDevice);

      // Логируем только при изменении И не в первые 10 секунд после старта
      if (wasOnline != isOnline && !_isStartupGrace) {
        EventLogger.log(
          event: isOnline ? 'online' : 'offline',
          deviceId: device.id,
          deviceName: device.name,
        );

        if (!isOnline) {
          final vkSettings = globalContainer.read(notificationSettingsProvider);
          final smsSettings = globalContainer.read(smsSettingsProvider);

          _notifier.notifyDevice(
            device: updatedDevice,
            type: 'offline',
            title: '📡 Устройство offline',
            message: device.name,
            vkSettings: vkSettings,
            smsSettings: smsSettings,
          );
        }
      } else if (wasOnline != isOnline && _isStartupGrace) {
        getIt<Talker>().debug(
          '🐝 Availability: $friendlyName → ${isOnline ? "online" : "offline"} '
              '(startup grace — без события)',
        );
      }

      getIt<Talker>().info(
        '🐝 Availability: $friendlyName → ${isOnline ? "online" : "offline"}',
      );
    } catch (e, st) {
      getIt<Talker>().error('❌ Availability error: $friendlyName', e, st);
    }
  }

  /// Логирует алерты Zigbee-датчиков в журнал НЕЗАВИСИМО от сцен.
  /// Вызывается при каждом onState.
  void _logZigbeeAlerts(Device device, Map<String, dynamic> newState) {
    try {
      final prevProps = device.properties;

      // water_leak: true → alarm_water_leak
      if (newState['water_leak'] == true &&
          prevProps['water_leak'] != true) {
        EventLogger.log(
          event: 'alarm_water_leak',
          deviceId: device.id,
          deviceName: device.name,
          value: 'Протечка',
        );
      }

      // smoke
      if (newState['smoke'] == true && prevProps['smoke'] != true) {
        EventLogger.log(
          event: 'alarm_smoke',
          deviceId: device.id,
          deviceName: device.name,
          value: 'Дым',
        );
      }

      // gas
      if (newState['gas'] == true && prevProps['gas'] != true) {
        EventLogger.log(
          event: 'alarm_gas',
          deviceId: device.id,
          deviceName: device.name,
          value: 'Газ',
        );
      }

      // motion / occupancy
      final motion = newState['occupancy'] ?? newState['motion'];
      final prevMotion = prevProps['occupancy'] ?? prevProps['motion'];
      if (motion == true && prevMotion != true) {
        EventLogger.log(
          event: 'alarm_motion',
          deviceId: device.id,
          deviceName: device.name,
          value: 'Движение',
        );
      }

      // contact: false → open, true → closed
      if (newState.containsKey('contact')) {
        final isOpen = newState['contact'] == false;
        final prevIsOpen = prevProps['contact'] == false;

        if (isOpen && !prevIsOpen) {
          EventLogger.log(
            event: 'alarm_contact_open',
            deviceId: device.id,
            deviceName: device.name,
            value: 'Открыто',
          );
        } else if (!isOpen && prevIsOpen) {
          EventLogger.log(
            event: 'alarm_contact_closed',
            deviceId: device.id,
            deviceName: device.name,
            value: 'Закрыто',
          );
        }
      }

      // temperature thresholds (если заданы в настройках датчика)
      final temp = newState['temperature'];
      if (temp is num) {
        final above = (prevProps['threshold_temperature_above'] as num?)?.toDouble();
        final below = (prevProps['threshold_temperature_below'] as num?)?.toDouble();
        final prevTemp = (prevProps['temperature'] as num?)?.toDouble();

        if (above != null && temp > above &&
            (prevTemp == null || prevTemp <= above)) {
          EventLogger.log(
            event: 'alarm_temperature_above',
            deviceId: device.id,
            deviceName: device.name,
            value: '${temp.toStringAsFixed(1)}°C',
          );
        }
        if (below != null && temp < below &&
            (prevTemp == null || prevTemp >= below)) {
          EventLogger.log(
            event: 'alarm_temperature_below',
            deviceId: device.id,
            deviceName: device.name,
            value: '${temp.toStringAsFixed(1)}°C',
          );
        }
      }
      // humidity thresholds
      final humidity = newState['humidity'];
      if (humidity is num) {
        final aboveH = (prevProps['threshold_humidity_above'] as num?)?.toDouble();
        final belowH = (prevProps['threshold_humidity_below'] as num?)?.toDouble();
        final prevHum = (prevProps['humidity'] as num?)?.toDouble();

        if (aboveH != null && humidity > aboveH &&
            (prevHum == null || prevHum <= aboveH)) {
          EventLogger.log(
            event: 'alarm_humidity_above',
            deviceId: device.id,
            deviceName: device.name,
            value: '${humidity.toStringAsFixed(1)}%',
          );
        }
        if (belowH != null && humidity < belowH &&
            (prevHum == null || prevHum >= belowH)) {
          EventLogger.log(
            event: 'alarm_humidity_below',
            deviceId: device.id,
            deviceName: device.name,
            value: '${humidity.toStringAsFixed(1)}%',
          );
        }
      }
    } catch (e, st) {
      getIt<Talker>().error('❌ logZigbeeAlerts error', e, st);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ZIGBEE TRIGGERS
  // ═══════════════════════════════════════════════════════════

  Future<void> _checkZigbeeSensorTriggers(
      Device sensorDevice,
      Map<String, dynamic> newState,
      ) async {
    try {
      final sceneRepo = getIt<SceneRepository>();
      final scenes = await sceneRepo.getAllScenes();
      final now = DateTime.now();

      for (final scene in scenes) {
        final trigger = scene.trigger;
        if (trigger == null ||
            trigger.type != TriggerType.deviceState ||
            trigger.sensorDeviceId != sensorDevice.id) {
          continue;
        }

        bool shouldExecute = false;
        final condition = trigger.sensorCondition;

        switch (condition) {
          case 'water_leak':
            shouldExecute = newState['water_leak'] == true;
            break;
          case 'motion':
            shouldExecute = newState['motion'] == true;
            break;
          case 'contact_open':
            shouldExecute = newState['contact'] == false;
            break;
          case 'contact_closed':
            shouldExecute = newState['contact'] == true;
            break;
          case 'smoke':
            shouldExecute = newState['smoke'] == true;
            break;
          case 'gas':
            shouldExecute = newState['gas'] == true;
            break;
          case 'temperature_above':
            final temp = newState['temperature'];
            if (temp is num) {
              shouldExecute = temp > (trigger.sensorThreshold ?? 30);
            }
            break;
          case 'temperature_below':
            final temp = newState['temperature'];
            if (temp is num) {
              shouldExecute = temp < (trigger.sensorThreshold ?? 18);
            }
            break;
          case 'humidity_above':
            final hum = newState['humidity'];
            if (hum is num) {
              shouldExecute = hum > (trigger.sensorThreshold ?? 80);
            }
            break;
          case 'humidity_below':
            final hum = newState['humidity'];
            if (hum is num) {
              shouldExecute = hum < (trigger.sensorThreshold ?? 40);
            }
            break;
        }

        if (shouldExecute) {
          final lastExecuted = trigger.lastExecuted != null
              ? DateTime.tryParse(trigger.lastExecuted!)
              : null;
          if (lastExecuted != null &&
              now.difference(lastExecuted).inMinutes < 5) {
            continue;
          }

          await EventLogger.log(
            event: 'alarm_$condition',
            deviceId: sensorDevice.id,
            deviceName: sensorDevice.name,
            value: condition,
          );

          getIt<Talker>().info(
            '🐝 Zigbee trigger: ${scene.name} (${sensorDevice.name} → $condition)',
          );

          await sceneRepo.executeScene(scene);

          // ✅ Уведомления — через Coordinator
          final vkSettings = globalContainer.read(notificationSettingsProvider);
          final smsSettings = globalContainer.read(smsSettingsProvider);

          _notifier.notifyDevice(
            device: sensorDevice,
            type: condition ?? '',
            title: _zigbeeConditionLabel(condition ?? ''),
            message: sensorDevice.name,
            vkSettings: vkSettings,
            smsSettings: smsSettings,
          );

          final updatedScene = scene.copyWith(
            trigger: scene.trigger?.copyWith(
              lastExecuted: now.toIso8601String(),
            ),
          );
          await sceneRepo.saveScene(updatedScene);
        }
      }
    } catch (e, st) {
      getIt<Talker>().error('❌ Zigbee trigger error', e, st);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FRIGATE EVENTS
  // ═══════════════════════════════════════════════════════════

  void _onFrigateEvent(FrigateEvent event) {
    try {
      if (!event.isActive) return;

      EventLogger.log(
        event: 'frigate_${event.label}',
        deviceId: 'frigate_${event.camera}',
        deviceName: event.camera,
        value: '${event.label} (${(event.score * 100).toStringAsFixed(0)}%)',
      );

      getIt<Talker>().info(
        '🎥 Frigate: ${event.camera} → ${event.label} (${(event.score * 100).toStringAsFixed(0)}%)',
      );

      // ✅ Уведомления — через Coordinator
      final devices = globalContainer.read(devicesProvider);
      final camera = devices.where((d) =>
      d.properties['source'] == 'frigate' &&
          d.properties['camera_name'] == event.camera).firstOrNull;

      if (camera == null) return;

      final vkSettings = globalContainer.read(notificationSettingsProvider);
      final smsSettings = globalContainer.read(smsSettingsProvider);

      _notifier.notifyFrigateEvent(
        camera: camera,
        event: event,
        vkSettings: vkSettings,
        smsSettings: smsSettings,
      );
    } catch (e) {
      getIt<Talker>().error('❌ Frigate event error', e);
    }
  }

  String _zigbeeConditionLabel(String condition) {
    switch (condition) {
      case 'water_leak':
        return '💧 Протечка';
      case 'smoke':
        return '🔥 Дым';
      case 'gas':
        return '💨 Газ';
      case 'motion':
        return '🏃 Движение';
      case 'contact_open':
        return '🚪 Открыто';
      case 'contact_closed':
        return '🚪 Закрыто';
      default:
        return condition;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ═══════════════════════════════════════════════════════════
// КОМНАТЫ ПО УМОЛЧАНИЮ
// ═══════════════════════════════════════════════════════════

void _addDefaultRooms() async {
  await Future.delayed(const Duration(milliseconds: 100));
  final roomRepo = getIt<RoomRepository>();
  final rooms = await roomRepo.getAllRooms();
  if (rooms.isEmpty) {
    await roomRepo.saveRoom(
        Room(id: 'living', name: 'Гостиная', icon: '🛋️', sortOrder: 0));
    await roomRepo.saveRoom(
        Room(id: 'bedroom', name: 'Спальня', icon: '🛏️', sortOrder: 1));
    await roomRepo.saveRoom(
        Room(id: 'kitchen', name: 'Кухня', icon: '🍳', sortOrder: 2));
    await roomRepo.saveRoom(
        Room(id: 'other', name: 'Техника', icon: '🔌', sortOrder: 3));
  }
}