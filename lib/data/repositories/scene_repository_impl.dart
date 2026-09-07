/// Реализация репозитория сцен.
/// Кэширует сцены в Map(String, Scene).
/// Выполняет сцены, отправляя команды на устройства через DeviceRepository.
library;
import '../../domain/models/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../local/database.dart';
import '../mappers/scene_mapper.dart';

class SceneRepositoryImpl implements SceneRepository {
  /// Репозиторий устройств для выполнения команд
  final DeviceRepository _deviceRepository;
  /// Кэш сцен в памяти
  final Map<String, Scene> _scenes = {};

  SceneRepositoryImpl(this._deviceRepository);

  /// Возвращает все сцены. При первом вызове загружает из БД.
  @override
  Future<List<Scene>> getAllScenes() async {
    if (_scenes.isEmpty) {
      final entities = await AppDatabase.getAllScenes();
      for (final e in entities) {
        _scenes[e.id] = SceneMapper.toDomain(e);
      }
    }
    return _scenes.values.toList();
  }

  /// Сохраняет сцену в кэш и БД.
  @override
  Future<void> saveScene(Scene scene) async {
    _scenes[scene.id] = scene;
    await AppDatabase.insertScene(SceneMapper.toEntity(scene));
  }

  /// Удаляет сцену из кэша и БД.
  @override
  Future<void> deleteScene(String id) async {
    _scenes.remove(id);
    await AppDatabase.deleteScene(id);
  }

  /// Выполняет сцену: для каждого действия отправляет команду на устройство.
  /// Поддерживает команды turnOn и turnOff.
  @override
  Future<void> executeScene(Scene scene) async {
    for (final action in scene.actions) {
      switch (action.command) {
        case 'turnOn': await _deviceRepository.turnOn(action.deviceId);
        case 'turnOff': await _deviceRepository.turnOff(action.deviceId);
      }
    }
  }
}