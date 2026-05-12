/// Modelo de Reserva que representa una reserva de un cliente.
///
/// Una reserva puede incluir programaciones, fincas, servicios y acompañantes.
class Reserva {
  final int id;
  final int? idCliente;
  final String? nombreCliente;
  final String? apellidoCliente;
  final int? idProgramacion; // NUEVO - FK a programación
  final DateTime? fechaReserva;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? cantidadPersonas;
  final double? precioTotal;
  final double? precioPorPersona; // NUEVO - Precio unitario
  final String? estado; // pendiente, confirmada, completada, cancelada
  final String? estadoPago; // NUEVO - pendiente, pagada
  final String? metodoPago; // NUEVO - transferencia, tarjeta, efectivo
  final String? comprobantePago; // NUEVO - URL del comprobante
  final String? observaciones;
  final String? motivoCancelacion; // NUEVO - Motivo si se cancela
  final List<dynamic>? programaciones;
  final List<dynamic>? fincas;
  final List<dynamic>? servicios;
  final List<dynamic>? acompanantes;
  /// Nombre de ruta en listados planos del API (`mis-reservas`).
  final String? rutaNombreListado;
  /// Nombre de finca en listados planos del API (`mis-reservas`).
  final String? fincaNombreListado;

  Reserva({
    required this.id,
    this.idCliente,
    this.nombreCliente,
    this.apellidoCliente,
    this.idProgramacion,
    this.fechaReserva,
    this.fechaInicio,
    this.fechaFin,
    this.cantidadPersonas,
    this.precioTotal,
    this.precioPorPersona,
    this.estado,
    this.estadoPago,
    this.metodoPago,
    this.comprobantePago,
    this.observaciones,
    this.motivoCancelacion,
    this.programaciones,
    this.fincas,
    this.servicios,
    this.acompanantes,
    this.rutaNombreListado,
    this.fincaNombreListado,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    String? nonEmptyStr(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    final rawInicio =
        json['fecha_inicio'] ??
        json['fecha_salida'] ??
        json['finca_fecha_checkin'];
    final rawFin =
        json['fecha_fin'] ??
        json['fecha_regreso'] ??
        json['finca_fecha_checkout'];

    return Reserva(
      id: parseInt(json['id'] ?? json['id_reserva']) ?? 0,
      idCliente: parseInt(json['id_cliente']),
      nombreCliente:
          json['cliente_nombre'] ?? json['nombre_cliente'] ?? json['nombre'],
      apellidoCliente:
          json['cliente_apellido'] ??
          json['apellido_cliente'] ??
          json['apellido'],
      idProgramacion: parseInt(json['id_programacion']),
      fechaReserva: () {
        final raw = json['fecha_reserva'] ?? json['fecha_creacion'];
        return raw != null ? DateTime.tryParse(raw.toString()) : null;
      }(),
      fechaInicio: rawInicio != null
          ? DateTime.tryParse(rawInicio.toString())
          : null,
      fechaFin: rawFin != null
          ? DateTime.tryParse(rawFin.toString())
          : null,
      cantidadPersonas: parseInt(json['cantidad_personas']),
      precioTotal: parsePrice(json['precio_total'] ?? json['monto_total']),
      precioPorPersona: parsePrice(
        json['precio_por_persona'] ?? json['precio_unitario'],
      ),
      estado: json['estado'],
      estadoPago: json['estado_pago'],
      metodoPago: json['metodo_pago'],
      comprobantePago: json['comprobante_pago'] ?? json['comprobante_url'],
      observaciones: json['observaciones'] ?? json['notas'],
      motivoCancelacion: json['motivo_cancelacion'], // NUEVO
      programaciones: json['programaciones'],
      fincas: json['fincas'],
      servicios: json['servicios'],
      acompanantes: json['acompanantes'],
      rutaNombreListado: nonEmptyStr(json['ruta_nombre']),
      fincaNombreListado: nonEmptyStr(json['finca_nombre']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'id_programacion': idProgramacion, // NUEVO
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'cantidad_personas': cantidadPersonas,
      'precio_total': precioTotal,
      'precio_por_persona': precioPorPersona, // NUEVO
      'estado': estado,
      'estado_pago': estadoPago, // NUEVO
      'metodo_pago': metodoPago, // NUEVO
      'comprobante_pago': comprobantePago, // NUEVO
      'observaciones': observaciones,
      'motivo_cancelacion': motivoCancelacion, // NUEVO
    };
  }

  /// Nombre completo del cliente
  String get clienteNombreCompleto =>
      '${nombreCliente ?? ''} ${apellidoCliente ?? ''}'.trim();

  /// Verifica si la reserva está activa (pendiente o confirmada)
  bool get estaActiva =>
      estado?.toLowerCase() == 'activa' ||
      estado?.toLowerCase() == 'confirmada' ||
      estado?.toLowerCase() == 'pendiente';

  /// Verifica si la reserva fue cancelada
  bool get estaCancelada => estado?.toLowerCase() == 'cancelada';

  /// Verifica si la reserva está completada
  bool get estaCompletada => estado?.toLowerCase() == 'completada';

  /// Verifica si el pago está pendiente
  bool get pagoPendiente => estadoPago?.toLowerCase() == 'pendiente';

  /// Verifica si el pago está hecho
  bool get pagoPagada => estadoPago?.toLowerCase() == 'pagada';

  /// Alojamiento en finca (no salida programada de ruta).
  bool get esReservaFinca {
    if (fincas != null && fincas!.isNotEmpty) return true;
    final o = (observaciones ?? '').toLowerCase();
    return o.contains('finca:');
  }

  /// Personas: detalle programación, u orientativo desde notas ("Personas: N").
  int? get cantidadPersonasEfectiva {
    if (cantidadPersonas != null && cantidadPersonas! > 0) {
      return cantidadPersonas;
    }
    final o = observaciones;
    if (o == null || o.isEmpty) return null;
    final m = RegExp(
      r'Personas:\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(o);
    if (m != null) return int.tryParse(m.group(1)!);
    return null;
  }

  double? _numDesdeMap(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  /// Subtotal hospedaje desde API detalle finca.
  double? get subtotalFinca {
    if (fincas == null || fincas!.isEmpty) return null;
    final f = fincas!.first;
    if (f is! Map) return null;
    return _numDesdeMap(f['subtotal']);
  }

  int? get nochesFinca {
    if (fincas == null || fincas!.isEmpty) return null;
    final f = fincas!.first;
    if (f is! Map) return null;
    final n = f['numero_noches'];
    if (n is int) return n;
    return int.tryParse(n?.toString() ?? '');
  }

  double? get precioPorNocheFinca {
    if (fincas == null || fincas!.isEmpty) return null;
    final f = fincas!.first;
    if (f is! Map) return null;
    return _numDesdeMap(f['precio_por_noche']);
  }

  /// Verifica si tiene comprobante de pago
  bool get tieneComprobante =>
      comprobantePago != null && comprobantePago!.isNotEmpty;

  /// Obtiene el nombre de la ruta o finca (si está disponible)
  String get nombreExperiencia {
    String? u(String? s) {
      if (s == null) return null;
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    final obs = u(observaciones);
    if (obs != null && obs.toLowerCase().contains('finca:')) {
      final m = RegExp(
        r'Finca:\s*([^|]+)',
        caseSensitive: false,
      ).firstMatch(obs);
      if (m != null) {
        final n = m.group(1)?.trim();
        if (n != null && n.isNotEmpty) return n;
      }
    }

    String? desdeMapa(dynamic item) {
      if (item is! Map) return null;
      final n = item['nombre'] ?? item['nombre_finca'] ?? item['finca_nombre'];
      return n != null ? u(n.toString()) : null;
    }

    final planoRuta = u(rutaNombreListado);
    if (planoRuta != null) return planoRuta;

    final planoFinca = u(fincaNombreListado);
    if (planoFinca != null) return planoFinca;

    if (fincas != null && fincas!.isNotEmpty) {
      final n = desdeMapa(fincas!.first);
      if (n != null) return n;
    }

    if (programaciones != null && programaciones!.isNotEmpty) {
      final p0 = programaciones!.first;
      if (p0 is Map) {
        for (final key in const [
          'ruta_nombre',
          'nombre_ruta',
          'nombre_finca',
        ]) {
          final v = p0[key];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString();
          }
        }
      }
    }

    return 'Experiencia';
  }

  /// Verifica si puede ser cancelada (estados permitidos)
  bool get puedeSerCancelada => estaActiva && !estaCompletada;
}

/// Modelo para un acompañante de reserva
class Acompanante {
  final int? id;
  final String nombre;
  final String? apellido;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? telefono;
  final int? edad;

  Acompanante({
    this.id,
    required this.nombre,
    this.apellido,
    this.tipoDocumento,
    this.numeroDocumento,
    this.telefono,
    this.edad,
  });

  factory Acompanante.fromJson(Map<String, dynamic> json) {
    return Acompanante(
      id: json['id'] ?? json['id_acompanante'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'],
      tipoDocumento: json['tipo_documento'],
      numeroDocumento: json['numero_documento'],
      telefono: json['telefono'],
      edad: json['edad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'telefono': telefono,
      'edad': edad,
    };
  }
}
