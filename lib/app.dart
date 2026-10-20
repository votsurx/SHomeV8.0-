/// Корневой виджет приложения.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/navigation/router.dart';
import 'application/state/presence_detector_provider.dart';
import 'application/state/theme_provider.dart';
import 'presentation/theme/app_theme.dart';

class SHomeApp extends StatelessWidget {
  const SHomeApp({super.key});

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
        );
      },
    );
  }
}