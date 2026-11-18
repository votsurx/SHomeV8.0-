import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:shome/data/local/database.dart';
import 'package:shome/data/services/adaptive_poller.dart';
import 'package:shome/presentation/screens/documents/legal_documents_screen.dart';
import 'package:shome/presentation/screens/screen_settings_screen.dart';
import 'package:shome/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await AppDatabase.database;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AdaptivePoller.writeIntervalMs(5000);
  });

  Future<void> settleDatabaseTimers(WidgetTester tester) async {
    // AppDatabase.getStatsSetting внутри FutureBuilder использует SQLite.
    // Продвигаем fake clock дальше 10-секундного тайм-аута sqflite.
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
  }

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          statsSettingReader: (key) async {
            if (key == 'events_retention_days') return '30';
            if (key == 'electricity_tariff_rub_per_kwh') return '5.5';
            return null;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> scrollToText(
      WidgetTester tester,
      String text,
      ) async {
    await tester.scrollUntilVisible(
      find.text(text),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await settleDatabaseTimers(tester);
  }

  group('SettingsScreen', () {
    testWidgets('отображает заголовок и интервал опроса', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Интервал опроса'), findsOneWidget);
      expect(
        find.text(AdaptivePoller.formatIntervalMs(5000)),
        findsOneWidget,
      );
    });

    testWidgets('отображает настройки экрана', (tester) async {
      await pumpSettings(tester);

      expect(find.text('Настройки экрана'), findsOneWidget);
      expect(find.text('Заставка и отображение'), findsOneWidget);
    });

    testWidgets('основные пункты настроек доступны при прокрутке',
            (tester) async {
          await pumpSettings(tester);

          const items = [
            'Интервал опроса',
            'Настройки экрана',
            'Хранить события',
            'Тариф электроэнергии',
            'Резервное копирование',
            'Настройки MQTT',
            'Проверить обновления',
            'Информация',
          ];

          for (final item in items) {
            await scrollToText(tester, item);
            expect(find.text(item), findsOneWidget);
          }
        });

    testWidgets('настройки экрана открывают ScreenSettingsScreen',
            (tester) async {
          await pumpSettings(tester);

          await tester.tap(find.text('Настройки экрана'));
          await tester.pumpAndSettle();

          expect(find.byType(ScreenSettingsScreen), findsOneWidget);
          expect(find.text('Заставка'), findsOneWidget);
        });

    testWidgets(
      'резервное копирование открывает диалог экспорта и импорта',
          (tester) async {
        await pumpSettings(tester);

        await tester.tap(find.text('Резервное копирование'));
        await tester.pumpAndSettle();

        expect(find.text('Экспортировать'), findsOneWidget);
        expect(find.text('Импортировать'), findsOneWidget);
      },
    );

    testWidgets('интервал опроса показывает актуальные варианты',
            (tester) async {
          await pumpSettings(tester);

          await tester.tap(find.text('Интервал опроса'));
          await tester.pumpAndSettle();

          final dialog = find.byType(SimpleDialog);
          expect(dialog, findsOneWidget);

          for (final label in AdaptivePoller.intervalOptions.values) {
            expect(
              find.descendant(
                of: dialog,
                matching: find.text(label),
              ),
              findsOneWidget,
              reason: 'В диалоге должен быть вариант "$label"',
            );
          }
        });

    testWidgets('Информация открывает экран юридических документов',
            (tester) async {
          await pumpSettings(tester);

          await scrollToText(tester, 'Информация');
          await tester.tap(find.text('Информация'));
          await tester.pumpAndSettle();

          expect(find.byType(LegalDocumentsScreen), findsOneWidget);
        });
  });
}