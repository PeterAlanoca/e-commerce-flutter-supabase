import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/product_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductService _productService;

  ProductBloc({required ProductService productService})
      : _productService = productService,
        super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final products = await _productService.getAllProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    // We keep the current state (likely Loaded) or emit Loading if we want to show a spinner
    // For better UX, we might want to emit Loading, but if we are in a list view, 
    // we might want to handle this differently (e.g. optimistic update).
    // For simplicity, let's emit Loading then reload.
    emit(ProductsLoading());
    try {
      await _productService.createProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      await _productService.updateProduct(event.id, event.product);
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      await _productService.deleteProduct(event.id);
      add(LoadProducts());
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
