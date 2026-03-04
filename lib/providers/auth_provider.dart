import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

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
  Future<bool> register({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    String? tipoDocumento,
    String? numeroDocumento,
    String? telefono,
    String? direccion,
    String? fechaNacimiento,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        correo: correo,
        contrasena: contrasena,
        nombre: nombre,
        apellido: apellido,
        tipoDocumento: tipoDocumento,
        numeroDocumento: numeroDocumento,
        telefono: telefono,
        direccion: direccion,
        fechaNacimiento: fechaNacimiento,
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

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Parsear mensajes de error para mostrar al usuario
  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Credenciales inválidas') || msg.contains('incorrectos')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('Correo ya registrado')) {
      return 'Ya existe una cuenta con este correo';
    }
    if (msg.contains('Cuenta inactiva')) {
      return 'Tu cuenta ha sido desactivada';
    }
    if (msg.contains('Campos incompletos')) {
      return 'Por favor completa todos los campos requeridos';
    }
    if (msg.contains('connectionError') || msg.contains('conectar')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    if (msg.contains('Timeout')) {
      return 'El servidor no respondió. Intenta de nuevo.';
    }
    return 'Ha ocurrido un error. Intenta de nuevo.';
  }
}
