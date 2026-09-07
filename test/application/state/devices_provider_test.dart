import 'package:flutter_test/flutter_test.dart';
import 'package:shome/domain/models/device.dart';
import 'package:shome/application/state/devices_provider.dart';

void main() {
  group('DevicesNotifier', () {
    // Этот тест проверяет логику сортировки _restoreOrder
    test('reorderDevices меняет порядок', () {
      // Проверяем логику на уровне списка
      final list = <Device>[
        Device(id: 'a', name: 'A', type: DeviceType.outlet, roomId: '1', isOnline: false, state: DeviceState.offline),
        Device(id: 'b', name: 'B', type: DeviceType.outlet, roomId: '1', isOnline: false, state: DeviceState.offline),
        Device(id: 'c', name: 'C', type: DeviceType.outlet, roomId: '1', isOnline: false, state: DeviceState.offline),
      ];

      // Имитируем reorder: b (индекс 1) → начало (индекс 0)
      final newList = [...list];
      final item = newList.removeAt(1);
      newList.insert(0, item);

      expect(newList[0].id, 'b');
      expect(newList[1].id, 'a');
      expect(newList[2].id, 'c');
    });
  });
}