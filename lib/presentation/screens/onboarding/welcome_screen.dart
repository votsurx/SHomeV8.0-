/// Приветственный экран онбординга.
/// Показывается при первом запуске приложения.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'package:shome/l10n/generated/app_localizations.dart';
import 'package:shome/presentation/widgets/language_selector_tile.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // На невысоком экране анимация уменьшается,
            // чтобы освободить место для выбора языка и кнопки.
            final animationSize =
            math.min(210.0, constraints.maxHeight * 0.28);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/Home.json',
                        width: animationSize,
                        height: animationSize,
                        repeat: true,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'SHome',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        l10n.welcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      const LanguageSelectorTile(),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/onboarding/scan');
                          },
                          child: Text(
                            l10n.startButton,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}