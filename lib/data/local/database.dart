/// Центральный класс для работы с SQLite базой данных SHome.
/// Управляет созданием, миграцией и всеми CRUD-операциями.
/// Таблицы: devices, rooms, scenes, events, timers, energy_log, sensor_log,
///          device_stats_daily, system_health_daily, stats_settings.
/// Версия БД: 9.
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

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shome.db');

    return await openDatabase(
      path,
      version: 9, // ← NEW: было 8
      onCreate: (db, version) async {
        // ─── существующие таблицы ───
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

        // ─── NEW: индексы для существующих таблиц ───
        await db.execute('CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_events_device ON events(deviceId)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_device_time ON sensor_log(deviceId, timestamp)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_time ON sensor_log(timestamp)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_energy_log_device_date ON energy_log(deviceId, date)');

        // ─── NEW: таблицы статистики ───
        await _createStatsTables(db);
      },
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
        if (oldVersion < 8) {
          await db.execute("UPDATE devices SET type = 'compound' WHERE type = 'robotVacuum'");
        }
        // ─── NEW: миграция v8 → v9 ───
        if (oldVersion < 9) {
          await db.execute('CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_events_device ON events(deviceId)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_device_time ON sensor_log(deviceId, timestamp)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_time ON sensor_log(timestamp)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_energy_log_device_date ON energy_log(deviceId, date)');
          await _createStatsTables(db);
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // NEW: создание таблиц статистики (общая для onCreate и onUpgrade)
  // ═══════════════════════════════════════════════════════════

  static Future<void> _createStatsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS device_stats_daily (
        device_id TEXT NOT NULL,
        date TEXT NOT NULL,
        online_count INTEGER NOT NULL DEFAULT 0,
        offline_count INTEGER NOT NULL DEFAULT 0,
        alert_count INTEGER NOT NULL DEFAULT 0,
        action_count INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (device_id, date)
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_device_stats_date ON device_stats_daily(date)');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS system_health_daily (
        date TEXT PRIMARY KEY,
        app_uptime_sec INTEGER NOT NULL DEFAULT 0,
        mqtt_reconnects INTEGER NOT NULL DEFAULT 0,
        heartbeat_losses INTEGER NOT NULL DEFAULT 0,
        db_size_mb REAL NOT NULL DEFAULT 0,
        error_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stats_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    // дефолты — INSERT OR IGNORE, чтобы не перетереть пользовательские настройки
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('stats_retention_days','365')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('events_retention_days','30')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('electricity_tariff_rub_per_kwh','5.5')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('stats_backfilled','0')");
  }

  // ============ Energy Log ============

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

  static Future<List<Map<String, dynamic>>> getSensorData({
    String? deviceId,
    int days = 7,
  }) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    String where;
    List<dynamic> whereArgs;
    if (deviceId != null) {
      where = 'deviceId = ? AND timestamp >= ?';
      whereArgs = [deviceId, cutoff];
    } else {
      where = 'timestamp >= ?';
      whereArgs = [cutoff];
    }
    return db.query('sensor_log', where: where, whereArgs: whereArgs, orderBy: 'timestamp ASC');
  }

  static Future<List<Map<String, dynamic>>> getEnergyStats({int days = 7}) async {
    final db = await database;
    return db.query('energy_log', orderBy: 'date DESC', limit: days);
  }

  // ============ Events CRUD ============

  static Future<void> insertEvent(EventEntity event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  static Future<List<EventEntity>> getRecentEvents({int limit = 100}) async {
    final db = await database;
    final maps = await db.query('events', orderBy: 'id DESC', limit: limit);
    return maps.map((m) => EventEntity.fromMap(m)).toList();
  }

  static Future<void> clearEvents() async {
    final db = await database;
    await db.delete('events');
  }

  // ============ Devices CRUD ============

  static Future<List<DeviceEntity>> getAllDevices() async {
    final db = await database;
    final maps = await db.query('devices');
    return maps.map((map) => DeviceEntity.fromMap(map)).toList();
  }

  static Future<DeviceEntity?> getDeviceById(String id) async {
    final db = await database;
    final maps = await db.query('devices', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return DeviceEntity.fromMap(maps.first);
  }

  static Future<void> insertDevice(DeviceEntity device) async {
    final db = await database;
    await db.insert('devices', device.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateDevice(DeviceEntity device) async {
    final db = await database;
    await db.update('devices', device.toMap(), where: 'id = ?', whereArgs: [device.id]);
  }

  static Future<void> deleteDevice(String id) async {
    final db = await database;
    await db.delete('devices', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Rooms CRUD ============

  static Future<List<RoomEntity>> getAllRooms() async {
    final db = await database;
    final maps = await db.query('rooms', orderBy: 'sortOrder');
    return maps.map((map) => RoomEntity.fromMap(map)).toList();
  }

  static Future<void> insertRoom(RoomEntity room) async {
    final db = await database;
    await db.insert('rooms', room.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteRoom(String id) async {
    final db = await database;
    await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Scenes CRUD ============

  static Future<List<SceneEntity>> getAllScenes() async {
    final db = await database;
    final maps = await db.query('scenes');
    return maps.map((map) => SceneEntity.fromMap(map)).toList();
  }

  static Future<void> insertScene(SceneEntity scene) async {
    final db = await database;
    await db.insert('scenes', scene.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteScene(String id) async {
    final db = await database;
    await db.delete('scenes', where: 'id = ?', whereArgs: [id]);
  }

  // ============ Timers CRUD ============

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

  static Future<void> markTimerExecuted(String id) async {
    final db = await database;
    await db.update('timers', {'executed': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteTimer(String id) async {
    final db = await database;
    await db.delete('timers', where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════
  // NEW: STATS — device_stats_daily
  // ═══════════════════════════════════════════════════════════

  static Future<void> upsertDeviceStat({
    required String deviceId,
    required String date,
    int online = 0,
    int offline = 0,
    int alert = 0,
    int action = 0,
  }) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO device_stats_daily
        (device_id, date, online_count, offline_count, alert_count, action_count)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(device_id, date) DO UPDATE SET
        online_count  = online_count  + excluded.online_count,
        offline_count = offline_count + excluded.offline_count,
        alert_count   = alert_count   + excluded.alert_count,
        action_count  = action_count  + excluded.action_count
    ''', [deviceId, date, online, offline, alert, action]);
  }

  static Future<List<Map<String, Object?>>> getDeviceUptime({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT device_id,
        SUM(online_count)  AS online,
        SUM(offline_count) AS offline,
        SUM(alert_count)   AS alerts,
        SUM(action_count)  AS actions,
        CASE WHEN SUM(online_count)+SUM(offline_count)=0 THEN NULL
             ELSE 1.0*SUM(online_count)/(SUM(online_count)+SUM(offline_count))
        END AS uptime_ratio
      FROM device_stats_daily
      WHERE date BETWEEN ? AND ?
      GROUP BY device_id
      ORDER BY uptime_ratio ASC
    ''', [fromDate, toDate]);
  }

  static Future<Map<String, int>> getStatsTotals({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final r = await db.rawQuery('''
      SELECT
        COALESCE(SUM(online_count),0)  AS online,
        COALESCE(SUM(offline_count),0) AS offline,
        COALESCE(SUM(alert_count),0)   AS alerts,
        COALESCE(SUM(action_count),0)  AS actions
      FROM device_stats_daily WHERE date BETWEEN ? AND ?
    ''', [fromDate, toDate]);
    final m = r.first;
    return {
      'online': (m['online'] as num).toInt(),
      'offline': (m['offline'] as num).toInt(),
      'alerts': (m['alerts'] as num).toInt(),
      'actions': (m['actions'] as num).toInt(),
    };
  }

  static Future<List<Map<String, Object?>>> getDeviceDailySeries({
    required String deviceId,
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT date, online_count, offline_count, alert_count, action_count
      FROM device_stats_daily
      WHERE device_id = ? AND date BETWEEN ? AND ?
      ORDER BY date ASC
    ''', [deviceId, fromDate, toDate]);
  }

  // ═══════════════════════════════════════════════════════════
  // NEW: STATS — system_health_daily
  // ═══════════════════════════════════════════════════════════

  static Future<void> incrementSystemError(String date) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO system_health_daily (date, error_count) VALUES (?, 1)
      ON CONFLICT(date) DO UPDATE SET error_count = error_count + 1
    ''', [date]);
  }

  static Future<Map<String, Object?>?> getSystemHealth(String date) async {
    final db = await database;
    final r = await db.query('system_health_daily', where: 'date = ?', whereArgs: [date], limit: 1);
    return r.isEmpty ? null : r.first;
  }

  // ═══════════════════════════════════════════════════════════
  // NEW: STATS — настройки
  // ═══════════════════════════════════════════════════════════

  static Future<String?> getStatsSetting(String key) async {
    final db = await database;
    final r = await db.query('stats_settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return r.isEmpty ? null : r.first['value'] as String?;
  }

  static Future<void> setStatsSetting(String key, String value) async {
    final db = await database;
    await db.insert('stats_settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}