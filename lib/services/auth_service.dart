import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'database_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class AuthService {
  final DatabaseService _db = DatabaseService.instance;
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  // Iniciar sesión con Supabase Auth
  Future<User?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      // Sincronizar usuario localmente
      return await _syncUserLocally(response.user!);
    } catch (e) {
      rethrow;
    }
  }

  // Registrarse con Supabase Auth
  Future<User?> register({
    required String email,
    required String password,
    required String role, // 'admin', 'store_manager', 'warehouse_manager'
    String? name,
    int? employeeId,
    int? storeId,
    int? warehouseId,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role,
          'name': name,
        },
      );

      if (response.user == null) return null;

      // Crear registro en tabla pública de usuarios en Supabase
      // Nota: Idealmente esto se haría con un Trigger en Supabase, 
      // pero lo hacemos aquí para simplificar si no hay triggers configurados.
      try {
        await _supabase.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'role': role,
          'name': name,
          'employee_id': employeeId,
          'store_id': storeId,
          'warehouse_id': warehouseId,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        print('Error creando perfil público: $e');
        // Continuamos aunque falle esto, para no bloquear el login
      }

      // Sincronizar usuario localmente
      return await _syncUserLocally(response.user!, 
        role: role, 
        name: name,
        employeeId: employeeId,
        storeId: storeId,
        warehouseId: warehouseId
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sincronizar usuario de Supabase a base de datos local
  Future<User> _syncUserLocally(supabase.User supabaseUser, {
    String? role,
    String? name,
    int? employeeId,
    int? storeId,
    int? warehouseId,
  }) async {
    final db = await _db.database;
    
    // Intentar obtener datos adicionales si no se pasaron
    if (role == null) {
      try {
        final userData = await _supabase
            .from('users')
            .select()
            .eq('id', supabaseUser.id)
            .single();
        
        role = userData['role'];
        name = userData['name'];
        employeeId = userData['employee_id'];
        storeId = userData['store_id'];
        warehouseId = userData['warehouse_id'];
      } catch (e) {
        print('Error obteniendo datos de usuario: $e');
      }
    }

    // Verificar si existe localmente por supabaseId o email
    final existingUser = await (db.select(db.users)
          ..where((u) => u.supabaseId.equals(supabaseUser.id) | u.email.equals(supabaseUser.email!)))
        .getSingleOrNull();

    final companion = UsersCompanion(
      email: Value(supabaseUser.email!),
      supabaseId: Value(supabaseUser.id),
      role: Value(role ?? 'admin'), // Fallback a admin si no hay rol
      name: Value(name),
      employeeId: Value(employeeId),
      storeId: Value(storeId),
      warehouseId: Value(warehouseId),
      password: const Value(''), // Ya no guardamos password localmente
      isSynced: const Value(true),
      updatedAt: Value(DateTime.now()),
    );

    if (existingUser != null) {
      await (db.update(db.users)..where((u) => u.id.equals(existingUser.id)))
          .write(companion);
      return await (db.select(db.users)..where((u) => u.id.equals(existingUser.id))).getSingle();
    } else {
      final id = await db.into(db.users).insert(companion);
      return await (db.select(db.users)..where((u) => u.id.equals(id))).getSingle();
    }
  }

  // Obtener usuario actual
  Future<User?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    final db = await _db.database;
    return await (db.select(db.users)
          ..where((u) => u.supabaseId.equals(session.user.id)))
        .getSingleOrNull();
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Store Supabase session tokens securely
  Future<void> storeSessionTokens(supabase.Session session) async {
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'supabase_access_token', value: session.accessToken);
    await storage.write(key: 'supabase_refresh_token', value: session.refreshToken);
  }

  // ---------- MFA SUPPORT ----------
  /// Enroll the user in TOTP MFA. Returns the QR code data that can be shown in UI.
  Future<String?> enrollMFA() async {
    try {
      final response = await _supabase.auth.mfa.enroll(
        factorType: supabase.FactorType.totp,
      );
      // The response contains a QR code URL (data:image/png;base64,...) that can be displayed.
      return response.totp?.qrCode;
    } catch (e) {
      print('Error enrolling MFA: $e');
      return null;
    }
  }

  /// Perform login with password, then if MFA is required, challenge and verify the TOTP code.
  /// Returns the authenticated user or null if verification fails.
  Future<User?> loginWithMFA(String email, String password, String totpCode) async {
    try {
      // First step: password authentication
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // If the user does not exist or password is wrong
      if (response.user == null) return null;

      // Check if MFA is required for this session
      if (response.session?.mfaRequired == true) {
        // Challenge the factor (the factorId is obtained from the session)
        final challenge = await _supabase.auth.mfa.challenge(
          factorId: response.session!.factorId!,
        );
        // Verify the TOTP code supplied by the user
        await _supabase.auth.mfa.verify(
          factorId: response.session!.factorId!,
          challengeId: challenge.id,
          code: totpCode,
        );
      }

      // After successful MFA (or if not required), sync locally and return user
      return await _syncUserLocally(response.user!);
    } catch (e) {
      print('Error during MFA login: $e');
      rethrow;
    }
  }

  Future<bool> hasPermission(User user, String permission) async {
    // Lógica de permisos basada en el rol
    switch (user.role) {
      case 'admin':
        return true;
      case 'store_manager':
        return permission.startsWith('store.') || permission == 'sale.';
      case 'warehouse_manager':
        return permission.startsWith('warehouse.') || permission == 'purchase.';
      default:
        return false;
    }
  }
}
