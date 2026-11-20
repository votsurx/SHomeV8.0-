import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';
import 'package:shome/application/services/presence_warning_controller.dart';
import 'package:shome/data/services/automation_engine.dart';
import 'package:shome/data/services/presence_detector.dart';
import 'package:shome/domain/models/scene.dart';
import 'package:shome/domain/repositories/scene_repository.dart';

class _FakeSceneRepository implements SceneRepository {
  final List<Scene> scenes = [];
  final List<String> executedSceneIds = [];
  final Completer<void> firstExecution = Completer<void>();

  @override
  Future<List<Scene>> getAllScenes() async => List<Scene>.of(scenes);

  @override
  Future<void> saveScene(Scene scene) async {
    final index = scenes.indexWhere((item) => item.id == scene.id);

    if (index == -1) {
      scenes.add(scene);
    } else {
      scenes[index] = scene;
    }
  }

  @override
  Future<void> deleteScene(String id) async {
    scenes.removeWhere((scene) => scene.id == id);
  }

  @override
  Future<void> executeScene(Scene scene) async {
    executedSceneIds.add(scene.id);

    if (!firstExecution.isCompleted) {
      firstExecution.complete();
    }
  }
}

Scene _nobodyHomeScene() {
  return const Scene(
    id: 'nobody_home',
    name: 'Никого нет дома',
    icon: '🏠',
    actions: [],
    trigger: SceneTrigger(
      type: TriggerType.presence,
      presenceEvent: PresenceEvent.nobodyHome,
    ),
  );
}

PresenceCycleResult _cycle({
  required PhonePresenceStatus status,
  required PresenceCloudAvailability cloud,
  DateTime? checkedAt,
}) {
  return PresenceCycleResult(
    phones: {
      'phone-1': PresencePhoneSnapshot(
        phoneId: 'phone-1',
        phoneName: 'Телефон 1',
        status: status,
        source: PresenceSource.cloud,
        viaWifi: false,
      ),
    },
    cloudAvailability: cloud,
    checkedAt: checkedAt ?? DateTime.now(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutomationEngine — сцена «Никого нет дома»', () {
    late _FakeSceneRepository repository;
    late PresenceWarningController warningController;
    late AutomationEngine engine;

    setUp(() async {
      repository = _FakeSceneRepository();
      await repository.saveScene(_nobodyHomeScene());

      warningController = PresenceWarningController();

      engine = AutomationEngine(
        repository,
        Talker(settings: TalkerSettings(enabled: false)),
        warningController: warningController,
        awayTimeoutReader: () async => 0,
        presenceWarningDuration: const Duration(seconds: 1),
        presenceWarningTickInterval: const Duration(milliseconds: 5),
      );

      engine.start();
    });

    tearDown(() {
      engine.stop();
      warningController.dispose();
    });

    test('после запуска по unknown переход в away не запускает сцену повторно',
            () async {
          await engine.processPresenceCycle(
            _cycle(
              status: PhonePresenceStatus.unknown,
              cloud: PresenceCloudAvailability.available,
            ),
          );

          await repository.firstExecution.future.timeout(
            const Duration(seconds: 2),
          );

          expect(repository.executedSceneIds, ['nobody_home']);

          await engine.processPresenceCycle(
            _cycle(
              status: PhonePresenceStatus.away,
              cloud: PresenceCloudAvailability.available,
            ),
          );

          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(repository.executedSceneIds, ['nobody_home']);
          expect(warningController.isActive, isFalse);
        });

    test('все телефоны away запускают сцену без предупреждения', () async {
      await engine.processPresenceCycle(
        _cycle(
          status: PhonePresenceStatus.away,
          cloud: PresenceCloudAvailability.available,
        ),
      );

      await repository.firstExecution.future.timeout(
        const Duration(seconds: 1),
      );

      expect(repository.executedSceneIds, ['nobody_home']);
      expect(warningController.isActive, isFalse);
    });

    test('unknown показывает предупреждение, но не запускает сцену сразу',
            () async {
          final cycle = _cycle(
            status: PhonePresenceStatus.unknown,
            cloud: PresenceCloudAvailability.available,
          );

          await engine.processPresenceCycle(cycle);

          expect(warningController.isActive, isTrue);
          expect(warningController.state!.sceneId, 'nobody_home');
          expect(warningController.state!.sceneName, 'Никого нет дома');
          expect(
            warningController.state!.unknownPhoneNames,
            ['Телефон 1'],
          );
          expect(
            warningController.state!.remainingSeconds,
            greaterThan(0),
          );
          expect(repository.executedSceneIds, isEmpty);

          // Обработка результата автоматики не меняет фактический статус.
          expect(
            cycle.phones['phone-1']!.status,
            PhonePresenceStatus.unknown,
          );
        });

    test('сцена запускается после окончания предупреждения для unknown',
            () async {
          await engine.processPresenceCycle(
            _cycle(
              status: PhonePresenceStatus.unknown,
              cloud: PresenceCloudAvailability.available,
            ),
          );

          expect(warningController.isActive, isTrue);
          expect(repository.executedSceneIds, isEmpty);

          await repository.firstExecution.future.timeout(
            const Duration(seconds: 2),
          );

          expect(repository.executedSceneIds, ['nobody_home']);
          expect(warningController.isActive, isFalse);
        });

    test('нажатие отмены скрывает предупреждение и блокирует повторный показ',
            () async {
          final cycle = _cycle(
            status: PhonePresenceStatus.unknown,
            cloud: PresenceCloudAvailability.available,
          );

          await engine.processPresenceCycle(cycle);

          expect(warningController.isActive, isTrue);

          warningController.requestCancel();

          expect(warningController.isActive, isFalse);

          // Тот же продолжающийся эпизод unknown не показывает баннер заново.
          await engine.processPresenceCycle(cycle);

          expect(warningController.isActive, isFalse);
          expect(repository.executedSceneIds, isEmpty);
        });

    test('подтверждённый home отменяет активное предупреждение', () async {
      await engine.processPresenceCycle(
        _cycle(
          status: PhonePresenceStatus.unknown,
          cloud: PresenceCloudAvailability.available,
        ),
      );

      expect(warningController.isActive, isTrue);

      await engine.processPresenceCycle(
        _cycle(
          status: PhonePresenceStatus.home,
          cloud: PresenceCloudAvailability.available,
        ),
      );

      expect(warningController.isActive, isFalse);
      expect(repository.executedSceneIds, isEmpty);
    });

    test('недоступное облако не запускает сцену и не показывает баннер',
            () async {
          await engine.processPresenceCycle(
            _cycle(
              status: PhonePresenceStatus.unknown,
              cloud: PresenceCloudAvailability.unavailable,
            ),
          );

          expect(warningController.isActive, isFalse);
          expect(repository.executedSceneIds, isEmpty);
        });
  });
}