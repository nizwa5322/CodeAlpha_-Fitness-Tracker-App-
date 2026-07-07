import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/fitness_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        workoutDuration INTEGER NOT NULL,
        workoutType TEXT NOT NULL
      )
    ''');

    // Insert sample data for testing
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();
    final sampleRecords = [
      FitnessRecord(
        date: now.subtract(const Duration(days: 6)),
        steps: 8500,
        calories: 320,
        workoutDuration: 35,
        workoutType: 'Running',
      ),
      FitnessRecord(
        date: now.subtract(const Duration(days: 5)),
        steps: 6200,
        calories: 250,
        workoutDuration: 30,
        workoutType: 'Cycling',
      ),
      FitnessRecord(
        date: now.subtract(const Duration(days: 4)),
        steps: 10000,
        calories: 400,
        workoutDuration: 45,
        workoutType: 'Weightlifting',
      ),
      FitnessRecord(
        date: now.subtract(const Duration(days: 3)),
        steps: 4500,
        calories: 180,
        workoutDuration: 20,
        workoutType: 'Yoga',
      ),
      FitnessRecord(
        date: now.subtract(const Duration(days: 2)),
        steps: 7200,
        calories: 280,
        workoutDuration: 40,
        workoutType: 'Walking',
      ),
      FitnessRecord(
        date: now.subtract(const Duration(days: 1)),
        steps: 9200,
        calories: 350,
        workoutDuration: 50,
        workoutType: 'Swimming',
      ),
    ];

    for (var record in sampleRecords) {
      await db.insert('records', record.toMap());
    }
  }

  // Insert a new record
  Future<int> insertRecord(FitnessRecord record) async {
    final db = await database;
    return await db.insert(
      'records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all records
  Future<List<FitnessRecord>> getRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      orderBy: 'date DESC',
    );
    return maps.map((map) => FitnessRecord.fromMap(map)).toList();
  }

  // Get records by date range
  Future<List<FitnessRecord>> getRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => FitnessRecord.fromMap(map)).toList();
  }

  // Update a record
  Future<int> updateRecord(FitnessRecord record) async {
    final db = await database;
    return await db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete a record
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get total count of records
  Future<int> getRecordCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM records');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get statistics (REMOVED complex query, simplified)
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(steps) as totalSteps,
        SUM(calories) as totalCalories,
        SUM(workoutDuration) as totalDuration,
        COUNT(*) as totalActivities,
        AVG(steps) as avgSteps,
        AVG(calories) as avgCalories
      FROM records
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }
    return {
      'totalSteps': 0,
      'totalCalories': 0,
      'totalDuration': 0,
      'totalActivities': 0,
      'avgSteps': 0,
      'avgCalories': 0,
    };
  }

  // Get today's record
  Future<FitnessRecord?> getTodayRecord() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final records = await getRecordsByDateRange(startOfDay, endOfDay);
    return records.isNotEmpty ? records.first : null;
  }

  // Get weekly records (last 7 days)
  Future<List<FitnessRecord>> getWeeklyRecords() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return await getRecordsByDateRange(weekAgo, now);
  }

  // Get monthly records
  Future<List<FitnessRecord>> getMonthlyRecords() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    return await getRecordsByDateRange(firstDay, now);
  }

  // Delete all records (for testing)
  Future<void> deleteAllRecords() async {
    final db = await database;
    await db.delete('records');
  }
}
