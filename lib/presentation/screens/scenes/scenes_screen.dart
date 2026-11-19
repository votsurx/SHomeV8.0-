/// Экран сцен — создание, редактирование и выполнение сценариев автоматизации.
/// Сцены могут запускаться вручную (тап), по времени (через AutomationEngine)
/// или по датчику (через AdaptivePoller + ZigbeeBridge.onState).
/// Поддерживаются повторы: один раз, каждый день, по дням недели.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/device.dart';
import '../../../domain/models/scene.dart';
import '../../../application/state/scenes_provider.dart';
import '../../../application/state/devices_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'scene_helpers.dart';
import 'scene_editor_dialog.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scenes = ref.watch(scenesProvider);
    final devices = ref.watch(devicesProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final crossAxisCount = _calculateCrossAxisCount(screenWidth, isLandscape);
    final tileWidth = _calculateTileWidth(screenWidth, crossAxisCount);
    final scale = (tileWidth / 160).clamp(0.9, 1.8);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scenesTitle)),
      body: scenes.isEmpty
          ? Center(child: Text(l10n.scenesEmpty))
          : GridView.builder(
        padding: EdgeInsets.all(8 * scale),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8 * scale,
          mainAxisSpacing: 8 * scale,
        ),
        itemCount: scenes.length,
        itemBuilder: (context, index) {
          final scene = scenes[index];
          return Card(
            child: InkWell(
              onTap: () {
                if (scene.trigger == null ||
                    scene.trigger!.type == TriggerType.manual) {
                  ref.read(scenesProvider.notifier).executeScene(scene.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.scenesAutoTriggerMessage(scene.name), style: TextStyle(fontSize: 12 * scale)),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              onLongPress: () => _showSceneMenu(context, ref, scene),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(6 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(scene.icon,
                            style: TextStyle(fontSize: 16 * scale)),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            scene.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11 * scale,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5 * scale),
                    _buildTriggerInfo(scene, scale),
                    SizedBox(height: 4 * scale),
                    Divider(height: 1, thickness: 0.5),
                    SizedBox(height: 4 * scale),
                    Expanded(
                      child: _buildActionsList(scene, devices, scale),
                    ),
                    Text(
                      '${scene.actions.length} ${SceneHelpers.pluralize(scene.actions.length)}',
                      style: TextStyle(
                          fontSize: 8 * scale, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSceneDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  int _calculateCrossAxisCount(double width, bool isLandscape) {
    if (isLandscape) {
      if (width >= 1200) return 5;
      if (width >= 900) return 4;
      if (width >= 700) return 3;
      return 2;
    }
    if (width >= 900) return 3;
    if (width >= 300) return 2;
    return 1;
  }

  double _calculateTileWidth(double screenWidth, int crossAxisCount) {
    const horizontalPadding = 16.0;
    const spacing = 8.0;
    final available =
        screenWidth - horizontalPadding - (spacing * (crossAxisCount - 1));
    return available / crossAxisCount;
  }

  Widget _buildTriggerInfo(Scene scene, double scale) {
    if (scene.trigger == null || scene.trigger!.type == TriggerType.manual) {
      return Row(
        children: [
          Icon(Icons.touch_app, size: 11 * scale, color: Colors.grey[600]),
          SizedBox(width: 2 * scale),
          Text(
            'Вручную',
            style: TextStyle(fontSize: 9 * scale, color: Colors.grey[600]),
          ),
        ],
      );
    }

    switch (scene.trigger!.type) {
      case TriggerType.time:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('⏰', style: TextStyle(fontSize: 11 * scale)),
                SizedBox(width: 2 * scale),
                Text(
                  scene.trigger!.time ?? '--:--',
                  style: TextStyle(
                      fontSize: 10 * scale, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            if (scene.trigger!.repeat != RepeatType.once) ...[
              SizedBox(height: 2 * scale),
              Row(
                children: [
                  Text('🔄', style: TextStyle(fontSize: 9 * scale)),
                  SizedBox(width: 2 * scale),
                  Expanded(
                    child: Text(
                      scene.trigger!.repeat == RepeatType.weekly &&
                          scene.trigger!.repeatDays?.isNotEmpty == true
                          ? SceneHelpers.daysLabel(scene.trigger!.repeatDays)
                          : SceneHelpers.repeatLabel(scene.trigger!.repeat),
                      style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );

      case TriggerType.deviceState:
        return Row(
          children: [
            Text('🌡️', style: TextStyle(fontSize: 11 * scale)),
            SizedBox(width: 2 * scale),
            Expanded(
              child: Text(
                SceneHelpers.sensorConditionLabel(scene.trigger!),
                style: TextStyle(fontSize: 8 * scale),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );

      case TriggerType.presence:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('📍', style: TextStyle(fontSize: 11 * scale)),
                SizedBox(width: 2 * scale),
                Expanded(
                  child: Text(
                    SceneHelpers.presenceEventLabel(scene.trigger!),
                    style: TextStyle(
                        fontSize: 9 * scale, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (scene.trigger!.presencePhoneId != null) ...[
              SizedBox(height: 2 * scale),
              Text(
                scene.trigger!.presencePhoneId!,
                style: TextStyle(fontSize: 8 * scale, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionsList(Scene scene, List<Device> devices, double scale) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: scene.actions.length,
      itemBuilder: (context, index) {
        final action = scene.actions[index];
        final device =
            devices.where((d) => d.id == action.deviceId).firstOrNull;
        final deviceName = device?.name ?? 'Устройство';
        final deviceIcon = SceneHelpers.deviceIcon(device?.type);
        final actionLabel = SceneHelpers.actionLabel(action.command);
        final actionColor = SceneHelpers.actionColor(action.command);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 1 * scale),
          child: Row(
            children: [
              Text(deviceIcon, style: TextStyle(fontSize: 9 * scale)),
              SizedBox(width: 2 * scale),
              Expanded(
                child: Text(
                  deviceName,
                  style: TextStyle(fontSize: 8 * scale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 3 * scale, vertical: 1),
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 7 * scale,
                    fontWeight: FontWeight.bold,
                    color: actionColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSceneMenu(BuildContext context, WidgetRef ref, Scene scene) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Редактировать'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateSceneDialog(context, ref, existingScene: scene);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(scenesProvider.notifier).deleteScene(scene.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSceneDialog(BuildContext context, WidgetRef ref,
      {Scene? existingScene}) {
    showDialog(
      context: context,
      builder: (_) => SceneEditorDialog(existingScene: existingScene),
    );
  }
}