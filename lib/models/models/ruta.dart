class Ruta {
  final int id;
  final String nombre;
  final String descripcion;
  final String ubicacion;
  final String? imagen;
  final double duracion; // en horas
  final double distancia; // en km
  final double precio;
  final int capacidad;
  final String dificultad; // fácil, moderado, difícil
  final List<String> incluye;
  final double rating;
  final int resenas;
  final bool disponible;

  Ruta({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.ubicacion,
    this.imagen,
    required this.duracion,
    required this.distancia,
    required this.precio,
    required this.capacidad,
    required this.dificultad,
    required this.incluye,
    required this.rating,
    required this.resenas,
    required this.disponible,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      imagen: json['imagen'],
      duracion: (json['duracion'] as num?)?.toDouble() ?? 0.0,
      distancia: (json['distancia'] as num?)?.toDouble() ?? 0.0,
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      capacidad: json['capacidad'] ?? 0,
      dificultad: json['dificultad'] ?? 'moderado',
      incluye: json['incluye'] != null ? List<String>.from(json['incluye']) : [],
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
      'duracion': duracion,
      'distancia': distancia,
      'precio': precio,
      'capacidad': capacidad,
      'dificultad': dificultad,
      'incluye': incluye,
      'rating': rating,
      'resenas': resenas,
      'disponible': disponible,
    };
  }
}
