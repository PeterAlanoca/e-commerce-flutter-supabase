import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'database_service.dart';
import 'inventory_service.dart';

class PurchaseService {
  final DatabaseService _db = DatabaseService.instance;
  final InventoryService _inventoryService = InventoryService();
  final Uuid _uuid = const Uuid();

  Future<Purchase> createPurchase({
    required DateTime date,
    int? warehouseId,
    int? storeId,
    int? employeeId,
    required List<Map<String, dynamic>> items, // {productId, productName, quantity, unitPrice, total}
    String? notes,
  }) async {
    final db = await _db.database;
    
    // Calcular total
    final total = items.fold<double>(
      0.0,
      (sum, item) => sum + (item['total'] as num).toDouble(),
    );
    
    // Generar número de compra
    final number = 'COMP-${DateTime.now().millisecondsSinceEpoch}';
    
    return await db.transaction(() async {
      // Guardar compra
      final purchaseCompanion = PurchasesCompanion.insert(
        number: number,
        date: date,
        warehouseId: Value(warehouseId),
        storeId: Value(storeId),
        employeeId: Value(employeeId),
        total: total,
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isSynced: const Value(false),
      );
      
      final purchaseId = await db.into(db.purchases).insert(purchaseCompanion);
      
      // Guardar items de compra
      for (var item in items) {
        await db.into(db.purchaseItems).insert(PurchaseItemsCompanion.insert(
          purchaseId: purchaseId,
          productId: item['productId'] as int,
          productName: item['productName'] as String,
          quantity: (item['quantity'] as num).toDouble(),
          unitPrice: (item['unitPrice'] as num).toDouble(),
          total: (item['total'] as num).toDouble(),
        ));
        
        // Actualizar inventario
        await _inventoryService.addInventory(
          productId: item['productId'] as int,
          quantity: (item['quantity'] as num).toDouble(),
          warehouseId: warehouseId,
          storeId: storeId,
        );
      }
      
      return await (db.select(db.purchases)..where((p) => p.id.equals(purchaseId))).getSingle();
    });
  }

  Future<List<Purchase>> getPurchases({
    int? warehouseId,
    int? storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db.database;
    
    var query = db.select(db.purchases);
    
    if (warehouseId != null) {
      query = query..where((p) => p.warehouseId.equals(warehouseId));
    }
    
    if (storeId != null) {
      query = query..where((p) => p.storeId.equals(storeId));
    }
    
    if (startDate != null) {
      query = query..where((p) => p.date.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      query = query..where((p) => p.date.isSmallerOrEqualValue(endDate));
    }
    
    final results = await query.get();
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  Future<Purchase?> getPurchaseById(int id) async {
    final db = await _db.database;
    return await (db.select(db.purchases)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<PurchaseItem>> getPurchaseItems(int purchaseId) async {
    final db = await _db.database;
    return await (db.select(db.purchaseItems)
          ..where((pi) => pi.purchaseId.equals(purchaseId)))
        .get();
  }

  Future<void> deletePurchase(int id) async {
    final db = await _db.database;
    final purchase = await getPurchaseById(id);
    
    if (purchase != null) {
      await db.transaction(() async {
        // Obtener items
        final items = await getPurchaseItems(id);
        
        // Revertir inventario
        for (var item in items) {
          await _inventoryService.subtractInventory(
            productId: item.productId,
            quantity: item.quantity,
            warehouseId: purchase.warehouseId,
            storeId: purchase.storeId,
          );
        }
        
        // Eliminar items
        await (db.delete(db.purchaseItems)..where((pi) => pi.purchaseId.equals(id))).go();
        
        // Eliminar compra
        await (db.delete(db.purchases)..where((p) => p.id.equals(id))).go();
      });
    }
  }
}
