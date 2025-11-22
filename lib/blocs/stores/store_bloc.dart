import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/store_service.dart';
import 'store_event.dart';
import 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final StoreService _storeService;

  StoreBloc({required StoreService storeService})
      : _storeService = storeService,
        super(StoresInitial()) {
    on<LoadStores>(_onLoadStores);
    on<AddStore>(_onAddStore);
    on<UpdateStore>(_onUpdateStore);
    on<DeleteStore>(_onDeleteStore);
  }

  Future<void> _onLoadStores(
    LoadStores event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoresLoading());
    try {
      final stores = await _storeService.getAllStores();
      emit(StoresLoaded(stores));
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onAddStore(
    AddStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoresLoading());
    try {
      await _storeService.createStore(event.store);
      add(LoadStores());
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onUpdateStore(
    UpdateStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoresLoading());
    try {
      await _storeService.updateStore(event.id, event.store);
      add(LoadStores());
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }

  Future<void> _onDeleteStore(
    DeleteStore event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoresLoading());
    try {
      await _storeService.deleteStore(event.id);
      add(LoadStores());
    } catch (e) {
      emit(StoresError(e.toString()));
    }
  }
}
