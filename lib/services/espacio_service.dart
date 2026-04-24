import '../models/espacio.dart';
import 'api_service.dart';

/// Service para gestionar operaciones HTTP con Espacios/Amenidades
class EspacioService {
  final ApiService _api = ApiService();

  /// Obtener todos los espacios disponibles
  /// GET /espacios
  Future<List<Espacio>> obtenerEspacios() async {
    try {
      final dynamic response = await _api.get('/espacios');

      List<dynamic> jsonData;

      if (response is List) {
        jsonData = response;
      } else if (response is Map && response['data'] is List) {
        jsonData = response['data'] as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido en /espacios');
      }

      return jsonData
          .map((e) => Espacio.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener espacio por ID
  /// GET /espacios/:id
  Future<Espacio> obtenerEspacioById(int id) async {
    try {
      final dynamic response = await _api.get('/espacios/$id');

      if (response is Map<String, dynamic>) {
        return Espacio.fromJson(response);
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo espacio (solo admin)
  /// POST /espacios
  Future<Espacio> crearEspacio({
    required String nombre,
    String? descripcion,
    String? icono,
    double? precio,
  }) async {
    try {
      final response = await _api.post(
        '/espacios',
        {
          'nombre': nombre,
          'descripcion': descripcion,
          'icono': icono,
          'precio': precio,
        },
      );

      if (response is Map<String, dynamic>) {
        return Espacio.fromJson(response);
      } else {
        throw Exception('Error: Respuesta inválida');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar espacio (solo admin)
  /// PUT /espacios/:id
  Future<Espacio> actualizarEspacio({
    required int id,
    required String nombre,
    String? descripcion,
    String? icono,
    double? precio,
    required bool disponible,
  }) async {
    try {
      final response = await _api.put(
        '/espacios/$id',
        {
          'nombre': nombre,
          'descripcion': descripcion,
          'icono': icono,
          'precio': precio,
          'disponible': disponible,
        },
      );

      if (response is Map<String, dynamic>) {
        return Espacio.fromJson(response);
      } else {
        throw Exception('Error: Respuesta inválida');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar espacio (solo admin)
  /// DELETE /espacios/:id
  Future<void> eliminarEspacio(int id) async {
    try {
      await _api.delete('/espacios/$id');
    } catch (e) {
      rethrow;
    }
  }
}
