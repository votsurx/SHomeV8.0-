import 'dart:io';

void main() {
  // 1. Читаем версию из pubspec.yaml
  final pubspec = File('pubspec.yaml');
  var content = pubspec.readAsStringSync();

  final versionMatch = RegExp(r'version: (\d+\.\d+\.\d+)\+\d+').firstMatch(content);
  if (versionMatch == null) {
    print('❌ Не удалось найти версию в pubspec.yaml');
    return;
  }

  final newVersion = versionMatch.group(1)!;

  print('📦 Версия из pubspec.yaml: $newVersion\n');

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

  // 3. build.gradle.kts (versionName)
  final gradle = File('android/app/build.gradle.kts');
  if (gradle.existsSync()) {
    var gradleContent = gradle.readAsStringSync();
    gradleContent = gradleContent.replaceAll(
      RegExp(r'versionName = "\d+\.\d+\.\d+"'),
      'versionName = "$newVersion"',
    );
    gradle.writeAsStringSync(gradleContent);
    print('✅ build.gradle.kts versionName → $newVersion');
  }

  // 4. pubspec.yaml description
  content = content.replaceAll(
    RegExp(r'description: SHome v\d+\.\d+\.\d+'),
    'description: SHome v$newVersion',
  );
  pubspec.writeAsStringSync(content);
  print('✅ pubspec.yaml description → $newVersion');

  print('\n🎉 Версия синхронизирована: $newVersion');
  print('Не забудь закоммитить:');
  print('  git add .');
  print('  git commit -m "release: v$newVersion"');
}