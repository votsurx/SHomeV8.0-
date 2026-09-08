/// Глобальные уровни логирования для разработчика.
/// Пользователю эти настройки не видны.
class DebugConfig {
  /// Уровень логирования:
  /// none  — ничего
  /// error — только ошибки
  /// info  — ошибки + важные события
  /// debug — всё
  static const String logLevel = 'error'; // ← меняй здесь вручную

  static bool get showErrors =>
      logLevel == 'error' || logLevel == 'info' || logLevel == 'debug';

  static bool get showInfo => logLevel == 'info' || logLevel == 'debug';

  static bool get showDebug => logLevel == 'debug';
}