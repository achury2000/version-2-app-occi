import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/reserva.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../services/reserva_service.dart';
import '../reservas/reserva_detalle_screen.dart';

/// FASE 3: GESTIÓN DE RESERVAS DEL CLIENTE
/// Funcionalidades:
/// ✅ Listar reservas
/// ✅ Buscar/Filtrar por estado y fechas
/// ✅ Ver detalle completo
/// ✅ Cancelar reserva
/// 🔄 Editar (si es posible según estado)
class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({Key? key}) : super(key: key);

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  final TextEditingController _searchController = TextEditingController();
  String _filtroEstado = '';
  bool _mostrarFiltros = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarReservas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    if (!mounted) return;

    try {
      final clienteProvider = context.read<ClienteProvider>();
      final idCliente = clienteProvider.cliente?.id;

      if (idCliente == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se encontró perfil de cliente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      final reservaProvider = context.read<ReservaProvider>();
      await reservaProvider.cargarReservas(idCliente: idCliente);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _mostrarDetalle(int idReserva) async {
    if (!mounted) return;

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReservaDetalleScreen(idReserva: idReserva),
        ),
      );

      if (!mounted) return;
      await _cargarReservas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSection(String title, List<(String, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0066CC),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.$1.isNotEmpty) ...[
                  SizedBox(
                    width: 110,
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    item.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Deseas cancelar la reserva #${reserva.id}?'),
            const SizedBox(height: 12),
            Text(
              '${_formatDate(reserva.fechaInicio)} a ${_formatDate(reserva.fechaFin)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop(false);
              if (mounted) {
                context.go('/home');
              }
            },
            icon: const Icon(Icons.home_outlined),
            label: const Text('Inicio'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Mantener'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    try {
      await _reservaService.cancelar(reserva.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reserva cancelada exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if (!mounted) return;
      await _cargarReservas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _colorEstado(String? estado) {
    final s = (estado ?? '').toLowerCase();
    if (s == 'confirmada' || s == 'activa') return Colors.green;
    if (s == 'cancelada') return Colors.red;
    if (s == 'pendiente') return Colors.orange;
    return Colors.blueGrey;
  }

  String _iconoEstado(String? estado) {
    final s = (estado ?? '').toLowerCase();
    if (s == 'confirmada' || s == 'activa') return '✅';
    if (s == 'cancelada') return '❌';
    if (s == 'pendiente') return '⏳';
    return '📋';
  }

  Color _colorEstadoPago(String? estadoPago) {
    final s = (estadoPago ?? '').toLowerCase();
    if (s == 'pagada' || s == 'completado') return Colors.green;
    if (s == 'en proceso' || s == 'proceso') return Colors.blue;
    if (s == 'pendiente') return Colors.orange;
    return Colors.blueGrey;
  }

  String _labelEstadoPago(String? estadoPago) {
    final s = (estadoPago ?? '').toLowerCase();
    if (s == 'pagada') return 'Pagada';
    if (s == 'completado') return 'Completado';
    if (s == 'en proceso' || s == 'proceso') return 'En proceso';
    if (s == 'pendiente') return 'Pendiente';
    return 'Sin dato';
  }

  Widget _barraFiltros(ReservaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por ID o nombre...',
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              provider.setBusqueda(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Botones de filtro
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _mostrarFiltros = !_mostrarFiltros);
                  },
                  icon: const Icon(Icons.filter_list),
                  label: Text(_mostrarFiltros ? 'Ocultar' : 'Mostrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (provider.filtroEstado.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    provider.limpiarFiltros();
                    setState(() => _filtroEstado = '');
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Panel de filtros
          if (_mostrarFiltros) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 Filtrar por estado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filtroChip('Todas', _filtroEstado.isEmpty, () {
                        setState(() => _filtroEstado = '');
                        provider.setFiltroEstado('');
                      }),
                      _filtroChip(
                        'Activas',
                        _filtroEstado.toLowerCase() == 'confirmada',
                        () {
                          setState(() => _filtroEstado = 'confirmada');
                          provider.setFiltroEstado('confirmada');
                        },
                      ),
                      _filtroChip(
                        'Pendientes',
                        _filtroEstado.toLowerCase() == 'pendiente',
                        () {
                          setState(() => _filtroEstado = 'pendiente');
                          provider.setFiltroEstado('pendiente');
                        },
                      ),
                      _filtroChip(
                        'Canceladas',
                        _filtroEstado.toLowerCase() == 'cancelada',
                        () {
                          setState(() => _filtroEstado = 'cancelada');
                          provider.setFiltroEstado('cancelada');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filtroChip(String label, bool seleccionado, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF0066CC),
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Mis Reservas'),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Ir a inicio',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              context.go('/home');
            },
          ),
        ],
      ),
      body: Consumer<ReservaProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _cargarReservas,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(provider.error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cargarReservas,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : !provider.tieneReservas
                ? ListView(
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Sin reservas registradas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Haz una nueva reserva para verla aquí',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _barraFiltros(provider),
                      Expanded(
                        child: provider.reservas.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No hay reservas que coincidan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: provider.reservas.length,
                                itemBuilder: (context, index) {
                                  final reserva = provider.reservas[index];
                                  final colorEstado = _colorEstado(
                                    reserva.estado,
                                  );
                                  final iconoEstado = _iconoEstado(
                                    reserva.estado,
                                  );
                                  final colorPago = _colorEstadoPago(
                                    reserva.estadoPago,
                                  );

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => _mostrarDetalle(reserva.id),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          iconoEstado,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          'Reserva #${reserva.id}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${_formatDate(reserva.fechaInicio)} - ${_formatDate(reserva.fechaFin)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colorEstado
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    (reserva.estado ??
                                                            'pendiente')
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: colorEstado,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colorPago.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Pago: ${_labelEstadoPago(reserva.estadoPago)}',
                                                    style: TextStyle(
                                                      color: colorPago,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.people,
                                                  size: 16,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${reserva.cantidadPersonas ?? 0} persona(s)',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.attach_money,
                                                  size: 16,
                                                  color: Colors.green.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '\$${reserva.precioTotal?.toStringAsFixed(0) ?? 'N/D'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _mostrarDetalle(
                                                          reserva.id,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.visibility,
                                                    ),
                                                    label: const Text(
                                                      'Detalles',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed:
                                                        reserva.estaActiva
                                                        ? () =>
                                                              _cancelarReserva(
                                                                reserva,
                                                              )
                                                        : null,
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.cancel,
                                                    ),
                                                    label: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
