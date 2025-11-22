import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/employee_service.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeService _employeeService;

  EmployeeBloc({required EmployeeService employeeService})
      : _employeeService = employeeService,
        super(EmployeesInitial()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<AddEmployee>(_onAddEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeesLoading());
    try {
      final employees = await _employeeService.getAllEmployees();
      emit(EmployeesLoaded(employees));
    } catch (e) {
      emit(EmployeesError(e.toString()));
    }
  }

  Future<void> _onAddEmployee(
    AddEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeesLoading());
    try {
      await _employeeService.createEmployee(event.employee);
      add(LoadEmployees());
    } catch (e) {
      emit(EmployeesError(e.toString()));
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeesLoading());
    try {
      await _employeeService.updateEmployee(event.id, event.employee);
      add(LoadEmployees());
    } catch (e) {
      emit(EmployeesError(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeesLoading());
    try {
      await _employeeService.deleteEmployee(event.id);
      add(LoadEmployees());
    } catch (e) {
      emit(EmployeesError(e.toString()));
    }
  }
}
