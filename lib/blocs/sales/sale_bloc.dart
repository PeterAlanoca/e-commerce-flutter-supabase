import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/sale_service.dart';
import 'sale_event.dart';
import 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleService _saleService;

  SaleBloc({required SaleService saleService})
      : _saleService = saleService,
        super(SalesInitial()) {
    on<LoadSales>(_onLoadSales);
    on<AddSale>(_onAddSale);
    on<DeleteSale>(_onDeleteSale);
  }

  Future<void> _onLoadSales(
    LoadSales event,
    Emitter<SaleState> emit,
  ) async {
    emit(SalesLoading());
    try {
      final sales = await _saleService.getSales(
        storeId: event.storeId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(SalesLoaded(sales));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> _onAddSale(
    AddSale event,
    Emitter<SaleState> emit,
  ) async {
    emit(SalesLoading());
    try {
      await _saleService.createSale(
        date: event.date,
        storeId: event.storeId,
        employeeId: event.employeeId,
        items: event.items,
        customerName: event.customerName,
        notes: event.notes,
      );
      add(LoadSales(storeId: event.storeId)); // Reload sales for the current store context if possible
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> _onDeleteSale(
    DeleteSale event,
    Emitter<SaleState> emit,
  ) async {
    emit(SalesLoading());
    try {
      await _saleService.deleteSale(event.id);
      add(const LoadSales()); // Reload all sales or we might need to pass filters again. 
      // Ideally we should keep the current filter state. 
      // For now, reloading all is safe but might reset view.
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}
