import 'api_service.dart';
import '../models/finca.dart';

/// Servicio para gestionar Fincas desde el backend Occitours.
///
/// Endpoints usados (vista cliente - solo lectura):
/// - GET /api/fincas              → Todas las fincas
/// - GET /api/fincas/disponibles  → Solo fincas disponibles
/// - GET /api/fincas/buscar       → Buscar fincas por nombre/ubicación
/// - GET /api/fincas/:id          → Detalle de una finca
class FincaService {
  final ApiService _api = ApiService();

  // Singleton
  static final FincaService _instance = FincaService._internal();
  factory FincaService() => _instance;
  FincaService._internal();

  /// Obtener todas las fincas.
  Future<List<Finca>> getAll() async {
    try {
      final response = await _api.get('/fincas');

      if (response is List) {
        return response.map((json) => Finca.fromJson(json)).toList();
      }

      // Si viene envuelto en un objeto con data/fincas
      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Finca.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener fincas disponibles.
  Future<List<Finca>> getDisponibles() async {
    try {
      final response = await _api.get('/fincas/disponibles');

      if (response is List) {
        return response.map((json) => Finca.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Finca.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar fincas por nombre o ubicación.
  Future<List<Finca>> buscar(String query) async {
    try {
      final response = await _api.get(
        '/fincas/buscar',
        queryParameters: {'q': query},
      );

      if (response is List) {
        return response.map((json) => Finca.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Finca.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de una finca por ID.
  Future<Finca> getById(int id) async {
    try {
      final response = await _api.get('/fincas/$id');

      if (response is Map<String, dynamic>) {
        // Puede venir directo o en response['data']
        if (response.containsKey('data')) {
          return Finca.fromJson(response['data']);
        }
        return Finca.fromJson(response);
      }

      throw Exception('Finca no encontrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener imágenes de una finca (endpoint público en backend).
  Future<List<String>> getImagenes(int idFinca) async {
    try {
      final response = await _api.get('/fincas/$idFinca/imagenes');

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
