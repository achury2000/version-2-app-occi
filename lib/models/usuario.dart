/// Modelo de Usuario que coincide con la respuesta del backend Occitours.
///
/// El backend devuelve en login/register:
/// ```json
/// { "id": 1, "correo": "...", "nombre": "...", "apellido": "...",
///   "rol": "Cliente", "tipo_usuario": "cliente" }
/// ```
///
/// El perfil completo incluye campos adicionales como tipo_documento,
/// numero_documento, telefono, direccion, fecha_nacimiento, etc.
class Usuario {
  final int id;
  final String correo;
  final String nombre;
  final String apellido;
  final String? rol;
  final String? tipoUsuario;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? telefono;
  final String? direccion;
  final String? fechaNacimiento;
  final bool? estado;
  final String? foto;
  final DateTime? createdAt;

  Usuario({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    this.rol,
    this.tipoUsuario,
    this.tipoDocumento,
    this.numeroDocumento,
    this.telefono,
    this.direccion,
    this.fechaNacimiento,
    this.estado,
    this.foto,
    this.createdAt,
  });

  /// Parsea desde la respuesta JSON del backend (login/register)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? json['id_usuarios'] ?? 0,
      correo: json['correo'] ?? json['email'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      rol: json['rol'] ?? json['rol_nombre'],
      tipoUsuario: json['tipo_usuario'],
      tipoDocumento: json['tipo_documento'],
      numeroDocumento: json['numero_documento'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaNacimiento: json['fecha_nacimiento'],
      estado: json['estado'],
      foto: json['foto'],
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '')
          : null,
    );
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correo': correo,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'tipo_usuario': tipoUsuario,
      'tipo_documento': tipoDocumento,
      'numero_documento': numeroDocumento,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_nacimiento': fechaNacimiento,
      'foto': foto,
    };
  }

  /// Nombre completo del usuario
  String get nombreCompleto => '$nombre $apellido';

  /// Copia con modificaciones
  Usuario copyWith({
    int? id,
    String? correo,
    String? nombre,
    String? apellido,
    String? rol,
    String? tipoUsuario,
    String? tipoDocumento,
    String? numeroDocumento,
    String? telefono,
    String? direccion,
    String? fechaNacimiento,
    bool? estado,
    String? foto,
  }) {
    return Usuario(
      id: id ?? this.id,
      correo: correo ?? this.correo,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      estado: estado ?? this.estado,
      foto: foto ?? this.foto,
    );
  }
}
