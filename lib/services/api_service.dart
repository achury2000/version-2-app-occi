import 'package:dio/dio.dart';
import '../config/environment.dart';
import 'token_service.dart';

class ApiService {
  // Singleton
  static final ApiService _instance = ApiService._internal();

  // Instancia de Dio para requests
  late Dio _dio;

  // Base URL del backend (detecta automáticamente web vs emulador)
  late String _baseUrl;

  // Servicio de token
  final TokenService _tokenService = TokenService();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _baseUrl = AppEnvironment.getBackendUrl();
    print('🌐 [ApiService] Inicializado con baseURL: $_baseUrl');
    _initializeDio();
  }

  String _normalizeEndpoint(String endpoint) {
    if (endpoint.isEmpty) return '/';
    return endpoint.startsWith('/') ? endpoint : '/$endpoint';
  }

  /// Inicializa Dio con configuración predeterminada e interceptor JWT
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Interceptor JWT: agrega el token automáticamente a cada request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print(
                '🔐 [ApiService] Token incluido en header: ${token.substring(0, 20)}...');
          } else {
            print('⚠️ [ApiService] ¡SIN TOKEN EN HEADER!');
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Si el servidor devuelve 401, el token expiró
          if (error.response?.statusCode == 401) {
            print('❌ [ApiService] Error 401: Token expirado o inválido');
            _tokenService.clearSession();
          }
          return handler.next(error);
        },
      ),
    );

    // Agregar interceptor para logs en desarrollo
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// Cambia la URL base del servidor (útil para testing)
  void setBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _dio.options.baseUrl = newBaseUrl;
    print('URL base actualizada a: $newBaseUrl');
  }

  /// GET request
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final response = await _dio.get(
        normalizedEndpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'GET', _normalizeEndpoint(endpoint));
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final response = await _dio.post(
        normalizedEndpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'POST', _normalizeEndpoint(endpoint));
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final response = await _dio.put(
        normalizedEndpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'PUT', _normalizeEndpoint(endpoint));
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final response = await _dio.delete(
        normalizedEndpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'DELETE', _normalizeEndpoint(endpoint));
    }
  }

  /// Manejo centralizado de errores
  dynamic _handleError(DioException error, String method, String endpoint) {
    String message = 'Error en $method: $endpoint';

    print('⚠️ [ApiService] DioException tipo: ${error.type}');
    print('⚠️ [ApiService] Status Code: ${error.response?.statusCode}');
    print('⚠️ [ApiService] Response Data: ${error.response?.data}');

    // Manejar errores de autenticación
    if (error.response?.statusCode == 403) {
      print(
          '🔐 [ApiService] Error 403 - Acceso Denegado (Permisos insuficientes)');
      message =
          '❌ Acceso denegado: No tienes permisos para esta acción. Verifica que hayas iniciado sesión correctamente.';
    } else if (error.response?.statusCode == 401) {
      print(
          '🔐 [ApiService] Error 401 - No Autorizado (Token inválido/expirado)');
      message = '❌ Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Timeout: No se puede conectar al servidor';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Timeout: El servidor tardó demasiado en responder';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Error de conexión: Verifica tu conexión a internet';
    } else if (error.response != null) {
      // Intentar extraer el mensaje del JSON de respuesta
      final responseData = error.response?.data;
      print('⚠️ [ApiService] Response data type: ${responseData.runtimeType}');

      if (responseData != null && responseData is Map) {
        // Priorizar el campo 'message', luego 'error', luego el primer valor
        message = responseData['message'] ??
            responseData['error'] ??
            responseData['errors'] ??
            responseData['validations'] ??
            'Error ${error.response?.statusCode}: ${error.response?.statusMessage}';

        // Si validations es un mapa, intenta extraer el primer error
        if (responseData['validations'] is Map) {
          final validations = responseData['validations'] as Map;
          final firstError = validations.values.firstWhere(
            (v) => v != null,
            orElse: () => null,
          );
          if (firstError != null) {
            message = 'Validación: $firstError';
          }
        }
      } else {
        message =
            'Error ${error.response?.statusCode}: ${error.response?.statusMessage}';
      }
    }

    print('❌ $message');
    throw Exception(message);
  }

  /// Verifica la conexión con el servidor
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      print('⚠️ No se pudo conectar al servidor: $e');
      return false;
    }
  }

  /// HTTP request genérico (solo con Dio)
  Future<dynamic> getDio(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Error en GET: $e');
    }
  }

  /// POST request genérico (solo con Dio)
  Future<dynamic> postDio(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception('Error en POST: $e');
    }
  }
}
