import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/reserva.dart';
import '../../providers/reserva_provider.dart';

class BusquedaAvanzadaScreen extends StatefulWidget {
  const BusquedaAvanzadaScreen({Key? key}) : super(key: key);

  @override
  State<BusquedaAvanzadaScreen> createState() => _BusquedaAvanzadaScreenState();
}

class _BusquedaAvanzadaScreenState extends State<BusquedaAvanzadaScreen> {
  final _queryController = TextEditingController();
  String _filtroEstado = 'todas';
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  bool _buscando = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(bool esDesde) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );

    if (picked != null) {
      setState(() {
        if (esDesde) {
          _fechaDesde = picked;
        } else {
          _fechaHasta = picked;
        }
      });
    }
  }

  void _ejecutarBusqueda() async {
    setState(() => _buscando = true);

    try {
      final provider = context.read<ReservaProvider>();

      // Aplicar filtros mediante el provider
      if (_queryController.text.isNotEmpty) {
        provider.setBusqueda(_queryController.text);
      }

      if (_filtroEstado != 'todas') {
        provider.setFiltroEstado(_filtroEstado);
      }

      setState(() => _buscando = false);
    } catch (e) {
      setState(() => _buscando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _queryController.clear();
      _filtroEstado = 'todas';
      _fechaDesde = null;
      _fechaHasta = null;
    });
    context.read<ReservaProvider>().limpiarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda Avanzada'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Búsqueda por texto
              const Text(
                'Búsqueda por ID o Nombre',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: 'ID de reserva o nombre del cliente...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Filtro de estado
              const Text(
                'Estado de Reserva',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todas', 'todas'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pendiente', 'pendiente'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Confirmada', 'confirmada'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completada', 'completada'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cancelada', 'cancelada'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rango de fechas
              const Text(
                'Rango de Fechas',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _seleccionarFecha(true),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _fechaDesde != null
                            ? DateFormat('dd/MM/yyyy').format(_fechaDesde!)
                            : 'Desde',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _seleccionarFecha(false),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _fechaHasta != null
                            ? DateFormat('dd/MM/yyyy').format(_fechaHasta!)
                            : 'Hasta',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _buscando ? null : _ejecutarBusqueda,
                      icon: _buscando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(_buscando ? 'Buscando...' : 'Buscar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _limpiarFiltros,
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Resultados
              const Text(
                'Resultados',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<ReservaProvider>(
                builder: (context, provider, _) {
                  final reservas = provider.reservas;

                  if (reservas.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: const [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No hay resultados'),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reservas.length,
                    itemBuilder: (context, index) {
                      final reserva = reservas[index];
                      return _buildResultadoCard(reserva);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      selected: _filtroEstado == value,
      label: Text(label),
      onSelected: (selected) {
        if (selected) {
          setState(() => _filtroEstado = value);
        }
      },
    );
  }

  Widget _buildResultadoCard(Reserva reserva) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reserva #${reserva.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _getColorEstado(reserva.estado ?? '').withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (reserva.estado ?? '').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getColorEstado(reserva.estado ?? ''),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reserva.nombreCliente ?? 'Cliente',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reserva.fechaInicio != null
                      ? dateFormat.format(reserva.fechaInicio!)
                      : 'N/A',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '\$${(reserva.precioTotal ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completada':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
