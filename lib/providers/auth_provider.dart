import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthProvider() {
    init();
  }

  Usuario? _usuario;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  // Getters
  Usuario? get usuario => _usuario;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  /// Inicializa el provider verificando si hay sesión guardada
  Future<void> init() async {
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      try {
        _token = await _authService.getToken();
        _usuario = await _authService.getProfile();
        _isLoggedIn = true;
      } catch (e) {
        // Token expirado o inválido, limpiar sesión
        await _authService.logout();
        _isLoggedIn = false;
      }
      notifyListeners();
    }
  }

  /// Login con correo y contraseña
  Future<bool> login(String correo, String contrasena) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        correo: correo,
        contrasena: contrasena,
      );

      _token = result['token'] as String;
      _usuario = result['usuario'] as Usuario;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registro de nuevo cliente
  ///
  /// IMPORTANTE: Después del registro, el usuario NO queda autenticado.
  /// Debe verificar su email primero con el código que recibió.
  ///
  /// Solo se requiere correo y contraseña en este paso.
  /// Los datos personales se capturan después en "Completar Perfil".
  Future<bool> register({
    required String correo,
    required String contrasena,
  }) async {
    print('📱 [AuthProvider] Iniciando registro para: $correo');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📱 [AuthProvider] Llamando a authService.register...');
      await _authService.register(
        correo: correo,
        contrasena: contrasena,
      );

      // NO iniciamos sesión automáticamente
      // El usuario debe verificar su email primero
      print('✅ [AuthProvider] Registro exitoso');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [AuthProvider] Error en registro: $e');
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verificar email con el código de verificación
  Future<bool> verifyEmail({
    required String email,
    required String codigo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.verifyEmail(
        email: email,
        codigo: codigo,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reenviar código de verificación al email
  Future<bool> resendVerificationCode(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resendVerificationCode(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cambiar contraseña del usuario autenticado
  Future<bool> cambiarContrasena({
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.cambiarContrasena(
        contrasenaActual: contrasenaActual,
        contrasenaNueva: contrasenaNueva,
      );

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtener perfil actualizado del servidor
  Future<void> refreshProfile() async {
    try {
      _usuario = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      _error = _parseError(e);
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _usuario = null;
    _token = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  /// Solicitar recuperación de contraseña por correo
  Future<bool> forgotPassword(String correo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(correo: correo);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restablecer contraseña con token/código de recuperación
  Future<bool> resetPassword({
    required String correo,
    required String token,
    required String nuevaContrasena,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        correo: correo,
        token: token,
        nuevaContrasena: nuevaContrasena,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtiene la ruta home según rol (actualmente unificada)
  String getHomeRouteByRole() {
    final rol = (_usuario?.rol ?? '').toLowerCase();

    if (rol.contains('admin') ||
        rol.contains('asesor') ||
        rol.contains('guia') ||
        rol.contains('cliente')) {
      return '/home';
    }

    return '/home';
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Parsear mensajes de error para mostrar al usuario
  String _parseError(dynamic e) {
    final msg = e.toString();
    final lowerMsg = msg.toLowerCase();

    bool containsAny(String source, List<String> values) {
      for (final value in values) {
        if (source.contains(value)) {
          return true;
        }
      }
      return false;
    }

    if (containsAny(lowerMsg, [
      'contrase',
      'password',
      'mayúsc',
      'minusc',
      'minúsc',
      'número',
      'numero',
      'especial',
      'uppercase',
      'lowercase',
      'digit',
      'symbol',
      'character',
      'weak',
      'fortaleza',
    ])) {
      return msg.replaceFirst('Exception: ', '');
    }

    if (msg.contains('RESET_CODE:TOKEN_INVALIDO')) {
      return 'El enlace o código no es válido.';
    }
    if (msg.contains('RESET_CODE:TOKEN_EXPIRADO')) {
      return 'El enlace o código expiró. Solicita uno nuevo.';
    }
    if (msg.contains('RESET_CODE:TOKEN_USADO')) {
      return 'Este enlace o código ya fue usado. Solicita uno nuevo.';
    }

    // Errores de reset de contraseña (prioridad alta)
    if (lowerMsg.contains('token') || lowerMsg.contains('código')) {
      if (lowerMsg.contains('expir')) {
        return 'El enlace o código expiró. Solicita uno nuevo.';
      }
      if (lowerMsg.contains('usad') ||
          lowerMsg.contains('consum') ||
          lowerMsg.contains('already used')) {
        return 'Este enlace o código ya fue usado. Solicita uno nuevo.';
      }
      if (lowerMsg.contains('inválid') ||
          lowerMsg.contains('invalido') ||
          lowerMsg.contains('invalido') ||
          lowerMsg.contains('invalid')) {
        return 'El enlace o código no es válido.';
      }
      return 'El código o enlace de recuperación no es válido o expiró.';
    }

    // Errores de login
    if (msg.contains('Credenciales inválidas') || msg.contains('incorrectos')) {
      return 'Correo o contraseña incorrectos';
    }

    // Errores de registro
    if (msg.contains('Correo ya registrado') ||
        msg.contains('Ya existe una cuenta')) {
      return 'Ya existe una cuenta con este correo';
    }

    // Errores de verificación
    if (msg.contains('Código incorrecto') || msg.contains('inválido')) {
      return 'Código de verificación incorrecto';
    }
    if (msg.contains('Código expirado') || msg.contains('expirado')) {
      return 'El código ha expirado. Solicita uno nuevo';
    }
    if (msg.contains('Registro no encontrado') ||
        msg.contains('no hay registro pendiente')) {
      return 'No hay registro pendiente para este correo';
    }

    // Errores de estado de cuenta
    if (msg.contains('Cuenta inactiva')) {
      return 'Tu cuenta ha sido desactivada';
    }
    if (msg.contains('no está verificado') ||
        msg.contains('not verified') ||
        msg.contains('debe verificar')) {
      return 'Debes verificar tu correo antes de iniciar sesión';
    }

    // Errores de validación
    if (msg.contains('Campos incompletos')) {
      return 'Por favor completa todos los campos requeridos';
    }

    // Errores de conexión
    if (msg.contains('connectionError') || msg.contains('conectar')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    if (msg.contains('Timeout')) {
      return 'El servidor no respondió. Intenta de nuevo.';
    }

    if (msg.contains('No se encontró una cuenta')) {
      return 'No se encontró una cuenta con ese correo.';
    }

    return 'Ha ocurrido un error. Intenta de nuevo.';
  }
}
