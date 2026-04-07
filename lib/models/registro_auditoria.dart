import 'package:intl/intl.dart';

/// Modelo de registro de auditoría
class RegistroAuditoria {
  final int id;
  final int? idUsuario;
  final String accion;
  final String entidad; // "Reserva", "ProgramacionPersonal", etc.
  final int? idEntidad;
  final DateTime fecha;
  final String? descripcion;
  final String? cambiosAnteriores;
  final String? cambiosNuevos;
  final String? ipCliente;
  final String? estado; // "exitoso", "fallido"

  RegistroAuditoria({
    required this.id,
    this.idUsuario,
    required this.accion,
    required this.entidad,
    this.idEntidad,
    required this.fecha,
    this.descripcion,
    this.cambiosAnteriores,
    this.cambiosNuevos,
    this.ipCliente,
    this.estado,
  });

  /// Resumen legible del evento
  String get resumen {
    final accionFormatada = accion
        .replaceFirst(accion[0], accion[0].toUpperCase())
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
    return '$accionFormatada $entidad #$idEntidad';
  }

  /// Fecha formateada
  String get fechaFormato {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(fecha);
  }

  factory RegistroAuditoria.fromJson(Map<String, dynamic> json) {
    return RegistroAuditoria(
      id: json['id'] ?? 0,
      idUsuario: json['id_usuario'],
      accion: json['accion'] ?? '',
      entidad: json['entidad'] ?? '',
      idEntidad: json['id_entidad'],
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      descripcion: json['descripcion'],
      cambiosAnteriores: json['cambios_anteriores'],
      cambiosNuevos: json['cambios_nuevos'],
      ipCliente: json['ip_cliente'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'accion': accion,
      'entidad': entidad,
      'id_entidad': idEntidad,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'cambios_anteriores': cambiosAnteriores,
      'cambios_nuevos': cambiosNuevos,
      'ip_cliente': ipCliente,
      'estado': estado,
    };
  }
}
