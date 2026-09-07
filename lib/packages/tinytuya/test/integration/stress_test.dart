/// Integration test - Stress test for rapid consecutive operations
/// Tests rapid consecutive operations on v3.3, v3.4, and v3.5 devices
/// to verify the package-level fixes for stream cleanup and operation locking.
@Tags(['integration'])
library;

import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';
import 'test_helpers.dart';

/// Test result tracker
class TestResult {
  final String operation;
  final bool success;
  final Duration duration;
  final String? error;
  final int retries;

  TestResult({
    required this.operation,
    required this.success,
    required this.duration,
    this.error,
    this.retries = 0,
  });
}

/// Retry wrapper for device operations
/// Returns result and retry count
Future<({Map<String, dynamic> result, int retries})> _retryOperation(
  Future<Map<String, dynamic>> Function() operation,
  String operationName, {
  int maxRetries = 2,
  int timeoutMs = 500,
}) async {
  var retries = 0;

  while (retries <= maxRetries) {
    try {
      final result = await operation().timeout(
        Duration(milliseconds: timeoutMs),
        onTimeout: () => {
          'success': false,
          'error': 'Operation timed out after ${timeoutMs}ms',
        },
      );

      // Check if operation succeeded
      if (result['success'] == true) {
        return (result: result, retries: retries);
      }

      // Operation returned failure - retry if we have attempts left
      if (retries < maxRetries) {
        print('    ↻ Retry ${retries + 1}/$maxRetries for $operationName...');
        retries++;
        await Future.delayed(const Duration(milliseconds: 50));
        continue;
      }

      // Out of retries
      return (result: result, retries: retries);
    } catch (e) {
      // Exception occurred - retry if we have attempts left
      if (retries < maxRetries) {
        print(
          '    ↻ Retry ${retries + 1}/$maxRetries for $operationName (error: $e)',
        );
        retries++;
        await Future.delayed(const Duration(milliseconds: 50));
        continue;
      }

      // Out of retries - return error
      return (
        result: {'success': false, 'error': e.toString()},
        retries: retries,
      );
    }
  }

  // Should never reach here
  return (
    result: {'success': false, 'error': 'Max retries exceeded'},
    retries: maxRetries,
  );
}

/// Stress test a single device with rapid consecutive operations
Future<List<TestResult>> stressTestDevice(
  Map<String, dynamic> deviceConfig,
  int cycles,
) async {
  print('\n${'=' * 80}');
  print('STRESS TEST: ${deviceConfig['name']}');
  print('=' * 80);
  print('Device ID: ${deviceConfig['device_id']}');
  print('IP: ${deviceConfig['ip']}');
  print('Version: ${deviceConfig['version']}');
  print('Test cycles: $cycles (${cycles * 2} total operations)');
  print('');

  final results = <TestResult>[];
  var successCount = 0;
  var failureCount = 0;

  final device = Device(
    deviceId: deviceConfig['device_id'],
    address: deviceConfig['ip'],
    localKey: deviceConfig['local_key'],
    version: deviceConfig['version'],
  );

  try {
    // Determine retry count and timeout based on device version
    // v3.3 devices are less reliable, give them more retries
    // v3.4+ have session key negotiation overhead, need longer timeouts
    // v3.5 also has GCM encryption overhead, needs even longer timeout
    final version = deviceConfig['version'] as double;
    final maxRetries = version <= 3.3 ? 2 : 1;
    final timeoutMs = version >= 3.5 ? 1500 : (version >= 3.4 ? 1000 : 500);

    print('Starting stress test at ${DateTime.now()}...');
    print(
      'Retry strategy: $maxRetries retries, ${timeoutMs}ms timeout for v$version devices\n',
    );

    for (var i = 1; i <= cycles; i++) {
      print('Cycle $i/$cycles:');

      // Turn ON with retry
      final onStart = DateTime.now();
      final onResult = await _retryOperation(
        () => device.turnOn(),
        'ON',
        maxRetries: maxRetries,
        timeoutMs: timeoutMs,
      );
      final onDuration = DateTime.now().difference(onStart);

      if (onResult.result['success'] == true) {
        final retryInfo = onResult.retries > 0
            ? ' (${onResult.retries} retries)'
            : '';
        print('  ✓ ON  - ${onDuration.inMilliseconds}ms$retryInfo');
        results.add(
          TestResult(
            operation: 'Cycle $i - ON',
            success: true,
            duration: onDuration,
            retries: onResult.retries,
          ),
        );
        successCount++;
      } else {
        print(
          '  ✗ ON  - FAILED after ${onResult.retries} retries: ${onResult.result}',
        );
        results.add(
          TestResult(
            operation: 'Cycle $i - ON',
            success: false,
            duration: onDuration,
            error: onResult.result.toString(),
            retries: onResult.retries,
          ),
        );
        failureCount++;
      }

      // Small delay between ON and OFF (but no delay between cycles)
      await Future.delayed(const Duration(milliseconds: 100));

      // Turn OFF with retry
      final offStart = DateTime.now();
      final offResult = await _retryOperation(
        () => device.turnOff(),
        'OFF',
        maxRetries: maxRetries,
        timeoutMs: timeoutMs,
      );
      final offDuration = DateTime.now().difference(offStart);

      if (offResult.result['success'] == true) {
        final retryInfo = offResult.retries > 0
            ? ' (${offResult.retries} retries)'
            : '';
        print('  ✓ OFF - ${offDuration.inMilliseconds}ms$retryInfo');
        results.add(
          TestResult(
            operation: 'Cycle $i - OFF',
            success: true,
            duration: offDuration,
            retries: offResult.retries,
          ),
        );
        successCount++;
      } else {
        print(
          '  ✗ OFF - FAILED after ${offResult.retries} retries: ${offResult.result}',
        );
        results.add(
          TestResult(
            operation: 'Cycle $i - OFF',
            success: false,
            duration: offDuration,
            error: offResult.result.toString(),
            retries: offResult.retries,
          ),
        );
        failureCount++;
      }

      // NO delay between cycles - this is the stress test!
      // We want to test rapid consecutive operations
    }

    print('\n${'─' * 80}');
    print('TEST SUMMARY FOR ${deviceConfig['name']}');
    print('─' * 80);
    print('Total operations: ${results.length}');
    print(
      'Successful: $successCount (${(successCount / results.length * 100).toStringAsFixed(1)}%)',
    );
    print(
      'Failed: $failureCount (${(failureCount / results.length * 100).toStringAsFixed(1)}%)',
    );

    // Calculate timing statistics
    final successfulResults = results.where((r) => r.success).toList();
    if (successfulResults.isNotEmpty) {
      final durations = successfulResults
          .map((r) => r.duration.inMilliseconds)
          .toList();
      durations.sort();

      final avg = durations.reduce((a, b) => a + b) / durations.length;
      final min = durations.first;
      final max = durations.last;
      final median = durations[durations.length ~/ 2];

      print('\nTiming Statistics (successful operations):');
      print('  Average: ${avg.toStringAsFixed(1)}ms');
      print('  Median:  ${median}ms');
      print('  Min:     ${min}ms');
      print('  Max:     ${max}ms');
    }

    // Show failures if any
    if (failureCount > 0) {
      print('\nFailed Operations:');
      for (final result in results.where((r) => !r.success)) {
        print('  ✗ ${result.operation}: ${result.error}');
      }
    }

    print('${'=' * 80}\n');
  } finally {
    device.close();
  }

  return results;
}

void main() {
  group('Stress Test Suite', () {
    test(
      'rapid consecutive operations across all devices',
      () async {
        final config = await loadDeviceConfig();
        if (config == null) {
          print(
            'Skipped: No devices.json found. Copy test/integration/devices.json.example and fill in device credentials to run integration tests',
          );
          return;
        }

        print(
          '╔════════════════════════════════════════════════════════════════════════════╗',
        );
        print(
          '║                    TinyTuya Dart - Stress Test Suite                      ║',
        );
        print(
          '║                                                                            ║',
        );
        print(
          '║  Testing rapid consecutive operations to validate package-level fixes     ║',
        );
        print(
          '║  Target: Zero failures, matching Python implementation reliability        ║',
        );
        print(
          '╚════════════════════════════════════════════════════════════════════════════╝',
        );
        print('');

        final devices = config['devices'] as List;

        // Test configuration
        const cyclesPerDevice =
            5; // 5 ON/OFF cycles = 10 total operations per device

        print('Test Configuration:');
        print('  Devices: ${devices.length}');
        print('  Cycles per device: $cyclesPerDevice');
        print('  Total operations per device: ${cyclesPerDevice * 2}');
        print(
          '  Total operations across all devices: ${devices.length * cyclesPerDevice * 2}',
        );
        print('');

        // Track overall results
        final allResults = <String, List<TestResult>>{};
        final startTime = DateTime.now();

        // Test each device
        for (final device in devices) {
          final results = await stressTestDevice(device, cyclesPerDevice);
          allResults[device['name']] = results;

          // Small pause between devices
          await Future.delayed(const Duration(seconds: 2));
        }

        final totalDuration = DateTime.now().difference(startTime);

        // Print overall summary
        print('\n');
        print(
          '╔════════════════════════════════════════════════════════════════════════════╗',
        );
        print(
          '║                        OVERALL TEST SUMMARY                                ║',
        );
        print(
          '╚════════════════════════════════════════════════════════════════════════════╝',
        );
        print('');
        print('Total test duration: ${totalDuration.inSeconds} seconds');
        print('');

        var totalOps = 0;
        var totalSuccess = 0;
        var totalFailures = 0;

        for (final entry in allResults.entries) {
          final deviceName = entry.key;
          final results = entry.value;
          final successes = results.where((r) => r.success).length;
          final failures = results.where((r) => !r.success).length;

          totalOps += results.length;
          totalSuccess += successes;
          totalFailures += failures;

          final successRate = (successes / results.length * 100)
              .toStringAsFixed(1);
          final status = failures == 0 ? '✓' : '✗';

          print('$status $deviceName:');
          print('    Total: ${results.length} ops');
          print('    Success: $successes ($successRate%)');
          print('    Failures: $failures');
          print('');
        }

        print('─' * 80);
        print('GRAND TOTAL:');
        print('  Operations: $totalOps');
        print(
          '  Successful: $totalSuccess (${(totalSuccess / totalOps * 100).toStringAsFixed(1)}%)',
        );
        print(
          '  Failed: $totalFailures (${(totalFailures / totalOps * 100).toStringAsFixed(1)}%)',
        );
        print('');

        if (totalFailures == 0) {
          print('🎉 SUCCESS! All operations completed without errors!');
          print('   Package reliability matches Python implementation.');
        } else {
          print('⚠️  WARNING: $totalFailures failures detected.');
          print('   Further investigation needed.');
        }

        print(
          '╔════════════════════════════════════════════════════════════════════════════╗',
        );
        print(
          '║                           Test Complete                                   ║',
        );
        print(
          '╚════════════════════════════════════════════════════════════════════════════╝',
        );

        // Assert that all operations succeeded
        expect(
          totalFailures,
          equals(0),
          reason: 'All stress test operations should succeed',
        );
        expect(
          totalSuccess,
          equals(totalOps),
          reason: 'All operations should be successful',
        );
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );
  });
}
