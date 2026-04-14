import '../models/servicio.dart';
import 'api_service.dart';

/// Service para gestionar operaciones HTTP con Servicios
/// Conecta con el backend API usando ApiService (con autenticación JWT)
class ServicioService {
  final ApiService _api = ApiService();

  /// Obtener todos los servicios disponibles
  /// GET /servicios/disponibles
  Future<List<Servicio>> obtenerServiciosDisponibles() async {
    try {
      final dynamic response = await _api.get('/servicios/disponibles');

      List<dynamic> jsonData;

      if (response is List) {
        jsonData = response;
      } else if (response is Map && response['data'] is List) {
        jsonData = response['data'] as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido en /servicios/disponibles');
      }

      return jsonData
          .map((s) => Servicio.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener servicios por tipo
  /// GET /servicios/tipo/:tipo
  Future<List<Servicio>> obtenerServiciosPorTipo(String tipo) async {
    try {
      final dynamic response = await _api.get('/servicios/tipo/$tipo');

      List<dynamic> jsonData;
      if (response is List) {
        jsonData = response;
      } else if (response is Map && response['data'] is List) {
        jsonData = response['data'] as List<dynamic>;
      } else {
        jsonData = [];
      }

      return jsonData
          .map((s) => Servicio.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener servicio por ID
  /// GET /servicios/:id
  Future<Servicio> obtenerServicioById(int id) async {
    try {
      final dynamic response = await _api.get('/servicios/$id');

      if (response is Map<String, dynamic>) {
        return Servicio.fromJson(response);
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todos los servicios (sin filtro)
  /// GET /servicios/
  Future<List<Servicio>> obtenerTodosLosServicios() async {
    try {
      final dynamic response = await _api.get('/servicios');

      List<dynamic> jsonData;
      if (response is List) {
        jsonData = response;
      } else if (response is Map && response['data'] is List) {
        jsonData = response['data'] as List<dynamic>;
      } else {
        jsonData = [];
      }

      return jsonData
          .map((s) => Servicio.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo servicio (solo admin)
  /// POST /servicios/
  Future<Servicio> crearServicio({
    required String nombre,
    required String descripcion,
    required double precio,
    String? imagenUrl,
  }) async {
    try {
      final response = await _api.post(
        '/servicios',
        {
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'imagen_url': imagenUrl,
        },
      );

      if (response is Map<String, dynamic>) {
        return Servicio.fromJson(response);
      } else {
        throw Exception('Error: Respuesta inválida');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar servicio (solo admin)
  /// PUT /servicios/:id
  Future<Servicio> actualizarServicio({
    required int id,
    required String nombre,
    required String descripcion,
    required double precio,
    String? imagenUrl,
    required bool estado,
  }) async {
    try {
      final response = await _api.put(
        '/servicios/$id',
        {
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'imagen_url': imagenUrl,
          'estado': estado,
        },
      );

      if (response is Map<String, dynamic>) {
        return Servicio.fromJson(response);
      } else {
        throw Exception('Error: Respuesta inválida');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar servicio (solo admin)
  /// DELETE /servicios/:id
  Future<void> eliminarServicio(int id) async {
    try {
      await _api.delete('/servicios/$id');
    } catch (e) {
      rethrow;
    }
  }
}
