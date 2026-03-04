import 'api_service.dart';
import '../models/programacion.dart';

/// Servicio para gestionar Programaciones desde el backend Occitours.
///
/// Endpoints usados (vista cliente):
/// - GET /api/programaciones               → Todas las programaciones (auth)
/// - GET /api/programaciones/disponibles   → Programaciones disponibles (auth)
/// - GET /api/programaciones/ruta/:id_ruta → Por ruta específica (auth)
/// - GET /api/programaciones/:id           → Detalle (auth)
class ProgramacionService {
  final ApiService _api = ApiService();

  // Singleton
  static final ProgramacionService _instance = ProgramacionService._internal();
  factory ProgramacionService() => _instance;
  ProgramacionService._internal();

  /// Obtener todas las programaciones.
  Future<List<Programacion>> getAll() async {
    try {
      final response = await _api.get('/programaciones');

      if (response is List) {
        return response.map((json) => Programacion.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Programacion.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener programaciones disponibles (con cupos).
  Future<List<Programacion>> getDisponibles() async {
    try {
      final response = await _api.get('/programaciones/disponibles');

      if (response is List) {
        return response.map((json) => Programacion.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Programacion.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener programaciones de una ruta específica.
  Future<List<Programacion>> getByRuta(int idRuta) async {
    try {
      final response = await _api.get('/programaciones/ruta/$idRuta');

      if (response is List) {
        return response.map((json) => Programacion.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Programacion.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de una programación por ID.
  Future<Programacion> getById(int id) async {
    try {
      final response = await _api.get('/programaciones/$id');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Programacion.fromJson(response['data']);
        }
        return Programacion.fromJson(response);
      }

      throw Exception('Programación no encontrada');
    } catch (e) {
      rethrow;
    }
  }
}
