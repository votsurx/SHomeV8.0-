# История изменений SHome

## [8.1.48] — 2026-11-13

### Added
- EventLogger для Zigbee alerts / availability / Frigate
- events_screen.dart — иконки, цвета, чипсы (Все/Алерты/Действия/Ошибки) + dropdown по устройствам
- notification_coordinator.dart — единая логика уведомлений (Singleton)
- device_notifications_screen.dart: notify_condition, notify_types, notify_cooldown_min (per-device)
- Кнопка 🔔 Уведомления в DeviceSettings (Zigbee) + FrigateCameraSettings
- Маршрут `/device_notifications?id=...`
- Per-channel уведомления VK/SMS (water_leak, smoke, gas, motion, contact, person, car, offline)
- vkCooldownMin / smsCooldownMin — антидребезг отдельно для VK/SMS
- globalContainer вынесен в lib/di/global_container.dart
- adaptive_poller.dart — Tuya offline + thresholds для датчиков

### Changed
- devices_provider.dart использует NotificationCoordinator
- SMS default — только критичное (water_leak, smoke, gas)
- flutter_secure_storage 9.2.4 → 11.2.0 (device_key_* восстановлены из бекапа)

### Fixed
- Frigate: дубликаты камер, удаление обеих, roomId → name
- Frigate: настройки камеры (bottom sheet) + шестерёнка на карточке
- Zigbee: availability (Wi-Fi иконка), onState → isOnline: true
- Zigbee-датчики в сценах (были только Tuya)

### Removed
- Локальный автобекап облака
- autoSync() из MailruCloudService (мёртвый код)

## v8.1.47 — Frigate UX + Zigbee Availability

### 🐛 Исправления
- **Frigate камеры** — убрана кнопка «Добавить камеру», только «+» на карточках
- **Дубликаты Frigate** — добавленные камеры **исчезают** из «Доступные», проверка перед добавлением
- **Удаление Frigate** — удаляется только одна камера (не обе)
- **Комната Frigate** — отображается **название**, не UUID (`🛋️ Гостиная` вместо `41f9f40b-...`)
- **Настройки Frigate-камеры** — полный диалог:
  - Название (редактирование)
  - Комната (dropdown, без дубликата `'other'`)
  - Уведомления (labels: person, car, dog, cat, bird, motorcycle, bicycle, truck, bus, boat)
  - Snapshot interval (5/10/30 сек)
  - RTSP порт (по умолчанию 8554)
  - Удаление с подтверждением
- **Шестерёнка** на `FrigateCameraCard` → `FrigateCameraSettings.show()`
- **Auto-restart** таймера при изменении `snapshot_interval`

### 🐝 Zigbee
- **Availability** — подписка на `zigbee2mqtt/+/availability`
- **`isOnline`** — обновляется при получении state (`isOnline: true`)
- **`availability`** — обновляет `isOnline` при `online`/`offline` от Zigbee2MQTT
- **Wi-Fi иконка** — корректно отражает реальный статус Zigbee-устройства

### ☁️ Облако
- **Автосинхронизация** отключена (была при сворачивании приложения)
- **Ручная загрузка** через «Облако → Загрузить в облако»
- **UI** — убрана карточка «🔄 Автосинхронизация»

### 🔧 versionCode
- `versionCode` = 80147

## v8.1.46 — AGP 9 + Built-in Kotlin

> Миграция инструментов сборки на актуальные версии. Цель — убрать
> предупреждение Flutter о Kotlin Gradle Plugin (KGP) и подготовить
> проект к будущим версиям Flutter, где KGP в приложении запрещён.
> Функционал приложения не менялся, но обновлены мажорные версии
> нескольких плагинов (file_picker, share_plus, secure_storage и др.).

### 🔧 Сборка
- **Flutter** 3.44.0 → **3.50.0**
- **Gradle** 8.14 → **9.6.0**
- **AGP** 8.11.1 → **9.3.1**
- **KGP** в `app/build.gradle.kts` **удалён**, включён **Built-in Kotlin** (`android.builtInKotlin=true`, `android.newDsl=false`)
- Предупреждение `applies the Kotlin Gradle Plugin, which will cause build failures` — **исчезло**

### 📦 Обновления зависимостей
- **`win32`** 5.15.0 → **6.4.0** (ключевое условие для AGP 9)
- **`file_picker`** 8.3.7 → **13.3.3** — новый API: `FilePicker.pickFile()` + `PlatformFile.readAsBytes()` (вместо `FilePickerResult` и `File.readAsString`)
- **`share_plus`** 10.1.4 → **13.3.1** — новый API: `SharePlus.instance.share(ShareParams(...))` (вместо `Share.shareXFiles`)
- **`flutter_secure_storage`** 9.2.4 → **11.2.0** — удалён `AndroidOptions(encryptedSharedPreferences: true)` (бэкенд Jetpack Security больше не поддерживается)
- **`network_info_plus`** 6.1.4 → **8.2.2**
- **`package_info_plus`** 9.0.1 → **10.2.2**
- **`talker_flutter`** / **`talker`** / **`talker_logger`** 4.x → **5.2.0**
- **`github_release_apk_updater`** 1.0.5 → **1.0.11** (AGP 9-совместимость)
- **`flutter_vlc_player`** 7.4.4 — **удалён** (мёртвая зависимость, в коде не использовался; тянул ~124 MB нативных VLC-библиотек)

### 🛠️ Технические
- `pubspec.yaml`: добавлен `dependency_overrides: dbus: ^0.8.0` — обход конфликта `geolocator_linux` ↔ `network_info_plus 8.x`
- `config_service.dart`: `importConfig` переписан под `file_picker 13.x`; `exportConfig` — под `share_plus 13.x`
- `encrypted_keys.dart`: убран `AndroidOptions(encryptedSharedPreferences: true)`
- `settings_screen_test.dart`: устаревший тест «NVR/MyiSpy» заменён на актуальный «основные пункты настроек»

### 📉 Размер APK
- Release APK: **198.6 MB → 71.1 MB** (после удаления `flutter_vlc_player` и VLC-библиотек)

### ✅ Проверено
- Debug-сборка — проходит
- Release-сборка — проходит (`app-release.apk`, 71.1 MB)
- Тесты — **45/45 passed**
- Приложение запускается на устройстве (BNE LX1)

### 🔧 versionCode
- `versionCode` = 80146

### 📝 Осталось на потом
- `package:flutter/material.dart` → `material_ui` (80 `info`-предупреждений, не блокирует сборку)
- Мажорные обновления `riverpod 2→3`, `go_router 14→18`, `freezed 2→4` — отдельная задача
- `sqlite3_flutter_libs 0.6.0+eol` — пакет EOL, стоит заменить

## v8.1.44 — Local HTTP Heartbeat

### 🎯 Новая функция: локальный heartbeat

- **HTTP-сервер в SHome** на порту 7777
  - `POST /heartbeat?phoneId=xxx` — приём heartbeat от Companion
  - `GET /status?phoneId=xxx` — запрос текущего статуса
  - `GET /ping` — health check
  - Автоочистка устаревших записей (90 сек)
- **Companion → SHome** каждые 30 сек (без облака!)
- **SHome читает локальный heartbeat первым** — 0 запросов в облако пока дома
- **Fallback на Mail.ru Cloud** — если heartbeat старше 90 сек
- **`unknown` ≠ `away`** — правильная семантика статусов
- **Автоостановка сервера** при закрытии приложения

### 🔧 Технические
- Новый файл: `lib/data/services/heartbeat_server.dart`
- Обновлён: `lib/main.dart` (запуск/остановка сервера)
- Обновлён: `lib/data/services/presence_detector.dart` (чтение heartbeat)

### 🔒 Безопасность
- Companion получает VK User ID из SecureStorage (уже было)
- Cloud credentials в SecureStorage (уже было)

### 🔧 versionCode
- `versionCode` = 80142

## v8.1.41
### 🐛 Исправления
- **VK User ID** больше не пропадает при пересборке экрана
- **VK-токен** — та же защита от потери ввода
- `VkSettingsScreen` переведён в `ConsumerStatefulWidget` (контроллеры живут всё время экрана)
- Добавлена кнопка **«Сохранить VK»** — явное сохранение токена и userId
- `onChanged` → `onSubmitted` + `onEditingComplete` (без записи на каждый символ)
- Добавлено логирование в `ConfigService.restoreFromJson()` — теперь видно, если что-то не сохранилось при импорте

### 🔧 versionCode
- `versionCode` = 80141

## v8.1.40 — Security & Cleanup Release

> Большой релиз с закрытием критичных дыр безопасности,
> упрощением архитектуры и чисткой мёртвого кода.
> Кодовая база та же, что в v8.1.38 + v8.1.39 — этот релиз
> содержит корректное описание всех изменений за период.

### 🔐 Безопасность
- **Tuya `localKey`** перенесён из SQLite (plaintext) в **Android Keystore** (AES-256)
  - В БД теперь только ссылка вида `sec:<uuid>`
  - Автомиграция старых ключей при первом запуске
- **VK-токен** перенесён из SharedPreferences в SecureStorage
- **VK `user_id`** перенесён в SecureStorage
- **VK API** переведён на **POST** — токен больше не попадает в URL и логи
- **Облако Mail.ru** (логин + пароль) — единое хранилище через `EncryptedKeys`
- **FileProvider** для установки APK и шаринга бекапов
- **`usesCleartextTraffic`** — разрешение локальных HTTP-запросов к NVR/MyiSpy
- **`<queries>`** — установщик APK виден на Android 11+
- **`tools:replace`** — разрешён конфликт с `github_release_apk_updater`

### 🐛 Исправления
- **Облако Mail.ru** — логин и пароль теперь сохраняются в резервную копию
- **VK User ID** — сохраняется в бекап (раньше читался, но UI не подхватывал)
- **Диалог перезапуска** после импорта бекапа (данные применяются полностью)
- **`fl_chart`** перенесён из `dev_dependencies` в `dependencies` (критично для release-сборки)
- Убран `await` на не-Future в `nvr_sync_service.dart`
- Исправлены int/String ключи в `energy_screen.dart`
- `_devicesNotifier.state` → публичный геттер `devices`
- Добавлены `context.mounted` в `menu_screen.dart`
- `Geolocator.getCurrentPosition` обновлён на `LocationSettings` (deprecated → актуальный API)
- Единый `_importConfig` (убран дубликат метода)
- `Restart.restartApp()` — правильное имя класса из пакета `restart_app`

### 🧹 Упрощение архитектуры
- **Удалён локальный автобекап** — облако Mail.ru основной источник резервных копий
- Убран триггер бекапа по `AppLifecycleState.inactive` (срабатывал при звонках/диалогах)
- `settings_screen.dart` — 2 опции бекапа вместо 3 (без «Восстановить из локального»)
- Все секреты через единый `EncryptedKeys`:
  - `device_key_<uuid>` — Tuya localKey
  - `vk_token` / `vk_user_id` — VK
  - `mailru_login` / `mailru_password` — облако
  - `mailru_autosync` / `mailru_last_sync` — синхронизация

### 🗑️ Удалён мёртвый код
- `lib/presentation/screens/video/video_screen.dart`
- `lib/presentation/screens/video/alarms_tab.dart`
- `lib/presentation/screens/video/local_camera_tab.dart`
- `lib/presentation/screens/video/rtsp_cameras_tab.dart`
- `lib/application/state/ispy_camera_provider.dart`
- `lib/domain/events/device_event_bus.dart`
- `lib/domain/events/device_events.dart`
- `lib/data/services/test_data_generator.dart`
- `lib/utils/constants.dart`
- Убрана регистрация `DeviceEventBus` из DI

### 📚 Документация
- Обновлены `README.md`, `ARCHITECTURE.md`, `PROJECT_STRUCTURE.md`

### 🔧 Технические метрики
- `flutter analyze` — **0 errors, 0 warnings**
- `flutter test` — **46/46 passed**
- `versionCode` = 80140

## v8.1.38
### 🔐 Безопасность
- **Tuya localKey** перенесён из SQLite в SecureStorage (Android Keystore, AES-256)
- **VK-токен** перенесён из SharedPreferences в SecureStorage
- **VK API** переведён на POST — токен больше не попадает в URL и логи
- **FileProvider** для установки APK и шаринга бекапов
- **`tools:replace`** для разрешения конфликта с `github_release_apk_updater`
- Добавлен атрибут `usesCleartextTraffic` для локальных HTTP-запросов к NVR/MyiSpy
- `<queries>` для установщика APK (Android 11+)

### 🧹 Упрощение
- **Удалён локальный автобекап** — облако Mail.ru основной источник резервных копий
- Убран триггер бекапа по `AppLifecycleState.inactive` (срабатывал при звонках)
- Удалены: `autoBackup()`, `quickImport()`, `hasLocalBackup()`, `lastBackupDate()`
- Упрощён `settings_screen.dart` — вместо 3 опций бекапа осталось 2

### 🗑️ Мёртвый код
- Удалено 9 неиспользуемых файлов (`video_screen`, `alarms_tab`, `ispy_camera_provider`, `device_event_bus` и др.)
- Убрана регистрация `DeviceEventBus` из DI

### 🐛 Исправления
- `fl_chart` перенесён из `dev_dependencies` в `dependencies`
- Убран `await` на не-Future в `nvr_sync_service`
- Исправлены int/String ключи в `energy_screen`
- `_devicesNotifier.state` → публичный геттер `devices`
- Добавлены `context.mounted` в `menu_screen`
- Обновлён `Geolocator.getCurrentPosition` (deprecated → settings)

### 📚 Документация
- Обновлены `README.md`, `ARCHITECTURE.md`, `PROJECT_STRUCTURE.md`

### 🔧 versionCode
- `versionCode` = 80138

## v8.1.35
### 🔔 Уведомления
- Раздельные экраны VK и SMS
- Экран «Уведомления» в главном меню (плитка)
- Список каналов уведомлений
- Управление номерами SMS (добавление, удаление, отключение)
- Отдельные настройки событий для VK и SMS
- Отдельное расписание для VK и SMS
- Отправка SMS напрямую с планшета
- VK-уведомления о тревогах LegionNVR

### 🔧 Технические изменения
- MethodChannel для отправки SMS
- Модели `SmsPhone`, `SmsSettings`
- Провайдер `smsSettingsProvider`
- `versionCode` = 80135

## v8.1.34
### 🔄 Система автообновления (финальная версия)
- **Прямое скачивание APK** с GitHub Releases (быстрее, без редиректов через API)
- **Пауза перед установкой** — окно установщика больше не закрывается
- **Адаптивный заголовок** диалога обновления для маленьких экранов
- **Подсказка после установки** — «откройте SHome вручную»
- **Release notes** — «Что нового» из GitHub
- **Прогресс-бар** скачивания с процентами
- **Проверка свободного места** перед скачиванием
- **Скорость скачивания** в МБ/с

### 🔧 Технические изменения
- **Единый ключ подписи** для debug и release сборок
- **Авторасчёт versionCode** из версии (8.1.34 → 80134)
- **Универсальный скрипт** `release.dart` (bump + sync + run)
- **Автоматические release notes** из коммитов
- **Подпись APK** через GitHub Secrets
- **Очистка старых APK** после установки

### 📚 Документация
- **Экран «История изменений»** из `CHANGELOG.md`
- Переименование «Юридическая информация» → «Информация»

### 🐛 Исправления
- Исправлен конфликт FileProvider с `github_release_apk_updater`
- Исправлено открытие установщика на TECNO
- Исправлен `ResolverActivity` при установке APK
- Исправлен формат версии в `pubspec.yaml` (без `v`)
- Исправлен `versionCode` (коллизии при minor > 20)

## v8.1.28
### 🔄 Автообновление
- Добавлена прямая загрузка APK
- Улучшен UI диалога обновления
- Исправлен перезапуск приложения

## v8.1.20
### 🔧 Технические изменения
- Авторасчёт `versionCode` из версии
- Единый ключ подписи для debug/release
- Скрипт `bump_version.dart` с гибридным режимом

## v8.1.15
### 🔄 Автообновление приложения
- Автоматическая проверка обновлений через GitHub Releases
- Красивый диалог обновления с release notes
- Прогресс-бар скачивания APK
- Автоматическая установка и перезапуск приложения
- Кнопка «Проверить обновления» в настройках
- Добавлена история изменений

### 🎨 Улучшения интерфейса
- Улучшен UI обновления с иконками и прогрессом
- Показ «Что нового» в диалоге обновления

### 🔧 Технические изменения
- Единый ключ подписи для debug и release сборок
- Автоматическая синхронизация версии через скрипты
- Автоматические release notes из коммитов
- Подпись APK через GitHub Secrets

## v8.1.12
### 🔔 Уведомления
- VK-уведомления для сцен (ручные, по времени, по датчику)
- VK-уведомления для устройств (вкл/выкл)
- VK-уведомления для составных устройств
- Настройки уведомлений с расписанием
- Выбор дней недели и времени для уведомлений

## v8.1.11
### 🦾 Составные устройства
- Адаптация кондиционера под составное устройство
- Редактор DPS с поддержкой enum_values
- Вкладка «Отображение» для кондиционера
- Поддержка divider для value-полей
- Улучшенные иконки для кондиционера

### 🎨 Многоканальные устройства
- Именование каналов многоканальных устройств
- Редактирование номеров каналов
- Отображение имён каналов в управлении

## v8.1.10
### 🎨 Интерфейс
- Адаптивные плитки сцен для телефона и планшета
- Горизонтальная и вертикальная ориентация
- Два столбца сцен на смартфоне

### 🔧 Исправления
- Запрет ручного запуска автосцен
- Вывод дней недели без дублирования

## v8.0.0
### 🔐 Закрытая лицензия
- Приложение становится проприетарным
- Добавлены юридические документы:
  - EULA (Лицензионное соглашение)
  - Политика конфиденциальности
  - Условия использования
- Обфускация кода для защиты от реверс-инжиниринга
- Подготовка к платной модели распространения

### 🎨 Улучшения интерфейса
- Полностью переработан CompoundDeviceCard:
  - Убрано дублирование названия и статуса
  - Компактное отображение информационных полей
  - Исправлен выход текста за границы
- Добавлена вкладка "Отображение" в настройках устройств:
  - Включение/выключение info и status полей
  - Мгновенное применение изменений
  - Сохранение настроек между сессиями

### 📚 Документация
- Добавлен экран "Юридическая информация"
- Интеграция с системными лицензиями Flutter
- Динамический год копирайта
- Версия приложения в одном месте

### 🛡️ Безопасность
- Обфускация кода при сборке
- Сохранение debug_info для отладки

### 🔧 Исправления
- Исправлено отображение длинных строк в карточках
- Исправлено сохранение show_on_card в dps_map
- Исправлена кликабельность CompoundDeviceCard
- Исправлены импорты в документах

---

## 📱 Основные возможности

### 🏠 Умный дом
- Управление устройствами Tuya по локальной сети
- Поддержка розеток, выключателей (1/2/3 канала), датчиков, штор, ламп
- Комнаты с фильтрацией
- Сцены и таймеры
- Энергомониторинг

### 🦾 Универсальное составное устройство
- Один тип — все сложные устройства: пылесос, кондиционер, увлажнитель
- Редактор dps_map — добавление/изменение/удаление DPS через GUI
- Выбор иконок для каждого DPS
- Динамический поллер — чтение всех DPS из карты
- Динамический виджет — генерируется из dps_map
- Сортировка DPS по номерам
- Настройка отображения полей на карточке

### 🔍 Сканер
- 📡 Tuya

### 🎨 Интерфейс
- Устройства на главном экране
- Адаптивная сетка (2-5 колонок)
- Drag & Drop с сохранением порядка
- Погода и время в AppBar (Open-Meteo API)
- Тёмная тема
- Компактные карточки составных устройств

### 📹 Видеонаблюдение
- Тревоги LegionNVR через MQTT
- VK уведомления о тревогах

### ☁️ Облако Mail.ru
- WebDAV подключение
- Автосинхронизация бекапов при сворачивании
- Ротация: 5 последних копий в облаке, 3 локально

### 💾 Резервное копирование
- 🔐 Полное шифрование бекапов
- Весь JSON бекапа шифруется (XOR + Base64)
- Пароль облака и токен VK зашифрованы внутри
- Автосохранение MQTT, облака, VK при экспорте
- При импорте — автоматическая расшифровка и восстановление
- Имя файла: backup_ГГММДД_ЧЧММ.json
- Локальный автобекап
- Экспорт через Share Sheet (почта, Telegram, облако)
- Импорт через File Picker
- Восстановление из локального бекапа

### 🔔 Уведомления
- VK Bot — пуш при тревогах
- VK-уведомления для сцен и устройств
- Настройка расписания уведомлений
- MQTT интеграция с LegionNVR

### 🔄 Автообновление
- Проверка обновлений через GitHub Releases
- Скачивание и установка APK
- Автоматический перезапуск

---

## 📄 Лицензия

**SHome** — проприетарное программное обеспечение.

© 2026 votsurX. Все права защищены.

Разработчик: ArchitectCO

### Условия использования:
- Запрещено копирование и распространение
- Запрещена модификация кода
- Запрещён реверс-инжиниринг
- Одна лицензия = одно устройство

Полный текст лицензии доступен в приложении:
Настройки → Юридическая информация → Лицензионное соглашение

---

## 📞 Контакты

По вопросам лицензирования: votsurx@gmail.com