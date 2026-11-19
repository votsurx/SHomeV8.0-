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
  String get scenesTitle => 'Сцены';

  @override
  String get scenesEmpty => 'Нет сцен. Создайте первую!';

  @override
  String get scenesManual => 'Вручную';

  @override
  String scenesAutoTriggerMessage(String name) {
    return '⏰ Сцена «$name» запускается автоматически по триггеру';
  }

  @override
  String scenesActionCount(int count) {
    return '$count устр.';
  }

  @override
  String scenesTimeTemperature(String operator, String threshold) {
    return 'Темп. $operator $threshold°C';
  }

  @override
  String scenesHumidity(String operator, String threshold) {
    return 'Влаж. $operator $threshold%';
  }

  @override
  String get scenesWaterLeak => '💧 Протечка';

  @override
  String get scenesMotion => '🏃 Движение';

  @override
  String get scenesContactOpen => '🚪 Открыто';

  @override
  String get scenesContactClosed => '🚪 Закрыто';

  @override
  String get scenesSmoke => '🔥 Дым';

  @override
  String get scenesGas => '💨 Газ';

  @override
  String get scenesPresence => 'Присутствие';

  @override
  String get scenesSomeoneArrived => 'Кто-то пришёл';

  @override
  String get scenesNobodyHome => 'Никого нет';

  @override
  String get scenesEveryoneHome => 'Все дома';

  @override
  String get scenesPhoneArrived => 'Телефон пришёл';

  @override
  String get scenesPhoneLeft => 'Телефон ушёл';

  @override
  String get scenesPhoneUnknown => 'Телефон потерян';

  @override
  String get scenesEveryDay => 'Каждый день';

  @override
  String get scenesWeekdays => 'По дням недели';

  @override
  String get scenesInterval => 'Интервал';

  @override
  String get scenesMondayShort => 'Пн';

  @override
  String get scenesTuesdayShort => 'Вт';

  @override
  String get scenesWednesdayShort => 'Ср';

  @override
  String get scenesThursdayShort => 'Чт';

  @override
  String get scenesFridayShort => 'Пт';

  @override
  String get scenesSaturdayShort => 'Сб';

  @override
  String get scenesSundayShort => 'Вс';

  @override
  String get scenesActionOn => 'ВКЛ';

  @override
  String get scenesActionOff => 'ВЫКЛ';

  @override
  String get scenesActionBrightness => 'ЯРК';

  @override
  String get scenesEdit => 'Редактировать';

  @override
  String get scenesDelete => 'Удалить';
}
