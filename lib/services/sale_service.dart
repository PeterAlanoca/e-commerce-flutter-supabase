import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'database_service.dart';
import 'inventory_service.dart';

class SaleService {
  final DatabaseService _db = DatabaseService.instance;
  final InventoryService _inventoryService = InventoryService();
  final Uuid _uuid = const Uuid();

  Future<Sale> createSale({
    required DateTime date,
    required int storeId,
    int? employeeId,
    required List<Map<String, dynamic>> items, // {productId, productName, quantity, unitPrice, total}
    String? customerName,
    String? notes,
  }) async {
    final db = await _db.database;
    
    // Verificar inventario antes de crear la venta
    for (var item in items) {
      final inventory = await _inventoryService.getInventory(
        productId: item['productId'] as int,
        storeId: storeId,
      );
      
      if (inventory == null || inventory.quantity < (item['quantity'] as num).toDouble()) {
        throw Exception(
          'No hay suficiente inventario para el producto ${item['productName']}',
        );
      }
    }
    
    // Calcular total
    final total = items.fold<double>(
      0.0,
      (sum, item) => sum + (item['total'] as num).toDouble(),
    );
    
    // Generar número de venta
    final number = 'VENT-${DateTime.now().millisecondsSinceEpoch}';
    
    return await db.transaction(() async {
      // Guardar venta
      final saleCompanion = SalesCompanion.insert(
        number: number,
        date: date,
        storeId: Value(storeId),
        employeeId: Value(employeeId),
        total: total,
        customerName: Value(customerName),
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        isSynced: const Value(false),
      );
      
      final saleId = await db.into(db.sales).insert(saleCompanion);
      
      // Guardar items de venta
      for (var item in items) {
        await db.into(db.saleItems).insert(SaleItemsCompanion.insert(
          saleId: saleId,
          productId: item['productId'] as int,
          productName: item['productName'] as String,
          quantity: (item['quantity'] as num).toDouble(),
          unitPrice: (item['unitPrice'] as num).toDouble(),
          total: (item['total'] as num).toDouble(),
        ));
        
        // Reducir inventario
        await _inventoryService.subtractInventory(
          productId: item['productId'] as int,
          quantity: (item['quantity'] as num).toDouble(),
          storeId: storeId,
        );
      }
      
      return await (db.select(db.sales)..where((s) => s.id.equals(saleId))).getSingle();
    });
  }

  Future<List<Sale>> getSales({
    int? storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db.database;
    
    var query = db.select(db.sales);
    
    if (storeId != null) {
      query = query..where((s) => s.storeId.equals(storeId));
    }
    
    if (startDate != null) {
      query = query..where((s) => s.date.isBiggerOrEqualValue(startDate));
    }
    
    if (endDate != null) {
      query = query..where((s) => s.date.isSmallerOrEqualValue(endDate));
    }
    
    final results = await query.get();
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  Future<Sale?> getSaleById(int id) async {
    final db = await _db.database;
    return await (db.select(db.sales)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<SaleItem>> getSaleItems(int saleId) async {
    final db = await _db.database;
    return await (db.select(db.saleItems)
          ..where((si) => si.saleId.equals(saleId)))
        .get();
  }

  // Obtener ventas del día
  Future<List<Sale>> getTodaySales({int? storeId}) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return await getSales(
      storeId: storeId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Calcular total de ventas del día
  Future<double> getTodaySalesTotal({int? storeId}) async {
    final sales = await getTodaySales(storeId: storeId);
    return sales.fold<double>(0.0, (sum, sale) => sum + sale.total);
  }

  Future<void> deleteSale(int id) async {
    final db = await _db.database;
    final sale = await getSaleById(id);
    
    if (sale != null) {
      await db.transaction(() async {
        // Obtener items
        final items = await getSaleItems(id);
        
        // Revertir inventario
        for (var item in items) {
          await _inventoryService.addInventory(
            productId: item.productId,
            quantity: item.quantity,
            storeId: sale.storeId,
          );
        }
        
        // Eliminar items
        await (db.delete(db.saleItems)..where((si) => si.saleId.equals(id))).go();
        
        // Eliminar venta
        await (db.delete(db.sales)..where((s) => s.id.equals(id))).go();
      });
    }
  }
}
