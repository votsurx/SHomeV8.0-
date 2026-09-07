/// Корневой виджет приложения.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/navigation/router.dart';
import 'application/state/theme_provider.dart';
import 'presentation/theme/app_theme.dart';
import 'application/state/nvr_provider.dart';

class SHomeApp extends StatelessWidget {
  const SHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) {
          // ✅ ЗАГРУЖАЕМ NVR НАСТРОЙКИ ПРИ СТАРТЕ
          ref.watch(nvrSettingsProvider);
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
      ),
    );
  }
}