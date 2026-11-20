/// Корневой виджет приложения.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'application/navigation/router.dart';
import 'application/services/presence_warning_controller.dart';
import 'application/state/presence_detector_provider.dart';
import 'application/state/theme_provider.dart';
import 'data/services/language_preference.dart';
import 'data/services/screen_saver_settings.dart';
import 'di/injection.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/presence_warning_banner.dart';
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
    unawaited(LanguagePreference.load());
    unawaited(ScreenSaverSettings.load());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(presenceDetectorProvider);

        final themeMode = ref.watch(themeProvider);
        final warningController = getIt<PresenceWarningController>();

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

              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,

              builder: (context, routerChild) {
                final l10n = AppLocalizations.of(context);

                return ValueListenableBuilder<ScreenSaverConfig>(
                  valueListenable: ScreenSaverSettings.value,
                  builder: (context, screenConfig, _) {
                    return AnimatedBuilder(
                      animation: warningController,
                      builder: (context, _) {
                        final warning = warningController.state;

                        return ScreenSaverHost(
                          enabled: screenConfig.enabled,
                          suppressScreenSaver: warning != null,
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
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              routerChild ?? const SizedBox.shrink(),
                              if (warning != null)
                                PresenceWarningBanner(
                                  sceneName: warning.sceneName,
                                  unknownPhoneNames:
                                  warning.unknownPhoneNames,
                                  remainingSeconds:
                                  warning.remainingSeconds,
                                  title: l10n.presenceWarningTitle,
                                  message: l10n.presenceWarningMessage,
                                  cancelLabel: l10n.presenceCancel,
                                  onCancel:
                                  warningController.requestCancel,
                                ),
                            ],
                          ),
                        );
                      },
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