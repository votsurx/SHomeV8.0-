import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/presence_detector.dart';
import 'package:shome/application/models/presence_settings.dart';

void main() {
  group('PresenceDetector', () {
    late PresenceDetector detector;

    setUp(() {
      detector = PresenceDetector();
    });

    // ─── distance (haversine) ───

    test('distance: 0 между одинаковыми точками', () {
      final d = detector.distance(55.7558, 37.6173, 55.7558, 37.6173);
      expect(d, closeTo(0, 0.01));
    });

    test('distance: ~111 км между 1° широты', () {
      // 1° широты ≈ 111 195 м
      final d = detector.distance(55.0, 37.0, 56.0, 37.0);
      expect(d, closeTo(111195, 1000));
    });

    test('distance: Москва–Питер ≈ 635 км', () {
      final d = detector.distance(55.7558, 37.6173, 59.9343, 30.3351);
      expect(d, closeTo(635000, 20000));
    });

    // ─── isAnyoneHome / isNobodyHome ───

    test('isAnyoneHome: пустой список → false', () {
      expect(detector.isAnyoneHome, false);
    });

    test('isNobodyHome: пустой список → false', () {
      expect(detector.isNobodyHome, false);
    });

    // ─── phones map ───

    test('phones: изначально пустой', () {
      expect(detector.phones, isEmpty);
    });

    test('stop без start не падает', () {
      detector.stop();
      expect(true, true);
    });
  });
}