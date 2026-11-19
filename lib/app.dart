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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'data/services/language_preference.dart';
import 'l10n/generated/app_localizations.dart';

class SHomeApp extends StatefulWidget {
  const SHomeApp({super.key});

  @override
  State<SHomeApp> createState() => _SHomeAppState();
}

class _SHomeAppState extends State<SHomeApp> {
  @override
  void initState() {
    super.initState();
    unawaited(LanguagePreference.load());
    unawaited(ScreenSaverSettings.load());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(presenceDetectorProvider);
        final themeMode = ref.watch(themeProvider);

        return ValueListenableBuilder<String>(
          valueListenable: LanguagePreference.value,
          builder: (context, languageCode, _) {
            final Locale? appLocale =
            languageCode == LanguagePreference.system
                ? null
                : Locale(languageCode);

            return MaterialApp.router(
              title: 'SHome',
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              routerConfig: router,
              debugShowCheckedModeBanner: false,

              // null означает «Как в системе».
              locale: appLocale,

              // Эти делегаты предоставляют AppLocalizations и системные
              // переводы Flutter Material, Widgets и Cupertino.
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,

              builder: (context, routerChild) {
                return ValueListenableBuilder<ScreenSaverConfig>(
                  valueListenable: ScreenSaverSettings.value,
                  builder: (context, screenConfig, _) {
                    return ScreenSaverHost(
                      enabled: screenConfig.enabled,
                      idleTimeout: Duration(
                        seconds: screenConfig.idleTimeoutSeconds,
                      ),
                      motionWakeEnabled:
                      screenConfig.motionWakeEnabled,
                      motionSensitivity:
                      screenConfig.motionSensitivity,
                      iconSize: 180,
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
      },
    );
  }
}