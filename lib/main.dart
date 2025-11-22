import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/supabase_config.dart';
import 'utils/router.dart';
import 'utils/create_default_user.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'services/auth_service.dart';
import 'blocs/products/product_bloc.dart';
import 'blocs/products/product_event.dart';
import 'services/product_service.dart';
import 'blocs/stores/store_bloc.dart';
import 'blocs/stores/store_event.dart';
import 'services/store_service.dart';
import 'blocs/warehouses/warehouse_bloc.dart';
import 'blocs/warehouses/warehouse_event.dart';
import 'services/warehouse_service.dart';
import 'blocs/employees/employee_bloc.dart';
import 'blocs/employees/employee_event.dart';
import 'services/employee_service.dart';
import 'blocs/sales/sale_bloc.dart';
import 'services/sale_service.dart';
import 'blocs/purchases/purchase_bloc.dart';
import 'services/purchase_service.dart';
import 'blocs/transfers/transfer_bloc.dart';
import 'services/transfer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  // NOTA: Reemplaza con tus credenciales de Supabase en config/supabase_config.dart
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  } catch (e) {
    // Si Supabase no está configurado, la app funcionará en modo offline
    debugPrint('Supabase no configurado: $e');
  }
  
  // Crear usuario admin por defecto si no existe
  await createDefaultAdminUser();
  
  // Asegurar que la app inicie siempre en el login (cerrar sesión si existe)
  await Supabase.instance.client.auth.signOut();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authService: AuthService())..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => ProductBloc(productService: ProductService())..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => StoreBloc(storeService: StoreService())..add(LoadStores()),
        ),
        BlocProvider(
          create: (context) => WarehouseBloc(warehouseService: WarehouseService())..add(LoadWarehouses()),
        ),
        BlocProvider(
          create: (context) => EmployeeBloc(employeeService: EmployeeService())..add(LoadEmployees()),
        ),
        BlocProvider(
          create: (context) => SaleBloc(saleService: SaleService()),
        ),
        BlocProvider(
          create: (context) => PurchaseBloc(purchaseService: PurchaseService()),
        ),
        BlocProvider(
          create: (context) => TransferBloc(transferService: TransferService()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Sistema de Inventario',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
