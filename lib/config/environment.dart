/// Configuración de entornos para la aplicación Occitours
///
/// Esta clase permite cambiar entre diferentes entornos (desarrollo, testing, producción)
/// y facilita la conexión con diferentes servidores backend

import 'package:flutter/foundation.dart' show kIsWeb;

class AppEnvironment {
  static const String development = 'development';
  static const String testing = 'testing';
  static const String production = 'production';

  // Entorno actual (cambiar según sea necesario)
  static const String currentEnvironment = development;

  // URLs del backend para cada entorno
  static const Map<String, String> backendUrls = {
    development: 'http://10.0.2.2:3000/api', // Emulador Android
    testing: 'http://localhost:3000/api', // Testing local / Web
    production: 'https://api.occitours.com/api', // Producción
  };

  /// Obtiene la URL base según el entorno actual y la plataforma
  static String getBackendUrl() {
    // Si está en web, usar localhost en lugar de 10.0.2.2
    if (kIsWeb && currentEnvironment == development) {
      return 'http://localhost:3000/api';
    }
    return backendUrls[currentEnvironment] ?? backendUrls[development]!;
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
