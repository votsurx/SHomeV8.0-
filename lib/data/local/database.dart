/// Центральный класс для работы с SQLite базой данных SHome.
/// Управляет созданием, миграцией и всеми CRUD-операциями.
/// Содержит 6 таблиц: devices, rooms, scenes, events, timers, energy_log.
/// Версия БД: 6.
library;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'entities/device_entity.dart';
import 'entities/room_entity.dart';
import 'entities/scene_entity.dart';
import 'entities/event_entity.dart';
import '../../domain/models/device_timer.dart';

class AppDatabase {
  static Database? _database;
  /// Синглтон базы данных. При первом обращении создаёт/открывает БД.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }
  /// Инициализирует БД: создаёт таблицы при первом запуске,
  /// выполняет миграции при обновлении версии.
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shome.db');

    return await openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
        // Создание всех таблиц с нуля
        await db.execute('''
          CREATE TABLE energy_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deviceId TEXT NOT NULL,
            deviceName TEXT NOT NULL,
            date TEXT NOT NULL,
            totalEnergy REAL NOT NULL DEFAULT 0,
            power REAL NOT NULL DEFAULT 0,
            voltage REAL NOT NULL DEFAULT 0,
            current REAL NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE timers (
            id TEXT PRIMARY KEY,
            deviceId TEXT NOT NULL,
            deviceName TEXT NOT NULL,
            command TEXT NOT NULL,
            executeAt TEXT NOT NULL,
            executed INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event TEXT NOT NULL,
            deviceId TEXT,
            deviceName TEXT,
            value TEXT,
            sceneName TEXT,
            roomName TEXT,
            timerName TEXT,
            timestamp TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sensor_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deviceId TEXT NOT NULL,
            deviceName TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            temperature REAL,
            humidity REAL,
            power REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE devices (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            roomId TEXT NOT NULL,
            isOnline INTEGER NOT NULL,
            state TEXT NOT NULL,
            deviceId TEXT,
            localKey TEXT,
            address TEXT,
            version REAL,
            dpsIndex INTEGER,
            properties TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE rooms (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT,
            sortOrder INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE scenes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            actions TEXT NOT NULL,
            triggerType TEXT,
            triggerTime TEXT,
            triggerRepeat TEXT
          )
        ''');
      },
      // Миграции при обновлении версии БД
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE devices ADD COLUMN dpsIndex INTEGER');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE scenes (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon TEXT NOT NULL,
              actions TEXT NOT NULL,
              triggerType TEXT,
              triggerTime TEXT,
              triggerRepeat TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE events (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              event TEXT NOT NULL,
              deviceId TEXT,
              deviceName TEXT,
              value TEXT,
              sceneName TEXT,
              roomName TEXT,
              timerName TEXT,
              timestamp TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE energy_log (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              deviceId TEXT NOT NULL,
              deviceName TEXT NOT NULL,
              date TEXT NOT NULL,
              totalEnergy REAL NOT NULL DEFAULT 0,
              power REAL NOT NULL DEFAULT 0,
              voltage REAL NOT NULL DEFAULT 0,
              current REAL NOT NULL DEFAULT 0
            )
          ''');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE sensor_log (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              deviceId TEXT NOT NULL,
              deviceName TEXT NOT NULL,
              timestamp TEXT NOT NULL,
              temperature REAL,
              humidity REAL,
              power REAL
            )
          ''');
        }
        // Миграция 8: переименование robotVacuum → compound
        if (oldVersion < 8) {
          await db.execute("UPDATE devices SET type = 'compound' WHERE type = 'robotVacuum'");
        }
      },
    );
  }
  // ============ Energy Log ============

  /// Сохраняет или обновляет данные энергопотребления за сегодня.
  /// Если запись за сегодня уже есть — добавляет energyIncrement к totalEnergy.

  static Future<void> upsertEnergyLog({
    required String deviceId,
    required String deviceName,
    required double power,
    required double voltage,
    required double current,
    required double energyIncrement,
  }) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final existing = await db.query('energy_log', where: 'deviceId = ? AND date = ?', whereArgs: [deviceId, today]);

    if (existing.isNotEmpty) {
      final row = existing.first;
      final newTotal = (row['totalEnergy'] as num).toDouble() + energyIncrement;
      await db.update('energy_log', {
        'totalEnergy': newTotal,
        'power': power,
        'voltage': voltage,
        'current': current,
      }, where: 'deviceId = ? AND date = ?', whereArgs: [deviceId, today]);
    } else {
      await db.insert('energy_log', {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'date': today,
        'totalEnergy': energyIncrement,
        'power': power,
        'voltage': voltage,
        'current': current,
      });
    }
  }
  /// Вставляет запись в лог датчиков
  static Future<void> insertSensorLog({
    required String deviceId,
    required String deviceName,
    required String timestamp,
    double? temperature,
    double? humidity,
    double? power,
  }) async {
    final db = await database;
    await db.insert('sensor_log', {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'timestamp': timestamp,
      'temperature': temperature,
      'humidity': humidity,
      'power': power,
    });
  }

  /// Возвращает данные датчиков за последние N дней
  static Future<List<Map<String, dynamic>>> getSensorData({
    String? deviceId,
    int days = 7,
  }) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();

    String? where;
    List<dynamic>? whereArgs;

    if (deviceId != null) {
      where = 'deviceId = ? AND timestamp >= ?';
      whereArgs = [deviceId, cutoff];
    } else {
      where = 'timestamp >= ?';
      whereArgs = [cutoff];
    }

    return await db.query('sensor_log', where: where, whereArgs: whereArgs, orderBy: 'timestamp ASC');
  }

  /// Возвращает статистику энергопотребления за последние N дней.
  static Future<List<Map<String, dynamic>>> getEnergyStats({int days = 7}) async {
    final db = await database;
    return await db.query('energy_log', orderBy: 'date DESC', limit: days);
  }

  // ============ Events CRUD ============

  /// Записывает событие в журнал.
  static Future<void> insertEvent(EventEntity event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }
  /// Возвращает последние N событий (по умолчанию 100).
  static Future<List<EventEntity>> getRecentEvents({int limit = 100}) async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'id DESC', limit: limit);
    return maps.map((m) => EventEntity.fromMap(m)).toList();
  }
  /// Удаляет все события из журнала.
  static Future<void> clearEvents() async {
    final db = await database;
    await db.delete('events');
  }

  // ============ Devices CRUD ============

  /// Возвращает все устройства из БД.
  static Future<List<DeviceEntity>> getAllDevices() async {
    final db = await database;
    final maps = await db.query('devices');
    return maps.map((map) => DeviceEntity.fromMap(map)).toList();
  }
  /// Вставляет новое устройство (или заменяет существующее).
  static Future<void> insertDevice(DeviceEntity device) async {
    final db = await database;
    await db.insert('devices', device.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  /// Обновляет существующее устройство.
  static Future<void> updateDevice(DeviceEntity device) async {
    final db = await database;
    await db.update('devices', device.toMap(), where: 'id = ?', whereArgs: [device.id]);
  }
  /// Удаляет устройство по ID.
  static Future<void> deleteDevice(String id) async {
    final db = await database;
    await db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Rooms CRUD ============

  /// Возвращает все комнаты, отсортированные по sortOrder.
  static Future<List<RoomEntity>> getAllRooms() async {
    final db = await database;
    final maps = await db.query('rooms', orderBy: 'sortOrder');
    return maps.map((map) => RoomEntity.fromMap(map)).toList();
  }
  /// Вставляет новую комнату.
  static Future<void> insertRoom(RoomEntity room) async {
    final db = await database;
    await db.insert('rooms', room.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  /// Удаляет комнату по ID.
  static Future<void> deleteRoom(String id) async {
    final db = await database;
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Scenes CRUD ============

  /// Возвращает все сцены из БД.
  static Future<List<SceneEntity>> getAllScenes() async {
    final db = await database;
    final maps = await db.query('scenes');
    return maps.map((map) => SceneEntity.fromMap(map)).toList();
  }
  /// Вставляет новую сцену.
  static Future<void> insertScene(SceneEntity scene) async {
    final db = await database;
    await db.insert('scenes', scene.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  /// Удаляет сцену по ID.
  static Future<void> deleteScene(String id) async {
    final db = await database;
    await db.delete('scenes', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Timers CRUD ============

  /// Вставляет новый таймер.
  static Future<void> insertTimer(DeviceTimer timer) async {
    final db = await database;
    await db.insert('timers', {
      'id': timer.id,
      'deviceId': timer.deviceId,
      'deviceName': timer.deviceName,
      'command': timer.command,
      'executeAt': timer.executeAt.toIso8601String(),
      'executed': timer.executed ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  /// Возвращает все активные (не выполненные) таймеры.
  static Future<List<DeviceTimer>> getActiveTimers() async {
    final db = await database;
    final maps = await db.query('timers', where: 'executed = 0', orderBy: 'executeAt ASC');
    return maps.map((m) => DeviceTimer(
      id: m['id'] as String,
      deviceId: m['deviceId'] as String,
      deviceName: m['deviceName'] as String,
      command: m['command'] as String,
      executeAt: DateTime.parse(m['executeAt'] as String),
      executed: (m['executed'] as int) == 1,
    )).toList();
  }
  /// Помечает таймер как выполненный.
  static Future<void> markTimerExecuted(String id) async {
    final db = await database;
    await db.update('timers', {'executed': 1}, where: 'id = ?', whereArgs: [id]);
  }
  /// Удаляет таймер.
  static Future<void> deleteTimer(String id) async {
    final db = await database;
    await db.delete('timers', where: 'id = ?', whereArgs: [id]);
  }
}