import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../config/app_config.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConfig.databaseName);

    return await openDatabase(
      path,
      version: AppConfig.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        local_path TEXT NOT NULL,
        thumbnail_path TEXT,
        equipment_id TEXT NOT NULL,
        equipment_name TEXT,
        area_id TEXT,
        area_name TEXT,
        plant_id TEXT,
        plant_name TEXT,
        latitude REAL,
        longitude REAL,
        location_name TEXT,
        captured_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        severity TEXT,
        notes TEXT,
        tags TEXT,
        is_uploaded INTEGER DEFAULT 0,
        uploaded_at INTEGER,
        server_url TEXT,
        retry_count INTEGER DEFAULT 0,
        last_retry_at INTEGER,
        error_message TEXT,
        file_size INTEGER,
        mime_type TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE equipment (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT,
        type TEXT,
        area_id TEXT,
        plant_id TEXT,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        photo_id TEXT NOT NULL,
        action TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry_at INTEGER,
        error_message TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (photo_id) REFERENCES photos (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_photos_equipment_id ON photos(equipment_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_photos_captured_at ON photos(captured_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_photos_is_uploaded ON photos(is_uploaded)
    ''');

    await db.execute('''
      CREATE INDEX idx_sync_queue_status ON sync_queue(status)
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('photos');
    await db.delete('sync_queue');
    await db.delete('equipment');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
