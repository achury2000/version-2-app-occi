import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  // Singleton
  static final ApiService _instance = ApiService._internal();
  
  // Instancia de Dio para requests
  late Dio _dio;
  
  // Base URL del backend
  late String _baseUrl;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _baseUrl = apiBaseUrl;
    _initializeDio();
  }

  /// Inicializa Dio con configuración predeterminada
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
    print('🔗 URL base actualizada a: $newBaseUrl');
  }

  /// GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'GET', endpoint);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'POST', endpoint);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'PUT', endpoint);
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e, 'DELETE', endpoint);
    }
  }

  /// Manejo centralizado de errores
  dynamic _handleError(DioException error, String method, String endpoint) {
    String message = 'Error en $method: $endpoint';

    if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Timeout: No se puede conectar al servidor';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Timeout: El servidor tardó demasiado en responder';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Error de conexión: Verifica tu conexión a internet';
    } else if (error.response != null) {
      message = 'Error ${error.response?.statusCode}: ${error.response?.statusMessage}';
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
