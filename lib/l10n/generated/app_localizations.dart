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

  /// No description provided for @sceneEditorTitleNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая сцена'**
  String get sceneEditorTitleNew;

  /// No description provided for @sceneEditorTitleEdit.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать сцену'**
  String get sceneEditorTitleEdit;

  /// No description provided for @sceneEditorName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get sceneEditorName;

  /// No description provided for @sceneEditorNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Выключить всё'**
  String get sceneEditorNameHint;

  /// No description provided for @sceneEditorTriggerType.
  ///
  /// In ru, this message translates to:
  /// **'Тип запуска'**
  String get sceneEditorTriggerType;

  /// No description provided for @sceneEditorTriggerManual.
  ///
  /// In ru, this message translates to:
  /// **'🎬 Вручную'**
  String get sceneEditorTriggerManual;

  /// No description provided for @sceneEditorTriggerTime.
  ///
  /// In ru, this message translates to:
  /// **'⏰ По времени'**
  String get sceneEditorTriggerTime;

  /// No description provided for @sceneEditorTriggerSensor.
  ///
  /// In ru, this message translates to:
  /// **'🌡️ По датчику'**
  String get sceneEditorTriggerSensor;

  /// No description provided for @sceneEditorTriggerPresence.
  ///
  /// In ru, this message translates to:
  /// **'📍 По присутствию'**
  String get sceneEditorTriggerPresence;

  /// No description provided for @sceneEditorRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повтор'**
  String get sceneEditorRepeat;

  /// No description provided for @sceneEditorRepeatOnce.
  ///
  /// In ru, this message translates to:
  /// **'Один раз'**
  String get sceneEditorRepeatOnce;

  /// No description provided for @sceneEditorRepeatDaily.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get sceneEditorRepeatDaily;

  /// No description provided for @sceneEditorRepeatWeekly.
  ///
  /// In ru, this message translates to:
  /// **'По дням недели'**
  String get sceneEditorRepeatWeekly;

  /// No description provided for @sceneEditorDaysOfWeek.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get sceneEditorDaysOfWeek;

  /// No description provided for @sceneEditorMonday.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get sceneEditorMonday;

  /// No description provided for @sceneEditorTuesday.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get sceneEditorTuesday;

  /// No description provided for @sceneEditorWednesday.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get sceneEditorWednesday;

  /// No description provided for @sceneEditorThursday.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get sceneEditorThursday;

  /// No description provided for @sceneEditorFriday.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get sceneEditorFriday;

  /// No description provided for @sceneEditorSaturday.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get sceneEditorSaturday;

  /// No description provided for @sceneEditorSunday.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get sceneEditorSunday;

  /// No description provided for @sceneEditorSensor.
  ///
  /// In ru, this message translates to:
  /// **'Датчик'**
  String get sceneEditorSensor;

  /// No description provided for @sceneEditorSelectSensor.
  ///
  /// In ru, this message translates to:
  /// **'Выберите датчик'**
  String get sceneEditorSelectSensor;

  /// No description provided for @sceneEditorCondition.
  ///
  /// In ru, this message translates to:
  /// **'Условие'**
  String get sceneEditorCondition;

  /// No description provided for @sceneEditorTemperatureAbove.
  ///
  /// In ru, this message translates to:
  /// **'🌡️ Температура выше {threshold} °C'**
  String sceneEditorTemperatureAbove(String threshold);

  /// No description provided for @sceneEditorTemperatureBelow.
  ///
  /// In ru, this message translates to:
  /// **'🌡️ Температура ниже {threshold} °C'**
  String sceneEditorTemperatureBelow(String threshold);

  /// No description provided for @sceneEditorHumidityAbove.
  ///
  /// In ru, this message translates to:
  /// **'💧 Влажность выше {threshold}%'**
  String sceneEditorHumidityAbove(String threshold);

  /// No description provided for @sceneEditorHumidityBelow.
  ///
  /// In ru, this message translates to:
  /// **'💧 Влажность ниже {threshold}%'**
  String sceneEditorHumidityBelow(String threshold);

  /// No description provided for @sceneEditorWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'💧 Протечка'**
  String get sceneEditorWaterLeak;

  /// No description provided for @sceneEditorMotion.
  ///
  /// In ru, this message translates to:
  /// **'🏃 Движение'**
  String get sceneEditorMotion;

  /// No description provided for @sceneEditorContactOpen.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Открыто'**
  String get sceneEditorContactOpen;

  /// No description provided for @sceneEditorContactClosed.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Закрыто'**
  String get sceneEditorContactClosed;

  /// No description provided for @sceneEditorSmoke.
  ///
  /// In ru, this message translates to:
  /// **'🔥 Дым'**
  String get sceneEditorSmoke;

  /// No description provided for @sceneEditorGas.
  ///
  /// In ru, this message translates to:
  /// **'💨 Газ'**
  String get sceneEditorGas;

  /// No description provided for @sceneEditorThreshold.
  ///
  /// In ru, this message translates to:
  /// **'Порог'**
  String get sceneEditorThreshold;

  /// No description provided for @sceneEditorPresenceEvent.
  ///
  /// In ru, this message translates to:
  /// **'Событие'**
  String get sceneEditorPresenceEvent;

  /// No description provided for @sceneEditorSomeoneHome.
  ///
  /// In ru, this message translates to:
  /// **'Кто-то пришёл'**
  String get sceneEditorSomeoneHome;

  /// No description provided for @sceneEditorNobodyHome.
  ///
  /// In ru, this message translates to:
  /// **'Никого нет'**
  String get sceneEditorNobodyHome;

  /// No description provided for @sceneEditorAllHome.
  ///
  /// In ru, this message translates to:
  /// **'Все дома'**
  String get sceneEditorAllHome;

  /// No description provided for @sceneEditorPhoneArrived.
  ///
  /// In ru, this message translates to:
  /// **'Телефон пришёл'**
  String get sceneEditorPhoneArrived;

  /// No description provided for @sceneEditorPhoneLeft.
  ///
  /// In ru, this message translates to:
  /// **'Телефон ушёл'**
  String get sceneEditorPhoneLeft;

  /// No description provided for @sceneEditorPhoneUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Телефон потерян'**
  String get sceneEditorPhoneUnknown;

  /// No description provided for @sceneEditorPhone.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get sceneEditorPhone;

  /// No description provided for @sceneEditorSelectPhone.
  ///
  /// In ru, this message translates to:
  /// **'Выберите телефон'**
  String get sceneEditorSelectPhone;

  /// No description provided for @sceneEditorAdvanced.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get sceneEditorAdvanced;

  /// No description provided for @sceneEditorDetectionChannel.
  ///
  /// In ru, this message translates to:
  /// **'Канал определения'**
  String get sceneEditorDetectionChannel;

  /// No description provided for @sceneEditorChannelAny.
  ///
  /// In ru, this message translates to:
  /// **'Любой'**
  String get sceneEditorChannelAny;

  /// No description provided for @sceneEditorChannelWifi.
  ///
  /// In ru, this message translates to:
  /// **'Только Wi-Fi'**
  String get sceneEditorChannelWifi;

  /// No description provided for @sceneEditorChannelGps.
  ///
  /// In ru, this message translates to:
  /// **'Только GPS'**
  String get sceneEditorChannelGps;

  /// No description provided for @sceneEditorStartDelay.
  ///
  /// In ru, this message translates to:
  /// **'Задержка перед запуском'**
  String get sceneEditorStartDelay;

  /// No description provided for @sceneEditorNoDelay.
  ///
  /// In ru, this message translates to:
  /// **'Без задержки'**
  String get sceneEditorNoDelay;

  /// No description provided for @sceneEditorMinute.
  ///
  /// In ru, this message translates to:
  /// **'1 минута'**
  String get sceneEditorMinute;

  /// No description provided for @sceneEditorMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count} минут'**
  String sceneEditorMinutes(int count);

  /// No description provided for @sceneEditorCooldown.
  ///
  /// In ru, this message translates to:
  /// **'Антидребезг'**
  String get sceneEditorCooldown;

  /// No description provided for @sceneEditorConfigureConditions.
  ///
  /// In ru, this message translates to:
  /// **'Настроить условия'**
  String get sceneEditorConfigureConditions;

  /// No description provided for @sceneEditorConditionsConfigured.
  ///
  /// In ru, this message translates to:
  /// **'Условия настроены ✓'**
  String get sceneEditorConditionsConfigured;

  /// No description provided for @sceneEditorActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get sceneEditorActions;

  /// No description provided for @sceneEditorNoDevices.
  ///
  /// In ru, this message translates to:
  /// **'Нет устройств'**
  String get sceneEditorNoDevices;

  /// No description provided for @sceneEditorActionOn.
  ///
  /// In ru, this message translates to:
  /// **'ВКЛ'**
  String get sceneEditorActionOn;

  /// No description provided for @sceneEditorActionOff.
  ///
  /// In ru, this message translates to:
  /// **'ВЫКЛ'**
  String get sceneEditorActionOff;

  /// No description provided for @sceneEditorCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get sceneEditorCancel;

  /// No description provided for @sceneEditorSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get sceneEditorSave;

  /// No description provided for @sceneEditorCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get sceneEditorCreate;

  /// No description provided for @sceneEditorValidation.
  ///
  /// In ru, this message translates to:
  /// **'⚠️ Введите название и выберите действия'**
  String get sceneEditorValidation;

  /// No description provided for @sceneEditorUpdated.
  ///
  /// In ru, this message translates to:
  /// **'✅ Сцена обновлена!'**
  String get sceneEditorUpdated;

  /// No description provided for @sceneEditorCreated.
  ///
  /// In ru, this message translates to:
  /// **'✅ Сцена создана!'**
  String get sceneEditorCreated;

  /// No description provided for @sceneEditorConditionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Условия'**
  String get sceneEditorConditionsTitle;

  /// No description provided for @sceneEditorTimeOfDay.
  ///
  /// In ru, this message translates to:
  /// **'Время суток'**
  String get sceneEditorTimeOfDay;

  /// No description provided for @sceneEditorFromTime.
  ///
  /// In ru, this message translates to:
  /// **'С {time}'**
  String sceneEditorFromTime(String time);

  /// No description provided for @sceneEditorUntilTime.
  ///
  /// In ru, this message translates to:
  /// **'До {time}'**
  String sceneEditorUntilTime(String time);

  /// No description provided for @sceneEditorDaysCondition.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get sceneEditorDaysCondition;

  /// No description provided for @sceneEditorReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get sceneEditorReset;

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

  /// No description provided for @scenesAutoTriggerMessage.
  ///
  /// In ru, this message translates to:
  /// **'⏰ Сцена «{name}» запускается автоматически по триггеру'**
  String scenesAutoTriggerMessage(String name);

  /// No description provided for @sceneEditorActionBrightness.
  ///
  /// In ru, this message translates to:
  /// **'ЯРК'**
  String get sceneEditorActionBrightness;

  /// No description provided for @sceneEditorDeviceUnitShort.
  ///
  /// In ru, this message translates to:
  /// **'устр.'**
  String get sceneEditorDeviceUnitShort;

  /// No description provided for @scenesPresence.
  ///
  /// In ru, this message translates to:
  /// **'Присутствие'**
  String get scenesPresence;

  /// No description provided for @scenesDeviceFallback.
  ///
  /// In ru, this message translates to:
  /// **'Устройство'**
  String get scenesDeviceFallback;

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

  /// No description provided for @screenSaverTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заставка'**
  String get screenSaverTitle;

  /// No description provided for @screenSaverSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Показывать анимированную заставку после бездействия'**
  String get screenSaverSubtitle;

  /// No description provided for @screenSaverMotionWakeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сбрасывать заставку по движению'**
  String get screenSaverMotionWakeTitle;

  /// No description provided for @screenSaverMotionWakeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Использовать фронтальную камеру, пока показана заставка'**
  String get screenSaverMotionWakeSubtitle;

  /// No description provided for @screenSaverSensitivity.
  ///
  /// In ru, this message translates to:
  /// **'Чувствительность: {value}%'**
  String screenSaverSensitivity(int value);

  /// No description provided for @screenSaverSensitivityLow.
  ///
  /// In ru, this message translates to:
  /// **'Низкая'**
  String get screenSaverSensitivityLow;

  /// No description provided for @screenSaverSensitivityHigh.
  ///
  /// In ru, this message translates to:
  /// **'Высокая'**
  String get screenSaverSensitivityHigh;

  /// No description provided for @screenSaverSensitivityHint.
  ///
  /// In ru, this message translates to:
  /// **'Если заставка срабатывает без движения, уменьшите чувствительность.'**
  String get screenSaverSensitivityHint;

  /// No description provided for @screenSaverTimeoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Время до заставки'**
  String get screenSaverTimeoutTitle;

  /// No description provided for @screenSaverChoose.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get screenSaverChoose;

  /// No description provided for @screenSaverTimeout30.
  ///
  /// In ru, this message translates to:
  /// **'30 секунд'**
  String get screenSaverTimeout30;

  /// No description provided for @screenSaverTimeout60.
  ///
  /// In ru, this message translates to:
  /// **'1 минута'**
  String get screenSaverTimeout60;

  /// No description provided for @screenSaverTimeout120.
  ///
  /// In ru, this message translates to:
  /// **'2 минуты'**
  String get screenSaverTimeout120;

  /// No description provided for @screenSaverTimeout300.
  ///
  /// In ru, this message translates to:
  /// **'5 минут'**
  String get screenSaverTimeout300;

  /// No description provided for @screenSaverTimeout600.
  ///
  /// In ru, this message translates to:
  /// **'10 минут'**
  String get screenSaverTimeout600;

  /// No description provided for @screenSaverTimeoutSeconds.
  ///
  /// In ru, this message translates to:
  /// **'{value} секунд'**
  String screenSaverTimeoutSeconds(int value);

  /// No description provided for @settingsPollInterval.
  ///
  /// In ru, this message translates to:
  /// **'Интервал опроса'**
  String get settingsPollInterval;

  /// No description provided for @settingsIntervalSeconds.
  ///
  /// In ru, this message translates to:
  /// **'{value} сек.'**
  String settingsIntervalSeconds(int value);

  /// No description provided for @settingsIntervalMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{value} мин.'**
  String settingsIntervalMinutes(int value);

  /// No description provided for @settingsPollIntervalChanged.
  ///
  /// In ru, this message translates to:
  /// **'Интервал изменён на {interval}. Перезапустите приложение.'**
  String settingsPollIntervalChanged(String interval);

  /// No description provided for @settingsEventsRetention.
  ///
  /// In ru, this message translates to:
  /// **'Хранить события'**
  String get settingsEventsRetention;

  /// No description provided for @settingsDays.
  ///
  /// In ru, this message translates to:
  /// **'{value} дней'**
  String settingsDays(int value);

  /// No description provided for @settingsElectricityTariff.
  ///
  /// In ru, this message translates to:
  /// **'Тариф электроэнергии'**
  String get settingsElectricityTariff;

  /// No description provided for @settingsCurrencyPerKwh.
  ///
  /// In ru, this message translates to:
  /// **'{value} ₽/кВт·ч'**
  String settingsCurrencyPerKwh(String value);

  /// No description provided for @settingsBackup.
  ///
  /// In ru, this message translates to:
  /// **'Резервное копирование'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт / Импорт'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsMqtt.
  ///
  /// In ru, this message translates to:
  /// **'Настройки MQTT'**
  String get settingsMqtt;

  /// No description provided for @settingsMqttSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Брокер для Zigbee2MQTT'**
  String get settingsMqttSubtitle;

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновления'**
  String get settingsCheckUpdates;

  /// No description provided for @settingsCheckUpdatesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверить наличие новой версии'**
  String get settingsCheckUpdatesSubtitle;

  /// No description provided for @settingsInformation.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get settingsInformation;

  /// No description provided for @settingsInformationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Лицензии и соглашения'**
  String get settingsInformationSubtitle;

  /// No description provided for @settingsExportReady.
  ///
  /// In ru, this message translates to:
  /// **'✅ Конфиг готов к отправке'**
  String get settingsExportReady;

  /// No description provided for @settingsError.
  ///
  /// In ru, this message translates to:
  /// **'❌ Ошибка: {error}'**
  String settingsError(String error);

  /// No description provided for @settingsImportDone.
  ///
  /// In ru, this message translates to:
  /// **'✅ Импорт выполнен'**
  String get settingsImportDone;

  /// No description provided for @settingsImportRestartHint.
  ///
  /// In ru, this message translates to:
  /// **'Данные восстановлены.\n\nРекомендуется перезапустить приложение, чтобы все настройки (VK, облако, устройства) применились.'**
  String get settingsImportRestartHint;

  /// No description provided for @settingsLater.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get settingsLater;

  /// No description provided for @settingsRestart.
  ///
  /// In ru, this message translates to:
  /// **'Перезапустить'**
  String get settingsRestart;

  /// No description provided for @settingsBackupDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Резервное копирование'**
  String get settingsBackupDialogTitle;

  /// No description provided for @settingsExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспортировать'**
  String get settingsExport;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться через облако, почту или Telegram'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImport.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать'**
  String get settingsImport;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать файл на устройстве или в облаке'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsRetentionDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Хранить события'**
  String get settingsRetentionDialogTitle;

  /// No description provided for @settingsRetentionDays.
  ///
  /// In ru, this message translates to:
  /// **'{value} дней'**
  String settingsRetentionDays(int value);

  /// No description provided for @settingsTariffDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тариф ₽/кВт·ч'**
  String get settingsTariffDialogTitle;

  /// No description provided for @settingsTariffInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректный тариф больше нуля'**
  String get settingsTariffInvalid;

  /// No description provided for @settingsTariffHint.
  ///
  /// In ru, this message translates to:
  /// **'5.5'**
  String get settingsTariffHint;

  /// No description provided for @smsSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'SMS-уведомления'**
  String get smsSettingsTitle;

  /// No description provided for @smsSettingsEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить SMS'**
  String get smsSettingsEnable;

  /// No description provided for @smsSettingsEnableSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отправлять уведомления по SMS'**
  String get smsSettingsEnableSubtitle;

  /// No description provided for @smsSettingsPhoneNumbers.
  ///
  /// In ru, this message translates to:
  /// **'Номера телефонов'**
  String get smsSettingsPhoneNumbers;

  /// No description provided for @smsSettingsNoPhones.
  ///
  /// In ru, this message translates to:
  /// **'Нет добавленных номеров'**
  String get smsSettingsNoPhones;

  /// No description provided for @smsSettingsEventsTitle.
  ///
  /// In ru, this message translates to:
  /// **'События для SMS'**
  String get smsSettingsEventsTitle;

  /// No description provided for @smsSettingsScenes.
  ///
  /// In ru, this message translates to:
  /// **'Сцены'**
  String get smsSettingsScenes;

  /// No description provided for @smsSettingsDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства'**
  String get smsSettingsDevices;

  /// No description provided for @smsSettingsAlarms.
  ///
  /// In ru, this message translates to:
  /// **'Тревоги'**
  String get smsSettingsAlarms;

  /// No description provided for @smsSettingsZigbeeWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 💧 Протечка'**
  String get smsSettingsZigbeeWaterLeak;

  /// No description provided for @smsSettingsZigbeeSmoke.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 🔥 Дым'**
  String get smsSettingsZigbeeSmoke;

  /// No description provided for @smsSettingsZigbeeGas.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 💨 Газ'**
  String get smsSettingsZigbeeGas;

  /// No description provided for @smsSettingsZigbeeMotion.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 🏃 Движение'**
  String get smsSettingsZigbeeMotion;

  /// No description provided for @smsSettingsZigbeeContact.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 🚪 Контакт'**
  String get smsSettingsZigbeeContact;

  /// No description provided for @smsSettingsFrigatePerson.
  ///
  /// In ru, this message translates to:
  /// **'Frigate: 🚶 Человек'**
  String get smsSettingsFrigatePerson;

  /// No description provided for @smsSettingsFrigateCar.
  ///
  /// In ru, this message translates to:
  /// **'Frigate: 🚗 Автомобиль'**
  String get smsSettingsFrigateCar;

  /// No description provided for @smsSettingsErrors.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки'**
  String get smsSettingsErrors;

  /// No description provided for @smsSettingsZigbeeOffline.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee offline'**
  String get smsSettingsZigbeeOffline;

  /// No description provided for @smsSettingsZigbeeOfflineSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Устройство потеряло связь'**
  String get smsSettingsZigbeeOfflineSubtitle;

  /// No description provided for @smsSettingsFrigateOffline.
  ///
  /// In ru, this message translates to:
  /// **'Frigate offline'**
  String get smsSettingsFrigateOffline;

  /// No description provided for @smsSettingsFrigateOfflineSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Frigate недоступен'**
  String get smsSettingsFrigateOfflineSubtitle;

  /// No description provided for @smsSettingsCooldown.
  ///
  /// In ru, this message translates to:
  /// **'Антидребезг SMS'**
  String get smsSettingsCooldown;

  /// No description provided for @smsSettingsOneMinute.
  ///
  /// In ru, this message translates to:
  /// **'1 минута'**
  String get smsSettingsOneMinute;

  /// No description provided for @smsSettingsMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count} минут'**
  String smsSettingsMinutes(int count);

  /// No description provided for @smsSettingsSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get smsSettingsSchedule;

  /// No description provided for @smsSettingsScheduleSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отправлять только в указанное время'**
  String get smsSettingsScheduleSubtitle;

  /// No description provided for @smsSettingsAlarmsOutsideSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Тревоги вне расписания'**
  String get smsSettingsAlarmsOutsideSchedule;

  /// No description provided for @smsSettingsStartTime.
  ///
  /// In ru, this message translates to:
  /// **'Время начала'**
  String get smsSettingsStartTime;

  /// No description provided for @smsSettingsEndTime.
  ///
  /// In ru, this message translates to:
  /// **'Время окончания'**
  String get smsSettingsEndTime;

  /// No description provided for @smsSettingsDaysOfWeek.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели:'**
  String get smsSettingsDaysOfWeek;

  /// No description provided for @smsSettingsMonday.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get smsSettingsMonday;

  /// No description provided for @smsSettingsTuesday.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get smsSettingsTuesday;

  /// No description provided for @smsSettingsWednesday.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get smsSettingsWednesday;

  /// No description provided for @smsSettingsThursday.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get smsSettingsThursday;

  /// No description provided for @smsSettingsFriday.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get smsSettingsFriday;

  /// No description provided for @smsSettingsSaturday.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get smsSettingsSaturday;

  /// No description provided for @smsSettingsSunday.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get smsSettingsSunday;

  /// No description provided for @smsSettingsAddPhoneRequired.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы один номер'**
  String get smsSettingsAddPhoneRequired;

  /// No description provided for @smsSettingsSendTest.
  ///
  /// In ru, this message translates to:
  /// **'Отправить тестовое SMS'**
  String get smsSettingsSendTest;

  /// No description provided for @smsSettingsTestMessage.
  ///
  /// In ru, this message translates to:
  /// **'✅ Тестовое SMS из SHome!'**
  String get smsSettingsTestMessage;

  /// No description provided for @smsSettingsAddPhoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить номер'**
  String get smsSettingsAddPhoneTitle;

  /// No description provided for @smsSettingsNameOptional.
  ///
  /// In ru, this message translates to:
  /// **'Имя (необязательно)'**
  String get smsSettingsNameOptional;

  /// No description provided for @smsSettingsNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Мой телефон'**
  String get smsSettingsNameHint;

  /// No description provided for @smsSettingsPhoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер'**
  String get smsSettingsPhoneLabel;

  /// No description provided for @smsSettingsPhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'+79991234567'**
  String get smsSettingsPhoneHint;

  /// No description provided for @smsSettingsCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get smsSettingsCancel;

  /// No description provided for @smsSettingsAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get smsSettingsAdd;

  /// No description provided for @smsSettingsDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get smsSettingsDelete;

  /// No description provided for @timersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Таймеры'**
  String get timersTitle;

  /// No description provided for @timersEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет активных таймеров'**
  String get timersEmpty;

  /// No description provided for @timersAlreadyFired.
  ///
  /// In ru, this message translates to:
  /// **'Уже сработал'**
  String get timersAlreadyFired;

  /// No description provided for @timersLessThanMinute.
  ///
  /// In ru, this message translates to:
  /// **'менее минуты'**
  String get timersLessThanMinute;

  /// No description provided for @timersTurnOn.
  ///
  /// In ru, this message translates to:
  /// **'Включится'**
  String get timersTurnOn;

  /// No description provided for @timersTurnOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключится'**
  String get timersTurnOff;

  /// No description provided for @timersCountdownMinutes.
  ///
  /// In ru, this message translates to:
  /// **'через {minutes} мин'**
  String timersCountdownMinutes(int minutes);

  /// No description provided for @timersCountdownHoursMinutes.
  ///
  /// In ru, this message translates to:
  /// **'через {hours} ч {minutes} мин'**
  String timersCountdownHoursMinutes(int hours, int minutes);

  /// No description provided for @timersTodayAt.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня в {time}'**
  String timersTodayAt(String time);

  /// No description provided for @timersNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый таймер'**
  String get timersNewTitle;

  /// No description provided for @timersDeviceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Устройство'**
  String get timersDeviceLabel;

  /// No description provided for @timersCommandOff.
  ///
  /// In ru, this message translates to:
  /// **'ВЫКЛ'**
  String get timersCommandOff;

  /// No description provided for @timersCommandOn.
  ///
  /// In ru, this message translates to:
  /// **'ВКЛ'**
  String get timersCommandOn;

  /// No description provided for @timersCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get timersCancel;

  /// No description provided for @timersCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get timersCreate;

  /// No description provided for @timersDeleteTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Удалить таймер'**
  String get timersDeleteTooltip;

  /// No description provided for @vkSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'VK Bot'**
  String get vkSettingsTitle;

  /// No description provided for @vkSettingsEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить VK'**
  String get vkSettingsEnable;

  /// No description provided for @vkSettingsEnableSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отправлять уведомления в VK'**
  String get vkSettingsEnableSubtitle;

  /// No description provided for @vkSettingsTokenLabel.
  ///
  /// In ru, this message translates to:
  /// **'VK Token'**
  String get vkSettingsTokenLabel;

  /// No description provided for @vkSettingsTokenHint.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте токен бота'**
  String get vkSettingsTokenHint;

  /// No description provided for @vkSettingsUserIdLabel.
  ///
  /// In ru, this message translates to:
  /// **'VK User ID'**
  String get vkSettingsUserIdLabel;

  /// No description provided for @vkSettingsUserIdHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, 123456789'**
  String get vkSettingsUserIdHint;

  /// No description provided for @vkSettingsEvents.
  ///
  /// In ru, this message translates to:
  /// **'События'**
  String get vkSettingsEvents;

  /// No description provided for @vkSettingsScenes.
  ///
  /// In ru, this message translates to:
  /// **'Сцены'**
  String get vkSettingsScenes;

  /// No description provided for @vkSettingsScenesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления о выполнении сцен'**
  String get vkSettingsScenesSubtitle;

  /// No description provided for @vkSettingsDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства'**
  String get vkSettingsDevices;

  /// No description provided for @vkSettingsDevicesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменение состояния устройств'**
  String get vkSettingsDevicesSubtitle;

  /// No description provided for @vkSettingsAlarms.
  ///
  /// In ru, this message translates to:
  /// **'Тревоги'**
  String get vkSettingsAlarms;

  /// No description provided for @vkSettingsZigbeeWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 💧 Протечка'**
  String get vkSettingsZigbeeWaterLeak;

  /// No description provided for @vkSettingsZigbeeSmoke.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 🔥 Дым'**
  String get vkSettingsZigbeeSmoke;

  /// No description provided for @vkSettingsZigbeeGas.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 💨 Газ'**
  String get vkSettingsZigbeeGas;

  /// No description provided for @vkSettingsZigbeeMotion.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 🏃 Движение'**
  String get vkSettingsZigbeeMotion;

  /// No description provided for @vkSettingsZigbeeContact.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee: 🚪 Контакт'**
  String get vkSettingsZigbeeContact;

  /// No description provided for @vkSettingsFrigatePerson.
  ///
  /// In ru, this message translates to:
  /// **'Frigate: 🚶 Человек'**
  String get vkSettingsFrigatePerson;

  /// No description provided for @vkSettingsFrigateCar.
  ///
  /// In ru, this message translates to:
  /// **'Frigate: 🚗 Автомобиль'**
  String get vkSettingsFrigateCar;

  /// No description provided for @vkSettingsErrors.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки'**
  String get vkSettingsErrors;

  /// No description provided for @vkSettingsZigbeeOffline.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee offline'**
  String get vkSettingsZigbeeOffline;

  /// No description provided for @vkSettingsZigbeeOfflineSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Устройство потеряло связь'**
  String get vkSettingsZigbeeOfflineSubtitle;

  /// No description provided for @vkSettingsFrigateOffline.
  ///
  /// In ru, this message translates to:
  /// **'Frigate offline'**
  String get vkSettingsFrigateOffline;

  /// No description provided for @vkSettingsFrigateOfflineSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Frigate недоступен'**
  String get vkSettingsFrigateOfflineSubtitle;

  /// No description provided for @vkSettingsCooldown.
  ///
  /// In ru, this message translates to:
  /// **'Антидребезг VK'**
  String get vkSettingsCooldown;

  /// No description provided for @vkSettingsCooldown1.
  ///
  /// In ru, this message translates to:
  /// **'1 минута'**
  String get vkSettingsCooldown1;

  /// No description provided for @vkSettingsCooldown5.
  ///
  /// In ru, this message translates to:
  /// **'5 минут'**
  String get vkSettingsCooldown5;

  /// No description provided for @vkSettingsCooldown15.
  ///
  /// In ru, this message translates to:
  /// **'15 минут'**
  String get vkSettingsCooldown15;

  /// No description provided for @vkSettingsCooldown30.
  ///
  /// In ru, this message translates to:
  /// **'30 минут'**
  String get vkSettingsCooldown30;

  /// No description provided for @vkSettingsSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get vkSettingsSchedule;

  /// No description provided for @vkSettingsScheduleSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Отправлять только в указанное время'**
  String get vkSettingsScheduleSubtitle;

  /// No description provided for @vkSettingsAlarmsOutsideSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Тревоги вне расписания'**
  String get vkSettingsAlarmsOutsideSchedule;

  /// No description provided for @vkSettingsAlarmsAlways.
  ///
  /// In ru, this message translates to:
  /// **'Тревоги отправлять всегда'**
  String get vkSettingsAlarmsAlways;

  /// No description provided for @vkSettingsStartTime.
  ///
  /// In ru, this message translates to:
  /// **'Время начала'**
  String get vkSettingsStartTime;

  /// No description provided for @vkSettingsEndTime.
  ///
  /// In ru, this message translates to:
  /// **'Время окончания'**
  String get vkSettingsEndTime;

  /// No description provided for @vkSettingsDaysOfWeek.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели:'**
  String get vkSettingsDaysOfWeek;

  /// No description provided for @vkSettingsMonday.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get vkSettingsMonday;

  /// No description provided for @vkSettingsTuesday.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get vkSettingsTuesday;

  /// No description provided for @vkSettingsWednesday.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get vkSettingsWednesday;

  /// No description provided for @vkSettingsThursday.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get vkSettingsThursday;

  /// No description provided for @vkSettingsFriday.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get vkSettingsFriday;

  /// No description provided for @vkSettingsSaturday.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get vkSettingsSaturday;

  /// No description provided for @vkSettingsSunday.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get vkSettingsSunday;

  /// No description provided for @vkSettingsSendTest.
  ///
  /// In ru, this message translates to:
  /// **'Отправить тест VK'**
  String get vkSettingsSendTest;

  /// No description provided for @vkSettingsTestMessage.
  ///
  /// In ru, this message translates to:
  /// **'✅ Тестовое уведомление из SHome!'**
  String get vkSettingsTestMessage;

  /// No description provided for @zigbeeScanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee'**
  String get zigbeeScanTitle;

  /// No description provided for @zigbeeRefresh.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get zigbeeRefresh;

  /// No description provided for @zigbeeStopPairing.
  ///
  /// In ru, this message translates to:
  /// **'Остановить сопряжение ({seconds} с)'**
  String zigbeeStopPairing(int seconds);

  /// No description provided for @zigbeeOpenPairing.
  ///
  /// In ru, this message translates to:
  /// **'Открыть сеть для сопряжения'**
  String get zigbeeOpenPairing;

  /// No description provided for @zigbeePairingInstruction.
  ///
  /// In ru, this message translates to:
  /// **'Зажмите кнопку на устройстве на 5 секунд'**
  String get zigbeePairingInstruction;

  /// No description provided for @zigbeeNoDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства не найдены.\nНажмите «Открыть сеть» и добавьте устройство.'**
  String get zigbeeNoDevices;

  /// No description provided for @zigbeeDeviceAdded.
  ///
  /// In ru, this message translates to:
  /// **'✅ {name} добавлено'**
  String zigbeeDeviceAdded(String name);

  /// No description provided for @changelogTitle.
  ///
  /// In ru, this message translates to:
  /// **'История изменений'**
  String get changelogTitle;

  /// No description provided for @changelogLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить историю изменений'**
  String get changelogLoadError;

  /// No description provided for @eulaTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лицензионное соглашение'**
  String get eulaTitle;

  /// No description provided for @legalInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get legalInfoTitle;

  /// No description provided for @legalDeveloperLabel.
  ///
  /// In ru, this message translates to:
  /// **'Разработчик: {name}'**
  String legalDeveloperLabel(String name);

  /// No description provided for @legalOwnerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Собственник: {name}'**
  String legalOwnerLabel(String name);

  /// No description provided for @legalVersionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Версия: {version}'**
  String legalVersionLabel(String version);

  /// No description provided for @legalEulaTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лицензионное соглашение (EULA)'**
  String get legalEulaTitle;

  /// No description provided for @legalEulaSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Правила использования приложения'**
  String get legalEulaSubtitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get legalPrivacyTitle;

  /// No description provided for @legalPrivacySubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Как мы обрабатываем ваши данные'**
  String get legalPrivacySubtitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get legalTermsTitle;

  /// No description provided for @legalTermsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Правила и ограничения'**
  String get legalTermsSubtitle;

  /// No description provided for @legalOpenSourceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лицензии открытого ПО'**
  String get legalOpenSourceTitle;

  /// No description provided for @legalOpenSourceSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сторонние библиотеки'**
  String get legalOpenSourceSubtitle;

  /// No description provided for @legalChangelogTitle.
  ///
  /// In ru, this message translates to:
  /// **'История изменений'**
  String get legalChangelogTitle;

  /// No description provided for @legalChangelogSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Что нового в каждой версии'**
  String get legalChangelogSubtitle;

  /// No description provided for @legalVersionFooter.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String legalVersionFooter(String version);

  /// No description provided for @statsPeriod24h.
  ///
  /// In ru, this message translates to:
  /// **'24ч'**
  String get statsPeriod24h;

  /// No description provided for @statsPeriod7d.
  ///
  /// In ru, this message translates to:
  /// **'7д'**
  String get statsPeriod7d;

  /// No description provided for @statsPeriod30d.
  ///
  /// In ru, this message translates to:
  /// **'30д'**
  String get statsPeriod30d;

  /// No description provided for @statsNoClimateData.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных датчиков за период'**
  String get statsNoClimateData;

  /// No description provided for @statsClimateByDevice.
  ///
  /// In ru, this message translates to:
  /// **'Климат по устройствам'**
  String get statsClimateByDevice;

  /// No description provided for @statsSampleCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет измерений} one{{count} измерение} few{{count} измерения} many{{count} измерений} other{{count} измерения}}'**
  String statsSampleCount(int count);

  /// No description provided for @statsTemperatureSummary.
  ///
  /// In ru, this message translates to:
  /// **'🌡️ {min}° … {max}° (среднее: {average}°)'**
  String statsTemperatureSummary(String min, String max, String average);

  /// No description provided for @statsHumiditySummary.
  ///
  /// In ru, this message translates to:
  /// **'💧 {min}% … {max}% (среднее: {average}%)'**
  String statsHumiditySummary(String min, String max, String average);

  /// No description provided for @statsNoDeviceDataPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных за период'**
  String get statsNoDeviceDataPeriod;

  /// No description provided for @statsDeviceEventCounts.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети: {offline} · алерты: {alerts} · действия: {actions}'**
  String statsDeviceEventCounts(int offline, int alerts, int actions);

  /// No description provided for @statsAlertsForDays.
  ///
  /// In ru, this message translates to:
  /// **'Алерты за {days} дн.'**
  String statsAlertsForDays(int days);

  /// No description provided for @statsOfflineForDays.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети за {days} дн.'**
  String statsOfflineForDays(int days);

  /// No description provided for @statsEnergyConsumption.
  ///
  /// In ru, this message translates to:
  /// **'Потребление'**
  String get statsEnergyConsumption;

  /// No description provided for @statsEnergyCost.
  ///
  /// In ru, this message translates to:
  /// **'Стоимость'**
  String get statsEnergyCost;

  /// No description provided for @statsEnergyPeriod.
  ///
  /// In ru, this message translates to:
  /// **'за {days} дн.'**
  String statsEnergyPeriod(int days);

  /// No description provided for @statsEnergyTariff.
  ///
  /// In ru, this message translates to:
  /// **'тариф {tariff} ₽/кВт·ч'**
  String statsEnergyTariff(String tariff);

  /// No description provided for @statsEnergyRubles.
  ///
  /// In ru, this message translates to:
  /// **'{value} ₽'**
  String statsEnergyRubles(String value);

  /// No description provided for @statsEnergyKwh.
  ///
  /// In ru, this message translates to:
  /// **'{value} кВт·ч'**
  String statsEnergyKwh(String value);

  /// No description provided for @statsEnergyNoData.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных энергопотребления за период'**
  String get statsEnergyNoData;

  /// No description provided for @statsEnergyByDevice.
  ///
  /// In ru, this message translates to:
  /// **'По устройствам'**
  String get statsEnergyByDevice;

  /// No description provided for @statsNotificationsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет уведомлений за период'**
  String get statsNotificationsEmpty;

  /// No description provided for @statsNotificationsSent.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено'**
  String get statsNotificationsSent;

  /// No description provided for @statsNotificationsSuppressed.
  ///
  /// In ru, this message translates to:
  /// **'Подавлено'**
  String get statsNotificationsSuppressed;

  /// No description provided for @statsNotificationsPeriod.
  ///
  /// In ru, this message translates to:
  /// **'за {days} дн.'**
  String statsNotificationsPeriod(int days);

  /// No description provided for @statsNotificationsCooldownPercent.
  ///
  /// In ru, this message translates to:
  /// **'cooldown ({percent}%)'**
  String statsNotificationsCooldownPercent(int percent);

  /// No description provided for @statsNotificationsByChannel.
  ///
  /// In ru, this message translates to:
  /// **'По каналам'**
  String get statsNotificationsByChannel;

  /// No description provided for @statsNotificationsChannelSuppressed.
  ///
  /// In ru, this message translates to:
  /// **'Подавлено: {count}'**
  String statsNotificationsChannelSuppressed(int count);

  /// No description provided for @statsNotificationsByCategory.
  ///
  /// In ru, this message translates to:
  /// **'По категориям'**
  String get statsNotificationsByCategory;

  /// No description provided for @statsNotificationsCategoryWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'💧 Протечка'**
  String get statsNotificationsCategoryWaterLeak;

  /// No description provided for @statsNotificationsCategorySmoke.
  ///
  /// In ru, this message translates to:
  /// **'🔥 Дым'**
  String get statsNotificationsCategorySmoke;

  /// No description provided for @statsNotificationsCategoryGas.
  ///
  /// In ru, this message translates to:
  /// **'💨 Газ'**
  String get statsNotificationsCategoryGas;

  /// No description provided for @statsNotificationsCategoryMotion.
  ///
  /// In ru, this message translates to:
  /// **'🏃 Движение'**
  String get statsNotificationsCategoryMotion;

  /// No description provided for @statsNotificationsCategoryContact.
  ///
  /// In ru, this message translates to:
  /// **'🚪 Контакт'**
  String get statsNotificationsCategoryContact;

  /// No description provided for @statsNotificationsCategoryPerson.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Человек'**
  String get statsNotificationsCategoryPerson;

  /// No description provided for @statsNotificationsCategoryCar.
  ///
  /// In ru, this message translates to:
  /// **'🎥 Автомобиль'**
  String get statsNotificationsCategoryCar;

  /// No description provided for @statsNotificationsCategoryOffline.
  ///
  /// In ru, this message translates to:
  /// **'📡 Не в сети'**
  String get statsNotificationsCategoryOffline;

  /// No description provided for @statsNotificationsCategoryLowBattery.
  ///
  /// In ru, this message translates to:
  /// **'🔋 Батарея'**
  String get statsNotificationsCategoryLowBattery;

  /// No description provided for @statsNotificationsCategoryStateChanged.
  ///
  /// In ru, this message translates to:
  /// **'🎛 Состояние'**
  String get statsNotificationsCategoryStateChanged;

  /// No description provided for @statsNotificationsCategoryUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get statsNotificationsCategoryUnknown;

  /// No description provided for @statsOverviewAlerts.
  ///
  /// In ru, this message translates to:
  /// **'Алерты'**
  String get statsOverviewAlerts;

  /// No description provided for @statsOverviewActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get statsOverviewActions;

  /// No description provided for @statsOverviewOffline.
  ///
  /// In ru, this message translates to:
  /// **'Не в сети'**
  String get statsOverviewOffline;

  /// No description provided for @statsOverviewOnline.
  ///
  /// In ru, this message translates to:
  /// **'В сети'**
  String get statsOverviewOnline;

  /// No description provided for @statsOverviewPeriod.
  ///
  /// In ru, this message translates to:
  /// **'за {days} дн.'**
  String statsOverviewPeriod(int days);

  /// No description provided for @statsOverviewWorstDevices.
  ///
  /// In ru, this message translates to:
  /// **'Проблемные устройства'**
  String get statsOverviewWorstDevices;

  /// No description provided for @statsOverviewNoProblems.
  ///
  /// In ru, this message translates to:
  /// **'Нет проблемных устройств за период 👍'**
  String get statsOverviewNoProblems;

  /// No description provided for @statsPresenceEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет данных присутствия за период'**
  String get statsPresenceEmpty;

  /// No description provided for @statsPresenceHome.
  ///
  /// In ru, this message translates to:
  /// **'Дома'**
  String get statsPresenceHome;

  /// No description provided for @statsPresenceNear.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get statsPresenceNear;

  /// No description provided for @statsPresenceAway.
  ///
  /// In ru, this message translates to:
  /// **'Ушёл'**
  String get statsPresenceAway;

  /// No description provided for @statsPresenceUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get statsPresenceUnknown;

  /// No description provided for @statsPresencePeriod.
  ///
  /// In ru, this message translates to:
  /// **'за {days} дн.'**
  String statsPresencePeriod(int days);

  /// No description provided for @statsPresenceCloudFallback.
  ///
  /// In ru, this message translates to:
  /// **'Переход на облако'**
  String get statsPresenceCloudFallback;

  /// No description provided for @statsPresenceCloudFallbackSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько раз heartbeat не сработал'**
  String get statsPresenceCloudFallbackSubtitle;

  /// No description provided for @statsPresenceDurationZero.
  ///
  /// In ru, this message translates to:
  /// **'0'**
  String get statsPresenceDurationZero;

  /// No description provided for @statsPresenceDurationHoursMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч {minutes} мин'**
  String statsPresenceDurationHoursMinutes(int hours, int minutes);

  /// No description provided for @statsPresenceDurationMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String statsPresenceDurationMinutes(int minutes);

  /// No description provided for @statsPresenceDurationLessMinute.
  ///
  /// In ru, this message translates to:
  /// **'менее минуты'**
  String get statsPresenceDurationLessMinute;

  /// No description provided for @statsScenesTop.
  ///
  /// In ru, this message translates to:
  /// **'Топ сцен'**
  String get statsScenesTop;

  /// No description provided for @statsScenesRuns.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет запусков} one{# раз} few{# раза} many{# раз} other{# раза}}'**
  String statsScenesRuns(int count);

  /// No description provided for @statsScenesNoRunsPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Нет срабатываний сцен за период'**
  String get statsScenesNoRunsPeriod;

  /// No description provided for @statsScenesForgottenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Забытые сцены (0 срабатываний)'**
  String get statsScenesForgottenTitle;

  /// No description provided for @statsScenesDeleteCandidate.
  ///
  /// In ru, this message translates to:
  /// **'Кандидат на удаление'**
  String get statsScenesDeleteCandidate;

  /// No description provided for @statsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статистика'**
  String get statsTitle;

  /// No description provided for @statsTabOverview.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get statsTabOverview;

  /// No description provided for @statsTabDevices.
  ///
  /// In ru, this message translates to:
  /// **'Устройства'**
  String get statsTabDevices;

  /// No description provided for @statsTabEnergy.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get statsTabEnergy;

  /// No description provided for @statsTabVideo.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get statsTabVideo;

  /// No description provided for @statsTabScenes.
  ///
  /// In ru, this message translates to:
  /// **'Сцены'**
  String get statsTabScenes;

  /// No description provided for @statsTabPresence.
  ///
  /// In ru, this message translates to:
  /// **'Присутствие'**
  String get statsTabPresence;

  /// No description provided for @statsTabClimate.
  ///
  /// In ru, this message translates to:
  /// **'Климат'**
  String get statsTabClimate;

  /// No description provided for @statsTabNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get statsTabNotifications;

  /// No description provided for @statsVideoEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет детекций за период'**
  String get statsVideoEmpty;

  /// No description provided for @statsVideoByTypes.
  ///
  /// In ru, this message translates to:
  /// **'По типам'**
  String get statsVideoByTypes;

  /// No description provided for @statsVideoByCameras.
  ///
  /// In ru, this message translates to:
  /// **'По камерам'**
  String get statsVideoByCameras;

  /// No description provided for @statsVideoActivityByHour.
  ///
  /// In ru, this message translates to:
  /// **'Активность по часам'**
  String get statsVideoActivityByHour;

  /// No description provided for @statsVideoHeatmapHint.
  ///
  /// In ru, this message translates to:
  /// **'Чем интенсивнее цвет — тем больше детекций'**
  String get statsVideoHeatmapHint;

  /// No description provided for @statsVideoLabelPerson.
  ///
  /// In ru, this message translates to:
  /// **'Человек'**
  String get statsVideoLabelPerson;

  /// No description provided for @statsVideoLabelCar.
  ///
  /// In ru, this message translates to:
  /// **'Автомобиль'**
  String get statsVideoLabelCar;

  /// No description provided for @statsVideoLabelDog.
  ///
  /// In ru, this message translates to:
  /// **'Собака'**
  String get statsVideoLabelDog;

  /// No description provided for @statsVideoLabelCat.
  ///
  /// In ru, this message translates to:
  /// **'Кошка'**
  String get statsVideoLabelCat;

  /// No description provided for @statsVideoLabelBird.
  ///
  /// In ru, this message translates to:
  /// **'Птица'**
  String get statsVideoLabelBird;

  /// No description provided for @statsVideoLabelMotorcycle.
  ///
  /// In ru, this message translates to:
  /// **'Мотоцикл'**
  String get statsVideoLabelMotorcycle;

  /// No description provided for @statsVideoLabelBicycle.
  ///
  /// In ru, this message translates to:
  /// **'Велосипед'**
  String get statsVideoLabelBicycle;

  /// No description provided for @statsVideoLabelTruck.
  ///
  /// In ru, this message translates to:
  /// **'Грузовик'**
  String get statsVideoLabelTruck;

  /// No description provided for @statsVideoLabelBus.
  ///
  /// In ru, this message translates to:
  /// **'Автобус'**
  String get statsVideoLabelBus;

  /// No description provided for @statsVideoLabelBoat.
  ///
  /// In ru, this message translates to:
  /// **'Лодка'**
  String get statsVideoLabelBoat;

  /// No description provided for @deviceCardWaterLeak.
  ///
  /// In ru, this message translates to:
  /// **'Протечка'**
  String get deviceCardWaterLeak;

  /// No description provided for @deviceCardMotion.
  ///
  /// In ru, this message translates to:
  /// **'Движение'**
  String get deviceCardMotion;

  /// No description provided for @deviceCardContactOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыто'**
  String get deviceCardContactOpen;

  /// No description provided for @deviceSettingsName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get deviceSettingsName;

  /// No description provided for @deviceSettingsRoom.
  ///
  /// In ru, this message translates to:
  /// **'Комната'**
  String get deviceSettingsRoom;

  /// No description provided for @deviceSettingsRtspUrl.
  ///
  /// In ru, this message translates to:
  /// **'RTSP URL'**
  String get deviceSettingsRtspUrl;

  /// No description provided for @deviceSettingsZigbeeDevice.
  ///
  /// In ru, this message translates to:
  /// **'Zigbee-устройство'**
  String get deviceSettingsZigbeeDevice;

  /// No description provided for @deviceSettingsIeeeAddress.
  ///
  /// In ru, this message translates to:
  /// **'IEEE-адрес'**
  String get deviceSettingsIeeeAddress;

  /// No description provided for @deviceSettingsModel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get deviceSettingsModel;

  /// No description provided for @deviceSettingsVendor.
  ///
  /// In ru, this message translates to:
  /// **'Производитель'**
  String get deviceSettingsVendor;

  /// No description provided for @deviceSettingsBattery.
  ///
  /// In ru, this message translates to:
  /// **'Батарея'**
  String get deviceSettingsBattery;

  /// No description provided for @deviceSettingsLinkQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество связи'**
  String get deviceSettingsLinkQuality;

  /// No description provided for @deviceSettingsNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get deviceSettingsNotifications;

  /// No description provided for @deviceSettingsDeviceId.
  ///
  /// In ru, this message translates to:
  /// **'Device ID'**
  String get deviceSettingsDeviceId;

  /// No description provided for @deviceSettingsIpAddress.
  ///
  /// In ru, this message translates to:
  /// **'IP-адрес'**
  String get deviceSettingsIpAddress;

  /// No description provided for @deviceSettingsLocalKey.
  ///
  /// In ru, this message translates to:
  /// **'Local Key'**
  String get deviceSettingsLocalKey;

  /// No description provided for @deviceSettingsProtocolVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия протокола'**
  String get deviceSettingsProtocolVersion;

  /// No description provided for @deviceSettingsChannels.
  ///
  /// In ru, this message translates to:
  /// **'Каналы'**
  String get deviceSettingsChannels;

  /// No description provided for @deviceSettingsDpsIndex.
  ///
  /// In ru, this message translates to:
  /// **'Индекс DPS'**
  String get deviceSettingsDpsIndex;

  /// No description provided for @deviceSettingsDpsMap.
  ///
  /// In ru, this message translates to:
  /// **'Карта DPS'**
  String get deviceSettingsDpsMap;

  /// No description provided for @deviceSettingsAddDps.
  ///
  /// In ru, this message translates to:
  /// **'Добавить DPS'**
  String get deviceSettingsAddDps;

  /// No description provided for @deviceSettingsDisplayOnCard.
  ///
  /// In ru, this message translates to:
  /// **'Отображение на карточке'**
  String get deviceSettingsDisplayOnCard;

  /// No description provided for @deviceSettingsDisplayHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите, какие данные показывать на главном экране'**
  String get deviceSettingsDisplayHint;

  /// No description provided for @deviceSettingsNoInfoParameters.
  ///
  /// In ru, this message translates to:
  /// **'Нет информационных параметров'**
  String get deviceSettingsNoInfoParameters;

  /// No description provided for @deviceSettingsDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить устройство?'**
  String get deviceSettingsDeleteTitle;

  /// No description provided for @deviceSettingsDeleteMessage.
  ///
  /// In ru, this message translates to:
  /// **'Удалить «{name}»?'**
  String deviceSettingsDeleteMessage(String name);

  /// No description provided for @deviceSettingsDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deviceSettingsDelete;

  /// No description provided for @deviceSettingsSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get deviceSettingsSave;

  /// No description provided for @deviceSettingsCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get deviceSettingsCancel;

  /// No description provided for @deviceSettingsCreateSensor.
  ///
  /// In ru, this message translates to:
  /// **'Создать датчик'**
  String get deviceSettingsCreateSensor;

  /// No description provided for @deviceSettingsSensorFromDevice.
  ///
  /// In ru, this message translates to:
  /// **'Из устройства: {name}'**
  String deviceSettingsSensorFromDevice(String name);

  /// No description provided for @deviceSettingsSensorType.
  ///
  /// In ru, this message translates to:
  /// **'Тип датчика'**
  String get deviceSettingsSensorType;

  /// No description provided for @deviceSettingsTemperature.
  ///
  /// In ru, this message translates to:
  /// **'Температура'**
  String get deviceSettingsTemperature;

  /// No description provided for @deviceSettingsHumidity.
  ///
  /// In ru, this message translates to:
  /// **'Влажность'**
  String get deviceSettingsHumidity;

  /// No description provided for @deviceSettingsPower.
  ///
  /// In ru, this message translates to:
  /// **'Мощность'**
  String get deviceSettingsPower;

  /// No description provided for @deviceSettingsCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Ток'**
  String get deviceSettingsCurrent;

  /// No description provided for @deviceSettingsVoltage.
  ///
  /// In ru, this message translates to:
  /// **'Напряжение'**
  String get deviceSettingsVoltage;

  /// No description provided for @deviceSettingsDivider.
  ///
  /// In ru, this message translates to:
  /// **'Делитель'**
  String get deviceSettingsDivider;

  /// No description provided for @deviceSettingsSensorCreated.
  ///
  /// In ru, this message translates to:
  /// **'✅ Датчик «{name}» создан!'**
  String deviceSettingsSensorCreated(String name);

  /// No description provided for @deviceSettingsChannel.
  ///
  /// In ru, this message translates to:
  /// **'Канал'**
  String get deviceSettingsChannel;

  /// No description provided for @deviceSettingsChannelNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер канала'**
  String get deviceSettingsChannelNumber;

  /// No description provided for @deviceSettingsDpsAddTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить DPS'**
  String get deviceSettingsDpsAddTitle;

  /// No description provided for @deviceSettingsDpsEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать DPS {key}'**
  String deviceSettingsDpsEditTitle(String key);

  /// No description provided for @deviceSettingsDpsNumber.
  ///
  /// In ru, this message translates to:
  /// **'Номер DPS'**
  String get deviceSettingsDpsNumber;

  /// No description provided for @deviceSettingsDpsType.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get deviceSettingsDpsType;

  /// No description provided for @deviceSettingsDpsRole.
  ///
  /// In ru, this message translates to:
  /// **'Роль'**
  String get deviceSettingsDpsRole;

  /// No description provided for @deviceSettingsDpsIcon.
  ///
  /// In ru, this message translates to:
  /// **'Иконка'**
  String get deviceSettingsDpsIcon;

  /// No description provided for @deviceSettingsNoIcon.
  ///
  /// In ru, this message translates to:
  /// **'Без иконки'**
  String get deviceSettingsNoIcon;

  /// No description provided for @deviceSettingsRoleChannel.
  ///
  /// In ru, this message translates to:
  /// **'Канал'**
  String get deviceSettingsRoleChannel;

  /// No description provided for @deviceSettingsRoleMain.
  ///
  /// In ru, this message translates to:
  /// **'Главная кнопка'**
  String get deviceSettingsRoleMain;

  /// No description provided for @deviceSettingsRoleAction.
  ///
  /// In ru, this message translates to:
  /// **'Действие'**
  String get deviceSettingsRoleAction;

  /// No description provided for @deviceSettingsRoleToggle.
  ///
  /// In ru, this message translates to:
  /// **'Переключатель'**
  String get deviceSettingsRoleToggle;

  /// No description provided for @deviceSettingsRoleInfo.
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get deviceSettingsRoleInfo;

  /// No description provided for @deviceSettingsRoleStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get deviceSettingsRoleStatus;

  /// No description provided for @deviceSettingsRoleEnum.
  ///
  /// In ru, this message translates to:
  /// **'Выпадающий список'**
  String get deviceSettingsRoleEnum;

  /// No description provided for @deviceSettingsRoleSlider.
  ///
  /// In ru, this message translates to:
  /// **'Ползунок'**
  String get deviceSettingsRoleSlider;

  /// No description provided for @deviceSettingsDpsChannelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Канал'**
  String get deviceSettingsDpsChannelTitle;

  /// No description provided for @deviceSettingsNotifyAlways.
  ///
  /// In ru, this message translates to:
  /// **'Всегда'**
  String get deviceSettingsNotifyAlways;

  /// No description provided for @deviceSettingsNotifyAway.
  ///
  /// In ru, this message translates to:
  /// **'Когда никого нет'**
  String get deviceSettingsNotifyAway;

  /// No description provided for @deviceSettingsNotifyNight.
  ///
  /// In ru, this message translates to:
  /// **'Ночью'**
  String get deviceSettingsNotifyNight;

  /// No description provided for @deviceSettingsNotifyAwayOrNight.
  ///
  /// In ru, this message translates to:
  /// **'Никого нет ИЛИ ночью'**
  String get deviceSettingsNotifyAwayOrNight;

  /// No description provided for @deviceSettingsNotifySummary.
  ///
  /// In ru, this message translates to:
  /// **'{count} типов · {condition}'**
  String deviceSettingsNotifySummary(int count, String condition);

  /// No description provided for @deviceSettingsTypeBool.
  ///
  /// In ru, this message translates to:
  /// **'вкл/выкл'**
  String get deviceSettingsTypeBool;

  /// No description provided for @deviceSettingsTypeValue.
  ///
  /// In ru, this message translates to:
  /// **'число'**
  String get deviceSettingsTypeValue;

  /// No description provided for @deviceSettingsTypeEnum.
  ///
  /// In ru, this message translates to:
  /// **'текстовый список'**
  String get deviceSettingsTypeEnum;

  /// No description provided for @deviceSettingsTypeSlider.
  ///
  /// In ru, this message translates to:
  /// **'ползунок'**
  String get deviceSettingsTypeSlider;

  /// No description provided for @deviceSettingsIconNone.
  ///
  /// In ru, this message translates to:
  /// **'Без иконки'**
  String get deviceSettingsIconNone;

  /// No description provided for @deviceSettingsIconPlayStop.
  ///
  /// In ru, this message translates to:
  /// **'Пуск/Стоп'**
  String get deviceSettingsIconPlayStop;

  /// No description provided for @deviceSettingsIconHomeBase.
  ///
  /// In ru, this message translates to:
  /// **'Дом/База'**
  String get deviceSettingsIconHomeBase;

  /// No description provided for @deviceSettingsIconPower.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get deviceSettingsIconPower;

  /// No description provided for @deviceSettingsIconWater.
  ///
  /// In ru, this message translates to:
  /// **'Вода'**
  String get deviceSettingsIconWater;

  /// No description provided for @deviceSettingsIconMop.
  ///
  /// In ru, this message translates to:
  /// **'Мытьё'**
  String get deviceSettingsIconMop;

  /// No description provided for @deviceSettingsIconDoNotDisturb.
  ///
  /// In ru, this message translates to:
  /// **'Не беспокоить'**
  String get deviceSettingsIconDoNotDisturb;

  /// No description provided for @deviceSettingsIconBattery.
  ///
  /// In ru, this message translates to:
  /// **'Батарея'**
  String get deviceSettingsIconBattery;

  /// No description provided for @deviceSettingsIconTimer.
  ///
  /// In ru, this message translates to:
  /// **'Таймер'**
  String get deviceSettingsIconTimer;

  /// No description provided for @deviceSettingsIconArea.
  ///
  /// In ru, this message translates to:
  /// **'Площадь'**
  String get deviceSettingsIconArea;

  /// No description provided for @deviceSettingsIconFan.
  ///
  /// In ru, this message translates to:
  /// **'Вентилятор'**
  String get deviceSettingsIconFan;

  /// No description provided for @deviceSettingsIconCooling.
  ///
  /// In ru, this message translates to:
  /// **'Охлаждение'**
  String get deviceSettingsIconCooling;

  /// No description provided for @deviceSettingsIconHeating.
  ///
  /// In ru, this message translates to:
  /// **'Обогрев'**
  String get deviceSettingsIconHeating;

  /// No description provided for @deviceSettingsIconDrying.
  ///
  /// In ru, this message translates to:
  /// **'Осушение'**
  String get deviceSettingsIconDrying;

  /// No description provided for @deviceSettingsIconAuto.
  ///
  /// In ru, this message translates to:
  /// **'Авто'**
  String get deviceSettingsIconAuto;

  /// No description provided for @deviceSettingsIconSleep.
  ///
  /// In ru, this message translates to:
  /// **'Сон'**
  String get deviceSettingsIconSleep;

  /// No description provided for @deviceSettingsIconVerticalBlinds.
  ///
  /// In ru, this message translates to:
  /// **'Вертикальные жалюзи'**
  String get deviceSettingsIconVerticalBlinds;

  /// No description provided for @deviceSettingsIconHorizontalBlinds.
  ///
  /// In ru, this message translates to:
  /// **'Горизонтальные жалюзи'**
  String get deviceSettingsIconHorizontalBlinds;

  /// No description provided for @deviceSettingsIconAirQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество воздуха'**
  String get deviceSettingsIconAirQuality;

  /// No description provided for @deviceSettingsIconFilter.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get deviceSettingsIconFilter;

  /// No description provided for @deviceSettingsIconTemperature.
  ///
  /// In ru, this message translates to:
  /// **'Температура'**
  String get deviceSettingsIconTemperature;

  /// No description provided for @deviceSettingsIconAirConditioner.
  ///
  /// In ru, this message translates to:
  /// **'Кондиционер'**
  String get deviceSettingsIconAirConditioner;

  /// No description provided for @deviceSettingsIconHeater.
  ///
  /// In ru, this message translates to:
  /// **'Обогреватель'**
  String get deviceSettingsIconHeater;

  /// No description provided for @deviceSettingsIconAir.
  ///
  /// In ru, this message translates to:
  /// **'Воздух'**
  String get deviceSettingsIconAir;

  /// No description provided for @deviceSettingsIconSuction.
  ///
  /// In ru, this message translates to:
  /// **'Всасывание'**
  String get deviceSettingsIconSuction;

  /// No description provided for @deviceSettingsIconWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание'**
  String get deviceSettingsIconWaiting;

  /// No description provided for @deviceSettingsIconSynchronization.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get deviceSettingsIconSynchronization;

  /// No description provided for @deviceSettingsDefaultChannelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Канал {key}'**
  String deviceSettingsDefaultChannelLabel(String key);

  /// No description provided for @deviceSettingsAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get deviceSettingsAdd;

  /// No description provided for @deviceSettingsCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get deviceSettingsCreate;

  /// No description provided for @todayDrawerToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayDrawerToday;
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
