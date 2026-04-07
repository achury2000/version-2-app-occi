import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/programacion_personal.dart';
import '../../providers/programacion_personal_provider.dart';
import '../../providers/auth_provider.dart';

class ListaProgramacionesPersonalesScreen extends StatefulWidget {
  const ListaProgramacionesPersonalesScreen({Key? key}) : super(key: key);

  @override
  State<ListaProgramacionesPersonalesScreen> createState() =>
      _ListaProgramacionesPersonalesScreenState();
}

class _ListaProgramacionesPersonalesScreenState
    extends State<ListaProgramacionesPersonalesScreen> {
  final _searchController = TextEditingController();
  String _filtroEstado = 'todas';
  bool _cargandoInicial = true;

  @override
  void initState() {
    super.initState();
    _cargarProgramaciones();
  }

  Future<void> _cargarProgramaciones() async {
    try {
      final auth = context.read<AuthProvider>();
      final idCliente = auth.usuario?.id;

      if (idCliente == null) {
        throw Exception('No hay cliente autenticado');
      }

      await context
          .read<ProgramacionPersonalProvider>()
          .cargarProgramaciones(idCliente: idCliente);

      if (mounted) {
        setState(() {
          _cargandoInicial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoInicial = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _mostrarConfirmacionEliminar(ProgramacionPersonal prog) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Programación'),
        content: Text('¿Deseas eliminar "${prog.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _eliminarProgramacion(prog.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarProgramacion(int id) async {
    try {
      await context
          .read<ProgramacionPersonalProvider>()
          .eliminarProgramacion(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Programación eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _marcarCompletada(ProgramacionPersonal prog) async {
    try {
      await context
          .read<ProgramacionPersonalProvider>()
          .marcarCompletada(prog.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Marcada como completada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargandoInicial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Programaciones Personales'),
        centerTitle: true,
      ),
      body: Consumer<ProgramacionPersonalProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _cargarProgramaciones,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!provider.tieneProgramaciones) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tienes programaciones personales'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/agregar-programacion-personal'),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear programación'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      provider.setBusqueda(value),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setBusqueda('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filtro de estado (chips)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _filtroEstado == 'todas',
                        label: Text('Todas (${provider.totalProgramaciones})'),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filtroEstado = 'todas');
                            provider.setFiltroEstado('todas');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _filtroEstado == 'pendiente',
                        label: Text('Pendientes (${provider.pendientes})'),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filtroEstado = 'pendiente');
                            provider.setFiltroEstado('pendiente');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _filtroEstado == 'completada',
                        label: Text('Completadas (${provider.completadas})'),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filtroEstado = 'completada');
                            provider.setFiltroEstado('completada');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de programaciones
                Expanded(
                  child: provider.programaciones.isEmpty
                      ? Center(
                          child: Text(
                            _filtroEstado == 'todas'
                                ? 'No hay programaciones'
                                : 'No hay programaciones $_filtroEstado',
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _cargarProgramaciones,
                          child: ListView.builder(
                            itemCount: provider.programaciones.length,
                            itemBuilder: (context, index) {
                              final prog = provider.programaciones[index];
                              return _buildProgramacionCard(prog);
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/agregar-programacion-personal'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgramacionCard(ProgramacionPersonal prog) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: Título + Estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prog.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (prog.descripcion != null &&
                          prog.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          prog.descripcion!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: prog.estaCompletada
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    prog.estaCompletada ? '✓ Completada' : '⏱ Pendiente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: prog.estaCompletada
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Fecha y hora
            if (prog.fechaProgramacion != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    prog.fechaHoraFormato,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Botones de acción
            Row(
              children: [
                if (!prog.estaCompletada)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _marcarCompletada(prog),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Completar'),
                    ),
                  ),
                if (!prog.estaCompletada) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/editar-programacion-personal',
                      extra: prog,
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _mostrarConfirmacionEliminar(prog),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
