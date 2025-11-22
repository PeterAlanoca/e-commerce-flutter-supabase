import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class WarehouseState extends Equatable {
  const WarehouseState();
  
  @override
  List<Object?> get props => [];
}

class WarehousesInitial extends WarehouseState {}

class WarehousesLoading extends WarehouseState {}

class WarehousesLoaded extends WarehouseState {
  final List<Warehouse> warehouses;

  const WarehousesLoaded(this.warehouses);

  @override
  List<Object> get props => [warehouses];
}

class WarehousesError extends WarehouseState {
  final String message;

  const WarehousesError(this.message);

  @override
  List<Object> get props => [message];
}
