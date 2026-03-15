import 'api_service.dart';
import 'token_service.dart';
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
      print('    ID Usuario: ${cliente.idUsuario}');
      
      final jsonData = cliente.toJson();
      print('📤 [ClienteService] JSON enviado: $jsonData');
      
      // Verificar que hay un token válido para autenticación
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        print('❌ [ClienteService] NO HAY TOKEN - Usuario no está autenticado!');
        throw Exception('❌ No estás autenticado. Debes iniciar sesión para completar tu perfil.');
      }
      print('🔐 [ClienteService] Token verificado: ${token.substring(0, 20)}...');
      print('📬 [ClienteService] Enviando POST a /clientes...');
      
      final response = await _api.post('/clientes', jsonData);

      print('📥 [ClienteService] Status: ${response['success']}');
      print('📥 [ClienteService] Respuesta completa: $response');
      
      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Perfil de cliente creado exitosamente');
        
        // Verificar que la respuesta tiene el cliente
        if (response['cliente'] == null) {
          print('⚠️ [ClienteService] Respuesta sin campo cliente');
          throw Exception('Respuesta inválida: sin datos de cliente');
        }
        
        return Cliente.fromJson(response['cliente']);
      }

      // La respuesta no fue exitosa
      if (response == null) {
        throw Exception('No hay respuesta del servidor');
      }
      
      final errorMsg = response['message'] ?? 
                      response['error'] ?? 
                      response['errors'] ??
                      'Error desconocido al crear cliente';
      
      print('⚠️ [ClienteService] Error en respuesta: $errorMsg');
      
      // Si es error de rol/permisos, agregar instrucciones útiles
      if (errorMsg.toString().contains('Acceso denegado') ||
          errorMsg.toString().contains('No tienes permisos') ||
          errorMsg.toString().contains('rol') ||
          errorMsg.toString().contains('Cliente')) {
        final mensajeCompleto = '''
$errorMsg

🔧 SOLUCIÓN:
El servidor está rechazando porque tu usuario no tiene el rol "Cliente" asignado.

Intenta estos pasos:
1️⃣ Cierra la app (Logout)
2️⃣ Vuelve a iniciar sesión (Login)
3️⃣ Intenta guardar tu perfil nuevamente

Si el error persiste, es un problema del backend que necesita ser arreglado por el equipo de desarrollo.
''';
        throw Exception(mensajeCompleto);
      }
      
      throw Exception(errorMsg.toString());
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
      print('    ID Usuario: ${cliente.idUsuario}');
      
      final jsonData = cliente.toJson();
      print('📤 [ClienteService] JSON enviado: $jsonData');
      
      // Verificar que hay un token válido para autenticación
      final token = await TokenService().getToken();
      if (token == null || token.isEmpty) {
        print('❌ [ClienteService] NO HAY TOKEN - Usuario no está autenticado!');
        throw Exception('❌ No estás autenticado. Debes iniciar sesión para actualizar tu perfil.');
      }
      print('🔐 [ClienteService] Token verificado: ${token.substring(0, 10)}...');
      
      final response = await _api.put('/clientes/$id', jsonData);

      print('📥 [ClienteService] Status: ${response['success']}');
      print('📥 [ClienteService] Respuesta: $response');
      
      if (response != null && response['success'] == true) {
        print('✅ [ClienteService] Cliente actualizado exitosamente');
        
        // Verificar que la respuesta tiene el cliente
        if (response['cliente'] == null) {
          print('⚠️ [ClienteService] Respuesta sin campo cliente');
          throw Exception('Respuesta inválida: sin datos de cliente');
        }
        
        return Cliente.fromJson(response['cliente']);
      }

      // La respuesta no fue exitosa
      if (response == null) {
        throw Exception('No hay respuesta del servidor');
      }
      
      final errorMsg = response['message'] ?? 
                      response['error'] ?? 
                      response['errors'] ??
                      'Error desconocido al actualizar cliente';
      
      print('⚠️ [ClienteService] Error en respuesta: $errorMsg');
      
      // Si es error de rol/permisos, agregar instrucciones útiles
      if (errorMsg.toString().contains('Acceso denegado') ||
          errorMsg.toString().contains('No tienes permisos') ||
          errorMsg.toString().contains('rol') ||
          errorMsg.toString().contains('Cliente')) {
        final mensajeCompleto = '''
$errorMsg

🔧 SOLUCIÓN:
El servidor está rechazando porque tu usuario no tiene el rol "Cliente" asignado.

Intenta estos pasos:
1️⃣ Cierra la app (Logout)
2️⃣ Vuelve a iniciar sesión (Login)
3️⃣ Intenta guardar tu perfil nuevamente

Si el error persiste, es un problema del backend que necesita ser arreglado por el equipo de desarrollo.
''';
        throw Exception(mensajeCompleto);
      }
      
      throw Exception(errorMsg.toString());
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
