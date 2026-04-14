import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> _normalizeRuta(Map<String, dynamic> raw) {
    final dificultadRaw = (raw['dificultad'] ?? '').toString().trim();
    final dificultadNormalizada = dificultadRaw.isEmpty
        ? 'Moderado'
        : dificultadRaw[0].toUpperCase() +
              dificultadRaw.substring(1).toLowerCase();

    return {
      ...raw,
      'id': _toInt(raw['id'] ?? raw['id_ruta']),
      'id_ruta': _toInt(raw['id_ruta'] ?? raw['id']),
      'nombre': (raw['nombre'] ?? 'Sin nombre').toString(),
      'descripcion': (raw['descripcion'] ?? '').toString(),
      'ubicacion': (raw['ubicacion'] ?? raw['departamento'] ?? '').toString(),
      'precio': _toDouble(raw['precio'] ?? raw['precio_base']),
      'duracion': _toDouble(raw['duracion'] ?? raw['duracion_dias']),
      'capacidad': _toInt(raw['capacidad'] ?? raw['capacidad_personas']),
      'dificultad': dificultadNormalizada,
      'imagen_principal':
          (raw['imagen_principal'] ?? raw['imagen_url'] ?? raw['imagen'] ?? '')
              .toString(),
      'incluye': raw['incluye'] is List
          ? List<String>.from(raw['incluye'])
          : <String>[],
      'disponible': raw['estado'] is bool ? raw['estado'] : true,
    };
  }

  Future<Map<String, dynamic>> _enrichRutaWithStorageImage(
    Map<String, dynamic> ruta,
  ) async {
    final currentImage = (ruta['imagen_principal'] ?? '').toString().trim();
    if (currentImage.startsWith('http')) {
      return ruta;
    }

    final idRuta = _toInt(ruta['id_ruta'] ?? ruta['id']);
    if (idRuta <= 0) return ruta;

    try {
      final response = await _apiService.get('/rutas/$idRuta/imagenes');
      List<dynamic> items = [];

      if (response is List) {
        items = response;
      } else if (response is Map && response['data'] is List) {
        items = response['data'] as List;
      }

      if (items.isEmpty) return ruta;

      final first = items.first;
      if (first is Map) {
        final url = (first['url'] ?? '').toString().trim();
        if (url.startsWith('http')) {
          return {...ruta, 'imagen_principal': url};
        }
      }
      return ruta;
    } catch (_) {
      return ruta;
    }
  }

  Map<String, dynamic> _normalizeFinca(Map<String, dynamic> raw) {
    return {
      ...raw,
      'id': _toInt(raw['id'] ?? raw['id_finca']),
      'id_finca': _toInt(raw['id_finca'] ?? raw['id']),
      'nombre': (raw['nombre'] ?? 'Sin nombre').toString(),
      'descripcion': (raw['descripcion'] ?? '').toString(),
      'ubicacion': (raw['ubicacion'] ?? raw['direccion'] ?? '').toString(),
      'capacidad_personas': _toInt(
        raw['capacidad_personas'] ?? raw['capacidad'],
      ),
      'precio_por_noche': _toDouble(
        raw['precio_por_noche'] ?? raw['precioNoche'] ?? raw['precio'],
      ),
      'imagen_principal': (raw['imagen_principal'] ?? raw['imagen'] ?? '')
          .toString(),
      'servicios': raw['servicios'] is List
          ? List<String>.from(raw['servicios'])
          : <String>[],
      'disponible': raw['estado'] is bool ? raw['estado'] : true,
    };
  }

  Future<Map<String, dynamic>> _enrichFincaWithStorageImage(
    Map<String, dynamic> finca,
  ) async {
    final currentImage = (finca['imagen_principal'] ?? '').toString().trim();
    if (currentImage.startsWith('http')) {
      return finca;
    }

    final idFinca = _toInt(finca['id_finca'] ?? finca['id']);
    if (idFinca <= 0) return finca;

    try {
      final response = await _apiService.get('/fincas/$idFinca/imagenes');
      List<dynamic> items = [];

      if (response is List) {
        items = response;
      } else if (response is Map && response['data'] is List) {
        items = response['data'] as List;
      }

      if (items.isEmpty) return finca;

      final first = items.first;
      if (first is Map) {
        final url = (first['url'] ?? '').toString().trim();
        if (url.startsWith('http')) {
          return {...finca, 'imagen_principal': url};
        }
      }
      return finca;
    } catch (_) {
      return finca;
    }
  }

  /// Obtener lista de fincas
  Future<void> fetchFincas() async {
    _isLoadingFincas = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/fincas');

      if (response is List) {
        _fincas = response
            .whereType<Map<String, dynamic>>()
            .map(_normalizeFinca)
            .toList();
      } else if (response is Map && response['data'] is List) {
        _fincas = (response['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(_normalizeFinca)
            .toList();
      } else {
        _fincas = [];
      }

      if (_fincas.isNotEmpty) {
        _fincas = await Future.wait(
          _fincas.whereType<Map<String, dynamic>>().map(
            _enrichFincaWithStorageImage,
          ),
        );
      }

      _isLoadingFincas = false;
    } catch (e) {
      _error = e.toString();
      _isLoadingFincas = false;
      _fincas = [];
    }
    notifyListeners();
  }

  /// Obtener lista de rutas
  Future<void> fetchRutas() async {
    _isLoadingRutas = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/rutas');

      if (response is List) {
        _rutas = response
            .whereType<Map<String, dynamic>>()
            .map(_normalizeRuta)
            .toList();
      } else if (response is Map && response['data'] is List) {
        _rutas = (response['data'] as List)
            .whereType<Map<String, dynamic>>()
            .map(_normalizeRuta)
            .toList();
      } else {
        _rutas = [];
      }

      if (_rutas.isNotEmpty) {
        _rutas = await Future.wait(
          _rutas.whereType<Map<String, dynamic>>().map(
            _enrichRutaWithStorageImage,
          ),
        );
      }

      _isLoadingRutas = false;
    } catch (e) {
      _error = e.toString();
      _isLoadingRutas = false;
      _rutas = [];
    }
    notifyListeners();
  }

  /// Obtener finca por ID
  dynamic getFincaById(int id) {
    try {
      return _fincas.firstWhere((f) {
        if (f is Map) {
          return f['id'] == id;
        }
        return false;
      });
    } catch (e) {
      return null;
    }
  }

  /// Obtener ruta por ID
  dynamic getRutaById(int id) {
    try {
      return _rutas.firstWhere((r) {
        if (r is Map) {
          return r['id'] == id || r['id_ruta'] == id;
        }
        return false;
      });
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

      if (f is Map) {
        nombre = (f['nombre'] ?? '').toString();
        ubicacion = (f['ubicacion'] ?? '').toString();
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

      if (r is Map) {
        nombre = (r['nombre'] ?? '').toString();
        ubicacion = (r['ubicacion'] ?? '').toString();
      }

      return nombre.toLowerCase().contains(query.toLowerCase()) ||
          ubicacion.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Filtrar fincas por precio
  List<dynamic> filterFincasByPrice(double minPrice, double maxPrice) {
    return _fincas.where((f) {
      double precio = 0;

      if (f is Map) {
        precio = (f['precio_por_noche'] ?? 0).toDouble();
      }

      return precio >= minPrice && precio <= maxPrice;
    }).toList();
  }

  /// Filtrar rutas por dificultad
  List<dynamic> filterRutasByDifficulty(String difficulty) {
    return _rutas.where((r) {
      if (r is Map) {
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
