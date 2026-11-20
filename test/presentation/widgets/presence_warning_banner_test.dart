import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shome/presentation/widgets/presence_warning_banner.dart';

void main() {
  group('PresenceWarningBanner', () {
    testWidgets('показывает сценарий, неизвестные телефоны и отсчёт',
            (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    PresenceWarningBanner(
                      sceneName: 'Никого нет дома',
                      unknownPhoneNames: const ['Телефон мамы', 'Телефон папы'],
                      remainingSeconds: 287,
                      title: 'Внимание!!!',
                      message: 'Запускается сценарий:',
                      cancelLabel: 'Отменить запуск',
                      onCancel: () {},
                    ),
                  ],
                ),
              ),
            ),
          );

          expect(find.text('Внимание!!!'), findsOneWidget);
          expect(find.text('Запускается сценарий:'), findsOneWidget);
          expect(find.text('Никого нет дома'), findsOneWidget);
          expect(find.text('Телефон мамы, Телефон папы'), findsOneWidget);
          expect(find.text('04:47'), findsOneWidget);
          expect(find.text('Отменить запуск'), findsOneWidget);
        });

    testWidgets('нажатие кнопки вызывает отмену', (tester) async {
      var cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                PresenceWarningBanner(
                  sceneName: 'Никого нет дома',
                  unknownPhoneNames: const ['Телефон мамы'],
                  remainingSeconds: 300,
                  title: 'Внимание!!!',
                  message: 'Запускается сценарий:',
                  cancelLabel: 'Отменить запуск',
                  onCancel: () => cancelCalled = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Отменить запуск'));
      expect(cancelCalled, isTrue);
    });

    testWidgets('отрицательный отсчёт отображается как 00:00',
            (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Stack(
                  children: [
                    PresenceWarningBanner(
                      sceneName: 'Никого нет дома',
                      unknownPhoneNames: const [],
                      remainingSeconds: -1,
                      title: 'Внимание!!!',
                      message: 'Запускается сценарий:',
                      cancelLabel: 'Отменить запуск',
                      onCancel: () {},
                    ),
                  ],
                ),
              ),
            ),
          );

          expect(find.text('00:00'), findsOneWidget);
        });
  });
}