import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'clinic_app.db');

    return await openDatabase(
      path,
      version: 3, // 🔺 bump version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ✅ Create tables (latest schema)
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE doctors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT,
        specialization TEXT,
        phone TEXT,
        email TEXT,
        experience INTEGER,
        availability TEXT,
        fee REAL,
        joinDate TEXT,
        clinicName TEXT,
        regNo TEXT,
        avatarPath TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctorId INTEGER NOT NULL,
        name TEXT NOT NULL,
        gender TEXT,
        age INTEGER,
        phone TEXT,
        email TEXT,
        bloodGroup TEXT,
        maritalStatus TEXT,
        address TEXT,
        conditionType TEXT,
        disease TEXT,
        notes TEXT,
        createdAt TEXT,
        FOREIGN KEY(doctorId) REFERENCES doctors(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        doctorId INTEGER NOT NULL,
        datetime TEXT NOT NULL,
        status TEXT,
        symptoms TEXT,
        diagnosis TEXT,
        treatment TEXT,
        paymentMode TEXT,
        FOREIGN KEY(patientId) REFERENCES patients(id),
        FOREIGN KEY(doctorId) REFERENCES doctors(id)
      )
    ''');
  }

  // ✅ Migration for older versions (adds new columns safely)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE doctors ADD COLUMN createdAt TEXT');
      } catch (e) {
        // ignore if already added
      }
    }
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table, orderBy: 'id DESC');
  }

  Future<int> update(String table, Map<String, dynamic> row, int id) async {
    final db = await database;
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }
}
