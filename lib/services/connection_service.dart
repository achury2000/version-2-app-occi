import 'package:dio/dio.dart';
import '../config/environment.dart';

/// Servicio para verificar y testear la conexión con el backend
class ConnectionService {
  final Dio _dio = Dio();

  /// Verifica si el servidor está activo
  Future<bool> isServerOnline(String baseUrl) async {
    try {
      final response = await _dio
          .get(
            baseUrl.replaceAll('/api', ''), // URL raíz sin /api
            options: Options(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Servidor offline: $e');
      return false;
    }
  }

  /// Obtiene la versión del servidor
  Future<Map<String, dynamic>?> getServerInfo(String baseUrl) async {
    try {
      final response = await _dio.get(
        baseUrl.replaceAll('/api', ''),
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.data;
    } catch (e) {
      print('⚠️ No se pudo obtener info del servidor: $e');
      return null;
    }
  }

  /// Testea todos los endpoints principales
  Future<Map<String, bool>> testAllEndpoints(String baseUrl) async {
    final results = <String, bool>{};
    final endpoints = [
      '/',
      '/auth',
      '/clientes',
      '/proveedores',
      '/servicios',
      '/reservas',
      '/dashboard',
    ];

    print('🧪 Testeando endpoints...');
    for (final endpoint in endpoints) {
      try {
        final response = await _dio
            .get(
              '$baseUrl$endpoint',
              options: Options(
                validateStatus: (status) =>
                    (status ?? 500) < 500, // Aceptar cualquier código
              ),
            )
            .timeout(const Duration(seconds: 5));

        results[endpoint] =
            response.statusCode == 200 || response.statusCode == 404;
        print('  ${(results[endpoint] ?? false) ? '✅' : '❌'} $endpoint');
      } catch (e) {
        results[endpoint] = false;
        print('  ❌ $endpoint - Error: $e');
      }
    }

    return results;
  }

  /// Testea autenticación
  Future<bool> testAuth(String baseUrl) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': 'test@example.com',
          'password': 'test123',
        },
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => (status ?? 500) < 500,
        ),
      );

      // Retorna true si existe el endpoint (aunque falle la autenticación)
      return response.statusCode != 404;
    } catch (e) {
      print('⚠️ Error testeando auth: $e');
      return false;
    }
  }

  /// Genera un reporte completo de conexión
  Future<String> generateConnectionReport() async {
    final baseUrl = AppEnvironment.getBackendUrl();
    final buffer = StringBuffer();

    buffer.writeln('╔═══════════════════════════════════════════════╗');
    buffer.writeln('║     REPORTE DE CONEXIÓN - OCCITOURS          ║');
    buffer.writeln('╚═══════════════════════════════════════════════╝');
    buffer.writeln('');

    // Info del entorno
    buffer.writeln(
        '📱 ENTORNO: ${AppEnvironment.currentEnvironment.toUpperCase()}');
    buffer.writeln('🌐 URL Base: $baseUrl');
    buffer.writeln('');

    // Test de servidor
    buffer.writeln('🔍 TEST DE SERVIDOR:');
    final isOnline = await isServerOnline(baseUrl);
    buffer.writeln('  ${isOnline ? '✅' : '❌'} Servidor online');

    if (isOnline) {
      buffer.writeln('');
      buffer.writeln('📊 INFO DEL SERVIDOR:');
      final info = await getServerInfo(baseUrl);
      if (info != null) {
        info.forEach((key, value) {
          buffer.writeln('  • $key: $value');
        });
      }
    }

    // Test de endpoints
    buffer.writeln('');
    buffer.writeln('🧪 TEST DE ENDPOINTS:');
    final endpointResults = await testAllEndpoints(baseUrl);

    final passed = endpointResults.values.where((v) => v).length;
    final total = endpointResults.length;

    endpointResults.forEach((endpoint, result) {
      buffer.writeln('  ${result ? '✅' : '❌'} $endpoint');
    });

    buffer.writeln('');
    buffer.writeln('📈 RESULTADO: $passed/$total endpoints disponibles');

    // Test de autenticación
    buffer.writeln('');
    buffer.writeln('🔐 TEST DE AUTENTICACIÓN:');
    final authAvailable = await testAuth(baseUrl);
    buffer
        .writeln('  ${authAvailable ? '✅' : '❌'} Endpoint de login disponible');

    buffer.writeln('');
    buffer.writeln('═══════════════════════════════════════════════');

    return buffer.toString();
  }
}
