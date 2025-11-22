import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/transfer_service.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferService _transferService;

  TransferBloc({required TransferService transferService})
      : _transferService = transferService,
        super(TransfersInitial()) {
    on<LoadTransfers>(_onLoadTransfers);
    on<AddTransfer>(_onAddTransfer);
    on<DeleteTransfer>(_onDeleteTransfer);
  }

  Future<void> _onLoadTransfers(
    LoadTransfers event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransfersLoading());
    try {
      final transfers = await _transferService.getTransfers(
        storeId: event.storeId,
        warehouseId: event.warehouseId,
        startDate: event.startDate,
        endDate: event.endDate,
        type: event.type,
      );
      emit(TransfersLoaded(transfers));
    } catch (e) {
      emit(TransfersError(e.toString()));
    }
  }

  Future<void> _onAddTransfer(
    AddTransfer event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransfersLoading());
    try {
      await _transferService.createTransfer(
        date: event.date,
        type: event.type,
        fromStoreId: event.fromStoreId,
        fromWarehouseId: event.fromWarehouseId,
        toStoreId: event.toStoreId,
        toWarehouseId: event.toWarehouseId,
        employeeId: event.employeeId,
        items: event.items,
        notes: event.notes,
      );
      add(LoadTransfers(
        storeId: event.fromStoreId ?? event.toStoreId,
        warehouseId: event.fromWarehouseId ?? event.toWarehouseId,
      )); 
    } catch (e) {
      emit(TransfersError(e.toString()));
    }
  }

  Future<void> _onDeleteTransfer(
    DeleteTransfer event,
    Emitter<TransferState> emit,
  ) async {
    emit(TransfersLoading());
    try {
      await _transferService.deleteTransfer(event.id);
      add(const LoadTransfers()); 
    } catch (e) {
      emit(TransfersError(e.toString()));
    }
  }
}
