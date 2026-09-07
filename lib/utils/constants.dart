/// Константы приложения.
/// Используются для настройки таймаутов, количества повторных попыток и heartbeat.
class AppConstants {
  /// Название приложения
  static const String appName = 'SHome';
  /// Таймаут по умолчанию для запросов к устройствам (мс)
  static const int defaultTimeout = 3000;
  /// Максимальное количество повторных попыток при ошибке
  static const int maxRetries = 2;
  /// Интервал heartbeat (секунд)
  static const int heartbeatInterval = 10;
}