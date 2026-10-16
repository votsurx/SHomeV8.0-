import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// HTTP-сервер для приёма heartbeat от Companion.
/// Companion каждые 30 сек шлёт POST /heartbeat?phoneId=xxx
/// SHome отвечает 200 OK, если Companion в сети.
class HeartbeatServer {
  static HttpServer? _server;
  static final Map<String, PhoneHeartbeat> _heartbeats = {};
  static Timer? _cleanupTimer;

  /// Запускает сервер. Возвращает true если успех.
  static Future<bool> start({int port = 7777}) async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      debugPrint('📡 HeartbeatServer запущен на ${_server!.address.address}:$port');

      // Очистка устаревших heartbeat каждые 30 сек
      _cleanupTimer = Timer.periodic(
        const Duration(seconds: 30),
            (_) => _cleanupStale(),
      );

      _server!.listen(
        _handleRequest,
        onError: (e) => debugPrint('❌ HeartbeatServer error: $e'),
      );

      return true;
    } catch (e) {
      debugPrint('❌ Не удалось запустить HeartbeatServer: $e');
      return false;
    }
  }

  static Future<void> _handleRequest(HttpRequest request) async {
    try {
      request.response.headers.add('Access-Control-Allow-Origin', '*');

      switch (request.uri.path) {
        case '/heartbeat':
          await _handleHeartbeat(request);
          break;
        case '/status':
          await _handleStatus(request);
          break;
        case '/ping':
          await _handlePing(request);
          break;
        default:
          request.response.statusCode = 404;
          request.response.write('Not Found');
      }
    } catch (e) {
      debugPrint('❌ Ошибка обработки: $e');
      request.response.statusCode = 500;
    } finally {
      await request.response.close();
    }
  }

  /// POST /heartbeat?phoneId=xxx
  /// Body (JSON): {phoneId, phoneName, status, battery, ssid}
  static Future<void> _handleHeartbeat(HttpRequest request) async {
    if (request.method != 'POST') {
      request.response.statusCode = 405;
      request.response.write('Method Not Allowed');
      return;
    }

    final phoneId = request.uri.queryParameters['phoneId'] ?? '';
    if (phoneId.isEmpty) {
      request.response.statusCode = 400;
      request.response.write('{"error": "phoneId required"}');
      return;
    }

    // Читаем body
    final body = await utf8.decoder.bind(request).join();
    Map<String, dynamic> data = {};
    if (body.isNotEmpty) {
      try {
        data = jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        // Игнорируем ошибки парсинга
      }
    }

    // Сохраняем heartbeat
    _heartbeats[phoneId] = PhoneHeartbeat(
      phoneId: phoneId,
      phoneName: data['phoneName'] as String? ?? phoneId,
      status: data['status'] as String? ?? 'home',
      battery: (data['battery'] as num?)?.toInt() ?? 0,
      ssid: data['ssid'] as String?,
      ts: DateTime.now(),
    );

    debugPrint('💓 Heartbeat: $phoneId (${_heartbeats[phoneId]!.status})');

    // Ответ
    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({
        'status': 'ok',
        'serverTime': DateTime.now().millisecondsSinceEpoch,
        'version': '8.1.41',
      }));
  }

  /// GET /status?phoneId=xxx
  /// Без параметра — возвращает всех активных.
  static Future<void> _handleStatus(HttpRequest request) async {
    final phoneId = request.uri.queryParameters['phoneId'] ?? '';

    if (phoneId.isEmpty) {
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'active': _heartbeats.values.map((h) => h.toJson()).toList(),
        }));
      return;
    }

    final hb = _heartbeats[phoneId];
    if (hb == null) {
      request.response
        ..statusCode = 404
        ..headers.contentType = ContentType.json
        ..write('{"error": "phone not found"}');
      return;
    }

    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(hb.toJson()));
  }

  /// GET /ping — быстрая проверка доступности сервера.
  static Future<void> _handlePing(HttpRequest request) async {
    request.response
      ..statusCode = 200
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({
        'status': 'ok',
        'serverTime': DateTime.now().millisecondsSinceEpoch,
      }));
  }

  /// Удаляет записи старше 90 секунд.
  static void _cleanupStale() {
    final now = DateTime.now();
    _heartbeats.removeWhere((_, hb) =>
    now.difference(hb.ts).inSeconds > 90);
  }

  /// Проверяет, жив ли Companion (приходил heartbeat не позднее maxAgeSec).
  static bool isAlive(String phoneId, {int maxAgeSec = 90}) {
    final hb = _heartbeats[phoneId];
    if (hb == null) return false;
    return DateTime.now().difference(hb.ts).inSeconds < maxAgeSec;
  }

  /// Возвращает heartbeat для phoneId (или null если устарел/нет).
  static PhoneHeartbeat? getHeartbeat(String phoneId) {
    final hb = _heartbeats[phoneId];
    if (hb == null) return null;
    if (DateTime.now().difference(hb.ts).inSeconds > 90) return null;
    return hb;
  }

  /// Останавливает сервер.
  static Future<void> stop() async {
    _cleanupTimer?.cancel();
    await _server?.close(force: true);
    _server = null;
  }
}

/// Публичная модель heartbeat от Companion.
class PhoneHeartbeat {
  final String phoneId;
  final String phoneName;
  final String status;
  final int battery;
  final String? ssid;
  final DateTime ts;

  PhoneHeartbeat({
    required this.phoneId,
    required this.phoneName,
    required this.status,
    required this.battery,
    this.ssid,
    required this.ts,
  });

  Map<String, dynamic> toJson() => {
    'phoneId': phoneId,
    'phoneName': phoneName,
    'status': status,
    'battery': battery,
    'ssid': ssid,
    'ts': ts.millisecondsSinceEpoch,
    'ageSec': DateTime.now().difference(ts).inSeconds,
  };
}