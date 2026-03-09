/// Modelo de Cliente para datos adicionales del usuario.
///
/// La tabla clientes almacena información detallada que complementa
/// los datos básicos de la tabla usuarios.
///
/// Relación: usuarios.id -> clientes.id_usuario
class Cliente {
  final int? id;
  final int idUsuario;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? telefono;
  final String? direccion;
  final String? ciudad;
  final String? pais;
  final String? codigoPostal;
  final String? fechaNacimiento;
  final String? genero;
  final String? nacionalidad;
  final String? preferencias;
  final String? notas;
  final bool? newsletter;
  final bool? estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cliente({
    this.id,
    required this.idUsuario,
    this.tipoDocumento,
    this.numeroDocumento,
    this.telefono,
    this.direccion,
    this.ciudad,
    this.pais,
    this.codigoPostal,
    this.fechaNacimiento,
    this.genero,
    this.nacionalidad,
    this.preferencias,
    this.notas,
    this.newsletter,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  /// Parsea desde la respuesta JSON del backend
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? json['id_clientes'],
      idUsuario: json['id_usuario'] ?? json['id_usuarios'] ?? 0,
      tipoDocumento: json['tipo_documento'],
      numeroDocumento: json['numero_documento'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      ciudad: json['ciudad'],
      pais: json['pais'],
      codigoPostal: json['codigo_postal'],
      fechaNacimiento: json['fecha_nacimiento'],
      genero: json['genero'],
      nacionalidad: json['nacionalidad'],
      preferencias: json['preferencias'],
      notas: json['notas'],
      newsletter: json['newsletter'],
      estado: json['estado'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_usuario': idUsuario,
      if (tipoDocumento != null) 'tipo_documento': tipoDocumento,
      if (numeroDocumento != null) 'numero_documento': numeroDocumento,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      if (ciudad != null) 'ciudad': ciudad,
      if (pais != null) 'pais': pais,
      if (codigoPostal != null) 'codigo_postal': codigoPostal,
      if (fechaNacimiento != null) 'fecha_nacimiento': fechaNacimiento,
      if (genero != null) 'genero': genero,
      if (nacionalidad != null) 'nacionalidad': nacionalidad,
      if (preferencias != null) 'preferencias': preferencias,
      if (notas != null) 'notas': notas,
      if (newsletter != null) 'newsletter': newsletter,
      if (estado != null) 'estado': estado,
    };
  }

  /// Copia con modificaciones
  Cliente copyWith({
    int? id,
    int? idUsuario,
    String? tipoDocumento,
    String? numeroDocumento,
    String? telefono,
    String? direccion,
    String? ciudad,
    String? pais,
    String? codigoPostal,
    String? fechaNacimiento,
    String? genero,
    String? nacionalidad,
    String? preferencias,
    String? notas,
    bool? newsletter,
    bool? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      pais: pais ?? this.pais,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      genero: genero ?? this.genero,
      nacionalidad: nacionalidad ?? this.nacionalidad,
      preferencias: preferencias ?? this.preferencias,
      notas: notas ?? this.notas,
      newsletter: newsletter ?? this.newsletter,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si el perfil está completo
  bool get isPerfilCompleto {
    return tipoDocumento != null &&
        numeroDocumento != null &&
        direccion != null &&
        ciudad != null &&
        pais != null;
  }

  @override
  String toString() {
    return 'Cliente(id: $id, idUsuario: $idUsuario, pais: $pais, ciudad: $ciudad)';
  }
}
