import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shome/data/protocols/tuya_protocol.dart';
import 'package:shome/di/injection.dart';
import 'package:shome/domain/models/device.dart';
import 'package:shome/domain/models/room.dart';
import 'package:shome/domain/repositories/device_repository.dart';
import 'package:shome/domain/repositories/room_repository.dart';
import 'package:shome/l10n/generated/app_localizations.dart';
import 'package:shome/presentation/widgets/device_settings.dart';

// ─── Моки ──────────────────────────────────────────────────────────

class MockRoomRepository implements RoomRepository {
  @override
  Future<List<Room>> getAllRooms() async => [
    Room(id: 'living', name: 'Гостиная', icon: '🛋️', sortOrder: 0),
    Room(id: 'bedroom', name: 'Спальня', icon: '🛏️', sortOrder: 1),
    Room(id: 'other', name: 'Техника', icon: '🔌', sortOrder: 2),
  ];

  @override
  Future<Room?> getRoomById(String id) async => null;

  @override
  Future<void> saveRoom(Room room) async {}

  @override
  Future<void> deleteRoom(String id) async {}
}

class MockDeviceRepository implements DeviceRepository {
  @override
  Future<List<Device>> getAllDevices() async => [];

  @override
  Future<Device?> getDeviceById(String id) async => null;

  @override
  Future<void> saveDevice(Device device) async {}

  @override
  Future<void> updateDeviceState(String id, DeviceState state) async {}

  @override
  Future<void> deleteDevice(String id) async {}

  @override
  Future<bool> turnOn(String id) async => true;

  @override
  Future<bool> turnOff(String id) async => true;

  @override
  Future<bool?> getDeviceStatus(String id) async => true;

  @override
  Future<bool> pingDevice(String id) async => true;

  @override
  Future<bool> setSwitchChannel(String id, int channel, bool state) async =>
      true;

  @override
  Future<bool> setCurtainPosition(String id, int position) async => true;

  @override
  Future<bool> setHvac(
      String id, {
        required bool power,
        required double targetTemp,
        required String mode,
        required int fanSpeed,
      }) async =>
      true;

  @override
  Future<void> updateDeviceProperties(
      String id,
      Map<String, dynamic> properties,
      ) async {}

  @override
  Future<bool> setBrightness(String id, int brightness) async => true;

  @override
  Future<Map<String, dynamic>?> getDeviceDps(String id) async => null;
}

class MockTuyaProtocol implements TuyaProtocol {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ─── Тесты ─────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSettings', () {
    setUpAll(() {
      if (!getIt.isRegistered<RoomRepository>()) {
        getIt.registerLazySingleton<RoomRepository>(
              () => MockRoomRepository(),
        );
      }

      if (!getIt.isRegistered<DeviceRepository>()) {
        getIt.registerLazySingleton<DeviceRepository>(
              () => MockDeviceRepository(),
        );
      }

      if (!getIt.isRegistered<TuyaProtocol>()) {
        getIt.registerLazySingleton<TuyaProtocol>(
              () => MockTuyaProtocol(),
        );
      }
    });

    tearDownAll(() async {
      await getIt.reset();
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('камера планшета — только название и комната', (tester) async {
      final device = Device(
        id: 'cam1',
        name: 'Камера планшета',
        type: DeviceType.camera,
        roomId: 'other',
        isOnline: true,
        state: DeviceState.online,
        properties: {
          'cameraType': 'device',
          'cameraLens': 0,
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () {
                      DeviceSettings.show(context, ref, device);
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Поля, которые должны быть для камеры.
      expect(find.text('Название'), findsOneWidget);
      expect(find.text('Комната'), findsOneWidget);

      // Поля Tuya скрыты для камеры.
      expect(find.text('Device ID'), findsNothing);
      expect(find.text('IP Адрес'), findsNothing);
      expect(find.text('Local Key'), findsNothing);
      expect(find.text('DPS Индекс'), findsNothing);

      // RTSP URL скрыт, потому что cameraType != 'rtsp'.
      expect(find.text('RTSP URL'), findsNothing);
    });
  });
}