import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class SaleState extends Equatable {
  const SaleState();
  
  @override
  List<Object?> get props => [];
}

class SalesInitial extends SaleState {}

class SalesLoading extends SaleState {}

class SalesLoaded extends SaleState {
  final List<Sale> sales;

  const SalesLoaded(this.sales);

  @override
  List<Object> get props => [sales];
}

class SalesError extends SaleState {
  final String message;

  const SalesError(this.message);

  @override
  List<Object> get props => [message];
}
