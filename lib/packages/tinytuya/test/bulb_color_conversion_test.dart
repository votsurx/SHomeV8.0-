import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:tinytuya/src/bulb_device.dart';

/// Helper to run Python test script
Future<Map<String, dynamic>> runPythonColorTest() async {
  final result = await Process.run('python3', [
    'test/comparison_tests/python_scripts/test_bulb_color_conversion.py',
  ]);

  if (result.exitCode != 0) {
    throw Exception('Python test failed: ${result.stderr}');
  }

  return jsonDecode(result.stdout.toString().trim()) as Map<String, dynamic>;
}

void main() {
  group('BulbDevice Color Conversion', () {
    late Map<String, dynamic> pythonResults;

    setUpAll(() async {
      pythonResults = await runPythonColorTest();
    });

    test('rgb_to_hexvalue() rgb8 format - compare with Python', () {
      expect(
        BulbDevice.rgbToHexvalue(255, 0, 0, 'rgb8'),
        equals(pythonResults['rgb_to_hex_rgb8_red']),
      );
      expect(
        BulbDevice.rgbToHexvalue(0, 255, 0, 'rgb8'),
        equals(pythonResults['rgb_to_hex_rgb8_green']),
      );
      expect(
        BulbDevice.rgbToHexvalue(0, 0, 255, 'rgb8'),
        equals(pythonResults['rgb_to_hex_rgb8_blue']),
      );
      expect(
        BulbDevice.rgbToHexvalue(255, 255, 255, 'rgb8'),
        equals(pythonResults['rgb_to_hex_rgb8_white']),
      );
      expect(
        BulbDevice.rgbToHexvalue(128, 64, 200, 'rgb8'),
        equals(pythonResults['rgb_to_hex_rgb8_mixed']),
      );
    });

    test('rgb_to_hexvalue() hsv16 format - compare with Python', () {
      expect(
        BulbDevice.rgbToHexvalue(255, 0, 0, 'hsv16'),
        equals(pythonResults['rgb_to_hex_hsv16_red']),
      );
      expect(
        BulbDevice.rgbToHexvalue(0, 255, 0, 'hsv16'),
        equals(pythonResults['rgb_to_hex_hsv16_green']),
      );
      expect(
        BulbDevice.rgbToHexvalue(0, 0, 255, 'hsv16'),
        equals(pythonResults['rgb_to_hex_hsv16_blue']),
      );
      expect(
        BulbDevice.rgbToHexvalue(255, 255, 255, 'hsv16'),
        equals(pythonResults['rgb_to_hex_hsv16_white']),
      );
      expect(
        BulbDevice.rgbToHexvalue(128, 64, 200, 'hsv16'),
        equals(pythonResults['rgb_to_hex_hsv16_mixed']),
      );
    });

    // Skip hsv_to_hexvalue() rgb8 format test due to Python library bug

    test('hsv_to_hexvalue() hsv16 format - compare with Python', () {
      expect(
        BulbDevice.hsvToHexvalue(0.0, 1.0, 1.0, 'hsv16'),
        equals(pythonResults['hsv_to_hex_hsv16_1']),
      );
      expect(
        BulbDevice.hsvToHexvalue(0.33, 1.0, 1.0, 'hsv16'),
        equals(pythonResults['hsv_to_hex_hsv16_2']),
      );
      expect(
        BulbDevice.hsvToHexvalue(0.66, 1.0, 1.0, 'hsv16'),
        equals(pythonResults['hsv_to_hex_hsv16_3']),
      );
    });

    test('hexvalue_to_rgb() - compare with Python', () {
      expect(
        BulbDevice.hexvalueToRgb('ff0000', hexformat: 'rgb8'),
        equals(pythonResults['hex_to_rgb_rgb8']),
      );
      expect(
        BulbDevice.hexvalueToRgb('000003e803e8', hexformat: 'hsv16'),
        equals(pythonResults['hex_to_rgb_hsv16']),
      );
      expect(
        BulbDevice.hexvalueToRgb('00ff00'), // auto-detect
        equals(pythonResults['hex_to_rgb_auto_6']),
      );
      expect(
        BulbDevice.hexvalueToRgb('007803e803e8'), // auto-detect
        equals(pythonResults['hex_to_rgb_auto_12']),
      );
      expect(
        BulbDevice.hexvalueToRgb('0000ff00f0ffff'), // auto-detect
        equals(pythonResults['hex_to_rgb_auto_14']),
      );
    });

    test('hexvalue_to_hsv() - compare with Python', () {
      // Helper to compare floating point lists with tolerance
      void expectHsvClose(List<double> actual, List<dynamic> expected) {
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i], closeTo(expected[i] as double, 0.001));
        }
      }

      expectHsvClose(
        BulbDevice.hexvalueToHsv('ff0000', hexformat: 'rgb8'),
        pythonResults['hex_to_hsv_rgb8'] as List,
      );
      expectHsvClose(
        BulbDevice.hexvalueToHsv('000003e803e8', hexformat: 'hsv16'),
        pythonResults['hex_to_hsv_hsv16'] as List,
      );
      expectHsvClose(
        BulbDevice.hexvalueToHsv('00ff00'), // auto-detect
        pythonResults['hex_to_hsv_auto_6'] as List,
      );
      expectHsvClose(
        BulbDevice.hexvalueToHsv('007803e803e8'), // auto-detect
        pythonResults['hex_to_hsv_auto_12'] as List,
      );
      expectHsvClose(
        BulbDevice.hexvalueToHsv('0000ff00f0ffff'), // auto-detect
        pythonResults['hex_to_hsv_auto_14'] as List,
      );
    });
  });
}
