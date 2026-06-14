import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/usage_record.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'smart_toilet.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usage_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deviceId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationSeconds INTEGER DEFAULT 0,
        waterUsageMl INTEGER DEFAULT 0,
        mode TEXT DEFAULT 'bidet'
      )
    ''');
    await db.execute('''
      CREATE TABLE device_settings (
        deviceId TEXT PRIMARY KEY,
        name TEXT,
        mqttTopic TEXT,
        seatTemperature INTEGER DEFAULT 25,
        waterTemperature INTEGER DEFAULT 30
      )
    ''');
  }

  Future<int> insertUsageRecord(UsageRecord record) async {
    final db = await database;
    return db.insert('usage_records', record.toMap());
  }

  Future<int> updateUsageRecord(UsageRecord record) async {
    final db = await database;
    return db.update(
      'usage_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<List<UsageRecord>> getUsageRecords({
    String? deviceId,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (deviceId != null) {
      conditions.add('deviceId = ?');
      args.add(deviceId);
    }
    if (from != null) {
      conditions.add('startTime >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('startTime <= ?');
      args.add(to.toIso8601String());
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    final maps = await db.query(
      'usage_records',
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'startTime DESC',
      limit: limit,
    );
    return maps.map((m) => UsageRecord.fromMap(m)).toList();
  }

  Future<Map<String, dynamic>> getStatistics({
    String? deviceId,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (deviceId != null) {
      conditions.add('deviceId = ?');
      args.add(deviceId);
    }
    if (from != null) {
      conditions.add('startTime >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('startTime <= ?');
      args.add(to.toIso8601String());
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as totalUses,
        COALESCE(SUM(durationSeconds), 0) as totalDuration,
        COALESCE(SUM(waterUsageMl), 0) as totalWaterUsage,
        COALESCE(AVG(durationSeconds), 0) as avgDuration
      FROM usage_records
      ${where != null ? 'WHERE $where' : ''}
    ''', args);

    return result.first;
  }

  Future<int> getTodayUsageCount(String deviceId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final db = await database;
    final result = await db.query(
      'usage_records',
      where: 'deviceId = ? AND startTime >= ?',
      whereArgs: [deviceId, today.toIso8601String()],
    );
    return result.length;
  }

  Future<void> saveDeviceSettings(Map<String, dynamic> settings) async {
    final db = await database;
    await db.insert(
      'device_settings',
      settings,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getDeviceSettings(String deviceId) async {
    final db = await database;
    final results = await db.query(
      'device_settings',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
