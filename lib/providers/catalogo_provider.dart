import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/finca.dart';
import '../models/ruta.dart';
import '../data/fincas_data.dart';
import '../data/rutas_data.dart';

class CatalogoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<dynamic> _fincas = [];
  List<dynamic> _rutas = [];
  bool _isLoadingFincas = false;
  bool _isLoadingRutas = false;
  String? _error;

  // Getters
  List<dynamic> get fincas => _fincas;
  List<dynamic> get rutas => _rutas;
  bool get isLoadingFincas => _isLoadingFincas;
  bool get isLoadingRutas => _isLoadingRutas;
  String? get error => _error;

  /// Obtener lista de fincas
  Future<void> fetchFincas() async {
    _isLoadingFincas = true;
    _error = null;
    notifyListeners();

    try {
      // Primero intentar del backend
      try {
        final response = await _apiService.get('/fincas');

        if (response is List) {
          _fincas = response.map((json) => Finca.fromJson(json)).toList();
        } else if (response is Map && response['data'] != null) {
          _fincas = (response['data'] as List)
              .map((json) => Finca.fromJson(json))
              .toList();
        } else {
          // Si la respuesta del backend está vacía, usar datos locales
          _fincas = FincasData.getAllFincas();
        }

        // Si backend no trae rutas de imagen útiles, priorizar datos locales
        final hasLocalAssetImagePaths = _fincas.any((f) {
          if (f is Finca) {
            final image = (f.imagen ?? '').trim();
            return image.startsWith('assets/');
          }
          if (f is Map) {
            final image =
                (f['imagen_principal'] ?? f['imagen'] ?? '').toString().trim();
            return image.startsWith('assets/');
          }
          return false;
        });

        if (!hasLocalAssetImagePaths) {
          _fincas = FincasData.getAllFincas();
        }
      } catch (e) {
        // Si falla la conexión al backend, usar datos locales
        _fincas = FincasData.getAllFincas();
      }

      _isLoadingFincas = false;
    } catch (e) {
      _error = e.toString();
      _isLoadingFincas = false;
      // Como último recurso, usar datos locales
      _fincas = FincasData.getAllFincas();
    }
    notifyListeners();
  }

  /// Obtener lista de rutas
  Future<void> fetchRutas() async {
    _isLoadingRutas = true;
    _error = null;
    notifyListeners();

    try {
      // Primero intentar del backend
      try {
        final response = await _apiService.get('/rutas');

        if (response is List) {
          _rutas = response.map((json) => Ruta.fromJson(json)).toList();
        } else if (response is Map && response['data'] != null) {
          _rutas = (response['data'] as List)
              .map((json) => Ruta.fromJson(json))
              .toList();
        } else {
          // Si la respuesta del backend está vacía, usar datos locales
          _rutas = RutasData.getAllRutas();
        }
      } catch (e) {
        // Si falla la conexión al backend, usar datos locales
        _rutas = RutasData.getAllRutas();
      }

      _isLoadingRutas = false;
    } catch (e) {
      _error = e.toString();
      _isLoadingRutas = false;
      // Como último recurso, usar datos locales
      _rutas = RutasData.getAllRutas();
    }
    notifyListeners();
  }

  /// Obtener finca por ID
  dynamic getFincaById(int id) {
    try {
      return _fincas.firstWhere((f) {
        if (f is Finca) {
          return f.id == id;
        } else if (f is Map) {
          return f['id'] == id;
        }
        return false;
      });
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
  List<dynamic> searchFincas(String query) {
    if (query.isEmpty) return _fincas;
    return _fincas.where((f) {
      String nombre = '';
      String ubicacion = '';

      if (f is Finca) {
        nombre = f.nombre;
        ubicacion = f.ubicacion;
      } else if (f is Map) {
        nombre = f['nombre'] ?? '';
        ubicacion = f['ubicacion'] ?? '';
      }

      return nombre.toLowerCase().contains(query.toLowerCase()) ||
          ubicacion.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Buscar rutas por nombre
  List<dynamic> searchRutas(String query) {
    if (query.isEmpty) return _rutas;
    return _rutas.where((r) {
      String nombre = '';
      String ubicacion = '';

      if (r is Ruta) {
        nombre = r.nombre;
        ubicacion = r.ubicacion;
      } else if (r is Map) {
        nombre = r['nombre'] ?? '';
        ubicacion = r['ubicacion'] ?? '';
      }

      return nombre.toLowerCase().contains(query.toLowerCase()) ||
          ubicacion.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Filtrar fincas por precio
  List<dynamic> filterFincasByPrice(double minPrice, double maxPrice) {
    return _fincas.where((f) {
      double precio = 0;

      if (f is Finca) {
        precio = f.precioNoche;
      } else if (f is Map) {
        precio = (f['precio_por_noche'] ?? 0).toDouble();
      }

      return precio >= minPrice && precio <= maxPrice;
    }).toList();
  }

  /// Filtrar rutas por dificultad
  List<dynamic> filterRutasByDifficulty(String difficulty) {
    return _rutas.where((r) {
      if (r is Ruta) {
        return r.dificultad == difficulty;
      } else if (r is Map) {
        return r['dificultad'] == difficulty;
      }
      return false;
    }).toList();
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
