import 'package:flutter_test/flutter_test.dart';
import 'package:shome/application/services/presence_warning_controller.dart';

void main() {
  group('PresenceWarningController', () {
    late PresenceWarningController controller;

    setUp(() {
      controller = PresenceWarningController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('изначально предупреждение неактивно', () {
      expect(controller.isActive, isFalse);
      expect(controller.state, isNull);
    });

    test('show сохраняет состояние и оповещает слушателей', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.show(
        sceneId: 'nobody_home',
        sceneName: 'Никого нет дома',
        unknownPhoneNames: const ['Телефон мамы', 'Телефон папы'],
        remainingSeconds: 300,
      );

      expect(controller.isActive, isTrue);
      expect(controller.state!.sceneId, 'nobody_home');
      expect(controller.state!.sceneName, 'Никого нет дома');
      expect(
        controller.state!.unknownPhoneNames,
        ['Телефон мамы', 'Телефон папы'],
      );
      expect(controller.state!.remainingSeconds, 300);
      expect(notifications, 1);
    });

    test('обновляет обратный отсчёт и не допускает отрицательного значения',
            () {
          controller.show(
            sceneId: 'nobody_home',
            sceneName: 'Никого нет дома',
            unknownPhoneNames: const ['Телефон мамы'],
            remainingSeconds: 300,
          );

          controller.updateRemainingSeconds(42);
          expect(controller.state!.remainingSeconds, 42);

          controller.updateRemainingSeconds(-5);
          expect(controller.state!.remainingSeconds, 0);
        });

    test('обновляет список телефонов со статусом unknown', () {
      controller.show(
        sceneId: 'nobody_home',
        sceneName: 'Никого нет дома',
        unknownPhoneNames: const ['Телефон мамы'],
        remainingSeconds: 300,
      );

      controller.updateUnknownPhoneNames(
        const ['Телефон папы', 'Телефон ребёнка'],
      );

      expect(
        controller.state!.unknownPhoneNames,
        ['Телефон папы', 'Телефон ребёнка'],
      );
      expect(controller.state!.remainingSeconds, 300);
    });

    test('requestCancel вызывает зарегистрированный обработчик', () {
      var cancelled = false;
      controller.setCancelHandler(() => cancelled = true);

      controller.requestCancel();

      expect(cancelled, isTrue);
    });

    test('clear сбрасывает предупреждение', () {
      controller.show(
        sceneId: 'nobody_home',
        sceneName: 'Никого нет дома',
        unknownPhoneNames: const ['Телефон мамы'],
        remainingSeconds: 300,
      );

      controller.clear();

      expect(controller.isActive, isFalse);
      expect(controller.state, isNull);
    });

    test('повторный clear не вызывает лишних уведомлений', () {
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.show(
        sceneId: 'nobody_home',
        sceneName: 'Никого нет дома',
        unknownPhoneNames: const ['Телефон мамы'],
        remainingSeconds: 300,
      );

      controller.clear();
      controller.clear();

      expect(notifications, 2);
    });
  });
}