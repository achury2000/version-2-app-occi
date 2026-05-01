import 'api_service.dart';

class SolicitudService {
  final ApiService _api = ApiService();

  // Singleton
  static final SolicitudService _instance = SolicitudService._internal();
  factory SolicitudService() => _instance;
  SolicitudService._internal();

  /// Crear una solicitud personalizada.
  /// payload esperable:
  /// {
  ///   'id_ruta': 1,
  ///   'fecha_salida': 'YYYY-MM-DD',
  ///   'hora_salida': 'HH:MM',
  ///   'observaciones': '...'
  ///   'acompanantes': [{ 'nombre_completo': '...', 'numero_documento': '...' }]
  /// }
  Future<int?> crear(Map<String, dynamic> payload) async {
    final response = await _api.post('/solicitudes', payload);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      final id = data is Map<String, dynamic> ? data['id'] ?? data['id_solicitud'] : null;
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '');
    }
    return null;
  }
}
