import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../services/transfer_service.dart';
import '../../services/product_service.dart';
import '../../services/store_service.dart';
import '../../services/warehouse_service.dart';

class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final TransferService _transferService = TransferService();
  final ProductService _productService = ProductService();
  final StoreService _storeService = StoreService();
  final WarehouseService _warehouseService = WarehouseService();
  DateTime _date = DateTime.now();
  String _type = 'store_to_store';
  Store? _fromStore;
  Store? _toStore;
  Warehouse? _fromWarehouse;
  Warehouse? _toWarehouse;
  List<Store> _stores = [];
  List<Warehouse> _warehouses = [];
  List<Product> _products = [];
  List<Map<String, dynamic>> _items = []; // {productId, productName, quantity}
  final _notesController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stores = await _storeService.getAllStores();
      final warehouses = await _warehouseService.getAllWarehouses();
      final products = await _productService.getAllProducts();
      setState(() {
        _stores = stores;
        _warehouses = warehouses;
        _products = products;
        if (_stores.isNotEmpty) _fromStore = _stores.first;
        if (_stores.length > 1) _toStore = _stores[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        products: _products,
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un item')),
      );
      return;
    }

    try {
      await _transferService.createTransfer(
        date: _date,
        type: _type,
        fromStoreId: _fromStore?.id,
        fromWarehouseId: _fromWarehouse?.id,
        toStoreId: _toStore?.id,
        toWarehouseId: _toWarehouse?.id,
        items: _items,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transferencia creada')),
        );
      }
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
      appBar: AppBar(title: const Text('Nueva Transferencia')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: const Text('Fecha'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _date = date);
                      }
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'store_to_store', child: Text('Tienda → Tienda')),
                      DropdownMenuItem(value: 'store_to_warehouse', child: Text('Tienda → Almacén')),
                      DropdownMenuItem(value: 'warehouse_to_store', child: Text('Almacén → Tienda')),
                      DropdownMenuItem(value: 'warehouse_to_warehouse', child: Text('Almacén → Almacén')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _type = value!;
                        _fromStore = null;
                        _toStore = null;
                        _fromWarehouse = null;
                        _toWarehouse = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_type == 'store_to_store' || _type == 'store_to_warehouse')
                    DropdownButtonFormField<Store>(
                      value: _fromStore,
                      decoration: const InputDecoration(
                        labelText: 'Tienda Origen *',
                        border: OutlineInputBorder(),
                      ),
                      items: _stores.map((store) {
                        return DropdownMenuItem(
                          value: store,
                          child: Text(store.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _fromStore = value);
                      },
                    ),
                  if (_type == 'warehouse_to_store' || _type == 'warehouse_to_warehouse')
                    DropdownButtonFormField<Warehouse>(
                      value: _fromWarehouse,
                      decoration: const InputDecoration(
                        labelText: 'Almacén Origen *',
                        border: OutlineInputBorder(),
                      ),
                      items: _warehouses.map((warehouse) {
                        return DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _fromWarehouse = value);
                      },
                    ),
                  const SizedBox(height: 16),
                  if (_type == 'store_to_store' || _type == 'warehouse_to_store')
                    DropdownButtonFormField<Store>(
                      value: _toStore,
                      decoration: const InputDecoration(
                        labelText: 'Tienda Destino *',
                        border: OutlineInputBorder(),
                      ),
                      items: _stores.map((store) {
                        return DropdownMenuItem(
                          value: store,
                          child: Text(store.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _toStore = value);
                      },
                    ),
                  if (_type == 'store_to_warehouse' || _type == 'warehouse_to_warehouse')
                    DropdownButtonFormField<Warehouse>(
                      value: _toWarehouse,
                      decoration: const InputDecoration(
                        labelText: 'Almacén Destino *',
                        border: OutlineInputBorder(),
                      ),
                      items: _warehouses.map((warehouse) {
                        return DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _toWarehouse = value);
                      },
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                      ElevatedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Card(
                      child: ListTile(
                        title: Text(item['productName'] as String),
                        subtitle: Text('Cantidad: ${item['quantity']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Guardar Transferencia'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final List<Product> products;
  final Function(Map<String, dynamic>) onAdd;

  const _AddItemDialog({
    required this.products,
    required this.onAdd,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _add() {
    if (_selectedProduct == null) return;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) return;

    widget.onAdd({
      'productId': _selectedProduct!.id,
      'productName': _selectedProduct!.name,
      'quantity': quantity,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Product>(
            value: _selectedProduct,
            decoration: const InputDecoration(
              labelText: 'Producto *',
              border: OutlineInputBorder(),
            ),
            items: widget.products.map((product) {
              return DropdownMenuItem(
                value: product,
                child: Text(product.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedProduct = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Cantidad *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _add,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
