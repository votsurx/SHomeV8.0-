import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreference {
  LanguagePreference._();

  static const String system = 'system';
  static const String russian = 'ru';
  static const String english = 'en';

  static const String _storageKey = 'app_language';

  static final ValueNotifier<String> value =
  ValueNotifier<String>(system);

  static Future<void>? _loadFuture;

  static Future<void> load() {
    return _loadFuture ??= _read();
  }

  static Future<void> _read() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey) ?? system;

    value.value = _isSupported(saved) ? saved : system;
  }

  static Future<void> set(String languageCode) async {
    if (!_isSupported(languageCode)) {
      throw ArgumentError.value(languageCode, 'languageCode');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, languageCode);
    value.value = languageCode;
  }

  static bool _isSupported(String code) {
    return code == system || code == russian || code == english;
  }

  static String label(String code) {
    switch (code) {
      case russian:
        return 'Русский';
      case english:
        return 'English';
      case system:
      default:
        return 'Как в системе';
    }
  }
}