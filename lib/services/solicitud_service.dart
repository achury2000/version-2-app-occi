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
      int? parseId(dynamic value) {
        if (value is int) return value;
        return int.tryParse(value?.toString() ?? '');
      }

      int? extractId(Map<String, dynamic> map) {
        return parseId(
          map['id_solicitud_personalizada'] ??
              map['id_solicitud'] ??
              map['id'] ??
              map['Id'],
        );
      }

      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final directId = extractId(data);
        if (directId != null) return directId;

        final solicitud = data['solicitud'];
        if (solicitud is Map<String, dynamic>) {
          final nestedId = extractId(solicitud);
          if (nestedId != null) return nestedId;
        }
        // Algunas respuestas envían el registro plano como lista u objeto único
        final raw = data['data'];
        if (raw is Map<String, dynamic>) {
          final idRaw = extractId(raw);
          if (idRaw != null) return idRaw;
        }
      }
    }
    return null;
  }
}
