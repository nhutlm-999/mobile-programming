import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:tvinh_fruit_sell/model/fruit.dart';

class DatabaseHelper {
  static const _databaseFileName = 'recurring_bills.db';
  static const _databaseVersion = 1;
  static const _tableName = 'bills';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Flow:
  // 1) Init DB ->
  // 1a) tao luong ket noi,
  // 1b) open db file,
  // 1c) tao du cac table (create tables)
  // 2) ... crud

  // Nếu dùng Web để test: chạy thêm lệnh sau trước khi run dự án
  // dart run sqflite_common_ffi_web:setup
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb; // chuyển factory khi chạy web
      return openDatabase(
        _databaseFileName,
        version: _databaseVersion,
        onCreate: _onCreate,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseFileName);
      // Debug: in ra để xác nhận file được tạo ở đâu
      print('>>> DB path: $path');
      return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
     CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        origin TEXT NOT NULL,
        price REAL NOT NULL,
        expiredDate TEXT NOT NULL
     )
   ''');

    await db.insert(_tableName, {
      'name': 'Cam Oi Xoai',
      'origin': 'Canto',
      'price': 100.0,
      'expiredDate': '2023-12-01',
    });
    ;
  }

  Future<List<Fruit>> getList() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query(
      _tableName,
      orderBy: 'id DESC',
    );
    return [for (final map in maps) Fruit.fromMap(map)];
  }

  Future<int> insert(Fruit object) async {
    final db = await database;
    return db.insert(
      _tableName,
      object.toMap(),
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Nếu có id bị đụng độ, thì replace ghi đè lên
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Fruit object) async {
    final db = await database;
    return db.update(
      _tableName,
      object.toMap(),
      where: 'id = ?',
      whereArgs: [object.id],
    );
  }
}
