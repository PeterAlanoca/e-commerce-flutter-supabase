import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class TransferState extends Equatable {
  const TransferState();
  
  @override
  List<Object?> get props => [];
}

class TransfersInitial extends TransferState {}

class TransfersLoading extends TransferState {}

class TransfersLoaded extends TransferState {
  final List<Transfer> transfers;

  const TransfersLoaded(this.transfers);

  @override
  List<Object> get props => [transfers];
}

class TransfersError extends TransferState {
  final String message;

  const TransfersError(this.message);

  @override
  List<Object> get props => [message];
}
