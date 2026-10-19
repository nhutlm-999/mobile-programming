import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:vinhvt9_sqlite/models/note.dart';

class DatabaseHelper {
  static const _databaseName = 'my_database.db';
  static const _noteTableName = 'notes';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    // if (_database != null) return _database!;
    // _database = await _initDatabase();
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_noteTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
  }

  // Get List
  Future<List<Note>> getNotes() async {
    final db = await database;
    List<Map<String, Object?>> maps = await db.query(
      _noteTableName,
      orderBy: 'id DESC',
    );

    return [for (final map in maps) Note.fromJson(map)];
  }

  // Create
}
