/// Единый координатор уведомлений.
/// Централизует:
/// - Проверку per-device notify_types
/// - Проверку notify_condition
/// - Антидребезг per-device
/// - Отправку VK/SMS
///
/// Настройки VK/SMS передаются параметрами (избегаем циклических зависимостей).
library;

import 'package:talker/talker.dart';
import '../../di/injection.dart';
import '../../domain/models/device.dart';
import '../../domain/models/frigate_models.dart';
import '../../application/models/notification_settings.dart';
import '../../application/models/sms_settings.dart';
import 'presence_detector.dart';
import 'sms_notification_service.dart';
import 'vk_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'notification_sender.dart';

class NotificationCoordinator {
  static final NotificationCoordinator _instance =
  NotificationCoordinator._();
  factory NotificationCoordinator() => _instance;
  NotificationCoordinator._();

  /// Антидребезг per-device per-channel per-type.
  /// Ключ: `<channel>_<type>_<deviceId>`.
  final Map<String, DateTime> _lastNotification = {};

  // 🆕 Инъекция для тестов
  NotificationSender _vkSender = VkNotificationSender();
  SmsNotificationService _smsService = SmsNotificationService();

  @visibleForTesting
  void setSendersForTest({
    NotificationSender? vkSender,
    SmsNotificationService? smsService,
  }) {
    if (vkSender != null) _vkSender = vkSender;
    if (smsService != null) _smsService = smsService;
  }

  @visibleForTesting
  void resetForTest() {
    _lastNotification.clear();
    _vkSender = VkNotificationSender();
    _smsService = SmsNotificationService();
  }

  // ═══════════════════════════════════════════════════════════
  // УСЛОВИЯ
  // ═══════════════════════════════════════════════════════════

  bool isConditionMet(String condition) {
    switch (condition) {
      case 'always':
        return true;
      case 'away':
        return getIt<PresenceDetector>().isNobodyHome;
      case 'night':
        final hour = DateTime.now().hour;
        return hour >= 22 || hour < 6;
      case 'away_or_night':
        final hour = DateTime.now().hour;
        return getIt<PresenceDetector>().isNobodyHome ||
            hour >= 22 ||
            hour < 6;
      default:
        return true;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // АНТИДРЕБЕЗГ
  // ═══════════════════════════════════════════════════════════

  bool _checkDebounce(String key, int cooldownMin) {
    final last = _lastNotification[key];
    if (last != null &&
        DateTime.now().difference(last).inMinutes < cooldownMin) {
      getIt<Talker>().debug('⏱ Debounce: $key');
      return false;
    }
    _lastNotification[key] = DateTime.now();
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // УНИВЕРСАЛЬНАЯ ОТПРАВКА
  // ═══════════════════════════════════════════════════════════

  /// Отправляет уведомление для устройства.
  /// Проверяет:
  /// - per-device notify_types (содержит ли type)
  /// - notify_condition
  /// - per-device cooldown (или глобальный, если не задан)
  /// - глобальные VK/SMS настройки
  Future<void> notifyDevice({
    required Device device,
    required String type, // 'state_changed', 'offline', 'error', ...
    required String title,
    required String message,
    required NotificationSettings vkSettings,
    required SmsSettings smsSettings,
  }) async {
    try {
      // 1. Per-device: тип разрешён?
      final notifyTypes =
      (device.properties['notify_types'] as List?)?.cast<String>();
      if (notifyTypes != null && !notifyTypes.contains(type)) {
        getIt<Talker>().debug(
            '⏱ notify_types: $type выключен для ${device.name}');
        return;
      }

      // 2. Per-device: условие
      final condition =
          device.properties['notify_condition'] as String? ?? 'always';
      if (!isConditionMet(condition)) {
        getIt<Talker>().debug(
            '⏱ condition: $condition не выполнено (${device.name})');
        return;
      }

      // 3. Per-device cooldown (fallback — глобальный)
      final deviceCooldown = device.properties['notify_cooldown_min'] as int?;
      final vkCooldown = deviceCooldown ?? vkSettings.vkCooldownMin;
      final smsCooldown = deviceCooldown ?? smsSettings.smsCooldownMin;

      // 4. VK
      if (vkSettings.isConfigured &&
          _isVkTypeEnabled(vkSettings, type, device)) {
        final key = 'vk_${type}_${device.id}';
        if (_checkDebounce(key, vkCooldown)) {
          await _vkSender.send('$title\n$message');
        }
      }

      // 5. SMS
      if (smsSettings.isConfigured &&
          _isSmsTypeEnabled(smsSettings, type, device)) {
        final key = 'sms_${type}_${device.id}';
        if (_checkDebounce(key, smsCooldown)) {
          for (final phone in smsSettings.phones.where((p) => p.enabled)) {
            await _smsService.sendSms(
              phoneNumber: phone.phone,
              message: 'SHome: $title\n$message',
            );
          }
        }
      }
    } catch (e) {
      getIt<Talker>().error('❌ Notification error', e);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FRIGATE
  // ═══════════════════════════════════════════════════════════

  Future<void> notifyFrigateEvent({
    required Device camera,
    required FrigateEvent event,
    required NotificationSettings vkSettings,
    required SmsSettings smsSettings,
  }) async {
    try {
      // 1. Camera.notify_labels
      final notifyLabels =
          (camera.properties['notify_labels'] as List?)?.cast<String>() ?? [];
      if (!notifyLabels.contains(event.label)) {
        getIt<Talker>().debug(
            '⏱ notify_labels: ${event.label} выключен для ${camera.name}');
        return;
      }

      // 2. Condition
      final condition =
          camera.properties['notify_condition'] as String? ?? 'always';
      if (!isConditionMet(condition)) {
        getIt<Talker>().debug(
            '⏱ condition: $condition не выполнено (${camera.name})');
        return;
      }

      // 3. Cooldown (fallback — глобальный)
      final deviceCooldown = camera.properties['notify_cooldown_min'] as int?;
      final vkCooldown = deviceCooldown ?? vkSettings.vkCooldownMin;
      final smsCooldown = deviceCooldown ?? smsSettings.smsCooldownMin;

      // 4. VK
      final vkEnabled = event.label == 'person'
          ? vkSettings.notifyFrigatePerson
          : event.label == 'car'
          ? vkSettings.notifyFrigateCar
          : false;

      if (vkEnabled && vkSettings.isConfigured) {
        final key = 'vk_frigate_${event.label}_${camera.id}';
        if (_checkDebounce(key, vkCooldown)) {
          final vk = VkNotificationService();
          await vk.loadSettings();
          await vk.sendAlarm(
            cameraName: event.camera,
            label: event.label,
            score: event.score,
          );
        }
      }

      // 5. SMS
      final smsEnabled = event.label == 'person'
          ? smsSettings.notifyFrigatePerson
          : event.label == 'car'
          ? smsSettings.notifyFrigateCar
          : false;

      if (smsEnabled && smsSettings.isConfigured) {
        final key = 'sms_frigate_${event.label}_${camera.id}';
        if (_checkDebounce(key, smsCooldown)) {
          for (final phone in smsSettings.phones.where((p) => p.enabled)) {
            await _smsService.sendAlarm(
              phoneNumber: phone.phone,
              cameraName: event.camera,
              event: event.label,
              percent: event.score * 100,
            );
          }
        }
      }
    } catch (e) {
      getIt<Talker>().error('❌ Frigate notify error', e);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // VK/SMS — какие типы включены
  // ═══════════════════════════════════════════════════════════

  bool _isVkTypeEnabled(
      NotificationSettings s, String type, Device device) {
    // Tuya device events
    if (type == 'state_changed') return s.notifyDevices;
    if (type == 'offline') {
      if (device.properties['source'] == 'zigbee') {
        return s.notifyZigbeeOffline;
      }
      if (device.properties['source'] == 'frigate') {
        return s.notifyFrigateOffline;
      }
      return s.notifyErrors; // Tuya — глобально
    }
    if (type == 'error') return s.notifyErrors;

    // Zigbee alerts
    if (type == 'water_leak') return s.notifyZigbeeWaterLeak;
    if (type == 'smoke') return s.notifyZigbeeSmoke;
    if (type == 'gas') return s.notifyZigbeeGas;
    if (type == 'motion') return s.notifyZigbeeMotion;
    if (type == 'contact_open' || type == 'contact_closed') {
      return s.notifyZigbeeContact;
    }

    // Frigate (для камер)
    if (type == 'person') return s.notifyFrigatePerson;
    if (type == 'car') return s.notifyFrigateCar;

    return false;
  }

  bool _isSmsTypeEnabled(
      SmsSettings s, String type, Device device) {
    if (type == 'state_changed') return s.notifyDevices;
    if (type == 'offline') {
      if (device.properties['source'] == 'zigbee') {
        return s.notifyZigbeeOffline;
      }
      if (device.properties['source'] == 'frigate') {
        return s.notifyFrigateOffline;
      }
      return s.notifyErrors;
    }
    if (type == 'error') return s.notifyErrors;

    if (type == 'water_leak') return s.notifyZigbeeWaterLeak;
    if (type == 'smoke') return s.notifyZigbeeSmoke;
    if (type == 'gas') return s.notifyZigbeeGas;
    if (type == 'motion') return s.notifyZigbeeMotion;
    if (type == 'contact_open' || type == 'contact_closed') {
      return s.notifyZigbeeContact;
    }

    if (type == 'person') return s.notifyFrigatePerson;
    if (type == 'car') return s.notifyFrigateCar;

    return false;
  }
}