import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Текущая выбранная комната.
/// `null` = все комнаты (главный экран, 'all').
final currentRoomIdProvider = StateProvider<String?>((ref) => null);