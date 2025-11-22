import 'package:drift/drift.dart';
import '../database/database.dart';
import 'database_service.dart';

class ProductService {
  final DatabaseService _db = DatabaseService.instance;

  Future<List<Product>> getAllProducts() async {
    final db = await _db.database;
    return await db.select(db.products).get();
  }

  Future<Product?> getProductById(int id) async {
    final db = await _db.database;
    return await (db.select(db.products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<int> createProduct(ProductsCompanion product) async {
    final db = await _db.database;
    return await db.into(db.products).insert(product);
  }

  Future<void> updateProduct(int id, ProductsCompanion product) async {
    final db = await _db.database;
    await (db.update(db.products)..where((p) => p.id.equals(id))).write(product);
  }

  Future<void> deleteProduct(int id) async {
    final db = await _db.database;
    await (db.delete(db.products)..where((p) => p.id.equals(id))).go();
  }
}

