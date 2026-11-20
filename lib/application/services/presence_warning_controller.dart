import 'package:flutter/foundation.dart';

/// Состояние предупреждения перед запуском сцены «Никого нет дома».
@immutable
class PresenceWarningState {
  PresenceWarningState({
    required this.sceneId,
    required this.sceneName,
    required List<String> unknownPhoneNames,
    required this.remainingSeconds,
  }) : unknownPhoneNames = List.unmodifiable(unknownPhoneNames);

  final String sceneId;
  final String sceneName;
  final List<String> unknownPhoneNames;
  final int remainingSeconds;
}

/// Передаёт состояние предупреждения между автоматизацией и UI.
///
/// AutomationEngine создаёт и обновляет предупреждение, а UI отображает его
/// поверх экранов приложения. Кнопка отмены вызывает зарегистрированный
/// обработчик движка.
class PresenceWarningController extends ChangeNotifier {
  PresenceWarningState? _state;

  /// Текущий предупреждающий отсчёт; null, если предупреждения нет.
  PresenceWarningState? get state => _state;

  bool get isActive => _state != null;

  VoidCallback? _onCancelRequested;

  /// Устанавливает или снимает обработчик нажатия кнопки отмены.
  void setCancelHandler(VoidCallback? handler) {
    _onCancelRequested = handler;
  }

  /// Показывает предупреждение или обновляет его данные.
  void show({
    required String sceneId,
    required String sceneName,
    required List<String> unknownPhoneNames,
    required int remainingSeconds,
  }) {
    _state = PresenceWarningState(
      sceneId: sceneId,
      sceneName: sceneName,
      unknownPhoneNames: unknownPhoneNames,
      remainingSeconds: remainingSeconds < 0 ? 0 : remainingSeconds,
    );
    notifyListeners();
  }

  /// Обновляет отображаемое оставшееся время.
  void updateRemainingSeconds(int seconds) {
    final current = _state;
    if (current == null) return;

    final safeSeconds = seconds < 0 ? 0 : seconds;
    if (current.remainingSeconds == safeSeconds) return;

    _state = PresenceWarningState(
      sceneId: current.sceneId,
      sceneName: current.sceneName,
      unknownPhoneNames: current.unknownPhoneNames,
      remainingSeconds: safeSeconds,
    );
    notifyListeners();
  }

  /// Обновляет список телефонов, статус которых остаётся unknown.
  void updateUnknownPhoneNames(List<String> phoneNames) {
    final current = _state;
    if (current == null) return;

    _state = PresenceWarningState(
      sceneId: current.sceneId,
      sceneName: current.sceneName,
      unknownPhoneNames: phoneNames,
      remainingSeconds: current.remainingSeconds,
    );
    notifyListeners();
  }

  /// Запрашивает отмену ожидающего запуска у AutomationEngine.
  void requestCancel() {
    _onCancelRequested?.call();
  }

  /// Скрывает предупреждение и очищает его данные.
  void clear() {
    if (_state == null) return;

    _state = null;
    notifyListeners();
  }
}