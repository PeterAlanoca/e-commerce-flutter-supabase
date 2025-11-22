import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {}

class AddEmployee extends EmployeeEvent {
  final EmployeesCompanion employee;

  const AddEmployee(this.employee);

  @override
  List<Object> get props => [employee];
}

class UpdateEmployee extends EmployeeEvent {
  final int id;
  final EmployeesCompanion employee;

  const UpdateEmployee({required this.id, required this.employee});

  @override
  List<Object> get props => [id, employee];
}

class DeleteEmployee extends EmployeeEvent {
  final int id;

  const DeleteEmployee(this.id);

  @override
  List<Object> get props => [id];
}
