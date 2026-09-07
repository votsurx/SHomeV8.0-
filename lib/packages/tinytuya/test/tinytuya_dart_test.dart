import 'package:tinytuya/tinytuya.dart';
import 'package:test/test.dart';

void main() {
  group('TinyTuya Dart Tests', () {
    test('Exceptions can be created', () {
      final exception = TinyTuyaException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('DecryptionException extends TinyTuyaException', () {
      final exception = DecryptionException('Decryption failed');
      expect(exception, isA<TinyTuyaException>());
      expect(exception.toString(), contains('DecryptionException'));
    });

    test('Device can be instantiated with required parameters', () {
      final device = Device(
        deviceId: 'test_device_id',
        address: '192.168.1.100',
        localKey: 'test_key_1234567890abcdef',
        version: 3.3,
      );

      expect(device.deviceId, equals('test_device_id'));
      expect(device.address, equals('192.168.1.100'));
      expect(device.localKey, equals('test_key_1234567890abcdef'));
      expect(device.version, equals(3.3));
    });
  });
}
