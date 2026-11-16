import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';
import 'package:shome/data/services/automation_engine.dart';
import 'package:shome/domain/models/scene.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AutomationEngine', () {
    late MockSceneRepository repo;
    late Talker talker;
    late AutomationEngine engine;

    setUp(() {
      repo = MockSceneRepository();
      talker = Talker(settings: TalkerSettings(enabled: false));
      engine = AutomationEngine(repo, talker);
    });

    tearDown(() {
      engine.stop();
    });

    // ─── time triggers ───

    test('time trigger: сцена с текущим временем выполняется', () async {
      final now = DateTime.now();
      final currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final scene = createTestScene(
        trigger: SceneTrigger(
          type: TriggerType.time,
          time: currentTime,
          repeat: RepeatType.daily,
        ),
      );
      await repo.saveScene(scene);

      await engine.checkTimeTriggers();

      expect(repo.executedSceneIds, contains('scene_1'));
    });

    test('time trigger: сцена с другим временем НЕ выполняется', () async {
      final now = DateTime.now();
      final other = now.add(const Duration(hours: 1));
      final otherTime =
          '${other.hour.toString().padLeft(2, '0')}:${other.minute.toString().padLeft(2, '0')}';

      final scene = createTestScene(
        trigger: SceneTrigger(
          type: TriggerType.time,
          time: otherTime,
          repeat: RepeatType.daily,
        ),
      );
      await repo.saveScene(scene);

      await engine.checkTimeTriggers();

      expect(repo.executedSceneIds, isEmpty);
    });

    test('time trigger: повторный вызов в ту же минуту НЕ выполняется',
            () async {
          final now = DateTime.now();
          final currentTime =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

          final scene = createTestScene(
            trigger: SceneTrigger(
              type: TriggerType.time,
              time: currentTime,
              repeat: RepeatType.daily,
            ),
          );
          await repo.saveScene(scene);

          await engine.checkTimeTriggers();
          expect(repo.executedSceneIds.length, 1);

          // Второй раз в ту же минуту — защита _isSameMinute
          await engine.checkTimeTriggers();
          expect(repo.executedSceneIds.length, 1);
        });

    test('time trigger: сцена без trigger не выполняется', () async {
      final scene = createTestScene(trigger: null);
      await repo.saveScene(scene);

      await engine.checkTimeTriggers();

      expect(repo.executedSceneIds, isEmpty);
    });

    test('time trigger: сцена с TriggerType.presence не выполняется по времени',
            () async {
          final now = DateTime.now();
          final currentTime =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

          final scene = createTestScene(
            trigger: SceneTrigger(
              type: TriggerType.presence,
              time: currentTime,
              presenceEvent: PresenceEvent.someoneHome,
            ),
          );
          await repo.saveScene(scene);

          await engine.checkTimeTriggers();

          expect(repo.executedSceneIds, isEmpty);
        });

    // ─── start/stop ───

    test('start/stop не падают', () {
      engine.start();
      engine.stop();
      expect(true, true);
    });

    test('stop идемпотентен — повторный вызов не падает', () {
      engine.start();
      engine.stop();
      engine.stop();
      expect(true, true);
    });
  });
}