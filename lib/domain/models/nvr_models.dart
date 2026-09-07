/// Модели для интеграции с LegionNVR
library;

import 'dart:convert';

// ============================================================
// 📷 NVR CAMERA
// ============================================================

class NvrCamera {
  final int id;
  final String name;
  final String rtspMain;
  final String? rtspSub;
  final bool enabled;
  final bool streamEnabled;
  final bool motionEnabled;
  final bool recordEnabled;
  final double motionThreshold;
  final int motionCooldown;
  final int? motionFps;
  final String? recordMode;
  final int? recordPreSec;
  final int? recordPostSec;
  final int retentionDays;
  final String? streamQuality;
  final int? streamHlsTime;
  final int? locationId;
  final String? locationName;

  NvrCamera({
    required this.id,
    required this.name,
    required this.rtspMain,
    this.rtspSub,
    this.enabled = true,
    this.streamEnabled = true,
    this.motionEnabled = true,
    this.recordEnabled = false,
    this.motionThreshold = 2.0,
    this.motionCooldown = 5,
    this.motionFps = 5,
    this.recordMode = 'motion',
    this.recordPreSec = 5,
    this.recordPostSec = 10,
    this.retentionDays = 7,
    this.streamQuality = 'copy',
    this.streamHlsTime = 1,
    this.locationId,
    this.locationName,
  });

  factory NvrCamera.fromJson(Map<String, dynamic> json) {
    return NvrCamera(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      rtspMain: json['rtsp_main'] as String? ?? '',
      rtspSub: json['rtsp_sub'] as String?,
      enabled: (json['enabled'] as int? ?? 1) == 1,
      streamEnabled: (json['stream_enabled'] as int? ?? 1) == 1,
      motionEnabled: (json['motion_enabled'] as int? ?? 1) == 1,
      recordEnabled: (json['record_enabled'] as int? ?? 0) == 1,
      motionThreshold: (json['motion_threshold'] as num?)?.toDouble() ?? 2.0,
      motionCooldown: json['motion_cooldown'] as int? ?? 5,
      motionFps: json['motion_fps'] as int? ?? 5,
      recordMode: json['record_mode'] as String? ?? 'motion',
      recordPreSec: json['record_pre_sec'] as int? ?? 5,
      recordPostSec: json['record_post_sec'] as int? ?? 10,
      retentionDays: json['record_retention_days'] as int? ?? 7,
      streamQuality: json['stream_quality'] as String? ?? 'copy',
      streamHlsTime: json['stream_hls_time'] as int? ?? 1,
      locationId: json['location_id'] as int?,
      locationName: json['location_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rtsp_main': rtspMain,
      'rtsp_sub': rtspSub,
      'enabled': enabled ? 1 : 0,
      'stream_enabled': streamEnabled ? 1 : 0,
      'motion_enabled': motionEnabled ? 1 : 0,
      'record_enabled': recordEnabled ? 1 : 0,
      'motion_threshold': motionThreshold,
      'motion_cooldown': motionCooldown,
      'motion_fps': motionFps,
      'record_mode': recordMode,
      'record_pre_sec': recordPreSec,
      'record_post_sec': recordPostSec,
      'record_retention_days': retentionDays,
      'stream_quality': streamQuality,
      'stream_hls_time': streamHlsTime,
      'location_id': locationId,
      'location_name': locationName,
    };
  }

  NvrCamera copyWith({
    int? id,
    String? name,
    String? rtspMain,
    String? rtspSub,
    bool? enabled,
    bool? streamEnabled,
    bool? motionEnabled,
    bool? recordEnabled,
    double? motionThreshold,
    int? motionCooldown,
    int? motionFps,
    String? recordMode,
    int? recordPreSec,
    int? recordPostSec,
    int? retentionDays,
    String? streamQuality,
    int? streamHlsTime,
    int? locationId,
    String? locationName,
  }) {
    return NvrCamera(
      id: id ?? this.id,
      name: name ?? this.name,
      rtspMain: rtspMain ?? this.rtspMain,
      rtspSub: rtspSub ?? this.rtspSub,
      enabled: enabled ?? this.enabled,
      streamEnabled: streamEnabled ?? this.streamEnabled,
      motionEnabled: motionEnabled ?? this.motionEnabled,
      recordEnabled: recordEnabled ?? this.recordEnabled,
      motionThreshold: motionThreshold ?? this.motionThreshold,
      motionCooldown: motionCooldown ?? this.motionCooldown,
      motionFps: motionFps ?? this.motionFps,
      recordMode: recordMode ?? this.recordMode,
      recordPreSec: recordPreSec ?? this.recordPreSec,
      recordPostSec: recordPostSec ?? this.recordPostSec,
      retentionDays: retentionDays ?? this.retentionDays,
      streamQuality: streamQuality ?? this.streamQuality,
      streamHlsTime: streamHlsTime ?? this.streamHlsTime,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
    );
  }
}

// ============================================================
// 📼 NVR RECORDING
// ============================================================

class NvrRecording {
  final int id;
  final int cameraId;
  final String cameraName;
  final String filename;
  final DateTime startTime;
  final DateTime? endTime;
  final String type;
  final double sizeMb;

  NvrRecording({
    required this.id,
    required this.cameraId,
    required this.cameraName,
    required this.filename,
    required this.startTime,
    this.endTime,
    this.type = 'motion',
    this.sizeMb = 0,
  });

  factory NvrRecording.fromJson(Map<String, dynamic> json) {
    return NvrRecording(
      id: json['id'] as int? ?? 0,
      cameraId: json['camera_id'] as int? ?? 0,
      cameraName: json['camera_name'] as String? ?? 'Unknown',
      filename: json['filename'] as String? ?? '',
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'] as String)
          : null,
      type: json['type'] as String? ?? 'motion',
      sizeMb: (json['size_mb'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ============================================================
// 🎯 NVR ZONE
// ============================================================

class NvrZone {
  final int id;
  final int cameraId;
  final String name;
  final String zoneType; // 'include' | 'exclude'
  final List<NvrPoint> points;
  final bool enabled;

  NvrZone({
    required this.id,
    required this.cameraId,
    required this.name,
    this.zoneType = 'exclude',
    this.points = const [],
    this.enabled = true,
  });

  factory NvrZone.fromJson(Map<String, dynamic> json) {
    return NvrZone(
      id: json['id'] as int? ?? 0,
      cameraId: json['camera_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      zoneType: json['zone_type'] as String? ?? 'exclude',
      points: (json['points_json'] as String?) != null
          ? (jsonDecode(json['points_json'] as String) as List)
          .map((p) => NvrPoint.fromJson(p as Map<String, dynamic>))
          .toList()
          : [],
      enabled: (json['enabled'] as int? ?? 1) == 1,
    );
  }
}

class NvrPoint {
  final int x;
  final int y;

  NvrPoint({required this.x, required this.y});

  factory NvrPoint.fromJson(Map<String, dynamic> json) {
    return NvrPoint(
      x: json['x'] as int? ?? 0,
      y: json['y'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y};
  }
}

// ============================================================
// 📨 NVR MQTT EVENT
// ============================================================

class NvrMqttEvent {
  final int cameraId;
  final String cameraName;
  final String event; // 'motion_start' | 'motion_end' | 'recording_start' | 'recording_end'
  final double? percent;
  final DateTime timestamp;

  NvrMqttEvent({
    required this.cameraId,
    required this.cameraName,
    required this.event,
    this.percent,
    required this.timestamp,
  });

  factory NvrMqttEvent.fromMqtt(String topic, String payload) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final parts = topic.split('/');
    final cameraId = int.tryParse(parts[1]) ?? 0;

    return NvrMqttEvent(
      cameraId: cameraId,
      cameraName: data['camera_name'] as String? ?? 'Camera $cameraId',
      event: data['event'] as String? ?? 'unknown',
      percent: (data['percent'] as num?)?.toDouble(),
      timestamp: DateTime.now(),
    );
  }

  bool get isMotionStart => event == 'motion_start';
  bool get isMotionEnd => event == 'motion_end';
  bool get isRecordingStart => event == 'recording_start';
  bool get isRecordingEnd => event == 'recording_end';

  String get label {
    switch (event) {
      case 'motion_start': return '🔴 Движение';
      case 'motion_end': return '🟢 Движение прекратилось';
      case 'recording_start': return '📼 Запись началась';
      case 'recording_end': return '⏹️ Запись завершена';
      default: return event;
    }
  }
}

class IspyCameraConfig {
  final int cameraId;
  final String cameraName;
  final String? rtspUrl;
  final String? resolution;
  final double? fps;
  final bool yoloEnabled;
  final String? hash;  // Хэш для сравнения

  IspyCameraConfig({
    required this.cameraId,
    required this.cameraName,
    this.rtspUrl,
    this.resolution,
    this.fps,
    this.yoloEnabled = false,
    this.hash,
  });

  factory IspyCameraConfig.fromJson(Map<String, dynamic> json) {
    return IspyCameraConfig(
      cameraId: json['camera_id'] as int? ?? 0,
      cameraName: json['camera_name'] as String? ?? '',
      rtspUrl: json['rtsp_url'] as String?,
      resolution: json['resolution'] as String?,
      fps: (json['fps'] as num?)?.toDouble(),
      yoloEnabled: json['yolo_enabled'] as bool? ?? false,
      hash: json['hash'] as String?,
    );
  }
}
// ============================================================
// 🧠 ISPY DETECTION EVENT (YOLO)
// ============================================================

class IspyDetectionEvent {
  final int cameraId;
  final String cameraName;
  final String eventType;
  final DateTime timestamp;
  final List<IspyDetectedObject> objects;
  final bool snapshotAvailable;

  IspyDetectionEvent({
    required this.cameraId,
    required this.cameraName,
    required this.eventType,
    required this.timestamp,
    required this.objects,
    this.snapshotAvailable = false,
  });

  factory IspyDetectionEvent.fromJson(Map<String, dynamic> json) {
    return IspyDetectionEvent(
      cameraId: json['camera_id'] as int? ?? 0,
      cameraName: json['camera_name'] as String? ?? 'Unknown',
      eventType: json['event_type'] as String? ?? 'detection',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String).toLocal()  // ← .toLocal()!
          : DateTime.now(),
      objects: (json['objects'] as List?)
          ?.map((o) => IspyDetectedObject.fromJson(o as Map<String, dynamic>))
          .toList() ??
          [],
      snapshotAvailable: json['snapshot_available'] as bool? ?? false,
    );
  }

  String get objectsSummary =>
      objects.map((o) => '${o.className}(${(o.confidence * 100).toStringAsFixed(0)}%)').join(', ');

  String get label => '🧠 $cameraName: $objectsSummary';
}

// ============================================================
// 🎯 ISPY DETECTED OBJECT
// ============================================================

class IspyDetectedObject {
  final String className;
  final double confidence;

  IspyDetectedObject({
    required this.className,
    required this.confidence,
  });

  factory IspyDetectedObject.fromJson(Map<String, dynamic> json) {
    return IspyDetectedObject(
      className: json['Class'] as String? ?? json['class'] as String? ?? 'unknown',
      confidence: (json['Confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get icon {
    switch (className.toLowerCase()) {
      case 'person':
        return '🧑';
      case 'car':
        return '🚗';
      case 'cat':
        return '🐱';
      case 'dog':
        return '🐶';
      case 'motorcycle':
        return '🏍️';
      case 'bicycle':
        return '🚲';
      case 'truck':
        return '🚚';
      case 'bus':
        return '🚌';
      default:
        return '📦';
    }
  }
}