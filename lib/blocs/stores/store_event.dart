import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadStores extends StoreEvent {}

class AddStore extends StoreEvent {
  final StoresCompanion store;

  const AddStore(this.store);

  @override
  List<Object> get props => [store];
}

class UpdateStore extends StoreEvent {
  final int id;
  final StoresCompanion store;

  const UpdateStore({required this.id, required this.store});

  @override
  List<Object> get props => [id, store];
}

class DeleteStore extends StoreEvent {
  final int id;

  const DeleteStore(this.id);

  @override
  List<Object> get props => [id];
}
