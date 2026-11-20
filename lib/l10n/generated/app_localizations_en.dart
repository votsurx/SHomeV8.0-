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
  String get cloudPasswordShow => 'Show password';

  @override
  String get cloudPasswordHide => 'Hide password';

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
  String get eventsFilterPresence => 'Presence';

  @override
  String get eventsFilterDate => 'Period';

  @override
  String get eventsFilterDateAll => 'All time';

  @override
  String get eventsFilterDateToday => 'Today';

  @override
  String get eventsFilterDateYesterday => 'Yesterday';

  @override
  String get eventsFilterDate7Days => 'Last 7 days';

  @override
  String get eventsFilterDate30Days => 'Last 30 days';

  @override
  String get eventsFilterDateCustom => 'Custom range';

  @override
  String get eventsFilterDateFrom => 'From';

  @override
  String get eventsFilterDateTo => 'To';

  @override
  String get eventsFilterDateApply => 'Apply';

  @override
  String get eventsFilterDateReset => 'Reset';

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
  String get sceneEditorTitleNew => 'New scene';

  @override
  String get sceneEditorTitleEdit => 'Edit scene';

  @override
  String get sceneEditorName => 'Name';

  @override
  String get sceneEditorNameHint => 'Turn everything off';

  @override
  String get sceneEditorTriggerType => 'Trigger type';

  @override
  String get sceneEditorTriggerManual => '🎬 Manual';

  @override
  String get sceneEditorTriggerTime => '⏰ By time';

  @override
  String get sceneEditorTriggerSensor => '🌡️ By sensor';

  @override
  String get sceneEditorTriggerPresence => '📍 By presence';

  @override
  String get sceneEditorRepeat => 'Repeat';

  @override
  String get sceneEditorRepeatOnce => 'Once';

  @override
  String get sceneEditorRepeatDaily => 'Every day';

  @override
  String get sceneEditorRepeatWeekly => 'Days of the week';

  @override
  String get sceneEditorDaysOfWeek => 'Days of the week';

  @override
  String get sceneEditorMonday => 'Mon';

  @override
  String get sceneEditorTuesday => 'Tue';

  @override
  String get sceneEditorWednesday => 'Wed';

  @override
  String get sceneEditorThursday => 'Thu';

  @override
  String get sceneEditorFriday => 'Fri';

  @override
  String get sceneEditorSaturday => 'Sat';

  @override
  String get sceneEditorSunday => 'Sun';

  @override
  String get sceneEditorSensor => 'Sensor';

  @override
  String get sceneEditorSelectSensor => 'Select a sensor';

  @override
  String get sceneEditorCondition => 'Condition';

  @override
  String sceneEditorTemperatureAbove(String threshold) {
    return '🌡️ Temperature above $threshold °C';
  }

  @override
  String sceneEditorTemperatureBelow(String threshold) {
    return '🌡️ Temperature below $threshold °C';
  }

  @override
  String sceneEditorHumidityAbove(String threshold) {
    return '💧 Humidity above $threshold%';
  }

  @override
  String sceneEditorHumidityBelow(String threshold) {
    return '💧 Humidity below $threshold%';
  }

  @override
  String get sceneEditorWaterLeak => '💧 Water leak';

  @override
  String get sceneEditorMotion => '🏃 Motion';

  @override
  String get sceneEditorContactOpen => '🚪 Open';

  @override
  String get sceneEditorContactClosed => '🚪 Closed';

  @override
  String get sceneEditorSmoke => '🔥 Smoke';

  @override
  String get sceneEditorGas => '💨 Gas';

  @override
  String get sceneEditorThreshold => 'Threshold';

  @override
  String get sceneEditorPresenceEvent => 'Event';

  @override
  String get sceneEditorSomeoneHome => 'Someone arrived';

  @override
  String get sceneEditorNobodyHome => 'Nobody is home';

  @override
  String get sceneEditorAllHome => 'Everyone is home';

  @override
  String get sceneEditorPhoneArrived => 'Phone arrived';

  @override
  String get sceneEditorPhoneLeft => 'Phone left';

  @override
  String get sceneEditorPhoneUnknown => 'Phone status unknown';

  @override
  String get sceneEditorPhone => 'Phone';

  @override
  String get sceneEditorSelectPhone => 'Select a phone';

  @override
  String get sceneEditorAdvanced => 'Advanced';

  @override
  String get sceneEditorDetectionChannel => 'Detection channel';

  @override
  String get sceneEditorChannelAny => 'Any';

  @override
  String get sceneEditorChannelWifi => 'Wi-Fi only';

  @override
  String get sceneEditorChannelGps => 'GPS only';

  @override
  String get sceneEditorStartDelay => 'Start delay';

  @override
  String get sceneEditorNoDelay => 'No delay';

  @override
  String get sceneEditorMinute => '1 minute';

  @override
  String sceneEditorMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get sceneEditorCooldown => 'Cooldown';

  @override
  String get sceneEditorConfigureConditions => 'Configure conditions';

  @override
  String get sceneEditorConditionsConfigured => 'Conditions configured ✓';

  @override
  String get sceneEditorActions => 'Actions';

  @override
  String get sceneEditorNoDevices => 'No devices';

  @override
  String get sceneEditorActionOn => 'ON';

  @override
  String get sceneEditorActionOff => 'OFF';

  @override
  String get sceneEditorCancel => 'Cancel';

  @override
  String get sceneEditorSave => 'Save';

  @override
  String get sceneEditorCreate => 'Create';

  @override
  String get sceneEditorValidation =>
      '⚠️ Enter a name and select at least one action';

  @override
  String get sceneEditorUpdated => '✅ Scene updated!';

  @override
  String get sceneEditorCreated => '✅ Scene created!';

  @override
  String get sceneEditorConditionsTitle => 'Conditions';

  @override
  String get sceneEditorTimeOfDay => 'Time of day';

  @override
  String sceneEditorFromTime(String time) {
    return 'From $time';
  }

  @override
  String sceneEditorUntilTime(String time) {
    return 'Until $time';
  }

  @override
  String get sceneEditorDaysCondition => 'Days of the week';

  @override
  String get sceneEditorReset => 'Reset';

  @override
  String get scenesTitle => 'Scenes';

  @override
  String get scenesEmpty => 'No scenes. Create your first one!';

  @override
  String scenesAutoTriggerMessage(String name) {
    return '⏰ Scene “$name” starts automatically when its trigger fires';
  }

  @override
  String get sceneEditorActionBrightness => 'BRIGHT';

  @override
  String get sceneEditorDeviceUnitShort => 'devices';

  @override
  String get scenesPresence => 'Presence';

  @override
  String get scenesDeviceFallback => 'Device';

  @override
  String get scenesEdit => 'Edit';

  @override
  String get scenesDelete => 'Delete';

  @override
  String get screenSaverTitle => 'Screensaver';

  @override
  String get screenSaverSubtitle =>
      'Show the animated screensaver after inactivity';

  @override
  String get screenSaverMotionWakeTitle => 'Dismiss screensaver on motion';

  @override
  String get screenSaverMotionWakeSubtitle =>
      'Use the front camera while the screensaver is visible';

  @override
  String screenSaverSensitivity(int value) {
    return 'Sensitivity: $value%';
  }

  @override
  String get screenSaverSensitivityLow => 'Low';

  @override
  String get screenSaverSensitivityHigh => 'High';

  @override
  String get screenSaverSensitivityHint =>
      'If the screensaver dismisses without movement, lower the sensitivity.';

  @override
  String get screenSaverTimeoutTitle => 'Inactivity time before screensaver';

  @override
  String get screenSaverChoose => 'Choose';

  @override
  String get screenSaverTimeout30 => '30 seconds';

  @override
  String get screenSaverTimeout60 => '1 minute';

  @override
  String get screenSaverTimeout120 => '2 minutes';

  @override
  String get screenSaverTimeout300 => '5 minutes';

  @override
  String get screenSaverTimeout600 => '10 minutes';

  @override
  String screenSaverTimeoutSeconds(int value) {
    return '$value seconds';
  }

  @override
  String get settingsPollInterval => 'Polling interval';

  @override
  String settingsIntervalSeconds(int value) {
    return '$value sec';
  }

  @override
  String settingsIntervalMinutes(int value) {
    return '$value min';
  }

  @override
  String settingsPollIntervalChanged(String interval) {
    return 'Polling interval changed to $interval. Restart the app.';
  }

  @override
  String get settingsEventsRetention => 'Event retention';

  @override
  String settingsDays(int value) {
    return '$value days';
  }

  @override
  String get settingsElectricityTariff => 'Electricity tariff';

  @override
  String settingsCurrencyPerKwh(String value) {
    return '$value ₽/kWh';
  }

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupSubtitle => 'Export / Import';

  @override
  String get settingsMqtt => 'MQTT settings';

  @override
  String get settingsMqttSubtitle => 'Broker for Zigbee2MQTT';

  @override
  String get settingsCheckUpdates => 'Check for updates';

  @override
  String get settingsCheckUpdatesSubtitle =>
      'Check whether a new version is available';

  @override
  String get settingsInformation => 'Information';

  @override
  String get settingsInformationSubtitle => 'Licenses and agreements';

  @override
  String get settingsExportReady => '✅ Configuration is ready to share';

  @override
  String settingsError(String error) {
    return '❌ Error: $error';
  }

  @override
  String get settingsImportDone => '✅ Import completed';

  @override
  String get settingsImportRestartHint =>
      'Data restored.\n\nRestarting the app is recommended to apply all settings (VK, cloud, and devices).';

  @override
  String get settingsLater => 'Later';

  @override
  String get settingsRestart => 'Restart';

  @override
  String get settingsBackupDialogTitle => 'Backup';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsExportSubtitle => 'Share via cloud, email, or Telegram';

  @override
  String get settingsImport => 'Import';

  @override
  String get settingsImportSubtitle =>
      'Choose a file on this device or in the cloud';

  @override
  String get settingsRetentionDialogTitle => 'Event retention';

  @override
  String settingsRetentionDays(int value) {
    return '$value days';
  }

  @override
  String get settingsTariffDialogTitle => 'Tariff ₽/kWh';

  @override
  String get settingsTariffInvalid => 'Enter a valid tariff greater than zero';

  @override
  String get settingsTariffHint => '5.5';

  @override
  String get smsSettingsTitle => 'SMS notifications';

  @override
  String get smsSettingsEnable => 'Enable SMS';

  @override
  String get smsSettingsEnableSubtitle => 'Send notifications by SMS';

  @override
  String get smsSettingsPhoneNumbers => 'Phone numbers';

  @override
  String get smsSettingsNoPhones => 'No phone numbers added';

  @override
  String get smsSettingsEventsTitle => 'Events sent by SMS';

  @override
  String get smsSettingsScenes => 'Scenes';

  @override
  String get smsSettingsDevices => 'Devices';

  @override
  String get smsSettingsAlarms => 'Alerts';

  @override
  String get smsSettingsZigbeeWaterLeak => 'Zigbee: 💧 Water leak';

  @override
  String get smsSettingsZigbeeSmoke => 'Zigbee: 🔥 Smoke';

  @override
  String get smsSettingsZigbeeGas => 'Zigbee: 💨 Gas';

  @override
  String get smsSettingsZigbeeMotion => 'Zigbee: 🏃 Motion';

  @override
  String get smsSettingsZigbeeContact => 'Zigbee: 🚪 Contact';

  @override
  String get smsSettingsFrigatePerson => 'Frigate: 🚶 Person';

  @override
  String get smsSettingsFrigateCar => 'Frigate: 🚗 Car';

  @override
  String get smsSettingsErrors => 'Errors';

  @override
  String get smsSettingsZigbeeOffline => 'Zigbee offline';

  @override
  String get smsSettingsZigbeeOfflineSubtitle => 'Device lost connection';

  @override
  String get smsSettingsFrigateOffline => 'Frigate offline';

  @override
  String get smsSettingsFrigateOfflineSubtitle => 'Frigate is unavailable';

  @override
  String get smsSettingsCooldown => 'SMS cooldown';

  @override
  String get smsSettingsOneMinute => '1 minute';

  @override
  String smsSettingsMinutes(int count) {
    return '$count minutes';
  }

  @override
  String get smsSettingsSchedule => 'Schedule';

  @override
  String get smsSettingsScheduleSubtitle =>
      'Send only during the specified time';

  @override
  String get smsSettingsAlarmsOutsideSchedule => 'Alerts outside the schedule';

  @override
  String get smsSettingsStartTime => 'Start time';

  @override
  String get smsSettingsEndTime => 'End time';

  @override
  String get smsSettingsDaysOfWeek => 'Days of the week:';

  @override
  String get smsSettingsMonday => 'Mon';

  @override
  String get smsSettingsTuesday => 'Tue';

  @override
  String get smsSettingsWednesday => 'Wed';

  @override
  String get smsSettingsThursday => 'Thu';

  @override
  String get smsSettingsFriday => 'Fri';

  @override
  String get smsSettingsSaturday => 'Sat';

  @override
  String get smsSettingsSunday => 'Sun';

  @override
  String get smsSettingsAddPhoneRequired => 'Add at least one phone number';

  @override
  String get smsSettingsSendTest => 'Send test SMS';

  @override
  String get smsSettingsTestMessage => '✅ Test SMS from SHome!';

  @override
  String get smsSettingsAddPhoneTitle => 'Add phone number';

  @override
  String get smsSettingsNameOptional => 'Name (optional)';

  @override
  String get smsSettingsNameHint => 'My phone';

  @override
  String get smsSettingsPhoneLabel => 'Phone number';

  @override
  String get smsSettingsPhoneHint => '+19995550123';

  @override
  String get smsSettingsCancel => 'Cancel';

  @override
  String get smsSettingsAdd => 'Add';

  @override
  String get smsSettingsDelete => 'Delete';

  @override
  String get timersTitle => 'Timers';

  @override
  String get timersEmpty => 'No active timers';

  @override
  String get timersAlreadyFired => 'Already fired';

  @override
  String get timersLessThanMinute => 'less than a minute';

  @override
  String get timersTurnOn => 'Will turn on';

  @override
  String get timersTurnOff => 'Will turn off';

  @override
  String timersCountdownMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String timersCountdownHoursMinutes(int hours, int minutes) {
    return 'in $hours h $minutes min';
  }

  @override
  String timersTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String get timersNewTitle => 'New timer';

  @override
  String get timersDeviceLabel => 'Device';

  @override
  String get timersCommandOff => 'OFF';

  @override
  String get timersCommandOn => 'ON';

  @override
  String get timersCancel => 'Cancel';

  @override
  String get timersCreate => 'Create';

  @override
  String get timersDeleteTooltip => 'Delete timer';

  @override
  String get vkSettingsTitle => 'VK Bot';

  @override
  String get vkSettingsEnable => 'Enable VK';

  @override
  String get vkSettingsEnableSubtitle => 'Send notifications to VK';

  @override
  String get vkSettingsTokenLabel => 'VK Token';

  @override
  String get vkSettingsTokenHint => 'Paste the bot token';

  @override
  String get vkSettingsUserIdLabel => 'VK User ID';

  @override
  String get vkSettingsUserIdHint => 'For example, 123456789';

  @override
  String get vkSettingsEvents => 'Events';

  @override
  String get vkSettingsScenes => 'Scenes';

  @override
  String get vkSettingsScenesSubtitle => 'Notifications when scenes run';

  @override
  String get vkSettingsDevices => 'Devices';

  @override
  String get vkSettingsDevicesSubtitle => 'Device state changes';

  @override
  String get vkSettingsAlarms => 'Alerts';

  @override
  String get vkSettingsZigbeeWaterLeak => 'Zigbee: 💧 Water leak';

  @override
  String get vkSettingsZigbeeSmoke => 'Zigbee: 🔥 Smoke';

  @override
  String get vkSettingsZigbeeGas => 'Zigbee: 💨 Gas';

  @override
  String get vkSettingsZigbeeMotion => 'Zigbee: 🏃 Motion';

  @override
  String get vkSettingsZigbeeContact => 'Zigbee: 🚪 Contact';

  @override
  String get vkSettingsFrigatePerson => 'Frigate: 🚶 Person';

  @override
  String get vkSettingsFrigateCar => 'Frigate: 🚗 Car';

  @override
  String get vkSettingsErrors => 'Errors';

  @override
  String get vkSettingsZigbeeOffline => 'Zigbee offline';

  @override
  String get vkSettingsZigbeeOfflineSubtitle => 'Device lost connection';

  @override
  String get vkSettingsFrigateOffline => 'Frigate offline';

  @override
  String get vkSettingsFrigateOfflineSubtitle => 'Frigate is unavailable';

  @override
  String get vkSettingsCooldown => 'VK cooldown';

  @override
  String get vkSettingsCooldown1 => '1 minute';

  @override
  String get vkSettingsCooldown5 => '5 minutes';

  @override
  String get vkSettingsCooldown15 => '15 minutes';

  @override
  String get vkSettingsCooldown30 => '30 minutes';

  @override
  String get vkSettingsSchedule => 'Schedule';

  @override
  String get vkSettingsScheduleSubtitle =>
      'Send only during the specified time';

  @override
  String get vkSettingsAlarmsOutsideSchedule => 'Alerts outside the schedule';

  @override
  String get vkSettingsAlarmsAlways => 'Always send alerts';

  @override
  String get vkSettingsStartTime => 'Start time';

  @override
  String get vkSettingsEndTime => 'End time';

  @override
  String get vkSettingsDaysOfWeek => 'Days of the week:';

  @override
  String get vkSettingsMonday => 'Mon';

  @override
  String get vkSettingsTuesday => 'Tue';

  @override
  String get vkSettingsWednesday => 'Wed';

  @override
  String get vkSettingsThursday => 'Thu';

  @override
  String get vkSettingsFriday => 'Fri';

  @override
  String get vkSettingsSaturday => 'Sat';

  @override
  String get vkSettingsSunday => 'Sun';

  @override
  String get vkSettingsSendTest => 'Send test VK message';

  @override
  String get vkSettingsTestMessage => '✅ Test notification from SHome!';

  @override
  String get zigbeeScanTitle => 'Zigbee';

  @override
  String get zigbeeRefresh => 'Refresh';

  @override
  String zigbeeStopPairing(int seconds) {
    return 'Stop pairing ($seconds sec)';
  }

  @override
  String get zigbeeOpenPairing => 'Open network for pairing';

  @override
  String get zigbeePairingInstruction =>
      'Press and hold the button on the device for 5 seconds';

  @override
  String get zigbeeNoDevices =>
      'No devices found.\nTap “Open network” and add a device.';

  @override
  String zigbeeDeviceAdded(String name) {
    return '✅ $name added';
  }

  @override
  String get changelogTitle => 'Changelog';

  @override
  String get changelogLoadError => 'Could not load the changelog';

  @override
  String get eulaTitle => 'License Agreement';

  @override
  String get legalInfoTitle => 'Information';

  @override
  String legalDeveloperLabel(String name) {
    return 'Developer: $name';
  }

  @override
  String legalOwnerLabel(String name) {
    return 'Owner: $name';
  }

  @override
  String legalVersionLabel(String version) {
    return 'Version: $version';
  }

  @override
  String get legalEulaTitle => 'End User License Agreement (EULA)';

  @override
  String get legalEulaSubtitle => 'Terms for using the application';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalPrivacySubtitle => 'How we process your data';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalTermsSubtitle => 'Rules and restrictions';

  @override
  String get legalOpenSourceTitle => 'Open-source licenses';

  @override
  String get legalOpenSourceSubtitle => 'Third-party libraries';

  @override
  String get legalChangelogTitle => 'Changelog';

  @override
  String get legalChangelogSubtitle => 'What\'s new in each version';

  @override
  String legalVersionFooter(String version) {
    return 'Version $version';
  }

  @override
  String get statsPeriod24h => '24h';

  @override
  String get statsPeriod7d => '7d';

  @override
  String get statsPeriod30d => '30d';

  @override
  String get statsNoClimateData => 'No sensor data for this period';

  @override
  String get statsClimateByDevice => 'Climate by device';

  @override
  String statsSampleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count samples',
      one: '$count sample',
      zero: 'No samples',
    );
    return '$_temp0';
  }

  @override
  String statsTemperatureSummary(String min, String max, String average) {
    return '🌡️ $min° … $max° (avg: $average°)';
  }

  @override
  String statsHumiditySummary(String min, String max, String average) {
    return '💧 $min% … $max% (avg: $average%)';
  }

  @override
  String get statsNoDeviceDataPeriod => 'No data for this period';

  @override
  String statsDeviceEventCounts(int offline, int alerts, int actions) {
    return 'Offline: $offline · alerts: $alerts · actions: $actions';
  }

  @override
  String statsAlertsForDays(int days) {
    return 'Alerts in the last $days days';
  }

  @override
  String statsOfflineForDays(int days) {
    return 'Offline in the last $days days';
  }

  @override
  String get statsEnergyConsumption => 'Consumption';

  @override
  String get statsEnergyCost => 'Cost';

  @override
  String statsEnergyPeriod(int days) {
    return 'for $days days';
  }

  @override
  String statsEnergyTariff(String tariff) {
    return 'rate $tariff RUB/kWh';
  }

  @override
  String statsEnergyRubles(String value) {
    return '$value RUB';
  }

  @override
  String statsEnergyKwh(String value) {
    return '$value kWh';
  }

  @override
  String get statsEnergyNoData => 'No energy consumption data for this period';

  @override
  String get statsEnergyByDevice => 'By device';

  @override
  String get statsNotificationsEmpty => 'No notifications for this period';

  @override
  String get statsNotificationsSent => 'Sent';

  @override
  String get statsNotificationsSuppressed => 'Suppressed';

  @override
  String statsNotificationsPeriod(int days) {
    return 'for $days days';
  }

  @override
  String statsNotificationsCooldownPercent(int percent) {
    return 'cooldown ($percent%)';
  }

  @override
  String get statsNotificationsByChannel => 'By channel';

  @override
  String statsNotificationsChannelSuppressed(int count) {
    return 'Suppressed: $count';
  }

  @override
  String get statsNotificationsByCategory => 'By category';

  @override
  String get statsNotificationsCategoryWaterLeak => '💧 Water leak';

  @override
  String get statsNotificationsCategorySmoke => '🔥 Smoke';

  @override
  String get statsNotificationsCategoryGas => '💨 Gas';

  @override
  String get statsNotificationsCategoryMotion => '🏃 Motion';

  @override
  String get statsNotificationsCategoryContact => '🚪 Contact';

  @override
  String get statsNotificationsCategoryPerson => '🎥 Person';

  @override
  String get statsNotificationsCategoryCar => '🎥 Car';

  @override
  String get statsNotificationsCategoryOffline => '📡 Offline';

  @override
  String get statsNotificationsCategoryLowBattery => '🔋 Battery';

  @override
  String get statsNotificationsCategoryStateChanged => '🎛 State';

  @override
  String get statsNotificationsCategoryUnknown => 'Other';

  @override
  String get statsOverviewAlerts => 'Alerts';

  @override
  String get statsOverviewActions => 'Actions';

  @override
  String get statsOverviewOffline => 'Offline';

  @override
  String get statsOverviewOnline => 'Online';

  @override
  String statsOverviewPeriod(int days) {
    return 'for $days days';
  }

  @override
  String get statsOverviewWorstDevices => 'Devices with issues';

  @override
  String get statsOverviewNoProblems =>
      'No devices with issues during this period 👍';

  @override
  String get statsPresenceEmpty => 'No presence data for this period';

  @override
  String get statsPresenceHome => 'At home';

  @override
  String get statsPresenceNear => 'Nearby';

  @override
  String get statsPresenceAway => 'Away';

  @override
  String get statsPresenceUnknown => 'Unknown';

  @override
  String statsPresencePeriod(int days) {
    return 'for $days days';
  }

  @override
  String get statsPresenceCloudFallback => 'Cloud fallback';

  @override
  String get statsPresenceCloudFallbackSubtitle =>
      'Number of heartbeat failures';

  @override
  String get statsPresenceDurationZero => '0';

  @override
  String statsPresenceDurationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String statsPresenceDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get statsPresenceDurationLessMinute => 'less than a minute';

  @override
  String get statsScenesTop => 'Top scenes';

  @override
  String statsScenesRuns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# runs',
      one: '# run',
      zero: 'No runs',
    );
    return '$_temp0';
  }

  @override
  String get statsScenesNoRunsPeriod => 'No scene runs during this period';

  @override
  String get statsScenesForgottenTitle => 'Unused scenes (0 runs)';

  @override
  String get statsScenesDeleteCandidate => 'Candidate for removal';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsTabOverview => 'Overview';

  @override
  String get statsTabDevices => 'Devices';

  @override
  String get statsTabEnergy => 'Energy';

  @override
  String get statsTabVideo => 'Video';

  @override
  String get statsTabScenes => 'Scenes';

  @override
  String get statsTabPresence => 'Presence';

  @override
  String get statsTabClimate => 'Climate';

  @override
  String get statsTabNotifications => 'Notifications';

  @override
  String get statsVideoEmpty => 'No detections for this period';

  @override
  String get statsVideoByTypes => 'By type';

  @override
  String get statsVideoByCameras => 'By camera';

  @override
  String get statsVideoActivityByHour => 'Activity by hour';

  @override
  String get statsVideoHeatmapHint =>
      'More intense color means more detections';

  @override
  String get statsVideoLabelPerson => 'Person';

  @override
  String get statsVideoLabelCar => 'Car';

  @override
  String get statsVideoLabelDog => 'Dog';

  @override
  String get statsVideoLabelCat => 'Cat';

  @override
  String get statsVideoLabelBird => 'Bird';

  @override
  String get statsVideoLabelMotorcycle => 'Motorcycle';

  @override
  String get statsVideoLabelBicycle => 'Bicycle';

  @override
  String get statsVideoLabelTruck => 'Truck';

  @override
  String get statsVideoLabelBus => 'Bus';

  @override
  String get statsVideoLabelBoat => 'Boat';

  @override
  String get deviceCardWaterLeak => 'Water leak';

  @override
  String get deviceCardMotion => 'Motion';

  @override
  String get deviceCardContactOpen => 'Open';

  @override
  String get deviceSettingsName => 'Name';

  @override
  String get deviceSettingsRoom => 'Room';

  @override
  String get deviceSettingsRtspUrl => 'RTSP URL';

  @override
  String get deviceSettingsZigbeeDevice => 'Zigbee device';

  @override
  String get deviceSettingsIeeeAddress => 'IEEE address';

  @override
  String get deviceSettingsModel => 'Model';

  @override
  String get deviceSettingsVendor => 'Manufacturer';

  @override
  String get deviceSettingsBattery => 'Battery';

  @override
  String get deviceSettingsLinkQuality => 'Link quality';

  @override
  String get deviceSettingsNotifications => 'Notifications';

  @override
  String get deviceSettingsDeviceId => 'Device ID';

  @override
  String get deviceSettingsIpAddress => 'IP address';

  @override
  String get deviceSettingsLocalKey => 'Local Key';

  @override
  String get deviceSettingsProtocolVersion => 'Protocol version';

  @override
  String get deviceSettingsChannels => 'Channels';

  @override
  String get deviceSettingsDpsIndex => 'DPS index';

  @override
  String get deviceSettingsDpsMap => 'DPS map';

  @override
  String get deviceSettingsAddDps => 'Add DPS';

  @override
  String get deviceSettingsDisplayOnCard => 'Card display';

  @override
  String get deviceSettingsDisplayHint =>
      'Choose which data to show on the main screen';

  @override
  String get deviceSettingsNoInfoParameters => 'No informational parameters';

  @override
  String get deviceSettingsDeleteTitle => 'Delete device?';

  @override
  String deviceSettingsDeleteMessage(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get deviceSettingsDelete => 'Delete';

  @override
  String get deviceSettingsSave => 'Save';

  @override
  String get deviceSettingsCancel => 'Cancel';

  @override
  String get deviceSettingsCreateSensor => 'Create sensor';

  @override
  String deviceSettingsSensorFromDevice(String name) {
    return 'From device: $name';
  }

  @override
  String get deviceSettingsSensorType => 'Sensor type';

  @override
  String get deviceSettingsTemperature => 'Temperature';

  @override
  String get deviceSettingsHumidity => 'Humidity';

  @override
  String get deviceSettingsPower => 'Power';

  @override
  String get deviceSettingsCurrent => 'Current';

  @override
  String get deviceSettingsVoltage => 'Voltage';

  @override
  String get deviceSettingsDivider => 'Divisor';

  @override
  String deviceSettingsSensorCreated(String name) {
    return '✅ Sensor “$name” created!';
  }

  @override
  String get deviceSettingsChannel => 'Channel';

  @override
  String get deviceSettingsChannelNumber => 'Channel number';

  @override
  String get deviceSettingsDpsAddTitle => 'Add DPS';

  @override
  String deviceSettingsDpsEditTitle(String key) {
    return 'Edit DPS $key';
  }

  @override
  String get deviceSettingsDpsNumber => 'DPS number';

  @override
  String get deviceSettingsDpsType => 'Type';

  @override
  String get deviceSettingsDpsRole => 'Role';

  @override
  String get deviceSettingsDpsIcon => 'Icon';

  @override
  String get deviceSettingsNoIcon => 'No icon';

  @override
  String get deviceSettingsRoleChannel => 'Channel';

  @override
  String get deviceSettingsRoleMain => 'Main button';

  @override
  String get deviceSettingsRoleAction => 'Action';

  @override
  String get deviceSettingsRoleToggle => 'Toggle';

  @override
  String get deviceSettingsRoleInfo => 'Information';

  @override
  String get deviceSettingsRoleStatus => 'Status';

  @override
  String get deviceSettingsRoleEnum => 'Dropdown';

  @override
  String get deviceSettingsRoleSlider => 'Slider';

  @override
  String get deviceSettingsDpsChannelTitle => 'Channel';

  @override
  String get deviceSettingsNotifyAlways => 'Always';

  @override
  String get deviceSettingsNotifyAway => 'When nobody is home';

  @override
  String get deviceSettingsNotifyNight => 'At night';

  @override
  String get deviceSettingsNotifyAwayOrNight =>
      'When nobody is home OR at night';

  @override
  String deviceSettingsNotifySummary(int count, String condition) {
    return '$count types · $condition';
  }

  @override
  String get deviceSettingsTypeBool => 'on/off';

  @override
  String get deviceSettingsTypeValue => 'number';

  @override
  String get deviceSettingsTypeEnum => 'text list';

  @override
  String get deviceSettingsTypeSlider => 'slider';

  @override
  String get deviceSettingsIconNone => 'No icon';

  @override
  String get deviceSettingsIconPlayStop => 'Play/Stop';

  @override
  String get deviceSettingsIconHomeBase => 'Home/Base';

  @override
  String get deviceSettingsIconPower => 'Power';

  @override
  String get deviceSettingsIconWater => 'Water';

  @override
  String get deviceSettingsIconMop => 'Mopping';

  @override
  String get deviceSettingsIconDoNotDisturb => 'Do not disturb';

  @override
  String get deviceSettingsIconBattery => 'Battery';

  @override
  String get deviceSettingsIconTimer => 'Timer';

  @override
  String get deviceSettingsIconArea => 'Area';

  @override
  String get deviceSettingsIconFan => 'Fan';

  @override
  String get deviceSettingsIconCooling => 'Cooling';

  @override
  String get deviceSettingsIconHeating => 'Heating';

  @override
  String get deviceSettingsIconDrying => 'Drying';

  @override
  String get deviceSettingsIconAuto => 'Auto';

  @override
  String get deviceSettingsIconSleep => 'Sleep';

  @override
  String get deviceSettingsIconVerticalBlinds => 'Vertical blinds';

  @override
  String get deviceSettingsIconHorizontalBlinds => 'Horizontal blinds';

  @override
  String get deviceSettingsIconAirQuality => 'Air quality';

  @override
  String get deviceSettingsIconFilter => 'Filter';

  @override
  String get deviceSettingsIconTemperature => 'Temperature';

  @override
  String get deviceSettingsIconAirConditioner => 'Air conditioner';

  @override
  String get deviceSettingsIconHeater => 'Heater';

  @override
  String get deviceSettingsIconAir => 'Air';

  @override
  String get deviceSettingsIconSuction => 'Suction';

  @override
  String get deviceSettingsIconWaiting => 'Waiting';

  @override
  String get deviceSettingsIconSynchronization => 'Synchronization';

  @override
  String deviceSettingsDefaultChannelLabel(String key) {
    return 'Channel $key';
  }

  @override
  String get deviceSettingsAdd => 'Add';

  @override
  String get deviceSettingsCreate => 'Create';

  @override
  String get todayDrawerToday => 'Today';

  @override
  String get menuResetOrderTitle => 'Reset order';

  @override
  String get menuResetOrderBody => 'Tiles will return to their default order.';

  @override
  String get menuResetOrderConfirm => 'Reset';

  @override
  String get settingsResetOrderTitle => 'Reset order';

  @override
  String get settingsResetOrderBody =>
      'Rows will return to their default order.';

  @override
  String get settingsResetOrderConfirm => 'Reset';

  @override
  String get updateJournalSource => 'Update';

  @override
  String get updateCheckFailed => 'Couldn\'t check for updates';

  @override
  String updateCheckError(String error) {
    return 'Update check failed: $error';
  }

  @override
  String get updateNoUpdatesTitle => 'No updates';

  @override
  String get updateNoUpdatesMessage =>
      'You have the latest version of SHome installed.';

  @override
  String get updateOk => 'OK';

  @override
  String updateDialogTitle(String version) {
    return 'Update $version';
  }

  @override
  String get updateWhatsNew => 'What\'s new:';

  @override
  String get updateAvailable => 'A new version of the app is available.';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownloading => 'Downloading update...';

  @override
  String get updateButton => 'Update';

  @override
  String get updateDownloadFailed => 'Download failed';

  @override
  String updateDownloadError(String version) {
    return 'Couldn\'t download the APK for version $version';
  }

  @override
  String updateInstallFailed(String error) {
    return 'Installation error: $error';
  }

  @override
  String updateInstallError(String version, String error) {
    return 'Couldn\'t open the installer for version $version: $error';
  }

  @override
  String get updateInstalledHint => 'After installation, open SHome manually';

  @override
  String get updateCancel => 'Cancel';

  @override
  String get updateCancelling => 'Cancelling...';

  @override
  String get updateDownloadCancelled => 'Download cancelled';
}
