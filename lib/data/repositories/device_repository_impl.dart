/// Реализация репозитория устройств.
/// Связывает доменный слой с TuyaProtocol (сеть) и AppDatabase (БД).
/// Кэширует устройства в Map(String, Device) для быстрого доступа.
/// При первом запросе загружает все устройства из БД.
library;
import '../../domain/models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../protocols/tuya_protocol.dart';
import '../local/database.dart';
import '../mappers/device_mapper.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final TuyaProtocol _tuyaProtocol;
  /// Кэш устройств в памяти: ключ — ID устройства, значение — доменная модель
  final Map<String, Device> _devices = {};

  DeviceRepositoryImpl(this._tuyaProtocol);

  /// Получает DPS устройства через TuyaProtocol.getStatus().
  /// Используется AdaptivePoller для опроса состояния.
  @override
  Future<Map<String, dynamic>?> getDeviceDps(String id) async {
    final device = _devices[id];
    if (device == null) return null;
    return await _tuyaProtocol.getStatus(device);
  }

  /// Обновляет properties устройства в кэше (без сохранения в БД).
  /// Используется для датчиков.
  @override
  Future<void> updateDeviceProperties(String id, Map<String, dynamic> properties) async {
    final device = _devices[id];
    if (device != null) {
      _devices[id] = device.copyWith(properties: properties);
    }
  }

  /// Возвращает все устройства. При первом вызове загружает из БД.
  @override
  Future<List<Device>> getAllDevices() async {
    if (_devices.isEmpty) {
      final entities = await AppDatabase.getAllDevices();
      for (final entity in entities) {
        _devices[entity.id] = DeviceMapper.toDomain(entity);
      }
    }
    return _devices.values.toList();
  }

  /// Находит устройство по ID. Если нет в кэше — загружает из БД.
  @override
  Future<Device?> getDeviceById(String id) async {
    if (!_devices.containsKey(id)) {
      await getAllDevices();
    }
    return _devices[id];
  }

  /// Сохраняет устройство в кэш и БД.
  @override
  Future<void> saveDevice(Device device) async {
    _devices[device.id] = device;
    await AppDatabase.insertDevice(DeviceMapper.toEntity(device));
  }

  /// Обновляет состояние (state) устройства в кэше и БД.
  @override
  Future<void> updateDeviceState(String id, DeviceState state) async {
    final device = _devices[id];
    if (device != null) {
      _devices[id] = device.copyWith(state: state);
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
  }

  /// Удаляет устройство из кэша и БД.
  @override
  Future<void> deleteDevice(String id) async {
    _devices.remove(id);
    await AppDatabase.deleteDevice(id);
  }

  /// Включает устройство: отправляет команду и обновляет состояние.
  @override
  Future<bool> turnOn(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.turnOn(device);
    if (success) await updateDeviceState(id, DeviceState.online);
    return success;
  }

  /// Выключает устройство: отправляет команду и обновляет состояние.
  @override
  Future<bool> turnOff(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.turnOff(device);
    if (success) await updateDeviceState(id, DeviceState.online);
    return success;
  }

  /// Проверяет статус устройства (пинг).
  @override
  Future<bool?> getDeviceStatus(String id) async {
    final device = _devices[id];
    if (device == null) return null;
    return await _tuyaProtocol.ping(device);
  }

  /// Проверяет доступность устройства (пинг).
  @override
  Future<bool> pingDevice(String id) async {
    final device = _devices[id];
    if (device == null) return false;
    return await _tuyaProtocol.ping(device);
  }

  /// Переключает канал многоканального устройства.
  /// Обновляет states в кэше и БД.
  @override
  Future<bool> setSwitchChannel(String id, int channel, bool state) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setSwitchChannel(device, channel, state);
    if (success) {
      final states = List<bool>.from(device.properties['states'] ?? []);
      if (channel <= states.length) {
        states[channel - 1] = state;
        _devices[id] = device.copyWith(properties: {...device.properties, 'states': states});
        await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
      }
    }
    return success;
  }

  /// Устанавливает позицию штор (0-100%).
  @override
  Future<bool> setCurtainPosition(String id, int position) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setCurtainPosition(device, position);
    if (success) {
      _devices[id] = device.copyWith(properties: {...device.properties, 'position': position});
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }

  /// Управляет кондиционером (HVAC).
  @override
  Future<bool> setHvac(String id, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setHvac(device, power: power, targetTemp: targetTemp, mode: mode, fanSpeed: fanSpeed);
    if (success) {
      _devices[id] = device.copyWith(properties: {...device.properties, 'isOn': power, 'targetTemp': targetTemp, 'mode': mode, 'fanSpeed': fanSpeed});
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }

  /// Устанавливает яркость лампы (0-255).
  @override
  Future<bool> setBrightness(String id, int brightness) async {
    final device = _devices[id];
    if (device == null) return false;
    final success = await _tuyaProtocol.setBrightness(device, brightness);
    if (success) {
      _devices[id] = device.copyWith(properties: {...device.properties, 'brightness': brightness, 'isOn': brightness > 0});
      await AppDatabase.updateDevice(DeviceMapper.toEntity(_devices[id]!));
    }
    return success;
  }
}