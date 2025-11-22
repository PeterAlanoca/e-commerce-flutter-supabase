import 'package:drift/drift.dart';
import '../database/database.dart';
import 'database_service.dart';

class EmployeeService {
  final DatabaseService _db = DatabaseService.instance;

  Future<List<Employee>> getAllEmployees() async {
    final db = await _db.database;
    return await db.select(db.employees).get();
  }

  Future<Employee?> getEmployeeById(int id) async {
    final db = await _db.database;
    return await (db.select(db.employees)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<int> createEmployee(EmployeesCompanion employee) async {
    final db = await _db.database;
    return await db.into(db.employees).insert(employee);
  }

  Future<void> updateEmployee(int id, EmployeesCompanion employee) async {
    final db = await _db.database;
    await (db.update(db.employees)..where((e) => e.id.equals(id))).write(employee);
  }

  Future<void> deleteEmployee(int id) async {
    final db = await _db.database;
    await (db.delete(db.employees)..where((e) => e.id.equals(id))).go();
  }
}

