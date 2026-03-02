import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

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

  /// Login con email y contraseña
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        _token = response['token'];
        _usuario = Usuario.fromJson(response['usuario']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Respuesta inválida del servidor';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registro con datos nuevos
  Future<bool> register(
    String nombre,
    String email,
    String password,
    String telefono,
    String pais,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('auth/register', {
        'nombre': nombre,
        'email': email,
        'password': password,
        'telefono': telefono,
        'pais': pais,
      });

      if (response != null && response['token'] != null) {
        _token = response['token'];
        _usuario = Usuario.fromJson(response['usuario']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al registrar usuario';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Recuperar contraseña
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post('auth/forgot-password', {
        'email': email,
      });

      if (response != null && response['message'] != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Error al enviar correo de recuperación';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  void logout() {
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
}
