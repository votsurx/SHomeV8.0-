import 'package:freezed_annotation/freezed_annotation.dart';

part 'presence_conditions.freezed.dart';
part 'presence_conditions.g.dart';

/// Условия для триггера присутствия.
@freezed
class PresenceConditions with _$PresenceConditions {
  const factory PresenceConditions({
    /// Использовать время суток
    @Default(false) bool useTime,
    @Default(0) int startHour,
    @Default(0) int startMinute,
    @Default(23) int endHour,
    @Default(59) int endMinute,

    /// Использовать дни недели
    @Default(false) bool useDays,
    @Default([]) List<int> daysOfWeek,

    /// Использовать состояние устройства
    @Default(false) bool useDevice,
    String? deviceId,
    bool? deviceOn,
  }) = _PresenceConditions;

  factory PresenceConditions.fromJson(Map<String, dynamic> json) =>
      _$PresenceConditionsFromJson(json);
}