import 'api_service.dart';
import '../models/programacion_personal.dart';

/// Servicio para gestionar Programaciones Personales del cliente.
///
/// Endpoints usados (vista cliente):
/// - GET  /programaciones-personales/cliente/:idCliente → Listar propias (auth)
/// - GET  /programaciones-personales/:id                → Detalle (auth)
/// - POST /programaciones-personales                    → Crear (auth)
/// - PUT  /programaciones-personales/:id                → Editar (auth)
/// - PUT  /programaciones-personales/:id/completar      → Marcar completada (auth)
/// - DELETE /programaciones-personales/:id              → Eliminar (auth)
class ProgramacionPersonalService {
  final ApiService _api = ApiService();

  // Singleton
  static final ProgramacionPersonalService _instance =
      ProgramacionPersonalService._internal();
  factory ProgramacionPersonalService() => _instance;
  ProgramacionPersonalService._internal();

  /// Obtener programaciones personales de un cliente.
  Future<List<ProgramacionPersonal>> getByCliente(int idCliente) async {
    try {
      final response = await _api.get('/programaciones-personales/cliente/$idCliente');

      if (response is List) {
        return response
            .map((json) => ProgramacionPersonal.fromJson(json))
            .toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list
            .map((json) => ProgramacionPersonal.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de una programación personal.
  Future<ProgramacionPersonal> getById(int id) async {
    try {
      final response = await _api.get('/programaciones-personales/$id');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return ProgramacionPersonal.fromJson(response['data']);
        }
        return ProgramacionPersonal.fromJson(response);
      }

      throw Exception('Programación personal no encontrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Crear una nueva programación personal.
  Future<ProgramacionPersonal> crear({
    required int idCliente,
    required String titulo,
    String? descripcion,
    DateTime? fechaProgramacion,
    String? horaProgramacion,
  }) async {
    try {
      final body = <String, dynamic>{
        'id_cliente': idCliente,
        'titulo': titulo,
      };

      if (descripcion != null) body['descripcion'] = descripcion;
      if (fechaProgramacion != null) {
        body['fecha_programacion'] = fechaProgramacion.toIso8601String();
      }
      if (horaProgramacion != null) body['hora_programacion'] = horaProgramacion;

      final response = await _api.post('/programaciones-personales', body);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return ProgramacionPersonal.fromJson(response['data']);
        }
        return ProgramacionPersonal.fromJson(response);
      }

      throw Exception('Error al crear programación personal');
    } catch (e) {
      rethrow;
    }
  }

  /// Editar una programación personal existente.
  Future<ProgramacionPersonal> actualizar({
    required int id,
    String? titulo,
    String? descripcion,
    DateTime? fechaProgramacion,
    String? horaProgramacion,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (titulo != null) body['titulo'] = titulo;
      if (descripcion != null) body['descripcion'] = descripcion;
      if (fechaProgramacion != null) {
        body['fecha_programacion'] = fechaProgramacion.toIso8601String();
      }
      if (horaProgramacion != null) body['hora_programacion'] = horaProgramacion;

      final response = await _api.put('/programaciones-personales/$id', body);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return ProgramacionPersonal.fromJson(response['data']);
        }
        return ProgramacionPersonal.fromJson(response);
      }

      throw Exception('Error al actualizar programación personal');
    } catch (e) {
      rethrow;
    }
  }

  /// Marcar una programación personal como completada.
  Future<ProgramacionPersonal> marcarCompletada(int id) async {
    try {
      final response = await _api.put('/programaciones-personales/$id/completar', {});

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return ProgramacionPersonal.fromJson(response['data']);
        }
        return ProgramacionPersonal.fromJson(response);
      }

      throw Exception('Error al marcar como completada');
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar una programación personal.
  Future<bool> eliminar(int id) async {
    try {
      final response = await _api.delete('/programaciones-personales/$id');

      if (response is Map) {
        return response['success'] == true;
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
