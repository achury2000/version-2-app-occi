/// Modelo de Programación que representa una salida programada de una ruta.
///
/// Una programación es una fecha/hora específica en la que una ruta
/// estará disponible para reservar, con cupos limitados.
class Programacion {
  final int id;
  final int? idRuta;
  final String? nombreRuta;
  final DateTime? fechaSalida;
  final String? horaSalida;
  final int? cuposDisponibles;
  final int? cuposTotales;
  final double? precio;
  final String? estado;
  final String? guia;
  final String? observaciones;

  Programacion({
    required this.id,
    this.idRuta,
    this.nombreRuta,
    this.fechaSalida,
    this.horaSalida,
    this.cuposDisponibles,
    this.cuposTotales,
    this.precio,
    this.estado,
    this.guia,
    this.observaciones,
  });

  factory Programacion.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }
    return Programacion(
      id: json['id'] ?? json['id_programacion'] ?? 0,
      idRuta: json['id_ruta'],
      nombreRuta: json['nombre_ruta'] ?? json['ruta_nombre'],
      fechaSalida: json['fecha_salida'] != null
          ? DateTime.tryParse(json['fecha_salida'].toString())
          : null,
      horaSalida: json['hora_salida'],
      cuposDisponibles: json['cupos_disponibles'],
      cuposTotales: json['cupos_totales'] ?? json['cupos'],
      precio: parsePrice(json['precio']),
      estado: json['estado'],
      guia: json['guia'] ?? json['nombre_guia'],
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_ruta': idRuta,
      'fecha_salida': fechaSalida?.toIso8601String(),
      'hora_salida': horaSalida,
      'cupos_disponibles': cuposDisponibles,
      'cupos_totales': cuposTotales,
      'precio': precio,
      'estado': estado,
      'guia': guia,
      'observaciones': observaciones,
    };
  }

  /// Verifica si hay cupos disponibles
  bool get tieneCupos => cuposDisponibles != null && cuposDisponibles! > 0;

  /// Verifica si la programación está activa
  bool get estaActiva => estado?.toLowerCase() == 'activo';
}
