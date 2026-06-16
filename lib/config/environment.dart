/// Configuración de entornos para la aplicación Occitours
///
/// Esta clase permite cambiar entre diferentes entornos (desarrollo, testing, producción)
/// y facilita la conexión con diferentes servidores backend
///
/// **Importante:** En Android nativo, `localhost` es el propio teléfono/emulador, no tu PC.
/// - Emulador Android → por defecto `http://10.0.2.2:3000/api`
/// - Teléfono físico → usa `flutter run --dart-define=BACKEND_BASE_URL=http://192.168.x.x:3000`
/// - Web (Chrome) → `http://localhost:3000/api`

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class AppEnvironment {
  static const String development = 'development';
  static const String testing = 'testing';
  static const String production = 'production';

  // ⚠️ PRODUCCIÓN: cambia a 'development' para desarrollo local
  static const String currentEnvironment = production;

  // 🔗 URL del backend desplegado en Vercel
  static const String vercelUrl = 'https://backocci-s.vercel.app';

  static const Map<String, String> backendUrls = {
    development: 'http://10.0.2.2:3000/api',
    testing: 'http://localhost:3000/api',
    production: '$vercelUrl/api',
  };

  /// Override: `flutter run --dart-define=BACKEND_BASE_URL=http://192.168.1.10:3000`
  static String getBackendUrl() {
    const override = String.fromEnvironment('BACKEND_BASE_URL');
    if (override.isNotEmpty) {
      final o = override.trim().replaceAll(RegExp(r'/+$'), '');
      return o.endsWith('/api') ? o : '$o/api';
    }

    if (kIsWeb) {
      if (currentEnvironment == development ||
          currentEnvironment == testing) {
        return 'http://localhost:3000/api';
      }
      return backendUrls[currentEnvironment] ?? backendUrls[production]!;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (currentEnvironment == production) {
        return backendUrls[production]!;
      }
      // `testing` apunta a localhost en el mapa; en Android eso no alcanza el backend del PC.
      return 'http://10.0.2.2:3000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (currentEnvironment == production) {
        return backendUrls[production]!;
      }
      return 'http://127.0.0.1:3000/api';
    }

    // Windows, Linux, macOS (Flutter desktop)
    if (currentEnvironment == development ||
        currentEnvironment == testing) {
      return 'http://127.0.0.1:3000/api';
    }
    return backendUrls[currentEnvironment] ?? backendUrls[production]!;
  }

  /// Obtiene el endpoint completo
  static String getEndpoint(String path) {
    return '${getBackendUrl()}/$path';
  }

  /// Verifica si estamos en producción
  static bool isProduction() {
    return currentEnvironment == production;
  }

  /// Verifica si estamos en desarrollo
  static bool isDevelopment() {
    return currentEnvironment == development;
  }

  /// Logs solo en desarrollo
  static void log(String message) {
    if (isDevelopment()) {
      print('📱 [APP] $message');
    }
  }

  /// Logs de API solo en desarrollo
  static void logApi(String method, String endpoint,
      {dynamic request, dynamic response}) {
    if (isDevelopment()) {
      print('🌐 [$method] $endpoint');
      if (request != null) print('   Request: $request');
      if (response != null) print('   Response: $response');
    }
  }
}
