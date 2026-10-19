import 'package:lab4_15oct/data/models/bill.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BillLocalDataSource {
  BillLocalDataSource._internal();

  static final BillLocalDataSource instance = BillLocalDataSource._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'recurring_bills.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bills(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bill_name TEXT NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            status TEXT NOT NULL DEFAULT 'Unpaid',
            due_date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Bill _fromMap(Map<String, Object?> map) {
    return Bill(
      id: map['id'] as int?,
      billName: map['bill_name'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: map['status'] as String,
      dueDate: map['due_date'] as String,
    );
  }

  Map<String, Object?> _toMap(Bill bill) {
    return {
      'id': bill.id,
      'bill_name': bill.billName,
      'category': bill.category,
      'amount': bill.amount,
      'status': bill.status,
      'due_date': bill.dueDate,
    };
  }

  Future<Bill> insertBill(Bill bill) async {
    final db = await database;
    final id = await db.insert(
      'bills',
      _toMap(bill),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return bill.copyWith(id: id);
  }

  Future<List<Bill>> getAllBills() async {
    final db = await database;
    final maps = await db.query('bills', orderBy: 'due_date ASC, id ASC');
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<Bill?> getBillById(int id) async {
    final db = await database;
    final maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return _fromMap(maps.first);
  }

  Future<int> updateBill(Bill bill) async {
    if (bill.id == null) {
      throw ArgumentError('Bill phải có ID để cập nhật.');
    }

    final db = await database;

    return db.update(
      'bills',
      _toMap(bill),
      where: 'id = ?',
      whereArgs: [bill.id],
    );
  }

  Future<int> deleteBill(int id) async {
    final db = await database;

    return db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }
}
