/// Modelo de Reserva que representa una reserva de un cliente.
///
/// Una reserva puede incluir programaciones, fincas, servicios y acompañantes.
class Reserva {
  final int id;
  final int? idCliente;
  final String? nombreCliente;
  final String? apellidoCliente;
  final DateTime? fechaReserva;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? cantidadPersonas;
  final double? precioTotal;
  final String? estado;
  final String? observaciones;
  final List<dynamic>? programaciones;
  final List<dynamic>? fincas;
  final List<dynamic>? servicios;
  final List<dynamic>? acompanantes;

  Reserva({
    required this.id,
    this.idCliente,
    this.nombreCliente,
    this.apellidoCliente,
    this.fechaReserva,
    this.fechaInicio,
    this.fechaFin,
    this.cantidadPersonas,
    this.precioTotal,
    this.estado,
    this.observaciones,
    this.programaciones,
    this.fincas,
    this.servicios,
    this.acompanantes,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] ?? json['id_reserva'] ?? 0,
      idCliente: json['id_cliente'],
      nombreCliente: json['nombre_cliente'] ?? json['nombre'],
      apellidoCliente: json['apellido_cliente'] ?? json['apellido'],
      fechaReserva: json['fecha_reserva'] != null
          ? DateTime.tryParse(json['fecha_reserva'].toString())
          : null,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.tryParse(json['fecha_inicio'].toString())
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.tryParse(json['fecha_fin'].toString())
          : null,
      cantidadPersonas: json['cantidad_personas'],
      precioTotal: (json['precio_total'] as num?)?.toDouble(),
      estado: json['estado'],
      observaciones: json['observaciones'],
      programaciones: json['programaciones'],
      fincas: json['fincas'],
      servicios: json['servicios'],
      acompanantes: json['acompanantes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'cantidad_personas': cantidadPersonas,
      'observaciones': observaciones,
    };
  }

  /// Nombre completo del cliente
  String get clienteNombreCompleto =>
      '${nombreCliente ?? ''} ${apellidoCliente ?? ''}'.trim();

  /// Verifica si la reserva está activa
  bool get estaActiva =>
      estado?.toLowerCase() == 'activa' ||
      estado?.toLowerCase() == 'confirmada';

  /// Verifica si la reserva fue cancelada
  bool get estaCancelada => estado?.toLowerCase() == 'cancelada';
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
