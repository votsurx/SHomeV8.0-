/// Утилиты для хранения порядка элементов (id) в SharedPreferences.
/// Используется в экранах со сортировкой: меню, настройки.
/// Устройства сортируются через DevicesNotifier (своя логика),
/// но алгоритм тот же — OrderStorage.reorder().
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderStorage {
  /// Загружает порядок из SharedPreferences.
  /// - Если ключа нет — возвращает [defaultOrder].
  /// - Удаляет из сохранённого порядка id, которых нет в [defaultOrder].
  /// - Добавляет в конец новые id из [defaultOrder], которых нет в сохранённом.
  static Future<List<String>> load(
      String key,
      List<String> defaultOrder,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json == null) return List<String>.from(defaultOrder);

    final saved = (jsonDecode(json) as List).cast<String>();
    final known = defaultOrder.toSet();
    final filtered = saved.where(known.contains).toList();
    for (final id in defaultOrder) {
      if (!filtered.contains(id)) filtered.add(id);
    }
    return filtered;
  }

  /// Сохраняет порядок в SharedPreferences.
  static Future<void> save(String key, List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(order));
  }

  /// Сбрасывает порядок (удаляет ключ).
  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Перемещает элемент и возвращает новый список.
  /// Логика идентична DevicesNotifier.reorderDevices.
  static List<String> reorder(
      List<String> current,
      int oldIndex,
      int newIndex,
      ) {
    final list = [...current];
    if (oldIndex < newIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return list;
  }
}