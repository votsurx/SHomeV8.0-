library;
import 'package:uuid/uuid.dart';
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../protocols/tuya_protocol.dart';
import '../local/database.dart';
import '../local/entities/device_entity.dart';
import '../local/secure_storage/encrypted_keys.dart';
import '../mappers/device_mapper.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final TuyaProtocol _tuyaProtocol;
  final EncryptedKeys _encryptedKeys;
  final Map<String, Device> _devices = {};

  /// Кэш localKey: deviceId → localKey (в памяти, только для активных сессий)
  final Map<String, String> _localKeys = {};

  DeviceRepositoryImpl(this._tuyaProtocol, this._encryptedKeys);

  // ═══════════════════════════════════════════════════════════════
  // ЗАГРУЗКА + МИГРАЦИЯ
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<List<Device>> getAllDevices() async {
    if (_devices.isEmpty) {
      final entities = await AppDatabase.getAllDevices();
      await _migrateLocalKeys(entities);   // ← миграция старых ключей

      for (final entity in entities) {
        final device = DeviceMapper.toDomain(entity);
        // Подставляем localKey из SecureStorage
        final localKey = _localKeys[entity.id];
        _devices[entity.id] = localKey != null
            ? device.copyWith(localKey: localKey)
            : device;
      }
    }
    return _devices.values.toList();
  }

  /// Мигрирует plaintext-ключи в SecureStorage.
  /// После миграции в БД остаётся только ссылка "sec:`uuid`".
  Future<void> _migrateLocalKeys(List<DeviceEntity> entities) async {
    for (final entity in entities) {
      final stored = entity.localKey;
      if (stored == null || stored.isEmpty) continue;

      if (stored.startsWith('sec:')) {
        // Новый формат — читаем из SecureStorage
        final uuid = stored.substring(4);
        final key = await _encryptedKeys.getDeviceKey(uuid);
        if (key != null) _localKeys[entity.id] = key;
      } else {
        // Старый формат — мигрируем
        final uuid = const Uuid().v4();
        await _encryptedKeys.saveDeviceKey(uuid, stored);
        _localKeys[entity.id] = stored;

        // Обновляем запись в БД (только поле localKey)
        await AppDatabase.updateDevice(
          entity.copyWith(localKey: 'sec:$uuid'),
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // СОХРАНЕНИЕ — ключ идёт в SecureStorage, в БД — ссылка
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<void> saveDevice(Device device) async {
    _devices[device.id] = device;

    String? dbLocalKey = device.localKey;   // что писать в БД

    if (device.localKey != null && device.localKey!.isNotEmpty) {
      // Всегда создаём новую запись (проще, чем искать существующую)
      // В реальности можно переиспользовать UUID, если ключ не менялся
      final existing = _localKeys[device.id];

      if (existing != device.localKey) {
        // Ключ новый или изменился — сохраняем
        final uuid = const Uuid().v4();
        await _encryptedKeys.saveDeviceKey(uuid, device.localKey!);
        _localKeys[device.id] = device.localKey!;
        dbLocalKey = 'sec:$uuid';
      } else {
        // Ключ тот же — оставляем существующую ссылку
        // (в БД она уже в виде sec:<uuid>)
        // Найдём UUID из старой entity
        final oldEntity = await AppDatabase.getDeviceById(device.id);
        dbLocalKey = oldEntity?.localKey ?? 'sec:${const Uuid().v4()}';
      }
    }

    // Сохраняем в БД с ссылкой
    final entity = DeviceMapper.toEntity(device).copyWith(localKey: dbLocalKey);
    await AppDatabase.insertDevice(entity);
  }

  @override
  Future<void> deleteDevice(String id) async {
    // Удаляем ключ из SecureStorage
    final entity = await AppDatabase.getDeviceById(id);
    if (entity?.localKey?.startsWith('sec:') == true) {
      final uuid = entity!.localKey!.substring(4);
      await _encryptedKeys.deleteDeviceKey(uuid);
    }
    _localKeys.remove(id);

    _devices.remove(id);
    await AppDatabase.deleteDevice(id);
  }

  // ═══════════════════════════════════════════════════════════════
  // ОСТАЛЬНЫЕ МЕТОДЫ — без изменений
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<Map<String, dynamic>?> getDeviceDps(String id) async {
    final device = _devices[id];
    if (device == null) return null;
    return await _tuyaProtocol.getStatus(device);
  }

  @override
  Future<void> updateDeviceProperties(String id, Map<String, dynamic> properties) async {
    final device = _devices[id];
    if (device != null) {
      _devices[id] = device.copyWith(properties: properties);
    }
  }

  @override
  Future<Device?> getDeviceById(String id) async {
    if (!_devices.containsKey(id)) await getAllDevices();
    return _devices[id];
  }

  @override
  Future<void> updateDeviceState(String id, DeviceState state) async {
    final device = _devices[id];
    if (device != null) {
      _devices[id] = device.copyWith(state: state);
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
  }

  @override
  Future<bool> turnOn(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.turnOn(device);
    if (success) await updateDeviceState(id, DeviceState.online);
    return success;
  }

  @override
  Future<bool> turnOff(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.turnOff(device);
    if (success) await updateDeviceState(id, DeviceState.online);
    return success;
  }

  @override
  Future<bool?> getDeviceStatus(String id) async {
    final device = _devices[id];
    if (device == null) return null;
    return await _tuyaProtocol.ping(device);
  }

  @override
  Future<bool> pingDevice(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    return await _tuyaProtocol.ping(device);
  }

  @override
  Future<bool> setSwitchChannel(String id, int channel, bool state) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setSwitchChannel(device, channel, state);
    if (success) {
      final states = List<bool>.from(device.properties['states'] ?? []);
      if (channel <= states.length) {
        states[channel - 1] = state;
        _devices[id] = device.copyWith(
          properties: {...device.properties, 'states': states},
        );
        await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
      }
    }
    return success;
  }

  @override
  Future<bool> setCurtainPosition(String id, int position) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setCurtainPosition(device, position);
    if (success) {
      _devices[id] = device.copyWith(
        properties: {...device.properties, 'position': position},
      );
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }

  @override
  Future<bool> setHvac(String id, {
    required bool power,
    required double targetTemp,
    required String mode,
    required int fanSpeed,
  }) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setHvac(
      device,
      power: power,
      targetTemp: targetTemp,
      mode: mode,
      fanSpeed: fanSpeed,
    );
    if (success) {
      _devices[id] = device.copyWith(
        properties: {
          ...device.properties,
          'isOn': power,
          'targetTemp': targetTemp,
          'mode': mode,
          'fanSpeed': fanSpeed,
        },
      );
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }

  @override
  Future<bool> setBrightness(String id, int brightness) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setBrightness(device, brightness);
    if (success) {
      _devices[id] = device.copyWith(
        properties: {
          ...device.properties,
          'brightness': brightness,
          'isOn': brightness > 0,
        },
      );
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }
}