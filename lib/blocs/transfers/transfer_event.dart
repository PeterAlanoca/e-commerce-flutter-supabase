import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransfers extends TransferEvent {
  final int? storeId;
  final int? warehouseId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? type;

  const LoadTransfers({
    this.storeId,
    this.warehouseId,
    this.startDate,
    this.endDate,
    this.type,
  });

  @override
  List<Object?> get props => [storeId, warehouseId, startDate, endDate, type];
}

class AddTransfer extends TransferEvent {
  final DateTime date;
  final String type;
  final int? fromStoreId;
  final int? fromWarehouseId;
  final int? toStoreId;
  final int? toWarehouseId;
  final int? employeeId;
  final List<Map<String, dynamic>> items;
  final String? notes;

  const AddTransfer({
    required this.date,
    required this.type,
    this.fromStoreId,
    this.fromWarehouseId,
    this.toStoreId,
    this.toWarehouseId,
    this.employeeId,
    required this.items,
    this.notes,
  });

  @override
  List<Object?> get props => [
        date,
        type,
        fromStoreId,
        fromWarehouseId,
        toStoreId,
        toWarehouseId,
        employeeId,
        items,
        notes,
      ];
}

class DeleteTransfer extends TransferEvent {
  final int id;

  const DeleteTransfer(this.id);

  @override
  List<Object> get props => [id];
}
