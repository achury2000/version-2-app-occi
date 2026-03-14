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
      tipoDocumento: json['tipo_documento']?.toString(),
      numeroDocumento: json['numero_documento']?.toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      ciudad: json['ciudad']?.toString(),
      pais: json['pais']?.toString(),
      codigoPostal: json['codigo_postal']?.toString(),
      fechaNacimiento: json['fecha_nacimiento']?.toString(),
      genero: json['genero']?.toString(),
      nacionalidad: json['nacionalidad']?.toString(),
      preferencias: json['preferencias']?.toString(),
      notas: json['notas']?.toString(),
      newsletter: _parseBool(json['newsletter']),
      estado: _parseBool(json['estado'], defaultValue: true),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Helper para parsear booleanos desde JSON (pueden ser bool, int, string)
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return defaultValue;
  }

  /// Convierte a JSON para enviar al backend
  /// Siempre incluye los campos requeridos
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'id_usuario': idUsuario,
      'tipo_documento': tipoDocumento ?? '',
      'numero_documento': numeroDocumento ?? '',
      'telefono': telefono ?? '',
      'direccion': direccion ?? '',
      'ciudad': ciudad ?? '',
      'pais': pais ?? '',
      'codigo_postal': codigoPostal ?? '',
      'fecha_nacimiento': fechaNacimiento ?? '',
      'genero': genero ?? '',
      'nacionalidad': nacionalidad ?? '',
      'preferencias': preferencias ?? '',
      'notas': notas ?? '',
      'newsletter': newsletter ?? false,
      'estado': estado ?? true,
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
