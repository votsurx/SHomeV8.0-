/// Чистые хелперы для экрана сцен: форматирование команд, иконок,
/// условий датчиков и присутствия.
library;

import 'package:flutter/material.dart';

import '../../../domain/models/device.dart';
import '../../../domain/models/scene.dart';
import '../../../l10n/generated/app_localizations.dart';

class SceneHelpers {
  SceneHelpers._();

  // ─── Действия ───

  static String actionLabel(
      String command,
      AppLocalizations l10n,
      ) {
    switch (command) {
      case 'turnOn':
        return l10n.sceneEditorActionOn;
      case 'turnOff':
        return l10n.sceneEditorActionOff;
      case 'setBrightness':
        return l10n.sceneEditorActionBrightness;
      default:
      // Неизвестная команда — техническое значение, оставляем как есть.
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

  static String sensorConditionLabel(
      SceneTrigger trigger,
      AppLocalizations l10n,
      ) {
    final condition = trigger.sensorCondition ?? '';
    final threshold = (trigger.sensorThreshold ?? 0).toString();

    switch (condition) {
      case 'temperature_above':
        return l10n.sceneEditorTemperatureAbove(threshold);
      case 'temperature_below':
        return l10n.sceneEditorTemperatureBelow(threshold);
      case 'humidity_above':
        return l10n.sceneEditorHumidityAbove(threshold);
      case 'humidity_below':
        return l10n.sceneEditorHumidityBelow(threshold);
      case 'water_leak':
        return l10n.sceneEditorWaterLeak;
      case 'motion':
        return l10n.sceneEditorMotion;
      case 'contact_open':
        return l10n.sceneEditorContactOpen;
      case 'contact_closed':
        return l10n.sceneEditorContactClosed;
      case 'smoke':
        return l10n.sceneEditorSmoke;
      case 'gas':
        return l10n.sceneEditorGas;
      default:
        return '$condition $threshold';
    }
  }

  // ─── Присутствие ───

  static String presenceEventLabel(
      SceneTrigger trigger,
      AppLocalizations l10n,
      ) {
    final event = trigger.presenceEvent;
    if (event == null) return l10n.scenesPresence;

    switch (event) {
      case PresenceEvent.someoneHome:
        return l10n.sceneEditorSomeoneHome;
      case PresenceEvent.nobodyHome:
        return l10n.sceneEditorNobodyHome;
      case PresenceEvent.allHome:
        return l10n.sceneEditorAllHome;
      case PresenceEvent.phoneArrived:
        return l10n.sceneEditorPhoneArrived;
      case PresenceEvent.phoneLeft:
        return l10n.sceneEditorPhoneLeft;
      case PresenceEvent.phoneUnknown:
        return l10n.sceneEditorPhoneUnknown;
    }
  }

  // ─── Повторы ───

  static String repeatLabel(
      RepeatType repeat,
      AppLocalizations l10n,
      ) {
    switch (repeat) {
      case RepeatType.daily:
        return l10n.sceneEditorRepeatDaily;
      case RepeatType.weekly:
        return l10n.sceneEditorRepeatWeekly;
      case RepeatType.interval:
        return l10n.sceneEditorMinutes(1);
      case RepeatType.once:
        return l10n.sceneEditorRepeatOnce;
    }
  }

  static String daysLabel(
      List<int>? days,
      AppLocalizations l10n,
      ) {
    if (days == null || days.isEmpty) return '';

    final names = [
      '',
      l10n.sceneEditorMonday,
      l10n.sceneEditorTuesday,
      l10n.sceneEditorWednesday,
      l10n.sceneEditorThursday,
      l10n.sceneEditorFriday,
      l10n.sceneEditorSaturday,
      l10n.sceneEditorSunday,
    ];

    return days
        .where((day) => day > 0 && day < names.length)
        .map((day) => names[day])
        .join(', ');
  }

  // ─── Прочее ───

  static String pluralize(
      int count,
      AppLocalizations l10n,
      ) {
    // Сохраняет прежнее назначение метода: вернуть краткую подпись единицы.
    return l10n.sceneEditorDeviceUnitShort;
  }

  static TimeOfDay? parseTime(String? timeStr) {
    if (timeStr == null) return null;

    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }
}