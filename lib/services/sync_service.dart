import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/database.dart';
import 'database_service.dart';

class SyncService {
  final DatabaseService _db = DatabaseService.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final Connectivity _connectivity = Connectivity();

  // Verificar conexión a internet
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Sincronizar todos los datos pendientes
  Future<void> syncAll() async {
    if (!await isConnected()) {
      return; // No hay conexión, no sincronizar
    }

    try {
      await syncProducts();
      await syncStores();
      await syncWarehouses();
      await syncEmployees();
      await syncUsers();
      await syncPurchases();
      await syncSales();
      await syncTransfers();
      await syncInventories();
    } catch (e) {
      print('Error en sincronización: $e');
    }
  }

  // Sincronizar productos
  Future<void> syncProducts() async {
    final db = await _db.database;
    
    // Subir productos no sincronizados
    final unsyncedProducts = await (db.select(db.products)
          ..where((p) => p.isSynced.equals(false)))
        .get();
    
    for (var product in unsyncedProducts) {
      try {
        final data = {
          'code': product.code,
          'name': product.name,
          'description': product.description,
          'category': product.category,
          'price': product.price,
          'cost_price': product.costPrice,
          'unit': product.unit,
          'created_at': product.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': product.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('products')
            .upsert(data)
            .select()
            .single();
        
        await (db.update(db.products)
              ..where((p) => p.id.equals(product.id)))
            .write(ProductsCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando producto ${product.id}: $e');
      }
    }
    
    // Descargar productos actualizados desde Supabase
    final response = await _supabase
        .from('products')
        .select()
        .order('updated_at', ascending: false);
    
    for (var data in response) {
      final existingProduct = await (db.select(db.products)
            ..where((p) => p.supabaseId.equals(data['id'].toString())))
          .getSingleOrNull();
      
      if (existingProduct == null || 
          (existingProduct.updatedAt != null &&
          DateTime.parse(data['updated_at']).isAfter(existingProduct.updatedAt!))) {
        final companion = ProductsCompanion.insert(
          code: Value(data['code']),
          name: data['name'],
          description: Value(data['description']),
          category: Value(data['category']),
          price: (data['price'] as num).toDouble(),
          costPrice: data['cost_price'] != null 
              ? Value((data['cost_price'] as num).toDouble())
              : const Value.absent(),
          unit: Value(data['unit']),
          createdAt: Value(DateTime.parse(data['created_at'])),
          updatedAt: Value(DateTime.parse(data['updated_at'])),
          isSynced: const Value(true),
          supabaseId: Value(data['id'].toString()),
        );
        
        if (existingProduct != null) {
          await (db.update(db.products)
                ..where((p) => p.id.equals(existingProduct.id)))
              .write(companion);
        } else {
          await db.into(db.products).insert(companion);
        }
      }
    }
  }

  // Sincronizar tiendas (simplificado - similar a productos)
  Future<void> syncStores() async {
    final db = await _db.database;
    final unsyncedStores = await (db.select(db.stores)
          ..where((s) => s.isSynced.equals(false)))
        .get();
    
    for (var store in unsyncedStores) {
      try {
        final data = {
          'code': store.code,
          'name': store.name,
          'address': store.address,
          'phone': store.phone,
          'email': store.email,
          'manager_id': store.managerId,
          'created_at': store.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': store.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('stores')
            .upsert(data)
            .select()
            .single();
        
        await (db.update(db.stores)
              ..where((s) => s.id.equals(store.id)))
            .write(StoresCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando tienda ${store.id}: $e');
      }
    }
  }

  // Sincronizar almacenes (similar a tiendas)
  Future<void> syncWarehouses() async {
    final db = await _db.database;
    final unsyncedWarehouses = await (db.select(db.warehouses)
          ..where((w) => w.isSynced.equals(false)))
        .get();
    
    for (var warehouse in unsyncedWarehouses) {
      try {
        final data = {
          'code': warehouse.code,
          'name': warehouse.name,
          'address': warehouse.address,
          'phone': warehouse.phone,
          'email': warehouse.email,
          'manager_id': warehouse.managerId,
          'created_at': warehouse.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': warehouse.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('warehouses')
            .upsert(data)
            .select()
            .single();
        
        await (db.update(db.warehouses)
              ..where((w) => w.id.equals(warehouse.id)))
            .write(WarehousesCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando almacén ${warehouse.id}: $e');
      }
    }
  }

  // Sincronizar empleados
  Future<void> syncEmployees() async {
    final db = await _db.database;
    final unsyncedEmployees = await (db.select(db.employees)
          ..where((e) => e.isSynced.equals(false)))
        .get();
    
    for (var employee in unsyncedEmployees) {
      try {
        final data = {
          'code': employee.code,
          'first_name': employee.firstName,
          'last_name': employee.lastName,
          'email': employee.email,
          'phone': employee.phone,
          'position': employee.position,
          'document_id': employee.documentId,
          'store_id': employee.storeId,
          'warehouse_id': employee.warehouseId,
          'created_at': employee.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': employee.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('employees')
            .upsert(data)
            .select()
            .single();
        
        await (db.update(db.employees)
              ..where((e) => e.id.equals(employee.id)))
            .write(EmployeesCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando empleado ${employee.id}: $e');
      }
    }
  }

  // Sincronizar usuarios
  Future<void> syncUsers() async {
    final db = await _db.database;
    final unsyncedUsers = await (db.select(db.users)
          ..where((u) => u.isSynced.equals(false)))
        .get();
    
    for (var user in unsyncedUsers) {
      try {
        final data = {
          'email': user.email,
          'name': user.name,
          'role': user.role,
          'employee_id': user.employeeId,
          'store_id': user.storeId,
          'warehouse_id': user.warehouseId,
          'created_at': user.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': user.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('users')
            .upsert(data)
            .select()
            .single();
        
        await (db.update(db.users)
              ..where((u) => u.id.equals(user.id)))
            .write(UsersCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando usuario ${user.id}: $e');
      }
    }
  }

  // Sincronizar compras
  Future<void> syncPurchases() async {
    final db = await _db.database;
    final unsyncedPurchases = await (db.select(db.purchases)
          ..where((p) => p.isSynced.equals(false)))
        .get();
    
    for (var purchase in unsyncedPurchases) {
      try {
        // Obtener items de la compra
        final items = await (db.select(db.purchaseItems)
              ..where((i) => i.purchaseId.equals(purchase.id)))
            .get();
            
        final itemsJson = items.map((item) => {
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.total,
        }).toList();

        final data = {
          'number': purchase.number,
          'date': purchase.date.toIso8601String(),
          'warehouse_id': purchase.warehouseId,
          'store_id': purchase.storeId,
          'employee_id': purchase.employeeId,
          'total': purchase.total,
          'notes': purchase.notes,
          'items': itemsJson,
          'created_at': purchase.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': purchase.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('purchases')
            .upsert(data)
            .select()
            .single();
        
        await (db.update(db.purchases)
              ..where((p) => p.id.equals(purchase.id)))
            .write(PurchasesCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando compra ${purchase.id}: $e');
      }
    }
  }

  // Sincronizar ventas
  Future<void> syncSales() async {
    final db = await _db.database;
    final unsyncedSales = await (db.select(db.sales)
          ..where((s) => s.isSynced.equals(false)))
        .get();
    
    for (var sale in unsyncedSales) {
      try {
        // Obtener items de la venta
        final items = await (db.select(db.saleItems)
              ..where((i) => i.saleId.equals(sale.id)))
            .get();
            
        final itemsJson = items.map((item) => {
          'product_id': item.productId,
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total': item.total,
        }).toList();

        final data = {
          'number': sale.number,
          'date': sale.date.toIso8601String(),
          'store_id': sale.storeId,
          'employee_id': sale.employeeId,
          'total': sale.total,
          'customer_name': sale.customerName,
          'notes': sale.notes,
          'items': itemsJson,
          'created_at': sale.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': sale.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        
        final response = await _supabase
            .from('sales')
            .upsert(data)
            .select()
            .single();
            
        await (db.update(db.sales)
              ..where((s) => s.id.equals(sale.id)))
            .write(SalesCompanion(
              supabaseId: Value(response['id'].toString()),
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando venta ${sale.id}: $e');
      }
    }
  }

  // Sincronizar transferencias (simplificado)
  Future<void> syncTransfers() async {
    final db = await _db.database;
    final unsyncedTransfers = await (db.select(db.transfers)
          ..where((t) => t.isSynced.equals(false)))
        .get();
    
    for (var transfer in unsyncedTransfers) {
      try {
        await (db.update(db.transfers)
              ..where((t) => t.id.equals(transfer.id)))
            .write(TransfersCompanion(
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando transferencia ${transfer.id}: $e');
      }
    }
  }

  // Sincronizar inventarios
  Future<void> syncInventories() async {
    final db = await _db.database;
    final unsyncedInventories = await (db.select(db.inventories)
          ..where((i) => i.isSynced.equals(false)))
        .get();
    
    for (var inventory in unsyncedInventories) {
      try {
        await (db.update(db.inventories)
              ..where((i) => i.id.equals(inventory.id)))
            .write(InventoriesCompanion(
              isSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ));
      } catch (e) {
        print('Error sincronizando inventario ${inventory.id}: $e');
      }
    }
  }
}
