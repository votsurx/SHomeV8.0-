// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeSubtitle => 'Control your smart home easily';

  @override
  String get startButton => 'Get started';

  @override
  String get languageTitle => 'App language';

  @override
  String get languageSystem => 'Use device language';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String languageSelected(String language) {
    return 'Selected language: $language';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get pollingInterval => 'Polling interval';

  @override
  String get screenSettings => 'Screen settings';

  @override
  String get screenSettingsSubtitle => 'Screensaver and display';

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
  String get continueButton => 'Continue';

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
  String get roomsTitle => 'Rooms';

  @override
  String get roomsCreateTitle => 'Create rooms';

  @override
  String get roomsOrganizeHint => 'Organize devices by room';

  @override
  String get roomsAddFirst => 'Add your first room';

  @override
  String get roomsAddButton => 'Add room';

  @override
  String get onboardingFinishButton => 'Done!';

  @override
  String get roomAddDialogTitle => 'Add room';

  @override
  String get roomNameLabel => 'Name';

  @override
  String get roomNameHint => 'Bedroom';

  @override
  String get noDevices => 'No devices';

  @override
  String get forecastTitle => 'Weather forecast';

  @override
  String get ok => 'OK';

  @override
  String get ipAddressLabel => 'IP address';

  @override
  String get menuTitle => 'Menu';

  @override
  String get menuDevices => 'Devices';

  @override
  String get menuEnergy => 'Energy';

  @override
  String get menuScenes => 'Scenes';

  @override
  String get menuScanTuya => 'Scan TUYA';

  @override
  String get menuZigbee => 'Zigbee';

  @override
  String get menuFrigate => 'Frigate';

  @override
  String get menuRooms => 'Rooms';

  @override
  String get menuStatistics => 'Statistics';

  @override
  String get menuTimers => 'Timers';

  @override
  String get menuEvents => 'Events';

  @override
  String get menuCloud => 'Cloud';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuPresence => 'Presence';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuThemeSystem => 'Theme: system';

  @override
  String get menuThemeLight => 'Theme: light';

  @override
  String get menuThemeDark => 'Theme: dark';

  @override
  String get backupKeyScanTitle => 'Scan backup key';

  @override
  String get switchCameraTooltip => 'Switch camera';

  @override
  String get flashTooltip => 'Flashlight';

  @override
  String get backupKeyScanHint => 'Point the camera at the SHome key QR code';

  @override
  String get cloudSettingsTitle => '☁️ Cloud storage';

  @override
  String get cloudStatusConnected => '✅ Connected';

  @override
  String get cloudStatusDisconnected => '⚪ Not connected';

  @override
  String get cloudStatusLabel => 'Status';

  @override
  String cloudLoginValue(String login) {
    return 'Login: $login';
  }

  @override
  String get cloudConnectSection => '🔗 Connection';

  @override
  String get cloudLogin => 'Login';

  @override
  String get cloudLoginHint => 'login@mail.ru';

  @override
  String get cloudAppPassword => 'App password';

  @override
  String get cloudPasswordHelp =>
      '💡 How to get an app password:\n1. Mail.ru → Settings → Security\n2. App passwords → Create\n3. Name it “SHome” and copy the password';

  @override
  String get cloudConnecting => 'Connecting...';

  @override
  String get cloudConnect => 'Connect';

  @override
  String get cloudEnterCredentials => 'Enter your login and password';

  @override
  String get cloudConnectedMessage => '✅ Connected to cloud';

  @override
  String get cloudConnectFailed =>
      '❌ Could not connect. Check your login and password.';

  @override
  String cloudConnectionError(String error) {
    return '❌ Connection error: $error';
  }

  @override
  String get cloudDisconnectedMessage => '🔌 Disconnected from cloud';

  @override
  String get cloudDisconnect => 'Disconnect';

  @override
  String get cloudDisconnectSubtitle =>
      'The backup key will remain on this device';

  @override
  String get cloudBackupKeyTitle => '🔐 Backup encryption key';

  @override
  String get cloudKeyCreated => 'Key created';

  @override
  String get cloudKeyMissing => 'Key not created';

  @override
  String get cloudKeyReadySubtitle => 'AES-256-GCM is ready';

  @override
  String get cloudKeyMissingSubtitle => 'Create or import a key';

  @override
  String get cloudGenerateNewKeyTitle => 'Generate a new key?';

  @override
  String get cloudGenerateNewKeyWarning =>
      'A new key will make all existing backups impossible to restore.\n\nContinue?';

  @override
  String get cloudGenerate => 'Generate';

  @override
  String get cloudKeyCreatedMessage => '✅ Backup key created';

  @override
  String cloudKeyCreateError(String error) {
    return '❌ Error creating key: $error';
  }

  @override
  String get cloudShowQr => 'Show QR code';

  @override
  String get cloudScanQr => 'Scan QR code';

  @override
  String get cloudQrTitle => 'Backup key QR code';

  @override
  String get cloudQrHint => 'Scan this QR code with another SHome device.';

  @override
  String get cloudClose => 'Close';

  @override
  String get cloudNoLoginData => '❌ Cloud sign-in details are missing';

  @override
  String get cloudGenerateKeyFirst => '❌ Generate a backup key first';

  @override
  String get cloudImportKeyFirst => '❌ Generate or import a backup key first';

  @override
  String get cloudBackupUploaded => '✅ Backup uploaded to cloud';

  @override
  String get cloudBackupUploadFailed => '❌ Backup upload failed';

  @override
  String cloudBackupUploadError(String error) {
    return '❌ Upload error: $error';
  }

  @override
  String get cloudBackupManagementTitle => '📋 Backup management';

  @override
  String get cloudUploadBackup => 'Upload to cloud';

  @override
  String get cloudUploadBackupSubtitle => 'Save the current backup to cloud';

  @override
  String get cloudDownloadBackup => 'Download from cloud';

  @override
  String get cloudDownloadBackupSubtitle => 'Restore a backup from cloud';

  @override
  String get cloudNoBackups => 'ℹ️ No backups in the cloud';

  @override
  String get cloudChooseBackup => 'Select a backup';

  @override
  String get cloudBackupDownloadFailed => '❌ Backup download failed';

  @override
  String cloudBackupRestoreSuccess(String backup) {
    return '✅ Backup “$backup” restored. Restart the app.';
  }

  @override
  String cloudBackupRestoreError(String error) {
    return '❌ Restore error: $error';
  }

  @override
  String cloudLastSync(String date) {
    return 'Last sync: $date';
  }

  @override
  String get cloudReplaceKeyTitle => 'Replace the key?';

  @override
  String get cloudReplaceKeyWarning =>
      'A backup key already exists on this device.\n\nAfter replacing it, backups created with the current key will no longer be accessible.';

  @override
  String get cloudReplace => 'Replace';

  @override
  String get cloudKeyImported => '✅ Backup key imported';

  @override
  String cloudKeyImportError(String error) {
    return '❌ Error importing key: $error';
  }

  @override
  String get deviceNotificationsTitle => 'Device notifications';

  @override
  String get deviceNotFound => 'Device not found';

  @override
  String get notificationSettingsSaved => '✅ Settings saved';

  @override
  String get save => 'Save';

  @override
  String get notificationDeviceZigbee => 'Zigbee sensor';

  @override
  String get notificationDeviceFrigate => 'Frigate camera';

  @override
  String notificationDeviceTuya(String type) {
    return 'Tuya ($type)';
  }

  @override
  String get notificationConditionSection => '⏱ Notification condition';

  @override
  String get notificationConditionAlways => 'Always';

  @override
  String get notificationConditionAway => 'Only when nobody is home';

  @override
  String get notificationConditionNight => 'Only at night (10:00 PM – 6:00 AM)';

  @override
  String get notificationConditionAwayOrNight =>
      'Nobody is home OR it is night';

  @override
  String get notificationCooldownSection => '⏱ Cooldown';

  @override
  String get notificationInterval => 'Interval';

  @override
  String get notificationMinute => '1 minute';

  @override
  String get notificationMinutes5 => '5 minutes';

  @override
  String get notificationMinutes15 => '15 minutes';

  @override
  String get notificationMinutes30 => '30 minutes';

  @override
  String get notificationTypesTitle => '🔔 Notification types';

  @override
  String get notificationFrigateLabelsTitle => '🔔 Detection objects';

  @override
  String get notificationWaterLeak => 'Water leak';

  @override
  String get notificationSmoke => 'Smoke';

  @override
  String get notificationGas => 'Gas';

  @override
  String get notificationMotion => 'Motion';

  @override
  String get notificationContact => 'Contact';

  @override
  String get notificationLowBattery => 'Low battery';

  @override
  String get notificationStateChanged => 'On/Off';

  @override
  String get notificationOffline => 'Offline';

  @override
  String get notificationError => 'Error';

  @override
  String get notificationTemperatureAbove => 'Temperature >';

  @override
  String get notificationTemperatureBelow => 'Temperature <';

  @override
  String get notificationHumidityAbove => 'Humidity >';

  @override
  String get notificationHumidityBelow => 'Humidity <';

  @override
  String get notificationPowerAbove => 'Power >';

  @override
  String get notificationPerson => 'Person';

  @override
  String get notificationCar => 'Car';

  @override
  String get notificationDog => 'Dog';

  @override
  String get notificationCat => 'Cat';

  @override
  String get notificationBird => 'Bird';

  @override
  String get notificationMotorcycle => 'Motorcycle';

  @override
  String get notificationBicycle => 'Bicycle';

  @override
  String get notificationTruck => 'Truck';

  @override
  String get notificationBus => 'Bus';

  @override
  String get notificationBoat => 'Boat';

  @override
  String get notificationThreshold => 'Threshold';

  @override
  String get notificationTemperatureThreshold => 'Temperature threshold';

  @override
  String get notificationHumidityThreshold => 'Humidity threshold';

  @override
  String get notificationPowerThreshold => 'Power threshold';

  @override
  String get notificationBatteryThreshold => 'Battery threshold';

  @override
  String get notificationHowItWorks => '💡 How it works';

  @override
  String get notificationAlwaysExplanation =>
      'Notifications are sent whenever the event occurs.';

  @override
  String notificationConditionExplanation(String condition) {
    return 'Notifications are sent only when this condition is met: “$condition”.';
  }

  @override
  String get eventsTitle => 'Events';

  @override
  String get eventsRefresh => 'Refresh';

  @override
  String get eventsClearAll => 'Clear all';

  @override
  String get eventsClearTitle => 'Clear events?';

  @override
  String get eventsClearWarning => 'All events will be permanently deleted.';

  @override
  String get eventsClearCancel => 'Cancel';

  @override
  String get eventsClearConfirm => 'Clear';

  @override
  String get eventsFilterAll => 'All';

  @override
  String get eventsFilterAlerts => 'Alerts';

  @override
  String get eventsFilterActions => 'Actions';

  @override
  String get eventsFilterErrors => 'Errors';

  @override
  String get eventsDeviceFilter => 'Device';

  @override
  String get eventsAllDevices => 'All devices';

  @override
  String get eventsEmptyFilter => 'No events match this filter';

  @override
  String get eventsSystemError => 'System error';

  @override
  String get eventsPhone => 'Phone';

  @override
  String get eventsPresence => 'Presence';

  @override
  String get eventsPresenceAway => 'Away';

  @override
  String get eventsPresenceHomeCloud => 'Home (cloud)';

  @override
  String get eventsPresenceHomeWifi => 'Home (Wi-Fi)';

  @override
  String get eventsPresenceHome => 'Home';

  @override
  String get eventsPresenceUnknown => 'Unknown';

  @override
  String get eventsSceneCompleted => 'Scene completed';

  @override
  String get eventsTurnedOn => 'Turned on';

  @override
  String get eventsTurnedOff => 'Turned off';

  @override
  String get eventsScene => 'Scene';

  @override
  String get eventsRoomAdded => 'Room added';

  @override
  String get eventsRoomRemoved => 'Room removed';

  @override
  String get eventsTimer => 'Timer';

  @override
  String get eventsDeviceAdded => 'Device added';

  @override
  String get eventsDeviceRemoved => 'Device removed';

  @override
  String get eventsSceneCreated => 'Scene created';

  @override
  String get eventsSceneDeleted => 'Scene deleted';

  @override
  String get eventsOnline => 'Online';

  @override
  String get eventsOffline => 'Offline';

  @override
  String get eventsError => 'Error';

  @override
  String get eventsAlarmWaterLeak => '💧 Water leak';

  @override
  String get eventsAlarmSmoke => '🔥 Smoke';

  @override
  String get eventsAlarmGas => '💨 Gas';

  @override
  String get eventsAlarmMotion => '🏃 Motion';

  @override
  String get eventsAlarmContactOpen => '🚪 Open';

  @override
  String get eventsAlarmContactClosed => '🚪 Closed';

  @override
  String get eventsAlarmTemperatureAbove => '🌡️ Temperature >';

  @override
  String get eventsAlarmTemperatureBelow => '🌡️ Temperature <';

  @override
  String get eventsAlarmHumidityAbove => '💧 Humidity >';

  @override
  String get eventsAlarmHumidityBelow => '💧 Humidity <';

  @override
  String get eventsFrigatePerson => '🎥 Person';

  @override
  String get eventsFrigateCar => '🎥 Car';

  @override
  String get eventsFrigateDog => '🎥 Dog';

  @override
  String get eventsFrigateCat => '🎥 Cat';

  @override
  String get eventsFrigateBird => '🎥 Bird';

  @override
  String get eventsFrigateOther => '🎥 Detection';

  @override
  String get frigateSettingsTooltip => 'Frigate settings';

  @override
  String get frigateRefreshTooltip => 'Refresh';

  @override
  String get frigateSHomeCameras => '🎥 Cameras in SHome';

  @override
  String get frigateAvailableCameras => '📍 Available in Frigate';

  @override
  String get frigateNoCameras =>
      'No cameras available.\nCheck Frigate settings.';

  @override
  String get frigateAllCamerasAdded => '✅ All cameras have been added';

  @override
  String get frigateStatistics => '📊 Statistics';

  @override
  String get frigateStatCameras => 'Cameras';

  @override
  String get frigateStatDetectors => 'Detectors';

  @override
  String get frigateStatCpu => 'CPU';

  @override
  String get frigateStatRam => 'RAM';

  @override
  String frigateRoomPrefix(String room) {
    return 'Room: $room';
  }

  @override
  String get frigateCameraSettingsTooltip => 'Settings';

  @override
  String get frigateRemoveFromSHomeTooltip => 'Remove from SHome';

  @override
  String get frigateAddToSHomeTooltip => 'Add to SHome';

  @override
  String frigateCameraAlreadyAdded(String name) {
    return '⚠️ Camera “$name” has already been added';
  }

  @override
  String frigateCameraAdded(String name) {
    return '✅ Camera “$name” added';
  }

  @override
  String get frigateDeleteCameraTitle => 'Delete camera?';

  @override
  String frigateDeleteCameraMessage(String name) {
    return 'Camera “$name” will be removed from SHome.';
  }

  @override
  String get frigateCancel => 'Cancel';

  @override
  String get frigateDelete => 'Delete';

  @override
  String frigateCameraRemoved(String name) {
    return '🗑️ Camera “$name” removed';
  }

  @override
  String get frigateRoomOther => '🔌 Other devices';

  @override
  String get frigateRoomLiving => '🛋️ Living room';

  @override
  String get frigateRoomBedroom => '🛏️ Bedroom';

  @override
  String get frigateRoomKitchen => '🍳 Kitchen';

  @override
  String get frigateSettingsTitle => 'Frigate settings';

  @override
  String get frigateConnectionSection => 'Connection';

  @override
  String get frigateHostLabel => 'Host (IP)';

  @override
  String get frigateHostHint => '192.168.43.16';

  @override
  String get frigatePortLabel => 'Port';

  @override
  String get frigatePortHint => '5000';

  @override
  String get frigateRtspPasswordLabel => 'RTSP password';

  @override
  String get frigateTestConnection => 'Test connection';

  @override
  String get frigateConnectionSuccess => 'Connection successful';

  @override
  String get frigateConnectionFailed => 'Connection failed';

  @override
  String get frigateSettingsSection => 'Settings';

  @override
  String get frigateStatsIntervalLabel => 'Statistics interval (sec)';

  @override
  String get frigateNotifyFor => 'Send notifications for:';

  @override
  String get frigateLabelPerson => 'Person';

  @override
  String get frigateLabelCar => 'Car';

  @override
  String get frigateLabelDog => 'Dog';

  @override
  String get frigateLabelCat => 'Cat';

  @override
  String get frigateLabelMotion => 'Motion';

  @override
  String get frigateSaving => 'Saving...';

  @override
  String get frigateSave => 'Save';

  @override
  String get frigateSettingsSaved => '✅ Settings saved';

  @override
  String get mqttSettingsTitle => 'MQTT settings';

  @override
  String get mqttBrokerTitle => 'MQTT broker';

  @override
  String get mqttUsageHint => 'Used for Zigbee2MQTT and Frigate';

  @override
  String get mqttHostLabel => 'Address (IP or hostname)';

  @override
  String get mqttHostHint => '192.168.43.16';

  @override
  String get mqttPortLabel => 'Port';

  @override
  String get mqttUsernameLabel => 'Username (optional)';

  @override
  String get mqttPasswordLabel => 'Password (optional)';

  @override
  String get mqttHostRequired => 'Enter the broker address';

  @override
  String get mqttConnectionFailed => 'Could not connect to the broker';

  @override
  String mqttConnectionError(String error) {
    return 'Error: $error';
  }

  @override
  String get mqttConnectionSuccess => 'Connection successful';

  @override
  String get mqttConnectionFailureStatus => 'Could not connect';

  @override
  String get mqttConnecting => 'Connecting...';

  @override
  String get mqttSaveAndConnect => 'Save and connect';

  @override
  String get notificationChannelsTitle => 'Notifications';

  @override
  String get notificationVkSubtitle => 'VK notifications';

  @override
  String get notificationSmsSubtitle => 'SMS notifications';

  @override
  String get presenceTitle => 'Presence';

  @override
  String get presenceTrackingEnable => 'Enable presence tracking';

  @override
  String get presenceTrackingSubtitle => 'Determine who is at home';

  @override
  String get presencePhones => 'Phones';

  @override
  String get presenceNoPhones => 'No phones added';

  @override
  String get presenceHomeZone => 'Home zone';

  @override
  String get presenceNotConfigured => 'Not configured';

  @override
  String get presenceRadius => 'Radius';

  @override
  String get presenceAwayTimeout => 'Away timeout';

  @override
  String get presenceHomeWifi => 'Home (Wi-Fi)';

  @override
  String get presenceHeartbeatActive => 'Heartbeat active';

  @override
  String get presenceHomeCloud => 'Home (cloud)';

  @override
  String get presenceWifiInactiveGpsUnavailable =>
      'Wi-Fi inactive · GPS unavailable';

  @override
  String presenceWifiInactiveDistance(String distance) {
    return 'Wi-Fi inactive · $distance from home';
  }

  @override
  String get presenceAway => 'Away';

  @override
  String presenceDistanceFromHome(String distance) {
    return 'Distance: $distance from home';
  }

  @override
  String get presenceUnknown => 'Unknown';

  @override
  String get presenceEditPhone => 'Edit phone';

  @override
  String get presenceAddPhone => 'Add phone';

  @override
  String get presenceName => 'Name';

  @override
  String get presenceNameHint => 'My phone';

  @override
  String get presencePhoneId => 'Phone ID';

  @override
  String get presencePhoneIdHint => '89533309330';

  @override
  String get presenceDelete => 'Delete';

  @override
  String get presenceCancel => 'Cancel';

  @override
  String get presenceSave => 'Save';

  @override
  String get presenceAdd => 'Add';

  @override
  String get presenceLatitude => 'Latitude';

  @override
  String get presenceLongitude => 'Longitude';

  @override
  String get presenceGetCurrentCoordinates => 'Get my coordinates';

  @override
  String get presenceGpsDisabled =>
      '❌ GPS is disabled. Enable it in system settings.';

  @override
  String get presencePermissionTitle => 'Permission required';

  @override
  String get presencePermissionMessage =>
      'GPS permission was permanently denied.\nOpen settings and grant it manually.';

  @override
  String get presenceOpenSettings => 'Open settings';

  @override
  String get presencePermissionNotGranted => '❌ GPS permission was not granted';

  @override
  String get presenceGettingGps =>
      'Getting GPS…\nThis may take up to 60 seconds';

  @override
  String presenceCoordinatesReceived(String latitude, String longitude) {
    return '✅ Coordinates received:\n$latitude, $longitude';
  }

  @override
  String get presenceGpsFailed =>
      '❌ Could not get GPS.\nTry moving to an open area.';

  @override
  String get presenceMeters => 'Meters';

  @override
  String get presenceRadiusHint => '100';

  @override
  String get presenceMinutes => 'Minutes';

  @override
  String get presenceTimeoutHint => '5';

  @override
  String get roomsManageEmpty => 'No rooms. Add your first room!';

  @override
  String roomsDeviceCount(int count) {
    return 'Devices: $count';
  }

  @override
  String get roomsEditDialogTitle => 'Edit room';

  @override
  String get roomsDeleteDialogTitle => 'Delete room?';

  @override
  String roomsDeleteWithDevices(int count) {
    return 'This room has $count devices. They will be moved to “All devices”. Continue?';
  }

  @override
  String roomsDeleteConfirmation(String name) {
    return 'Delete room “$name”?';
  }

  @override
  String get roomsAllDevices => 'All devices';

  @override
  String roomsDeletedMessage(String name) {
    return 'Room “$name” deleted';
  }

  @override
  String get roomIconLiving => 'Living room';

  @override
  String get roomIconBedroom => 'Bedroom';

  @override
  String get roomIconKitchen => 'Kitchen';

  @override
  String get roomIconBathroom => 'Bathroom';

  @override
  String get roomIconGarage => 'Garage';

  @override
  String get roomIconYard => 'Yard';

  @override
  String get roomIconKids => 'Kids\' room';

  @override
  String get roomIconStorage => 'Storage';

  @override
  String get roomIconOffice => 'Office';

  @override
  String get roomIconHome => 'Home';

  @override
  String get roomIconAppliances => 'Appliances';

  @override
  String get roomsDeleteButton => 'Delete';

  @override
  String get scenesTitle => 'Scenes';

  @override
  String get scenesEmpty => 'No scenes. Create your first one!';

  @override
  String get scenesManual => 'Manual';

  @override
  String scenesAutoTriggerMessage(String name) {
    return '⏰ “$name” starts automatically when its trigger fires';
  }

  @override
  String scenesActionCount(int count) {
    return '$count devices';
  }

  @override
  String scenesTimeTemperature(String operator, String threshold) {
    return 'Temp. $operator $threshold°C';
  }

  @override
  String scenesHumidity(String operator, String threshold) {
    return 'Humidity $operator $threshold%';
  }

  @override
  String get scenesWaterLeak => '💧 Water leak';

  @override
  String get scenesMotion => '🏃 Motion';

  @override
  String get scenesContactOpen => '🚪 Open';

  @override
  String get scenesContactClosed => '🚪 Closed';

  @override
  String get scenesSmoke => '🔥 Smoke';

  @override
  String get scenesGas => '💨 Gas';

  @override
  String get scenesPresence => 'Presence';

  @override
  String get scenesSomeoneArrived => 'Someone arrived';

  @override
  String get scenesNobodyHome => 'Nobody is home';

  @override
  String get scenesEveryoneHome => 'Everyone is home';

  @override
  String get scenesPhoneArrived => 'Phone arrived';

  @override
  String get scenesPhoneLeft => 'Phone left';

  @override
  String get scenesPhoneUnknown => 'Phone status unknown';

  @override
  String get scenesEveryDay => 'Every day';

  @override
  String get scenesWeekdays => 'Days of the week';

  @override
  String get scenesInterval => 'Interval';

  @override
  String get scenesMondayShort => 'Mon';

  @override
  String get scenesTuesdayShort => 'Tue';

  @override
  String get scenesWednesdayShort => 'Wed';

  @override
  String get scenesThursdayShort => 'Thu';

  @override
  String get scenesFridayShort => 'Fri';

  @override
  String get scenesSaturdayShort => 'Sat';

  @override
  String get scenesSundayShort => 'Sun';

  @override
  String get scenesActionOn => 'ON';

  @override
  String get scenesActionOff => 'OFF';

  @override
  String get scenesActionBrightness => 'BRIGHT';

  @override
  String get scenesEdit => 'Edit';

  @override
  String get scenesDelete => 'Delete';
}
