import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Ejemplo práctico de cómo usar ApiService
/// Este archivo muestra los patrones más comunes para integrar la API

class ApiServiceExamples {
  
  // ==========================================
  // EJEMPLO 1: GET - Obtener datos
  // ==========================================
  static Future<void> exampleGet() async {
    final apiService = ApiService();
    
    try {
      // GET simple
      final clientes = await apiService.get('clientes');
      print('✅ Clientes obtenidos: ${clientes.length}');

      // GET con parámetros
      final fincas = await apiService.get(
        'fincas',
        queryParameters: {
          'limit': 10,
          'offset': 0,
          'filtro': 'activos',
        },
      );
      print('✅ Fincas: $fincas');
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  // ==========================================
  // EJEMPLO 2: POST - Crear datos
  // ==========================================
  static Future<void> examplePost() async {
    final apiService = ApiService();
    
    try {
      // POST simple - Login
      final loginResponse = await apiService.post('auth/login', {
        'email': 'usuario@example.com',
        'password': 'contraseña123',
      });
      
      final token = loginResponse['token'];
      print('✅ Login exitoso. Token: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error de login: $e');
    }
  }

  // ==========================================
  // EJEMPLO 3: POST - Crear cliente
  // ==========================================
  static Future<void> exampleCreateCliente() async {
    final apiService = ApiService();
    
    try {
      final nuevoCliente = await apiService.post('clientes', {
        'nombre': 'Juan Pérez',
        'email': 'juan@example.com',
        'telefono': '+34 612 345 678',
        'pais': 'España',
      });
      
      print('✅ Cliente creado: ${nuevoCliente['id']}');
    } catch (e) {
      print('❌ Error al crear cliente: $e');
    }
  }

  // ==========================================
  // EJEMPLO 4: PUT - Actualizar datos
  // ==========================================
  static Future<void> examplePut() async {
    final apiService = ApiService();
    
    try {
      final clienteActualizado = await apiService.put('clientes/123', {
        'nombre': 'Juan García Pérez',
        'email': 'juan.garcia@example.com',
        'telefono': '+34 612 999 888',
      });
      
      print('✅ Cliente actualizado: $clienteActualizado');
    } catch (e) {
      print('❌ Error al actualizar: $e');
    }
  }

  // ==========================================
  // EJEMPLO 5: DELETE - Eliminar datos
  // ==========================================
  static Future<void> exampleDelete() async {
    final apiService = ApiService();
    
    try {
      await apiService.delete('clientes/123');
      print('✅ Cliente eliminado');
    } catch (e) {
      print('❌ Error al eliminar: $e');
    }
  }

  // ==========================================
  // EJEMPLO 6: Manejo de errores
  // ==========================================
  static Future<void> exampleErrorHandling() async {
    final apiService = ApiService();
    
    try {
      final response = await apiService.get('clientes/999');
      print('✅ Datos: $response');
    } on Exception catch (e) {
      // Capturar errores específicos
      final errorMessage = e.toString();
      
      if (errorMessage.contains('404')) {
        print('⚠️ El recurso no existe');
      } else if (errorMessage.contains('timeout')) {
        print('⚠️ Conexión lenta');
      } else if (errorMessage.contains('401')) {
        print('⚠️ No autorizado');
      } else {
        print('❌ Error desconocido: $e');
      }
    }
  }

  // ==========================================
  // EJEMPLO 7: Verificar conexión
  // ==========================================
  static Future<void> exampleCheckConnection() async {
    final apiService = ApiService();
    
    final isConnected = await apiService.checkConnection();
    if (isConnected) {
      print('✅ Servidor online');
    } else {
      print('❌ Servidor offline');
    }
  }

  // ==========================================
  // EJEMPLO 8: Cambiar URL dinámicamente
  // ==========================================
  static Future<void> exampleChangeUrl() async {
    final apiService = ApiService();
    
    // Cambiar a otro servidor
    apiService.setBaseUrl('http://otro-servidor.com:3000/api');
    
    final isConnected = await apiService.checkConnection();
    print('Servidor alternativo: ${isConnected ? '✅' : '❌'}');
  }
}

// ==========================================
// EJEMPLO 9: Provider Pattern (Recomendado)
// ==========================================
class ClienteProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Map<String, dynamic>> clientes = [];
  bool isLoading = false;
  String? error;

  /// Obtener lista de clientes
  Future<void> fetchClientes() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('clientes');
      clientes = response is List ? List<Map<String, dynamic>>.from(response) : [];
      isLoading = false;
    } catch (e) {
      error = e.toString();
      isLoading = false;
    }
    notifyListeners();
  }

  /// Crear nuevo cliente
  Future<void> createCliente(Map<String, dynamic> data) async {
    try {
      final newCliente = await _apiService.post('clientes', data);
      clientes.add(newCliente);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  /// Eliminar cliente
  Future<void> deleteCliente(int id) async {
    try {
      await _apiService.delete('clientes/$id');
      clientes.removeWhere((c) => c['id'] == id);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

// ==========================================
// EJEMPLO 10: Integración en Widget
// ==========================================
class ClientesListWidget extends StatefulWidget {
  const ClientesListWidget({Key? key}) : super(key: key);

  @override
  State<ClientesListWidget> createState() => _ClientesListWidgetState();
}

class _ClientesListWidgetState extends State<ClientesListWidget> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> futureClientes;

  @override
  void initState() {
    super.initState();
    futureClientes = _apiService.get('clientes').then((data) => data as List<dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureClientes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay clientes'));
        }

        final clientes = snapshot.data!;
        return ListView.builder(
          itemCount: clientes.length,
          itemBuilder: (context, index) {
            final cliente = clientes[index];
            return ListTile(
              title: Text(cliente['nombre'] ?? 'Sin nombre'),
              subtitle: Text(cliente['email'] ?? 'Sin email'),
              leading: const Icon(Icons.person),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await _apiService.delete('clientes/${cliente['id']}');
                  setState(() {
                    futureClientes = _apiService.get('clientes').then((data) => data as List<dynamic>);
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// TIPS Y MEJORES PRÁCTICAS
// ==========================================
/*
1. SIEMPRE usa try-catch para las llamadas a API
2. SIEMPRE verifica la conexión antes de hacer requests
3. USA TypeSafety: parseando respuestas a modelos Dart
4. CREA modelos con json_serializable para serialización automática
5. USA Provider o Riverpod para gestión de estado
6. IMPLEMENTA caché local con Hive o SQLite
7. MANEJA timeouts apropiadamente
8. REGISTRA errores en desarrollo
9. AGRUPA endpoints en servicios temáticos
10. TEST la app con diferentes velocidades de conexión
*/
