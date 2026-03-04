import 'api_service.dart';
import '../models/reserva.dart';

/// Servicio para gestionar Reservas desde el backend Occitours.
///
/// Endpoints usados (vista cliente):
/// - GET  /api/reservas/cliente/:idCliente → Reservas del cliente (auth)
/// - GET  /api/reservas/:id               → Detalle de reserva (auth)
/// - GET  /api/reservas/buscar            → Buscar reservas (auth)
/// - POST /api/reservas                   → Crear reserva (auth, rol Cliente)
/// - POST /api/reservas/:id/cancelar      → Cancelar reserva (auth, rol Cliente)
/// - POST /api/reservas/:id/acompanante   → Agregar acompañante (auth, rol Cliente)
class ReservaService {
  final ApiService _api = ApiService();

  // Singleton
  static final ReservaService _instance = ReservaService._internal();
  factory ReservaService() => _instance;
  ReservaService._internal();

  /// Obtener las reservas de un cliente específico.
  Future<List<Reserva>> getByCliente(int idCliente) async {
    try {
      final response = await _api.get('/reservas/cliente/$idCliente');

      if (response is List) {
        return response.map((json) => Reserva.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Reserva.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalle de una reserva por ID.
  Future<Reserva> getById(int id) async {
    try {
      final response = await _api.get('/reservas/$id');

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Reserva.fromJson(response['data']);
        }
        return Reserva.fromJson(response);
      }

      throw Exception('Reserva no encontrada');
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar reservas.
  Future<List<Reserva>> buscar({
    String? query,
    String? estado,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (query != null) params['q'] = query;
      if (estado != null) params['estado'] = estado;
      if (fechaDesde != null) params['fecha_desde'] = fechaDesde;
      if (fechaHasta != null) params['fecha_hasta'] = fechaHasta;

      final response = await _api.get(
        '/reservas/buscar',
        queryParameters: params,
      );

      if (response is List) {
        return response.map((json) => Reserva.fromJson(json)).toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list.map((json) => Reserva.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Crear una nueva reserva.
  ///
  /// El cliente puede crear su propia reserva.
  Future<Reserva> crear({
    required int idCliente,
    required String fechaInicio,
    required String fechaFin,
    required int cantidadPersonas,
    String? observaciones,
  }) async {
    try {
      final body = <String, dynamic>{
        'id_cliente': idCliente,
        'fecha_inicio': fechaInicio,
        'fecha_fin': fechaFin,
        'cantidad_personas': cantidadPersonas,
      };

      if (observaciones != null) body['observaciones'] = observaciones;

      final response = await _api.post('/reservas', body);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Reserva.fromJson(response['data']);
        }
        return Reserva.fromJson(response);
      }

      throw Exception('Error al crear reserva');
    } catch (e) {
      rethrow;
    }
  }

  /// Cancelar una reserva existente.
  ///
  /// El cliente puede cancelar su propia reserva.
  Future<bool> cancelar(int idReserva) async {
    try {
      final response = await _api.post('/reservas/$idReserva/cancelar', {});

      if (response is Map) {
        return response['success'] == true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Agregar un acompañante a una reserva.
  ///
  /// El cliente puede agregar acompañantes a sus reservas.
  Future<bool> agregarAcompanante({
    required int idReserva,
    required String nombre,
    String? apellido,
    String? tipoDocumento,
    String? numeroDocumento,
    String? telefono,
    int? edad,
  }) async {
    try {
      final body = <String, dynamic>{
        'nombre': nombre,
      };

      if (apellido != null) body['apellido'] = apellido;
      if (tipoDocumento != null) body['tipo_documento'] = tipoDocumento;
      if (numeroDocumento != null) body['numero_documento'] = numeroDocumento;
      if (telefono != null) body['telefono'] = telefono;
      if (edad != null) body['edad'] = edad;

      final response = await _api.post(
        '/reservas/$idReserva/acompanante',
        body,
      );

      if (response is Map) {
        return response['success'] == true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }
}
