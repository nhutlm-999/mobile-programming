import 'package:flutter/foundation.dart';
import 'package:lab3/model/brand.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static const _databaseName = 'ComputerStoreDB.db';
  static const _brandTable = 'brands';
  static const _categoryTable = 'categories';
  static const _computerTable = 'computers';
  // Singleton pattern (giữ đúng chuẩn sqlite_intro)
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return openDatabase(
        _databaseName,
        version: 1,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
      );
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_brandTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_name TEXT NOT NULL,
        country TEXT NOT NULL,
        founded_year INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $_categoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $_computerTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        brand_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        cpu TEXT NOT NULL,
        ram INTEGER NOT NULL,
        storage INTEGER NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        sold_quantity INTEGER NOT NULL,
        is_featured INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (brand_id) REFERENCES $_brandTable (id),
        FOREIGN KEY (category_id) REFERENCES $_categoryTable (id)
      )
    ''');
    await _seedSampleData(db);
  }

  // Task 1: Insert sample data (Minimum: 5 Brands, 3 Categories, 15 Computers)
  Future<void> _seedSampleData(Database db) async {
    // 5 Brands
    final brands = [
      {'brand_name': 'ASUS', 'country': 'Taiwan', 'founded_year': 1989},
      {'brand_name': 'Dell', 'country': 'USA', 'founded_year': 1984},
      {'brand_name': 'HP', 'country': 'USA', 'founded_year': 1939},
      {'brand_name': 'Acer', 'country': 'Taiwan', 'founded_year': 1976},
      {'brand_name': 'Lenovo', 'country': 'China', 'founded_year': 1984},
    ];
    for (final b in brands) {
      await db.insert(_brandTable, b);
    }
    // 3 Categories
    final categories = [
      {'category_name': 'Laptop'},
      {'category_name': 'Desktop'},
      {'category_name': 'Component'},
    ];
    for (final c in categories) {
      await db.insert(_categoryTable, c);
    }
    // 15 Computers
    final computers = [
      {
        'product_name': 'ROG Strix G16',
        'brand_id': 1,
        'category_id': 1,
        'cpu': 'Intel Core i7',
        'ram': 16,
        'storage': 1024,
        'price': 1250.0,
        'stock': 15,
        'sold_quantity': 32,
        'is_featured': 1,
      },
      {
        'product_name': 'Vivobook S15',
        'brand_id': 1,
        'category_id': 1,
        'cpu': 'Intel Core i5',
        'ram': 16,
        'storage': 512,
        'price': 780.0,
        'stock': 20,
        'sold_quantity': 45,
        'is_featured': 0,
      },
      {
        'product_name': 'TUF Gaming A15',
        'brand_id': 1,
        'category_id': 1,
        'cpu': 'AMD Ryzen 7',
        'ram': 16,
        'storage': 512,
        'price': 950.0,
        'stock': 8,
        'sold_quantity': 28,
        'is_featured': 1,
      },
      {
        'product_name': 'ROG Maximus Z790 Board',
        'brand_id': 1,
        'category_id': 3,
        'cpu': 'Socket LGA1700',
        'ram': 64,
        'storage': 256,
        'price': 420.0,
        'stock': 4,
        'sold_quantity': 12,
        'is_featured': 0,
      },
      {
        'product_name': 'Dell XPS 15',
        'brand_id': 2,
        'category_id': 1,
        'cpu': 'Intel Core i9',
        'ram': 32,
        'storage': 1024,
        'price': 1850.0,
        'stock': 6,
        'sold_quantity': 19,
        'is_featured': 1,
      },
      {
        'product_name': 'Dell Inspiron 14',
        'brand_id': 2,
        'category_id': 1,
        'cpu': 'Intel Core i5',
        'ram': 8,
        'storage': 256,
        'price': 480.0,
        'stock': 25,
        'sold_quantity': 60,
        'is_featured': 0,
      },
      {
        'product_name': 'OptiPlex 7010 Tower',
        'brand_id': 2,
        'category_id': 2,
        'cpu': 'Intel Core i7',
        'ram': 16,
        'storage': 512,
        'price': 890.0,
        'stock': 12,
        'sold_quantity': 22,
        'is_featured': 0,
      },
      {
        'product_name': 'HP Spectre x360',
        'brand_id': 3,
        'category_id': 1,
        'cpu': 'Intel Core i7',
        'ram': 16,
        'storage': 1024,
        'price': 1400.0,
        'stock': 3,
        'sold_quantity': 18,
        'is_featured': 1,
      },
      {
        'product_name': 'HP Pavilion Gaming Desktop',
        'brand_id': 3,
        'category_id': 2,
        'cpu': 'AMD Ryzen 5',
        'ram': 16,
        'storage': 512,
        'price': 750.0,
        'stock': 10,
        'sold_quantity': 25,
        'is_featured': 0,
      },
      {
        'product_name': 'HP Omen 45L',
        'brand_id': 3,
        'category_id': 2,
        'cpu': 'Intel Core i9',
        'ram': 64,
        'storage': 2048,
        'price': 2400.0,
        'stock': 2,
        'sold_quantity': 9,
        'is_featured': 1,
      },
      {
        'product_name': 'Acer Nitro 5',
        'brand_id': 4,
        'category_id': 1,
        'cpu': 'Intel Core i5',
        'ram': 8,
        'storage': 512,
        'price': 690.0,
        'stock': 18,
        'sold_quantity': 50,
        'is_featured': 1,
      },
      {
        'product_name': 'Acer Predator Orion 3000',
        'brand_id': 4,
        'category_id': 2,
        'cpu': 'Intel Core i7',
        'ram': 32,
        'storage': 1024,
        'price': 1350.0,
        'stock': 0,
        'sold_quantity': 15,
        'is_featured': 0,
      },
      {
        'product_name': 'Acer Predator Bifrost GPU Kit',
        'brand_id': 4,
        'category_id': 3,
        'cpu': 'Intel Arc A770',
        'ram': 16,
        'storage': 256,
        'price': 390.0,
        'stock': 7,
        'sold_quantity': 14,
        'is_featured': 0,
      },
      {
        'product_name': 'Lenovo ThinkPad X1 Carbon',
        'brand_id': 5,
        'category_id': 1,
        'cpu': 'Intel Core i7',
        'ram': 32,
        'storage': 1024,
        'price': 1650.0,
        'stock': 9,
        'sold_quantity': 35,
        'is_featured': 1,
      },
      {
        'product_name': 'Lenovo Legion Tower 5i',
        'brand_id': 5,
        'category_id': 2,
        'cpu': 'Intel Core i7',
        'ram': 32,
        'storage': 2048,
        'price': 1550.0,
        'stock': 4,
        'sold_quantity': 21,
        'is_featured': 1,
      },
    ];
    for (final comp in computers) {
      await db.insert(_computerTable, comp);
    }
  }

  // =========================================================================
  // TASK 2: BRAND MANAGEMENT
  // =========================================================================
  // 2.1 & 2.5: Lấy danh sách Brand kèm số lượng sản phẩm (hỗ trợ tìm kiếm theo tên/quốc gia)
  Future<List<Brand>> getBrands({String? keyword}) async {
    final db = await database;
    String whereClause = '';
    List<Object?> args = [];
    if (keyword != null && keyword.trim().isNotEmpty) {
      final kw = '%${keyword.trim()}%';
      whereClause = 'WHERE b.brand_name LIKE ? COLLATE NOCASE OR b.country LIKE ? COLLATE NOCASE';
      args = [kw, kw];
    }
    final maps = await db.rawQuery('''
      SELECT
        b.id,
        b.brand_name,
        b.country,
        b.founded_year,
        COUNT(c.id) AS totalProducts
      FROM $_brandTable b
      LEFT JOIN $_computerTable c ON b.id = c.brand_id
      $whereClause
      GROUP BY b.id
      ORDER BY b.brand_name ASC
    ''', args);
    return [for (final map in maps) Brand.fromJson(map)];
  }

  Future<bool> isBrandNameDuplicate(String brandName, {int? excludeId}) async {
    final db = await database;
    final maps = await db.query(
      _brandTable,
      where: excludeId != null
          ? 'LOWER(brand_name) = ? AND id != ?'
          : 'LOWER(brand_name) = ?',
      whereArgs: excludeId != null
          ? [brandName.toLowerCase(), excludeId]
          : [brandName.toLowerCase()],
    );

    return maps.isNotEmpty;
  }

  Future<int> insertBrand(Brand brand) async {
    final db = await database;
    return await db.insert(_brandTable, brand.toJson());
  }

  Future<int> updateBrand(Brand brand) async {
    final db = await database;
    return db.update(
      _brandTable,
      brand.toJson(),
      where: 'id = ?',
      whereArgs: [brand.id],
    );
  }

  Future<int> deleteBrand(int id) async {
    final db = await database;
    return await db.delete(_brandTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countComputersByBrand(int branchId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $_computerTable WHERE brand_id = ?',
      [branchId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
