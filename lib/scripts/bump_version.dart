import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart run scripts/bump_version.dart <version>');
    print('Example: dart run scripts/bump_version.dart 8.1.0');
    return;
  }

  final newVersion = args[0];

  // 1. Обновляем pubspec.yaml
  final pubspec = File('pubspec.yaml');
  var content = pubspec.readAsStringSync();
  content = content.replaceAll(
    RegExp(r'version: \d+\.\d+\.\d+\+\d+'),
    'version: $newVersion+1',
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