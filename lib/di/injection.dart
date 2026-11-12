/// Контейнер внедрения зависимостей (Dependency Injection) на базе GetIt.
library;

import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/repositories/room_repository.dart';
import '../domain/repositories/scene_repository.dart';
import '../data/local/secure_storage/encrypted_keys.dart';
import '../data/protocols/tuya_protocol.dart';
import '../data/repositories/device_repository_impl.dart';
import '../data/repositories/room_repository_impl.dart';
import '../data/repositories/scene_repository_impl.dart';
import '../data/services/automation_engine.dart';
import '../data/services/presence_detector.dart';
import '../data/services/timer_engine.dart';
import '../data/services/zigbee_bridge.dart';
import '../data/protocols/zigbee_protocol.dart';
import '../domain/services/mqtt_service_interface.dart';
import '../data/services/mqtt_service_impl.dart';
import '../data/services/frigate_service.dart';
import '../data/services/frigate_bridge.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // ============================================================
  // 📝 ЛОГГЕР
  // ============================================================

  final talker = TalkerFlutter.init();
  getIt.registerLazySingleton<Talker>(() => talker);


  // ============================================================
  // 📡 MQTT
  // ============================================================

  getIt.registerLazySingleton<MqttService>(
        () => MqttServiceImpl(getIt<Talker>()),
  );

  // ============================================================
  // 🐝 ZIGBEE
  // ============================================================

  getIt.registerLazySingleton<ZigbeeBridge>(
        () => ZigbeeBridge(
      mqttService: getIt<MqttService>(),
      talker: getIt<Talker>(),
    ),
  );

  getIt.registerLazySingleton<ZigbeeProtocol>(
        () => ZigbeeProtocol(getIt<MqttService>(), getIt<Talker>()),
  );

  // ============================================================
  // 🎥 FRIGATE
  // ============================================================

  getIt.registerLazySingleton<FrigateService>(
        () => FrigateService(getIt<Talker>()),
  );

  getIt.registerLazySingleton<FrigateBridge>(
        () => FrigateBridge(
      mqttService: getIt<MqttService>(),
      talker: getIt<Talker>(),
    ),
  );

  // ============================================================
  // 🔐 СИНГЛТОНЫ
  // ============================================================

  // EncryptedKeys регистрируется ПЕРВЫМ — его использует
  // DeviceRepositoryImpl для безопасного хранения localKey Tuya.
  getIt.registerLazySingleton<EncryptedKeys>(() => EncryptedKeys());

  // ============================================================
  // 🔌 ПРОТОКОЛЫ
  // ============================================================

  getIt.registerLazySingleton<TuyaProtocol>(
        () => TuyaProtocol(getIt<Talker>()),
  );

  // ============================================================
  // 📦 РЕПОЗИТОРИИ
  // ============================================================

  getIt.registerLazySingleton<DeviceRepository>(
        () => DeviceRepositoryImpl(
      getIt<TuyaProtocol>(),
      getIt<EncryptedKeys>(),
    ),
  );

  getIt.registerLazySingleton<RoomRepository>(
        () => RoomRepositoryImpl(),
  );

  getIt.registerLazySingleton<SceneRepository>(
        () => SceneRepositoryImpl(getIt<DeviceRepository>()),
  );

  // ============================================================
  // 📍 ДЕТЕКТОР ПРИСУТСТВИЯ
  // ============================================================

  getIt.registerLazySingleton<PresenceDetector>(
        () => PresenceDetector(),
  );

  // ============================================================
  // ⚙️ ДВИЖКИ
  // ============================================================

  getIt.registerLazySingleton<TimerEngine>(
        () => TimerEngine(getIt<DeviceRepository>(), getIt<Talker>()),
  );

  getIt.registerLazySingleton<AutomationEngine>(
        () => AutomationEngine(
      getIt<SceneRepository>(),
      getIt<Talker>(),
      presenceDetector: getIt<PresenceDetector>(),
    ),
  );
}