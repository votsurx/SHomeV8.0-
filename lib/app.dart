/// Корневой виджет приложения.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'application/navigation/router.dart';
import 'application/state/presence_detector_provider.dart';
import 'application/state/theme_provider.dart';
import 'data/services/screen_saver_settings.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/screen_saver_host.dart';

class SHomeApp extends StatefulWidget {
  const SHomeApp({super.key});

  @override
  State<SHomeApp> createState() => _SHomeAppState();
}

class _SHomeAppState extends State<SHomeApp> {
  @override
  void initState() {
    super.initState();
    unawaited(ScreenSaverSettings.load());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(presenceDetectorProvider);
        final themeMode = ref.watch(themeProvider);

        return MaterialApp.router(
          title: 'SHome',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, routerChild) {
            return ValueListenableBuilder<ScreenSaverConfig>(
              valueListenable: ScreenSaverSettings.value,
              builder: (context, config, _) {
                return ScreenSaverHost(
                  enabled: config.enabled,
                  idleTimeout: Duration(seconds: config.idleTimeoutSeconds),
                  motionWakeEnabled: config.motionWakeEnabled,
                  iconSize: 180,
                  motionSensitivity: config.motionSensitivity,
                  screenSaverBuilder: (context) {
                    return Lottie.asset(
                      'assets/animations/Home.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    );
                  },
                  child: routerChild ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}