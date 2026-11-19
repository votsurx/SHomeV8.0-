import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenSaverConfig {
  const ScreenSaverConfig({
    this.enabled = true,
    this.idleTimeoutSeconds = 120,
    this.motionWakeEnabled = false,
    this.motionSensitivity = 50,
  });

  final bool enabled;
  final int idleTimeoutSeconds;
  final bool motionWakeEnabled;
  final int motionSensitivity;

  ScreenSaverConfig copyWith({
    bool? enabled,
    int? idleTimeoutSeconds,
    bool? motionWakeEnabled,
    int? motionSensitivity,
  }) {
    return ScreenSaverConfig(
      enabled: enabled ?? this.enabled,
      idleTimeoutSeconds:
      idleTimeoutSeconds ?? this.idleTimeoutSeconds,
      motionWakeEnabled:
      motionWakeEnabled ?? this.motionWakeEnabled,
      motionSensitivity:
      motionSensitivity ?? this.motionSensitivity,
    );
  }
}

class ScreenSaverSettings {
  ScreenSaverSettings._();

  static const _enabledKey = 'screen_saver_enabled';
  static const _timeoutKey = 'screen_saver_idle_timeout_seconds';
  static const _motionWakeKey = 'screen_saver_motion_wake_enabled';
  static const _motionSensitivityKey = 'screen_saver_motion_sensitivity';

  static final ValueNotifier<ScreenSaverConfig> value =
  ValueNotifier(const ScreenSaverConfig());

  static Future<void>? _loadFuture;

  static Future<void> load() {
    return _loadFuture ??= _readSettings();
  }

  static Future<void> _readSettings() async {
    final prefs = await SharedPreferences.getInstance();

    value.value = ScreenSaverConfig(
      enabled: prefs.getBool(_enabledKey) ?? true,
      idleTimeoutSeconds: prefs.getInt(_timeoutKey) ?? 120,
      motionWakeEnabled: prefs.getBool(_motionWakeKey) ?? false,
      motionSensitivity: prefs.getInt(_motionSensitivityKey) ?? 50,
    );
  }
  static Future<void> setMotionSensitivity(int sensitivity) async {
    final value = sensitivity.clamp(0, 100);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_motionSensitivityKey, value);
    ScreenSaverSettings.value.value =
        ScreenSaverSettings.value.value.copyWith(
          motionSensitivity: value,
        );
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    value.value = value.value.copyWith(enabled: enabled);
  }

  static Future<void> setIdleTimeout(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeoutKey, seconds);
    value.value = value.value.copyWith(idleTimeoutSeconds: seconds);
  }

  static Future<void> setMotionWakeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_motionWakeKey, enabled);
    value.value = value.value.copyWith(motionWakeEnabled: enabled);
  }
}