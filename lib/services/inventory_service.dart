import 'package:drift/drift.dart';
import '../database/database.dart';
import 'database_service.dart';

class InventoryService {
  final DatabaseService _db = DatabaseService.instance;

  // Obtener inventario de un producto en una ubicación específica
  Future<Inventory?> getInventory({
    required int productId,
    int? storeId,
    int? warehouseId,
  }) async {
    final db = await _db.database;
    
    if (storeId != null) {
      return await (db.select(db.inventories)
            ..where((i) => i.productId.equals(productId) & i.storeId.equals(storeId)))
          .getSingleOrNull();
    } else if (warehouseId != null) {
      return await (db.select(db.inventories)
            ..where((i) => i.productId.equals(productId) & i.warehouseId.equals(warehouseId)))
          .getSingleOrNull();
    }
    
    return null;
  }

  // Obtener todo el inventario de una tienda
  Future<List<Inventory>> getStoreInventory(int storeId) async {
    final db = await _db.database;
    return await (db.select(db.inventories)
          ..where((i) => i.storeId.equals(storeId)))
        .get();
  }

  // Obtener todo el inventario de un almacén
  Future<List<Inventory>> getWarehouseInventory(int warehouseId) async {
    final db = await _db.database;
    return await (db.select(db.inventories)
          ..where((i) => i.warehouseId.equals(warehouseId)))
        .get();
  }

  // Obtener inventario global (suma de todas las ubicaciones)
  Future<Map<int, double>> getGlobalInventory() async {
    final db = await _db.database;
    final inventories = await db.select(db.inventories).get();
    
    final Map<int, double> globalInventory = {};
    for (var inventory in inventories) {
      globalInventory[inventory.productId] = 
          (globalInventory[inventory.productId] ?? 0) + inventory.quantity;
    }
    
    return globalInventory;
  }

  // Obtener inventario de un producto específico
  Future<double> getProductInventory(int productId) async {
    final db = await _db.database;
    final inventories = await (db.select(db.inventories)
          ..where((i) => i.productId.equals(productId)))
        .get();
    
    return inventories.fold<double>(0, (sum, inv) => sum + inv.quantity);
  }

  // Actualizar inventario (agregar cantidad)
  Future<void> addInventory({
    required int productId,
    required double quantity,
    int? storeId,
    int? warehouseId,
  }) async {
    final db = await _db.database;
    
    await db.transaction(() async {
      var inventory = await getInventory(
        productId: productId,
        storeId: storeId,
        warehouseId: warehouseId,
      );
      
      if (inventory != null) {
        // Actualizar existente
        await (db.update(db.inventories)
              ..where((i) => i.id.equals(inventory.id)))
            .write(InventoriesCompanion(
              quantity: Value(inventory.quantity + quantity),
              updatedAt: Value(DateTime.now()),
            ));
      } else {
        // Crear nuevo
        await db.into(db.inventories).insert(InventoriesCompanion.insert(
          productId: productId,
          storeId: Value(storeId),
          warehouseId: Value(warehouseId),
          quantity: quantity,
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
      }
    });
  }

  // Restar inventario
  Future<void> subtractInventory({
    required int productId,
    required double quantity,
    int? storeId,
    int? warehouseId,
  }) async {
    final db = await _db.database;
    
    await db.transaction(() async {
      var inventory = await getInventory(
        productId: productId,
        storeId: storeId,
        warehouseId: warehouseId,
      );
      
      if (inventory != null && inventory.quantity >= quantity) {
        await (db.update(db.inventories)
              ..where((i) => i.id.equals(inventory.id)))
            .write(InventoriesCompanion(
              quantity: Value(inventory.quantity - quantity),
              updatedAt: Value(DateTime.now()),
            ));
      } else {
        throw Exception('Inventario insuficiente');
      }
    });
  }

  // Transferir inventario
  Future<void> transferInventory({
    required int productId,
    required double quantity,
    int? fromStoreId,
    int? fromWarehouseId,
    int? toStoreId,
    int? toWarehouseId,
  }) async {
    final db = await _db.database;
    
    await db.transaction(() async {
      // Restar del origen
      await subtractInventory(
        productId: productId,
        quantity: quantity,
        storeId: fromStoreId,
        warehouseId: fromWarehouseId,
      );
      
      // Agregar al destino
      await addInventory(
        productId: productId,
        quantity: quantity,
        storeId: toStoreId,
        warehouseId: toWarehouseId,
      );
    });
  }
}
