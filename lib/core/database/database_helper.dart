import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'dart:io' show Platform, Directory;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('launchdesk.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory('${appDir.path}/LaunchDesk');
    if (!await dbDir.exists()) await dbDir.create(recursive: true);
    final path = join(dbDir.path, filePath);
    final factory = (Platform.isAndroid || Platform.isIOS)
        ? mobile.databaseFactory
        : databaseFactoryFfi;
    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar_path TEXT,
        active_theme_id TEXT DEFAULT 'default_dark',
        preferences TEXT DEFAULT '{}',
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        last_used TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS themes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT DEFAULT '',
        author TEXT DEFAULT 'User',
        version TEXT DEFAULT '1.0.0',
        data TEXT NOT NULL,
        thumbnail TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedules (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        repeat TEXT DEFAULT 'none',
        repeat_days TEXT DEFAULT '[]',
        color INTEGER DEFAULT 4280391380,
        priority TEXT DEFAULT 'medium',
        icon TEXT DEFAULT 'calendar',
        enable_notification INTEGER DEFAULT 1,
        notify_minutes_before INTEGER DEFAULT 5,
        status TEXT DEFAULT 'upcoming',
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS apps (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        target TEXT NOT NULL,
        icon_path TEXT,
        custom_icon_data TEXT,
        icon_color INTEGER DEFAULT 4280391380,
        category TEXT,
        group_id TEXT,
        is_favorite INTEGER DEFAULT 0,
        is_pinned INTEGER DEFAULT 0,
        sort_order INTEGER DEFAULT 0,
        last_opened TEXT,
        open_count INTEGER DEFAULT 0,
        tags TEXT DEFAULT '[]',
        metadata TEXT DEFAULT '{}',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_groups (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        name TEXT NOT NULL,
        color INTEGER DEFAULT 4280391380,
        icon_path TEXT,
        is_expanded INTEGER DEFAULT 1,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS widgets (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        type TEXT NOT NULL,
        title TEXT DEFAULT '',
        is_visible INTEGER DEFAULT 1,
        x REAL DEFAULT 0,
        y REAL DEFAULT 0,
        width REAL DEFAULT 200,
        height REAL DEFAULT 150,
        sort_order INTEGER DEFAULT 0,
        settings TEXT DEFAULT '{}',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id TEXT PRIMARY KEY DEFAULT 'global',
        profile_id TEXT DEFAULT 'default',
        data TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        title TEXT NOT NULL,
        content TEXT DEFAULT '',
        color INTEGER DEFAULT 2030043422,
        is_pinned INTEGER DEFAULT 0,
        tags TEXT DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        text TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 1,
        due_date TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        title TEXT NOT NULL,
        body TEXT DEFAULT '',
        type TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS layouts (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        is_active INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS statistics (
        id TEXT PRIMARY KEY,
        profile_id TEXT DEFAULT 'default',
        date TEXT NOT NULL,
        apps_opened INTEGER DEFAULT 0,
        schedules_completed INTEGER DEFAULT 0,
        todos_completed INTEGER DEFAULT 0,
        active_minutes INTEGER DEFAULT 0,
        data TEXT DEFAULT '{}'
      )
    ''');

    // Insert default profile
    await db.insert('users', {
      'id': 'default',
      'name': 'User',
      'active_theme_id': 'default_dark',
      'preferences': '{}',
      'is_default': 1,
      'created_at': DateTime.now().toIso8601String(),
      'last_used': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Future migrations here
  }

  // ─── Generic CRUD ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> queryAll(String table,
      {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<Map<String, dynamic>?> queryOne(String table, String id) async {
    final db = await database;
    final results = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWhere(String table, String where, List<dynamic> args) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: args);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
    _database = null;
  }
}
