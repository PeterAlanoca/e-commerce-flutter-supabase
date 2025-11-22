import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import '../../database/database.dart';
import '../../services/employee_service.dart';
import '../../services/store_service.dart';
import '../../services/warehouse_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({super.key, this.employee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _documentIdController = TextEditingController();
  final EmployeeService _employeeService = EmployeeService();
  final StoreService _storeService = StoreService();
  final WarehouseService _warehouseService = WarehouseService();
  
  List<Store> _stores = [];
  List<Warehouse> _warehouses = [];
  int? _selectedStoreId;
  int? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.employee != null) {
      _firstNameController.text = widget.employee!.firstName;
      _lastNameController.text = widget.employee!.lastName;
      _codeController.text = widget.employee!.code ?? '';
      _emailController.text = widget.employee!.email ?? '';
      _phoneController.text = widget.employee!.phone ?? '';
      _positionController.text = widget.employee!.position ?? '';
      _documentIdController.text = widget.employee!.documentId ?? '';
      _selectedStoreId = widget.employee!.storeId;
      _selectedWarehouseId = widget.employee!.warehouseId;
    }
  }

  Future<void> _loadData() async {
    final stores = await _storeService.getAllStores();
    final warehouses = await _warehouseService.getAllWarehouses();
    setState(() {
      _stores = stores;
      _warehouses = warehouses;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _documentIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final now = DateTime.now();
      final companion = EmployeesCompanion(
        code: _codeController.text.isEmpty 
            ? const Value.absent() 
            : Value(_codeController.text),
        firstName: Value(_firstNameController.text),
        lastName: Value(_lastNameController.text),
        email: _emailController.text.isEmpty 
            ? const Value.absent() 
            : Value(_emailController.text),
        phone: _phoneController.text.isEmpty 
            ? const Value.absent() 
            : Value(_phoneController.text),
        position: _positionController.text.isEmpty
            ? const Value.absent()
            : Value(_positionController.text),
        documentId: _documentIdController.text.isEmpty
            ? const Value.absent()
            : Value(_documentIdController.text),
        storeId: Value(_selectedStoreId),
        warehouseId: Value(_selectedWarehouseId),
        createdAt: widget.employee?.createdAt != null 
            ? Value(widget.employee!.createdAt!) 
            : Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      );

      if (widget.employee != null) {
        await _employeeService.updateEmployee(widget.employee!.id, companion);
      } else {
        await _employeeService.createEmployee(companion);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.employee == null ? 'Nuevo Empleado' : 'Editar Empleado',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documentIdController,
                decoration: const InputDecoration(
                  labelText: 'Documento',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedStoreId,
                decoration: const InputDecoration(
                  labelText: 'Tienda',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('Ninguna')),
                  ..._stores.map((store) => DropdownMenuItem<int>(
                    value: store.id,
                    child: Text(store.name),
                  )),
                ],
                onChanged: (value) => setState(() => _selectedStoreId = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedWarehouseId,
                decoration: const InputDecoration(
                  labelText: 'Almacén',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('Ninguno')),
                  ..._warehouses.map((warehouse) => DropdownMenuItem<int>(
                    value: warehouse.id,
                    child: Text(warehouse.name),
                  )),
                ],
                onChanged: (value) => setState(() => _selectedWarehouseId = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
