import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/presence_settings.dart';

final presenceSettingsProvider =
StateNotifierProvider<PresenceSettingsNotifier, PresenceSettings>((ref) {
  return PresenceSettingsNotifier();
});

class PresenceSettingsNotifier extends StateNotifier<PresenceSettings> {
  PresenceSettingsNotifier() : super(PresenceSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final phonesJson = prefs.getString('presence_phones') ?? '[]';
    final phonesList = (jsonDecode(phonesJson) as List)
        .map((e) => PresencePhone.fromJson(e as Map<String, dynamic>))
        .toList();

    state = PresenceSettings(
      enabled: prefs.getBool('presence_enabled') ?? false,
      pairId: prefs.getString('presence_pair_id') ?? '',
      phones: phonesList,
      homeLat: prefs.getDouble('presence_home_lat') ?? 0.0,
      homeLng: prefs.getDouble('presence_home_lng') ?? 0.0,
      homeRadius: prefs.getInt('presence_home_radius') ?? 100,
      awayTimeoutMin: prefs.getInt('presence_away_timeout') ?? 5,
    );
  }

  Future<void> update(PresenceSettings settings) async {
    state = settings;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('presence_enabled', settings.enabled);
    await prefs.setString('presence_pair_id', settings.pairId);
    await prefs.setString(
      'presence_phones',
      jsonEncode(settings.phones.map((p) => p.toJson()).toList()),
    );
    await prefs.setDouble('presence_home_lat', settings.homeLat);
    await prefs.setDouble('presence_home_lng', settings.homeLng);
    await prefs.setInt('presence_home_radius', settings.homeRadius);
    await prefs.setInt('presence_away_timeout', settings.awayTimeoutMin);
  }

  Future<void> addPhone(PresencePhone phone) async {
    final updated = [...state.phones, phone];
    await update(state.copyWith(phones: updated));
  }

  Future<void> removePhone(String phoneId) async {
    final updated = state.phones.where((p) => p.phoneId != phoneId).toList();
    await update(state.copyWith(phones: updated));
  }

  Future<void> updatePhone(String phoneId, PresencePhone newPhone) async {
    final updated = state.phones.map((p) {
      return p.phoneId == phoneId ? newPhone : p;
    }).toList();
    await update(state.copyWith(phones: updated));
  }
}