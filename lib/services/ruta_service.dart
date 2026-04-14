import 'api_service.dart';
import '../models/ruta.dart';

/// Servicio para gestionar Rutas turísticas desde el backend Occitours.
///
/// Endpoints usados (vista cliente):
/// - GET /api/rutas               → Todas las rutas (auth)
/// - GET /api/rutas/activas       → Rutas activas (público)
/// - GET /api/rutas/buscar        → Buscar rutas (público)
/// - GET /api/rutas/dificultad/:d → Por dificultad (público)
/// - GET /api/rutas/:id           → Detalle de una ruta (auth)
class RutaService {
  final ApiService _api = ApiService();

  // Singleton
  static final RutaService _instance = RutaService._internal();
  factory RutaService() => _instance;
  RutaService._internal();

  /// Obtener todas las rutas (requiere autenticación).
  Future<List<Ruta>> getAll() async {
    try {
      final response = await _api.get('/rutas');

      if (response is List) {
        return response.map((json) => Ruta.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Ruta.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener rutas activas (endpoint público, no requiere auth).
  Future<List<Ruta>> getActivas() async {
    try {
      final response = await _api.get('/rutas/activas');

      if (response is List) {
        return response.map((json) => Ruta.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Ruta.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar rutas por nombre o ubicación (endpoint público).
  Future<List<Ruta>> buscar(String query) async {
    try {
      final response = await _api.get(
        '/rutas/buscar',
        queryParameters: {'q': query},
      );

      if (response is List) {
        return response.map((json) => Ruta.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Ruta.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener rutas por nivel de dificultad (endpoint público).
  /// Valores válidos: 'facil', 'moderado', 'dificil'
  Future<List<Ruta>> getByDificultad(String dificultad) async {
    try {
      final response = await _api.get('/rutas/dificultad/$dificultad');

      if (response is List) {
        return response.map((json) => Ruta.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Ruta.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de una ruta por ID (requiere auth).
  Future<Ruta> getById(int id) async {
    try {
      final response = await _api.get('/rutas/$id');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Ruta.fromJson(response['data']);
        }
        return Ruta.fromJson(response);
      }

      throw Exception('Ruta no encontrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener imágenes de una ruta (endpoint público en backend).
  Future<List<String>> getImagenes(int idRuta) async {
    try {
      final response = await _api.get('/rutas/$idRuta/imagenes');

      if (response is List) {
        return response
            .whereType<Map>()
            .map((item) => (item['url'] ?? '').toString())
            .where((url) => url.isNotEmpty)
            .toList();
      }

      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .whereType<Map>()
            .map((item) => (item['url'] ?? '').toString())
            .where((url) => url.isNotEmpty)
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}
