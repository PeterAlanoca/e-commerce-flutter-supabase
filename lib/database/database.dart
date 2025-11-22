import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Tabla de Productos
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get price => real()();
  RealColumn get costPrice => real().nullable()();
  TextColumn get unit => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Tiendas
class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  IntColumn get managerId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Almacenes
class Warehouses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  IntColumn get managerId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Empleados
class Employees extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().nullable()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get position => text().nullable()();
  TextColumn get documentId => text().nullable()();
  IntColumn get storeId => integer().nullable()();
  IntColumn get warehouseId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Usuarios
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text()();
  TextColumn get password => text()();
  TextColumn get name => text().nullable()();
  TextColumn get role => text()(); // 'admin', 'store_manager', 'warehouse_manager'
  IntColumn get employeeId => integer().nullable()();
  IntColumn get storeId => integer().nullable()();
  IntColumn get warehouseId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Compras
class Purchases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get storeId => integer().nullable()();
  IntColumn get warehouseId => integer().nullable()();
  IntColumn get employeeId => integer().nullable()();
  RealColumn get total => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Items de Compra
class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get purchaseId => integer()();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();
}

// Tabla de Ventas
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get storeId => integer().nullable()();
  IntColumn get employeeId => integer().nullable()();
  RealColumn get total => real()();
  TextColumn get customerName => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Items de Venta
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer()();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();
}

// Tabla de Transferencias
class Transfers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get number => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // 'store_to_store', 'warehouse_to_warehouse', 'warehouse_to_store', 'store_to_warehouse'
  IntColumn get fromStoreId => integer().nullable()();
  IntColumn get fromWarehouseId => integer().nullable()();
  IntColumn get toStoreId => integer().nullable()();
  IntColumn get toWarehouseId => integer().nullable()();
  IntColumn get employeeId => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text()(); // 'pending', 'completed', 'cancelled'
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

// Tabla de Items de Transferencia
class TransferItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transferId => integer()();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
}

// Tabla de Inventario
class Inventories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer()();
  IntColumn get storeId => integer().nullable()();
  IntColumn get warehouseId => integer().nullable()();
  RealColumn get quantity => real()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get supabaseId => text().nullable()();
}

@DriftDatabase(tables: [
  Products,
  Stores,
  Warehouses,
  Employees,
  Users,
  Purchases,
  PurchaseItems,
  Sales,
  SaleItems,
  Transfers,
  TransferItems,
  Inventories,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(purchases, purchases.storeId);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ecommerce.db'));
    return NativeDatabase(file);
  });
}

