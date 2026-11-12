/// Управляет флагом завершения онбординга через SharedPreferences.
/// Если онбординг не пройден — при старте показывается Welcome экран.
/// После завершения — флаг сохраняется и больше не показывается.
library;
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  /// Ключ для хранения флага в SharedPreferences
  static const _keyOnboardingComplete = 'onboarding_complete';

  /// Проверяет, был ли завершён онбординг.
  /// Возвращает true, если пользователь уже прошёл онбординг.
  /// Если ключ отсутствует — возвращает false (первый запуск).
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  /// Устанавливает флаг завершения онбординга в true.
  /// Вызывается после прохождения всех экранов онбординга.
  static Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  /// Сбрасывает флаг онбординга (для отладки или сброса настроек).
  /// После вызова при следующем запуске снова покажется онбординг.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingComplete);
  }
}