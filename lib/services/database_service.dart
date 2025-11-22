import 'package:drift/drift.dart';
import '../database/database.dart';

class DatabaseService {
  static DatabaseService? _instance;
  AppDatabase? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<AppDatabase> get database async {
    _database ??= AppDatabase();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
