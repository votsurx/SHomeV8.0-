/// Тема приложения — светлая и тёмная.
/// Использует Material 3 с Dynamic Color.
/// Цветовая схема генерируется из seedColor (primary).
library;
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  /// Светлая тема Material 3.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
    );
  }

  /// Тёмная тема Material 3.
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
    );
  }
}