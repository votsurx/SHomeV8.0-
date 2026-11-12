/// Доменная модель устройства — центральная модель всего приложения.
/// Использует Freezed для иммутабельности, copyWith, JSON-сериализации.
/// Поддерживает все типы устройств: розетки, выключатели, датчики, шторы, HVAC, лампы, камеры.
/// Свойства (properties) — гибкий Map для хранения специфичных данных каждого типа.
library;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
class Device with _$Device {
  const factory Device({
    /// Внутренний уникальный идентификатор (UUID)
    required String id,
    /// Человекочитаемое название устройства
    required String name,
    /// Тип устройства: outlet, switch1/2/3, sensor, curtain, hvac, light, camera, button
    required DeviceType type,
    /// ID комнаты, к которой привязано устройство
    required String roomId,
    /// Флаг "в сети"
    required bool isOnline,
    /// Текущее состояние: online, offline, pending, error
    required DeviceState state,
    /// Tuya Device ID (внешний идентификатор устройства в облаке Tuya)
    String? deviceId,
    /// Локальный ключ шифрования для Tuya-протокола
    String? localKey,
    /// IP-адрес устройства в локальной сети
    String? address,
    /// Версия протокола Tuya: 3.1, 3.3, 3.4, 3.5
    double? version,
    /// Индекс DPS для вкл/выкл (по умолчанию 1, для SimPal-TY130 = 2)
    int? dpsIndex,
    /// MQTT-топик (для будущей интеграции с Zigbee/MQTT)
    String? mqttTopic,
    /// Последнее значение температуры (для датчиков)
    double? temperature,
    /// Последнее значение влажности (для датчиков)
    double? humidity,
    /// Последнее значение датчика движения
    bool? motion,
    /// Последнее значение датчика открытия двери
    bool? doorOpen,
    /// Уровень заряда батареи (для беспроводных датчиков)
    double? battery,
    /// Гибкие свойства: isOn, states, channels, brightness, position,
    /// sensorType, sensorDps, sensorDivider, temperature, humidity, power...
    @Default({}) Map<String, dynamic> properties,
  }) = _Device;

  /// Создаёт Device из JSON (используется при экспорте/импорте конфигурации)
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}

/// Типы устройств, поддерживаемые приложением.
/// sensor — единый тип для всех датчиков (подтип в SensorType).
enum DeviceType {
  outlet,     // Розетка
  switch1,    // Одноклавишный выключатель
  switch2,    // Двухклавишный выключатель
  switch3,    // Трёхклавишный выключатель
  sensor,     // Датчик (температура, влажность, мощность, ток, напряжение, движение, дверь)
  curtain,    // Шторы/жалюзи
  hvac,       // Кондиционер
  light,      // Лампа (диммируемая)
  camera,     // Камера (RTSP)
  button,     // Zigbee кнопка
  compound,   // универсальное составное устройство
}

/// Подтипы датчиков для DeviceType.sensor.
/// Определяет, какой параметр измеряет датчик и как отображать данные.
enum SensorType {
  temperature,  // Температура (°C)
  humidity,     // Влажность (%)
  power,        // Мощность (W)
  current,      // Ток (mA)
  voltage,      // Напряжение (V)
  motion,       // Движение
  door,         // Открытие двери
}

/// Состояние устройства.
enum DeviceState {
  online,   // В сети, отвечает на запросы
  offline,  // Не в сети
  pending,  // Ожидает выполнения команды
  error,    // Ошибка
}