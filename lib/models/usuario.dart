class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? foto;
  final String telefono;
  final String pais;
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.foto,
    required this.telefono,
    required this.pais,
    required this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      foto: json['foto'],
      telefono: json['telefono'] ?? '',
      pais: json['pais'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'foto': foto,
      'telefono': telefono,
      'pais': pais,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
