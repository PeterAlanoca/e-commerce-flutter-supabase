import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/warehouse_service.dart';
import 'warehouse_event.dart';
import 'warehouse_state.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  final WarehouseService _warehouseService;

  WarehouseBloc({required WarehouseService warehouseService})
      : _warehouseService = warehouseService,
        super(WarehousesInitial()) {
    on<LoadWarehouses>(_onLoadWarehouses);
    on<AddWarehouse>(_onAddWarehouse);
    on<UpdateWarehouse>(_onUpdateWarehouse);
    on<DeleteWarehouse>(_onDeleteWarehouse);
  }

  Future<void> _onLoadWarehouses(
    LoadWarehouses event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehousesLoading());
    try {
      final warehouses = await _warehouseService.getAllWarehouses();
      emit(WarehousesLoaded(warehouses));
    } catch (e) {
      emit(WarehousesError(e.toString()));
    }
  }

  Future<void> _onAddWarehouse(
    AddWarehouse event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehousesLoading());
    try {
      await _warehouseService.createWarehouse(event.warehouse);
      add(LoadWarehouses());
    } catch (e) {
      emit(WarehousesError(e.toString()));
    }
  }

  Future<void> _onUpdateWarehouse(
    UpdateWarehouse event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehousesLoading());
    try {
      await _warehouseService.updateWarehouse(event.id, event.warehouse);
      add(LoadWarehouses());
    } catch (e) {
      emit(WarehousesError(e.toString()));
    }
  }

  Future<void> _onDeleteWarehouse(
    DeleteWarehouse event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(WarehousesLoading());
    try {
      await _warehouseService.deleteWarehouse(event.id);
      add(LoadWarehouses());
    } catch (e) {
      emit(WarehousesError(e.toString()));
    }
  }
}
