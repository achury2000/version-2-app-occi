class Finca {
  final int id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final String? imagen;
  final double latitud;
  final double longitud;
  final double precioNoche;
  final int capacidad;
  final List<String> servicios;
  final double rating;
  final int resenas;
  final bool disponible;

  Finca({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    this.imagen,
    required this.latitud,
    required this.longitud,
    required this.precioNoche,
    required this.capacidad,
    required this.servicios,
    required this.rating,
    required this.resenas,
    required this.disponible,
  });

  factory Finca.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }
    return Finca(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      imagen: json['imagen'],
      latitud: (json['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitud'] as num?)?.toDouble() ?? 0.0,
      precioNoche: parsePrice(json['precioNoche']),
      capacidad: json['capacidad'] ?? 0,
      servicios: json['servicios'] != null
          ? List<String>.from(json['servicios'])
          : [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      resenas: json['resenas'] ?? 0,
      disponible: json['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'imagen': imagen,
      'latitud': latitud,
      'longitud': longitud,
      'precioNoche': precioNoche,
      'capacidad': capacidad,
      'servicios': servicios,
      'rating': rating,
      'resenas': resenas,
      'disponible': disponible,
    };
  }
}
