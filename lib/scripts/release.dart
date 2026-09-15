import 'dart:io';

void main() async {
  print('╔══════════════════════════════════════════╗');
  print('║        SHome Release Manager             ║');
  print('╚══════════════════════════════════════════╝');
  print('');

  // Читаем текущую версию
  final pubspec = File('pubspec.yaml');
  var content = pubspec.readAsStringSync();

  final versionMatch = RegExp(r'version: (\d+\.\d+\.\d+)\+\d+').firstMatch(content);
  if (versionMatch == null) {
    print('❌ Не удалось найти версию в pubspec.yaml');
    return;
  }

  final currentVersion = versionMatch.group(1)!;
  print('📦 Текущая версия: $currentVersion');
  print('');

  // Спрашиваем действие
  print('Выберите действие:');
  print('  [1] Создать релиз (bump + commit + tag + push)');
  print('  [2] Синхронизировать версию из pubspec.yaml');
  print('  [3] Запустить flutter run с новой версией');
  print('  [4] Выйти');
  print('');
  stdout.write('Введите номер (1-4): ');

  final choice = stdin.readLineSync()?.trim() ?? '';

  switch (choice) {
    case '1':
      await _createRelease(currentVersion, content, pubspec);
      break;
    case '2':
      await _syncVersion(currentVersion);
      break;
    case '3':
      await _runWithVersion(currentVersion, content, pubspec);
      break;
    case '4':
      print('👋 Выход');
      break;
    default:
      print('❌ Неверный выбор');
  }
}

/// Создать релиз: bump + commit + tag + push
Future<void> _createRelease(String currentVersion, String content, File pubspec) async {
  print('');
  stdout.write('Новая версия (Enter = ${_nextVersion(currentVersion)}): ');
  final input = stdin.readLineSync()?.trim() ?? '';

  final newVersion = input.isEmpty ? _nextVersion(currentVersion) : _cleanVersion(input);
  print('');
  print('🆕 Новая версия: $newVersion');

  await _updateVersionFiles(newVersion, content, pubspec);

  print('');
  stdout.write('Создать релиз v$newVersion? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? '';

  if (confirm != 'y') {
    print('❌ Отменено');
    return;
  }

  // Git commit
  print('');
  print('📝 Коммит...');
  await Process.run('git', ['add', '.']);
  await Process.run('git', ['commit', '-m', 'release: v$newVersion']);

  print('🚀 Пуш...');
  await Process.run('git', ['push', 'origin', 'main']);

  print('🏷️  Тег...');
  await Process.run('git', ['tag', 'v$newVersion']);
  await Process.run('git', ['push', 'origin', 'v$newVersion']);

  print('');
  print('🎉 Релиз v$newVersion создан!');
  print('GitHub Actions соберёт APK автоматически.');
}

/// Синхронизировать версию из pubspec.yaml во все файлы
Future<void> _syncVersion(String currentVersion) async {
  print('');
  print('🔄 Синхронизация версии $currentVersion...');

  final pubspec = File('pubspec.yaml');
  final content = pubspec.readAsStringSync();
  await _updateVersionFiles(currentVersion, content, pubspec);

  print('');
  print('🎉 Версия синхронизирована: $currentVersion');
}

/// Запустить flutter run с новой версией
Future<void> _runWithVersion(String currentVersion, String content, File pubspec) async {
  print('');
  stdout.write('Новая версия (Enter = ${_nextVersion(currentVersion)}): ');
  final input = stdin.readLineSync()?.trim() ?? '';

  final newVersion = input.isEmpty ? _nextVersion(currentVersion) : _cleanVersion(input);
  print('');
  print('🆕 Новая версия: $newVersion');

  await _updateVersionFiles(newVersion, content, pubspec);

  print('');
  print('🚀 Запускаю flutter run...');
  print('');

  final result = await Process.start(
    'flutter.bat',
    ['run'],
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  await result.exitCode;
}

/// Убирает 'v' в начале версии
String _cleanVersion(String version) {
  return version.startsWith('v') ? version.substring(1) : version;
}

/// Увеличивает patch на +1
String _nextVersion(String version) {
  final parts = version.split('.');
  final newPatch = int.parse(parts[2]) + 1;
  return '${parts[0]}.${parts[1]}.$newPatch';
}

/// Обновляет версию во всех файлах
Future<void> _updateVersionFiles(String newVersion, String content, File pubspec) async {
  // 1. pubspec.yaml
  content = content.replaceAll(
    RegExp(r'version: \d+\.\d+\.\d+\+\d+'),
    'version: $newVersion+1',
  );
  content = content.replaceAll(
    RegExp(r'description: SHome v\d+\.\d+\.\d+'),
    'description: SHome v$newVersion',
  );
  pubspec.writeAsStringSync(content);
  print('✅ pubspec.yaml → $newVersion');

  // 2. legal_documents.dart
  final legalDocs = File('lib/presentation/screens/documents/legal_documents.dart');
  if (legalDocs.existsSync()) {
    var legalContent = legalDocs.readAsStringSync();
    legalContent = legalContent.replaceAll(
      RegExp(r"appVersion = '\d+\.\d+\.\d+'"),
      "appVersion = '$newVersion'",
    );
    legalDocs.writeAsStringSync(legalContent);
    print('✅ legal_documents.dart → $newVersion');
  }

  // 3. build.gradle.kts
  final gradle = File('android/app/build.gradle.kts');
  if (gradle.existsSync()) {
    var gradleContent = gradle.readAsStringSync();
    gradleContent = gradleContent.replaceAll(
      RegExp(r'versionName = "\d+\.\d+\.\d+"'),
      'versionName = "$newVersion"',
    );

    final versionCodeMatch = RegExp(r'versionCode = (\d+)').firstMatch(gradleContent);
    if (versionCodeMatch != null) {
      final currentCode = int.parse(versionCodeMatch.group(1)!);
      final newCode = currentCode + 1;
      gradleContent = gradleContent.replaceAll(
        RegExp(r'versionCode = \d+'),
        'versionCode = $newCode',
      );
      print('✅ versionCode → $newCode');
    }

    gradle.writeAsStringSync(gradleContent);
    print('✅ build.gradle.kts → $newVersion');
  }
}