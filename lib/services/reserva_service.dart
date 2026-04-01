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
  /// El cliente puede crear su propia reserva desde una programación.
  /// Opcionalmente puede incluir servicios adicionales.
  Future<Reserva> crear({
    required int idCliente,
    required int idProgramacion,
    required int cantidadPersonas,
    String? metodoPago,
    String? observaciones,
    List<int>? servicios,
  }) async {
    try {
      final body = <String, dynamic>{
        'id_cliente': idCliente,
        'id_programacion': idProgramacion,
        'cantidad_personas': cantidadPersonas,
      };

      if (metodoPago != null) body['metodo_pago'] = metodoPago;
      if (observaciones != null) body['observaciones'] = observaciones;
      if (servicios != null && servicios.isNotEmpty) {
        body['servicios'] = servicios;
      }

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

  /// Cancelar una reserva existente con motivo/justificación.
  ///
  /// El cliente puede cancelar su propia reserva con un motivo.
  /// Opcionalmente puede proporcionar un motivo de cancelación.
  Future<Reserva> cancelar(int idReserva, {String? motivo}) async {
    try {
      final body = <String, dynamic>{};
      if (motivo != null && motivo.isNotEmpty) {
        body['motivo_cancelacion'] = motivo;
      }

      final response = await _api.post('/reservas/$idReserva/cancelar', body);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Reserva.fromJson(response['data']);
        }
        return Reserva.fromJson(response);
      }

      throw Exception('Error al cancelar reserva');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar una reserva existente.
  ///
  /// El cliente puede editar su propia reserva si está en estado pendiente.
  Future<Reserva> actualizar({
    required int idReserva,
    int? cantidadPersonas,
    String? metodoPago,
    String? observaciones,
    List<int>? servicios,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (cantidadPersonas != null) body['cantidad_personas'] = cantidadPersonas;
      if (metodoPago != null) body['metodo_pago'] = metodoPago;
      if (observaciones != null) body['observaciones'] = observaciones;
      if (servicios != null && servicios.isNotEmpty) {
        body['servicios'] = servicios;
      }

      final response = await _api.put('/reservas/$idReserva', body);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Reserva.fromJson(response['data']);
        }
        return Reserva.fromJson(response);
      }

      throw Exception('Error al actualizar reserva');
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
