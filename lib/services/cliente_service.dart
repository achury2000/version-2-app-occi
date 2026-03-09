import 'api_service.dart';
import '../models/cliente.dart';

/// Servicio de clientes que conecta con el backend Occitours.
///
/// Endpoints usados:
/// - GET    /api/clientes/:id         - Obtener cliente por ID
/// - GET    /api/clientes/usuario/:id - Obtener cliente por ID de usuario
/// - POST   /api/clientes             - Crear perfil de cliente
/// - PUT    /api/clientes/:id         - Actualizar perfil de cliente
/// - DELETE /api/clientes/:id         - Eliminar cliente
class ClienteService {
  final ApiService _api = ApiService();

  // Singleton
  static final ClienteService _instance = ClienteService._internal();
  factory ClienteService() => _instance;
  ClienteService._internal();

  /// Obtener cliente por ID de usuario.
  ///
  /// Usa el ID del usuario autenticado para obtener su perfil de cliente.
  Future<Cliente?> getClienteByUsuarioId(int idUsuario) async {
    try {
      print('🌐 [ClienteService] Obteniendo cliente para usuario: $idUsuario');
      final response = await _api.get('/clientes/usuario/$idUsuario');

      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Cliente encontrado');
        return Cliente.fromJson(response['cliente']);
      }

      // Si no existe el cliente, retornar null
      print('⚠️ [ClienteService] Cliente no encontrado - perfil no completado');
      return null;
    } catch (e) {
      print('❌ [ClienteService] Error al obtener cliente: $e');
      // No lanzar excepción si no existe, solo retornar null
      if (e.toString().contains('404') ||
          e.toString().contains('no encontrado')) {
        return null;
      }
      rethrow;
    }
  }

  /// Obtener cliente por ID de cliente.
  Future<Cliente> getClienteById(int id) async {
    try {
      print('🌐 [ClienteService] Obteniendo cliente con ID: $id');
      final response = await _api.get('/clientes/$id');

      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Cliente obtenido exitosamente');
        return Cliente.fromJson(response['cliente']);
      }

      throw Exception(response?['message'] ?? 'Error al obtener cliente');
    } catch (e) {
      print('❌ [ClienteService] Error: $e');
      rethrow;
    }
  }

  /// Crear perfil de cliente (completar perfil).
  ///
  /// Se ejecuta tras el registro cuando el usuario completa su perfil.
  Future<Cliente> createCliente(Cliente cliente) async {
    try {
      print('🌐 [ClienteService] Creando perfil de cliente...');
      final response = await _api.post('/clientes', cliente.toJson());

      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Perfil de cliente creado');
        return Cliente.fromJson(response['cliente']);
      }

      throw Exception(
          response?['message'] ?? 'Error al crear perfil de cliente');
    } catch (e) {
      print('❌ [ClienteService] Error al crear cliente: $e');
      rethrow;
    }
  }

  /// Actualizar perfil de cliente.
  ///
  /// Actualiza los datos del perfil del cliente.
  Future<Cliente> updateCliente(int id, Cliente cliente) async {
    try {
      print('🌐 [ClienteService] Actualizando cliente ID: $id');
      final response = await _api.put('/clientes/$id', cliente.toJson());

      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Cliente actualizado');
        return Cliente.fromJson(response['cliente']);
      }

      throw Exception(response?['message'] ?? 'Error al actualizar cliente');
    } catch (e) {
      print('❌ [ClienteService] Error al actualizar: $e');
      rethrow;
    }
  }

  /// Eliminar cliente.
  Future<bool> deleteCliente(int id) async {
    try {
      print('🌐 [ClienteService] Eliminando cliente ID: $id');
      final response = await _api.delete('/clientes/$id');

      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Cliente eliminado');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ [ClienteService] Error al eliminar: $e');
      rethrow;
    }
  }

  /// Verificar si el usuario tiene perfil de cliente completado.
  Future<bool> hasPerfilCompleto(int idUsuario) async {
    try {
      final cliente = await getClienteByUsuarioId(idUsuario);
      if (cliente == null) return false;
      return cliente.isPerfilCompleto;
    } catch (e) {
      print('❌ [ClienteService] Error verificando perfil: $e');
      return false;
    }
  }
}
