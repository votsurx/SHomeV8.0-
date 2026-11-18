import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenSaverConfig {
  const ScreenSaverConfig({
    this.enabled = true,
    this.idleTimeoutSeconds = 120,
  });

  final bool enabled;
  final int idleTimeoutSeconds;

  ScreenSaverConfig copyWith({
    bool? enabled,
    int? idleTimeoutSeconds,
  }) {
    return ScreenSaverConfig(
      enabled: enabled ?? this.enabled,
      idleTimeoutSeconds:
      idleTimeoutSeconds ?? this.idleTimeoutSeconds,
    );
  }
}

class ScreenSaverSettings {
  ScreenSaverSettings._();

  static const _enabledKey = 'screen_saver_enabled';
  static const _timeoutKey = 'screen_saver_idle_timeout_seconds';

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
}