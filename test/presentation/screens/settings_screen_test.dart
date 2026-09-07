import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shome/presentation/screens/settings_screen.dart';

void main() {
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

    testWidgets('отображает О приложении', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('О приложении'), findsOneWidget);
      expect(find.textContaining('SHome v2'), findsOneWidget); // любая версия
    });

    testWidgets('нажатие на Резервное копирование открывает SimpleDialog', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      // Нажимаем на карточку «Резервное копирование»
      await tester.tap(find.text('Резервное копирование'));
      await tester.pumpAndSettle();

      // Должен открыться SimpleDialog
      expect(find.text('Экспортировать'), findsOneWidget);
      expect(find.text('Импортировать'), findsOneWidget);
    });

    testWidgets('нажатие на Интервал опроса открывает SimpleDialog с вариантами', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Интервал опроса'));
      await tester.pumpAndSettle();

      // Проверяем что варианты появились
      expect(find.text('2 секунд'), findsOneWidget);
      expect(find.text('5 секунд'), findsOneWidget);
      expect(find.text('10 секунд'), findsOneWidget);
      expect(find.text('30 секунд'), findsOneWidget);
    });

    testWidgets('нажатие на О приложении открывает AboutDialog', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('О приложении'));
      await tester.pumpAndSettle();

      // Должен открыться AboutDialog
      expect(find.text('SHome'), findsWidgets); // может быть несколько
    });
  });
}