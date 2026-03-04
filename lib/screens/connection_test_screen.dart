import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/connection_service.dart';
import '../config/environment.dart';

/// Pantalla para testear la conexión con el backend
/// Útil durante desarrollo para verificar que todo está conectado
class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  late ConnectionService _connectionService;
  late ApiService _apiService;
  String _report = 'Generando reporte...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectionService = ConnectionService();
    _apiService = ApiService();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _connectionService.generateConnectionReport();
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _report = 'Error generando reporte: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testEndpoint(String endpoint) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testeando endpoint...')),
    );

    try {
      final response = await _apiService.get(endpoint);
      if (mounted) {
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Respuesta Exitosa'),
            content: SingleChildScrollView(
              child: Text(
                response.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔗 Test de Conexión'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del entorno
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entorno y Configuración',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text('Entorno: ${AppEnvironment.currentEnvironment}'),
                    Text('URL Base: ${AppEnvironment.getBackendUrl()}'),
                    Text('Producción: ${AppEnvironment.isProduction()}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reporte
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reporte de Conexión',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              _report,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de test rápido
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Rápido de Endpoints',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.home),
                          label: const Text('GET /'),
                          onPressed: () => _testEndpoint('/'),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person),
                          label: const Text('GET /clientes'),
                          onPressed: () => _testEndpoint('clientes'),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.store),
                          label: const Text('GET /servicios'),
                          onPressed: () => _testEndpoint('servicios'),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.bookmark),
                          label: const Text('GET /reservas'),
                          onPressed: () => _testEndpoint('reservas'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón para cambiar URL
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cambiar URL del Servidor',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.link),
                      label: const Text('Usar localhost:3000'),
                      onPressed: () {
                        _apiService.setBaseUrl('http://localhost:3000/api');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL actualizada a localhost:3000'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
