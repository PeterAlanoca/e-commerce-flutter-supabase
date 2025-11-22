import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class StoreState extends Equatable {
  const StoreState();
  
  @override
  List<Object?> get props => [];
}

class StoresInitial extends StoreState {}

class StoresLoading extends StoreState {}

class StoresLoaded extends StoreState {
  final List<Store> stores;

  const StoresLoaded(this.stores);

  @override
  List<Object> get props => [stores];
}

class StoresError extends StoreState {
  final String message;

  const StoresError(this.message);

  @override
  List<Object> get props => [message];
}
