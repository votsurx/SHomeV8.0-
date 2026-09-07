/// Маппер между доменной моделью Scene и сущностью SQLite SceneEntity.
/// Действия (actions) сериализуются в JSON-строку и обратно.
/// Триггеры преобразуются между enum и строкой.
library;
import 'dart:convert';
import '../../domain/models/scene.dart';
import '../local/entities/scene_entity.dart';

class SceneMapper {
  /// Преобразует доменную модель Scene в сущность для сохранения в БД.
  /// - actions преобразуется в JSON-строку через jsonEncode.
  /// - TriggerType, RepeatType сохраняются как строки через .name.
  static SceneEntity toEntity(Scene scene) => SceneEntity(
    id: scene.id,
    name: scene.name,
    icon: scene.icon,
    actions: jsonEncode(scene.actions.map((a) => a.toJson()).toList()),
    triggerType: scene.trigger?.type.name,
    triggerTime: scene.trigger?.time,
    triggerRepeat: scene.trigger?.repeat.name,
  );

  /// Преобразует сущность БД в доменную модель Scene.
  /// - actions десериализуется из JSON-строки в список SceneAction.
  /// - TriggerType, RepeatType восстанавливаются через enum.values.firstWhere.
  /// - Если triggerType == null — сцена ручная (trigger = null).
  static Scene toDomain(SceneEntity entity) => Scene(
    id: entity.id,
    name: entity.name,
    icon: entity.icon,
    actions: (jsonDecode(entity.actions) as List).map((a) => SceneAction.fromJson(a)).toList(),
    trigger: entity.triggerType != null
        ? SceneTrigger(
      type: TriggerType.values.firstWhere((t) => t.name == entity.triggerType),
      time: entity.triggerTime,
      repeat: entity.triggerRepeat != null
          ? RepeatType.values.firstWhere((r) => r.name == entity.triggerRepeat)
          : RepeatType.once,
    )
        : null,
  );
}