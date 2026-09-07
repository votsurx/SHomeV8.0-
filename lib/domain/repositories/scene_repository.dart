/// Интерфейс репозитория сцен — контракт между доменным и data-слоем.
/// Определяет операции со сценами: CRUD и выполнение.
/// Реализован в SceneRepositoryImpl.
import '../models/scene.dart';

abstract class SceneRepository {
  /// Возвращает все сцены из БД
  Future<List<Scene>> getAllScenes();
  /// Сохраняет сцену (создаёт или обновляет)
  Future<void> saveScene(Scene scene);
  /// Удаляет сцену по ID
  Future<void> deleteScene(String id);
  /// Выполняет сцену — отправляет все команды на устройства
  Future<void> executeScene(Scene scene);
}