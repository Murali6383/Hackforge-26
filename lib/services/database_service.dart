import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/emergency_event.dart';
import '../models/safety_report.dart';

/// SQLite database service for offline caching of SOS events and reports
class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'safesphere.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE emergencies (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            userName TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            address TEXT,
            status TEXT NOT NULL,
            type TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            trackingPath TEXT,
            responderId TEXT,
            responderName TEXT,
            notes TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE safety_reports (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            userName TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            address TEXT,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            severity TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            isAnonymous INTEGER DEFAULT 0,
            upvotes INTEGER DEFAULT 0,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Insert emergency event (offline support)
  Future<void> insertEmergency(EmergencyEvent event) async {
    final db = await database;
    await db.insert(
      'emergencies',
      {
        ...event.toJson(),
        'trackingPath': jsonEncode(
          event.trackingPath.map((e) => e.toJson()).toList(),
        ),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all cached emergencies
  Future<List<EmergencyEvent>> getEmergencies() async {
    final db = await database;
    final maps = await db.query('emergencies', orderBy: 'timestamp DESC');
    return maps.map((m) {
      final json = Map<String, dynamic>.from(m);
      if (json['trackingPath'] is String) {
        json['trackingPath'] = jsonDecode(json['trackingPath']);
      }
      return EmergencyEvent.fromJson(json);
    }).toList();
  }

  /// Update emergency status
  Future<void> updateEmergencyStatus(String id, String status) async {
    final db = await database;
    await db.update(
      'emergencies',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get unsynced events for when internet returns
  Future<List<EmergencyEvent>> getUnsyncedEmergencies() async {
    final db = await database;
    final maps = await db.query(
      'emergencies',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return maps.map((m) {
      final json = Map<String, dynamic>.from(m);
      if (json['trackingPath'] is String) {
        json['trackingPath'] = jsonDecode(json['trackingPath']);
      }
      return EmergencyEvent.fromJson(json);
    }).toList();
  }

  /// Mark event as synced
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      'emergencies',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insert safety report
  Future<void> insertReport(SafetyReport report) async {
    final db = await database;
    await db.insert(
      'safety_reports',
      {
        ...report.toJson(),
        'isAnonymous': report.isAnonymous ? 1 : 0,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all reports
  Future<List<SafetyReport>> getReports() async {
    final db = await database;
    final maps = await db.query('safety_reports', orderBy: 'timestamp DESC');
    return maps.map((m) {
      final json = Map<String, dynamic>.from(m);
      json['isAnonymous'] = json['isAnonymous'] == 1;
      return SafetyReport.fromJson(json);
    }).toList();
  }
}
