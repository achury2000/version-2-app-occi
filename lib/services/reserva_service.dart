import 'api_service.dart';
import '../models/reserva.dart';
import 'token_service.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

/// Servicio para gestionar Reservas desde el backend Occitours.
///
/// Endpoints usados (vista cliente):
/// - GET  /api/reservas/mis-reservas      → Reservas del cliente autenticado
/// - GET  /api/reservas/mis-reservas/:id  → Detalle de reserva del cliente
/// - GET  /api/reservas/buscar            → Buscar reservas (auth)
/// - POST /api/reservas                   → Crear reserva (auth, rol Cliente)
/// - POST /api/reservas/:id/cancelar      → Cancelar reserva (auth, rol Cliente)
/// - POST /api/reservas/:id/acompanante   → Agregar acompañante (auth, rol Cliente)
class ReservaService {
  final ApiService _api = ApiService();
  final TokenService _tokenService = TokenService();

  /// Evita disparar decenas de GET a signed-url al pintar el listado (y 401 en cadena).
  static final Map<int, Future<String?>> _signedUrlInflight = {};

  // Singleton
  static final ReservaService _instance = ReservaService._internal();
  factory ReservaService() => _instance;
  ReservaService._internal();

  /// Subcarpeta por fecha de subida (DD-MM-YY), alineada con el backend (`pagoComprobantesService`).
  String carpetaFechaComprobante([DateTime? when]) {
    final n = when ?? DateTime.now();
    final dd = n.day.toString().padLeft(2, '0');
    final mm = n.month.toString().padLeft(2, '0');
    final yy = (n.year % 100).toString().padLeft(2, '0');
    return '$dd-$mm-$yy';
  }

  List<Reserva> _parseReservasResponse(dynamic response) {
    if (response is List) {
      return response.map((json) => Reserva.fromJson(json)).toList();
    }

    if (response is Map) {
      for (final key in const ['data', 'reservas', 'result']) {
        final candidate = response[key];
        if (candidate is List) {
          return candidate.map((json) => Reserva.fromJson(json)).toList();
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _normalizarDetalleReserva(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      return response;
    }

    final reserva = data['reserva'];
    if (reserva is! Map<String, dynamic>) {
      return data;
    }

    final normalizado = Map<String, dynamic>.from(reserva);
    normalizado['fecha_reserva'] =
        normalizado['fecha_reserva'] ?? normalizado['fecha_creacion'];
    final programacion = data['programacion'];
    final resumenPago = data['resumen_pago'];
    final pagos = data['pagos'];

    if (programacion is Map<String, dynamic>) {
      normalizado['id_programacion'] = programacion['id_programacion'];
      normalizado['fecha_inicio'] =
          programacion['fecha_salida'] ?? normalizado['fecha_inicio'];
      normalizado['fecha_fin'] =
          programacion['fecha_regreso'] ?? normalizado['fecha_fin'];
      normalizado['cantidad_personas'] =
          programacion['cantidad_personas'] ?? normalizado['cantidad_personas'];
      normalizado['precio_por_persona'] =
          programacion['precio_unitario'] ?? normalizado['precio_por_persona'];

      if (programacion['id_programacion'] != null) {
        normalizado['programaciones'] = [programacion];
      }
    }

    final fincaDetalle = data['finca'];
    if (fincaDetalle is Map<String, dynamic> &&
        fincaDetalle['id_finca'] != null) {
      normalizado['fecha_inicio'] =
          fincaDetalle['fecha_checkin'] ?? normalizado['fecha_inicio'];
      normalizado['fecha_fin'] =
          fincaDetalle['fecha_checkout'] ?? normalizado['fecha_fin'];
      normalizado['fincas'] = [fincaDetalle];
    }

    if (resumenPago is Map<String, dynamic>) {
      normalizado['estado_pago'] = resumenPago['estado_pago'];
      normalizado['precio_total'] =
          normalizado['precio_total'] ??
          normalizado['monto_total'] ??
          resumenPago['monto_total'];
    }

    if (pagos is List &&
        pagos.isNotEmpty &&
        pagos.first is Map<String, dynamic>) {
      final primerPago = pagos.first as Map<String, dynamic>;
      normalizado['metodo_pago'] =
          normalizado['metodo_pago'] ?? primerPago['metodo_pago'];
      normalizado['comprobante_pago'] =
          normalizado['comprobante_pago'] ?? primerPago['comprobante_url'];
    }

    normalizado['servicios'] = data['servicios'];
    normalizado['acompanantes'] = data['acompanantes'] ?? data['acompañantes'];
    normalizado['observaciones'] =
        normalizado['observaciones'] ?? normalizado['notas'];

    return normalizado;
  }

  /// Obtener las reservas de un cliente específico.
  Future<List<Reserva>> getByCliente(int idCliente) async {
    try {
      final response = await _api.get('/reservas/mis-reservas');
      return _parseReservasResponse(response);
    } catch (e) {
      // Compatibilidad con backends antiguos.
      for (final endpoint in const [
        '/reservas/cliente',
        '/reservas/mias',
        '/reservas/mis',
      ]) {
        try {
          final response = endpoint == '/reservas/cliente'
              ? await _api.get('/reservas/cliente/$idCliente')
              : await _api.get(endpoint);
          return _parseReservasResponse(response);
        } catch (_) {
          // Intentar siguiente endpoint para compatibilidad entre backends.
        }
      }

      rethrow;
    }
  }

  /// Obtener detalle de una reserva por ID.
  Future<Reserva> getById(int id) async {
    try {
      final response = await _api.get('/reservas/mis-reservas/$id');

      final normalizado = _normalizarDetalleReserva(response);
      if (normalizado.isNotEmpty) {
        return Reserva.fromJson(normalizado);
      }

      throw Exception('Reserva no encontrada');
    } catch (e) {
      // Compatibilidad con backends que aún exponen detalle en /reservas/:id.
      try {
        final response = await _api.get('/reservas/$id');
        final normalizado = _normalizarDetalleReserva(response);
        if (normalizado.isNotEmpty) {
          return Reserva.fromJson(normalizado);
        }
        if (response is Map<String, dynamic>) {
          if (response.containsKey('data')) {
            return Reserva.fromJson(response['data']);
          }
          return Reserva.fromJson(response);
        }
      } catch (_) {}
      rethrow;
    }
  }

  /// Obtener QR de pago para una reserva.
  ///
  /// El backend puede responder con varias estructuras, por eso se valida
  /// de forma defensiva para extraer una URL utilizable.
  Future<String?> getQrReserva(int idReserva) async {
    try {
      final response = await _api.get('/reservas/$idReserva/qr');

      if (response is Map<String, dynamic>) {
        final data = response['data'];

        if (data is Map<String, dynamic>) {
          final url =
              (data['url'] ??
                      data['qr_url'] ??
                      data['signed_url'] ??
                      data['qr_signed_url'] ??
                      '')
                  .toString()
                  .trim();
          if (url.startsWith('http')) return url;
        }

        final rootUrl =
            (response['url'] ??
                    response['qr_url'] ??
                    response['signed_url'] ??
                    response['qr_signed_url'] ??
                    '')
                .toString()
                .trim();
        if (rootUrl.startsWith('http')) return rootUrl;
      }

      return null;
    } catch (_) {
      return null;
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
  /// Soporta dos modos:
  /// - Con programación: POST /reservas/crear-con-programacion
  /// - Ruta normal (sin programación): POST /reservas
  /// Los acompañantes deben enviarse después con POST /reservas/:id/acompanante.
  Future<Reserva> crear({
    required int idCliente,
    int? idProgramacion,
    int? idRuta,
    required int cantidadPersonas,
    String? metodoPago,
    String? observaciones,
    List<Map<String, dynamic>>? acompanantes,
  }) async {
    try {
      if ((idProgramacion == null || idProgramacion <= 0) &&
          (idRuta == null || idRuta <= 0)) {
        throw Exception('Debes seleccionar una programación o una ruta');
      }

      if (idProgramacion != null && idProgramacion > 0) {
        return await _crearConProgramacion(
          idCliente: idCliente,
          idProgramacion: idProgramacion,
          cantidadPersonas: cantidadPersonas,
          metodoPago: metodoPago,
          observaciones: observaciones,
          acompanantes: acompanantes,
        );
      }

      return await _crearConRuta(
        idCliente: idCliente,
        idRuta: idRuta!,
        cantidadPersonas: cantidadPersonas,
        metodoPago: metodoPago,
        observaciones: observaciones,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Reserva> _crearConProgramacion({
    required int idCliente,
    required int idProgramacion,
    required int cantidadPersonas,
    String? metodoPago,
    String? observaciones,
    List<Map<String, dynamic>>? acompanantes,
  }) async {
    final body = <String, dynamic>{
      'id_cliente': idCliente,
      'id_programacion': idProgramacion,
      'cantidad_personas': cantidadPersonas,
    };

    if (observaciones != null && observaciones.trim().isNotEmpty) {
      body['notas'] = observaciones;
    }

    if (acompanantes != null && acompanantes.isNotEmpty) {
      body['acompanantes'] = acompanantes;
    }

    final response = await _api.post('/reservas/crear-con-programacion', body);

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      int? parseId(dynamic v) {
        if (v == null) return null;
        if (v is int) return v > 0 ? v : null;
        final s = v.toString().trim();
        if (s.isEmpty) return null;
        return int.tryParse(s);
      }

      final idReserva = data is Map<String, dynamic>
          ? parseId(
              data['id_reserva'] ??
                  data['out_id_reserva'] ??
                  data['id'],
            )
          : null;

      final idReservaInt = idReserva;

      if (idReservaInt != null && idReservaInt > 0) {
        if (metodoPago != null && metodoPago.trim().isNotEmpty) {
          try {
            await actualizar(idReserva: idReservaInt, metodoPago: metodoPago);
          } catch (_) {
            // Mantener éxito de creación aunque falle este paso secundario.
          }
        }
        return getById(idReservaInt);
      }
    }

    throw Exception('Error al crear reserva con programación');
  }

  Future<Reserva> _crearConRuta({
    required int idCliente,
    required int idRuta,
    required int cantidadPersonas,
    String? metodoPago,
    String? observaciones,
  }) async {
    final body = <String, dynamic>{
      'id_cliente': idCliente,
      'id_ruta': idRuta,
      'cantidad_personas': cantidadPersonas,
    };

    if (metodoPago != null && metodoPago.trim().isNotEmpty) {
      body['metodo_pago'] = metodoPago;
    }
    if (observaciones != null && observaciones.trim().isNotEmpty) {
      body['notas'] = observaciones;
    }

    final response = await _api.post('/reservas', body);

    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return Reserva.fromJson(data);
      }
      return Reserva.fromJson(response);
    }

    throw Exception('Error al crear reserva por ruta');
  }

  Future<int?> registrarPagoReserva({
    required int idReserva,
    required double monto,
    required String metodoPago,
    String? referencia,
  }) async {
    final body = <String, dynamic>{'monto': monto, 'metodo_pago': metodoPago};

    if (referencia != null && referencia.trim().isNotEmpty) {
      body['referencia'] = referencia;
    }

    final response = await _api.post('/reservas/$idReserva/pagos', body);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final idPago = data['id_pago'] ?? data['id'];
        if (idPago is int) return idPago;
        return int.tryParse(idPago?.toString() ?? '');
      }
    }
    return null;
  }

  Future<void> subirComprobantePago({
    required int idPago,
    required PlatformFile archivo,
    required int idCliente,
    int? idReserva,
  }) async {
    MultipartFile multipart;
    final extension =
        (archivo.extension ??
                (archivo.name.contains('.')
                    ? archivo.name.split('.').last
                    : 'bin'))
            .toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageFileName = 'pago_${idPago}_$timestamp.$extension';
    final carpetaFecha = carpetaFechaComprobante();

    if (archivo.bytes != null) {
      multipart = MultipartFile.fromBytes(
        archivo.bytes!,
        filename: storageFileName,
      );
    } else if (archivo.path != null) {
      multipart = await MultipartFile.fromFile(
        archivo.path!,
        filename: storageFileName,
      );
    } else {
      throw Exception('No se pudo leer el archivo seleccionado');
    }

    final formData = FormData.fromMap({
      'archivo': multipart,
      'bucket': 'comprobantes',
      'bucket_name': 'comprobantes',
      'id_cliente': idCliente,
      if (idReserva != null) 'id_reserva': idReserva,
      'fecha_carpeta': carpetaFecha,
    });

    await _api.postFormData(
      '/pagos/$idPago/comprobante',
      formData,
      queryParameters: {
        'bucket': 'comprobantes',
        'id_cliente': idCliente,
        'fecha_carpeta': carpetaFecha,
        if (idReserva != null) 'id_reserva': idReserva,
      },
    );
  }

  /// URL temporal para ver el comprobante si el bucket es privado.
  Future<String?> obtenerUrlComprobanteFirmada(int idPago) async {
    if (!await _tokenService.hasToken()) return null;
    return _signedUrlInflight.putIfAbsent(
      idPago,
      () => _fetchSignedUrlOnce(idPago).whenComplete(() {
        _signedUrlInflight.remove(idPago);
      }),
    );
  }

  Future<String?> _fetchSignedUrlOnce(int idPago) async {
    try {
      final response = await _api.get('/pagos/$idPago/comprobante/signed-url');
      if (response is Map<String, dynamic>) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final u = data['signedUrl'] ?? data['signed_url'];
          final s = u?.toString().trim() ?? '';
          if (s.startsWith('http')) return s;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<Reserva> crearBaseReserva({
    required int idCliente,
    String? metodoPago,
    String? observaciones,
  }) async {
    final body = <String, dynamic>{'id_cliente': idCliente};

    if (metodoPago != null && metodoPago.trim().isNotEmpty) {
      body['metodo_pago'] = metodoPago;
    }
    if (observaciones != null && observaciones.trim().isNotEmpty) {
      body['notas'] = observaciones;
    }

    final response = await _api.post('/reservas', body);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return Reserva.fromJson(data);
      }
      return Reserva.fromJson(response);
    }

    throw Exception('Error al crear reserva base');
  }

  Future<void> agregarFincaDetalle({
    required int idReserva,
    required int idFinca,
    required DateTime fechaCheckin,
    required DateTime fechaCheckout,
    required int numeroNoches,
    required double precioPorNoche,
  }) async {
    final body = <String, dynamic>{
      'id_finca': idFinca,
      'fecha_checkin': fechaCheckin.toIso8601String(),
      'fecha_checkout': fechaCheckout.toIso8601String(),
      'numero_noches': numeroNoches,
      'precio_por_noche': precioPorNoche,
    };

    await _api.post('/reservas/$idReserva/finca', body);
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

      if (cantidadPersonas != null) {
        body['cantidad_personas'] = cantidadPersonas;
      }
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
    required String apellido,
    String? tipoDocumento,
    String? numeroDocumento,
    String? telefono,
    DateTime? fechaNacimiento,
    int? idCliente,
  }) async {
    try {
      final apellidoValue = apellido.trim().isEmpty ? '-' : apellido.trim();
      final body = <String, dynamic>{
        'nombre': nombre,
        'apellido': apellidoValue,
      };

      if (tipoDocumento != null) body['tipo_documento'] = tipoDocumento;
      if (numeroDocumento != null) body['numero_documento'] = numeroDocumento;
      if (telefono != null) body['telefono'] = telefono;
      if (fechaNacimiento != null) {
        body['fecha_nacimiento'] = fechaNacimiento
            .toIso8601String()
            .split('T')
            .first;
      }
      if (idCliente != null) body['id_cliente'] = idCliente;

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

  /// Agregar un servicio adicional a una reserva existente.
  ///
  /// El cliente puede agregar servicios después de crear la reserva.
  Future<Reserva> agregarServicio({
    required int idReserva,
    required int idServicio,
    int cantidad = 1,
    double? precioUnitario,
  }) async {
    try {
      final response = await _api.post('/reservas/$idReserva/servicio', {
        'id_servicio': idServicio,
        'cantidad': cantidad,
        if (precioUnitario != null) 'precio_unitario': precioUnitario,
      });

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Reserva.fromJson(response['data']);
        }
        return Reserva.fromJson(response);
      }

      throw Exception('Error al agregar servicio');
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar un servicio de una reserva existente.
  ///
  /// El cliente puede eliminar servicios que agregó.
  Future<Reserva> eliminarServicio({
    required int idReserva,
    required int idServicio,
  }) async {
    try {
      final response = await _api.delete(
        '/reservas/$idReserva/servicios/$idServicio',
      );

      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          return Reserva.fromJson(response['data']);
        }
        return Reserva.fromJson(response);
      }

      throw Exception('Error al eliminar servicio');
    } catch (e) {
      rethrow;
    }
  }
}
