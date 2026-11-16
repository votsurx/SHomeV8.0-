import 'package:flutter_test/flutter_test.dart';
import 'package:shome/data/services/notification_coordinator.dart';
import 'package:shome/domain/models/device.dart';
import 'package:shome/application/models/notification_settings.dart';
import 'package:shome/application/models/sms_settings.dart';
import '../helpers/test_helpers.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationCoordinator', () {
    late NotificationCoordinator coordinator;
    late MockNotificationSender sender;
    late MockSmsService smsService;

    setUpAll(() {
      setupPrefsMock();
      setupSecureStorageMock();
      setupGetItForTests();
    });

    setUp(() {
      coordinator = NotificationCoordinator();
      coordinator.resetForTest();                        // ← сначала
      sender = MockNotificationSender();
      smsService = MockSmsService();
      coordinator.setSendersForTest(                    // ← потом
        vkSender: sender,
        smsService: smsService,
      );
    });

    // ─── isConditionMet ───

    test('isConditionMet always → true', () {
      expect(coordinator.isConditionMet('always'), true);
    });

    test('isConditionMet night — возвращает bool', () {
      final result = coordinator.isConditionMet('night');
      expect(result, isA<bool>());
    });

    test('isConditionMet default → true', () {
      expect(coordinator.isConditionMet('unknown_condition'), true);
    });

    // ─── notifyDevice: notify_types фильтр ───

    test('notifyDevice не шлёт, если type не в notify_types', () async {
      final device = createTestDevice(
        properties: {
          'notify_types': ['offline'],
        },
      );

      final vk = NotificationSettings(
        enabled: true,
        vkToken: 'token',
        vkUserId: '123',
        notifyDevices: true,
      );

      await coordinator.notifyDevice(
        device: device,
        type: 'state_changed',
        title: 'Test',
        message: 'Test',
        vkSettings: vk,
        smsSettings: SmsSettings(enabled: false),
      );

      // state_changed не в notify_types → VK не вызван
      expect(sender.sent, isEmpty);
    });

    test('notifyDevice шлёт, если type в notify_types', () async {
      final device = createTestDevice(
        properties: {
          'notify_types': ['state_changed'],
        },
      );

      final vk = NotificationSettings(
        enabled: true,
        vkToken: 'token',
        vkUserId: '123',
        notifyDevices: true,
        vkCooldownMin: 1,
      );

      await coordinator.notifyDevice(
        device: device,
        type: 'state_changed',
        title: 'Test',
        message: 'Test',
        vkSettings: vk,
        smsSettings: SmsSettings(enabled: false),
      );

      // type в notify_types → VK вызван
      expect(sender.sent.length, 1);
      expect(sender.sent.first, contains('Test'));
    });

    test('notifyDevice шлёт, если notify_types null', () async {
      final device = createTestDevice(properties: {});

      final vk = NotificationSettings(
        enabled: true,
        vkToken: 'token',
        vkUserId: '123',
        notifyDevices: true,
      );

      await coordinator.notifyDevice(
        device: device,
        type: 'state_changed',
        title: 'Test',
        message: 'Test',
        vkSettings: vk,
        smsSettings: SmsSettings(enabled: false),
      );

      expect(sender.sent.length, 1);
    });

    // ─── notifyDevice: condition ───

    test('notifyDevice condition=away — не шлёт, если кто-то дома', () async {
      final device = createTestDevice(
        properties: {'notify_condition': 'away'},
      );

      final vk = NotificationSettings(
        enabled: true,
        vkToken: 'token',
        vkUserId: '123',
        notifyDevices: true,
      );

      // PresenceDetector пустой → isNobodyHome = false → condition не выполнено
      await coordinator.notifyDevice(
        device: device,
        type: 'state_changed',
        title: 'Test',
        message: 'Test',
        vkSettings: vk,
        smsSettings: SmsSettings(enabled: false),
      );

      expect(sender.sent, isEmpty);
    });

    // ─── notifyDevice: антидребезг ───

    test('notifyDevice антидребезг блокирует повтор в течение cooldown',
            () async {
          final device = createTestDevice(properties: {
            'notify_cooldown_min': 10,
          });

          final vk = NotificationSettings(
            enabled: true,
            vkToken: 'token',
            vkUserId: '123',
            notifyDevices: true,
            vkCooldownMin: 10,
          );

          // Первый вызов — проходит
          await coordinator.notifyDevice(
            device: device,
            type: 'state_changed',
            title: 'First',
            message: 'First',
            vkSettings: vk,
            smsSettings: SmsSettings(enabled: false),
          );
          expect(sender.sent.length, 1);

          // Второй вызов — антидребезг (10 мин) блокирует
          await coordinator.notifyDevice(
            device: device,
            type: 'state_changed',
            title: 'Second',
            message: 'Second',
            vkSettings: vk,
            smsSettings: SmsSettings(enabled: false),
          );
          expect(sender.sent.length, 1); // всё ещё 1
        });

    test('notifyDevice антидребезг: разные устройства не блокируют друг друга',
            () async {
          final device1 = createTestDevice(id: 'dev_1');
          final device2 = createTestDevice(id: 'dev_2');

          final vk = NotificationSettings(
            enabled: true,
            vkToken: 'token',
            vkUserId: '123',
            notifyDevices: true,
            vkCooldownMin: 10,
          );

          await coordinator.notifyDevice(
            device: device1,
            type: 'state_changed',
            title: 'D1',
            message: 'D1',
            vkSettings: vk,
            smsSettings: SmsSettings(enabled: false),
          );

          await coordinator.notifyDevice(
            device: device2,
            type: 'state_changed',
            title: 'D2',
            message: 'D2',
            vkSettings: vk,
            smsSettings: SmsSettings(enabled: false),
          );

          // Разные устройства → оба отправлены
          expect(sender.sent.length, 2);
        });

    // ─── notifyFrigateEvent ───

    test('notifyFrigateEvent не шлёт, если label не в notify_labels',
            () async {
          final camera = createTestDevice(
            type: DeviceType.camera,
            properties: {
              'source': 'frigate',
              'notify_labels': ['person'],
            },
          );

          await coordinator.notifyFrigateEvent(
            camera: camera,
            event: createFrigateEvent(label: 'car'),
            vkSettings: NotificationSettings(enabled: false),
            smsSettings: SmsSettings(enabled: false),
          );

          // car не в notify_labels → ничего не отправлено
          expect(sender.sent, isEmpty);
        });
  });
}