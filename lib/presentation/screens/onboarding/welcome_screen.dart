/// Приветственный экран онбординга.
/// Показывается при первом запуске приложения.
/// Кнопка "Начать" ведёт на сканер устройств.
library;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Иконка дома
              // Вместо Icon(Icons.home_rounded) поставить:
              Lottie.asset(
                'assets/animations/Home.json',
                width: 250,
                height: 250,
                repeat: true,
              ),
              const SizedBox(height: 32),
              // Название приложения
              Text(
                'SHome',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Подзаголовок
              Text(
                'Управляйте своим умным домом легко и просто',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              // Кнопка "Начать" — переход к сканеру устройств
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/onboarding/scan'),
                  child: const Text('Начать', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}