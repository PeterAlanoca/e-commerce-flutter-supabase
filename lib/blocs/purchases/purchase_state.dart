import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class PurchaseState extends Equatable {
  const PurchaseState();
  
  @override
  List<Object?> get props => [];
}

class PurchasesInitial extends PurchaseState {}

class PurchasesLoading extends PurchaseState {}

class PurchasesLoaded extends PurchaseState {
  final List<Purchase> purchases;

  const PurchasesLoaded(this.purchases);

  @override
  List<Object> get props => [purchases];
}

class PurchasesError extends PurchaseState {
  final String message;

  const PurchasesError(this.message);

  @override
  List<Object> get props => [message];
}
