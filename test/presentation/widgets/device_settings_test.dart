import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shome/domain/models/device.dart';
import 'package:shome/domain/models/room.dart';
import 'package:shome/domain/repositories/room_repository.dart';
import 'package:shome/presentation/widgets/device_settings.dart';
import 'package:shome/di/injection.dart';

class MockRoomRepository implements RoomRepository {
  @override
  Future<List<Room>> getAllRooms() async => [
    Room(id: 'living', name: 'Гостиная', icon: '🛋️', sortOrder: 0),
    Room(id: 'bedroom', name: 'Спальня', icon: '🛏️', sortOrder: 1),
  ];

  @override
  Future<Room?> getRoomById(String id) async => null;

  @override
  Future<void> saveRoom(Room room) async {}

  @override
  Future<void> deleteRoom(String id) async {}
}

void main() {
  group('DeviceSettings', () {
    setUp(() {
      getIt.registerSingleton<RoomRepository>(MockRoomRepository());
    });

    tearDown(() {
      getIt.unregister<RoomRepository>();
    });

    testWidgets('камера планшета — только название и комната', (tester) async {
      final device = Device(
        id: 'cam1', name: 'Камера планшета', type: DeviceType.camera,
        roomId: 'other', isOnline: true, state: DeviceState.online,
        properties: {'cameraType': 'device', 'cameraLens': 0},
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(builder: (context, ref, _) {
                return ElevatedButton(
                  onPressed: () => DeviceSettings.show(context, ref, device),
                  child: const Text('Open'),
                );
              }),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Название'), findsOneWidget);
      expect(find.text('Комната'), findsOneWidget);
      expect(find.text('Device ID'), findsNothing);
      expect(find.text('IP Адрес'), findsNothing);
      expect(find.text('Local Key'), findsNothing);
      expect(find.text('DPS Индекс'), findsNothing);
    });
  });
}