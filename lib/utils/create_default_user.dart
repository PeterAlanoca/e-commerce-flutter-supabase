import '../services/auth_service.dart';

/// Script para crear un usuario admin por defecto
/// Ejecutar una vez al iniciar la app por primera vez
Future<void> createDefaultAdminUser() async {
  final authService = AuthService();
  
  try {
    // Intentar crear usuario admin por defecto
    await authService.register(
      email: 'admin@inventario.com',
      password: 'admin123',
      role: 'admin',
      name: 'Administrador',
    );
    print('✅ Usuario admin creado: admin@inventario.com / admin123');
  } catch (e) {
    // Si ya existe, no hacer nada
    if (e.toString().contains('ya está registrado')) {
      print('ℹ️ Usuario admin ya existe');
    } else {
      print('⚠️ Error creando usuario admin: $e');
    }
  }
}


