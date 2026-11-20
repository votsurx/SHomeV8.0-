import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shome/presentation/widgets/screen_saver_host.dart';

void main() {
  group('ScreenSaverHost', () {
    testWidgets(
      'временно скрывает заставку и не показывает её при подавлении',
          (tester) async {
        await tester.pumpWidget(const _ScreenSaverTestApp());

        // Дожидаемся показа заставки по таймеру бездействия.
        await tester.pump(const Duration(milliseconds: 60));
        expect(find.byKey(const ValueKey('screen-saver')), findsOneWidget);

        // В тесте переключаем состояние родителя напрямую: видимая заставка
        // намеренно перекрывает кнопки основного экрана.
        tester.state<_ScreenSaverTestAppState>(
          find.byType(_ScreenSaverTestApp),
        ).setSuppression(true);
        await tester.pump();

        expect(find.byKey(const ValueKey('screen-saver')), findsNothing);

        // Пока подавление активно, заставка не включается снова.
        await tester.pump(const Duration(seconds: 2));
        expect(find.byKey(const ValueKey('screen-saver')), findsNothing);

        // Снимаем подавление: запускается новый таймер бездействия.
        tester.state<_ScreenSaverTestAppState>(
          find.byType(_ScreenSaverTestApp),
        ).setSuppression(false);
        await tester.pump();

        expect(find.byKey(const ValueKey('screen-saver')), findsNothing);

        await tester.pump(const Duration(milliseconds: 60));
        expect(find.byKey(const ValueKey('screen-saver')), findsOneWidget);
      },
    );
  });
}

class _ScreenSaverTestApp extends StatefulWidget {
  const _ScreenSaverTestApp();

  @override
  State<_ScreenSaverTestApp> createState() => _ScreenSaverTestAppState();
}

class _ScreenSaverTestAppState extends State<_ScreenSaverTestApp> {
  bool _suppressScreenSaver = false;

  void setSuppression(bool value) {
    setState(() {
      _suppressScreenSaver = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ScreenSaverHost(
          enabled: true,
          suppressScreenSaver: _suppressScreenSaver,
          idleTimeout: const Duration(milliseconds: 50),
          motionWakeEnabled: false,
          screenSaverBuilder: (_) => const ColoredBox(
            key: ValueKey('screen-saver'),
            color: Colors.black,
          ),
          child: const Center(
            child: Text('Основной экран'),
          ),
        ),
      ),
    );
  }
}