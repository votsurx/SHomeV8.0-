/// Центральный класс для работы с SQLite базой данных SHome.
/// Управляет созданием, миграцией и всеми CRUD-операциями.
/// Таблицы: devices, rooms, scenes, events, timers, energy_log, sensor_log,
///          device_stats_daily, system_health_daily, stats_settings, presence_daily.
/// Версия БД: 10.
library;
import 'dart:convert';

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
      version: 12,
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
        // notification_stats_daily — отправки уведомлений
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_stats_daily (
            date TEXT NOT NULL,
            channel TEXT NOT NULL,
            category TEXT NOT NULL,
            sent INTEGER NOT NULL DEFAULT 0,
            suppressed_by_cooldown INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (date, channel, category)
          )
        ''');

        // ─── индексы ───
        await db.execute('CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_events_device ON events(deviceId)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_device_time ON sensor_log(deviceId, timestamp)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_time ON sensor_log(timestamp)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_energy_log_device_date ON energy_log(deviceId, date)');

        // ─── таблицы статистики ───
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
        if (oldVersion < 9) {
          await db.execute('CREATE INDEX IF NOT EXISTS idx_events_timestamp ON events(timestamp)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_events_device ON events(deviceId)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_device_time ON sensor_log(deviceId, timestamp)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_sensor_log_time ON sensor_log(timestamp)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_energy_log_device_date ON energy_log(deviceId, date)');
          await _createStatsTables(db);
        }
        if (oldVersion < 10) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS presence_daily (
              date TEXT PRIMARY KEY,
              home_sec INTEGER NOT NULL DEFAULT 0,
              near_sec INTEGER NOT NULL DEFAULT 0,
              away_sec INTEGER NOT NULL DEFAULT 0,
              unknown_sec INTEGER NOT NULL DEFAULT 0,
              cloud_fallback_count INTEGER NOT NULL DEFAULT 0
            )
          ''');
        }
        if (oldVersion < 11) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS notification_stats_daily (
              date TEXT NOT NULL,
              channel TEXT NOT NULL,
              category TEXT NOT NULL,
              sent INTEGER NOT NULL DEFAULT 0,
              suppressed_by_cooldown INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY (date, channel, category)
            )
          ''');
          if (oldVersion < 12) {
            await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_battery_threshold','20')");
            await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_linkquality_threshold','30')");
            await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_offline_per_day','5')");
            await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_energy_multiplier','1.5')");
          }
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // создание таблиц статистики (общая для onCreate и onUpgrade)
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
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('stats_retention_days','365')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('events_retention_days','30')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('electricity_tariff_rub_per_kwh','5.5')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('stats_backfilled','0')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_battery_threshold','20')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_linkquality_threshold','30')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_offline_per_day','5')");
    await db.rawInsert("INSERT OR IGNORE INTO stats_settings(key,value) VALUES('anomaly_energy_multiplier','1.5')");

    // ─── NEW: presence_daily ───
    await db.execute('''
      CREATE TABLE IF NOT EXISTS presence_daily (
        date TEXT PRIMARY KEY,
        home_sec INTEGER NOT NULL DEFAULT 0,
        near_sec INTEGER NOT NULL DEFAULT 0,
        away_sec INTEGER NOT NULL DEFAULT 0,
        unknown_sec INTEGER NOT NULL DEFAULT 0,
        cloud_fallback_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
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
  // STATS — device_stats_daily
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
  // STATS — system_health_daily
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
  // STATS — настройки
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

  // ═══════════════════════════════════════════════════════════
  // STATS: Frigate детекции (из events)
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, int>> getFrigateDetectionsByLabel({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT event, COUNT(*) AS cnt
      FROM events
      WHERE event LIKE 'frigate_%'
        AND timestamp >= ? AND timestamp < ?
      GROUP BY event
    ''', [fromDate, '$toDate 23:59:59']);
    final result = <String, int>{};
    for (final r in rows) {
      final label = (r['event'] as String).replaceFirst('frigate_', '');
      result[label] = (r['cnt'] as num).toInt();
    }
    return result;
  }

  static Future<Map<String, int>> getFrigateDetectionsByCamera({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT deviceName, COUNT(*) AS cnt
      FROM events
      WHERE event LIKE 'frigate_%'
        AND timestamp >= ? AND timestamp < ?
        AND deviceName IS NOT NULL
      GROUP BY deviceName
    ''', [fromDate, '$toDate 23:59:59']);
    final result = <String, int>{};
    for (final r in rows) {
      result[r['deviceName'] as String] = (r['cnt'] as num).toInt();
    }
    return result;
  }

  static Future<List<Map<String, Object?>>> getFrigateHourlyHeatmap({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT
        substr(timestamp, 1, 10) AS date,
        CAST(substr(timestamp, 12, 2) AS INTEGER) AS hour,
        COUNT(*) AS count
      FROM events
      WHERE event LIKE 'frigate_%'
        AND timestamp >= ? AND timestamp < ?
      GROUP BY date, hour
      ORDER BY date ASC, hour ASC
    ''', [fromDate, '$toDate 23:59:59']);
  }

  // ═══════════════════════════════════════════════════════════
  // STATS: Сцены (из events)
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, int>> getSceneStats({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT sceneName, COUNT(*) AS cnt
      FROM events
      WHERE event = 'scene' AND sceneName IS NOT NULL
        AND timestamp >= ? AND timestamp < ?
      GROUP BY sceneName
      ORDER BY cnt DESC
    ''', [fromDate, '$toDate 23:59:59']);
    final result = <String, int>{};
    for (final r in rows) {
      result[r['sceneName'] as String] = (r['cnt'] as num).toInt();
    }
    return result;
  }

  static Future<List<String>> getForgottenScenes({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT name FROM scenes
      WHERE name NOT IN (
        SELECT DISTINCT sceneName FROM events
        WHERE event = 'scene' AND sceneName IS NOT NULL
          AND timestamp >= ? AND timestamp < ?
      )
      ORDER BY name ASC
    ''', [fromDate, '$toDate 23:59:59']);
    return rows.map((r) => r['name'] as String).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // STATS: Присутствие (из presence_daily)
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, int>> getPresenceTotals({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final r = await db.rawQuery('''
      SELECT
        COALESCE(SUM(home_sec), 0)    AS home,
        COALESCE(SUM(near_sec), 0)    AS near,
        COALESCE(SUM(away_sec), 0)    AS away,
        COALESCE(SUM(unknown_sec), 0) AS unknown,
        COALESCE(SUM(cloud_fallback_count), 0) AS cloud
      FROM presence_daily
      WHERE date BETWEEN ? AND ?
    ''', [fromDate, toDate]);
    final m = r.first;
    return {
      'home': (m['home'] as num).toInt(),
      'near': (m['near'] as num).toInt(),
      'away': (m['away'] as num).toInt(),
      'unknown': (m['unknown'] as num).toInt(),
      'cloud': (m['cloud'] as num).toInt(),
    };
  }

  static Future<List<Map<String, Object?>>> getPresenceDailySeries({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT date, home_sec, near_sec, away_sec, unknown_sec
      FROM presence_daily
      WHERE date BETWEEN ? AND ?
      ORDER BY date ASC
    ''', [fromDate, toDate]);
  }

  static Future<void> addPresenceSeconds({
    required String date,
    required String state,
    required int seconds,
  }) async {
    final db = await database;
    // защита от SQL-инъекции: state — только из известного набора
    const allowed = {'home', 'near', 'away', 'unknown'};
    if (!allowed.contains(state)) return;
    final column = '${state}_sec';
    await db.rawInsert('''
      INSERT INTO presence_daily (date, $column)
      VALUES (?, ?)
      ON CONFLICT(date) DO UPDATE SET $column = $column + excluded.$column
    ''', [date, seconds]);
  }

  static Future<void> incrementCloudFallback(String date) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO presence_daily (date, cloud_fallback_count)
      VALUES (?, 1)
      ON CONFLICT(date) DO UPDATE SET cloud_fallback_count = cloud_fallback_count + 1
    ''', [date]);
  }

  // ═══════════════════════════════════════════════════════════
  // STATS: Климат (из sensor_log)
  // ═══════════════════════════════════════════════════════════

  static Future<List<Map<String, Object?>>> getClimateStats({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT deviceId, deviceName,
        MIN(temperature) AS t_min,
        MAX(temperature) AS t_max,
        AVG(temperature) AS t_avg,
        MIN(humidity) AS h_min,
        MAX(humidity) AS h_max,
        AVG(humidity) AS h_avg,
        COUNT(*) AS samples
      FROM sensor_log
      WHERE timestamp >= ? AND timestamp < ?
        AND (temperature IS NOT NULL OR humidity IS NOT NULL)
      GROUP BY deviceId
      ORDER BY deviceName ASC
    ''', [fromDate, '$toDate 23:59:59']);
  }

  static Future<List<Map<String, Object?>>> getClimateTrend({
    required String deviceId,
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT timestamp, temperature, humidity
      FROM sensor_log
      WHERE deviceId = ? AND timestamp >= ? AND timestamp < ?
        AND (temperature IS NOT NULL OR humidity IS NOT NULL)
      ORDER BY timestamp ASC
    ''', [deviceId, fromDate, '$toDate 23:59:59']);
  }
  // ═══════════════════════════════════════════════════════════
  // STATS: Уведомления (notification_stats_daily)
  // ═══════════════════════════════════════════════════════════

  /// Инкремент отправленного уведомления.
  static Future<void> incrementNotificationSent({
    required String date,
    required String channel,   // 'vk' | 'sms'
    required String category,
  }) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO notification_stats_daily (date, channel, category, sent)
      VALUES (?, ?, ?, 1)
      ON CONFLICT(date, channel, category) DO UPDATE SET sent = sent + 1
    ''', [date, channel, category]);
  }

  /// Инкремент подавленного cooldown.
  static Future<void> incrementNotificationSuppressed({
    required String date,
    required String channel,
    required String category,
  }) async {
    final db = await database;
    await db.rawInsert('''
      INSERT INTO notification_stats_daily
        (date, channel, category, suppressed_by_cooldown)
      VALUES (?, ?, ?, 1)
      ON CONFLICT(date, channel, category) DO UPDATE SET
        suppressed_by_cooldown = suppressed_by_cooldown + 1
    ''', [date, channel, category]);
  }

  /// Топ категорий по отправкам.
  static Future<List<Map<String, Object?>>> getNotificationByCategory({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    return db.rawQuery('''
      SELECT category,
        SUM(sent) AS sent,
        SUM(suppressed_by_cooldown) AS suppressed
      FROM notification_stats_daily
      WHERE date BETWEEN ? AND ?
      GROUP BY category
      ORDER BY sent DESC
    ''', [fromDate, toDate]);
  }

  /// По каналам (VK vs SMS).
  static Future<Map<String, Map<String, int>>> getNotificationByChannel({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT channel,
        SUM(sent) AS sent,
        SUM(suppressed_by_cooldown) AS suppressed
      FROM notification_stats_daily
      WHERE date BETWEEN ? AND ?
      GROUP BY channel
    ''', [fromDate, toDate]);
    final result = <String, Map<String, int>>{};
    for (final r in rows) {
      result[r['channel'] as String] = {
        'sent': (r['sent'] as num).toInt(),
        'suppressed': (r['suppressed'] as num).toInt(),
      };
    }
    return result;
  }

  /// Суммарно за период.
  static Future<Map<String, int>> getNotificationTotals({
    required String fromDate,
    required String toDate,
  }) async {
    final db = await database;
    final r = await db.rawQuery('''
      SELECT
        COALESCE(SUM(sent), 0) AS sent,
        COALESCE(SUM(suppressed_by_cooldown), 0) AS suppressed
      FROM notification_stats_daily
      WHERE date BETWEEN ? AND ?
    ''', [fromDate, toDate]);
    final m = r.first;
    return {
      'sent': (m['sent'] as num).toInt(),
      'suppressed': (m['suppressed'] as num).toInt(),
    };
  }
  // ═══════════════════════════════════════════════════════════
  // STATS: Сегодня (мини-карточки)
  // ═══════════════════════════════════════════════════════════

  static Future<Map<String, int>> getTodayStats(String date) async {
    final db = await database;
    final r = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN event LIKE 'alarm_%' OR event LIKE 'frigate_%' THEN 1 ELSE 0 END), 0) AS alerts,
        COALESCE(SUM(CASE WHEN event IN ('turnOn','turnOff') THEN 1 ELSE 0 END), 0) AS actions
      FROM events
      WHERE timestamp >= ? AND timestamp < ?
    ''', [date, '$date 23:59:59']);
    final m = r.first;
    return {
      'alerts': (m['alerts'] as num).toInt(),
      'actions': (m['actions'] as num).toInt(),
    };
  }

  static Future<Map<String, double>> getTodayEnergy(String date) async {
    final db = await database;
    final energyR = await db.rawQuery('''
      SELECT COALESCE(SUM(totalEnergy), 0) AS kwh FROM energy_log WHERE date = ?
    ''', [date]);
    final tempR = await db.rawQuery('''
      SELECT COALESCE(AVG(temperature), 0) AS avg_temp
      FROM sensor_log WHERE timestamp >= ? AND timestamp < ? AND temperature IS NOT NULL
    ''', [date, '$date 23:59:59']);
    final e = energyR.first;
    final t = tempR.first;
    return {
      'kwh': (e['kwh'] as num).toDouble(),
      'avg_temp': (t['avg_temp'] as num).toDouble(),
    };
  }

  /// Аномалии за сегодня.
  static Future<List<Map<String, Object?>>> getAnomalies(String date) async {
    final db = await database;
    final result = <Map<String, Object?>>[];

    // 1. Battery < 20% (из devices.properties)
    final devices = await db.query('devices');
    for (final d in devices) {
      final propsRaw = d['properties'] as String?;
      if (propsRaw == null) continue;
      try {
        final props = _parseProps(propsRaw);
        final battery = (props['battery'] as num?)?.toInt();
        if (battery != null && battery < 20) {
          result.add({
            'type': 'battery',
            'title': '🔋 ${d['name']}',
            'subtitle': 'Батарея $battery%',
          });
        }
        final lq = (props['linkquality'] as num?)?.toInt();
        if (lq != null && lq < 30) {
          result.add({
            'type': 'linkquality',
            'title': '📶 ${d['name']}',
            'subtitle': 'Linkquality $lq (плохо)',
          });
        }
      } catch (_) {}
    }

    // 2. Offline > 5 раз за сегодня
    final offlineRows = await db.rawQuery('''
      SELECT deviceId, deviceName, COUNT(*) AS cnt
      FROM events
      WHERE event = 'offline' AND timestamp >= ? AND timestamp < ?
      GROUP BY deviceId
      HAVING cnt > 5
    ''', [date, '$date 23:59:59']);
    for (final r in offlineRows) {
      result.add({
        'type': 'offline',
        'title': '📡 ${r['deviceName'] ?? '—'}',
        'subtitle': 'Offline ${r['cnt']} раз сегодня',
      });
    }

    // 3. Энергия > 1.5× avg за 30 дней
    final energyAnomalies = await db.rawQuery('''
      WITH avg30 AS (
        SELECT deviceId, AVG(totalEnergy) AS avg_kwh
        FROM energy_log
        WHERE date >= date('now', '-30 days') AND date < ?
        GROUP BY deviceId
      )
      SELECT e.deviceId, e.deviceName, e.totalEnergy, a.avg_kwh
      FROM energy_log e
      JOIN avg30 a ON a.deviceId = e.deviceId
      WHERE e.date = ? AND e.totalEnergy > a.avg_kwh * 1.5
    ''', [date, date]);
    for (final r in energyAnomalies) {
      result.add({
        'type': 'energy',
        'title': '⚡ ${r['deviceName'] ?? '—'}',
        'subtitle': '${(r['totalEnergy'] as num).toStringAsFixed(2)} кВт·ч (норма ${(r['avg_kwh'] as num).toStringAsFixed(2)})',
      });
    }

    return result;
  }

  static Map<String, dynamic> _parseProps(String raw) {
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }
  // ═══════════════════════════════════════════════════════════
  // STATS: Сегодня С ФИЛЬТРОМ ПО КОМНАТЕ (v8.2.7)
  // ═══════════════════════════════════════════════════════════

  /// Алерты/действия за сегодня. Если [roomId] != null — только устройства комнаты.
  static Future<Map<String, int>> getTodayStatsByRoom({
    required String date,
    String? roomId,
  }) async {
    final db = await database;
    if (roomId == null) {
      return getTodayStats(date);
    }
    final r = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN e.event LIKE 'alarm_%' OR e.event LIKE 'frigate_%' THEN 1 ELSE 0 END), 0) AS alerts,
        COALESCE(SUM(CASE WHEN e.event IN ('turnOn','turnOff') THEN 1 ELSE 0 END), 0) AS actions
      FROM events e
      JOIN devices d ON d.id = e.deviceId
      WHERE d.roomId = ? AND e.timestamp >= ? AND e.timestamp < ?
    ''', [roomId, date, '$date 23:59:59']);
    final m = r.first;
    return {
      'alerts': (m['alerts'] as num).toInt(),
      'actions': (m['actions'] as num).toInt(),
    };
  }

  /// Энергия + средняя температура за сегодня. Если [roomId] != null — только комнаты.
  static Future<Map<String, double>> getTodayEnergyByRoom({
    required String date,
    String? roomId,
  }) async {
    final db = await database;
    if (roomId == null) {
      return getTodayEnergy(date);
    }
    final energyR = await db.rawQuery('''
      SELECT COALESCE(SUM(e.totalEnergy), 0) AS kwh
      FROM energy_log e
      JOIN devices d ON d.id = e.deviceId
      WHERE d.roomId = ? AND e.date = ?
    ''', [roomId, date]);
    final tempR = await db.rawQuery('''
      SELECT COALESCE(AVG(s.temperature), 0) AS avg_temp
      FROM sensor_log s
      JOIN devices d ON d.id = s.deviceId
      WHERE d.roomId = ? AND s.timestamp >= ? AND s.timestamp < ?
        AND s.temperature IS NOT NULL
    ''', [roomId, date, '$date 23:59:59']);
    final e = energyR.first;
    final t = tempR.first;
    return {
      'kwh': (e['kwh'] as num).toDouble(),
      'avg_temp': (t['avg_temp'] as num).toDouble(),
    };
  }

  /// Количество online-устройств в комнате (или всех).
  static Future<int> getOnlineCount({String? roomId}) async {
    final db = await database;
    final r = roomId == null
        ? await db.rawQuery('SELECT COUNT(*) AS cnt FROM devices WHERE isOnline = 1')
        : await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM devices WHERE isOnline = 1 AND roomId = ?',
      [roomId],
    );
    return (r.first['cnt'] as num).toInt();
  }

  /// Общее количество устройств в комнате (или всех).
  static Future<int> getTotalCount({String? roomId}) async {
    final db = await database;
    final r = roomId == null
        ? await db.rawQuery('SELECT COUNT(*) AS cnt FROM devices')
        : await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM devices WHERE roomId = ?',
      [roomId],
    );
    return (r.first['cnt'] as num).toInt();
  }

  /// Аномалии за сегодня. Если [roomId] != null — только устройства комнаты.
  static Future<List<Map<String, Object?>>> getAnomaliesByRoom({
    required String date,
    String? roomId,
  }) async {
    final db = await database;
    final result = <Map<String, Object?>>[];

    // ─── читаем пороги из настроек ───
    final batteryTh = int.tryParse(
        await getStatsSetting('anomaly_battery_threshold') ?? '20') ??
        20;
    final lqTh = int.tryParse(
        await getStatsSetting('anomaly_linkquality_threshold') ?? '30') ??
        30;
    final offlineTh = int.tryParse(
        await getStatsSetting('anomaly_offline_per_day') ?? '5') ??
        5;
    final energyMult = double.tryParse(
        await getStatsSetting('anomaly_energy_multiplier') ?? '1.5') ??
        1.5;

    // 1. Battery / Linkquality (из devices.properties)
    final devices = roomId == null
        ? await db.query('devices')
        : await db.query('devices', where: 'roomId = ?', whereArgs: [roomId]);
    for (final d in devices) {
      final propsRaw = d['properties'] as String?;
      if (propsRaw == null) continue;
      try {
        final props = _parseProps(propsRaw);
        final battery = (props['battery'] as num?)?.toInt();
        if (battery != null && battery < batteryTh) {
          result.add({
            'type': 'battery',
            'title': '🔋 ${d['name']}',
            'subtitle': 'Батарея $battery% (порог $batteryTh%)',
          });
        }
        final lq = (props['linkquality'] as num?)?.toInt();
        if (lq != null && lq < lqTh) {
          result.add({
            'type': 'linkquality',
            'title': '📶 ${d['name']}',
            'subtitle': 'Linkquality $lq (порог $lqTh)',
          });
        }
      } catch (_) {}
    }

    // 2. Offline > N раз за сегодня
    final offlineSql = roomId == null
        ? '''
          SELECT e.deviceId, e.deviceName, COUNT(*) AS cnt
          FROM events e
          WHERE e.event = 'offline' AND e.timestamp >= ? AND e.timestamp < ?
          GROUP BY e.deviceId
          HAVING cnt > ?
        '''
        : '''
          SELECT e.deviceId, e.deviceName, COUNT(*) AS cnt
          FROM events e
          JOIN devices d ON d.id = e.deviceId
          WHERE e.event = 'offline' AND d.roomId = ?
            AND e.timestamp >= ? AND e.timestamp < ?
          GROUP BY e.deviceId
          HAVING cnt > ?
        ''';
    final offlineArgs = roomId == null
        ? [date, '$date 23:59:59', offlineTh]
        : [roomId, date, '$date 23:59:59', offlineTh];
    final offlineRows = await db.rawQuery(offlineSql, offlineArgs);
    for (final r in offlineRows) {
      result.add({
        'type': 'offline',
        'title': '📡 ${r['deviceName'] ?? '—'}',
        'subtitle': 'Offline ${r['cnt']} раз сегодня (порог $offlineTh)',
      });
    }

    // 3. Энергия > N× avg за 30 дней
    final energySql = roomId == null
        ? '''
          WITH avg30 AS (
            SELECT deviceId, AVG(totalEnergy) AS avg_kwh
            FROM energy_log
            WHERE date >= date('now', '-30 days') AND date < ?
            GROUP BY deviceId
          )
          SELECT e.deviceId, e.deviceName, e.totalEnergy, a.avg_kwh
          FROM energy_log e
          JOIN avg30 a ON a.deviceId = e.deviceId
          WHERE e.date = ? AND e.totalEnergy > a.avg_kwh * ?
        '''
        : '''
          WITH avg30 AS (
            SELECT deviceId, AVG(totalEnergy) AS avg_kwh
            FROM energy_log
            WHERE date >= date('now', '-30 days') AND date < ?
            GROUP BY deviceId
          )
          SELECT e.deviceId, e.deviceName, e.totalEnergy, a.avg_kwh
          FROM energy_log e
          JOIN avg30 a ON a.deviceId = e.deviceId
          JOIN devices d ON d.id = e.deviceId
          WHERE e.date = ? AND d.roomId = ? AND e.totalEnergy > a.avg_kwh * ?
        ''';
    final energyArgs = roomId == null
        ? [date, date, energyMult]
        : [date, date, roomId, energyMult];
    final energyAnomalies = await db.rawQuery(energySql, energyArgs);
    for (final r in energyAnomalies) {
      result.add({
        'type': 'energy',
        'title': '⚡ ${r['deviceName'] ?? '—'}',
        'subtitle':
        '${(r['totalEnergy'] as num).toStringAsFixed(2)} кВт·ч (норма ${(r['avg_kwh'] as num).toStringAsFixed(2)}, ×$energyMult)',
      });
    }

    return result;
  }
  // ═══════════════════════════════════════════════════════════
  // RETENTION: удаление старых событий
  // ═══════════════════════════════════════════════════════════

  /// Удаляет события старше `events_retention_days` (default 30).
  /// Возвращает количество удалённых.
  static Future<int> cleanupOldEvents() async {
    final daysStr = await getStatsSetting('events_retention_days') ?? '30';
    final days = int.tryParse(daysStr) ?? 30;
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .toIso8601String();
    final db = await database;
    return db.delete('events', where: 'timestamp < ?', whereArgs: [cutoff]);
  }
}