import 'api_service.dart';
import 'token_service.dart';
import '../models/usuario.dart';

/// Servicio de autenticación que conecta con el backend Occitours.
///
/// Endpoints usados:
/// - POST /api/auth/login
/// - POST /api/auth/register
/// - GET  /api/auth/profile
/// - PUT  /api/auth/cambiar-contrasena
class AuthService {
  final ApiService _api = ApiService();
  final TokenService _tokenService = TokenService();

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Iniciar sesión con correo y contraseña.
  ///
  /// Envía `correo` y `contrasena` al backend.
  /// Guarda el token JWT y datos del usuario en almacenamiento local.
  /// Retorna el [Usuario] autenticado o lanza excepción.
  Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await _api.post('/auth/login', {
        'correo': correo,
        'contrasena': contrasena,
      });

      if (response != null && response['success'] == true) {
        final token = response['token'] as String;
        final usuario = Usuario.fromJson(response['usuario']);

        // Guardar token y datos del usuario
        await _tokenService.saveToken(token);
        await _tokenService.saveUserData(
          userId: usuario.id,
          email: usuario.correo,
          rol: usuario.rol ?? 'Cliente',
        );

        return {
          'token': token,
          'usuario': usuario,
        };
      }

      throw Exception(response?['message'] ?? 'Error al iniciar sesión');
    } catch (e) {
      rethrow;
    }
  }

  /// Registrar un nuevo cliente.
  ///
  /// Campos requeridos: correo, contrasena, nombre, apellido.
  /// Campos opcionales: tipo_documento, numero_documento, telefono, direccion, fecha_nacimiento.
  /// El backend asigna automáticamente el rol "Cliente" (id_roles: 3).
  Future<Map<String, dynamic>> register({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    String? tipoDocumento,
    String? numeroDocumento,
    String? telefono,
    String? direccion,
    String? fechaNacimiento,
  }) async {
    try {
      final body = <String, dynamic>{
        'correo': correo,
        'contrasena': contrasena,
        'nombre': nombre,
        'apellido': apellido,
      };

      // Agregar campos opcionales solo si tienen valor
      if (tipoDocumento != null) body['tipo_documento'] = tipoDocumento;
      if (numeroDocumento != null) body['numero_documento'] = numeroDocumento;
      if (telefono != null) body['telefono'] = telefono;
      if (direccion != null) body['direccion'] = direccion;
      if (fechaNacimiento != null) body['fecha_nacimiento'] = fechaNacimiento;

      final response = await _api.post('/auth/register', body);

      if (response != null && response['success'] == true) {
        final token = response['token'] as String;
        final usuario = Usuario.fromJson(response['usuario']);

        // Guardar token y datos del usuario
        await _tokenService.saveToken(token);
        await _tokenService.saveUserData(
          userId: usuario.id,
          email: usuario.correo,
          rol: usuario.rol ?? 'Cliente',
        );

        return {
          'token': token,
          'usuario': usuario,
        };
      }

      throw Exception(response?['message'] ?? 'Error al registrar usuario');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener el perfil completo del usuario autenticado.
  ///
  /// Requiere token JWT (se envía automáticamente por el interceptor).
  Future<Usuario> getProfile() async {
    try {
      final response = await _api.get('/auth/profile');

      if (response != null && response['success'] == true) {
        return Usuario.fromJson(response['perfil']);
      }

      throw Exception(response?['message'] ?? 'Error al obtener perfil');
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar la contraseña del usuario autenticado.
  ///
  /// Requiere la contraseña actual y la nueva.
  Future<bool> cambiarContrasena({
    required String contrasenaActual,
    required String contrasenaNueva,
  }) async {
    try {
      final response = await _api.put('/auth/cambiar-contrasena', {
        'contrasenaActual': contrasenaActual,
        'contrasenaNueva': contrasenaNueva,
      });

      return response != null && response['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  /// Cerrar sesión: limpia el token y datos locales.
  Future<void> logout() async {
    await _tokenService.clearSession();
  }

  /// Verifica si hay una sesión activa (token almacenado).
  Future<bool> isLoggedIn() async {
    return _tokenService.hasToken();
  }

  /// Obtiene el token actual almacenado.
  Future<String?> getToken() async {
    return _tokenService.getToken();
  }
}
