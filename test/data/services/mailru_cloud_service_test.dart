import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/mailru_cloud_service.dart';
import 'package:shome/domain/services/presence_cloud_reader.dart';

void main() {
  group('MailruCloudService.readPresence', () {
    const phoneId = '89533309330';
    const directoryPath = '/SHome/presence';
    const filePath = '/SHome/presence/$phoneId.json';

    test('возвращает found для корректной JSON-записи', () async {
      final service = MailruCloudService(
        login: 'test@mail.ru',
        password: 'test_password',
        presenceDirectoryListing: (path) async {
          expect(path, directoryPath);
          return ['$phoneId.json'];
        },
        presenceFileReader: (path) async {
          expect(path, filePath);
          return utf8.encode(
            jsonEncode({
              'phoneId': phoneId,
              'status': 'away',
              'lat': 54.5375645,
              'lng': 36.2994795,
              'accuracy': 10.7,
              'battery': 70,
              'ts': 1795173296092,
            }),
          );
        },
      );

      final result = await service.readPresence(phoneId: phoneId);

      expect(result.status, PresenceCloudReadStatus.found);
      expect(result.cloudAvailable, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!['phoneId'], phoneId);
      expect(result.data!['status'], 'away');
      expect(result.data!['accuracy'], 10.7);
    });

    test('возвращает notFound, если облачный каталог доступен, '
        'но файла телефона в нём нет', () async {
      var fileReadCalled = false;

      final service = MailruCloudService(
        login: 'test@mail.ru',
        password: 'test_password',
        presenceDirectoryListing: (path) async {
          expect(path, directoryPath);
          return ['another-phone.json'];
        },
        presenceFileReader: (path) async {
          fileReadCalled = true;
          return <int>[];
        },
      );

      final result = await service.readPresence(phoneId: phoneId);

      expect(result.status, PresenceCloudReadStatus.notFound);
      expect(result.cloudAvailable, isTrue);
      expect(fileReadCalled, isFalse);
    });

    test('возвращает unavailable, если не удалось прочитать каталог',
            () async {
          final service = MailruCloudService(
            login: 'test@mail.ru',
            password: 'test_password',
            presenceDirectoryListing: (_) async {
              throw Exception('network unavailable');
            },
            presenceFileReader: (_) async => <int>[],
          );

          final result = await service.readPresence(phoneId: phoneId);

          expect(result.status, PresenceCloudReadStatus.unavailable);
          expect(result.cloudAvailable, isFalse);
          expect(result.details, contains('network unavailable'));
        });

    test('возвращает unavailable, если файл исчез или не читается '
        'после получения списка', () async {
      final service = MailruCloudService(
        login: 'test@mail.ru',
        password: 'test_password',
        presenceDirectoryListing: (_) async => ['$phoneId.json'],
        presenceFileReader: (_) async {
          throw Exception('file read failed');
        },
      );

      final result = await service.readPresence(phoneId: phoneId);

      expect(result.status, PresenceCloudReadStatus.unavailable);
      expect(result.cloudAvailable, isFalse);
      expect(result.details, contains('file read failed'));
    });

    test('возвращает invalidData для некорректного JSON', () async {
      final service = MailruCloudService(
        login: 'test@mail.ru',
        password: 'test_password',
        presenceDirectoryListing: (_) async => ['$phoneId.json'],
        presenceFileReader: (_) async => utf8.encode('{broken json'),
      );

      final result = await service.readPresence(phoneId: phoneId);

      expect(result.status, PresenceCloudReadStatus.invalidData);
      expect(result.cloudAvailable, isTrue);
      expect(result.details, isNotEmpty);
    });

    test('возвращает invalidData, если JSON — не объект', () async {
      final service = MailruCloudService(
        login: 'test@mail.ru',
        password: 'test_password',
        presenceDirectoryListing: (_) async => ['$phoneId.json'],
        presenceFileReader: (_) async => utf8.encode(jsonEncode([1, 2, 3])),
      );

      final result = await service.readPresence(phoneId: phoneId);

      expect(result.status, PresenceCloudReadStatus.invalidData);
      expect(result.cloudAvailable, isTrue);
    });

    test('нельзя передать только одну тестовую функцию', () {
      expect(
            () => MailruCloudService(
          login: 'test@mail.ru',
          password: 'test_password',
          presenceDirectoryListing: (_) async => <String>[],
        ),
        throwsArgumentError,
      );
    });
  });
}