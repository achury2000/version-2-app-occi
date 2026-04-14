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

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  bool _looksLikeCliente(Map<String, dynamic>? data) {
    if (data == null) return false;

    return data.containsKey('id_usuario') ||
        data.containsKey('id_usuarios') ||
        data.containsKey('tipo_documento') ||
        data.containsKey('numero_documento') ||
        data.containsKey('telefono') ||
        data.containsKey('direccion') ||
        data.containsKey('ciudad') ||
        data.containsKey('pais');
  }

  Map<String, dynamic>? _extractClientePayload(dynamic response) {
    final map = _asMap(response);
    if (map == null) return null;

    if (_looksLikeCliente(map)) {
      return map;
    }

    for (final key in const ['cliente', 'data', 'perfil', 'result']) {
      final nested = _asMap(map[key]);
      if (_looksLikeCliente(nested)) {
        return nested;
      }
    }

    return null;
  }

  bool _responseIsSuccess(dynamic response) {
    final map = _asMap(response);
    if (map == null) return false;

    final success = map['success'];
    if (success is bool) {
      return success;
    }

    return _extractClientePayload(map) != null;
  }

  bool _isDuplicateClienteError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('409') ||
        message.contains('duplicate') ||
        message.contains('duplicado') ||
        message.contains('ya existe') ||
        message.contains('already exists') ||
        message.contains('unique');
  }

  bool _isCodigoPostalColumnError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('codigo_postal') &&
        (message.contains('does not exist') ||
            message.contains('no existe') ||
            message.contains('column c.codigo_postal'));
  }

  /// Obtener cliente por ID de usuario.
  ///
  /// Usa el ID del usuario autenticado para obtener su perfil de cliente.
  Future<Cliente?> getClienteByUsuarioId(int idUsuario) async {
    try {
      print('🌐 [ClienteService] Obteniendo cliente para usuario: $idUsuario');
      final response = await _api.get('/clientes/usuario/$idUsuario');

      final clienteData = _extractClientePayload(response);
      if (clienteData != null && _responseIsSuccess(response)) {
        print('✅ [ClienteService] Cliente encontrado');
        return Cliente.fromJson(clienteData);
      }

      final responseMap = _asMap(response);
      final backendMessage = responseMap?['message']?.toString().toLowerCase();
      if (backendMessage != null &&
          (backendMessage.contains('no encontrado') ||
              backendMessage.contains('not found'))) {
        print(
            '⚠️ [ClienteService] Cliente no encontrado - perfil no completado');
        return null;
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
      // Fallback temporal: backend desalineado en columna opcional.
      // Se asume perfil no existente para no bloquear el flujo móvil.
      if (_isCodigoPostalColumnError(e)) {
        print(
            '⚠️ [ClienteService] Backend sin columna codigo_postal. Se asume perfil no encontrado.');
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
        throw Exception(
            '❌ No estás autenticado. Debes iniciar sesión para completar tu perfil.');
      }
      print(
          '🔐 [ClienteService] Token verificado: ${token.substring(0, 20)}...');
      print('📬 [ClienteService] Enviando POST a /clientes...');

      final response = await _api.post('/clientes', jsonData);

      print('📥 [ClienteService] Status: ${response['success']}');
      print('📥 [ClienteService] Respuesta completa: $response');

      if (_responseIsSuccess(response)) {
        print('✅ [ClienteService] Perfil de cliente creado exitosamente');

        final clienteData = _extractClientePayload(response);
        if (clienteData != null) {
          return Cliente.fromJson(clienteData);
        }

        final recargado = await getClienteByUsuarioId(cliente.idUsuario);
        if (recargado != null) {
          return recargado;
        }

        print(
            '⚠️ [ClienteService] Respuesta sin payload de cliente recargable');
        throw Exception('Respuesta inválida: sin datos de cliente');
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
        throw Exception(
            '❌ No estás autenticado. Debes iniciar sesión para actualizar tu perfil.');
      }
      print(
          '🔐 [ClienteService] Token verificado: ${token.substring(0, 10)}...');

      final response = await _api.put('/clientes/$id', jsonData);

      print('📥 [ClienteService] Status: ${response['success']}');
      print('📥 [ClienteService] Respuesta: $response');

      if (_responseIsSuccess(response)) {
        print('✅ [ClienteService] Cliente actualizado exitosamente');

        final clienteData = _extractClientePayload(response);
        if (clienteData != null) {
          return Cliente.fromJson(clienteData);
        }

        final recargado = await getClienteByUsuarioId(cliente.idUsuario);
        if (recargado != null) {
          return recargado;
        }

        print(
            '⚠️ [ClienteService] Respuesta sin payload de cliente recargable');
        throw Exception('Respuesta inválida: sin datos de cliente');
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

  /// Guarda el perfil del cliente garantizando el enlace con id_usuario.
  ///
  /// Si ya existe un registro para el usuario, actualiza ese registro.
  /// Si no existe, lo crea. Si el backend responde con duplicado por una
  /// carrera entre pantallas o datos desactualizados, reintenta como update.
  Future<Cliente> upsertClienteByUsuario(Cliente cliente) async {
    final existente = await getClienteByUsuarioId(cliente.idUsuario);

    if (existente?.id != null) {
      return updateCliente(
        existente!.id!,
        cliente.copyWith(
          id: existente.id,
          idUsuario: existente.idUsuario,
        ),
      );
    }

    try {
      return await createCliente(cliente);
    } catch (e) {
      if (_isDuplicateClienteError(e)) {
        print(
            '⚠️ [ClienteService] Duplicado detectado, reintentando como update');
        final recargado = await getClienteByUsuarioId(cliente.idUsuario);
        if (recargado?.id != null) {
          return updateCliente(
            recargado!.id!,
            cliente.copyWith(
              id: recargado.id,
              idUsuario: recargado.idUsuario,
            ),
          );
        }
      }
      rethrow;
    }
  }
}
