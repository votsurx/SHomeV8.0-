import 'dart:io';

void main(List<String> args) {
  // Читаем текущую версию из pubspec.yaml
  final pubspec = File('pubspec.yaml');
  var content = pubspec.readAsStringSync();

  final versionMatch = RegExp(r'version: (\d+\.\d+\.\d+)\+\d+').firstMatch(content);
  if (versionMatch == null) {
    print('❌ Не удалось найти версию в pubspec.yaml');
    return;
  }

  final currentVersion = versionMatch.group(1)!;
  final parts = currentVersion.split('.');
  final newPatch = int.parse(parts[2]) + 1;
  final newVersion = '${parts[0]}.${parts[1]}.$newPatch';

  print('📦 Текущая версия: $currentVersion');
  print('🆕 Новая версия: $newVersion\n');

  // 1. Обновляем pubspec.yaml
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

  // 2. Обновляем legal_documents.dart
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

  // 3. Обновляем build.gradle.kts
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

  print('\n🎉 Версия обновлена до $newVersion');
  print('Не забудь закоммитить и создать тег:');
  print('  git add .');
  print('  git commit -m "release: v$newVersion"');
  print('  git tag v$newVersion');
  print('  git push origin main v$newVersion');
}