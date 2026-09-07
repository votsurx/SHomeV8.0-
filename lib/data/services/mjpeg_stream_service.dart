/// Сервис для получения MJPEG-потоков с LegionNVR
library;

import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class MjpegStreamService {
  final http.Client _client = http.Client();
  StreamController<Uint8List>? _controller;
  http.StreamedResponse? _response;
  bool _isRunning = false;

  /// Подписаться на MJPEG-поток
  Stream<Uint8List> subscribe(String url) {
    _controller = StreamController<Uint8List>.broadcast();
    _startStream(url);
    return _controller!.stream;
  }

  void _startStream(String url) async {
    _isRunning = true;

    try {
      final request = http.Request('GET', Uri.parse(url));
      _response = await _client.send(request);

      if (_response!.statusCode != 200) {
        _controller?.addError('Failed to connect: ${_response!.statusCode}');
        return;
      }

      // Парсинг multipart/x-mixed-replace
      final stream = _response!.stream;
      final boundary = _parseBoundary(_response!.headers);

      if (boundary == null) {
        _controller?.addError('No boundary found');
        return;
      }

      final buffer = <int>[];
      bool inFrame = false;

      await for (final chunk in stream) {
        if (!_isRunning) break;

        buffer.addAll(chunk);

        while (true) {
          final data = Uint8List.fromList(buffer);

          if (!inFrame) {
            // Ищем начало кадра: --boundary\r\n
            final startIndex = _findBoundary(data, boundary);
            if (startIndex == -1) break;

            // Ищем начало JPEG: \xff\xd8
            final jpegStart = _findJpegStart(data, startIndex);
            if (jpegStart == -1) break;

            buffer.removeRange(0, jpegStart);
            inFrame = true;
          }

          if (inFrame) {
            // Ищем конец JPEG: \xff\xd9
            final jpegEnd = _findJpegEnd(Uint8List.fromList(buffer));
            if (jpegEnd == -1) break;

            // Извлекаем кадр
            final frame = Uint8List.fromList(buffer.sublist(0, jpegEnd + 2));
            _controller?.add(frame);

            buffer.removeRange(0, jpegEnd + 2);
            inFrame = false;
          }
        }
      }
    } catch (e) {
      _controller?.addError(e);
    }
  }

  String? _parseBoundary(Map<String, String> headers) {
    final contentType = headers['content-type'] ?? '';
    final match = RegExp(r'boundary=([^\s;]+)').firstMatch(contentType);
    return match?.group(1);
  }

  int _findBoundary(Uint8List data, String boundary) {
    final search = '--$boundary\r\n'.codeUnits;
    for (int i = 0; i < data.length - search.length; i++) {
      bool found = true;
      for (int j = 0; j < search.length; j++) {
        if (data[i + j] != search[j]) {
          found = false;
          break;
        }
      }
      if (found) return i;
    }
    return -1;
  }

  int _findJpegStart(Uint8List data, int start) {
    const marker = [0xFF, 0xD8];
    for (int i = start; i < data.length - 1; i++) {
      if (data[i] == marker[0] && data[i + 1] == marker[1]) {
        return i;
      }
    }
    return -1;
  }

  int _findJpegEnd(Uint8List data) {
    const marker = [0xFF, 0xD9];
    for (int i = 0; i < data.length - 1; i++) {
      if (data[i] == marker[0] && data[i + 1] == marker[1]) {
        return i;
      }
    }
    return -1;
  }

  void stop() {
    _isRunning = false;
    _response?.stream.listen((_) {});
    _controller?.close();
  }

  void dispose() {
    stop();
    _client.close();
  }
}