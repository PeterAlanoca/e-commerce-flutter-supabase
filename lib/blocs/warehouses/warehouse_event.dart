import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarehouses extends WarehouseEvent {}

class AddWarehouse extends WarehouseEvent {
  final WarehousesCompanion warehouse;

  const AddWarehouse(this.warehouse);

  @override
  List<Object> get props => [warehouse];
}

class UpdateWarehouse extends WarehouseEvent {
  final int id;
  final WarehousesCompanion warehouse;

  const UpdateWarehouse({required this.id, required this.warehouse});

  @override
  List<Object> get props => [id, warehouse];
}

class DeleteWarehouse extends WarehouseEvent {
  final int id;

  const DeleteWarehouse(this.id);

  @override
  List<Object> get props => [id];
}
