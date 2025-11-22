import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/report_service.dart';
import '../../services/store_service.dart';
import '../../services/warehouse_service.dart';
import '../../database/database.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  final StoreService _storeService = StoreService();
  final WarehouseService _warehouseService = WarehouseService();
  
  int _selectedTab = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  Store? _selectedStore;
  Warehouse? _selectedWarehouse;
  List<Store> _stores = [];
  List<Warehouse> _warehouses = [];
  Map<String, dynamic>? _salesReport;
  Map<String, dynamic>? _purchasesReport;
  Map<String, dynamic>? _transfersReport;
  Map<String, dynamic>? _todaySalesReport;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadTodaySales();
  }

  Future<void> _loadData() async {
    try {
      final stores = await _storeService.getAllStores();
      final warehouses = await _warehouseService.getAllWarehouses();
      setState(() {
        _stores = stores;
        _warehouses = warehouses;
      });
    } catch (e) {
      // Error loading data
    }
  }

  Future<void> _loadTodaySales() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getTodayGlobalSalesReport();
      setState(() {
        _todaySalesReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSalesReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getSalesReport(
        storeId: _selectedStore?.id,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _salesReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPurchasesReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getPurchasesReport(
        warehouseId: _selectedWarehouse?.id,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _purchasesReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTransfersReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _reportService.getTransfersReport(
        storeId: _selectedStore?.id,
        warehouseId: _selectedWarehouse?.id,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _transfersReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Column(
        children: [
          // Filtros
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: Text(_startDate == null
                              ? 'Fecha Inicio'
                              : dateFormat.format(_startDate!)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _startDate = date);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(_endDate == null
                              ? 'Fecha Fin'
                              : dateFormat.format(_endDate!)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _endDate = date);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedTab == 0 || _selectedTab == 2)
                    DropdownButtonFormField<Store>(
                      value: _selectedStore,
                      decoration: const InputDecoration(
                        labelText: 'Tienda',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<Store>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ..._stores.map((store) => DropdownMenuItem(
                          value: store,
                          child: Text(store.name),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStore = value);
                      },
                    ),
                  if (_selectedTab == 1)
                    DropdownButtonFormField<Warehouse>(
                      value: _selectedWarehouse,
                      decoration: const InputDecoration(
                        labelText: 'Almacén',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<Warehouse>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ..._warehouses.map((warehouse) => DropdownMenuItem(
                          value: warehouse,
                          child: Text(warehouse.name),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedWarehouse = value);
                      },
                    ),
                  ElevatedButton(
                    onPressed: () {
                      switch (_selectedTab) {
                        case 0:
                          _loadSalesReport();
                          break;
                        case 1:
                          _loadPurchasesReport();
                          break;
                        case 2:
                          _loadTransfersReport();
                          break;
                      }
                    },
                    child: const Text('Generar Reporte'),
                  ),
                ],
              ),
            ),
          ),
          // Tabs
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Ventas'),
                  selected: _selectedTab == 0,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTab = 0);
                  },
                ),
              ),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Compras'),
                  selected: _selectedTab == 1,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTab = 1);
                  },
                ),
              ),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Transferencias'),
                  selected: _selectedTab == 2,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTab = 2);
                  },
                ),
              ),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Hoy'),
                  selected: _selectedTab == 3,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTab = 3);
                  },
                ),
              ),
            ],
          ),
          // Contenido
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildSalesReport(currencyFormat),
                      _buildPurchasesReport(currencyFormat),
                      _buildTransfersReport(),
                      _buildTodaySalesReport(currencyFormat),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesReport(NumberFormat currencyFormat) {
    if (_salesReport == null) {
      return const Center(child: Text('Seleccione filtros y genere el reporte'));
    }

    final sales = _salesReport!['sales'] as List;
    final total = _salesReport!['total'] as double;
    final count = _salesReport!['count'] as int;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Total Ventas: ${currencyFormat.format(total)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Text('Cantidad: $count'),
              ],
            ),
          ),
        ),
        ...sales.map((sale) => Card(
              child: ListTile(
                title: Text((sale as Sale).number),
                subtitle: Text('Total: ${currencyFormat.format(sale.total)}'),
              ),
            )),
      ],
    );
  }

  Widget _buildPurchasesReport(NumberFormat currencyFormat) {
    if (_purchasesReport == null) {
      return const Center(child: Text('Seleccione filtros y genere el reporte'));
    }

    final purchases = _purchasesReport!['purchases'] as List;
    final total = _purchasesReport!['total'] as double;
    final count = _purchasesReport!['count'] as int;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Total Compras: ${currencyFormat.format(total)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                Text('Cantidad: $count'),
              ],
            ),
          ),
        ),
        ...purchases.map((purchase) => Card(
              child: ListTile(
                title: Text((purchase as Purchase).number),
                subtitle: Text('Total: ${currencyFormat.format(purchase.total)}'),
              ),
            )),
      ],
    );
  }

  Widget _buildTransfersReport() {
    if (_transfersReport == null) {
      return const Center(child: Text('Seleccione filtros y genere el reporte'));
    }

    final transfers = _transfersReport!['transfers'] as List;
    final count = _transfersReport!['count'] as int;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Total Transferencias: $count',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        ...transfers.map((transfer) => Card(
              child: ListTile(
                title: Text((transfer as Transfer).number),
                subtitle: Text('Tipo: ${transfer.type}'),
              ),
            )),
      ],
    );
  }

  Widget _buildTodaySalesReport(NumberFormat currencyFormat) {
    if (_todaySalesReport == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = _todaySalesReport!['total'] as double;
    final count = _todaySalesReport!['count'] as int;

    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ventas del Día',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 16),
              Text(currencyFormat.format(total),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  )),
              const SizedBox(height: 8),
              Text('$count ventas'),
            ],
          ),
        ),
      ),
    );
  }
}
