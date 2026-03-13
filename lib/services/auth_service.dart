import 'api_service.dart';
import 'token_service.dart';
import '../models/usuario.dart';

/// Servicio de autenticación que conecta con el backend Occitours.
///
/// Endpoints usados:
/// - POST /api/auth/login
/// - POST /api/auth/register
/// - POST /api/auth/verify-email
/// - POST /api/auth/resend-verification-code
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
  /// Solo requiere correo y contraseña.
  /// Los datos personales (nombre, apellido, etc.) se capturan después
  /// en la pantalla "Completar Perfil" y se guardan en la tabla clientes.
  ///
  /// El backend asigna automáticamente el rol "Cliente" (id_roles: 3).
  ///
  /// IMPORTANTE: El backend NO retorna token en el registro.
  /// El usuario debe verificar su email primero antes de poder iniciar sesión.
  Future<Map<String, dynamic>> register({
    required String correo,
    required String contrasena,
  }) async {
    try {
      print('🌐 [AuthService] Preparando registro...');
      final body = <String, dynamic>{
        'correo': correo,
        'contrasena': contrasena,
      };

      print('🌐 [AuthService] Enviando POST a /auth/register');
      print('🌐 [AuthService] Body: ${body.keys.join(", ")}');

      final response = await _api.post('/auth/register', body);

      print('🌐 [AuthService] Respuesta recibida: $response');

      if (response != null && response['success'] == true) {
        // En desarrollo, el backend puede enviar el código en la respuesta
        final verificationCode = response['verification_code'];
        if (verificationCode != null) {
          print('🔑 [DEV] Código de verificación: $verificationCode');
        }

        print('✅ [AuthService] Registro exitoso - Código enviado al email');
        return {
          'success': true,
          'message': response['message'] ?? 'Usuario registrado exitosamente',
          'verification_code': verificationCode, // Para testing
        };
      }

      print('❌ [AuthService] Respuesta no exitosa: ${response?['message']}');
      throw Exception(response?['message'] ?? 'Error al registrar usuario');
    } catch (e) {
      print('❌ [AuthService] Excepción en register: $e');
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

  /// Verificar email con el código de verificación recibido.
  ///
  /// Envía el código de 6 dígitos al backend para verificar la cuenta.
  /// IMPORTANTE: Solo después de verificar el código se crea el usuario en la BD.
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String codigo,
  }) async {
    try {
      print('🌐 [AuthService] Verificando email: $email');
      print('🌐 [AuthService] Código: ${codigo.substring(0, 2)}****');

      final response = await _api.post('/auth/verificar-email', {
        'correo': email,
        'codigo': codigo,
      });

      print('🌐 [AuthService] Respuesta verificación: $response');

      if (response != null && response['success'] == true) {
        print('✅ [AuthService] Email verificado exitosamente');
        return {
          'success': true,
          'message': response['message'] ?? 'Email verificado correctamente',
        };
      }

      throw Exception(
          response?['message'] ?? 'Código de verificación inválido');
    } catch (e) {
      print('❌ [AuthService] Error en verificación: $e');
      rethrow;
    }
  }

  /// Reenviar el código de verificación al correo.
  ///
  /// Solicita al backend que genere y envíe un nuevo código de verificación.
  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      print('🌐 [AuthService] Reenviando código a: $email');

      final response = await _api.post('/auth/reenviar-verificacion', {
        'correo': email,
      });

      print('🌐 [AuthService] Respuesta reenvío: $response');

      if (response != null && response['success'] == true) {
        // En desarrollo, el backend puede enviar el código en la respuesta
        final verificationCode = response['verification_code'];
        if (verificationCode != null) {
          print('🔑 [DEV] Código de verificación: $verificationCode');
        }

        print('✅ [AuthService] Código reenviado exitosamente');
        return {
          'success': true,
          'message': response['message'] ?? 'Código reenviado correctamente',
          'verification_code': verificationCode, // Para testing
        };
      }

      throw Exception(response?['message'] ?? 'Error al reenviar el código');
    } catch (e) {
      print('❌ [AuthService] Error al reenviar: $e');
      rethrow;
    }
  }

  /// Solicitar recuperación de contraseña.
  ///
  /// Intenta distintos endpoints para compatibilidad con variaciones de backend.
  Future<Map<String, dynamic>> forgotPassword({
    required String correo,
  }) async {
    final payload = {'correo': correo};

    final endpoints = <String>[
      '/auth/forgot-password',
      '/auth/recuperar-contrasena',
      '/auth/olvide-contrasena',
    ];

    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        final response = await _api.post(endpoint, payload);

        if (response != null && response['success'] == true) {
          return {
            'success': true,
            'message': response['message'] ??
                'Se enviaron instrucciones de recuperación al correo.',
          };
        }

        throw Exception(
            response?['message'] ?? 'No se pudo procesar la solicitud');
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
      }
    }

    throw lastError ??
        Exception('No se pudo solicitar la recuperación de contraseña');
  }

  /// Restablecer contraseña usando token/código de recuperación.
  ///
  /// Soporta distintos nombres de campo y endpoints para compatibilidad.
  Future<Map<String, dynamic>> resetPassword({
    required String correo,
    required String token,
    required String nuevaContrasena,
  }) async {
    final payloads = <Map<String, dynamic>>[
      {
        'correo': correo,
        'token': token,
        'nuevaContrasena': nuevaContrasena,
      },
      {
        'correo': correo,
        'codigo': token,
        'nuevaContrasena': nuevaContrasena,
      },
      {
        'email': correo,
        'token': token,
        'password': nuevaContrasena,
      },
    ];

    final endpoints = <String>[
      '/auth/reset-password',
      '/auth/restablecer-contrasena',
      '/auth/confirm-reset-password',
    ];

    Exception? lastError;

    for (final endpoint in endpoints) {
      for (final payload in payloads) {
        try {
          final response = await _api.post(endpoint, payload);

          if (response != null && response['success'] == true) {
            return {
              'success': true,
              'message': response['message'] ??
                  'Contraseña actualizada correctamente.',
            };
          }

          final code = response?['code']?.toString();
          final message = response?['message']?.toString() ??
              'No se pudo restablecer la contraseña';

          if (code != null && code.isNotEmpty) {
            throw Exception('RESET_CODE:$code|$message');
          }

          throw Exception(message);
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
        }
      }
    }

    throw lastError ?? Exception('No se pudo restablecer la contraseña');
  }
}
