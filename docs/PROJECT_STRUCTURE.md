# 🏠 SHome v2.0 — Структура проекта

## 📁 Корневые папки

| Папка/Файл | Описание |
|------------|----------|
| `lib/` | Исходный код приложения |
| `android/` | Android-конфигурация (Gradle, манифест) |
| `assets/` | Иконки, изображения, переводы |
| `test/` | Unit, widget, интеграционные тесты |
| `docs/` | Документация проекта |
| `lib/packages/tinytuya/` | Локальная копия библиотеки TinyTuya |

---

## 📂 `lib/` — Исходный код

### `main.dart`
Точка входа. Инициализирует DI, добавляет тестовые комнаты, запускает приложение.

### `app.dart`
Корневой виджет `SHomeApp` с `MaterialApp.router`, темой и `ProviderScope`.

---

## 📂 `lib/di/` — Dependency Injection

| Файл | Описание |
|------|----------|
| `injection.dart` | Регистрация всех зависимостей через GetIt: репозитории, сервисы, протоколы |

---

## 📂 `lib/domain/` — Бизнес-логика

### `lib/domain/models/` — Модели данных

| Файл | Описание |
|------|----------|
| `device.dart` | Модель устройства (Freezed): id, name, type, roomId, deviceId, localKey, dpsIndex, properties |
| `room.dart` | Модель комнаты: id, name, icon, sortOrder |
| `scene.dart` | Модель сцены: id, name, actions, trigger |

### `lib/domain/repositories/` — Интерфейсы репозиториев

| Файл | Описание |
|------|----------|
| `device_repository.dart` | Контракт: getAllDevices, saveDevice, turnOn/Off, ping, setSwitchChannel, getDeviceDps |
| `room_repository.dart` | Контракт: getAllRooms, saveRoom, deleteRoom |
| `scene_repository.dart` | Контракт: getAllScenes, saveScene, executeScene |

### `lib/domain/commands/` — Команды устройств

| Файл | Описание |
|------|----------|
| `device_command.dart` | Модель команды: DeviceCommandType, deviceId, params, retries |
| `device_command_handler.dart` | Обработчик команд с повторами (3 попытки с задержкой) |

### `lib/domain/events/` — События

| Файл | Описание |
|------|----------|
| `device_event_bus.dart` | Шина событий (Singleton) |
| `device_events.dart` | Классы событий: DeviceStateChanged, DeviceOnline, DeviceOffline |

### `lib/domain/services/` — Интерфейсы сервисов

| Файл | Описание |
|------|----------|
| `mqtt_service_interface.dart` | Интерфейс MQTT сервиса (на будущее) |

---

## 📂 `lib/data/` — Реализация

### `lib/data/repositories/` — Реализации репозиториев

| Файл | Описание |
|------|----------|
| `device_repository_impl.dart` | Реализация DeviceRepository: Map + SQLite, turnOn/Off через TuyaProtocol |
| `room_repository_impl.dart` | Реализация RoomRepository: Map + SQLite |
| `scene_repository_impl.dart` | Реализация SceneRepository: Map, выполнение сцен |

### `lib/data/protocols/` — Сетевые протоколы

| Файл | Описание |
|------|----------|
| `tuya_protocol.dart` | Работа с устройствами Tuya через tinytuya: turnOn/Off, setValue, getStatus, ping |

### `lib/data/services/` — Сервисы

| Файл | Описание |
|------|----------|
| `adaptive_poller.dart` | Умный опрос устройств: 2с → 1мин → 5мин, сброс при ответе/команде |
| `port_scanner.dart` | Асинхронное сканирование портов 6666-6668-7000 по всей подсети |
| `mqtt_service_impl.dart` | Заготовка MQTT клиента (на будущее) |

### `lib/data/local/` — Локальное хранение

| Файл | Описание |
|------|----------|
| `database.dart` | SQLite база данных: таблицы devices, rooms |
| `entities/device_entity.dart` | Сущность устройства для БД |
| `entities/room_entity.dart` | Сущность комнаты для БД |
| `secure_storage/encrypted_keys.dart` | Хранение ключей в flutter_secure_storage |

### `lib/data/mappers/` — Мапперы

| Файл | Описание |
|------|----------|
| `device_mapper.dart` | Device ↔ DeviceEntity |
| `room_mapper.dart` | Room ↔ RoomEntity |

---

## 📂 `lib/application/` — Управление состоянием

### `lib/application/state/` — Riverpod провайдеры

| Файл | Описание |
|------|----------|
| `devices_provider.dart` | DevicesNotifier: список устройств, turnOn/Off, updateDeviceState |
| `rooms_provider.dart` | RoomsNotifier: список комнат, addRoom, deleteRoom |
| `scenes_provider.dart` | ScenesNotifier: список сцен, executeScene |
| `theme_provider.dart` | ThemeNotifier: переключение темы (система/день/ночь) |
| `onboarding_manager.dart` | Флаг завершения онбординга в SharedPreferences |

### `lib/application/navigation/` — Роутинг

| Файл | Описание |
|------|----------|
| `router.dart` | GoRouter: /, /devices, /energy, /scenes, /scan, /rooms, /onboarding/* |

---

## 📂 `lib/presentation/` — UI

### `lib/presentation/screens/` — Экраны

| Файл | Описание |
|------|----------|
| `home_screen.dart` | Dashboard с адаптивной сеткой плиток |
| `device_list_screen.dart` | Список устройств в виде сетки с RoomSelector |
| `energy_screen.dart` | Энергомониторинг (заготовка) |
| `scenes_screen.dart` | Сетка сцен с созданием/выполнением |
| `scan_devices_screen.dart` | Сканер устройств Tuya с прогресс-баром |
| `rooms_manage_screen.dart` | Управление комнатами: добавить/удалить/переименовать |
| `settings_screen.dart` | Настройки (заготовка) |
| `onboarding/*` | Экраны онбординга: welcome, scan, rooms_setup |

### `lib/presentation/widgets/` — Виджеты

| Файл | Описание |
|------|----------|
| `device_card.dart` | Карточка устройства с power-иконкой, шестерёнкой, многоканальными |
| `room_selector.dart` | Горизонтальные чипсы комнат с кнопкой + |

### `lib/presentation/theme/` — Темы

| Файл | Описание |
|------|----------|
| `app_theme.dart` | Material 3 тема (светлая/тёмная) |
| `colors.dart` | Цвета приложения |

---

## 📂 `lib/utils/` — Утилиты

| Файл | Описание |
|------|----------|
| `constants.dart` | Константы приложения |
| `helpers.dart` | Вспомогательные функции |

---

## 🔧 `android/` — Конфигурация Android

| Файл | Описание |
|------|----------|
| `app/build.gradle.kts` | Конфигурация сборки: compileSdk 36, minSdk 24 |
| `settings.gradle.kts` | Плагины: AGP 8.11.1, Kotlin 2.2.20 |
| `gradle/wrapper/gradle-wrapper.properties` | Gradle 8.14 |
| `app/src/main/AndroidManifest.xml` | Разрешения: INTERNET, NETWORK, WIFI |

---

## 🔑 Ключевые технологии

| Компонент | Технология |
|-----------|------------|
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| DI | GetIt |
| Database | SQLite (sqflite) |
| Secure Storage | flutter_secure_storage |
| Tuya Protocol | TinyTuya (локальная копия) |
| Code Generation | Freezed + json_serializable |
| Logging | Talker |
| UI | Material 3, Dynamic Color |