import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../services/purchase_service.dart';
import '../../services/product_service.dart';
import '../../services/warehouse_service.dart';
import '../../services/store_service.dart';

class PurchaseFormScreen extends StatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  final ProductService _productService = ProductService();

  final WarehouseService _warehouseService = WarehouseService();
  final StoreService _storeService = StoreService();
  DateTime _date = DateTime.now();
  bool _isStore = false;
  Warehouse? _selectedWarehouse;
  Store? _selectedStore;
  List<Warehouse> _warehouses = [];
  List<Store> _stores = [];
  List<Product> _products = [];
  List<Map<String, dynamic>> _items = []; // {productId, productName, quantity, unitPrice, total}
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
      final warehouses = await _warehouseService.getAllWarehouses();
      final stores = await _storeService.getAllStores();
      final products = await _productService.getAllProducts();
      setState(() {
        _warehouses = warehouses;
        _stores = stores;
        _products = products;
        if (_warehouses.isNotEmpty) _selectedWarehouse = _warehouses.first;
        if (_stores.isNotEmpty) _selectedStore = _stores.first;
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
    if (!_isStore && _selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un almacén')),
      );
      return;
    }

    if (_isStore && _selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una tienda')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un item')),
      );
      return;
    }

    try {
      await _purchaseService.createPurchase(
        date: _date,
        warehouseId: _isStore ? null : _selectedWarehouse!.id,
        storeId: _isStore ? _selectedStore!.id : null,
        items: _items,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra registrada')),
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
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final total = _items.fold<double>(
      0.0,
      (sum, item) => sum + (item['total'] as num).toDouble(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Compra')),
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

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Almacén'),
                          value: false,
                          groupValue: _isStore,
                          onChanged: (value) {
                            setState(() => _isStore = value!);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Tienda'),
                          value: true,
                          groupValue: _isStore,
                          onChanged: (value) {
                            setState(() => _isStore = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (!_isStore)
                    DropdownButtonFormField<Warehouse>(
                      value: _selectedWarehouse,
                      decoration: const InputDecoration(
                        labelText: 'Almacén *',
                        border: OutlineInputBorder(),
                      ),
                      items: _warehouses.map((warehouse) {
                        return DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedWarehouse = value);
                      },
                    )
                  else
                    DropdownButtonFormField<Store>(
                      value: _selectedStore,
                      decoration: const InputDecoration(
                        labelText: 'Tienda *',
                        border: OutlineInputBorder(),
                      ),
                      items: _stores.map((store) {
                        return DropdownMenuItem(
                          value: store,
                          child: Text(store.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedStore = value);
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
                        subtitle: Text(
                          '${item['quantity']} x ${currencyFormat.format(item['unitPrice'])} = ${currencyFormat.format(item['total'])}',
                        ),
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
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currencyFormat.format(total),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Guardar Compra'),
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
  final _unitPriceController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _add() {
    if (_selectedProduct == null) return;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ??
        _selectedProduct!.price;
    if (quantity <= 0) return;

    widget.onAdd({
      'productId': _selectedProduct!.id,
      'productName': _selectedProduct!.name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': quantity * unitPrice,
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
              setState(() {
                _selectedProduct = value;
                if (value != null) {
                  _unitPriceController.text = value.price.toString();
                }
              });
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
          const SizedBox(height: 16),
          TextField(
            controller: _unitPriceController,
            decoration: const InputDecoration(
              labelText: 'Precio Unitario *',
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
