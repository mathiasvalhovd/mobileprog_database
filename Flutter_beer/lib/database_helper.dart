import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Private constructor (singleton pattern)
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Getter to get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'my_database.db');
    
    // Print the database path for debugging
    print('Database path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE Test(
            id INTEGER PRIMARY KEY,
            name TEXT,
            value INTEGER,
            num REAL
          )
          '''
        );
      },
    );
  }

  // Insert a record into the Test table
  Future<int> insertRecord(Map<String, dynamic> record) async {
    Database db = await instance.database;
    return await db.insert('Test', record);
  }

  // Query all records from the Test table
  Future<List<Map<String, dynamic>>> queryAllRecords() async {
    Database db = await instance.database;
    return await db.query('Test');
  }
}
