/// Провайдер сцен на Riverpod.
/// Управляет сценами: создание, выполнение, удаление.
/// Логирует все действия через EventLogger.
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/event_logger.dart';
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../di/injection.dart';
import '../../data/services/vk_notification_service.dart';
import 'notification_settings_provider.dart';
import 'global_container.dart';

/// Глобальный провайдер списка сцен.
final scenesProvider = StateNotifierProvider<ScenesNotifier, List<Scene>>((ref) {
  return ScenesNotifier();
});

/// Управляет сценами: загрузка, добавление, выполнение, удаление.
class ScenesNotifier extends StateNotifier<List<Scene>> {
  final SceneRepository _repository = getIt<SceneRepository>();

  ScenesNotifier() : super([]) {
    _loadScenes();
  }

  /// Загружает все сцены из репозитория
  Future<void> _loadScenes() async {
    state = await _repository.getAllScenes();
  }

  /// Добавляет новую сцену. Логирует событие sceneCreated.
  Future<void> addScene(Scene scene) async {
    await _repository.saveScene(scene);
    await _loadScenes();
    EventLogger.log(event: 'sceneCreated', sceneName: scene.name);
  }

  /// Выполняет сцену: для каждого действия отправляет команду на устройство.
  /// Логирует событие scene.
  Future<void> executeScene(String id) async {
    final scene = state.firstWhere((s) => s.id == id);
    await _repository.executeScene(scene);

    // Отправляем уведомление
    final settings = globalContainer.read(notificationSettingsProvider);
    if (settings.enabled && settings.notifyScenes && settings.isConfigured) {
      final vk = VkNotificationService();
      await vk.loadSettings();
      await vk.sendSceneNotification(sceneName: scene.name, success: true);
    }

    await EventLogger.log(
      deviceId: '',
      deviceName: '',
      event: 'scene',
      sceneName: scene.name,
    );
  }

  /// Удаляет сцену. Логирует событие sceneDeleted.
  Future<void> deleteScene(String id) async {
    final scene = state.firstWhere((s) => s.id == id);
    EventLogger.log(event: 'sceneDeleted', sceneName: scene.name);
    await _repository.deleteScene(id);
    state = state.where((s) => s.id != id).toList();
  }
}