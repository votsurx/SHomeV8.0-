/// Провайдер темы на Riverpod.
/// Управляет переключением темы: День → Ночь → Авто → День.
/// Сохраняет выбор в SharedPreferences.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'system';
    state = _parseTheme(value);
  }

  /// Переключает: День → Ночь → Авто → День...
  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('auto_theme') ?? false;

    if (auto) {
      // Авто → Ночь
      state = ThemeMode.dark;
      await prefs.setString(_key, 'dark');
      await prefs.setBool('auto_theme', false);
    } else if (state == ThemeMode.dark) {
      // Ночь → День
      state = ThemeMode.light;
      await prefs.setString(_key, 'light');
    } else {
      // День → Авто
      state = ThemeMode.system; // ← system = авто
      await prefs.setString(_key, 'system');
      await prefs.setBool('auto_theme', true);
    }
    await updateAutoCache();
  }

  Future<void> setDark() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('auto_theme') ?? false;
    if (!auto) return; // только в авто-режиме
    state = ThemeMode.dark;
    await prefs.setString(_key, 'dark');
  }

  Future<void> setLight() async {
    final prefs = await SharedPreferences.getInstance();
    final auto = prefs.getBool('auto_theme') ?? false;
    if (!auto) return;
    state = ThemeMode.light;
    await prefs.setString(_key, 'light');
  }

  ThemeMode _parseTheme(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String get themeName {
    if (_isAuto) return 'Авто';
    switch (state) {
      case ThemeMode.dark: return 'Ночь';
      case ThemeMode.light: return 'День';
      default: return 'Ночь';
    }
  }

  IconData get themeIcon {
    if (_isAuto) return Icons.brightness_auto;
    switch (state) {
      case ThemeMode.dark: return Icons.nightlight_round;
      case ThemeMode.light: return Icons.wb_sunny;
      default: return Icons.nightlight_round;
    }
  }

  /// Синхронно проверяет авто (костыль, но работает)
  bool get _isAuto {
    // Не можем использовать await в геттере, поэтому синхронно читаем SharedPreferences
    // Используем static переменную как кеш
    return _autoCache;
  }

  static bool _autoCache = false;

  static Future<void> updateAutoCache() async {
    final prefs = await SharedPreferences.getInstance();
    _autoCache = prefs.getBool('auto_theme') ?? false;
  }
}