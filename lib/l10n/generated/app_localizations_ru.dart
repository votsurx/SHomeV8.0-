// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get welcomeSubtitle => 'Управляйте своим умным домом легко и просто';

  @override
  String get startButton => 'Начать';

  @override
  String get languageTitle => 'Язык приложения';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String languageSelected(String language) {
    return 'Выбран язык: $language';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get pollingInterval => 'Интервал опроса';

  @override
  String get screenSettings => 'Настройки экрана';

  @override
  String get screenSettingsSubtitle => 'Заставка и отображение';

  @override
  String get scanTuyaTitle => 'Scan Tuya';

  @override
  String get tuyaSearchTitle => 'Searching for Tuya devices';

  @override
  String get scanPortsHint =>
      'Scanning ports 6666, 6667, 6668, and 7000 on the local network';

  @override
  String scanProgress(int progress, int total) {
    return 'Checked: $progress / $total';
  }

  @override
  String foundDevices(int count) {
    return 'Found: $count';
  }

  @override
  String get deviceAddedStatus => 'Added';

  @override
  String get tapToScan => 'Tap “Scan”';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scan => 'Scan';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get addDeviceTitle => 'Add device';

  @override
  String ipAddress(String ip) {
    return 'IP: $ip';
  }

  @override
  String portNumber(int port) {
    return 'Port: $port';
  }

  @override
  String defaultDeviceName(String ip) {
    return 'Device $ip';
  }

  @override
  String get deviceName => 'Name';

  @override
  String get deviceType => 'Device type';

  @override
  String get outlet => 'Outlet';

  @override
  String get switchOne => 'Switch (1 gang)';

  @override
  String get switchTwo => 'Switch (2 gang)';

  @override
  String get switchThree => 'Switch (3 gang)';

  @override
  String get sensor => 'Sensor';

  @override
  String get light => 'Light';

  @override
  String get curtain => 'Curtain';

  @override
  String get airConditioner => 'Air conditioner';

  @override
  String get universalDevice => 'Universal device';

  @override
  String get deviceId => 'Device ID';

  @override
  String get localKey => 'Local Key';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String deviceAddedMessage(String name) {
    return '$name added!';
  }

  @override
  String get localNetworkNotFound => 'Could not determine the local network';

  @override
  String get roomsTitle => 'Комнаты';

  @override
  String get roomsCreateTitle => 'Создайте комнаты';

  @override
  String get roomsOrganizeHint => 'Организуйте устройства по комнатам';

  @override
  String get roomsAddFirst => 'Добавьте первую комнату';

  @override
  String get roomsAddButton => 'Добавить комнату';

  @override
  String get onboardingFinishButton => 'Готово!';

  @override
  String get roomAddDialogTitle => 'Добавить комнату';

  @override
  String get roomNameLabel => 'Название';

  @override
  String get roomNameHint => 'Спальня';

  @override
  String get noDevices => 'Нет устройств';

  @override
  String get forecastTitle => 'Прогноз погоды';

  @override
  String get ok => 'OK';

  @override
  String get ipAddressLabel => 'IP-адрес';

  @override
  String get menuTitle => 'Меню';

  @override
  String get menuDevices => 'Устройства';

  @override
  String get menuEnergy => 'Энергия';

  @override
  String get menuScenes => 'Сцены';

  @override
  String get menuScanTuya => 'Сканировать TUYA';

  @override
  String get menuZigbee => 'Zigbee';

  @override
  String get menuFrigate => 'Frigate';

  @override
  String get menuRooms => 'Комнаты';

  @override
  String get menuStatistics => 'Статистика';

  @override
  String get menuTimers => 'Таймеры';

  @override
  String get menuEvents => 'События';

  @override
  String get menuCloud => 'Облако';

  @override
  String get menuNotifications => 'Уведомления';

  @override
  String get menuPresence => 'Присутствие';

  @override
  String get menuSettings => 'Настройки';

  @override
  String get menuThemeSystem => 'Тема: системная';

  @override
  String get menuThemeLight => 'Тема: светлая';

  @override
  String get menuThemeDark => 'Тема: тёмная';

  @override
  String get backupKeyScanTitle => 'Сканировать ключ';

  @override
  String get switchCameraTooltip => 'Переключить камеру';

  @override
  String get flashTooltip => 'Вспышка';

  @override
  String get backupKeyScanHint => 'Наведите камеру на QR-код ключа SHome';

  @override
  String get cloudSettingsTitle => '☁️ Облачное хранилище';

  @override
  String get cloudStatusConnected => '✅ Подключено';

  @override
  String get cloudStatusDisconnected => '⚪ Не подключено';

  @override
  String get cloudStatusLabel => 'Статус';

  @override
  String cloudLoginValue(String login) {
    return 'Логин: $login';
  }

  @override
  String get cloudConnectSection => '🔗 Подключение';

  @override
  String get cloudLogin => 'Логин';

  @override
  String get cloudLoginHint => 'login@mail.ru';

  @override
  String get cloudAppPassword => 'Пароль приложения';

  @override
  String get cloudPasswordHelp =>
      '💡 Как получить пароль приложения:\n1. Mail.ru → Настройки → Безопасность\n2. Пароли для приложений → Создать\n3. Назовите «SHome» → скопируйте пароль';

  @override
  String get cloudConnecting => 'Подключение...';

  @override
  String get cloudConnect => 'Подключить';

  @override
  String get cloudEnterCredentials => 'Введите логин и пароль';

  @override
  String get cloudConnectedMessage => '✅ Подключено к облаку';

  @override
  String get cloudConnectFailed =>
      '❌ Не удалось подключиться. Проверьте логин и пароль.';

  @override
  String cloudConnectionError(String error) {
    return '❌ Ошибка подключения: $error';
  }

  @override
  String get cloudDisconnectedMessage => '🔌 Отключено от облака';

  @override
  String get cloudDisconnect => 'Отключить';

  @override
  String get cloudDisconnectSubtitle =>
      'Ключ резервного копирования останется на устройстве';

  @override
  String get cloudBackupKeyTitle => '🔐 Ключ резервного копирования';

  @override
  String get cloudKeyCreated => 'Ключ создан';

  @override
  String get cloudKeyMissing => 'Ключ не создан';

  @override
  String get cloudKeyReadySubtitle => 'AES-256-GCM готов к работе';

  @override
  String get cloudKeyMissingSubtitle => 'Создайте или импортируйте ключ';

  @override
  String get cloudGenerateNewKeyTitle => 'Сгенерировать новый ключ?';

  @override
  String get cloudGenerateNewKeyWarning =>
      'Новый ключ сделает все существующие резервные копии недоступными для восстановления.\n\nПродолжить?';

  @override
  String get cloudGenerate => 'Сгенерировать';

  @override
  String get cloudKeyCreatedMessage => '✅ Ключ резервного копирования создан';

  @override
  String cloudKeyCreateError(String error) {
    return '❌ Ошибка создания ключа: $error';
  }

  @override
  String get cloudShowQr => 'Показать QR';

  @override
  String get cloudScanQr => 'Сканировать QR';

  @override
  String get cloudQrTitle => 'QR-ключ резервного копирования';

  @override
  String get cloudQrHint =>
      'Отсканируйте этот QR-код на другом устройстве SHome.';

  @override
  String get cloudClose => 'Закрыть';

  @override
  String get cloudNoLoginData => '❌ Нет данных для входа в облако';

  @override
  String get cloudGenerateKeyFirst =>
      '❌ Сначала сгенерируйте ключ резервного копирования';

  @override
  String get cloudImportKeyFirst =>
      '❌ Сначала сгенерируйте или импортируйте ключ резервного копирования';

  @override
  String get cloudBackupUploaded => '✅ Бекап загружен в облако';

  @override
  String get cloudBackupUploadFailed => '❌ Ошибка загрузки бекапа';

  @override
  String cloudBackupUploadError(String error) {
    return '❌ Ошибка загрузки: $error';
  }

  @override
  String get cloudBackupManagementTitle => '📋 Управление бекапами';

  @override
  String get cloudUploadBackup => 'Загрузить в облако';

  @override
  String get cloudUploadBackupSubtitle => 'Сохранить текущий бекап в облако';

  @override
  String get cloudDownloadBackup => 'Скачать из облака';

  @override
  String get cloudDownloadBackupSubtitle => 'Восстановить бекап из облака';

  @override
  String get cloudNoBackups => 'ℹ️ В облаке нет бекапов';

  @override
  String get cloudChooseBackup => 'Выберите бекап';

  @override
  String get cloudBackupDownloadFailed => '❌ Ошибка скачивания бекапа';

  @override
  String cloudBackupRestoreSuccess(String backup) {
    return '✅ Бекап «$backup» восстановлен. Перезапустите приложение.';
  }

  @override
  String cloudBackupRestoreError(String error) {
    return '❌ Ошибка восстановления: $error';
  }

  @override
  String cloudLastSync(String date) {
    return 'Последняя синхронизация: $date';
  }

  @override
  String get cloudReplaceKeyTitle => 'Заменить ключ?';

  @override
  String get cloudReplaceKeyWarning =>
      'На устройстве уже есть ключ резервного копирования.\n\nПосле замены старые бекапы, созданные текущим ключом, станут недоступны.';

  @override
  String get cloudReplace => 'Заменить';

  @override
  String get cloudKeyImported => '✅ Ключ резервного копирования импортирован';

  @override
  String cloudKeyImportError(String error) {
    return '❌ Ошибка импорта ключа: $error';
  }

  @override
  String get deviceNotificationsTitle => 'Уведомления устройства';

  @override
  String get deviceNotFound => 'Устройство не найдено';

  @override
  String get notificationSettingsSaved => '✅ Настройки сохранены';

  @override
  String get save => 'Сохранить';

  @override
  String get notificationDeviceZigbee => 'Zigbee-датчик';

  @override
  String get notificationDeviceFrigate => 'Frigate-камера';

  @override
  String notificationDeviceTuya(String type) {
    return 'Tuya ($type)';
  }

  @override
  String get notificationConditionSection => '⏱ Условие отправки';

  @override
  String get notificationConditionAlways => 'Всегда';

  @override
  String get notificationConditionAway => 'Только когда никого нет дома';

  @override
  String get notificationConditionNight => 'Только ночью (22:00 – 06:00)';

  @override
  String get notificationConditionAwayOrNight => 'Никого нет дома ИЛИ ночью';

  @override
  String get notificationCooldownSection => '⏱ Антидребезг';

  @override
  String get notificationInterval => 'Интервал';

  @override
  String get notificationMinute => '1 минута';

  @override
  String get notificationMinutes5 => '5 минут';

  @override
  String get notificationMinutes15 => '15 минут';

  @override
  String get notificationMinutes30 => '30 минут';

  @override
  String get notificationTypesTitle => '🔔 Типы уведомлений';

  @override
  String get notificationFrigateLabelsTitle => '🔔 Объекты для детекции';

  @override
  String get notificationWaterLeak => 'Протечка';

  @override
  String get notificationSmoke => 'Дым';

  @override
  String get notificationGas => 'Газ';

  @override
  String get notificationMotion => 'Движение';

  @override
  String get notificationContact => 'Контакт';

  @override
  String get notificationLowBattery => 'Низкий заряд';

  @override
  String get notificationStateChanged => 'Вкл/Выкл';

  @override
  String get notificationOffline => 'Offline';

  @override
  String get notificationError => 'Ошибка';

  @override
  String get notificationTemperatureAbove => 'Температура >';

  @override
  String get notificationTemperatureBelow => 'Температура <';

  @override
  String get notificationHumidityAbove => 'Влажность >';

  @override
  String get notificationHumidityBelow => 'Влажность <';

  @override
  String get notificationPowerAbove => 'Мощность >';

  @override
  String get notificationPerson => 'Человек';

  @override
  String get notificationCar => 'Автомобиль';

  @override
  String get notificationDog => 'Собака';

  @override
  String get notificationCat => 'Кошка';

  @override
  String get notificationBird => 'Птица';

  @override
  String get notificationMotorcycle => 'Мотоцикл';

  @override
  String get notificationBicycle => 'Велосипед';

  @override
  String get notificationTruck => 'Грузовик';

  @override
  String get notificationBus => 'Автобус';

  @override
  String get notificationBoat => 'Лодка';

  @override
  String get notificationThreshold => 'Порог';

  @override
  String get notificationTemperatureThreshold => 'Порог температуры';

  @override
  String get notificationHumidityThreshold => 'Порог влажности';

  @override
  String get notificationPowerThreshold => 'Порог мощности';

  @override
  String get notificationBatteryThreshold => 'Порог заряда';

  @override
  String get notificationHowItWorks => '💡 Как это работает';

  @override
  String get notificationAlwaysExplanation =>
      'Уведомления отправляются всегда при срабатывании.';

  @override
  String notificationConditionExplanation(String condition) {
    return 'Уведомления отправляются только при выполнении условия «$condition».';
  }

  @override
  String get eventsTitle => 'События';

  @override
  String get eventsRefresh => 'Обновить';

  @override
  String get eventsClearAll => 'Очистить всё';

  @override
  String get eventsClearTitle => 'Очистить события?';

  @override
  String get eventsClearWarning => 'Все события будут удалены безвозвратно.';

  @override
  String get eventsClearCancel => 'Отмена';

  @override
  String get eventsClearConfirm => 'Очистить';

  @override
  String get eventsFilterAll => 'Все';

  @override
  String get eventsFilterAlerts => 'Алерты';

  @override
  String get eventsFilterActions => 'Действия';

  @override
  String get eventsFilterErrors => 'Ошибки';

  @override
  String get eventsDeviceFilter => 'Устройство';

  @override
  String get eventsAllDevices => 'Все устройства';

  @override
  String get eventsEmptyFilter => 'Нет событий по фильтру';

  @override
  String get eventsSystemError => 'Системная ошибка';

  @override
  String get eventsPhone => 'Телефон';

  @override
  String get eventsPresence => 'Присутствие';

  @override
  String get eventsPresenceAway => 'Ушёл';

  @override
  String get eventsPresenceHomeCloud => 'Дома (облако)';

  @override
  String get eventsPresenceHomeWifi => 'Дома (Wi-Fi)';

  @override
  String get eventsPresenceHome => 'Дома';

  @override
  String get eventsPresenceUnknown => 'Неизвестно';

  @override
  String get eventsSceneCompleted => 'Сцена выполнена';

  @override
  String get eventsTurnedOn => 'Включено';

  @override
  String get eventsTurnedOff => 'Выключено';

  @override
  String get eventsScene => 'Сцена';

  @override
  String get eventsRoomAdded => 'Комната добавлена';

  @override
  String get eventsRoomRemoved => 'Комната удалена';

  @override
  String get eventsTimer => 'Таймер';

  @override
  String get eventsDeviceAdded => 'Устройство добавлено';

  @override
  String get eventsDeviceRemoved => 'Устройство удалено';

  @override
  String get eventsSceneCreated => 'Сцена создана';

  @override
  String get eventsSceneDeleted => 'Сцена удалена';

  @override
  String get eventsOnline => 'В сети';

  @override
  String get eventsOffline => 'Не в сети';

  @override
  String get eventsError => 'Ошибка';

  @override
  String get eventsAlarmWaterLeak => '💧 Протечка';

  @override
  String get eventsAlarmSmoke => '🔥 Дым';

  @override
  String get eventsAlarmGas => '💨 Газ';

  @override
  String get eventsAlarmMotion => '🏃 Движение';

  @override
  String get eventsAlarmContactOpen => '🚪 Открыто';

  @override
  String get eventsAlarmContactClosed => '🚪 Закрыто';

  @override
  String get eventsAlarmTemperatureAbove => '🌡️ Температура >';

  @override
  String get eventsAlarmTemperatureBelow => '🌡️ Температура <';

  @override
  String get eventsAlarmHumidityAbove => '💧 Влажность >';

  @override
  String get eventsAlarmHumidityBelow => '💧 Влажность <';

  @override
  String get eventsFrigatePerson => '🎥 Человек';

  @override
  String get eventsFrigateCar => '🎥 Автомобиль';

  @override
  String get eventsFrigateDog => '🎥 Собака';

  @override
  String get eventsFrigateCat => '🎥 Кошка';

  @override
  String get eventsFrigateBird => '🎥 Птица';

  @override
  String get eventsFrigateOther => '🎥 Обнаружение';

  @override
  String get frigateSettingsTooltip => 'Настройки Frigate';

  @override
  String get frigateRefreshTooltip => 'Обновить';

  @override
  String get frigateSHomeCameras => '🎥 Камеры в SHome';

  @override
  String get frigateAvailableCameras => '📍 Доступные в Frigate';

  @override
  String get frigateNoCameras =>
      'Нет доступных камер.\nПроверьте настройки Frigate.';

  @override
  String get frigateAllCamerasAdded => '✅ Все камеры добавлены';

  @override
  String get frigateStatistics => '📊 Статистика';

  @override
  String get frigateStatCameras => 'Камеры';

  @override
  String get frigateStatDetectors => 'Детекторы';

  @override
  String get frigateStatCpu => 'CPU';

  @override
  String get frigateStatRam => 'RAM';

  @override
  String frigateRoomPrefix(String room) {
    return 'Комната: $room';
  }

  @override
  String get frigateCameraSettingsTooltip => 'Настройки';

  @override
  String get frigateRemoveFromSHomeTooltip => 'Удалить из SHome';

  @override
  String get frigateAddToSHomeTooltip => 'Добавить в SHome';

  @override
  String frigateCameraAlreadyAdded(String name) {
    return '⚠️ Камера «$name» уже добавлена';
  }

  @override
  String frigateCameraAdded(String name) {
    return '✅ Камера «$name» добавлена';
  }

  @override
  String get frigateDeleteCameraTitle => 'Удалить камеру?';

  @override
  String frigateDeleteCameraMessage(String name) {
    return 'Камера «$name» будет удалена из SHome.';
  }

  @override
  String get frigateCancel => 'Отмена';

  @override
  String get frigateDelete => 'Удалить';

  @override
  String frigateCameraRemoved(String name) {
    return '🗑️ Камера «$name» удалена';
  }

  @override
  String get frigateRoomOther => '🔌 Техника';

  @override
  String get frigateRoomLiving => '🛋️ Гостиная';

  @override
  String get frigateRoomBedroom => '🛏️ Спальня';

  @override
  String get frigateRoomKitchen => '🍳 Кухня';

  @override
  String get frigateSettingsTitle => 'Настройки Frigate';

  @override
  String get frigateConnectionSection => 'Подключение';

  @override
  String get frigateHostLabel => 'Host (IP)';

  @override
  String get frigateHostHint => '192.168.43.16';

  @override
  String get frigatePortLabel => 'Port';

  @override
  String get frigatePortHint => '5000';

  @override
  String get frigateRtspPasswordLabel => 'RTSP-пароль';

  @override
  String get frigateTestConnection => 'Проверить';

  @override
  String get frigateConnectionSuccess => 'Подключение успешно';

  @override
  String get frigateConnectionFailed => 'Не удалось подключиться';

  @override
  String get frigateSettingsSection => 'Настройки';

  @override
  String get frigateStatsIntervalLabel => 'Интервал статистики (сек)';

  @override
  String get frigateNotifyFor => 'Уведомления для:';

  @override
  String get frigateLabelPerson => 'Человек';

  @override
  String get frigateLabelCar => 'Автомобиль';

  @override
  String get frigateLabelDog => 'Собака';

  @override
  String get frigateLabelCat => 'Кошка';

  @override
  String get frigateLabelMotion => 'Движение';

  @override
  String get frigateSaving => 'Сохранение...';

  @override
  String get frigateSave => 'Сохранить';

  @override
  String get frigateSettingsSaved => '✅ Настройки сохранены';

  @override
  String get mqttSettingsTitle => 'Настройки MQTT';

  @override
  String get mqttBrokerTitle => 'Брокер MQTT';

  @override
  String get mqttUsageHint => 'Используется для Zigbee2MQTT и Frigate';

  @override
  String get mqttHostLabel => 'Адрес (IP или hostname)';

  @override
  String get mqttHostHint => '192.168.43.16';

  @override
  String get mqttPortLabel => 'Порт';

  @override
  String get mqttUsernameLabel => 'Логин (необязательно)';

  @override
  String get mqttPasswordLabel => 'Пароль (необязательно)';

  @override
  String get mqttHostRequired => 'Укажите адрес брокера';

  @override
  String get mqttConnectionFailed => 'Не удалось подключиться к брокеру';

  @override
  String mqttConnectionError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get mqttConnectionSuccess => 'Подключение успешно';

  @override
  String get mqttConnectionFailureStatus => 'Не удалось подключиться';

  @override
  String get mqttConnecting => 'Подключение...';

  @override
  String get mqttSaveAndConnect => 'Сохранить и подключиться';

  @override
  String get notificationChannelsTitle => 'Уведомления';

  @override
  String get notificationVkSubtitle => 'Уведомления в VK';

  @override
  String get notificationSmsSubtitle => 'Уведомления по SMS';

  @override
  String get presenceTitle => 'Присутствие';

  @override
  String get presenceTrackingEnable => 'Включить отслеживание';

  @override
  String get presenceTrackingSubtitle => 'Определять, кто дома';

  @override
  String get presencePhones => 'Телефоны';

  @override
  String get presenceNoPhones => 'Нет добавленных телефонов';

  @override
  String get presenceHomeZone => 'Домашняя зона';

  @override
  String get presenceNotConfigured => 'Не настроено';

  @override
  String get presenceRadius => 'Радиус';

  @override
  String get presenceAwayTimeout => 'Таймаут «ушёл»';

  @override
  String get presenceHomeWifi => 'Дома (Wi-Fi)';

  @override
  String get presenceHeartbeatActive => 'Heartbeat активен';

  @override
  String get presenceHomeCloud => 'Дома (облако)';

  @override
  String get presenceWifiInactiveGpsUnavailable =>
      'Wi-Fi не активен · GPS недоступен';

  @override
  String presenceWifiInactiveDistance(String distance) {
    return 'Wi-Fi не активен · $distance от дома';
  }

  @override
  String get presenceAway => 'Ушёл';

  @override
  String presenceDistanceFromHome(String distance) {
    return 'Расстояние: $distance от дома';
  }

  @override
  String get presenceUnknown => 'Неизвестно';

  @override
  String get presenceEditPhone => 'Редактировать телефон';

  @override
  String get presenceAddPhone => 'Добавить телефон';

  @override
  String get presenceName => 'Название';

  @override
  String get presenceNameHint => 'Мой телефон';

  @override
  String get presencePhoneId => 'Phone ID';

  @override
  String get presencePhoneIdHint => '89533309330';

  @override
  String get presenceDelete => 'Удалить';

  @override
  String get presenceCancel => 'Отмена';

  @override
  String get presenceSave => 'Сохранить';

  @override
  String get presenceAdd => 'Добавить';

  @override
  String get presenceLatitude => 'Широта';

  @override
  String get presenceLongitude => 'Долгота';

  @override
  String get presenceGetCurrentCoordinates => 'Определить мои координаты';

  @override
  String get presenceGpsDisabled =>
      '❌ GPS выключен в системе. Включите его в настройках.';

  @override
  String get presencePermissionTitle => 'Нет разрешения';

  @override
  String get presencePermissionMessage =>
      'Разрешение на GPS отклонено навсегда.\nОткройте настройки и разрешите его вручную.';

  @override
  String get presenceOpenSettings => 'Открыть настройки';

  @override
  String get presencePermissionNotGranted => '❌ Разрешение на GPS не выдано';

  @override
  String get presenceGettingGps =>
      'Получаем GPS…\nЭто может занять до 60 секунд';

  @override
  String presenceCoordinatesReceived(String latitude, String longitude) {
    return '✅ Координаты получены:\n$latitude, $longitude';
  }

  @override
  String get presenceGpsFailed =>
      '❌ Не удалось получить GPS.\nПопробуйте выйти на открытое место.';

  @override
  String get presenceMeters => 'Метры';

  @override
  String get presenceRadiusHint => '100';

  @override
  String get presenceMinutes => 'Минуты';

  @override
  String get presenceTimeoutHint => '5';

  @override
  String get roomsManageEmpty => 'Нет комнат. Добавьте первую!';

  @override
  String roomsDeviceCount(int count) {
    return 'Устройств: $count';
  }

  @override
  String get roomsEditDialogTitle => 'Редактировать комнату';

  @override
  String get roomsDeleteDialogTitle => 'Удалить комнату?';

  @override
  String roomsDeleteWithDevices(int count) {
    return 'В комнате $count устройств. Они будут перенесены в «Все устройства». Продолжить?';
  }

  @override
  String roomsDeleteConfirmation(String name) {
    return 'Удалить комнату «$name»?';
  }

  @override
  String get roomsAllDevices => 'Все устройства';

  @override
  String roomsDeletedMessage(String name) {
    return 'Комната «$name» удалена';
  }

  @override
  String get roomIconLiving => 'Гостиная';

  @override
  String get roomIconBedroom => 'Спальня';

  @override
  String get roomIconKitchen => 'Кухня';

  @override
  String get roomIconBathroom => 'Ванная';

  @override
  String get roomIconGarage => 'Гараж';

  @override
  String get roomIconYard => 'Двор';

  @override
  String get roomIconKids => 'Детская';

  @override
  String get roomIconStorage => 'Кладовая';

  @override
  String get roomIconOffice => 'Кабинет';

  @override
  String get roomIconHome => 'Дом';

  @override
  String get roomIconAppliances => 'Техника';

  @override
  String get roomsDeleteButton => 'Удалить';

  @override
  String get sceneEditorTitleNew => 'Новая сцена';

  @override
  String get sceneEditorTitleEdit => 'Редактировать сцену';

  @override
  String get sceneEditorName => 'Название';

  @override
  String get sceneEditorNameHint => 'Выключить всё';

  @override
  String get sceneEditorTriggerType => 'Тип запуска';

  @override
  String get sceneEditorTriggerManual => '🎬 Вручную';

  @override
  String get sceneEditorTriggerTime => '⏰ По времени';

  @override
  String get sceneEditorTriggerSensor => '🌡️ По датчику';

  @override
  String get sceneEditorTriggerPresence => '📍 По присутствию';

  @override
  String get sceneEditorRepeat => 'Повтор';

  @override
  String get sceneEditorRepeatOnce => 'Один раз';

  @override
  String get sceneEditorRepeatDaily => 'Каждый день';

  @override
  String get sceneEditorRepeatWeekly => 'По дням недели';

  @override
  String get sceneEditorDaysOfWeek => 'Дни недели';

  @override
  String get sceneEditorMonday => 'Пн';

  @override
  String get sceneEditorTuesday => 'Вт';

  @override
  String get sceneEditorWednesday => 'Ср';

  @override
  String get sceneEditorThursday => 'Чт';

  @override
  String get sceneEditorFriday => 'Пт';

  @override
  String get sceneEditorSaturday => 'Сб';

  @override
  String get sceneEditorSunday => 'Вс';

  @override
  String get sceneEditorSensor => 'Датчик';

  @override
  String get sceneEditorSelectSensor => 'Выберите датчик';

  @override
  String get sceneEditorCondition => 'Условие';

  @override
  String sceneEditorTemperatureAbove(String threshold) {
    return '🌡️ Температура выше $threshold °C';
  }

  @override
  String sceneEditorTemperatureBelow(String threshold) {
    return '🌡️ Температура ниже $threshold °C';
  }

  @override
  String sceneEditorHumidityAbove(String threshold) {
    return '💧 Влажность выше $threshold%';
  }

  @override
  String sceneEditorHumidityBelow(String threshold) {
    return '💧 Влажность ниже $threshold%';
  }

  @override
  String get sceneEditorWaterLeak => '💧 Протечка';

  @override
  String get sceneEditorMotion => '🏃 Движение';

  @override
  String get sceneEditorContactOpen => '🚪 Открыто';

  @override
  String get sceneEditorContactClosed => '🚪 Закрыто';

  @override
  String get sceneEditorSmoke => '🔥 Дым';

  @override
  String get sceneEditorGas => '💨 Газ';

  @override
  String get sceneEditorThreshold => 'Порог';

  @override
  String get sceneEditorPresenceEvent => 'Событие';

  @override
  String get sceneEditorSomeoneHome => 'Кто-то пришёл';

  @override
  String get sceneEditorNobodyHome => 'Никого нет';

  @override
  String get sceneEditorAllHome => 'Все дома';

  @override
  String get sceneEditorPhoneArrived => 'Телефон пришёл';

  @override
  String get sceneEditorPhoneLeft => 'Телефон ушёл';

  @override
  String get sceneEditorPhoneUnknown => 'Телефон потерян';

  @override
  String get sceneEditorPhone => 'Телефон';

  @override
  String get sceneEditorSelectPhone => 'Выберите телефон';

  @override
  String get sceneEditorAdvanced => 'Дополнительно';

  @override
  String get sceneEditorDetectionChannel => 'Канал определения';

  @override
  String get sceneEditorChannelAny => 'Любой';

  @override
  String get sceneEditorChannelWifi => 'Только Wi-Fi';

  @override
  String get sceneEditorChannelGps => 'Только GPS';

  @override
  String get sceneEditorStartDelay => 'Задержка перед запуском';

  @override
  String get sceneEditorNoDelay => 'Без задержки';

  @override
  String get sceneEditorMinute => '1 минута';

  @override
  String sceneEditorMinutes(int count) {
    return '$count минут';
  }

  @override
  String get sceneEditorCooldown => 'Антидребезг';

  @override
  String get sceneEditorConfigureConditions => 'Настроить условия';

  @override
  String get sceneEditorConditionsConfigured => 'Условия настроены ✓';

  @override
  String get sceneEditorActions => 'Действия';

  @override
  String get sceneEditorNoDevices => 'Нет устройств';

  @override
  String get sceneEditorActionOn => 'ВКЛ';

  @override
  String get sceneEditorActionOff => 'ВЫКЛ';

  @override
  String get sceneEditorCancel => 'Отмена';

  @override
  String get sceneEditorSave => 'Сохранить';

  @override
  String get sceneEditorCreate => 'Создать';

  @override
  String get sceneEditorValidation => '⚠️ Введите название и выберите действия';

  @override
  String get sceneEditorUpdated => '✅ Сцена обновлена!';

  @override
  String get sceneEditorCreated => '✅ Сцена создана!';

  @override
  String get sceneEditorConditionsTitle => 'Условия';

  @override
  String get sceneEditorTimeOfDay => 'Время суток';

  @override
  String sceneEditorFromTime(String time) {
    return 'С $time';
  }

  @override
  String sceneEditorUntilTime(String time) {
    return 'До $time';
  }

  @override
  String get sceneEditorDaysCondition => 'Дни недели';

  @override
  String get sceneEditorReset => 'Сбросить';

  @override
  String get scenesTitle => 'Сцены';

  @override
  String get scenesEmpty => 'Нет сцен. Создайте первую!';

  @override
  String scenesAutoTriggerMessage(String name) {
    return '⏰ Сцена «$name» запускается автоматически по триггеру';
  }

  @override
  String get sceneEditorActionBrightness => 'ЯРК';

  @override
  String get sceneEditorDeviceUnitShort => 'устр.';

  @override
  String get scenesPresence => 'Присутствие';

  @override
  String get scenesDeviceFallback => 'Устройство';

  @override
  String get scenesEdit => 'Редактировать';

  @override
  String get scenesDelete => 'Удалить';

  @override
  String get screenSaverTitle => 'Заставка';

  @override
  String get screenSaverSubtitle =>
      'Показывать анимированную заставку после бездействия';

  @override
  String get screenSaverMotionWakeTitle => 'Сбрасывать заставку по движению';

  @override
  String get screenSaverMotionWakeSubtitle =>
      'Использовать фронтальную камеру, пока показана заставка';

  @override
  String screenSaverSensitivity(int value) {
    return 'Чувствительность: $value%';
  }

  @override
  String get screenSaverSensitivityLow => 'Низкая';

  @override
  String get screenSaverSensitivityHigh => 'Высокая';

  @override
  String get screenSaverSensitivityHint =>
      'Если заставка срабатывает без движения, уменьшите чувствительность.';

  @override
  String get screenSaverTimeoutTitle => 'Время до заставки';

  @override
  String get screenSaverChoose => 'Выбрать';

  @override
  String get screenSaverTimeout30 => '30 секунд';

  @override
  String get screenSaverTimeout60 => '1 минута';

  @override
  String get screenSaverTimeout120 => '2 минуты';

  @override
  String get screenSaverTimeout300 => '5 минут';

  @override
  String get screenSaverTimeout600 => '10 минут';

  @override
  String screenSaverTimeoutSeconds(int value) {
    return '$value секунд';
  }

  @override
  String get settingsPollInterval => 'Интервал опроса';

  @override
  String settingsIntervalSeconds(int value) {
    return '$value сек.';
  }

  @override
  String settingsIntervalMinutes(int value) {
    return '$value мин.';
  }

  @override
  String settingsPollIntervalChanged(String interval) {
    return 'Интервал изменён на $interval. Перезапустите приложение.';
  }

  @override
  String get settingsEventsRetention => 'Хранить события';

  @override
  String settingsDays(int value) {
    return '$value дней';
  }

  @override
  String get settingsElectricityTariff => 'Тариф электроэнергии';

  @override
  String settingsCurrencyPerKwh(String value) {
    return '$value ₽/кВт·ч';
  }

  @override
  String get settingsBackup => 'Резервное копирование';

  @override
  String get settingsBackupSubtitle => 'Экспорт / Импорт';

  @override
  String get settingsMqtt => 'Настройки MQTT';

  @override
  String get settingsMqttSubtitle => 'Брокер для Zigbee2MQTT';

  @override
  String get settingsCheckUpdates => 'Проверить обновления';

  @override
  String get settingsCheckUpdatesSubtitle => 'Проверить наличие новой версии';

  @override
  String get settingsInformation => 'Информация';

  @override
  String get settingsInformationSubtitle => 'Лицензии и соглашения';

  @override
  String get settingsExportReady => '✅ Конфиг готов к отправке';

  @override
  String settingsError(String error) {
    return '❌ Ошибка: $error';
  }

  @override
  String get settingsImportDone => '✅ Импорт выполнен';

  @override
  String get settingsImportRestartHint =>
      'Данные восстановлены.\n\nРекомендуется перезапустить приложение, чтобы все настройки (VK, облако, устройства) применились.';

  @override
  String get settingsLater => 'Позже';

  @override
  String get settingsRestart => 'Перезапустить';

  @override
  String get settingsBackupDialogTitle => 'Резервное копирование';

  @override
  String get settingsExport => 'Экспортировать';

  @override
  String get settingsExportSubtitle =>
      'Поделиться через облако, почту или Telegram';

  @override
  String get settingsImport => 'Импортировать';

  @override
  String get settingsImportSubtitle =>
      'Выбрать файл на устройстве или в облаке';

  @override
  String get settingsRetentionDialogTitle => 'Хранить события';

  @override
  String settingsRetentionDays(int value) {
    return '$value дней';
  }

  @override
  String get settingsTariffDialogTitle => 'Тариф ₽/кВт·ч';

  @override
  String get settingsTariffInvalid => 'Введите корректный тариф больше нуля';

  @override
  String get settingsTariffHint => '5.5';

  @override
  String get smsSettingsTitle => 'SMS-уведомления';

  @override
  String get smsSettingsEnable => 'Включить SMS';

  @override
  String get smsSettingsEnableSubtitle => 'Отправлять уведомления по SMS';

  @override
  String get smsSettingsPhoneNumbers => 'Номера телефонов';

  @override
  String get smsSettingsNoPhones => 'Нет добавленных номеров';

  @override
  String get smsSettingsEventsTitle => 'События для SMS';

  @override
  String get smsSettingsScenes => 'Сцены';

  @override
  String get smsSettingsDevices => 'Устройства';

  @override
  String get smsSettingsAlarms => 'Тревоги';

  @override
  String get smsSettingsZigbeeWaterLeak => 'Zigbee: 💧 Протечка';

  @override
  String get smsSettingsZigbeeSmoke => 'Zigbee: 🔥 Дым';

  @override
  String get smsSettingsZigbeeGas => 'Zigbee: 💨 Газ';

  @override
  String get smsSettingsZigbeeMotion => 'Zigbee: 🏃 Движение';

  @override
  String get smsSettingsZigbeeContact => 'Zigbee: 🚪 Контакт';

  @override
  String get smsSettingsFrigatePerson => 'Frigate: 🚶 Человек';

  @override
  String get smsSettingsFrigateCar => 'Frigate: 🚗 Автомобиль';

  @override
  String get smsSettingsErrors => 'Ошибки';

  @override
  String get smsSettingsZigbeeOffline => 'Zigbee offline';

  @override
  String get smsSettingsZigbeeOfflineSubtitle => 'Устройство потеряло связь';

  @override
  String get smsSettingsFrigateOffline => 'Frigate offline';

  @override
  String get smsSettingsFrigateOfflineSubtitle => 'Frigate недоступен';

  @override
  String get smsSettingsCooldown => 'Антидребезг SMS';

  @override
  String get smsSettingsOneMinute => '1 минута';

  @override
  String smsSettingsMinutes(int count) {
    return '$count минут';
  }

  @override
  String get smsSettingsSchedule => 'Расписание';

  @override
  String get smsSettingsScheduleSubtitle =>
      'Отправлять только в указанное время';

  @override
  String get smsSettingsAlarmsOutsideSchedule => 'Тревоги вне расписания';

  @override
  String get smsSettingsStartTime => 'Время начала';

  @override
  String get smsSettingsEndTime => 'Время окончания';

  @override
  String get smsSettingsDaysOfWeek => 'Дни недели:';

  @override
  String get smsSettingsMonday => 'Пн';

  @override
  String get smsSettingsTuesday => 'Вт';

  @override
  String get smsSettingsWednesday => 'Ср';

  @override
  String get smsSettingsThursday => 'Чт';

  @override
  String get smsSettingsFriday => 'Пт';

  @override
  String get smsSettingsSaturday => 'Сб';

  @override
  String get smsSettingsSunday => 'Вс';

  @override
  String get smsSettingsAddPhoneRequired => 'Добавьте хотя бы один номер';

  @override
  String get smsSettingsSendTest => 'Отправить тестовое SMS';

  @override
  String get smsSettingsTestMessage => '✅ Тестовое SMS из SHome!';

  @override
  String get smsSettingsAddPhoneTitle => 'Добавить номер';

  @override
  String get smsSettingsNameOptional => 'Имя (необязательно)';

  @override
  String get smsSettingsNameHint => 'Мой телефон';

  @override
  String get smsSettingsPhoneLabel => 'Номер';

  @override
  String get smsSettingsPhoneHint => '+79991234567';

  @override
  String get smsSettingsCancel => 'Отмена';

  @override
  String get smsSettingsAdd => 'Добавить';

  @override
  String get smsSettingsDelete => 'Удалить';

  @override
  String get timersTitle => 'Таймеры';

  @override
  String get timersEmpty => 'Нет активных таймеров';

  @override
  String get timersAlreadyFired => 'Уже сработал';

  @override
  String get timersLessThanMinute => 'менее минуты';

  @override
  String get timersTurnOn => 'Включится';

  @override
  String get timersTurnOff => 'Выключится';

  @override
  String timersCountdownMinutes(int minutes) {
    return 'через $minutes мин';
  }

  @override
  String timersCountdownHoursMinutes(int hours, int minutes) {
    return 'через $hours ч $minutes мин';
  }

  @override
  String timersTodayAt(String time) {
    return 'Сегодня в $time';
  }

  @override
  String get timersNewTitle => 'Новый таймер';

  @override
  String get timersDeviceLabel => 'Устройство';

  @override
  String get timersCommandOff => 'ВЫКЛ';

  @override
  String get timersCommandOn => 'ВКЛ';

  @override
  String get timersCancel => 'Отмена';

  @override
  String get timersCreate => 'Создать';

  @override
  String get timersDeleteTooltip => 'Удалить таймер';

  @override
  String get vkSettingsTitle => 'VK Bot';

  @override
  String get vkSettingsEnable => 'Включить VK';

  @override
  String get vkSettingsEnableSubtitle => 'Отправлять уведомления в VK';

  @override
  String get vkSettingsTokenLabel => 'VK Token';

  @override
  String get vkSettingsTokenHint => 'Вставьте токен бота';

  @override
  String get vkSettingsUserIdLabel => 'VK User ID';

  @override
  String get vkSettingsUserIdHint => 'Например, 123456789';

  @override
  String get vkSettingsEvents => 'События';

  @override
  String get vkSettingsScenes => 'Сцены';

  @override
  String get vkSettingsScenesSubtitle => 'Уведомления о выполнении сцен';

  @override
  String get vkSettingsDevices => 'Устройства';

  @override
  String get vkSettingsDevicesSubtitle => 'Изменение состояния устройств';

  @override
  String get vkSettingsAlarms => 'Тревоги';

  @override
  String get vkSettingsZigbeeWaterLeak => 'Zigbee: 💧 Протечка';

  @override
  String get vkSettingsZigbeeSmoke => 'Zigbee: 🔥 Дым';

  @override
  String get vkSettingsZigbeeGas => 'Zigbee: 💨 Газ';

  @override
  String get vkSettingsZigbeeMotion => 'Zigbee: 🏃 Движение';

  @override
  String get vkSettingsZigbeeContact => 'Zigbee: 🚪 Контакт';

  @override
  String get vkSettingsFrigatePerson => 'Frigate: 🚶 Человек';

  @override
  String get vkSettingsFrigateCar => 'Frigate: 🚗 Автомобиль';

  @override
  String get vkSettingsErrors => 'Ошибки';

  @override
  String get vkSettingsZigbeeOffline => 'Zigbee offline';

  @override
  String get vkSettingsZigbeeOfflineSubtitle => 'Устройство потеряло связь';

  @override
  String get vkSettingsFrigateOffline => 'Frigate offline';

  @override
  String get vkSettingsFrigateOfflineSubtitle => 'Frigate недоступен';

  @override
  String get vkSettingsCooldown => 'Антидребезг VK';

  @override
  String get vkSettingsCooldown1 => '1 минута';

  @override
  String get vkSettingsCooldown5 => '5 минут';

  @override
  String get vkSettingsCooldown15 => '15 минут';

  @override
  String get vkSettingsCooldown30 => '30 минут';

  @override
  String get vkSettingsSchedule => 'Расписание';

  @override
  String get vkSettingsScheduleSubtitle =>
      'Отправлять только в указанное время';

  @override
  String get vkSettingsAlarmsOutsideSchedule => 'Тревоги вне расписания';

  @override
  String get vkSettingsAlarmsAlways => 'Тревоги отправлять всегда';

  @override
  String get vkSettingsStartTime => 'Время начала';

  @override
  String get vkSettingsEndTime => 'Время окончания';

  @override
  String get vkSettingsDaysOfWeek => 'Дни недели:';

  @override
  String get vkSettingsMonday => 'Пн';

  @override
  String get vkSettingsTuesday => 'Вт';

  @override
  String get vkSettingsWednesday => 'Ср';

  @override
  String get vkSettingsThursday => 'Чт';

  @override
  String get vkSettingsFriday => 'Пт';

  @override
  String get vkSettingsSaturday => 'Сб';

  @override
  String get vkSettingsSunday => 'Вс';

  @override
  String get vkSettingsSendTest => 'Отправить тест VK';

  @override
  String get vkSettingsTestMessage => '✅ Тестовое уведомление из SHome!';

  @override
  String get zigbeeScanTitle => 'Zigbee';

  @override
  String get zigbeeRefresh => 'Обновить';

  @override
  String zigbeeStopPairing(int seconds) {
    return 'Остановить сопряжение ($seconds с)';
  }

  @override
  String get zigbeeOpenPairing => 'Открыть сеть для сопряжения';

  @override
  String get zigbeePairingInstruction =>
      'Зажмите кнопку на устройстве на 5 секунд';

  @override
  String get zigbeeNoDevices =>
      'Устройства не найдены.\nНажмите «Открыть сеть» и добавьте устройство.';

  @override
  String zigbeeDeviceAdded(String name) {
    return '✅ $name добавлено';
  }

  @override
  String get changelogTitle => 'История изменений';

  @override
  String get changelogLoadError => 'Не удалось загрузить историю изменений';

  @override
  String get eulaTitle => 'Лицензионное соглашение';

  @override
  String get legalInfoTitle => 'Информация';

  @override
  String legalDeveloperLabel(String name) {
    return 'Разработчик: $name';
  }

  @override
  String legalOwnerLabel(String name) {
    return 'Собственник: $name';
  }

  @override
  String legalVersionLabel(String version) {
    return 'Версия: $version';
  }

  @override
  String get legalEulaTitle => 'Лицензионное соглашение (EULA)';

  @override
  String get legalEulaSubtitle => 'Правила использования приложения';

  @override
  String get legalPrivacyTitle => 'Политика конфиденциальности';

  @override
  String get legalPrivacySubtitle => 'Как мы обрабатываем ваши данные';

  @override
  String get legalTermsTitle => 'Условия использования';

  @override
  String get legalTermsSubtitle => 'Правила и ограничения';

  @override
  String get legalOpenSourceTitle => 'Лицензии открытого ПО';

  @override
  String get legalOpenSourceSubtitle => 'Сторонние библиотеки';

  @override
  String get legalChangelogTitle => 'История изменений';

  @override
  String get legalChangelogSubtitle => 'Что нового в каждой версии';

  @override
  String legalVersionFooter(String version) {
    return 'Версия $version';
  }

  @override
  String get statsPeriod24h => '24ч';

  @override
  String get statsPeriod7d => '7д';

  @override
  String get statsPeriod30d => '30д';

  @override
  String get statsNoClimateData => 'Нет данных датчиков за период';

  @override
  String get statsClimateByDevice => 'Климат по устройствам';

  @override
  String statsSampleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count измерения',
      many: '$count измерений',
      few: '$count измерения',
      one: '$count измерение',
      zero: 'Нет измерений',
    );
    return '$_temp0';
  }

  @override
  String statsTemperatureSummary(String min, String max, String average) {
    return '🌡️ $min° … $max° (среднее: $average°)';
  }

  @override
  String statsHumiditySummary(String min, String max, String average) {
    return '💧 $min% … $max% (среднее: $average%)';
  }

  @override
  String get statsNoDeviceDataPeriod => 'Нет данных за период';

  @override
  String statsDeviceEventCounts(int offline, int alerts, int actions) {
    return 'Не в сети: $offline · алерты: $alerts · действия: $actions';
  }

  @override
  String statsAlertsForDays(int days) {
    return 'Алерты за $days дн.';
  }

  @override
  String statsOfflineForDays(int days) {
    return 'Не в сети за $days дн.';
  }

  @override
  String get statsEnergyConsumption => 'Потребление';

  @override
  String get statsEnergyCost => 'Стоимость';

  @override
  String statsEnergyPeriod(int days) {
    return 'за $days дн.';
  }

  @override
  String statsEnergyTariff(String tariff) {
    return 'тариф $tariff ₽/кВт·ч';
  }

  @override
  String statsEnergyRubles(String value) {
    return '$value ₽';
  }

  @override
  String statsEnergyKwh(String value) {
    return '$value кВт·ч';
  }

  @override
  String get statsEnergyNoData => 'Нет данных энергопотребления за период';

  @override
  String get statsEnergyByDevice => 'По устройствам';

  @override
  String get statsNotificationsEmpty => 'Нет уведомлений за период';

  @override
  String get statsNotificationsSent => 'Отправлено';

  @override
  String get statsNotificationsSuppressed => 'Подавлено';

  @override
  String statsNotificationsPeriod(int days) {
    return 'за $days дн.';
  }

  @override
  String statsNotificationsCooldownPercent(int percent) {
    return 'cooldown ($percent%)';
  }

  @override
  String get statsNotificationsByChannel => 'По каналам';

  @override
  String statsNotificationsChannelSuppressed(int count) {
    return 'Подавлено: $count';
  }

  @override
  String get statsNotificationsByCategory => 'По категориям';

  @override
  String get statsNotificationsCategoryWaterLeak => '💧 Протечка';

  @override
  String get statsNotificationsCategorySmoke => '🔥 Дым';

  @override
  String get statsNotificationsCategoryGas => '💨 Газ';

  @override
  String get statsNotificationsCategoryMotion => '🏃 Движение';

  @override
  String get statsNotificationsCategoryContact => '🚪 Контакт';

  @override
  String get statsNotificationsCategoryPerson => '🎥 Человек';

  @override
  String get statsNotificationsCategoryCar => '🎥 Автомобиль';

  @override
  String get statsNotificationsCategoryOffline => '📡 Не в сети';

  @override
  String get statsNotificationsCategoryLowBattery => '🔋 Батарея';

  @override
  String get statsNotificationsCategoryStateChanged => '🎛 Состояние';

  @override
  String get statsNotificationsCategoryUnknown => 'Другое';

  @override
  String get statsOverviewAlerts => 'Алерты';

  @override
  String get statsOverviewActions => 'Действия';

  @override
  String get statsOverviewOffline => 'Не в сети';

  @override
  String get statsOverviewOnline => 'В сети';

  @override
  String statsOverviewPeriod(int days) {
    return 'за $days дн.';
  }

  @override
  String get statsOverviewWorstDevices => 'Проблемные устройства';

  @override
  String get statsOverviewNoProblems => 'Нет проблемных устройств за период 👍';

  @override
  String get statsPresenceEmpty => 'Нет данных присутствия за период';

  @override
  String get statsPresenceHome => 'Дома';

  @override
  String get statsPresenceNear => 'Рядом';

  @override
  String get statsPresenceAway => 'Ушёл';

  @override
  String get statsPresenceUnknown => 'Неизвестно';

  @override
  String statsPresencePeriod(int days) {
    return 'за $days дн.';
  }

  @override
  String get statsPresenceCloudFallback => 'Переход на облако';

  @override
  String get statsPresenceCloudFallbackSubtitle =>
      'Сколько раз heartbeat не сработал';

  @override
  String get statsPresenceDurationZero => '0';

  @override
  String statsPresenceDurationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String statsPresenceDurationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get statsPresenceDurationLessMinute => 'менее минуты';

  @override
  String get statsScenesTop => 'Топ сцен';

  @override
  String statsScenesRuns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# раза',
      many: '# раз',
      few: '# раза',
      one: '# раз',
      zero: 'Нет запусков',
    );
    return '$_temp0';
  }

  @override
  String get statsScenesNoRunsPeriod => 'Нет срабатываний сцен за период';

  @override
  String get statsScenesForgottenTitle => 'Забытые сцены (0 срабатываний)';

  @override
  String get statsScenesDeleteCandidate => 'Кандидат на удаление';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get statsTabOverview => 'Обзор';

  @override
  String get statsTabDevices => 'Устройства';

  @override
  String get statsTabEnergy => 'Энергия';

  @override
  String get statsTabVideo => 'Видео';

  @override
  String get statsTabScenes => 'Сцены';

  @override
  String get statsTabPresence => 'Присутствие';

  @override
  String get statsTabClimate => 'Климат';

  @override
  String get statsTabNotifications => 'Уведомления';

  @override
  String get statsVideoEmpty => 'Нет детекций за период';

  @override
  String get statsVideoByTypes => 'По типам';

  @override
  String get statsVideoByCameras => 'По камерам';

  @override
  String get statsVideoActivityByHour => 'Активность по часам';

  @override
  String get statsVideoHeatmapHint =>
      'Чем интенсивнее цвет — тем больше детекций';

  @override
  String get statsVideoLabelPerson => 'Человек';

  @override
  String get statsVideoLabelCar => 'Автомобиль';

  @override
  String get statsVideoLabelDog => 'Собака';

  @override
  String get statsVideoLabelCat => 'Кошка';

  @override
  String get statsVideoLabelBird => 'Птица';

  @override
  String get statsVideoLabelMotorcycle => 'Мотоцикл';

  @override
  String get statsVideoLabelBicycle => 'Велосипед';

  @override
  String get statsVideoLabelTruck => 'Грузовик';

  @override
  String get statsVideoLabelBus => 'Автобус';

  @override
  String get statsVideoLabelBoat => 'Лодка';

  @override
  String get deviceCardWaterLeak => 'Протечка';

  @override
  String get deviceCardMotion => 'Движение';

  @override
  String get deviceCardContactOpen => 'Открыто';

  @override
  String get deviceSettingsName => 'Название';

  @override
  String get deviceSettingsRoom => 'Комната';

  @override
  String get deviceSettingsRtspUrl => 'RTSP URL';

  @override
  String get deviceSettingsZigbeeDevice => 'Zigbee-устройство';

  @override
  String get deviceSettingsIeeeAddress => 'IEEE-адрес';

  @override
  String get deviceSettingsModel => 'Модель';

  @override
  String get deviceSettingsVendor => 'Производитель';

  @override
  String get deviceSettingsBattery => 'Батарея';

  @override
  String get deviceSettingsLinkQuality => 'Качество связи';

  @override
  String get deviceSettingsNotifications => 'Уведомления';

  @override
  String get deviceSettingsDeviceId => 'Device ID';

  @override
  String get deviceSettingsIpAddress => 'IP-адрес';

  @override
  String get deviceSettingsLocalKey => 'Local Key';

  @override
  String get deviceSettingsProtocolVersion => 'Версия протокола';

  @override
  String get deviceSettingsChannels => 'Каналы';

  @override
  String get deviceSettingsDpsIndex => 'Индекс DPS';

  @override
  String get deviceSettingsDpsMap => 'Карта DPS';

  @override
  String get deviceSettingsAddDps => 'Добавить DPS';

  @override
  String get deviceSettingsDisplayOnCard => 'Отображение на карточке';

  @override
  String get deviceSettingsDisplayHint =>
      'Выберите, какие данные показывать на главном экране';

  @override
  String get deviceSettingsNoInfoParameters => 'Нет информационных параметров';

  @override
  String get deviceSettingsDeleteTitle => 'Удалить устройство?';

  @override
  String deviceSettingsDeleteMessage(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get deviceSettingsDelete => 'Удалить';

  @override
  String get deviceSettingsSave => 'Сохранить';

  @override
  String get deviceSettingsCancel => 'Отмена';

  @override
  String get deviceSettingsCreateSensor => 'Создать датчик';

  @override
  String deviceSettingsSensorFromDevice(String name) {
    return 'Из устройства: $name';
  }

  @override
  String get deviceSettingsSensorType => 'Тип датчика';

  @override
  String get deviceSettingsTemperature => 'Температура';

  @override
  String get deviceSettingsHumidity => 'Влажность';

  @override
  String get deviceSettingsPower => 'Мощность';

  @override
  String get deviceSettingsCurrent => 'Ток';

  @override
  String get deviceSettingsVoltage => 'Напряжение';

  @override
  String get deviceSettingsDivider => 'Делитель';

  @override
  String deviceSettingsSensorCreated(String name) {
    return '✅ Датчик «$name» создан!';
  }

  @override
  String get deviceSettingsChannel => 'Канал';

  @override
  String get deviceSettingsChannelNumber => 'Номер канала';

  @override
  String get deviceSettingsDpsAddTitle => 'Добавить DPS';

  @override
  String deviceSettingsDpsEditTitle(String key) {
    return 'Редактировать DPS $key';
  }

  @override
  String get deviceSettingsDpsNumber => 'Номер DPS';

  @override
  String get deviceSettingsDpsType => 'Тип';

  @override
  String get deviceSettingsDpsRole => 'Роль';

  @override
  String get deviceSettingsDpsIcon => 'Иконка';

  @override
  String get deviceSettingsNoIcon => 'Без иконки';

  @override
  String get deviceSettingsRoleChannel => 'Канал';

  @override
  String get deviceSettingsRoleMain => 'Главная кнопка';

  @override
  String get deviceSettingsRoleAction => 'Действие';

  @override
  String get deviceSettingsRoleToggle => 'Переключатель';

  @override
  String get deviceSettingsRoleInfo => 'Информация';

  @override
  String get deviceSettingsRoleStatus => 'Статус';

  @override
  String get deviceSettingsRoleEnum => 'Выпадающий список';

  @override
  String get deviceSettingsRoleSlider => 'Ползунок';

  @override
  String get deviceSettingsDpsChannelTitle => 'Канал';

  @override
  String get deviceSettingsNotifyAlways => 'Всегда';

  @override
  String get deviceSettingsNotifyAway => 'Когда никого нет';

  @override
  String get deviceSettingsNotifyNight => 'Ночью';

  @override
  String get deviceSettingsNotifyAwayOrNight => 'Никого нет ИЛИ ночью';

  @override
  String deviceSettingsNotifySummary(int count, String condition) {
    return '$count типов · $condition';
  }

  @override
  String get deviceSettingsTypeBool => 'вкл/выкл';

  @override
  String get deviceSettingsTypeValue => 'число';

  @override
  String get deviceSettingsTypeEnum => 'текстовый список';

  @override
  String get deviceSettingsTypeSlider => 'ползунок';

  @override
  String get deviceSettingsIconNone => 'Без иконки';

  @override
  String get deviceSettingsIconPlayStop => 'Пуск/Стоп';

  @override
  String get deviceSettingsIconHomeBase => 'Дом/База';

  @override
  String get deviceSettingsIconPower => 'Питание';

  @override
  String get deviceSettingsIconWater => 'Вода';

  @override
  String get deviceSettingsIconMop => 'Мытьё';

  @override
  String get deviceSettingsIconDoNotDisturb => 'Не беспокоить';

  @override
  String get deviceSettingsIconBattery => 'Батарея';

  @override
  String get deviceSettingsIconTimer => 'Таймер';

  @override
  String get deviceSettingsIconArea => 'Площадь';

  @override
  String get deviceSettingsIconFan => 'Вентилятор';

  @override
  String get deviceSettingsIconCooling => 'Охлаждение';

  @override
  String get deviceSettingsIconHeating => 'Обогрев';

  @override
  String get deviceSettingsIconDrying => 'Осушение';

  @override
  String get deviceSettingsIconAuto => 'Авто';

  @override
  String get deviceSettingsIconSleep => 'Сон';

  @override
  String get deviceSettingsIconVerticalBlinds => 'Вертикальные жалюзи';

  @override
  String get deviceSettingsIconHorizontalBlinds => 'Горизонтальные жалюзи';

  @override
  String get deviceSettingsIconAirQuality => 'Качество воздуха';

  @override
  String get deviceSettingsIconFilter => 'Фильтр';

  @override
  String get deviceSettingsIconTemperature => 'Температура';

  @override
  String get deviceSettingsIconAirConditioner => 'Кондиционер';

  @override
  String get deviceSettingsIconHeater => 'Обогреватель';

  @override
  String get deviceSettingsIconAir => 'Воздух';

  @override
  String get deviceSettingsIconSuction => 'Всасывание';

  @override
  String get deviceSettingsIconWaiting => 'Ожидание';

  @override
  String get deviceSettingsIconSynchronization => 'Синхронизация';

  @override
  String deviceSettingsDefaultChannelLabel(String key) {
    return 'Канал $key';
  }

  @override
  String get deviceSettingsAdd => 'Добавить';

  @override
  String get deviceSettingsCreate => 'Создать';

  @override
  String get todayDrawerToday => 'Сегодня';
}
