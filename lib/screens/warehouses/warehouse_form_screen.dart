import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import '../../database/database.dart';
import '../../services/warehouse_service.dart';

class WarehouseFormScreen extends StatefulWidget {
  final Warehouse? warehouse;

  const WarehouseFormScreen({super.key, this.warehouse});

  @override
  State<WarehouseFormScreen> createState() => _WarehouseFormScreenState();
}

class _WarehouseFormScreenState extends State<WarehouseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final WarehouseService _warehouseService = WarehouseService();

  @override
  void initState() {
    super.initState();
    if (widget.warehouse != null) {
      _nameController.text = widget.warehouse!.name;
      _codeController.text = widget.warehouse!.code ?? '';
      _addressController.text = widget.warehouse!.address ?? '';
      _phoneController.text = widget.warehouse!.phone ?? '';
      _emailController.text = widget.warehouse!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final now = DateTime.now();
      final companion = WarehousesCompanion(
        code: _codeController.text.isEmpty 
            ? const Value.absent() 
            : Value(_codeController.text),
        name: Value(_nameController.text),
        address: _addressController.text.isEmpty
            ? const Value.absent()
            : Value(_addressController.text),
        phone: _phoneController.text.isEmpty 
            ? const Value.absent() 
            : Value(_phoneController.text),
        email: _emailController.text.isEmpty 
            ? const Value.absent() 
            : Value(_emailController.text),
        createdAt: widget.warehouse?.createdAt != null 
            ? Value(widget.warehouse!.createdAt!) 
            : Value(now),
        updatedAt: Value(now),
        isSynced: const Value(false),
      );

      if (widget.warehouse != null) {
        await _warehouseService.updateWarehouse(widget.warehouse!.id, companion);
      } else {
        await _warehouseService.createWarehouse(companion);
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
        title: Text(widget.warehouse == null ? 'Nuevo Almacén' : 'Editar Almacén'),
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
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
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
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
