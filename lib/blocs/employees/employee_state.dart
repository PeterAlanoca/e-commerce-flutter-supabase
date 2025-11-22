import 'package:equatable/equatable.dart';
import '../../database/database.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();
  
  @override
  List<Object?> get props => [];
}

class EmployeesInitial extends EmployeeState {}

class EmployeesLoading extends EmployeeState {}

class EmployeesLoaded extends EmployeeState {
  final List<Employee> employees;

  const EmployeesLoaded(this.employees);

  @override
  List<Object> get props => [employees];
}

class EmployeesError extends EmployeeState {
  final String message;

  const EmployeesError(this.message);

  @override
  List<Object> get props => [message];
}
