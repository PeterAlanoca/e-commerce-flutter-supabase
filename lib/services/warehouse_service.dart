import 'package:drift/drift.dart';
import '../database/database.dart';
import 'database_service.dart';

class WarehouseService {
  final DatabaseService _db = DatabaseService.instance;

  Future<List<Warehouse>> getAllWarehouses() async {
    final db = await _db.database;
    return await db.select(db.warehouses).get();
  }

  Future<Warehouse?> getWarehouseById(int id) async {
    final db = await _db.database;
    return await (db.select(db.warehouses)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<int> createWarehouse(WarehousesCompanion warehouse) async {
    final db = await _db.database;
    return await db.into(db.warehouses).insert(warehouse);
  }

  Future<void> updateWarehouse(int id, WarehousesCompanion warehouse) async {
    final db = await _db.database;
    await (db.update(db.warehouses)..where((w) => w.id.equals(id))).write(warehouse);
  }

  Future<void> deleteWarehouse(int id) async {
    final db = await _db.database;
    await (db.delete(db.warehouses)..where((w) => w.id.equals(id))).go();
  }
}

