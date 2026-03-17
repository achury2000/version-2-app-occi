class ClientePerfilModel {
  final int? id;
  final int? idUsuario;
  final String nombre;
  final String apellido;
  final String tipoDocumento;
  final String numeroDocumento;
  final String telefono;
  final String direccion;
  final String ciudad;
  final String pais;
  final String? codigoPostal;
  final String? fechaNacimiento;
  final String? genero;
  final String? nacionalidad;
  final String? preferencias;
  final String? notas;
  final bool newsletter;
  final bool estado;

  const ClientePerfilModel({
    this.id,
    this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.telefono,
    required this.direccion,
    required this.ciudad,
    required this.pais,
    this.codigoPostal,
    this.fechaNacimiento,
    this.genero,
    this.nacionalidad,
    this.preferencias,
    this.notas,
    this.newsletter = false,
    this.estado = true,
  });

  factory ClientePerfilModel.empty() {
    return const ClientePerfilModel(
      tipoDocumento: '',
      nombre: '',
      apellido: '',
      numeroDocumento: '',
      telefono: '',
      direccion: '',
      ciudad: '',
      pais: '',
      codigoPostal: null,
      fechaNacimiento: null,
      genero: null,
      nacionalidad: null,
      preferencias: null,
      notas: null,
      newsletter: false,
      estado: true,
    );
  }

  factory ClientePerfilModel.fromJson(Map<String, dynamic> json) {
    return ClientePerfilModel(
      id: _toInt(json['id']),
      idUsuario: _toInt(json['id_usuario'] ?? json['id_usuarios']),
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      tipoDocumento: (json['tipo_documento'] ?? '').toString(),
      numeroDocumento: (json['numero_documento'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      direccion: (json['direccion'] ?? '').toString(),
      ciudad: (json['ciudad'] ?? '').toString(),
      pais: (json['pais'] ?? '').toString(),
      codigoPostal: _nullableText(json['codigo_postal']),
      fechaNacimiento: _nullableText(json['fecha_nacimiento']),
      genero: _nullableText(json['genero']),
      nacionalidad: _nullableText(json['nacionalidad']),
      preferencias: _nullableText(json['preferencias']),
      notas: _nullableText(json['notas']),
      newsletter: _toBool(json['newsletter']),
      estado: _toBool(json['estado'], defaultValue: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (idUsuario != null) 'id_usuario': idUsuario,
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'tipo_documento': tipoDocumento.trim(),
      'numero_documento': numeroDocumento.trim(),
      'telefono': telefono.trim(),
      'direccion': direccion.trim(),
      'ciudad': ciudad.trim(),
      'pais': pais.trim(),
      'codigo_postal':
          codigoPostal?.trim().isEmpty == true ? null : codigoPostal?.trim(),
      'fecha_nacimiento': fechaNacimiento?.trim().isEmpty == true
          ? null
          : fechaNacimiento?.trim(),
      'genero': genero?.trim().isEmpty == true ? null : genero?.trim(),
      'nacionalidad':
          nacionalidad?.trim().isEmpty == true ? null : nacionalidad?.trim(),
      'preferencias':
          preferencias?.trim().isEmpty == true ? null : preferencias?.trim(),
      'notas': notas?.trim().isEmpty == true ? null : notas?.trim(),
      'newsletter': newsletter,
      'estado': estado,
    };
  }

  ClientePerfilModel copyWith({
    int? id,
    int? idUsuario,
    String? nombre,
    String? apellido,
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
  }) {
    return ClientePerfilModel(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
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
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _toBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    final text = value.toString().toLowerCase().trim();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return defaultValue;
  }

  static String? _nullableText(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
