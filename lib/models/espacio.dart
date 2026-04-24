/// Modelo de Espacio/Amenidad de una finca
/// Representa espacios o amenidades disponibles como: piscina, jacuzzi, sala de juegos, etc.

class Espacio {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono; // ej: pool, hot_tub, game_room
  final double? precio; // precio adicional si aplica
  final bool disponible;
  final DateTime? fechaCreacion;

  Espacio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.precio,
    required this.disponible,
    this.fechaCreacion,
  });

  /// Crear Espacio desde JSON
  factory Espacio.fromJson(Map<String, dynamic> json) {
    return Espacio(
      id: json['id'] ?? json['id_espacio'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      icono: json['icono'],
      precio: json['precio'] != null 
          ? double.tryParse(json['precio'].toString()) 
          : null,
      disponible: json['disponible'] ?? true,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_espacio': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'icono': icono,
      'precio': precio,
      'disponible': disponible,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Espacio(id: $id, nombre: $nombre)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Espacio &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
