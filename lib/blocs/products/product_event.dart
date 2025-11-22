import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class AddProduct extends ProductEvent {
  final ProductsCompanion product;

  const AddProduct(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final int id;
  final ProductsCompanion product;

  const UpdateProduct({required this.id, required this.product});

  @override
  List<Object> get props => [id, product];
}

class DeleteProduct extends ProductEvent {
  final int id;

  const DeleteProduct(this.id);

  @override
  List<Object> get props => [id];
}
