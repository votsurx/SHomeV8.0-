/// Riverpod-провайдер для Zigbee-устройств.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/zigbee_device.dart';
import '../../data/services/zigbee_bridge.dart';
import '../../di/injection.dart';

/// Список всех Zigbee-устройств из Z2M.
final zigbeeDevicesProvider =
StateNotifierProvider<ZigbeeDevicesNotifier, List<ZigbeeDevice>>((ref) {
  return ZigbeeDevicesNotifier();
});

/// Флаг: открыта ли сеть для сопряжения.
final zigbeePermitJoinProvider = StateProvider<bool>((ref) => false);

/// Таймер обратного отсчёта сопряжения (секунды).
final zigbeePermitJoinTimerProvider = StateProvider<int>((ref) => 0);

class ZigbeeDevicesNotifier extends StateNotifier<List<ZigbeeDevice>> {
  final ZigbeeBridge _bridge = getIt<ZigbeeBridge>();

  ZigbeeDevicesNotifier() : super([]) {
    _bridge.onDevicesList = (devices) {
      state = devices.where((d) => !d.isCoordinator).toList();
    };

    if (_bridge.lastDevices.isNotEmpty) {
      state = _bridge.lastDevices.where((d) => !d.isCoordinator).toList();
    }
  }

  ZigbeeDevice? findByName(String friendlyName) {
    try {
      return state.firstWhere((d) => d.friendlyName == friendlyName);
    } catch (_) {
      return null;
    }
  }
}