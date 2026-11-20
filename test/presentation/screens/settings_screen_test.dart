import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:shome/data/local/database.dart';
import 'package:shome/data/services/adaptive_poller.dart';
import 'package:shome/presentation/screens/documents/legal_documents_screen.dart';
import 'package:shome/presentation/screens/screen_settings_screen.dart';
import 'package:shome/presentation/screens/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shome/l10n/generated/app_localizations.dart';

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
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
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

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      );

      expect(find.text(l10n.settingsTitle), findsOneWidget);
      expect(find.text(l10n.settingsPollInterval), findsOneWidget);
      expect(find.text(l10n.settingsIntervalSeconds(5)), findsOneWidget);
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

    testWidgets('интервал опроса показывает актуальные варианты', (tester) async {
      await pumpSettings(tester);

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SettingsScreen)),
      );

      await tester.tap(find.text(l10n.settingsPollInterval));
      await tester.pumpAndSettle();

      final dialog = find.byType(SimpleDialog);
      expect(dialog, findsOneWidget);

      final expectedCounts = <String, int>{};

      for (final milliseconds in AdaptivePoller.intervalOptions.keys) {
        final label = milliseconds >= 60000 && milliseconds % 60000 == 0
            ? l10n.settingsIntervalMinutes(milliseconds ~/ 60000)
            : l10n.settingsIntervalSeconds((milliseconds / 1000).round());

        expectedCounts.update(
          label,
              (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      for (final entry in expectedCounts.entries) {
        expect(
          find.descendant(
            of: dialog,
            matching: find.text(entry.key),
          ),
          findsNWidgets(entry.value),
          reason:
          'В диалоге должно быть ${entry.value} пункт(а) с подписью "${entry.key}"',
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