import 'api_service.dart';
import '../models/registro_auditoria.dart';

/// Servicio para gestionar registros de auditoría
class AuditoriaService {
  final ApiService _api = ApiService();

  static final AuditoriaService _instance = AuditoriaService._internal();
  factory AuditoriaService() => _instance;
  AuditoriaService._internal();

  /// Obtener registros de auditoría del cliente
  Future<List<RegistroAuditoria>> getRegistros({
    int? idCliente,
    String? entidad,
    String? accion,
    int? limite = 100,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (idCliente != null) params['id_cliente'] = idCliente;
      if (entidad != null) params['entidad'] = entidad;
      if (accion != null) params['accion'] = accion;
      if (limite != null) params['limite'] = limite;

      final response = await _api.get(
        '/auditoria',
        queryParameters: params,
      );

      if (response is List) {
        return response
            .map((json) => RegistroAuditoria.fromJson(json))
            .toList();
      }

      if (response is Map && response['data'] != null) {
        final list = response['data'] as List;
        return list
            .map((json) => RegistroAuditoria.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Registrar una acción en auditoría
  Future<void> registrar({
    required String accion,
    required String entidad,
    required int idEntidad,
    String? descripcion,
    String? cambiosAnteriores,
    String? cambiosNuevos,
  }) async {
    try {
      final body = <String, dynamic>{
        'accion': accion,
        'entidad': entidad,
        'id_entidad': idEntidad,
      };

      if (descripcion != null) body['descripcion'] = descripcion;
      if (cambiosAnteriores != null) body['cambios_anteriores'] = cambiosAnteriores;
      if (cambiosNuevos != null) body['cambios_nuevos'] = cambiosNuevos;

      await _api.post('/auditoria', body);
    } catch (e) {
      rethrow;
    }
  }
}
