import 'package:dio/dio.dart';
import '../models/servicio.dart';
import '../config/environment.dart';

/// Service para gestionar operaciones HTTP con Servicios
/// Conecta con el backend API usando Dio
class ServicioService {
  late String _baseUrl;
  late Dio _dio;

  ServicioService() {
    _baseUrl = '${AppEnvironment.getBackendUrl()}/servicios';
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
      ),
    );
  }

  /// Obtener todos los servicios disponibles
  /// GET /servicios/disponibles
  Future<List<Servicio>> obtenerServiciosDisponibles() async {
    try {
      final response = await _dio.get('/disponibles');

      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        List<dynamic> jsonData;

        if (raw is List) {
          jsonData = raw;
        } else if (raw is Map && raw['data'] is List) {
          jsonData = raw['data'] as List<dynamic>;
        } else {
          throw Exception('Formato de respuesta inválido en /servicios/disponibles');
        }

        return jsonData
            .map((s) => Servicio.fromJson(s as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Error ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout al conectar con servidor');
      } else if (e.type == DioExceptionType.unknown) {
        throw Exception('Error de conexión: ${e.message}');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Endpoint de servicios no encontrado');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Error del servidor al obtener servicios');
      } else {
        throw Exception('Error: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener servicios por tipo
  /// GET /servicios/tipo/:tipo
  Future<List<Servicio>> obtenerServiciosPorTipo(String tipo) async {
    try {
      final response = await _dio.get('/tipo/$tipo');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.map((s) => Servicio.fromJson(s as Map<String, dynamic>)).toList();
      } else {
        throw Exception(
          'Error al obtener servicios por tipo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener servicio por ID
  /// GET /servicios/:id
  Future<Servicio> obtenerServicioPorId(int id) async {
    try {
      final response = await _dio.get('/$id');

      if (response.statusCode == 200) {
        return Servicio.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Servicio no encontrado');
      } else {
        throw Exception(
          'Error al obtener servicio: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Servicio no encontrado');
      }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todos los servicios (sin filtro)
  /// GET /servicios/
  Future<List<Servicio>> obtenerTodosLosServicios() async {
    try {
      final response = await _dio.get('');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.map((s) => Servicio.fromJson(s as Map<String, dynamic>)).toList();
      } else {
        throw Exception(
          'Error al obtener servicios: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo servicio (solo admin)
  /// POST /servicios/
  Future<Servicio> crearServicio({
    required String nombre,
    required String descripcion,
    required double precio,
    String? imagenUrl,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'imagen_url': imagenUrl,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Servicio.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado para crear servicios');
      } else if (response.statusCode == 400) {
        throw Exception('Datos inválidos');
      } else {
        throw Exception('Error al crear servicio: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado para crear servicios');
      }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar servicio (solo admin)
  /// PUT /servicios/:id
  Future<Servicio> actualizarServicio({
    required int id,
    required String nombre,
    required String descripcion,
    required double precio,
    String? imagenUrl,
    required bool estado,
    required String token,
  }) async {
    try {
      final response = await _dio.put(
        '/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'precio': precio,
          'imagen_url': imagenUrl,
          'estado': estado,
        },
      );

      if (response.statusCode == 200) {
        return Servicio.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Servicio no encontrado');
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado para actualizar servicios');
      } else {
        throw Exception('Error al actualizar servicio: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Servicio no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw Exception('No autorizado');
      }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar servicio (solo admin)
  /// DELETE /servicios/:id
  Future<void> eliminarServicio({
    required int id,
    required String token,
  }) async {
    try {
      final response = await _dio.delete(
        '/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Servicio no encontrado');
        } else if (response.statusCode == 401) {
          throw Exception('No autorizado para eliminar servicios');
        } else {
          throw Exception('Error al eliminar servicio: ${response.statusCode}');
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Servicio no encontrado');
      } else if (e.response?.statusCode == 401) {
        throw Exception('No autorizado');
      }
      throw Exception('Error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }
}
