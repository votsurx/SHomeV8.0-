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

final getIt = GetIt.instance;

void configureDependencies() {
  // ============================================================
  // 📝 ЛОГГЕР
  // ============================================================

  final talker = TalkerFlutter.init();
  getIt.registerLazySingleton<Talker>(() => talker);

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
      getIt<EncryptedKeys>(),   // ← ДОБАВЛЕНО: ключи в SecureStorage
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