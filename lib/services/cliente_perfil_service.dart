import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../models/cliente_perfil_model.dart';

class ClientePerfilHttpException implements Exception {
  final int statusCode;
  final String message;

  ClientePerfilHttpException(this.statusCode, this.message);

  @override
  String toString() => 'ClientePerfilHttpException($statusCode): $message';
}

class ClientePerfilService {
  final http.Client _httpClient;
  final String _baseUrl;

  ClientePerfilService({http.Client? httpClient, String? baseUrl})
      : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? AppEnvironment.getBackendUrl();

  Future<ClientePerfilModel?> obtenerPerfil({
    required int idUsuario,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/clientes/usuario/$idUsuario');

    final response = await _httpClient.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 404) {
      return null;
    }

    final bodyMap = _decodeBody(response.body);

    if (_isCodigoPostalColumnError(response.statusCode, bodyMap)) {
      return null;
    }

    if (response.statusCode == 200) {
      final payload = _extractPerfilPayload(bodyMap);
      if (payload == null) {
        throw ClientePerfilHttpException(
          500,
          'Respuesta inválida del servidor: perfil no encontrado en payload',
        );
      }
      return ClientePerfilModel.fromJson(payload);
    }

    throw ClientePerfilHttpException(
      response.statusCode,
      _extractMessage(bodyMap, fallback: 'No se pudo obtener el perfil.'),
    );
  }

  bool _isCodigoPostalColumnError(int statusCode, Map<String, dynamic>? body) {
    if (statusCode != 500 || body == null) return false;

    final message =
        '${body['message'] ?? ''} ${body['error'] ?? ''} ${body['details'] ?? ''}'
            .toLowerCase();

    return message.contains('codigo_postal') &&
        (message.contains('does not exist') ||
            message.contains('no existe') ||
            message.contains('column c.codigo_postal'));
  }

  Future<ClientePerfilModel> guardarMiPerfil({
    required ClientePerfilModel perfil,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/clientes/mi-perfil');

    final response = await _httpClient.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(perfil.toJson()),
    );

    final bodyMap = _decodeBody(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final payload = _extractPerfilPayload(bodyMap);
      if (payload != null) {
        return ClientePerfilModel.fromJson(payload);
      }
      return perfil;
    }

    throw ClientePerfilHttpException(
      response.statusCode,
      _extractMessage(bodyMap, fallback: 'No se pudo guardar el perfil.'),
    );
  }

  Map<String, dynamic>? _extractPerfilPayload(Map<String, dynamic>? body) {
    if (body == null) return null;

    if (_looksLikePerfil(body)) {
      return body;
    }

    for (final key in const ['cliente', 'data', 'perfil', 'result']) {
      final nested = body[key];
      if (nested is Map) {
        final nestedMap = Map<String, dynamic>.from(nested);
        if (_looksLikePerfil(nestedMap)) {
          return nestedMap;
        }
      }
    }

    return null;
  }

  bool _looksLikePerfil(Map<String, dynamic> data) {
    if (data.containsKey('nombre') || data.containsKey('apellido')) {
      return true;
    }

    return data.containsKey('tipo_documento') ||
        data.containsKey('numero_documento') ||
        data.containsKey('telefono') ||
        data.containsKey('direccion') ||
        data.containsKey('ciudad') ||
        data.containsKey('pais') ||
        data.containsKey('id_usuario');
  }

  Map<String, dynamic>? _decodeBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractMessage(Map<String, dynamic>? body,
      {required String fallback}) {
    if (body == null) return fallback;
    final value = body['message'] ?? body['error'];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
