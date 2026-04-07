/// Modelo de Servicio
/// Representa un servicio adicional que se puede agregar a una reserva

class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  final bool estado;
  final DateTime? fechaCreacion;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl,
    required this.estado,
    this.fechaCreacion,
  });

  /// Crear Servicio desde JSON (API)
  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id_servicio'] ?? json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      imagenUrl: json['imagen_url']?.toString(),
      estado: json['estado'] ?? true,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
    );
  }

  /// Convertir Servicio a JSON (enviar a API)
  Map<String, dynamic> toJson() {
    return {
      'id_servicio': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  /// Crear copia del Servicio con cambios
  Servicio copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    bool? estado,
    DateTime? fechaCreacion,
  }) {
    return Servicio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() => 'Servicio(id: $id, nombre: $nombre, precio: $precio)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Servicio &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
