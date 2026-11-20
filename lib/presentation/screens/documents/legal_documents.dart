/// Юридические документы приложения SHome.
library;

import 'package:flutter/widgets.dart';

class LegalDocuments {
  // Информация о приложении.
  static const String appName = 'SHome';
  static const String developer = 'ArchitectCO';
  static const String owner = 'votsurX';
  static const String contactEmail = 'votsurx@gmail.com';
  static const String appVersion = '8.4.4';
  static const String buildNumber = '1';
  static const String lastUpdated = '07 Сентября 2026';
  static const String lastUpdatedEn = 'September 7, 2026';
  static const String copyrightYear = '2026';

  static String get fullVersion => '$appVersion ($buildNumber)';
  static String get copyright => '© $copyrightYear $owner';

  /// Выбирает английский текст для локали en; для остальных локалей — русский.
  static bool _isEnglish(Locale locale) => locale.languageCode == 'en';

  static String eulaFor(Locale locale) =>
      _isEnglish(locale) ? eulaEn : eula;

  static String privacyPolicyFor(Locale locale) =>
      _isEnglish(locale) ? privacyPolicyEn : privacyPolicy;

  static String termsOfServiceFor(Locale locale) =>
      _isEnglish(locale) ? termsOfServiceEn : termsOfService;

  // Русские тексты сохранены для совместимости с существующими вызовами.
  static const String eula = '''
# SHome End User License Agreement (EULA)

**Версия приложения: $appVersion**
**Последнее обновление: $lastUpdated**

## 1. Принятие условий

Устанавливая и используя приложение SHome ("Приложение"), вы соглашаетесь с условиями данного Соглашения. Если вы не согласны с условиями, не устанавливайте и не используйте Приложение.

## 2. Лицензия

$developer ("Разработчик") предоставляет вам:
- Неисключительную лицензию
- Непередаваемую лицензию
- Ограниченную лицензию

На использование Приложения на устройствах, которыми вы владеете или управляете.

## 3. Ограничения

Вы не имеете права:
- Копировать, модифицировать или создавать производные работы
- Декомпилировать, дизассемблировать или реверс-инжинирить Приложение
- Сдавать в аренду, лизинг или сублицензировать Приложение
- Удалять или изменять уведомления об авторских правах
- Использовать Приложение в незаконных целях
- Передавать свои учётные данные третьим лицам

## 4. Интеллектуальная собственность

Все права на Приложение, включая:
- Исходный код
- Дизайн
- Логотипы
- Торговые марки
- Документацию

Принадлежат $owner и $developer.

## 5. Отказ от гарантий

Приложение предоставляется "КАК ЕСТЬ" без каких-либо гарантий, явных или подразумеваемых, включая, но не ограничиваясь:
- Гарантии товарной пригодности
- Гарантии пригодности для конкретной цели
- Гарантии ненарушения прав

## 6. Ограничение ответственности

$developer не несёт ответственности за:
- Прямые или косвенные убытки
- Потерю данных
- Потерю прибыли
- Прерывание бизнеса
- Ущерб оборудованию

Даже если была уведомлена о возможности таких убытков.

## 7. Обновления

Разработчик может выпускать обновления Приложения. Вы соглашаетесь получать такие обновления автоматически.

## 8. Прекращение действия

Лицензия действует до её прекращения. Она прекращается автоматически если:
- Вы нарушаете условия Соглашения
- Вы удаляете Приложение
- Разработчик прекращает поддержку Приложения

## 9. Применимое право

Настоящее Соглашение регулируется законодательством Российской Федерации.

## 10. Контакты

По вопросам обращаться: $contactEmail
''';

  static const String eulaEn = '''
# SHome End User License Agreement (EULA)

**App version: $appVersion**
**Last updated: $lastUpdatedEn**

## 1. Acceptance of terms

By installing and using the SHome application (the “App”), you agree to the terms of this Agreement. If you do not agree to these terms, do not install or use the App.

## 2. License

$developer (the “Developer”) grants you a:
- Non-exclusive license
- Non-transferable license
- Limited license

to use the App on devices that you own or control.

## 3. Restrictions

You may not:
- Copy, modify, or create derivative works of the App
- Decompile, disassemble, or reverse engineer the App
- Rent, lease, or sublicense the App
- Remove or alter copyright notices
- Use the App for unlawful purposes
- Disclose your credentials to third parties

## 4. Intellectual property

All rights to the App, including its:
- Source code
- Design
- Logos
- Trademarks
- Documentation

belong to $owner and $developer.

## 5. Disclaimer of warranties

The App is provided “AS IS”, without warranties of any kind, express or implied, including but not limited to:
- Warranties of merchantability
- Warranties of fitness for a particular purpose
- Warranties of non-infringement

## 6. Limitation of liability

$developer is not liable for:
- Direct or indirect losses
- Loss of data
- Loss of profits
- Business interruption
- Damage to equipment

even if advised of the possibility of such damages.

## 7. Updates

The Developer may release updates to the App. You agree to receive such updates automatically.

## 8. Termination

This license remains in effect until terminated. It terminates automatically if:
- You violate the terms of this Agreement
- You uninstall the App
- The Developer discontinues support for the App

## 9. Governing law

This Agreement is governed by the laws of the Russian Federation.

## 10. Contact

For questions, contact: $contactEmail
''';

  static const String privacyPolicy = '''
# Политика конфиденциальности SHome

**Версия приложения: $appVersion**
**Последнее обновление: $lastUpdated**

## 1. Какие данные мы собираем

### Данные устройств умного дома:
- IP-адреса устройств
- Local Key (ключи шифрования)
- Состояние устройств (вкл/выкл, температура и т.д.)
- Названия устройств и комнат
- DPS параметры устройств

### Технические данные:
- Версия приложения
- Модель устройства (телефона)
- Версия операционной системы
- Crash reports (отчёты об ошибках)

## 2. Как мы используем данные

- Для управления устройствами умного дома
- Для улучшения работы приложения
- Для исправления ошибок
- Для аналитики использования (анонимно)

## 3. Хранение данных

Данные хранятся:
- Локально на устройстве пользователя
- В зашифрованном виде
- Не передаются третьим лицам

## 4. Передача данных

Мы НЕ продаём и НЕ передаём данные третьим лицам, кроме случаев:
- Требования законодательства
- Защиты наших прав
- Предотвращения мошенничества

## 5. Безопасность

Мы используем:
- Шифрование данных
- Безопасные протоколы передачи
- Регулярные обновления безопасности
- Локальное хранение без облачных сервисов

## 6. Права пользователя

Вы имеете право:
- Получить копию своих данных
- Удалить свои данные (удалив приложение)
- Отозвать согласие на обработку
- Пожаловаться в надзорные органы

## 7. Аналитика

Мы используем:
- Firebase Analytics (анонимная статистика)
- Crashlytics (отчёты об ошибках)

Вы можете отключить аналитику в настройках приложения.

## 8. Данные детей

Приложение не предназначено для детей младше 13 лет. Мы сознательно не собираем данные детей.

## 9. Изменения политики

Мы можем обновлять политику. О значительных изменениях будем уведомлять в приложении.

## 10. Контакты

По вопросам конфиденциальности: $contactEmail
''';

  static const String privacyPolicyEn = '''
# SHome Privacy Policy

**App version: $appVersion**
**Last updated: $lastUpdatedEn**

## 1. Information we collect

### Smart home device data:
- Device IP addresses
- Local Keys (encryption keys)
- Device state (on/off, temperature, and similar data)
- Device and room names
- Device DPS parameters

### Technical data:
- App version
- Device model
- Operating system version
- Crash reports

## 2. How we use information

- To control smart home devices
- To improve the App
- To fix errors
- For anonymous usage analytics

## 3. Data storage

Data is:
- Stored locally on the user's device
- Stored in encrypted form
- Not shared with third parties

## 4. Data disclosure

We do NOT sell or disclose data to third parties, except when necessary:
- To comply with legal requirements
- To protect our rights
- To prevent fraud

## 5. Security

We use:
- Data encryption
- Secure transmission protocols
- Regular security updates
- Local storage; however, the App can also use cloud services configured by the user

## 6. User rights

You have the right to:
- Obtain a copy of your data
- Delete your data by uninstalling the App
- Withdraw consent to processing
- Submit a complaint to a supervisory authority

## 7. Analytics

We use:
- Firebase Analytics for usage statistics
- Crashlytics for crash reports

You can disable analytics in the App settings.

## 8. Children's data

The App is not intended for children under 13. We do not knowingly collect children's data.

## 9. Changes to this policy

We may update this policy. We will notify users in the App about significant changes.

## 10. Contact

For privacy questions, contact: $contactEmail
''';

  static const String termsOfService = '''
# Условия использования SHome

**Версия приложения: $appVersion**
**Последнее обновление: $lastUpdated**

## 1. Общие положения

Используя SHome, вы соглашаетесь:
- Использовать приложение только в законных целях
- Не нарушать права других пользователей
- Не взламывать и не модифицировать приложение
- Не создавать помехи в работе сервиса

## 2. Аккаунт

Вы несёте ответственность за:
- Сохранность данных вашего аккаунта
- Все действия, совершённые под вашим аккаунтом
- Своевременное обновление информации

## 3. Платные функции

- Покупки осуществляются через официальные магазины
- Возврат средств регулируется правилами магазинов
- Подписка продлевается автоматически
- Отмена подписки возможна в любой момент

## 4. Интеллектуальная собственность

Весь контент приложения защищён авторским правом:
- Программный код
- Дизайн
- Графические элементы
- Документация

## 5. Ограничение ответственности

$developer не несёт ответственности за:
- Неправильную работу устройств
- Потерю данных
- Ущерб, причинённый использованием приложения
- Сбои в работе оборудования

## 6. Гарантии

Приложение предоставляется "как есть" без каких-либо гарантий.

## 7. Изменения условий

Мы можем изменять условия. Продолжение использования означает согласие с изменениями.

## 8. Прекращение доступа

Мы можем заблокировать доступ при нарушении условий.

## 9. Применимое право

Настоящие условия регулируются законодательством Российской Федерации.

## 10. Контакты

$contactEmail
''';

  static const String termsOfServiceEn = '''
# SHome Terms of Service

**App version: $appVersion**
**Last updated: $lastUpdatedEn**

## 1. General

By using SHome, you agree to:
- Use the App only for lawful purposes
- Respect the rights of other users
- Not hack or modify the App
- Not interfere with the operation of the service

## 2. Account

You are responsible for:
- Keeping your account information secure
- All actions performed through your account
- Keeping your information up to date

## 3. Paid features

- Purchases are made through official stores
- Refunds are governed by the stores' policies
- Subscriptions renew automatically
- You may cancel a subscription at any time

## 4. Intellectual property

All App content is protected by copyright, including:
- Software code
- Design
- Graphics
- Documentation

## 5. Limitation of liability

$developer is not responsible for:
- Devices operating incorrectly
- Loss of data
- Damage caused by use of the App
- Equipment failures

## 6. Warranties

The App is provided “as is”, without warranties of any kind.

## 7. Changes to these terms

We may change these terms. Continuing to use the App means that you accept the changes.

## 8. Termination of access

We may block access if these terms are violated.

## 9. Governing law

These terms are governed by the laws of the Russian Federation.

## 10. Contact

$contactEmail
''';
}