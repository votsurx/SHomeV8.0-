/// Результат чтения облачной записи присутствия.
///
/// Различаем недоступность облака и отсутствие/некорректность записи:
/// отсутствие GPS-записи телефона не должно маскировать общий сбой связи.
library;

enum PresenceCloudReadStatus {
  /// Запись получена и разобрана как JSON-объект.
  found,

  /// Облако доступно, но файла этого телефона нет.
  notFound,

  /// Не удалось подтвердить доступность облака:
  /// сеть, сервер или авторизация недоступны.
  unavailable,

  /// Файл прочитан, но содержит некорректный JSON или не объект.
  invalidData,
}

class PresenceCloudReadResult {
  const PresenceCloudReadResult._({
    required this.status,
    this.data,
    this.details,
  });

  /// Запись найдена и прочитана.
  factory PresenceCloudReadResult.found(
      Map<String, dynamic> data,
      ) {
    return PresenceCloudReadResult._(
      status: PresenceCloudReadStatus.found,
      data: Map<String, dynamic>.unmodifiable(data),
    );
  }

  /// Облако доступно, но файла телефона нет.
  const PresenceCloudReadResult.notFound()
      : this._(status: PresenceCloudReadStatus.notFound);

  /// Доступность облака подтвердить не удалось.
  const PresenceCloudReadResult.unavailable({
    String? details,
  }) : this._(
    status: PresenceCloudReadStatus.unavailable,
    details: details,
  );

  /// Файл получен, но его содержимое некорректно.
  const PresenceCloudReadResult.invalidData({
    String? details,
  }) : this._(
    status: PresenceCloudReadStatus.invalidData,
    details: details,
  );

  final PresenceCloudReadStatus status;

  /// Данные записи доступны только при статусе [PresenceCloudReadStatus.found].
  final Map<String, dynamic>? data;

  /// Диагностическое описание ошибки; не предназначено для показа пользователю.
  final String? details;

  /// `false` только когда не удалось подтвердить доступность облака.
  bool get cloudAvailable =>
      status != PresenceCloudReadStatus.unavailable;
}

/// Абстракция чтения присутствия из облака.
///
/// Детектор сможет получать тестовую реализацию вместо реального WebDAV.
abstract interface class PresenceCloudReader {
  Future<PresenceCloudReadResult> readPresence({
    required String phoneId,
  });
}