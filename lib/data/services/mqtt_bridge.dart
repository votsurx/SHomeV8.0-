/// MQTT мост для приёма событий от MyiSpy и LegionNVR
/// Подписывается на топики ispy/# и spartan/+/motion
library;

import 'dart:async';
import 'dart:convert';
import 'package:talker/talker.dart';
import '../../domain/services/mqtt_service_interface.dart';
import '../../domain/models/nvr_models.dart';
import '../local/database.dart';
import '../local/entities/event_entity.dart';

class MqttBridge {
  final MqttService _mqttService;
  final Talker _talker;

  // ============================================================
  // КОЛБЭКИ ДЛЯ LEGION NVR
  // ============================================================

  /// Колбэк при получении события движения (LegionNVR)
  void Function(NvrMqttEvent event)? onMotionEvent;

  /// Колбэк при получении статуса камеры
  void Function(int cameraId, bool isOnline)? onStatusEvent;

  /// Колбэк при получении события записи
  void Function(int cameraId, bool isRecording)? onRecordingEvent;

  // ============================================================
  // КОЛБЭКИ ДЛЯ MYISPY
  // ============================================================

  /// Колбэк при получении конфига камеры (RTSP URL и т.д.)
  void Function(IspyCameraConfig config)? onIspyCameraConfig;

  /// Колбэк при получении события детекции YOLO от MyiSpy
  void Function(IspyDetectionEvent event)? onIspyDetection;

  StreamSubscription<MqttMessageData>? _subscription;
  bool _isRunning = false;

  MqttBridge({
    required MqttService mqttService,
    required Talker talker,
  })  : _mqttService = mqttService,
        _talker = talker;

  /// Запустить MQTT мост
  Future<void> start() async {
    if (_isRunning) return;

    try {
      // Подписываемся на топики LegionNVR
      await _mqttService.subscribe('spartan/+/motion');
      await _mqttService.subscribe('spartan/+/status');
      await _mqttService.subscribe('spartan/+/recording');
      await _mqttService.subscribe('spartan/+/error');

      // Подписываемся на топики MyiSpy
      await _mqttService.subscribe('ispy/detect/+');
      await _mqttService.subscribe('ispy/motion/+');
      await _mqttService.subscribe('ispy/record/+');
      await _mqttService.subscribe('ispy/status/+');
      await _mqttService.subscribe('ispy/events/+');
      await _mqttService.subscribe('ispy/camera/+/config');
      await _mqttService.subscribe('ispy/camera/+/status');

      // Слушаем сообщения
      _subscription = _mqttService.messageStream.listen(
        _handleMessage,
        onError: (error) {
          _talker.error('❌ MQTT Bridge error', error);
        },
      );

      _isRunning = true;
      _talker.info('📡 MQTT Bridge started (MyiSpy + LegionNVR)');
    } catch (e) {
      _talker.error('❌ Failed to start MQTT Bridge', e);
      rethrow;
    }
  }

  /// Остановить MQTT мост
  void stop() {
    _subscription?.cancel();
    _isRunning = false;
    _talker.info('📡 MQTT Bridge stopped');
  }

  // ============================================================
  // ОБРАБОТКА СООБЩЕНИЙ
  // ============================================================

  void _handleMessage(MqttMessageData msg) {
    try {
      final topic = msg.topic;

      if (topic.startsWith('ispy/')) {
        _handleIspyMessage(msg);
      } else if (topic.startsWith('spartan/')) {
        _handleLegionMessage(msg);
      }
    } catch (e) {
      _talker.error('❌ Error handling MQTT message', e);
    }
  }

  // ============================================================
  // 📨 ОБРАБОТКА MYISPY
  // ============================================================

  void _handleIspyMessage(MqttMessageData msg) {
    final topic = msg.topic;

    try {
      if (topic.contains('/camera/') && topic.endsWith('/status')) {
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final cameraId = data['camera_id'] as int? ?? 0;
        final online = data['online'] as bool? ?? false;
        _talker.info('📡 MyiSpy Camera $cameraId: ${online ? "ONLINE" : "OFFLINE"}');
        onStatusEvent?.call(cameraId, online);
        return;
      }

      else if (topic.contains('/camera/') && topic.endsWith('/config')) {
        // Конфиг камеры
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final config = IspyCameraConfig.fromJson(data);
        _talker.info('📡 Конфиг камеры: ${config.cameraName} (RTSP: ${config.rtspUrl ?? "нет"})');
        onIspyCameraConfig?.call(config);

      } else if (topic.contains('/detect/') || topic.contains('/events/')) {
        // YOLO детекция
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final event = IspyDetectionEvent.fromJson(data);
        _talker.info('🧠 MyiSpy: ${event.cameraName} → ${event.objectsSummary}');
        _saveIspyEventToDb(event);
        onIspyDetection?.call(event);

      } else if (topic.contains('/motion/')) {
        // Движение
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final cameraName = data['camera_name'] as String? ?? 'Unknown';
        _talker.info('🏃 MyiSpy Motion: $cameraName');

      } else if (topic.contains('/record/')) {
        // Запись
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final cameraId = data['camera_id'] as int? ?? 0;
        final isRecording = data['recording'] as bool? ?? false;
        _talker.info('📼 MyiSpy Recording: Camera $cameraId = $isRecording');
        onRecordingEvent?.call(cameraId, isRecording);

      } else if (topic.contains('/status/')) {
        // Статус
        final data = jsonDecode(msg.payload) as Map<String, dynamic>;
        final cameraId = data['camera_id'] as int? ?? 0;
        final online = data['online'] as bool? ?? false;
        _talker.info('📡 MyiSpy Status: Camera $cameraId = ${online ? "ONLINE" : "OFFLINE"}');
        onStatusEvent?.call(cameraId, online);
      }
    } catch (e) {
      _talker.error('❌ Error handling MyiSpy message', e);
    }
  }

  // ============================================================
  // 📨 ОБРАБОТКА LEGION NVR
  // ============================================================

  void _handleLegionMessage(MqttMessageData msg) {
    final topic = msg.topic;

    if (topic.endsWith('/motion')) {
      _handleMotion(msg);
    } else if (topic.endsWith('/status')) {
      _handleStatus(msg);
    } else if (topic.endsWith('/recording')) {
      _handleRecording(msg);
    } else if (topic.endsWith('/error')) {
      _handleError(msg);
    }
  }

  void _handleMotion(MqttMessageData msg) {
    final event = NvrMqttEvent.fromMqtt(msg.topic, msg.payload);

    _talker.info(
      '🔴 LegionNVR: ${event.cameraName} → ${event.event} (${event.percent?.toStringAsFixed(1)}%)',
    );

    _saveEventToDb(event);
    onMotionEvent?.call(event);
  }

  void _handleStatus(MqttMessageData msg) {
    try {
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;
      final cameraId = data['camera_id'] as int? ?? 0;
      final status = data['status'] as String? ?? 'offline';
      final isOnline = status == 'online';

      _talker.debug('📡 Camera $cameraId is ${isOnline ? "ONLINE" : "OFFLINE"}');
      onStatusEvent?.call(cameraId, isOnline);
    } catch (e) {
      _talker.error('❌ Error handling status', e);
    }
  }

  void _handleRecording(MqttMessageData msg) {
    try {
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;
      final cameraId = data['camera_id'] as int? ?? 0;
      final isRecording = data['recording'] as bool? ?? false;

      _talker.debug('📼 Camera $cameraId recording: ${isRecording ? "ON" : "OFF"}');
      onRecordingEvent?.call(cameraId, isRecording);
    } catch (e) {
      _talker.error('❌ Error handling recording', e);
    }
  }

  void _handleError(MqttMessageData msg) {
    try {
      final data = jsonDecode(msg.payload) as Map<String, dynamic>;
      final cameraId = data['camera_id'] as int? ?? 0;
      final error = data['error'] as String? ?? 'Unknown error';

      _talker.error('⚠️ Camera $cameraId error: $error');

      final entity = EventEntity(
        event: 'error',
        deviceId: 'nvr_$cameraId',
        deviceName: 'Camera $cameraId',
        value: error,
        timestamp: DateTime.now().toIso8601String(),
      );
      AppDatabase.insertEvent(entity);
    } catch (e) {
      _talker.error('❌ Error handling error', e);
    }
  }

  // ============================================================
  // 💾 СОХРАНЕНИЕ В БД
  // ============================================================

  Future<void> _saveEventToDb(NvrMqttEvent event) async {
    try {
      final eventType = event.isMotionStart
          ? 'motion_start'
          : event.isMotionEnd
          ? 'motion_end'
          : event.event;

      final entity = EventEntity(
        event: eventType,
        deviceId: 'nvr_${event.cameraId}',
        deviceName: event.cameraName,
        value: event.percent?.toStringAsFixed(1) ?? '',
        timestamp: event.timestamp.toIso8601String(),
      );

      await AppDatabase.insertEvent(entity);
    } catch (e) {
      _talker.error('❌ Failed to save event to DB', e);
    }
  }

  Future<void> _saveIspyEventToDb(IspyDetectionEvent event) async {
    try {
      final objects = event.objects.map((o) =>
      '${o.className}(${(o.confidence * 100).toStringAsFixed(0)}%)'
      ).join(', ');

      final entity = EventEntity(
        event: 'yolo_detection',
        deviceId: 'ispy_${event.cameraId}',
        deviceName: event.cameraName,
        value: objects,
        timestamp: event.timestamp.toIso8601String(),
      );

      await AppDatabase.insertEvent(entity);
    } catch (e) {
      _talker.error('❌ Failed to save Ispy event to DB', e);
    }
  }

  /// Проверяет, запущен ли мост
  bool get isRunning => _isRunning;
}