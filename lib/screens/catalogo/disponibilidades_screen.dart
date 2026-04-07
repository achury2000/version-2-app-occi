import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/programacion.dart';
import '../../providers/programacion_provider.dart';
import '../../providers/reserva_provider.dart';

class DisponibilidadesScreen extends StatefulWidget {
  const DisponibilidadesScreen({Key? key}) : super(key: key);

  @override
  State<DisponibilidadesScreen> createState() => _DisponibilidadesScreenState();
}

class _DisponibilidadesScreenState extends State<DisponibilidadesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarProgramaciones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _cargarProgramaciones() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramacionProvider>().cargarProgramaciones();
    });
  }

  void _aplicarBusqueda(BuildContext context, String query) {
    final provider = context.read<ProgramacionProvider>();
    if (query.isEmpty) {
      provider.limpiarFiltros();
    } else {
      provider.setBusqueda(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidades'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _cargarProgramaciones();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _aplicarBusqueda(context, value),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o ruta...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _aplicarBusqueda(context, '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            // Filtros expandibles
            if (_showFilters) _buildFiltersPanel(context),
            // Tabs para vista de lista/grid
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Lista',
                ),
                Tab(
                  icon: Icon(Icons.grid_3x3),
                  text: 'Grid',
                ),
              ],
            ),
            // Contenido con lista de programaciones
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(context),
                  _buildGridView(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersPanel(BuildContext context) {
    return Consumer<ProgramacionProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtro por estado
              const Text(
                'Estado',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['disponible', 'completo', 'cancelado']
                    .map(
                      (estado) => FilterChip(
                        label: Text(estado),
                        selected:
                            (provider.filtros['estado'] ?? '') == estado,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setFiltroEstado(estado);
                          } else {
                            provider.setFiltroEstado('');
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              // Limpiar filtros
              TextButton(
                onPressed: () {
                  provider.limpiarFiltros();
                  setState(() {
                    _showFilters = false;
                  });
                },
                child: const Text('Limpiar filtros'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return Consumer<ProgramacionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null && provider.error!.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _cargarProgramaciones,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final programaciones = provider.programaciones;
        
        if (!provider.tieneProgramaciones) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay disponibilidades',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Intenta cambiar los filtros',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: programaciones.length,
          itemBuilder: (context, index) {
            return _buildProgramacionCard(
              context,
              programaciones[index],
              index,
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    return Consumer<ProgramacionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null && provider.error!.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _cargarProgramaciones,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final programaciones = provider.programaciones;

        if (!provider.tieneProgramaciones) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_month, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay disponibilidades'),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: programaciones.length,
          itemBuilder: (context, index) {
            return _buildProgramacionGridItem(
              context,
              programaciones[index],
            );
          },
        );
      },
    );
  }

  Widget _buildProgramacionCard(
    BuildContext context,
    Programacion programacion,
    int index,
  ) {
    final estadoColor = _getEstadoColor(programacion.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalle(context, programacion),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con nombre y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          programacion.nombreRuta ?? 'Sin nombre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (programacion.guia != null)
                          Text(
                            'Guía: ${programacion.guia}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      programacion.estado ?? 'Desconocido',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              // Información de fecha y cupos
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(programacion.fechaSalida),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    programacion.horaSalida ?? 'N/A',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Información de cupos y precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${programacion.cuposDisponibles ?? 0}/${programacion.cuposTotales ?? 0} cupos',
                        style: TextStyle(
                          fontSize: 13,
                          color: (programacion.cuposDisponibles ?? 0) > 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${(programacion.precio ?? 0).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              if (programacion.observaciones != null &&
                  programacion.observaciones!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    programacion.observaciones!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramacionGridItem(
    BuildContext context,
    Programacion programacion,
  ) {
    final estadoColor = _getEstadoColor(programacion.estado);

    return Card(
      child: InkWell(
        onTap: () => _mostrarDetalle(context, programacion),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                programacion.estado ?? 'Desconocido',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: estadoColor,
                ),
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      programacion.nombreRuta ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(programacion.fechaSalida),
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          programacion.horaSalida ?? 'N/A',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${programacion.cuposDisponibles ?? 0}/${programacion.cuposTotales ?? 0}',
                            style: TextStyle(
                              fontSize: 11,
                              color: (programacion.cuposDisponibles ?? 0) > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '\$${(programacion.precio ?? 0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
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

  void _mostrarDetalle(BuildContext context, Programacion programacion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildDetalleModal(context, programacion),
    );
  }

  Widget _buildDetalleModal(BuildContext context, Programacion programacion) {
    final estadoColor = _getEstadoColor(programacion.estado);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            programacion.nombreRuta ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: estadoColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                (programacion.estado ?? 'N/A').toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: estadoColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Detalles
                _buildDetalleRow(
                  'Fecha de salida',
                  _formatDateLong(programacion.fechaSalida),
                  Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                _buildDetalleRow(
                  'Hora de salida',
                  programacion.horaSalida,
                  Icons.schedule,
                ),
                const SizedBox(height: 16),
                _buildDetalleRow(
                  'Cupos disponibles',
                  '${programacion.cuposDisponibles ?? 0} de ${programacion.cuposTotales ?? 0}',
                  Icons.people,
                  valueColor: (programacion.cuposDisponibles ?? 0) > 0
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(height: 16),
                _buildDetalleRow(
                  'Precio por persona',
                  '\$${(programacion.precio ?? 0).toStringAsFixed(2)}',
                  Icons.attach_money,
                  valueColor: Colors.blue,
                ),
                if (programacion.guia != null &&
                    programacion.guia!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetalleRow(
                    'Guía',
                    programacion.guia,
                    Icons.person,
                  ),
                ],
                if (programacion.observaciones != null &&
                    programacion.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Observaciones',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    programacion.observaciones!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                // Botón de reserva
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (programacion.cuposDisponibles ?? 0) > 0
                        ? () => _iniciarReserva(context, programacion)
                        : null,
                    child: const Text('Reservar ahora'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetalleRow(
    String label,
    String? value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _iniciarReserva(BuildContext context, Programacion programacion) {
    // Guardar la programación seleccionada en el provider
    context
        .read<ProgramacionProvider>()
        .cargarDetalleProgramacion(programacion.id!);

    // Inicializar la reserva con la programación seleccionada
    context.read<ReservaProvider>().iniciarReservaConProgramacion(
          idProgramacion: programacion.id!,
          nombreRuta: programacion.nombreRuta,
          precio: programacion.precio,
        );

    // Navegar a la pantalla de crear reserva
    Navigator.pop(context);

    // Usar context.push desde GoRouter para navegar
    Future.delayed(const Duration(milliseconds: 200), () {
      if (context.mounted) {
        context.push('/crear-reserva?idProgramacion=${programacion.id}');
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatDateLong(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      const monthNames = [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre'
      ];
      return '${date.day} de ${monthNames[date.month - 1]} de ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getEstadoColor(String? estado) {
    switch ((estado ?? '').toLowerCase()) {
      case 'disponible':
        return Colors.green;
      case 'completo':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
