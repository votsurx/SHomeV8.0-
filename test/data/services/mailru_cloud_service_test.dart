import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/mailru_cloud_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MailruCloudService', () {
    late MailruCloudService service;

    setUp(() {
      service = MailruCloudService(
        login: 'test@mail.ru',
        password: 'test_password',
      );
    });

    test('создаётся с правильными параметрами', () {
      expect(service.login, 'test@mail.ru');
      expect(service.password, 'test_password');
    });

    test('testConnection возвращает false при неверных данных', () async {
      final result = await service.testConnection();
      // Без реального WebDAV должно вернуть false
      expect(result, false);
    });

    test('listBackups возвращает пустой список при ошибке', () async {
      final backups = await service.listBackups();
      // Без подключения к облаку — пустой список
      expect(backups, isEmpty);
    });

    test('downloadBackup возвращает null при ошибке', () async {
      final result = await service.downloadBackup('nonexistent.json');
      expect(result, isNull);
    });

    test('uploadBackup возвращает false при ошибке', () async {
      final result = await service.uploadBackup('{"test": true}');
      expect(result, false);
    });

    test('статический autoSync не падает без сохранённых данных', () async {
      // Не должен бросать исключений
      await MailruCloudService.autoSync('{"test": true}');
      // Если дошли сюда — тест пройден
      expect(true, true);
    });
  });
}