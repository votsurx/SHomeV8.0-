/// Протокол для прямого управления устройствами Tuya через локальный tinytuya.
/// Обёртка над OutletDevice с поддержкой разных DPS-индексов.
/// Вкл/выкл: для dpsIndex=1 используется outlet.turnOn/Off(), для остальных — setValue().
/// Поддерживает многоканальные устройства, шторы, HVAC, диммирование.
/// Использует Talker для логирования.
library;
import 'package:tinytuya/tinytuya.dart' hide Device;
import 'package:talker/talker.dart';
import '../../domain/models/device.dart';
import '../../application/constants/debug_config.dart';

class TuyaProtocol {
  final Talker _talker;

  TuyaProtocol(this._talker);

  /// Создаёт экземпляр OutletDevice из доменной модели Device.
  /// Если поля null — подставляет значения по умолчанию (версия 3.5).
  OutletDevice _createOutletDevice(Device device) {
    return OutletDevice(
      deviceId: device.deviceId ?? '',
      address: device.address ?? '',
      localKey: device.localKey ?? '',
      version: device.version ?? 3.5,
    );
  }

  /// Включает устройство.
  /// Для dpsIndex=1 использует outlet.turnOn() (надёжнее для стандартных устройств).
  /// Для остальных dpsIndex вызывает setValue(index, true).
  Future<bool> turnOn(Device device) async {
    try {
      _talker.info('Turning ON device: ${device.name}');
      final outlet = _createOutletDevice(device);
      if (device.dpsIndex == null || device.dpsIndex == 1) {
        // Стандартное устройство — используем встроенный метод
        await outlet.turnOn();
      } else {
        // Нестандартный DPS (например, усилитель с DPS=2)
        await outlet.setValue(index: device.dpsIndex!, value: true);
      }
      _talker.info('Device ${device.name} turned ON successfully');
      return true;
    } catch (e, stackTrace) {
      _talker.error('Failed to turn ON ${device.name}', e, stackTrace);
      return false;
    }
  }

  /// Выключает устройство.
  /// Аналогично turnOn — для dpsIndex=1 использует outlet.turnOff().
  Future<bool> turnOff(Device device) async {
    try {
      _talker.info('Turning OFF device: ${device.name}');
      final outlet = _createOutletDevice(device);
      if (device.dpsIndex == null || device.dpsIndex == 1) {
        await outlet.turnOff();
      } else {
        await outlet.setValue(index: device.dpsIndex!, value: false);
      }
      _talker.info('Device ${device.name} turned OFF successfully');
      return true;
    } catch (e, stackTrace) {
      _talker.error('Failed to turn OFF ${device.name}', e, stackTrace);
      return false;
    }
  }

  /// Проверяет доступность устройства.
  /// Отправляет setValue с null на DPS 1 и ждёт ответа.
  /// Если в ответе есть 'Error' — устройство недоступно.
  Future<bool> ping(Device device) async {
    try {
      final outlet = _createOutletDevice(device);
      final result = await outlet.setValue(index: '1', value: null, nowait: false);

      if (result.containsKey('Error')) {
        _talker.debug('Device ${device.name} ping failed: ${result['Error']}');
        return false;
      }

      _talker.debug('Device ${device.name} ping successful');
      return true;
    } catch (e) {
      _talker.debug('Device ${device.name} ping failed: $e');
      return false;
    }
  }

  /// Переключает канал многоканального устройства.
  /// channel — номер канала (1, 2, 3).
  /// state — true (вкл) или false (выкл).
  /// Отправляет bool напрямую (без преобразования в 1/0).
  Future<bool> setSwitchChannel(Device device, int channel, bool state) async {
    try {
      _talker.info('Setting channel $channel to $state on ${device.name}');
      final outlet = _createOutletDevice(device);
      await outlet.setValue(index: channel, value: state);
      _talker.info('Channel $channel set successfully');
      return true;
    } catch (e) {
      _talker.error('Failed to set channel: $e');
      return false;
    }
  }

  /// Устанавливает позицию штор (0-100%).
  Future<bool> setCurtainPosition(Device device, int position) async {
    try {
      final outlet = _createOutletDevice(device);
      await outlet.setValue(index: '1', value: position);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Управляет кондиционером (HVAC).
  /// power — вкл/выкл, targetTemp — целевая температура,
  /// mode — auto/cool/heat/dry/fan, fanSpeed — скорость вентилятора (1-5).
  Future<bool> setHvac(Device device, {required bool power, required double targetTemp, required String mode, required int fanSpeed}) async {
    try {
      final outlet = _createOutletDevice(device);
      final modeMap = {'auto': 0, 'cool': 1, 'heat': 2, 'dry': 3, 'fan': 4};
      await outlet.setValue(index: '1', value: power ? 1 : 0);
      await outlet.setValue(index: '2', value: targetTemp.toInt());
      await outlet.setValue(index: '3', value: modeMap[mode] ?? 0);
      await outlet.setValue(index: '4', value: fanSpeed);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Устанавливает яркость лампы (диммирование).
  /// brightness — значение 0-255.
  Future<bool> setBrightness(Device device, int brightness) async {
    try {
      final outlet = _createOutletDevice(device);
      await outlet.setDimmer(value: brightness);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Получает DPS устройства (устаревший метод, используется редко).
  Future<Map<String, dynamic>?> getDeviceDps(Device device) async {
    try {
      _talker.info('Getting DPS for device: ${device.name}');
      final outlet = _createOutletDevice(device);
      final result = await outlet.setDimmer(value: 255, nowait: true);
      return result;
    } catch (e) {
      return {'note': 'DPS reading not fully supported yet'};
    }
  }

  /// Получает полный статус устройства (все DPS).
  /// Использует outlet.status() — TCP-запрос к устройству.
  /// Возвращает Map с dps-данными или null при ошибке.
  /// Не все устройства поддерживают status() (например, SimPal-TY130).
  Future<Map<String, dynamic>?> getStatus(Device device) async {
    try {
      if (DebugConfig.showDebug) {
        _talker.info('Getting status for: ${device.name}');
      }
      final outlet = _createOutletDevice(device);
      final result = await outlet.status();
      if (DebugConfig.showDebug) {
        _talker.debug('Status result: $result');
      }
      return result;
    } catch (e) {
    if (DebugConfig.showDebug) {
      _talker.error('Failed to get status for ${device.name}: $e');
    }
      return null;
    }
  }

  /// Универсальная установка значения DP (Data Point).
  /// dpId – номер DP (целое число).
  /// value – значение: bool, int, double, String (enum), List и т.д.
  Future<bool> setDp(Device device, int dpId, dynamic value) async {
    try {
      _talker.info('Setting DP $dpId on ${device.name} to $value');
      final outlet = _createOutletDevice(device);
      await outlet.setValue(index: dpId, value: value);
      _talker.info('DP $dpId set successfully');
      return true;
    } catch (e, stackTrace) {
      _talker.error('Failed to set DP $dpId on ${device.name}', e, stackTrace);
      return false;
    }
  }
}