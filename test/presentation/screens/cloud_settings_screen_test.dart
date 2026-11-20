import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shome/l10n/generated/app_localizations.dart';
import 'package:shome/presentation/screens/cloud_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Secure Storage возвращает пустые значения: облако не подключено.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      ),
          (call) async {
        switch (call.method) {
          case 'read':
            return null;
          case 'readAll':
            return <String, String>{};
          case 'write':
          case 'delete':
            return null;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      ),
      null,
    );
  });

  group('CloudSettingsScreen', () {
    testWidgets('отображает статус «Не подключено»', (tester) async {
      await tester.pumpWidget(_localizedApp());
      await tester.pumpAndSettle();

      expect(find.text('☁️ Облачное хранилище'), findsOneWidget);
      expect(find.textContaining('Не подключено'), findsOneWidget);
    });

    testWidgets('отображает поля ввода логина и пароля', (tester) async {
      await tester.pumpWidget(_localizedApp());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Логин'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Пароль приложения'),
        findsOneWidget,
      );
    });

    testWidgets('отображает кнопку «Подключить»', (tester) async {
      await tester.pumpWidget(_localizedApp());
      await tester.pumpAndSettle();

      expect(find.text('Подключить'), findsOneWidget);
    });

    testWidgets('отображает подсказку о пароле приложения', (tester) async {
      await tester.pumpWidget(_localizedApp());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Как получить пароль приложения'),
        findsOneWidget,
      );
      expect(find.textContaining('Mail.ru'), findsOneWidget);
      expect(find.textContaining('SHome'), findsOneWidget);
    });

    testWidgets('кнопка «Подключить» находится в ElevatedButton',
            (tester) async {
          await tester.pumpWidget(_localizedApp());
          await tester.pumpAndSettle();

          final button = find.ancestor(
            of: find.text('Подключить'),
            matching: find.byType(ElevatedButton),
          );

          expect(button, findsOneWidget);
        });

    testWidgets('можно ввести логин и пароль', (tester) async {
      await tester.pumpWidget(_localizedApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Логин'),
        'user@mail.ru',
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Пароль приложения'),
        'secret',
      );
      await tester.pump();

      expect(find.text('user@mail.ru'), findsOneWidget);
      expect(find.text('secret'), findsOneWidget);
    });
  });
}

Widget _localizedApp() {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const CloudSettingsScreen(),
  );
}