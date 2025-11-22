import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/stores/stores_screen.dart';
import '../screens/warehouses/warehouses_screen.dart';
import '../screens/employees/employees_screen.dart';
import '../screens/purchases/purchases_screen.dart';
import '../screens/sales/sales_screen.dart';
import '../screens/transfers/transfers_screen.dart';
import '../screens/reports/reports_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/register';

    if (session != null && isLoggingIn) {
      return '/dashboard';
    }

    if (session == null && !isLoggingIn) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: '/stores',
      builder: (context, state) => const StoresScreen(),
    ),
    GoRoute(
      path: '/warehouses',
      builder: (context, state) => const WarehousesScreen(),
    ),
    GoRoute(
      path: '/employees',
      builder: (context, state) => const EmployeesScreen(),
    ),
    GoRoute(
      path: '/purchases',
      builder: (context, state) => const PurchasesScreen(),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SalesScreen(),
    ),
    GoRoute(
      path: '/transfers',
      builder: (context, state) => const TransfersScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
  ],
);


