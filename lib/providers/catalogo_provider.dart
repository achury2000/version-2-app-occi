import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/finca.dart';
import '../models/ruta.dart';

class CatalogoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Finca> _fincas = [];
  List<Ruta> _rutas = [];
  bool _isLoadingFincas = false;
  bool _isLoadingRutas = false;
  String? _error;

  // Getters
  List<Finca> get fincas => _fincas;
  List<Ruta> get rutas => _rutas;
  bool get isLoadingFincas => _isLoadingFincas;
  bool get isLoadingRutas => _isLoadingRutas;
  String? get error => _error;

  /// Obtener lista de fincas
  Future<void> fetchFincas() async {
    _isLoadingFincas = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('fincas');

      if (response is List) {
        _fincas = response.map((json) => Finca.fromJson(json)).toList();
      } else if (response is Map && response['data'] != null) {
        _fincas = (response['data'] as List)
            .map((json) => Finca.fromJson(json))
            .toList();
      }
      _isLoadingFincas = false;
    } catch (e) {
      _error = e.toString();
      _isLoadingFincas = false;
    }
    notifyListeners();
  }

  /// Obtener lista de rutas
  Future<void> fetchRutas() async {
    _isLoadingRutas = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('rutas');

      if (response is List) {
        _rutas = response.map((json) => Ruta.fromJson(json)).toList();
      } else if (response is Map && response['data'] != null) {
        _rutas = (response['data'] as List)
            .map((json) => Ruta.fromJson(json))
            .toList();
      }
      _isLoadingRutas = false;
    } catch (e) {
      _error = e.toString();
      _isLoadingRutas = false;
    }
    notifyListeners();
  }

  /// Obtener finca por ID
  Finca? getFincaById(int id) {
    try {
      return _fincas.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener ruta por ID
  Ruta? getRutaById(int id) {
    try {
      return _rutas.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Buscar fincas por nombre
  List<Finca> searchFincas(String query) {
    if (query.isEmpty) return _fincas;
    return _fincas
        .where((f) =>
            f.nombre.toLowerCase().contains(query.toLowerCase()) ||
            f.ubicacion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Buscar rutas por nombre
  List<Ruta> searchRutas(String query) {
    if (query.isEmpty) return _rutas;
    return _rutas
        .where((r) =>
            r.nombre.toLowerCase().contains(query.toLowerCase()) ||
            r.ubicacion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filtrar fincas por precio
  List<Finca> filterFincasByPrice(double minPrice, double maxPrice) {
    return _fincas
        .where((f) => f.precioNoche >= minPrice && f.precioNoche <= maxPrice)
        .toList();
  }

  /// Filtrar rutas por dificultad
  List<Ruta> filterRutasByDifficulty(String difficulty) {
    return _rutas.where((r) => r.dificultad == difficulty).toList();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
