import 'package:flutter/material.dart';
import '../services/cliente_service.dart';
import '../models/cliente.dart';

/// Provider para gestionar el perfil del cliente
class ClienteProvider extends ChangeNotifier {
  final ClienteService _clienteService = ClienteService();

  Cliente? _cliente;
  bool _isLoading = false;
  String? _error;
  bool _perfilCompleto = false;

  // Getters
  Cliente? get cliente => _cliente;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get perfilCompleto => _perfilCompleto;

  /// Obtener el perfil del cliente por ID de usuario
  Future<void> loadCliente(int idUsuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cliente = await _clienteService.getClienteByUsuarioId(idUsuario);
      _perfilCompleto = _cliente?.isPerfilCompleto ?? false;
      print(
          '✅ [ClienteProvider] Cliente cargado - Perfil completo: $_perfilCompleto');
    } catch (e) {
      _error = e.toString();
      print('❌ [ClienteProvider] Error al cargar cliente: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Crear o actualizar el perfil del cliente
  Future<bool> saveCliente(Cliente cliente, int idUsuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final clienteNormalizado = cliente.copyWith(
        id: _cliente?.id ?? cliente.id,
        idUsuario: idUsuario,
      );

      print(
          '🌐 [ClienteProvider] Guardando perfil cliente para usuario: $idUsuario');
      print('📋 [ClienteProvider] Payload normalizado:');
      print('   id: ${clienteNormalizado.id}');
      print('   idUsuario: ${clienteNormalizado.idUsuario}');
      print('   tipoDocumento: ${clienteNormalizado.tipoDocumento}');
      print('   numeroDocumento: ${clienteNormalizado.numeroDocumento}');

      final clienteGuardado =
          await _clienteService.upsertClienteByUsuario(clienteNormalizado);

      _cliente = clienteGuardado;
      _perfilCompleto = _cliente!.isPerfilCompleto;

      print(
          '✅ [ClienteProvider] Cliente guardado - Perfil completo: $_perfilCompleto');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Extraer el mensaje de error más legible
      String errorMsg = e.toString();

      // Si contiene información útil del backend, extraerla
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      if (errorMsg.contains('HttpException: ')) {
        errorMsg = errorMsg.replaceFirst('HttpException: ', '');
      }

      _error = errorMsg;
      print('❌ [ClienteProvider] Error al guardar cliente: $errorMsg');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verificar si el perfil está completo
  Future<bool> verificarPerfilCompleto(int idUsuario) async {
    try {
      _perfilCompleto = await _clienteService.hasPerfilCompleto(idUsuario);
      notifyListeners();
      return _perfilCompleto;
    } catch (e) {
      print('❌ [ClienteProvider] Error verificando perfil: $e');
      return false;
    }
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
