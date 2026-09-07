/// Tests for message parsing, packing, and unpacking
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';
import 'dart:typed_data';
import 'dart:convert';

// Import message helper functions
import 'package:tinytuya/src/core/message_helper.dart';
import 'package:tinytuya/src/core/header.dart';

void main() {
  group('Message Header Tests', () {
    test('Parse 55AA header', () {
      // Create a simple 55AA header
      // Format: prefix(4), seqno(4), cmd(4), length(4)
      final headerBytes = ByteData(16);
      headerBytes.setUint32(0, prefix55aaValue, Endian.big);
      headerBytes.setUint32(4, 1, Endian.big); // seqno = 1
      headerBytes.setUint32(8, 7, Endian.big); // cmd = CONTROL (7)
      headerBytes.setUint32(12, 50, Endian.big); // payload length = 50

      final header = parseHeader(headerBytes.buffer.asUint8List());

      expect(header.prefix, equals(prefix55aaValue));
      expect(header.seqno, equals(1));
      expect(header.cmd, equals(7));
      expect(header.length, equals(50));
      expect(header.totalLength, equals(66)); // 16 + 50
    });

    test('Parse header with invalid prefix', () {
      final headerBytes = ByteData(16);
      headerBytes.setUint32(0, 0xDEADBEEF, Endian.big); // Invalid prefix
      headerBytes.setUint32(4, 1, Endian.big);
      headerBytes.setUint32(8, 7, Endian.big);
      headerBytes.setUint32(12, 50, Endian.big);

      expect(
        () => parseHeader(headerBytes.buffer.asUint8List()),
        throwsA(isA<DecodeError>()),
      );
    });

    test('Parse header with insufficient data', () {
      final headerBytes = Uint8List(10); // Too short

      expect(() => parseHeader(headerBytes), throwsA(isA<DecodeError>()));
    });

    test('Parse header with oversized payload', () {
      final headerBytes = ByteData(16);
      headerBytes.setUint32(0, prefix55aaValue, Endian.big);
      headerBytes.setUint32(4, 1, Endian.big);
      headerBytes.setUint32(8, 7, Endian.big);
      headerBytes.setUint32(12, 2000, Endian.big); // Too large

      expect(
        () => parseHeader(headerBytes.buffer.asUint8List()),
        throwsA(isA<DecodeError>()),
      );
    });
  });

  group('CRC32 Tests', () {
    test('Calculate CRC32', () {
      final data = Uint8List.fromList(utf8.encode('Hello, World!'));
      final crc = calculateCrc32(data);

      // CRC32 should be a 32-bit unsigned integer
      expect(crc, isA<int>());
      expect(crc, greaterThan(0));
      expect(crc, lessThanOrEqualTo(0xFFFFFFFF));
    });

    test('CRC32 is deterministic', () {
      final data = Uint8List.fromList(utf8.encode('Test data'));
      final crc1 = calculateCrc32(data);
      final crc2 = calculateCrc32(data);

      expect(crc1, equals(crc2));
    });

    test('Different data produces different CRC', () {
      final data1 = Uint8List.fromList(utf8.encode('Data 1'));
      final data2 = Uint8List.fromList(utf8.encode('Data 2'));

      final crc1 = calculateCrc32(data1);
      final crc2 = calculateCrc32(data2);

      expect(crc1, isNot(equals(crc2)));
    });
  });

  group('Message Pack/Unpack Tests', () {
    test('Pack and unpack simple 55AA message', () async {
      final payload = Uint8List.fromList(utf8.encode('{"test": "data"}'));

      final msg = TuyaMessage(
        seqno: 1,
        cmd: 7, // CONTROL
        payload: payload,
        crc: 0, // Will be calculated
      );

      // Pack the message
      final packed = await packMessage(msg);

      expect(packed.length, greaterThan(16)); // At least header size
      expect(packed[0], equals(0x00)); // Prefix starts with 0x00
      expect(packed[1], equals(0x00));
      expect(packed[2], equals(0x55));
      expect(packed[3], equals(0xAA));

      // Unpack the message
      final unpacked = await unpackMessage(packed);

      expect(unpacked.seqno, equals(1));
      expect(unpacked.cmd, equals(7));
      expect(unpacked.crcGood, isTrue);
      expect(utf8.decode(unpacked.payload), equals('{"test": "data"}'));
    });

    test('Pack message with HMAC key', () async {
      final payload = Uint8List.fromList(utf8.encode('{"secure": "data"}'));
      final hmacKey = Uint8List.fromList(utf8.encode('my_secret_key_16'));

      final msg = TuyaMessage(
        seqno: 2,
        cmd: 8, // STATUS
        payload: payload,
        crc: 0,
      );

      final packed = await packMessage(msg, hmacKey: hmacKey);

      // HMAC adds 32 bytes for the hash
      expect(packed.length, greaterThan(16 + 32));

      // Unpack with same HMAC key
      final unpacked = await unpackMessage(packed, hmacKey: hmacKey);

      expect(unpacked.seqno, equals(2));
      expect(unpacked.cmd, equals(8));
      expect(unpacked.crcGood, isTrue);
    });

    test('Pack and unpack with retcode', () async {
      final payload = Uint8List.fromList(utf8.encode('{"result": "ok"}'));

      final msg = TuyaMessage(
        seqno: 3,
        cmd: 8,
        retcode: 0,
        payload: payload,
        crc: 0,
      );

      final packed = await packMessage(msg);
      final unpacked = await unpackMessage(packed);

      expect(unpacked.seqno, equals(3));
      expect(unpacked.retcode, equals(0));
      expect(unpacked.crcGood, isTrue);
    });

    test('Unpack with corrupted CRC fails gracefully', () async {
      final payload = Uint8List.fromList(utf8.encode('{"test": "data"}'));

      final msg = TuyaMessage(seqno: 1, cmd: 7, payload: payload, crc: 0);

      final packed = await packMessage(msg);

      // Corrupt the CRC (last 8 bytes: CRC + suffix)
      packed[packed.length - 8] ^= 0xFF;

      final unpacked = await unpackMessage(packed);

      expect(unpacked.crcGood, isFalse);
    });
  });

  group('Helper Function Tests', () {
    test('hasSuffix detects valid suffix', () {
      final data = BytesBuilder();
      data.add(Uint8List(20)); // Some data
      data.add(suffix55aaBin); // Valid suffix

      expect(hasSuffix(data.toBytes()), isTrue);
    });

    test('hasSuffix detects invalid suffix', () {
      final data = Uint8List(20);

      expect(hasSuffix(data), isFalse);
    });

    test('hasSuffix handles short data', () {
      final data = Uint8List(2);

      expect(hasSuffix(data), isFalse);
    });
  });
}
