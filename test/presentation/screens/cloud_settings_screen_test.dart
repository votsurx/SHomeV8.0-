import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shome/presentation/screens/cloud_settings_screen.dart';
import 'package:flutter/services.dart';

void main() {
  group('CloudSettingsScreen', () {
    setUp(() async {
      // Мок для FlutterSecureStorage — все значения null (не подключено)
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (call) async {
          if (call.method == 'read') return null;
          if (call.method == 'readAll') return <String, String>{};
          if (call.method == 'write') return null;
          if (call.method == 'delete') return null;
          return null;
        },
      );
    });

    testWidgets('отображает статус Не подключено', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CloudSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('☁️ Облачное хранилище'), findsOneWidget);
      expect(find.textContaining('Не подключено'), findsOneWidget);
    });

    testWidgets('отображает поля ввода логина и пароля', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CloudSettingsScreen()));
      await tester.pumpAndSettle();

      // Поле логина
      expect(find.widgetWithText(TextField, 'Логин'), findsOneWidget);
      // Поле пароля
      expect(find.widgetWithText(TextField, 'Пароль приложения'), findsOneWidget);
    });

    testWidgets('отображает кнопку Подключить', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CloudSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Подключить'), findsOneWidget);
    });

    testWidgets('отображает подсказку о пароле приложения', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CloudSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Как получить пароль приложения'), findsOneWidget);
      expect(find.textContaining('Mail.ru'), findsOneWidget);
      expect(find.textContaining('SHome'), findsOneWidget);
    });

    testWidgets('кнопка Подключить отображается', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CloudSettingsScreen()));
      await tester.pumpAndSettle();

      // Проверяем что ElevatedButton с текстом «Подключить» существует
      final button = find.ancestor(
        of: find.text('Подключить'),
        matching: find.byType(ElevatedButton),
      );
      expect(button, findsOneWidget);
    });

    testWidgets('можно ввести логин и пароль', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CloudSettingsScreen()));
      await tester.pumpAndSettle();

      // Вводим логин
      await tester.enterText(find.widgetWithText(TextField, 'Логин'), 'user@mail.ru');
      await tester.pumpAndSettle();

      // Вводим пароль
      await tester.enterText(find.widgetWithText(TextField, 'Пароль приложения'), 'secret');
      await tester.pumpAndSettle();

      // Проверяем что ввелось
      expect(find.text('user@mail.ru'), findsOneWidget);
      expect(find.text('secret'), findsOneWidget);
    });
  });
}