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
  }

  /// Обновляет состояние одного устройства (по friendly_name).
  void updateDeviceState(String friendlyName, Map<String, dynamic> newState) {
    state = state.map((d) {
      if (d.friendlyName != friendlyName) return d;
      return d; // состояние хранится отдельно, в Device.properties
    }).toList();
  }

  /// Находит устройство по friendly_name.
  ZigbeeDevice? findByName(String friendlyName) {
    try {
      return state.firstWhere((d) => d.friendlyName == friendlyName);
    } catch (_) {
      return null;
    }
  }
}