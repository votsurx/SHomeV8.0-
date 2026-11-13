## v8.1.46 — AGP 9 + Built-in Kotlin

> Миграция инструментов сборки на актуальные версии. Цель — убрать
> предупреждение Flutter о Kotlin Gradle Plugin (KGP) и подготовить
> проект к будущим версиям Flutter, где KGP в приложении запрещён.
> Функционал приложения не менялся, но обновлены мажорные версии
> нескольких плагинов (file_picker, share_plus, secure_storage и др.).

### 🔧 Сборка
- **Flutter** 3.44.0 → **3.50.0**
- **Gradle** 8.14 → **9.5.0**
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
- 
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

# 🏠 SHome v8.1.37 — Умный дом на Flutter

[![Version](https://img.shields.io/badge/version-8.1.37-blue)](https://github.com/votsurx/SHomeDART/releases)
[![Platform](https://img.shields.io/badge/platform-Android-lightgrey)]()

Локальный контроллер умного дома для устройств Tuya с подсистемой видео,
интеграцией с MyiSpy/LegionNVR, присутствием по Wi-Fi/GPS, облачной
синхронизацией и уведомлениями через VK и SMS.

---

## 📱 Основные возможности

### 🏠 Умный дом
- Управление устройствами Tuya по локальной сети (tinytuya)
- Розетки, выключатели (1/2/3 канала), датчики, шторы, лампы, кондиционеры
- Универсальное составное устройство (`compound`) с редактором DPS-карты
- Комнаты с фильтрацией и drag & drop порядком
- Сцены: ручные, по времени, по датчику, по присутствию
- Таймеры с отложенным вкл/выкл
- Энергомониторинг (мощность, напряжение, ток, кВт·ч)
- Журнал событий

### 📹 Видеонаблюдение
- **LegionNVR** — REST API + MJPEG-стримы в карточках
- **MyiSpy** — приём YOLO-детекций по MQTT + RTSP-плеер
- **RTSP-камеры** — добавление вручную с URL
- **Локальная камера** планшета/телефона (фронт/тыл)
- Уведомления о тревогах через VK

### 📍 Присутствие
- Определение «дома/ушёл» по:
    - Пингу Wi-Fi IP телефона
    - GPS-координатам через Mail.ru Cloud (WebDAV)
- Радиус и тайм-аут настраиваются
- Триггеры сцен по событиям присутствия (кто-то пришёл, все дома, никого нет)

### 🔔 Уведомления
- **VK Bot** — с настройкой расписания и категорий событий
- **SMS** — прямая отправка через `MethodChannel`
- Раздельные расписания для VK и SMS
- Категории: сцены, устройства, тревоги, ошибки

### ☁️ Облако Mail.ru
- Резервные копии через WebDAV
- Автосинхронизация при сворачивании
- Ротация: 5 копий в облаке, 3 локально
- **Шифрование бекапов** (XOR + Base64)

### 🎨 Интерфейс
- Material 3 с Dynamic Color
- Адаптивная сетка (2-5 колонок)
- Тёмная/светлая/авто тема
- Время + погода (wttr.in) в AppBar
- Сканер Tuya-устройств (порты 6666-6668-7000)

### 🔄 Автообновление
- Проверка через GitHub Releases
- Скачивание и установка APK с прогресс-баром
- Показ «Что нового» из release notes

---

## 🦾 Универсальное составное устройство

Один тип `compound` заменяет пылесосы, кондиционеры, увлажнители:

1. Добавьте устройство → Тип: **Универсальное устройство**
2. Шестерёнка → **DPS-карта** → **Добавить DPS**
3. Укажите: номер, название, тип (`bool`/`value`/`enum`/`slider`),
   роль (`main`/`action`/`toggle`/`info`/`status`/`slider`/`enum`/`channel`),
   иконку
4. Виджет и опрос строятся автоматически из карты

Переключатели **show_on_card** для info/status DPS позволяют управлять
отображением на карточке главного экрана.

---

## 🛠️ Технологии

| Слой | Технология |
|------|------------|
| Фреймворк | Flutter 3.x (Dart 3.2+) |
| Состояние | Riverpod 2.x |
| Навигация | GoRouter |
| DI | GetIt |
| БД | SQLite (sqflite) — 6 таблиц |
| Ключи | flutter_secure_storage |
| Протокол Tuya | TinyTuya (локальная копия) |
| MQTT | mqtt_client |
| WebDAV | webdav_client |
| Модели | Freezed + json_serializable |
| Логгер | Talker |
| Графики | fl_chart |
| Видео | video_player, camera |
| Анимации | Lottie |

---

## 📦 Установка

Скачайте APK из [Releases](https://github.com/votsurx/SHome-Releases/releases).

**Требования:** Android 7.0+, планшет/телефон.

---

## 🚀 Быстрый старт

1. Пройдите онбординг (создайте комнаты)
2. Сканер → добавьте Tuya-устройства (Device ID, Local Key, IP)
3. Настройки → Видео NVR / Видео MyiSpy (если используете)
4. Настройки → Уведомления (VK / SMS)
5. Меню → Облако (для бекапов)
6. Меню → Присутствие (Wi-Fi/GPS-отслеживание)

---

## 📄 Лицензия

**SHome** — проприетарное ПО. © 2026 votsurX.
Разработчик: ArchitectCO.

Полный текст: приложение → Настройки → Информация → EULA.

---

## 📞 Контакты

votsurx@gmail.com