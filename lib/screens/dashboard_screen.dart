import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/sale_service.dart';
import '../services/sync_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _saleService = SaleService();
  final _syncService = SyncService();
  double _todaySalesTotal = 0.0;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadTodaySales();
  }

  Future<void> _loadTodaySales() async {
    final total = await _saleService.getTodaySalesTotal();
    setState(() {
      _todaySalesTotal = total;
    });
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _syncService.syncAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronización completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en sincronización: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncData,
            tooltip: 'Sincronizar',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.store,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sistema de Inventario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                context.push('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Productos'),
              onTap: () {
                Navigator.pop(context);
                context.push('/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text('Tiendas'),
              onTap: () {
                Navigator.pop(context);
                context.push('/stores');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: const Text('Almacenes'),
              onTap: () {
                Navigator.pop(context);
                context.push('/warehouses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Empleados'),
              onTap: () {
                Navigator.pop(context);
                context.push('/employees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Compras'),
              onTap: () {
                Navigator.pop(context);
                context.push('/purchases');
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Ventas'),
              onTap: () {
                Navigator.pop(context);
                context.push('/sales');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transferencias'),
              onTap: () {
                Navigator.pop(context);
                context.push('/transfers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Reportes'),
              onTap: () {
                Navigator.pop(context);
                context.push('/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(AuthLogoutRequested());
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildStatCard(
            context,
            'Ventas del Día',
            currencyFormat.format(_todaySalesTotal),
            Icons.attach_money,
            Colors.green,
            () => context.push('/sales'),
          ),
          _buildStatCard(
            context,
            'Productos',
            'Ver todos',
            Icons.inventory_2,
            Colors.blue,
            () => context.push('/products'),
          ),
          _buildStatCard(
            context,
            'Tiendas',
            'Gestionar',
            Icons.storefront,
            Colors.orange,
            () => context.push('/stores'),
          ),
          _buildStatCard(
            context,
            'Almacenes',
            'Gestionar',
            Icons.warehouse,
            Colors.purple,
            () => context.push('/warehouses'),
          ),
          _buildStatCard(
            context,
            'Compras',
            'Registrar',
            Icons.shopping_cart,
            Colors.teal,
            () => context.push('/purchases'),
          ),
          _buildStatCard(
            context,
            'Reportes',
            'Ver reportes',
            Icons.assessment,
            Colors.indigo,
            () => context.push('/reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



