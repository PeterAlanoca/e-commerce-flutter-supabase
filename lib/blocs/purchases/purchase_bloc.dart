import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/purchase_service.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseService _purchaseService;

  PurchaseBloc({required PurchaseService purchaseService})
      : _purchaseService = purchaseService,
        super(PurchasesInitial()) {
    on<LoadPurchases>(_onLoadPurchases);
    on<AddPurchase>(_onAddPurchase);
    on<DeletePurchase>(_onDeletePurchase);
  }

  Future<void> _onLoadPurchases(
    LoadPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchasesLoading());
    try {
      final purchases = await _purchaseService.getPurchases(
        warehouseId: event.warehouseId,
        storeId: event.storeId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(PurchasesLoaded(purchases));
    } catch (e) {
      emit(PurchasesError(e.toString()));
    }
  }

  Future<void> _onAddPurchase(
    AddPurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchasesLoading());
    try {
      await _purchaseService.createPurchase(
        date: event.date,
        warehouseId: event.warehouseId,
        storeId: event.storeId,
        employeeId: event.employeeId,
        items: event.items,
        notes: event.notes,
      );
      add(LoadPurchases(
        warehouseId: event.warehouseId,
        storeId: event.storeId,
      )); 
    } catch (e) {
      emit(PurchasesError(e.toString()));
    }
  }

  Future<void> _onDeletePurchase(
    DeletePurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchasesLoading());
    try {
      await _purchaseService.deletePurchase(event.id);
      add(const LoadPurchases()); 
    } catch (e) {
      emit(PurchasesError(e.toString()));
    }
  }
}
