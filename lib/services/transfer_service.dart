import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'database_service.dart';
import 'inventory_service.dart';

class TransferService {
  final DatabaseService _db = DatabaseService.instance;
  final InventoryService _inventoryService = InventoryService();
  final Uuid _uuid = const Uuid();

  Future<Transfer> createTransfer({
    required DateTime date,
    required String type, // 'store_to_store', 'warehouse_to_warehouse', etc.
    int? fromStoreId,
    int? fromWarehouseId,
    int? toStoreId,
    int? toWarehouseId,
    int? employeeId,
    required List<Map<String, dynamic>> items, // {productId, productName, quantity}
    String? notes,
  }) async {
    final db = await _db.database;
    
    // Verificar inventario en el origen
    for (var item in items) {
      final inventory = await _inventoryService.getInventory(
        productId: item['productId'] as int,
        storeId: fromStoreId,
        warehouseId: fromWarehouseId,
      );
      
      if (inventory == null || inventory.quantity < (item['quantity'] as num).toDouble()) {
        throw Exception(
          'No hay suficiente inventario para transferir el producto ${item['productName']}',
        );
      }
    }
    
    // Generar número de transferencia
    final number = 'TRANS-${DateTime.now().millisecondsSinceEpoch}';
    
    return await db.transaction(() async {
      // Guardar transferencia
      final transferCompanion = TransfersCompanion.insert(
        number: number,
        date: date,
        type: type,
        status: 'completed', // Completada inmediatamente
        fromStoreId: Value(fromStoreId),
        fromWarehouseId: Value(fromWarehouseId),
        toStoreId: Value(toStoreId),
        toWarehouseId: Value(toWarehouseId),
        employeeId: Value(employeeId),
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isSynced: const Value(false),
      );
      
      final transferId = await db.into(db.transfers).insert(transferCompanion);
      
      // Guardar items de transferencia
      for (var item in items) {
        await db.into(db.transferItems).insert(TransferItemsCompanion.insert(
          transferId: transferId,
          productId: item['productId'] as int,
          productName: item['productName'] as String,
          quantity: (item['quantity'] as num).toDouble(),
        ));
        
        // Realizar transferencia de inventario
        await _inventoryService.transferInventory(
          productId: item['productId'] as int,
          quantity: (item['quantity'] as num).toDouble(),
          fromStoreId: fromStoreId,
          fromWarehouseId: fromWarehouseId,
          toStoreId: toStoreId,
          toWarehouseId: toWarehouseId,
        );
      }
      
      return await (db.select(db.transfers)..where((t) => t.id.equals(transferId))).getSingle();
    });
  }

  Future<List<Transfer>> getTransfers({
    int? storeId,
    int? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    final db = await _db.database;
    
    var query = db.select(db.transfers);
    
    if (storeId != null) {
      query = query..where((t) => 
        t.fromStoreId.equals(storeId) | t.toStoreId.equals(storeId));
    }
    
    if (warehouseId != null) {
      query = query..where((t) => 
        t.fromWarehouseId.equals(warehouseId) | t.toWarehouseId.equals(warehouseId));
    }
    
    if (type != null) {
      query = query..where((t) => t.type.equals(type));
    }
    
    if (startDate != null) {
      query = query..where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      query = query..where((t) => t.date.isSmallerOrEqualValue(endDate));
    }
    
    final results = await query.get();
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  Future<Transfer?> getTransferById(int id) async {
    final db = await _db.database;
    return await (db.select(db.transfers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<TransferItem>> getTransferItems(int transferId) async {
    final db = await _db.database;
    return await (db.select(db.transferItems)
          ..where((ti) => ti.transferId.equals(transferId)))
        .get();
  }

  Future<void> updateTransferStatus(int id, String status) async {
    final db = await _db.database;
    await (db.update(db.transfers)..where((t) => t.id.equals(id)))
        .write(TransfersCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
          isSynced: const Value(false),
        ));
  }

  Future<void> deleteTransfer(int id) async {
    final db = await _db.database;
    final transfer = await getTransferById(id);
    
    if (transfer != null && transfer.status == 'pending') {
      await db.transaction(() async {
        // Obtener items
        final items = await getTransferItems(id);
        
        // Revertir transferencia de inventario
        for (var item in items) {
          await _inventoryService.transferInventory(
            productId: item.productId,
            quantity: item.quantity,
            fromStoreId: transfer.toStoreId,
            fromWarehouseId: transfer.toWarehouseId,
            toStoreId: transfer.fromStoreId,
            toWarehouseId: transfer.fromWarehouseId,
          );
        }
        
        // Eliminar items
        await (db.delete(db.transferItems)..where((ti) => ti.transferId.equals(id))).go();
        
        // Eliminar transferencia
        await (db.delete(db.transfers)..where((t) => t.id.equals(id))).go();
      });
    }
  }
}
