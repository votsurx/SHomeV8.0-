/// Dart tinytuya scanner for comparison

import 'dart:convert';
import 'dart:io';
import 'package:tinytuya/tinytuya.dart';

Future<void> main(List<String> args) async {
  final scanTime = args.isNotEmpty ? int.parse(args[0]) : 5;

  stderr.writeln('Dart Scanner - Starting scan...');

  try {
    final devices = await deviceScan(scanTime: scanTime, verbose: true);

    stderr.writeln('Dart Scanner - Found ${devices.length} devices');

    // Convert to JSON format matching Python output
    final devicesJson = devices.map((d) => d.toJson()).toList();

    // Output JSON to stdout for parsing
    print(jsonEncode(devicesJson));
  } catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}
