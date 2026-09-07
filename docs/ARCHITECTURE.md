# 🏗️ Архитектура SHome v2.0 — Взаимосвязи

## 📊 Слои приложения (Clean Architecture)
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER │
│ Экраны: HomeScreen, DeviceListScreen, ScenesScreen, ... │
│ Виджеты: DeviceCard, RoomSelector │
│ Темы: AppTheme, Colors │
└──────────────────────────┬──────────────────────────────────┘
│ зависит от
▼
┌─────────────────────────────────────────────────────────────┐
│ APPLICATION LAYER │
│ State: devicesProvider, roomsProvider, themeProvider │
│ Navigation: router.dart (GoRouter) │
│ Managers: OnboardingManager │
└──────────────────────────┬──────────────────────────────────┘
│ зависит от
▼
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER │
│ Models: Device, Room, Scene │
│ Repositories (интерфейсы): DeviceRepo, RoomRepo, SceneRepo │
│ Commands: DeviceCommand, CommandHandler │
│ Events: DeviceEventBus, DeviceEvents │
└──────────────────────────┬──────────────────────────────────┘
│ реализуется в
▼
┌─────────────────────────────────────────────────────────────┐
│ DATA LAYER │
│ Repositories (импл): DeviceRepoImpl, RoomRepoImpl │
│ Protocols: TuyaProtocol (tinytuya) │
│ Services: AdaptivePoller, PortScanner │
│ Local: SQLite, SecureStorage │
│ Mappers: DeviceMapper, RoomMapper │
└─────────────────────────────────────────────────────────────┘

---

## 🔄 Основные потоки данных

### 1. Включение/выключение устройства
DeviceCard (power-иконка)
→ devicesProvider.turnOn(id)
→ DeviceCommandHandler.execute()
→ TuyaProtocol.setValue(index, value)
→ tinytuya.OutletDevice.setValue()
→ UDP-пакет на устройство
→ Ответ устройства
→ Обновление isOn в properties
→ UI перерисовывается

### 2. Сканирование устройств
ScanDevicesScreen
→ PortScanner.scanSubnet()
→ Проверка портов 6666-6668-7000 на всех IP подсети
→ Найдено → DiscoveredDevice
→ Диалог добавления
→ devicesProvider.addDevice()
→ DeviceRepository.saveDevice()
→ SQLite + Map

### 3. Опрос состояния (AdaptivePoller)
AdaptivePoller (каждые 2-5 сек)
→ TuyaProtocol.getStatus()
→ tinytuya.OutletDevice.status()
→ DPS данные
→ Сравнение isOn с текущим
→ Изменилось → devicesProvider.updateDeviceState()
→ UI обновляется
→ Не изменилось → ничего
→ Ошибка → счётчик ошибок +1 → замедление интервала

### 4. Сцены
ScenesScreen
→ scenesProvider.executeScene()
→ SceneRepositoryImpl.executeScene()
→ Для каждого SceneAction:
→ deviceRepository.turnOn/Off()
→ ... (поток 1)

### 5. Онбординг
main.dart
→ HomeScreen.initState()
→ OnboardingManager.isOnboardingComplete()
→ false → WelcomeScreen
→ ScanScreen
→ RoomsSetupScreen
→ OnboardingManager.complete()
→ HomeScreen

---

## 🗄️ База данных
SQLite: shome.db
├── devices
│ ├── id (TEXT PK)
│ ├── name (TEXT)
│ ├── type (TEXT)
│ ├── roomId (TEXT)
│ ├── isOnline (INTEGER)
│ ├── state (TEXT)
│ ├── deviceId (TEXT)
│ ├── localKey (TEXT)
│ ├── address (TEXT)
│ ├── version (REAL)
│ ├── dpsIndex (INTEGER)
│ └── properties (TEXT JSON)
└── rooms
├── id (TEXT PK)
├── name (TEXT)
├── icon (TEXT)
└── sortOrder (INTEGER)

---

## 📡 Сетевые протоколы
TuyaProtocol
├── UDP broadcast (обнаружение)
│ └── Порты: 6666, 6667, 7000
├── TCP (управление)
│ └── Порт: 6668
└── Шифрование: AES-128-ECB/GCM
└── Ключ: localKey устройства

---

## 🧩 Dependency Injection (GetIt)
getIt
├── Talker (логгер)
├── DeviceEventBus
├── EncryptedKeys
├── TuyaProtocol
├── DeviceRepository → DeviceRepositoryImpl
├── RoomRepository → RoomRepositoryImpl
├── SceneRepository → SceneRepositoryImpl
├── MqttService → MqttServiceImpl (заготовка)
└── DeviceCommandHandler

---

## 🎨 UI-компоненты
HomeScreen (Dashboard)
├── GridView (адаптивная сетка)
│ ├── Устройства → /devices
│ ├── Энергия → /energy
│ ├── Сцены → /scenes
│ ├── Сканировать → /scan
│ ├── Тема → themeProvider.toggle()
│ ├── Комнаты → /rooms
│ ├── Статистика (заглушка)
│ ├── Таймеры (заглушка)
│ └── События (заглушка)
└── AdaptivePoller (фоновый опрос)
DeviceListScreen
├── RoomSelector (чипсы комнат)
└── GridView устройств
└── DeviceCard
├── Power-иконка (вкл/выкл)
├── Многоканальные (несколько power)
├── Датчик (температура/влажность)
├── Шторы (% открытия)
└── Шестерёнка (настройки)
├── Название
├── Device ID (только чтение)
├── IP Адрес
├── Local Key
├── Комната (выпадающий список)
├── DPS Индекс
├── Количество каналов (для switch)
├── DPS каналов (только чтение)
├── Сохранить
└── Удалить

---

## 🔐 Безопасность
Ключи устройств:
flutter_secure_storage (EncryptedKeys)
└── localKey (AES-ключ устройства)

В БД хранится только keyId → ключ в SecureStorage

---

## 🧠 Адаптивный опрос (AdaptivePoller)
Состояния:
NORMAL (2 сек)
→ 3 ошибки → SLOW (1 мин)
→ 3 ошибки → VERY_SLOW (5 мин)
→ Успех → NORMAL (сброс)
Ручная команда → NORMAL (сброс)

Защита:

polling flag (не более 1 одновременного опроса на устройство)

Future.wait (параллельный опрос всех устройств)
