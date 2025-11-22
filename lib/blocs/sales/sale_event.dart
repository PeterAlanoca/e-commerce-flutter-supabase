import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSales extends SaleEvent {
  final int? storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSales({this.storeId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

class AddSale extends SaleEvent {
  final DateTime date;
  final int storeId;
  final int? employeeId;
  final List<Map<String, dynamic>> items;
  final String? customerName;
  final String? notes;

  const AddSale({
    required this.date,
    required this.storeId,
    this.employeeId,
    required this.items,
    this.customerName,
    this.notes,
  });

  @override
  List<Object?> get props => [date, storeId, employeeId, items, customerName, notes];
}

class DeleteSale extends SaleEvent {
  final int id;

  const DeleteSale(this.id);

  @override
  List<Object> get props => [id];
}
