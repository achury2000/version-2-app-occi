import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/registro_auditoria.dart';
import '../../services/auditoria_service.dart';
import '../../providers/auth_provider.dart';

class AuditoriaScreen extends StatefulWidget {
  const AuditoriaScreen({Key? key}) : super(key: key);

  @override
  State<AuditoriaScreen> createState() => _AuditoriaScreenState();
}

class _AuditoriaScreenState extends State<AuditoriaScreen> {
  final _service = AuditoriaService();
  List<RegistroAuditoria> _registros = [];
  bool _cargando = true;
  String? _error;
  String _filtroEntidad = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    try {
      final auth = context.read<AuthProvider>();
      final idCliente = auth.usuario?.id;

      if (idCliente == null) {
        throw Exception('No hay cliente autenticado');
      }

      final registros = await _service.getRegistros(
        idCliente: idCliente,
        entidad: _filtroEntidad == 'Todos' ? null : _filtroEntidad,
      );

      setState(() {
        _registros = registros.reversed.toList(); // Más recientes primero
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar auditoría: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Auditoría'),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _cargando = true);
                          _cargarRegistros();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _registros.isEmpty
                  ? const Center(
                      child: Text('No hay eventos registrados'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Filtro
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  selected: _filtroEntidad == 'Todos',
                                  label: const Text('Todos'),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _filtroEntidad = 'Todos');
                                      _cargarRegistros();
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  selected: _filtroEntidad == 'Reserva',
                                  label: const Text('Reservas'),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _filtroEntidad = 'Reserva');
                                      _cargarRegistros();
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  selected:
                                      _filtroEntidad == 'ProgramacionPersonal',
                                  label:
                                      const Text('Programaciones Personales'),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() =>
                                          _filtroEntidad =
                                              'ProgramacionPersonal');
                                      _cargarRegistros();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lista
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                await _cargarRegistros();
                              },
                              child: ListView.builder(
                                itemCount: _registros.length,
                                itemBuilder: (context, index) {
                                  final registro = _registros[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(
                                        _getIconoAccion(registro.accion),
                                        color: _getColorAccion(registro.accion),
                                      ),
                                      title: Text(
                                        registro.resumen,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(registro.fechaFormato),
                                          if (registro.descripcion != null)
                                            Text(
                                              registro.descripcion!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                      isThreeLine:
                                          registro.descripcion != null,
                                      trailing: registro.estado == 'exitoso'
                                          ? const Icon(Icons.check,
                                              color: Colors.green)
                                          : registro.estado == 'fallido'
                                              ? const Icon(Icons.close,
                                                  color: Colors.red)
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  IconData _getIconoAccion(String accion) {
    switch (accion.toLowerCase()) {
      case 'crear':
        return Icons.add_circle;
      case 'editar':
        return Icons.edit;
      case 'eliminar':
        return Icons.delete;
      case 'cancelar':
        return Icons.cancel;
      case 'completar':
        return Icons.check_circle;
      default:
        return Icons.event;
    }
  }

  Color _getColorAccion(String accion) {
    switch (accion.toLowerCase()) {
      case 'crear':
        return Colors.green;
      case 'editar':
        return Colors.blue;
      case 'eliminar':
        return Colors.red;
      case 'cancelar':
        return Colors.orange;
      case 'completar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
