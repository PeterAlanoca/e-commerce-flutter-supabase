import 'package:drift/drift.dart';
import '../database/database.dart';
import 'database_service.dart';

class StoreService {
  final DatabaseService _db = DatabaseService.instance;

  Future<List<Store>> getAllStores() async {
    final db = await _db.database;
    return await db.select(db.stores).get();
  }

  Future<Store?> getStoreById(int id) async {
    final db = await _db.database;
    return await (db.select(db.stores)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> createStore(StoresCompanion store) async {
    final db = await _db.database;
    return await db.into(db.stores).insert(store);
  }

  Future<void> updateStore(int id, StoresCompanion store) async {
    final db = await _db.database;
    await (db.update(db.stores)..where((s) => s.id.equals(id))).write(store);
  }

  Future<void> deleteStore(int id) async {
    final db = await _db.database;
    await (db.delete(db.stores)..where((s) => s.id.equals(id))).go();
  }
}

