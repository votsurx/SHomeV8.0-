import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @welcomeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Управляйте своим умным домом легко и просто'**
  String get welcomeSubtitle;

  /// No description provided for @startButton.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get startButton;

  /// No description provided for @languageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык приложения'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get languageSystem;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбран язык: {language}'**
  String languageSelected(String language);

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @pollingInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал опроса'**
  String get pollingInterval;

  /// No description provided for @screenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки экрана'**
  String get screenSettings;

  /// No description provided for @screenSettingsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Заставка и отображение'**
  String get screenSettingsSubtitle;

  /// No description provided for @scanTuyaTitle.
  ///
  /// In ru, this message translates to:
  /// **'Scan Tuya'**
  String get scanTuyaTitle;

  /// No description provided for @tuyaSearchTitle.
  ///
  /// In ru, this message translates to:
  /// **'Searching for Tuya devices'**
  String get tuyaSearchTitle;

  /// No description provided for @scanPortsHint.
  ///
  /// In ru, this message translates to:
  /// **'Scanning ports 6666, 6667, 6668, and 7000 on the local network'**
  String get scanPortsHint;

  /// No description provided for @scanProgress.
  ///
  /// In ru, this message translates to:
  /// **'Checked: {progress} / {total}'**
  String scanProgress(int progress, int total);

  /// No description provided for @foundDevices.
  ///
  /// In ru, this message translates to:
  /// **'Found: {count}'**
  String foundDevices(int count);

  /// No description provided for @deviceAddedStatus.
  ///
  /// In ru, this message translates to:
  /// **'Added'**
  String get deviceAddedStatus;

  /// No description provided for @tapToScan.
  ///
  /// In ru, this message translates to:
  /// **'Tap “Scan”'**
  String get tapToScan;

  /// No description provided for @scanning.
  ///
  /// In ru, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @scan.
  ///
  /// In ru, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @continueButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueButton;

  /// No description provided for @addDeviceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Add device'**
  String get addDeviceTitle;

  /// No description provided for @ipAddress.
  ///
  /// In ru, this message translates to:
  /// **'IP: {ip}'**
  String ipAddress(String ip);

  /// No description provided for @portNumber.
  ///
  /// In ru, this message translates to:
  /// **'Port: {port}'**
  String portNumber(int port);

  /// No description provided for @defaultDeviceName.
  ///
  /// In ru, this message translates to:
  /// **'Device {ip}'**
  String defaultDeviceName(String ip);

  /// No description provided for @deviceName.
  ///
  /// In ru, this message translates to:
  /// **'Name'**
  String get deviceName;

  /// No description provided for @deviceType.
  ///
  /// In ru, this message translates to:
  /// **'Device type'**
  String get deviceType;

  /// No description provided for @outlet.
  ///
  /// In ru, this message translates to:
  /// **'Outlet'**
  String get outlet;

  /// No description provided for @switchOne.
  ///
  /// In ru, this message translates to:
  /// **'Switch (1 gang)'**
  String get switchOne;

  /// No description provided for @switchTwo.
  ///
  /// In ru, this message translates to:
  /// **'Switch (2 gang)'**
  String get switchTwo;

  /// No description provided for @switchThree.
  ///
  /// In ru, this message translates to:
  /// **'Switch (3 gang)'**
  String get switchThree;

  /// No description provided for @sensor.
  ///
  /// In ru, this message translates to:
  /// **'Sensor'**
  String get sensor;

  /// No description provided for @light.
  ///
  /// In ru, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @curtain.
  ///
  /// In ru, this message translates to:
  /// **'Curtain'**
  String get curtain;

  /// No description provided for @airConditioner.
  ///
  /// In ru, this message translates to:
  /// **'Air conditioner'**
  String get airConditioner;

  /// No description provided for @universalDevice.
  ///
  /// In ru, this message translates to:
  /// **'Universal device'**
  String get universalDevice;

  /// No description provided for @deviceId.
  ///
  /// In ru, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @localKey.
  ///
  /// In ru, this message translates to:
  /// **'Local Key'**
  String get localKey;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deviceAddedMessage.
  ///
  /// In ru, this message translates to:
  /// **'{name} added!'**
  String deviceAddedMessage(String name);

  /// No description provided for @localNetworkNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Could not determine the local network'**
  String get localNetworkNotFound;

  /// No description provided for @roomsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Комнаты'**
  String get roomsTitle;

  /// No description provided for @roomsCreateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте комнаты'**
  String get roomsCreateTitle;

  /// No description provided for @roomsOrganizeHint.
  ///
  /// In ru, this message translates to:
  /// **'Организуйте устройства по комнатам'**
  String get roomsOrganizeHint;

  /// No description provided for @roomsAddFirst.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первую комнату'**
  String get roomsAddFirst;

  /// No description provided for @roomsAddButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить комнату'**
  String get roomsAddButton;

  /// No description provided for @onboardingFinishButton.
  ///
  /// In ru, this message translates to:
  /// **'Готово!'**
  String get onboardingFinishButton;

  /// No description provided for @roomAddDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить комнату'**
  String get roomAddDialogTitle;

  /// No description provided for @roomNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get roomNameLabel;

  /// No description provided for @roomNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Спальня'**
  String get roomNameHint;

  /// No description provided for @noDevices.
  ///
  /// In ru, this message translates to:
  /// **'Нет устройств'**
  String get noDevices;

  /// No description provided for @forecastTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз погоды'**
  String get forecastTitle;

  /// No description provided for @ok.
  ///
  /// In ru, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @ipAddressLabel.
  ///
  /// In ru, this message translates to:
  /// **'IP-адрес'**
  String get ipAddressLabel;

  /// No description provided for @menuTitle.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get menuTitle;

  /// No description provided for @menuDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства'**
  String get menuDevices;

  /// No description provided for @menuEnergy.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get menuEnergy;

  /// No description provided for @menuScenes.
  ///
  /// In ru, this message translates to:
  /// **'Сцены'**
  String get menuScenes;

  /// No description provided for @menuScanTuya.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать TUYA'**
  String get menuScanTuya;

  /// No description provided for @menuZigbee.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee'**
  String get menuZigbee;

  /// No description provided for @menuFrigate.
  ///
  /// In ru, this message translates to:
  /// **'Frigate'**
  String get menuFrigate;

  /// No description provided for @menuRooms.
  ///
  /// In ru, this message translates to:
  /// **'Комнаты'**
  String get menuRooms;

  /// No description provided for @menuStatistics.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get menuStatistics;

  /// No description provided for @menuTimers.
  ///
  /// In ru, this message translates to:
  /// **'Таймеры'**
  String get menuTimers;

  /// No description provided for @menuEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get menuEvents;

  /// No description provided for @menuCloud.
  ///
  /// In ru, this message translates to:
  /// **'Облако'**
  String get menuCloud;

  /// No description provided for @menuNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get menuNotifications;

  /// No description provided for @menuPresence.
  ///
  /// In ru, this message translates to:
  /// **'Присутствие'**
  String get menuPresence;

  /// No description provided for @menuSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get menuSettings;

  /// No description provided for @menuThemeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Тема: системная'**
  String get menuThemeSystem;

  /// No description provided for @menuThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Тема: светлая'**
  String get menuThemeLight;

  /// No description provided for @menuThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тема: тёмная'**
  String get menuThemeDark;

  /// No description provided for @backupKeyScanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать ключ'**
  String get backupKeyScanTitle;

  /// No description provided for @switchCameraTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Переключить камеру'**
  String get switchCameraTooltip;

  /// No description provided for @flashTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Вспышка'**
  String get flashTooltip;

  /// No description provided for @backupKeyScanHint.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру на QR-код ключа SHome'**
  String get backupKeyScanHint;

  /// No description provided for @cloudSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'☁️ Облачное хранилище'**
  String get cloudSettingsTitle;

  /// No description provided for @cloudStatusConnected.
  ///
  /// In ru, this message translates to:
  /// **'✅ Подключено'**
  String get cloudStatusConnected;

  /// No description provided for @cloudStatusDisconnected.
  ///
  /// In ru, this message translates to:
  /// **'⚪ Не подключено'**
  String get cloudStatusDisconnected;

  /// No description provided for @cloudStatusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get cloudStatusLabel;

  /// No description provided for @cloudLoginValue.
  ///
  /// In ru, this message translates to:
  /// **'Логин: {login}'**
  String cloudLoginValue(String login);

  /// No description provided for @cloudConnectSection.
  ///
  /// In ru, this message translates to:
  /// **'🔗 Подключение'**
  String get cloudConnectSection;

  /// No description provided for @cloudLogin.
  ///
  /// In ru, this message translates to:
  /// **'Логин'**
  String get cloudLogin;

  /// No description provided for @cloudLoginHint.
  ///
  /// In ru, this message translates to:
  /// **'login@mail.ru'**
  String get cloudLoginHint;

  /// No description provided for @cloudAppPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль приложения'**
  String get cloudAppPassword;

  /// No description provided for @cloudPasswordHelp.
  ///
  /// In ru, this message translates to:
  /// **'💡 Как получить пароль приложения:\n1. Mail.ru → Настройки → Безопасность\n2. Пароли для приложений → Создать\n3. Назовите «SHome» → скопируйте пароль'**
  String get cloudPasswordHelp;

  /// No description provided for @cloudConnecting.
  ///
  /// In ru, this message translates to:
  /// **'Подключение...'**
  String get cloudConnecting;

  /// No description provided for @cloudConnect.
  ///
  /// In ru, this message translates to:
  /// **'Подключить'**
  String get cloudConnect;

  /// No description provided for @cloudEnterCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Введите логин и пароль'**
  String get cloudEnterCredentials;

  /// No description provided for @cloudConnectedMessage.
  ///
  /// In ru, this message translates to:
  /// **'✅ Подключено к облаку'**
  String get cloudConnectedMessage;

  /// No description provided for @cloudConnectFailed.
  ///
  /// In ru, this message translates to:
  /// **'❌ Не удалось подключиться. Проверьте логин и пароль.'**
  String get cloudConnectFailed;

  /// No description provided for @cloudConnectionError.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка подключения: {error}'**
  String cloudConnectionError(String error);

  /// No description provided for @cloudDisconnectedMessage.
  ///
  /// In ru, this message translates to:
  /// **'🔌 Отключено от облака'**
  String get cloudDisconnectedMessage;

  /// No description provided for @cloudDisconnect.
  ///
  /// In ru, this message translates to:
  /// **'Отключить'**
  String get cloudDisconnect;

  /// No description provided for @cloudDisconnectSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Ключ резервного копирования останется на устройстве'**
  String get cloudDisconnectSubtitle;

  /// No description provided for @cloudBackupKeyTitle.
  ///
  /// In ru, this message translates to:
  /// **'🔐 Ключ резервного копирования'**
  String get cloudBackupKeyTitle;

  /// No description provided for @cloudKeyCreated.
  ///
  /// In ru, this message translates to:
  /// **'Ключ создан'**
  String get cloudKeyCreated;

  /// No description provided for @cloudKeyMissing.
  ///
  /// In ru, this message translates to:
  /// **'Ключ не создан'**
  String get cloudKeyMissing;

  /// No description provided for @cloudKeyReadySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'AES-256-GCM готов к работе'**
  String get cloudKeyReadySubtitle;

  /// No description provided for @cloudKeyMissingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте или импортируйте ключ'**
  String get cloudKeyMissingSubtitle;

  /// No description provided for @cloudGenerateNewKeyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать новый ключ?'**
  String get cloudGenerateNewKeyTitle;

  /// No description provided for @cloudGenerateNewKeyWarning.
  ///
  /// In ru, this message translates to:
  /// **'Новый ключ сделает все существующие резервные копии недоступными для восстановления.\n\nПродолжить?'**
  String get cloudGenerateNewKeyWarning;

  /// No description provided for @cloudGenerate.
  ///
  /// In ru, this message translates to:
  /// **'Сгенерировать'**
  String get cloudGenerate;

  /// No description provided for @cloudKeyCreatedMessage.
  ///
  /// In ru, this message translates to:
  /// **'✅ Ключ резервного копирования создан'**
  String get cloudKeyCreatedMessage;

  /// No description provided for @cloudKeyCreateError.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка создания ключа: {error}'**
  String cloudKeyCreateError(String error);

  /// No description provided for @cloudShowQr.
  ///
  /// In ru, this message translates to:
  /// **'Показать QR'**
  String get cloudShowQr;

  /// No description provided for @cloudScanQr.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать QR'**
  String get cloudScanQr;

  /// No description provided for @cloudQrTitle.
  ///
  /// In ru, this message translates to:
  /// **'QR-ключ резервного копирования'**
  String get cloudQrTitle;

  /// No description provided for @cloudQrHint.
  ///
  /// In ru, this message translates to:
  /// **'Отсканируйте этот QR-код на другом устройстве SHome.'**
  String get cloudQrHint;

  /// No description provided for @cloudClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get cloudClose;

  /// No description provided for @cloudNoLoginData.
  ///
  /// In ru, this message translates to:
  /// **'❌ Нет данных для входа в облако'**
  String get cloudNoLoginData;

  /// No description provided for @cloudGenerateKeyFirst.
  ///
  /// In ru, this message translates to:
  /// **'❌ Сначала сгенерируйте ключ резервного копирования'**
  String get cloudGenerateKeyFirst;

  /// No description provided for @cloudImportKeyFirst.
  ///
  /// In ru, this message translates to:
  /// **'❌ Сначала сгенерируйте или импортируйте ключ резервного копирования'**
  String get cloudImportKeyFirst;

  /// No description provided for @cloudBackupUploaded.
  ///
  /// In ru, this message translates to:
  /// **'✅ Бекап загружен в облако'**
  String get cloudBackupUploaded;

  /// No description provided for @cloudBackupUploadFailed.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка загрузки бекапа'**
  String get cloudBackupUploadFailed;

  /// No description provided for @cloudBackupUploadError.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка загрузки: {error}'**
  String cloudBackupUploadError(String error);

  /// No description provided for @cloudBackupManagementTitle.
  ///
  /// In ru, this message translates to:
  /// **'📋 Управление бекапами'**
  String get cloudBackupManagementTitle;

  /// No description provided for @cloudUploadBackup.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить в облако'**
  String get cloudUploadBackup;

  /// No description provided for @cloudUploadBackupSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить текущий бекап в облако'**
  String get cloudUploadBackupSubtitle;

  /// No description provided for @cloudDownloadBackup.
  ///
  /// In ru, this message translates to:
  /// **'Скачать из облака'**
  String get cloudDownloadBackup;

  /// No description provided for @cloudDownloadBackupSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить бекап из облака'**
  String get cloudDownloadBackupSubtitle;

  /// No description provided for @cloudNoBackups.
  ///
  /// In ru, this message translates to:
  /// **'ℹ️ В облаке нет бекапов'**
  String get cloudNoBackups;

  /// No description provided for @cloudChooseBackup.
  ///
  /// In ru, this message translates to:
  /// **'Выберите бекап'**
  String get cloudChooseBackup;

  /// No description provided for @cloudBackupDownloadFailed.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка скачивания бекапа'**
  String get cloudBackupDownloadFailed;

  /// No description provided for @cloudBackupRestoreSuccess.
  ///
  /// In ru, this message translates to:
  /// **'✅ Бекап «{backup}» восстановлен. Перезапустите приложение.'**
  String cloudBackupRestoreSuccess(String backup);

  /// No description provided for @cloudBackupRestoreError.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка восстановления: {error}'**
  String cloudBackupRestoreError(String error);

  /// No description provided for @cloudLastSync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя синхронизация: {date}'**
  String cloudLastSync(String date);

  /// No description provided for @cloudReplaceKeyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заменить ключ?'**
  String get cloudReplaceKeyTitle;

  /// No description provided for @cloudReplaceKeyWarning.
  ///
  /// In ru, this message translates to:
  /// **'На устройстве уже есть ключ резервного копирования.\n\nПосле замены старые бекапы, созданные текущим ключом, станут недоступны.'**
  String get cloudReplaceKeyWarning;

  /// No description provided for @cloudReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get cloudReplace;

  /// No description provided for @cloudKeyImported.
  ///
  /// In ru, this message translates to:
  /// **'✅ Ключ резервного копирования импортирован'**
  String get cloudKeyImported;

  /// No description provided for @cloudKeyImportError.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка импорта ключа: {error}'**
  String cloudKeyImportError(String error);

  /// No description provided for @deviceNotificationsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления устройства'**
  String get deviceNotificationsTitle;

  /// No description provided for @deviceNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Устройство не найдено'**
  String get deviceNotFound;

  /// No description provided for @notificationSettingsSaved.
  ///
  /// In ru, this message translates to:
  /// **'✅ Настройки сохранены'**
  String get notificationSettingsSaved;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @notificationDeviceZigbee.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee-датчик'**
  String get notificationDeviceZigbee;

  /// No description provided for @notificationDeviceFrigate.
  ///
  /// In ru, this message translates to:
  /// **'Frigate-камера'**
  String get notificationDeviceFrigate;

  /// No description provided for @notificationDeviceTuya.
  ///
  /// In ru, this message translates to:
  /// **'Tuya ({type})'**
  String notificationDeviceTuya(String type);

  /// No description provided for @notificationConditionSection.
  ///
  /// In ru, this message translates to:
  /// **'⏱ Условие отправки'**
  String get notificationConditionSection;

  /// No description provided for @notificationConditionAlways.
  ///
  /// In ru, this message translates to:
  /// **'Всегда'**
  String get notificationConditionAlways;

  /// No description provided for @notificationConditionAway.
  ///
  /// In ru, this message translates to:
  /// **'Только когда никого нет дома'**
  String get notificationConditionAway;

  /// No description provided for @notificationConditionNight.
  ///
  /// In ru, this message translates to:
  /// **'Только ночью (22:00 – 06:00)'**
  String get notificationConditionNight;

  /// No description provided for @notificationConditionAwayOrNight.
  ///
  /// In ru, this message translates to:
  /// **'Никого нет дома ИЛИ ночью'**
  String get notificationConditionAwayOrNight;

  /// No description provided for @notificationCooldownSection.
  ///
  /// In ru, this message translates to:
  /// **'⏱ Антидребезг'**
  String get notificationCooldownSection;

  /// No description provided for @notificationInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал'**
  String get notificationInterval;

  /// No description provided for @notificationMinute.
  ///
  /// In ru, this message translates to:
  /// **'1 минута'**
  String get notificationMinute;

  /// No description provided for @notificationMinutes5.
  ///
  /// In ru, this message translates to:
  /// **'5 минут'**
  String get notificationMinutes5;

  /// No description provided for @notificationMinutes15.
  ///
  /// In ru, this message translates to:
  /// **'15 минут'**
  String get notificationMinutes15;

  /// No description provided for @notificationMinutes30.
  ///
  /// In ru, this message translates to:
  /// **'30 минут'**
  String get notificationMinutes30;

  /// No description provided for @notificationTypesTitle.
  ///
  /// In ru, this message translates to:
  /// **'🔔 Типы уведомлений'**
  String get notificationTypesTitle;

  /// No description provided for @notificationFrigateLabelsTitle.
  ///
  /// In ru, this message translates to:
  /// **'🔔 Объекты для детекции'**
  String get notificationFrigateLabelsTitle;

  /// No description provided for @notificationWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'Протечка'**
  String get notificationWaterLeak;

  /// No description provided for @notificationSmoke.
  ///
  /// In ru, this message translates to:
  /// **'Дым'**
  String get notificationSmoke;

  /// No description provided for @notificationGas.
  ///
  /// In ru, this message translates to:
  /// **'Газ'**
  String get notificationGas;

  /// No description provided for @notificationMotion.
  ///
  /// In ru, this message translates to:
  /// **'Движение'**
  String get notificationMotion;

  /// No description provided for @notificationContact.
  ///
  /// In ru, this message translates to:
  /// **'Контакт'**
  String get notificationContact;

  /// No description provided for @notificationLowBattery.
  ///
  /// In ru, this message translates to:
  /// **'Низкий заряд'**
  String get notificationLowBattery;

  /// No description provided for @notificationStateChanged.
  ///
  /// In ru, this message translates to:
  /// **'Вкл/Выкл'**
  String get notificationStateChanged;

  /// No description provided for @notificationOffline.
  ///
  /// In ru, this message translates to:
  /// **'Offline'**
  String get notificationOffline;

  /// No description provided for @notificationError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get notificationError;

  /// No description provided for @notificationTemperatureAbove.
  ///
  /// In ru, this message translates to:
  /// **'Температура >'**
  String get notificationTemperatureAbove;

  /// No description provided for @notificationTemperatureBelow.
  ///
  /// In ru, this message translates to:
  /// **'Температура <'**
  String get notificationTemperatureBelow;

  /// No description provided for @notificationHumidityAbove.
  ///
  /// In ru, this message translates to:
  /// **'Влажность >'**
  String get notificationHumidityAbove;

  /// No description provided for @notificationHumidityBelow.
  ///
  /// In ru, this message translates to:
  /// **'Влажность <'**
  String get notificationHumidityBelow;

  /// No description provided for @notificationPowerAbove.
  ///
  /// In ru, this message translates to:
  /// **'Мощность >'**
  String get notificationPowerAbove;

  /// No description provided for @notificationPerson.
  ///
  /// In ru, this message translates to:
  /// **'Человек'**
  String get notificationPerson;

  /// No description provided for @notificationCar.
  ///
  /// In ru, this message translates to:
  /// **'Автомобиль'**
  String get notificationCar;

  /// No description provided for @notificationDog.
  ///
  /// In ru, this message translates to:
  /// **'Собака'**
  String get notificationDog;

  /// No description provided for @notificationCat.
  ///
  /// In ru, this message translates to:
  /// **'Кошка'**
  String get notificationCat;

  /// No description provided for @notificationBird.
  ///
  /// In ru, this message translates to:
  /// **'Птица'**
  String get notificationBird;

  /// No description provided for @notificationMotorcycle.
  ///
  /// In ru, this message translates to:
  /// **'Мотоцикл'**
  String get notificationMotorcycle;

  /// No description provided for @notificationBicycle.
  ///
  /// In ru, this message translates to:
  /// **'Велосипед'**
  String get notificationBicycle;

  /// No description provided for @notificationTruck.
  ///
  /// In ru, this message translates to:
  /// **'Грузовик'**
  String get notificationTruck;

  /// No description provided for @notificationBus.
  ///
  /// In ru, this message translates to:
  /// **'Автобус'**
  String get notificationBus;

  /// No description provided for @notificationBoat.
  ///
  /// In ru, this message translates to:
  /// **'Лодка'**
  String get notificationBoat;

  /// No description provided for @notificationThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог'**
  String get notificationThreshold;

  /// No description provided for @notificationTemperatureThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог температуры'**
  String get notificationTemperatureThreshold;

  /// No description provided for @notificationHumidityThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог влажности'**
  String get notificationHumidityThreshold;

  /// No description provided for @notificationPowerThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог мощности'**
  String get notificationPowerThreshold;

  /// No description provided for @notificationBatteryThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог заряда'**
  String get notificationBatteryThreshold;

  /// No description provided for @notificationHowItWorks.
  ///
  /// In ru, this message translates to:
  /// **'💡 Как это работает'**
  String get notificationHowItWorks;

  /// No description provided for @notificationAlwaysExplanation.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления отправляются всегда при срабатывании.'**
  String get notificationAlwaysExplanation;

  /// No description provided for @notificationConditionExplanation.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления отправляются только при выполнении условия «{condition}».'**
  String notificationConditionExplanation(String condition);

  /// No description provided for @eventsTitle.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get eventsTitle;

  /// No description provided for @eventsRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get eventsRefresh;

  /// No description provided for @eventsClearAll.
  ///
  /// In ru, this message translates to:
  /// **'Очистить всё'**
  String get eventsClearAll;

  /// No description provided for @eventsClearTitle.
  ///
  /// In ru, this message translates to:
  /// **'Очистить события?'**
  String get eventsClearTitle;

  /// No description provided for @eventsClearWarning.
  ///
  /// In ru, this message translates to:
  /// **'Все события будут удалены безвозвратно.'**
  String get eventsClearWarning;

  /// No description provided for @eventsClearCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get eventsClearCancel;

  /// No description provided for @eventsClearConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get eventsClearConfirm;

  /// No description provided for @eventsFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get eventsFilterAll;

  /// No description provided for @eventsFilterAlerts.
  ///
  /// In ru, this message translates to:
  /// **'Алерты'**
  String get eventsFilterAlerts;

  /// No description provided for @eventsFilterActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get eventsFilterActions;

  /// No description provided for @eventsFilterErrors.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки'**
  String get eventsFilterErrors;

  /// No description provided for @eventsDeviceFilter.
  ///
  /// In ru, this message translates to:
  /// **'Устройство'**
  String get eventsDeviceFilter;

  /// No description provided for @eventsAllDevices.
  ///
  /// In ru, this message translates to:
  /// **'Все устройства'**
  String get eventsAllDevices;

  /// No description provided for @eventsEmptyFilter.
  ///
  /// In ru, this message translates to:
  /// **'Нет событий по фильтру'**
  String get eventsEmptyFilter;

  /// No description provided for @eventsSystemError.
  ///
  /// In ru, this message translates to:
  /// **'Системная ошибка'**
  String get eventsSystemError;

  /// No description provided for @eventsPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get eventsPhone;

  /// No description provided for @eventsPresence.
  ///
  /// In ru, this message translates to:
  /// **'Присутствие'**
  String get eventsPresence;

  /// No description provided for @eventsPresenceAway.
  ///
  /// In ru, this message translates to:
  /// **'Ушёл'**
  String get eventsPresenceAway;

  /// No description provided for @eventsPresenceHomeCloud.
  ///
  /// In ru, this message translates to:
  /// **'Дома (облако)'**
  String get eventsPresenceHomeCloud;

  /// No description provided for @eventsPresenceHomeWifi.
  ///
  /// In ru, this message translates to:
  /// **'Дома (Wi-Fi)'**
  String get eventsPresenceHomeWifi;

  /// No description provided for @eventsPresenceHome.
  ///
  /// In ru, this message translates to:
  /// **'Дома'**
  String get eventsPresenceHome;

  /// No description provided for @eventsPresenceUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get eventsPresenceUnknown;

  /// No description provided for @eventsSceneCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Сцена выполнена'**
  String get eventsSceneCompleted;

  /// No description provided for @eventsTurnedOn.
  ///
  /// In ru, this message translates to:
  /// **'Включено'**
  String get eventsTurnedOn;

  /// No description provided for @eventsTurnedOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключено'**
  String get eventsTurnedOff;

  /// No description provided for @eventsScene.
  ///
  /// In ru, this message translates to:
  /// **'Сцена'**
  String get eventsScene;

  /// No description provided for @eventsRoomAdded.
  ///
  /// In ru, this message translates to:
  /// **'Комната добавлена'**
  String get eventsRoomAdded;

  /// No description provided for @eventsRoomRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Комната удалена'**
  String get eventsRoomRemoved;

  /// No description provided for @eventsTimer.
  ///
  /// In ru, this message translates to:
  /// **'Таймер'**
  String get eventsTimer;

  /// No description provided for @eventsDeviceAdded.
  ///
  /// In ru, this message translates to:
  /// **'Устройство добавлено'**
  String get eventsDeviceAdded;

  /// No description provided for @eventsDeviceRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Устройство удалено'**
  String get eventsDeviceRemoved;

  /// No description provided for @eventsSceneCreated.
  ///
  /// In ru, this message translates to:
  /// **'Сцена создана'**
  String get eventsSceneCreated;

  /// No description provided for @eventsSceneDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Сцена удалена'**
  String get eventsSceneDeleted;

  /// No description provided for @eventsOnline.
  ///
  /// In ru, this message translates to:
  /// **'В сети'**
  String get eventsOnline;

  /// No description provided for @eventsOffline.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети'**
  String get eventsOffline;

  /// No description provided for @eventsError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get eventsError;

  /// No description provided for @eventsAlarmWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'💧 Протечка'**
  String get eventsAlarmWaterLeak;

  /// No description provided for @eventsAlarmSmoke.
  ///
  /// In ru, this message translates to:
  /// **'🔥 Дым'**
  String get eventsAlarmSmoke;

  /// No description provided for @eventsAlarmGas.
  ///
  /// In ru, this message translates to:
  /// **'💨 Газ'**
  String get eventsAlarmGas;

  /// No description provided for @eventsAlarmMotion.
  ///
  /// In ru, this message translates to:
  /// **'🏃 Движение'**
  String get eventsAlarmMotion;

  /// No description provided for @eventsAlarmContactOpen.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Открыто'**
  String get eventsAlarmContactOpen;

  /// No description provided for @eventsAlarmContactClosed.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Закрыто'**
  String get eventsAlarmContactClosed;

  /// No description provided for @eventsAlarmTemperatureAbove.
  ///
  /// In ru, this message translates to:
  /// **'🌡️ Температура >'**
  String get eventsAlarmTemperatureAbove;

  /// No description provided for @eventsAlarmTemperatureBelow.
  ///
  /// In ru, this message translates to:
  /// **'🌡️ Температура <'**
  String get eventsAlarmTemperatureBelow;

  /// No description provided for @eventsAlarmHumidityAbove.
  ///
  /// In ru, this message translates to:
  /// **'💧 Влажность >'**
  String get eventsAlarmHumidityAbove;

  /// No description provided for @eventsAlarmHumidityBelow.
  ///
  /// In ru, this message translates to:
  /// **'💧 Влажность <'**
  String get eventsAlarmHumidityBelow;

  /// No description provided for @eventsFrigatePerson.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Человек'**
  String get eventsFrigatePerson;

  /// No description provided for @eventsFrigateCar.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Автомобиль'**
  String get eventsFrigateCar;

  /// No description provided for @eventsFrigateDog.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Собака'**
  String get eventsFrigateDog;

  /// No description provided for @eventsFrigateCat.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Кошка'**
  String get eventsFrigateCat;

  /// No description provided for @eventsFrigateBird.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Птица'**
  String get eventsFrigateBird;

  /// No description provided for @eventsFrigateOther.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Обнаружение'**
  String get eventsFrigateOther;

  /// No description provided for @frigateSettingsTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Настройки Frigate'**
  String get frigateSettingsTooltip;

  /// No description provided for @frigateRefreshTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get frigateRefreshTooltip;

  /// No description provided for @frigateSHomeCameras.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Камеры в SHome'**
  String get frigateSHomeCameras;

  /// No description provided for @frigateAvailableCameras.
  ///
  /// In ru, this message translates to:
  /// **'📍 Доступные в Frigate'**
  String get frigateAvailableCameras;

  /// No description provided for @frigateNoCameras.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных камер.\nПроверьте настройки Frigate.'**
  String get frigateNoCameras;

  /// No description provided for @frigateAllCamerasAdded.
  ///
  /// In ru, this message translates to:
  /// **'✅ Все камеры добавлены'**
  String get frigateAllCamerasAdded;

  /// No description provided for @frigateStatistics.
  ///
  /// In ru, this message translates to:
  /// **'📊 Статистика'**
  String get frigateStatistics;

  /// No description provided for @frigateStatCameras.
  ///
  /// In ru, this message translates to:
  /// **'Камеры'**
  String get frigateStatCameras;

  /// No description provided for @frigateStatDetectors.
  ///
  /// In ru, this message translates to:
  /// **'Детекторы'**
  String get frigateStatDetectors;

  /// No description provided for @frigateStatCpu.
  ///
  /// In ru, this message translates to:
  /// **'CPU'**
  String get frigateStatCpu;

  /// No description provided for @frigateStatRam.
  ///
  /// In ru, this message translates to:
  /// **'RAM'**
  String get frigateStatRam;

  /// No description provided for @frigateRoomPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Комната: {room}'**
  String frigateRoomPrefix(String room);

  /// No description provided for @frigateCameraSettingsTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get frigateCameraSettingsTooltip;

  /// No description provided for @frigateRemoveFromSHomeTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Удалить из SHome'**
  String get frigateRemoveFromSHomeTooltip;

  /// No description provided for @frigateAddToSHomeTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в SHome'**
  String get frigateAddToSHomeTooltip;

  /// No description provided for @frigateCameraAlreadyAdded.
  ///
  /// In ru, this message translates to:
  /// **'⚠️ Камера «{name}» уже добавлена'**
  String frigateCameraAlreadyAdded(String name);

  /// No description provided for @frigateCameraAdded.
  ///
  /// In ru, this message translates to:
  /// **'✅ Камера «{name}» добавлена'**
  String frigateCameraAdded(String name);

  /// No description provided for @frigateDeleteCameraTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить камеру?'**
  String get frigateDeleteCameraTitle;

  /// No description provided for @frigateDeleteCameraMessage.
  ///
  /// In ru, this message translates to:
  /// **'Камера «{name}» будет удалена из SHome.'**
  String frigateDeleteCameraMessage(String name);

  /// No description provided for @frigateCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get frigateCancel;

  /// No description provided for @frigateDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get frigateDelete;

  /// No description provided for @frigateCameraRemoved.
  ///
  /// In ru, this message translates to:
  /// **'🗑️ Камера «{name}» удалена'**
  String frigateCameraRemoved(String name);

  /// No description provided for @frigateRoomOther.
  ///
  /// In ru, this message translates to:
  /// **'🔌 Техника'**
  String get frigateRoomOther;

  /// No description provided for @frigateRoomLiving.
  ///
  /// In ru, this message translates to:
  /// **'🛋️ Гостиная'**
  String get frigateRoomLiving;

  /// No description provided for @frigateRoomBedroom.
  ///
  /// In ru, this message translates to:
  /// **'🛏️ Спальня'**
  String get frigateRoomBedroom;

  /// No description provided for @frigateRoomKitchen.
  ///
  /// In ru, this message translates to:
  /// **'🍳 Кухня'**
  String get frigateRoomKitchen;

  /// No description provided for @frigateSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки Frigate'**
  String get frigateSettingsTitle;

  /// No description provided for @frigateConnectionSection.
  ///
  /// In ru, this message translates to:
  /// **'Подключение'**
  String get frigateConnectionSection;

  /// No description provided for @frigateHostLabel.
  ///
  /// In ru, this message translates to:
  /// **'Host (IP)'**
  String get frigateHostLabel;

  /// No description provided for @frigateHostHint.
  ///
  /// In ru, this message translates to:
  /// **'192.168.43.16'**
  String get frigateHostHint;

  /// No description provided for @frigatePortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Port'**
  String get frigatePortLabel;

  /// No description provided for @frigatePortHint.
  ///
  /// In ru, this message translates to:
  /// **'5000'**
  String get frigatePortHint;

  /// No description provided for @frigateRtspPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'RTSP-пароль'**
  String get frigateRtspPasswordLabel;

  /// No description provided for @frigateTestConnection.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get frigateTestConnection;

  /// No description provided for @frigateConnectionSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Подключение успешно'**
  String get frigateConnectionSuccess;

  /// No description provided for @frigateConnectionFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться'**
  String get frigateConnectionFailed;

  /// No description provided for @frigateSettingsSection.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get frigateSettingsSection;

  /// No description provided for @frigateStatsIntervalLabel.
  ///
  /// In ru, this message translates to:
  /// **'Интервал статистики (сек)'**
  String get frigateStatsIntervalLabel;

  /// No description provided for @frigateNotifyFor.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления для:'**
  String get frigateNotifyFor;

  /// No description provided for @frigateLabelPerson.
  ///
  /// In ru, this message translates to:
  /// **'Человек'**
  String get frigateLabelPerson;

  /// No description provided for @frigateLabelCar.
  ///
  /// In ru, this message translates to:
  /// **'Автомобиль'**
  String get frigateLabelCar;

  /// No description provided for @frigateLabelDog.
  ///
  /// In ru, this message translates to:
  /// **'Собака'**
  String get frigateLabelDog;

  /// No description provided for @frigateLabelCat.
  ///
  /// In ru, this message translates to:
  /// **'Кошка'**
  String get frigateLabelCat;

  /// No description provided for @frigateLabelMotion.
  ///
  /// In ru, this message translates to:
  /// **'Движение'**
  String get frigateLabelMotion;

  /// No description provided for @frigateSaving.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение...'**
  String get frigateSaving;

  /// No description provided for @frigateSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get frigateSave;

  /// No description provided for @frigateSettingsSaved.
  ///
  /// In ru, this message translates to:
  /// **'✅ Настройки сохранены'**
  String get frigateSettingsSaved;

  /// No description provided for @mqttSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки MQTT'**
  String get mqttSettingsTitle;

  /// No description provided for @mqttBrokerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Брокер MQTT'**
  String get mqttBrokerTitle;

  /// No description provided for @mqttUsageHint.
  ///
  /// In ru, this message translates to:
  /// **'Используется для Zigbee2MQTT и Frigate'**
  String get mqttUsageHint;

  /// No description provided for @mqttHostLabel.
  ///
  /// In ru, this message translates to:
  /// **'Адрес (IP или hostname)'**
  String get mqttHostLabel;

  /// No description provided for @mqttHostHint.
  ///
  /// In ru, this message translates to:
  /// **'192.168.43.16'**
  String get mqttHostHint;

  /// No description provided for @mqttPortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Порт'**
  String get mqttPortLabel;

  /// No description provided for @mqttUsernameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Логин (необязательно)'**
  String get mqttUsernameLabel;

  /// No description provided for @mqttPasswordLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пароль (необязательно)'**
  String get mqttPasswordLabel;

  /// No description provided for @mqttHostRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите адрес брокера'**
  String get mqttHostRequired;

  /// No description provided for @mqttConnectionFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться к брокеру'**
  String get mqttConnectionFailed;

  /// No description provided for @mqttConnectionError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {error}'**
  String mqttConnectionError(String error);

  /// No description provided for @mqttConnectionSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Подключение успешно'**
  String get mqttConnectionSuccess;

  /// No description provided for @mqttConnectionFailureStatus.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подключиться'**
  String get mqttConnectionFailureStatus;

  /// No description provided for @mqttConnecting.
  ///
  /// In ru, this message translates to:
  /// **'Подключение...'**
  String get mqttConnecting;

  /// No description provided for @mqttSaveAndConnect.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить и подключиться'**
  String get mqttSaveAndConnect;

  /// No description provided for @notificationChannelsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationChannelsTitle;

  /// No description provided for @notificationVkSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления в VK'**
  String get notificationVkSubtitle;

  /// No description provided for @notificationSmsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления по SMS'**
  String get notificationSmsSubtitle;

  /// No description provided for @presenceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Присутствие'**
  String get presenceTitle;

  /// No description provided for @presenceTrackingEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить отслеживание'**
  String get presenceTrackingEnable;

  /// No description provided for @presenceTrackingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Определять, кто дома'**
  String get presenceTrackingSubtitle;

  /// No description provided for @presencePhones.
  ///
  /// In ru, this message translates to:
  /// **'Телефоны'**
  String get presencePhones;

  /// No description provided for @presenceNoPhones.
  ///
  /// In ru, this message translates to:
  /// **'Нет добавленных телефонов'**
  String get presenceNoPhones;

  /// No description provided for @presenceHomeZone.
  ///
  /// In ru, this message translates to:
  /// **'Домашняя зона'**
  String get presenceHomeZone;

  /// No description provided for @presenceNotConfigured.
  ///
  /// In ru, this message translates to:
  /// **'Не настроено'**
  String get presenceNotConfigured;

  /// No description provided for @presenceRadius.
  ///
  /// In ru, this message translates to:
  /// **'Радиус'**
  String get presenceRadius;

  /// No description provided for @presenceAwayTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Таймаут «ушёл»'**
  String get presenceAwayTimeout;

  /// No description provided for @presenceHomeWifi.
  ///
  /// In ru, this message translates to:
  /// **'Дома (Wi-Fi)'**
  String get presenceHomeWifi;

  /// No description provided for @presenceHeartbeatActive.
  ///
  /// In ru, this message translates to:
  /// **'Heartbeat активен'**
  String get presenceHeartbeatActive;

  /// No description provided for @presenceHomeCloud.
  ///
  /// In ru, this message translates to:
  /// **'Дома (облако)'**
  String get presenceHomeCloud;

  /// No description provided for @presenceWifiInactiveGpsUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Wi-Fi не активен · GPS недоступен'**
  String get presenceWifiInactiveGpsUnavailable;

  /// No description provided for @presenceWifiInactiveDistance.
  ///
  /// In ru, this message translates to:
  /// **'Wi-Fi не активен · {distance} от дома'**
  String presenceWifiInactiveDistance(String distance);

  /// No description provided for @presenceAway.
  ///
  /// In ru, this message translates to:
  /// **'Ушёл'**
  String get presenceAway;

  /// No description provided for @presenceDistanceFromHome.
  ///
  /// In ru, this message translates to:
  /// **'Расстояние: {distance} от дома'**
  String presenceDistanceFromHome(String distance);

  /// No description provided for @presenceUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get presenceUnknown;

  /// No description provided for @presenceEditPhone.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать телефон'**
  String get presenceEditPhone;

  /// No description provided for @presenceAddPhone.
  ///
  /// In ru, this message translates to:
  /// **'Добавить телефон'**
  String get presenceAddPhone;

  /// No description provided for @presenceName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get presenceName;

  /// No description provided for @presenceNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Мой телефон'**
  String get presenceNameHint;

  /// No description provided for @presencePhoneId.
  ///
  /// In ru, this message translates to:
  /// **'Phone ID'**
  String get presencePhoneId;

  /// No description provided for @presencePhoneIdHint.
  ///
  /// In ru, this message translates to:
  /// **'89533309330'**
  String get presencePhoneIdHint;

  /// No description provided for @presenceDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get presenceDelete;

  /// No description provided for @presenceCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get presenceCancel;

  /// No description provided for @presenceSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get presenceSave;

  /// No description provided for @presenceAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get presenceAdd;

  /// No description provided for @presenceLatitude.
  ///
  /// In ru, this message translates to:
  /// **'Широта'**
  String get presenceLatitude;

  /// No description provided for @presenceLongitude.
  ///
  /// In ru, this message translates to:
  /// **'Долгота'**
  String get presenceLongitude;

  /// No description provided for @presenceGetCurrentCoordinates.
  ///
  /// In ru, this message translates to:
  /// **'Определить мои координаты'**
  String get presenceGetCurrentCoordinates;

  /// No description provided for @presenceGpsDisabled.
  ///
  /// In ru, this message translates to:
  /// **'❌ GPS выключен в системе. Включите его в настройках.'**
  String get presenceGpsDisabled;

  /// No description provided for @presencePermissionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нет разрешения'**
  String get presencePermissionTitle;

  /// No description provided for @presencePermissionMessage.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение на GPS отклонено навсегда.\nОткройте настройки и разрешите его вручную.'**
  String get presencePermissionMessage;

  /// No description provided for @presenceOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get presenceOpenSettings;

  /// No description provided for @presencePermissionNotGranted.
  ///
  /// In ru, this message translates to:
  /// **'❌ Разрешение на GPS не выдано'**
  String get presencePermissionNotGranted;

  /// No description provided for @presenceGettingGps.
  ///
  /// In ru, this message translates to:
  /// **'Получаем GPS…\nЭто может занять до 60 секунд'**
  String get presenceGettingGps;

  /// No description provided for @presenceCoordinatesReceived.
  ///
  /// In ru, this message translates to:
  /// **'✅ Координаты получены:\n{latitude}, {longitude}'**
  String presenceCoordinatesReceived(String latitude, String longitude);

  /// No description provided for @presenceGpsFailed.
  ///
  /// In ru, this message translates to:
  /// **'❌ Не удалось получить GPS.\nПопробуйте выйти на открытое место.'**
  String get presenceGpsFailed;

  /// No description provided for @presenceMeters.
  ///
  /// In ru, this message translates to:
  /// **'Метры'**
  String get presenceMeters;

  /// No description provided for @presenceRadiusHint.
  ///
  /// In ru, this message translates to:
  /// **'100'**
  String get presenceRadiusHint;

  /// No description provided for @presenceMinutes.
  ///
  /// In ru, this message translates to:
  /// **'Минуты'**
  String get presenceMinutes;

  /// No description provided for @presenceTimeoutHint.
  ///
  /// In ru, this message translates to:
  /// **'5'**
  String get presenceTimeoutHint;

  /// No description provided for @roomsManageEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет комнат. Добавьте первую!'**
  String get roomsManageEmpty;

  /// No description provided for @roomsDeviceCount.
  ///
  /// In ru, this message translates to:
  /// **'Устройств: {count}'**
  String roomsDeviceCount(int count);

  /// No description provided for @roomsEditDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать комнату'**
  String get roomsEditDialogTitle;

  /// No description provided for @roomsDeleteDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить комнату?'**
  String get roomsDeleteDialogTitle;

  /// No description provided for @roomsDeleteWithDevices.
  ///
  /// In ru, this message translates to:
  /// **'В комнате {count} устройств. Они будут перенесены в «Все устройства». Продолжить?'**
  String roomsDeleteWithDevices(int count);

  /// No description provided for @roomsDeleteConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Удалить комнату «{name}»?'**
  String roomsDeleteConfirmation(String name);

  /// No description provided for @roomsAllDevices.
  ///
  /// In ru, this message translates to:
  /// **'Все устройства'**
  String get roomsAllDevices;

  /// No description provided for @roomsDeletedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Комната «{name}» удалена'**
  String roomsDeletedMessage(String name);

  /// No description provided for @roomIconLiving.
  ///
  /// In ru, this message translates to:
  /// **'Гостиная'**
  String get roomIconLiving;

  /// No description provided for @roomIconBedroom.
  ///
  /// In ru, this message translates to:
  /// **'Спальня'**
  String get roomIconBedroom;

  /// No description provided for @roomIconKitchen.
  ///
  /// In ru, this message translates to:
  /// **'Кухня'**
  String get roomIconKitchen;

  /// No description provided for @roomIconBathroom.
  ///
  /// In ru, this message translates to:
  /// **'Ванная'**
  String get roomIconBathroom;

  /// No description provided for @roomIconGarage.
  ///
  /// In ru, this message translates to:
  /// **'Гараж'**
  String get roomIconGarage;

  /// No description provided for @roomIconYard.
  ///
  /// In ru, this message translates to:
  /// **'Двор'**
  String get roomIconYard;

  /// No description provided for @roomIconKids.
  ///
  /// In ru, this message translates to:
  /// **'Детская'**
  String get roomIconKids;

  /// No description provided for @roomIconStorage.
  ///
  /// In ru, this message translates to:
  /// **'Кладовая'**
  String get roomIconStorage;

  /// No description provided for @roomIconOffice.
  ///
  /// In ru, this message translates to:
  /// **'Кабинет'**
  String get roomIconOffice;

  /// No description provided for @roomIconHome.
  ///
  /// In ru, this message translates to:
  /// **'Дом'**
  String get roomIconHome;

  /// No description provided for @roomIconAppliances.
  ///
  /// In ru, this message translates to:
  /// **'Техника'**
  String get roomIconAppliances;

  /// No description provided for @roomsDeleteButton.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get roomsDeleteButton;

  /// No description provided for @scenesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сцены'**
  String get scenesTitle;

  /// No description provided for @scenesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет сцен. Создайте первую!'**
  String get scenesEmpty;

  /// No description provided for @scenesManual.
  ///
  /// In ru, this message translates to:
  /// **'Вручную'**
  String get scenesManual;

  /// No description provided for @scenesAutoTriggerMessage.
  ///
  /// In ru, this message translates to:
  /// **'⏰ Сцена «{name}» запускается автоматически по триггеру'**
  String scenesAutoTriggerMessage(String name);

  /// No description provided for @scenesActionCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} устр.'**
  String scenesActionCount(int count);

  /// No description provided for @scenesTimeTemperature.
  ///
  /// In ru, this message translates to:
  /// **'Темп. {operator} {threshold}°C'**
  String scenesTimeTemperature(String operator, String threshold);

  /// No description provided for @scenesHumidity.
  ///
  /// In ru, this message translates to:
  /// **'Влаж. {operator} {threshold}%'**
  String scenesHumidity(String operator, String threshold);

  /// No description provided for @scenesWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'💧 Протечка'**
  String get scenesWaterLeak;

  /// No description provided for @scenesMotion.
  ///
  /// In ru, this message translates to:
  /// **'🏃 Движение'**
  String get scenesMotion;

  /// No description provided for @scenesContactOpen.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Открыто'**
  String get scenesContactOpen;

  /// No description provided for @scenesContactClosed.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Закрыто'**
  String get scenesContactClosed;

  /// No description provided for @scenesSmoke.
  ///
  /// In ru, this message translates to:
  /// **'🔥 Дым'**
  String get scenesSmoke;

  /// No description provided for @scenesGas.
  ///
  /// In ru, this message translates to:
  /// **'💨 Газ'**
  String get scenesGas;

  /// No description provided for @scenesPresence.
  ///
  /// In ru, this message translates to:
  /// **'Присутствие'**
  String get scenesPresence;

  /// No description provided for @scenesSomeoneArrived.
  ///
  /// In ru, this message translates to:
  /// **'Кто-то пришёл'**
  String get scenesSomeoneArrived;

  /// No description provided for @scenesNobodyHome.
  ///
  /// In ru, this message translates to:
  /// **'Никого нет'**
  String get scenesNobodyHome;

  /// No description provided for @scenesEveryoneHome.
  ///
  /// In ru, this message translates to:
  /// **'Все дома'**
  String get scenesEveryoneHome;

  /// No description provided for @scenesPhoneArrived.
  ///
  /// In ru, this message translates to:
  /// **'Телефон пришёл'**
  String get scenesPhoneArrived;

  /// No description provided for @scenesPhoneLeft.
  ///
  /// In ru, this message translates to:
  /// **'Телефон ушёл'**
  String get scenesPhoneLeft;

  /// No description provided for @scenesPhoneUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Телефон потерян'**
  String get scenesPhoneUnknown;

  /// No description provided for @scenesEveryDay.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get scenesEveryDay;

  /// No description provided for @scenesWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'По дням недели'**
  String get scenesWeekdays;

  /// No description provided for @scenesInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал'**
  String get scenesInterval;

  /// No description provided for @scenesMondayShort.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get scenesMondayShort;

  /// No description provided for @scenesTuesdayShort.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get scenesTuesdayShort;

  /// No description provided for @scenesWednesdayShort.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get scenesWednesdayShort;

  /// No description provided for @scenesThursdayShort.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get scenesThursdayShort;

  /// No description provided for @scenesFridayShort.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get scenesFridayShort;

  /// No description provided for @scenesSaturdayShort.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get scenesSaturdayShort;

  /// No description provided for @scenesSundayShort.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get scenesSundayShort;

  /// No description provided for @scenesActionOn.
  ///
  /// In ru, this message translates to:
  /// **'ВКЛ'**
  String get scenesActionOn;

  /// No description provided for @scenesActionOff.
  ///
  /// In ru, this message translates to:
  /// **'ВЫКЛ'**
  String get scenesActionOff;

  /// No description provided for @scenesActionBrightness.
  ///
  /// In ru, this message translates to:
  /// **'ЯРК'**
  String get scenesActionBrightness;

  /// No description provided for @scenesEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get scenesEdit;

  /// No description provided for @scenesDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get scenesDelete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
