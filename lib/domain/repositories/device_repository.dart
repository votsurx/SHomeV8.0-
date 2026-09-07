/// Интерфейс репозитория устройств — контракт между доменным и data-слоем.
/// Определяет все операции с устройствами: CRUD, управление, опрос.
/// Реализован в DeviceRepositoryImpl.
library;
import '../models/device.dart';

abstract class DeviceRepository {
  // ============ CRUD ============

  /// Возвращает все устройства из БД
  Future<List<Device>> getAllDevices();
  /// Находит устройство по ID
  Future<Device?> getDeviceById(String id);
  /// Сохраняет устройство (создаёт или обновляет)
  Future<void> saveDevice(Device device);
  /// Обновляет состояние устройства (online/offline/pending/error)
  Future<void> updateDeviceState(String id, DeviceState state);
  /// Удаляет устройство
  Future<void> deleteDevice(String id);

  // ============ Базовое управление ============

  /// Включает устройство
  Future<bool> turnOn(String id);
  /// Выключает устройство
  Future<bool> turnOff(String id);
  /// Проверяет статус устройства
  Future<bool?> getDeviceStatus(String id);
  /// Проверяет доступность устройства (пинг)
  Future<bool> pingDevice(String id);

  // ============ Многоканальные выключатели ============

  /// Переключает канал многоканального устройства
  Future<bool> setSwitchChannel(String id, int channel, bool state);

  // ============ Шторы ============

  /// Устанавливает позицию штор (0-100%)
  Future<bool> setCurtainPosition(String id, int position);

  // ============ Кондиционер ============

  /// Управляет кондиционером: вкл/выкл, температура, режим, скорость вентилятора
  Future<bool> setHvac(String id, {
    required bool power,
    required double targetTemp,
    required String mode,
    required int fanSpeed,
  });

  // ============ Свойства ============

  /// Обновляет properties устройства (для датчиков)
  Future<void> updateDeviceProperties(String id, Map<String, dynamic> properties);

  // ============ Лампа ============

  /// Устанавливает яркость лампы (0-255)
  Future<bool> setBrightness(String id, int brightness);

  // ============ DPS ============

  /// Получает DPS устройства (статус, показания датчиков)
  Future<Map<String, dynamic>?> getDeviceDps(String id);
}