/// Провайдер для камер MyiSpy, получающий события через MQTT
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mqtt_bridge.dart';
import '../../domain/models/nvr_models.dart';

// ============================================================
// 📷 ISPY CAMERA STATE
// ============================================================

class IspyCameraState {
  final Map<int, IspyCameraInfo> cameras;
  final IspyDetectionEvent? lastDetection;

  const IspyCameraState({
    this.cameras = const {},
    this.lastDetection,
  });

  IspyCameraState copyWith({
    Map<int, IspyCameraInfo>? cameras,
    IspyDetectionEvent? lastDetection,
  }) {
    return IspyCameraState(
      cameras: cameras ?? this.cameras,
      lastDetection: lastDetection ?? this.lastDetection,
    );
  }
}

class IspyCameraInfo {
  final int id;
  final String name;
  final bool isOnline;
  final bool isRecording;
  final String? lastObject;
  final double? lastConfidence;
  final DateTime? lastEventTime;

  const IspyCameraInfo({
    required this.id,
    required this.name,
    this.isOnline = false,
    this.isRecording = false,
    this.lastObject,
    this.lastConfidence,
    this.lastEventTime,
  });

  IspyCameraInfo copyWith({
    int? id,
    String? name,
    bool? isOnline,
    bool? isRecording,
    String? lastObject,
    double? lastConfidence,
    DateTime? lastEventTime,
  }) {
    return IspyCameraInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      isOnline: isOnline ?? this.isOnline,
      isRecording: isRecording ?? this.isRecording,
      lastObject: lastObject ?? this.lastObject,
      lastConfidence: lastConfidence ?? this.lastConfidence,
      lastEventTime: lastEventTime ?? this.lastEventTime,
    );
  }
}

// ============================================================
// 🔌 ISPY CAMERA PROVIDER
// ============================================================

final ispyCameraProvider = StateNotifierProvider<IspyCameraNotifier, IspyCameraState>(
      (ref) => IspyCameraNotifier(),
);

class IspyCameraNotifier extends StateNotifier<IspyCameraState> {
  MqttBridge? _mqttBridge;

  IspyCameraNotifier() : super(const IspyCameraState());

  /// Подключить MQTT бридж и начать слушать события MyiSpy
  void setMqttBridge(MqttBridge bridge) {
    _mqttBridge = bridge;

    // Подписываемся на события детекции
    bridge.onIspyDetection = (event) {
      _onDetection(event);
    };

    // Подписываемся на события статуса
    bridge.onStatusEvent = (cameraId, isOnline) {
      _onStatus(cameraId, isOnline);
    };

    // Подписываемся на события записи
    bridge.onRecordingEvent = (cameraId, isRecording) {
      _onRecording(cameraId, isRecording);
    };
  }

  void _onDetection(IspyDetectionEvent event) {
    final cameras = Map<int, IspyCameraInfo>.from(state.cameras);

    final objectNames = event.objects.map((o) => o.className).join(", ");
    final maxConfidence = event.objects.isEmpty ? 0.0 : event.objects.first.confidence;

    cameras[event.cameraId] = IspyCameraInfo(
      id: event.cameraId,
      name: event.cameraName,
      isOnline: true,
      isRecording: cameras[event.cameraId]?.isRecording ?? false,
      lastObject: objectNames,
      lastConfidence: maxConfidence,
      lastEventTime: event.timestamp,
    );

    state = IspyCameraState(
      cameras: cameras,
      lastDetection: event,
    );
  }

  void _onStatus(int cameraId, bool isOnline) {
    final cameras = Map<int, IspyCameraInfo>.from(state.cameras);

    if (cameras.containsKey(cameraId)) {
      cameras[cameraId] = cameras[cameraId]!.copyWith(isOnline: isOnline);
    } else {
      cameras[cameraId] = IspyCameraInfo(
        id: cameraId,
        name: 'Camera $cameraId',
        isOnline: isOnline,
      );
    }

    state = state.copyWith(cameras: cameras);
  }

  void _onRecording(int cameraId, bool isRecording) {
    final cameras = Map<int, IspyCameraInfo>.from(state.cameras);

    if (cameras.containsKey(cameraId)) {
      cameras[cameraId] = cameras[cameraId]!.copyWith(isRecording: isRecording);
    } else {
      cameras[cameraId] = IspyCameraInfo(
        id: cameraId,
        name: 'Camera $cameraId',
        isRecording: isRecording,
      );
    }

    state = state.copyWith(cameras: cameras);
  }
}