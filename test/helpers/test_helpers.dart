import 'package:flutter_test/flutter_test.dart';
import 'package:shome/domain/models/device.dart';
import 'package:shome/domain/models/scene.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:shome/domain/models/frigate_models.dart';
import 'package:shome/domain/repositories/scene_repository.dart';
import 'package:shome/data/services/notification_sender.dart';
import 'package:talker/talker.dart';
import 'package:shome/data/services/presence_detector.dart';
import 'package:shome/di/injection.dart';
import 'package:shome/data/services/sms_notification_service.dart';

void setupGetItForTests() {
  // Talker — нужен NotificationCoordinator, EventLogger, AdaptivePoller
  if (!getIt.isRegistered<Talker>()) {
    getIt.registerLazySingleton<Talker>(
          () => Talker(settings: TalkerSettings(enabled: false)),
    );
  }
  // PresenceDetector — нужен isConditionMet('away')
  if (!getIt.isRegistered<PresenceDetector>()) {
    getIt.registerLazySingleton<PresenceDetector>(() => PresenceDetector());
  }
}

/// Мок SceneRepository — хранит сцены в памяти, записывает вызовы executeScene.
class MockSceneRepository implements SceneRepository {
  final List<Scene> _scenes = [];
  final List<String> executedSceneIds = [];

  @override
  Future<List<Scene>> getAllScenes() async => List.from(_scenes);

  @override
  Future<void> saveScene(Scene scene) async {
    final idx = _scenes.indexWhere((s) => s.id == scene.id);
    if (idx != -1) {
      _scenes[idx] = scene;
    } else {
      _scenes.add(scene);
    }
  }

  @override
  Future<void> deleteScene(String id) async {
    _scenes.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> executeScene(Scene scene) async {
    executedSceneIds.add(scene.id);
  }
}

FrigateEvent createFrigateEvent({
  String id = 'evt_1',
  String camera = 'front_door',
  String label = 'person',
  double score = 0.9,
  DateTime? startTime,
  DateTime? endTime,
}) {
  return FrigateEvent(
    id: id,
    camera: camera,
    label: label,
    score: score,
    startTime: startTime ?? DateTime.now(),
    endTime: endTime,
  );
}

/// Инициализация sqflite FFI для тестов БД.
void setupSqfliteFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

/// Мок SecureStorage — возвращает null/пусто.
void setupSecureStorageMock({Map<String, String>? initial}) {
  final storage = Map<String, String>.from(initial ?? {});
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (call) async {
      switch (call.method) {
        case 'read':
          return storage[call.arguments['key']];
        case 'readAll':
          return storage;
        case 'write':
          storage[call.arguments['key']] = call.arguments['value'] as String;
          return null;
        case 'delete':
          storage.remove(call.arguments['key']);
          return null;
        case 'deleteAll':
          storage.clear();
          return null;
        case 'containsKey':
          return storage.containsKey(call.arguments['key']);
        default:
          return null;
      }
    },
  );
}

/// Мок SharedPreferences с пустыми значениями.
void setupPrefsMock([Map<String, Object>? initial]) {
  SharedPreferences.setMockInitialValues(initial ?? {});
}

/// Создаёт тестовое устройство.
Device createTestDevice({
  String id = 'dev_1',
  String name = 'Test Device',
  DeviceType type = DeviceType.outlet,
  String roomId = 'living',
  bool isOnline = true,
  DeviceState state = DeviceState.online,
  String? source,
  Map<String, dynamic>? properties,
}) {
  return Device(
    id: id,
    name: name,
    type: type,
    roomId: roomId,
    isOnline: isOnline,
    state: state,
    deviceId: 'bf_$id',
    localKey: 'key_$id',
    address: '192.168.1.1',
    version: 3.3,
    properties: {
      if (source != null) 'source': source,
      'isOn': false,
      ...?properties,
    },
  );
}

/// Создаёт тестовую сцену.
Scene createTestScene({
  String id = 'scene_1',
  String name = 'Test Scene',
  String icon = '🎬',
  List<SceneAction>? actions,
  SceneTrigger? trigger,
}) {
  return Scene(
    id: id,
    name: name,
    icon: icon,
    actions: actions ?? [const SceneAction(deviceId: 'dev_1', command: 'turnOn')],
    trigger: trigger,
  );
}
/// Мок VK-sender для тестов NotificationCoordinator.
class MockNotificationSender implements NotificationSender {
  final List<String> sent = [];
  bool shouldFail = false;

  @override
  Future<bool> send(String message) async {
    if (shouldFail) return false;
    sent.add(message);
    return true;
  }

  void reset() {
    sent.clear();
    shouldFail = false;
  }
}
/// Мок SMS-сервиса для тестов.
class MockSmsService implements SmsNotificationService {
  final List<String> sentSms = [];
  final List<String> sentAlarms = [];
  bool shouldFail = false;

  @override
  Future<bool> requestPermission() async => !shouldFail;

  @override
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    if (shouldFail) return false;
    sentSms.add('$phoneNumber: $message');
    return true;
  }

  @override
  Future<bool> sendAlarm({
    required String phoneNumber,
    required String cameraName,
    required String event,
    double? percent,
  }) async {
    if (shouldFail) return false;
    sentAlarms.add('$phoneNumber: $cameraName:$event');
    return true;
  }
}