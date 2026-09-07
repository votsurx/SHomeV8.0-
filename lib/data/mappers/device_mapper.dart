/// Маппер между доменной моделью Device и сущностью SQLite DeviceEntity.
/// Преобразует типы DeviceType/DeviceState в строки для БД и обратно.
/// Свойства (properties) сериализуются в JSON-строку и обратно.
library;
import 'dart:convert';
import '../../domain/models/device.dart';
import '../local/entities/device_entity.dart';

class DeviceMapper {
  /// Преобразует сущность БД в доменную модель.
  /// - DeviceType и DeviceState восстанавливаются из строк через enum.values.firstWhere.
  /// - properties десериализуется из JSON-строки в Map.
  /// - isOnline преобразуется из int (0/1) в bool.
  static Device toDomain(DeviceEntity entity) {
    return Device(
      id: entity.id,
      name: entity.name,
      type: DeviceType.values.firstWhere((t) => t.name == entity.type),
      roomId: entity.roomId,
      isOnline: entity.isOnline == 1,
      state: DeviceState.values.firstWhere((s) => s.name == entity.state),
      deviceId: entity.deviceId,
      localKey: entity.localKey,
      address: entity.address,
      version: entity.version,
      dpsIndex: entity.dpsIndex,
      properties: Map<String, dynamic>.from(jsonDecode(entity.properties)),
    );
  }

  /// Преобразует доменную модель в сущность для сохранения в БД.
  /// - DeviceType и DeviceState преобразуются в строки через .name.
  /// - properties сериализуется в JSON-строку.
  /// - isOnline преобразуется из bool в int (1/0).
  static DeviceEntity toEntity(Device device) {
    return DeviceEntity(
      id: device.id,
      name: device.name,
      type: device.type.name,
      roomId: device.roomId,
      isOnline: device.isOnline ? 1 : 0,
      state: device.state.name,
      deviceId: device.deviceId,
      localKey: device.localKey,
      address: device.address,
      version: device.version,
      dpsIndex: device.dpsIndex,
      properties: jsonEncode(device.properties),
    );
  }
}