/// Чистые хелперы для экрана сцен: форматирование команд, иконок,
/// условий датчиков и присутствия.
/// Не зависят от Riverpod — тестируются отдельно.
library;

import 'package:flutter/material.dart';

import '../../../domain/models/device.dart';
import '../../../domain/models/scene.dart';

class SceneHelpers {
  SceneHelpers._();

  // ─── Действия ───

  static String actionLabel(String command) {
    switch (command) {
      case 'turnOn':
        return 'ВКЛ';
      case 'turnOff':
        return 'ВЫКЛ';
      case 'setBrightness':
        return 'ЯРК';
      default:
        return command.toUpperCase();
    }
  }

  static Color actionColor(String command) {
    switch (command) {
      case 'turnOn':
        return Colors.green;
      case 'turnOff':
        return Colors.red;
      case 'setBrightness':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  static String deviceIcon(DeviceType? type) {
    switch (type) {
      case DeviceType.outlet:
        return '🔌';
      case DeviceType.switch1:
      case DeviceType.switch2:
      case DeviceType.switch3:
        return '💡';
      case DeviceType.light:
        return '💡';
      case DeviceType.sensor:
        return '🌡️';
      case DeviceType.camera:
        return '📹';
      case DeviceType.compound:
        return '🤖';
      default:
        return '📦';
    }
  }

  // ─── Условия датчика ───

  static String sensorConditionLabel(SceneTrigger trigger) {
    final condition = trigger.sensorCondition ?? '';
    final threshold = trigger.sensorThreshold ?? 0;

    switch (condition) {
      case 'temperature_above':
        return 'Темп. > $threshold°C';
      case 'temperature_below':
        return 'Темп. < $threshold°C';
      case 'humidity_above':
        return 'Влаж. > $threshold%';
      case 'humidity_below':
        return 'Влаж. < $threshold%';
      case 'water_leak':
        return '💧 Протечка';
      case 'motion':
        return '🏃 Движение';
      case 'contact_open':
        return '🚪 Открыто';
      case 'contact_closed':
        return '🚪 Закрыто';
      case 'smoke':
        return '🔥 Дым';
      case 'gas':
        return '💨 Газ';
      default:
        return '$condition $threshold';
    }
  }

  // ─── Присутствие ───

  static String presenceEventLabel(SceneTrigger trigger) {
    final event = trigger.presenceEvent;
    if (event == null) return 'Присутствие';

    switch (event) {
      case PresenceEvent.someoneHome:
        return 'Кто-то пришёл';
      case PresenceEvent.nobodyHome:
        return 'Никого нет';
      case PresenceEvent.allHome:
        return 'Все дома';
      case PresenceEvent.phoneArrived:
        return 'Телефон пришёл';
      case PresenceEvent.phoneLeft:
        return 'Телефон ушёл';
      case PresenceEvent.phoneUnknown:
        return 'Телефон потерян';
    }
  }

  // ─── Повторы ───

  static String repeatLabel(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return 'Каждый день';
      case RepeatType.weekly:
        return 'По дням недели';
      case RepeatType.interval:
        return 'Интервал';
      default:
        return '';
    }
  }

  static String daysLabel(List<int>? days) {
    if (days == null || days.isEmpty) return '';
    final names = ['', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days.map((d) => names[d]).join(', ');
  }

  // ─── Прочее ───

  static String pluralize(int count) => 'устр.';

  static TimeOfDay? parseTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}