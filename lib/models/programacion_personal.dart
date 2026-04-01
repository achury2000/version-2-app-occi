/// Modelo de Programación Personal que representa una actividad personal del cliente.
///
/// Una programación personal es una actividad creada por el cliente para su
/// organización personal, con fecha, hora y descripción.
class ProgramacionPersonal {
  final int id;
  final int? idCliente;
  final String titulo;
  final String? descripcion;
  final DateTime? fechaProgramacion;
  final String? horaProgramacion;
  final bool? completada;
  final String? estado; // pendiente, completada, cancelada
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  ProgramacionPersonal({
    required this.id,
    this.idCliente,
    required this.titulo,
    this.descripcion,
    this.fechaProgramacion,
    this.horaProgramacion,
    this.completada,
    this.estado,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory ProgramacionPersonal.fromJson(Map<String, dynamic> json) {
    return ProgramacionPersonal(
      id: json['id'] ?? json['id_programacion_personal'] ?? 0,
      idCliente: json['id_cliente'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      fechaProgramacion: json['fecha_programacion'] != null
          ? DateTime.tryParse(json['fecha_programacion'].toString())
          : null,
      horaProgramacion: json['hora_programacion'],
      completada: json['completada'] ?? false,
      estado: json['estado'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.tryParse(json['fecha_actualizacion'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_programacion': fechaProgramacion?.toIso8601String(),
      'hora_programacion': horaProgramacion,
      'completada': completada,
      'estado': estado,
    };
  }

  /// Verifica si la programación está completada
  bool get estaCompletada => completada ?? false;

  /// Verifica si la programación está pendiente
  bool get estaPendiente => !(completada ?? false);

  /// Formatea la fecha y hora para mostrar
  String get fechaHoraFormato {
    if (fechaProgramacion == null) return 'Sin fecha';
    final fecha = '${fechaProgramacion!.day}/${fechaProgramacion!.month}/${fechaProgramacion!.year}';
    final hora = horaProgramacion ?? '00:00';
    return '$fecha $hora';
  }
}
