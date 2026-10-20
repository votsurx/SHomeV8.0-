/// REST-клиент для Frigate NVR.
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:talker/talker.dart';
import '../../domain/models/frigate_models.dart';

class FrigateService {
  final Talker _talker;
  String _host = '';
  int _port = 5000;
  String? _rtspPassword;

  FrigateService(this._talker);

  void configure({
    required String host,
    int port = 5000,
    String? rtspPassword,
  }) {
    _host = host;
    _port = port;
    _rtspPassword = rtspPassword;
  }

  String get host => _host;
  int get port => _port;
  bool get isConfigured => _host.isNotEmpty;

  String get _baseUrl => 'http://$_host:$_port';

  /// Получить список камер из /api/config.
  Future<List<FrigateCamera>> getCameras() async {
    if (!isConfigured) return [];

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/config'));
      if (response.statusCode != 200) {
        _talker.error('Frigate /api/config: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final cameras = data['cameras'] as Map<String, dynamic>? ?? {};

      return cameras.entries
          .where((e) => e.value is Map<String, dynamic>)
          .map((e) => FrigateCamera.fromJson(
        e.key,
        e.value as Map<String, dynamic>,
      ))
          .toList();
    } catch (e) {
      _talker.error('Frigate getCameras error', e);
      return [];
    }
  }

  /// Получить статистику (CPU, RAM, камеры).
  Future<FrigateStats?> getStats() async {
    if (!isConfigured) return null;

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/stats'));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return FrigateStats.fromJson(data);
    } catch (e) {
      _talker.error('Frigate getStats error', e);
      return null;
    }
  }

  /// Получить последний снапшот камеры.
  Future<Uint8List?> getSnapshot(String camera) async {
    if (!isConfigured) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/$camera/latest.jpg'),
      );
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (e) {
      _talker.error('Frigate getSnapshot error', e);
      return null;
    }
  }

  /// Получить снапшот события.
  Future<Uint8List?> getEventSnapshot(String eventId) async {
    if (!isConfigured) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/events/$eventId/snapshot.jpg'),
      );
      if (response.statusCode != 200) return null;
      return response.bodyBytes;
    } catch (e) {
      _talker.error('Frigate getEventSnapshot error', e);
      return null;
    }
  }

  /// Получить список событий (последние N).
  Future<List<FrigateEvent>> getEvents({int limit = 50}) async {
    if (!isConfigured) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/events?limit=$limit'),
      );
      if (response.statusCode != 200) return [];

      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((j) => FrigateEvent.fromJson({'after': j}))
          .toList();
    } catch (e) {
      _talker.error('Frigate getEvents error', e);
      return [];
    }
  }

  /// Получить RTSP-URL камеры (для плеера).
  String? getRtspUrl(String camera) {
    if (!isConfigured) return null;
    final password = _rtspPassword ?? 'password';
    return 'rtsp://admin:$password@$_host:8554/$camera';
  }

  /// Проверить подключение (запрос /api/config).
  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/config'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}