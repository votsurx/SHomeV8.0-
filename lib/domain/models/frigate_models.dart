/// Модели Frigate NVR.
/// Парсятся из REST API (/api/config, /api/stats) и MQTT (frigate/events).
library;

/// Камера Frigate.
class FrigateCamera {
  final String name;
  final bool enabled;
  final List<String> zones;
  final int? width;
  final int? height;
  final int? fps;
  final String? roomId;  // привязка к комнате SHome (опционально)

  FrigateCamera({
    required this.name,
    this.enabled = true,
    this.zones = const [],
    this.width,
    this.height,
    this.fps,
    this.roomId,
  });

  factory FrigateCamera.fromJson(String name, Map<String, dynamic> json) {
    final detect = json['detect'] as Map<String, dynamic>?;
    final zonesRaw = json['zones'] as Map<String, dynamic>?;

    return FrigateCamera(
      name: name,
      enabled: json['enabled'] as bool? ?? true,
      zones: zonesRaw?.keys.toList() ?? [],
      width: detect?['width'] as int?,
      height: detect?['height'] as int?,
      fps: detect?['fps'] as int?,
      roomId: json['room_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'enabled': enabled,
    'zones': zones,
    'width': width,
    'height': height,
    'fps': fps,
    'room_id': roomId,
  };

  FrigateCamera copyWith({
    String? name,
    bool? enabled,
    List<String>? zones,
    int? width,
    int? height,
    int? fps,
    String? roomId,
  }) {
    return FrigateCamera(
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      zones: zones ?? this.zones,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      roomId: roomId ?? this.roomId,
    );
  }
}

/// Событие Frigate (детекция объекта).
class FrigateEvent {
  final String id;
  final String camera;
  final String label;        // person, car, dog, cat...
  final double score;        // 0.0 – 1.0
  final DateTime startTime;
  final DateTime? endTime;
  final bool hasClip;
  final bool hasSnapshot;
  final List<String> zones;

  FrigateEvent({
    required this.id,
    required this.camera,
    required this.label,
    required this.score,
    required this.startTime,
    this.endTime,
    this.hasClip = false,
    this.hasSnapshot = false,
    this.zones = const [],
  });

  factory FrigateEvent.fromJson(Map<String, dynamic> json) {
    final before = json['before'] as Map<String, dynamic>? ?? {};
    final after = json['after'] as Map<String, dynamic>? ?? {};
    final data = after.isNotEmpty ? after : before;

    return FrigateEvent(
      id: data['id'] as String? ?? '',
      camera: data['camera'] as String? ?? '',
      label: data['label'] as String? ?? '',
      score: (data['score'] as num?)?.toDouble() ?? 0.0,
      startTime: DateTime.fromMillisecondsSinceEpoch(
        ((data['start_time'] as num?)?.toDouble() ?? 0 * 1000).toInt(),
      ),
      endTime: data['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
        ((data['end_time'] as num).toDouble() * 1000).toInt(),
      )
          : null,
      hasClip: data['has_clip'] as bool? ?? false,
      hasSnapshot: data['has_snapshot'] as bool? ?? false,
      zones: (data['zones'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  bool get isActive => endTime == null;
  bool get isPerson => label == 'person';
  bool get isCar => label == 'car';
}

/// Статистика Frigate (CPU, RAM, камеры).
class FrigateStats {
  final int camerasOnline;
  final int camerasTotal;
  final int detectorsOnline;
  final int detectorsTotal;
  final double cpuUsage;
  final double memoryUsage;

  FrigateStats({
    required this.camerasOnline,
    required this.camerasTotal,
    required this.detectorsOnline,
    required this.detectorsTotal,
    required this.cpuUsage,
    required this.memoryUsage,
  });

  factory FrigateStats.fromJson(Map<String, dynamic> json) {
    final cameras = json['cameras'] as Map<String, dynamic>? ?? {};
    final detectors = json['detectors'] as Map<String, dynamic>? ?? {};
    final cpu = json['cpu_usages'] as Map<String, dynamic>? ?? {};

    int online = 0;
    for (final cam in cameras.values) {
      if (cam is Map && cam['camera_fps'] != null) online++;
    }

    return FrigateStats(
      camerasOnline: online,
      camerasTotal: cameras.length,
      detectorsOnline: detectors.length,
      detectorsTotal: detectors.length,
      cpuUsage: (cpu['frigate']?['cpu'] as num?)?.toDouble() ?? 0.0,
      memoryUsage: (cpu['frigate']?['mem'] as num?)?.toDouble() ?? 0.0,
    );
  }
}