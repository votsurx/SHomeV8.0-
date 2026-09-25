import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shome/presentation/screens/settings_screen.dart';
import 'package:shome/presentation/screens/documents/legal_documents_screen.dart';

void main() {
  // Инициализируем биндинг — нужен для SharedPreferences в тестах
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'poll_interval': 5});
    });

    testWidgets('отображает интервал опроса', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Интервал опроса'), findsOneWidget);
      expect(find.text('5 сек'), findsOneWidget);
    });

    testWidgets('отображает резервное копирование', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Резервное копирование'), findsOneWidget);
    });

    testWidgets('отображает Информацию', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      // Плитка называется «Информация», а не «О приложении»
      expect(find.text('Информация'), findsOneWidget);
    });

    testWidgets('отображает NVR и MyiSpy', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Видео NVR'), findsOneWidget);
      expect(find.text('Видео MyiSpy'), findsOneWidget);
    });

    testWidgets('нажатие на Резервное копирование открывает SimpleDialog',
            (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Резервное копирование'));
          await tester.pumpAndSettle();

          // В SimpleDialog должны быть пункты экспорта/импорта
          expect(find.text('Экспортировать'), findsOneWidget);
          expect(find.text('Импортировать'), findsOneWidget);
        });

    testWidgets('нажатие на Интервал опроса открывает SimpleDialog с вариантами',
            (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Интервал опроса'));
          await tester.pumpAndSettle();

          expect(find.text('2 секунд'), findsOneWidget);
          expect(find.text('5 секунд'), findsOneWidget);
          expect(find.text('10 секунд'), findsOneWidget);
          expect(find.text('30 секунд'), findsOneWidget);
        });

    testWidgets('нажатие на Информация открывает LegalDocumentsScreen',
            (tester) async {
          await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Информация'));
          await tester.pumpAndSettle();

          // Проверяем, что открылся экран с юридическими документами
          expect(find.byType(LegalDocumentsScreen), findsOneWidget);
          expect(find.text('Лицензионное соглашение (EULA)'), findsOneWidget);
          expect(find.text('Политика конфиденциальности'), findsOneWidget);
          expect(find.text('Условия использования'), findsOneWidget);
        });
  });
}