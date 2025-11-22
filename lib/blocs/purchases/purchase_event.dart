import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchases extends PurchaseEvent {
  final int? warehouseId;
  final int? storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadPurchases({this.warehouseId, this.storeId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [warehouseId, storeId, startDate, endDate];
}

class AddPurchase extends PurchaseEvent {
  final DateTime date;
  final int? warehouseId;
  final int? storeId;
  final int? employeeId;
  final List<Map<String, dynamic>> items;
  final String? notes;

  const AddPurchase({
    required this.date,
    this.warehouseId,
    this.storeId,
    this.employeeId,
    required this.items,
    this.notes,
  });

  @override
  List<Object?> get props => [date, warehouseId, storeId, employeeId, items, notes];
}

class DeletePurchase extends PurchaseEvent {
  final int id;

  const DeletePurchase(this.id);

  @override
  List<Object> get props => [id];
}
