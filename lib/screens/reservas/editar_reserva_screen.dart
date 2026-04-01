import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/reserva.dart';
import '../../providers/servicio_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../services/reserva_service.dart';

class EditarReservaScreen extends StatefulWidget {
  final Reserva reserva;

  const EditarReservaScreen({Key? key, required this.reserva}) : super(key: key);

  @override
  State<EditarReservaScreen> createState() => _EditarReservaScreenState();
}

class _EditarReservaScreenState extends State<EditarReservaScreen> {
  late ReservaService _reservaService;
  late int _cantidadPersonas;
  late String _metodoPago;
  late List<int> _serviciosSeleccionados;
  late TextEditingController _observacionesController;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _reservaService = ReservaService();
    _cantidadPersonas = widget.reserva.cantidadPersonas ?? 1;
    _metodoPago = widget.reserva.metodoPago ?? 'transferencia';
    _serviciosSeleccionados = _extraerIdsServicios();
    _observacionesController = TextEditingController(
      text: widget.reserva.observaciones ?? '',
    );

    // Cargar servicios seleccionados en el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<ServicioProvider>()
            .cargarServiciosSeleccionados(_serviciosSeleccionados);
      }
    });
  }

  List<int> _extraerIdsServicios() {
    if (widget.reserva.servicios == null) return [];
    final lista = (widget.reserva.servicios as List)
        .map((s) => (s is Map ? (s['id'] ?? s['id_servicio'] as int) : s as int))
        .toList();
    return lista.cast<int>();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  double _calcularPrecioTotal() {
    if (widget.reserva.precioPorPersona == null) return 0;
    return (widget.reserva.precioPorPersona ?? 0) * _cantidadPersonas;
  }

  Future<void> _actualizarReserva() async {
    setState(() {
      _cargando = true;
    });

    try {
      final reservaActualizada = await _reservaService.actualizar(
        idReserva: widget.reserva.id,
        cantidadPersonas: _cantidadPersonas,
        observaciones: _observacionesController.text,
        servicios: _serviciosSeleccionados.isNotEmpty ? _serviciosSeleccionados : null,
      );

      if (!mounted) return;

      // Limpiar servicios
      context.read<ServicioProvider>().limpiarSeleccion();

      // Actualizar provider
      await context
          .read<ReservaProvider>()
          .obtenerDetalle(widget.reserva.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Reserva #${reservaActualizada.id} actualizada'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const metodos = ['transferencia', 'tarjeta', 'efectivo'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Reserva'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ENCABEZADO CON INFO
            _buildEncabezado(),
            const SizedBox(height: 24),

            /// CANTIDAD DE PERSONAS
            _buildSeccionCantidad(),
            const SizedBox(height: 24),

            /// MÉTODO DE PAGO
            _buildSeccionPago(metodos),
            const SizedBox(height: 24),

            /// SERVICIOS ADICIONALES
            _buildSeccionServicios(),
            const SizedBox(height: 24),

            /// OBSERVACIONES
            _buildSeccionObservaciones(),
            const SizedBox(height: 24),

            /// RESUMEN DE PRECIO
            _buildResumenPrecio(),
            const SizedBox(height: 24),

            /// BOTONES
            _buildBotones(),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reserva #${widget.reserva.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.reserva.nombreExperiencia,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionCantidad() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad de Personas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed: _cantidadPersonas > 1
                  ? () => setState(() => _cantidadPersonas--)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_cantidadPersonas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _cantidadPersonas++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionPago(List<String> metodos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de Pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: metodos
              .map(
                (metodo) => RadioListTile<String>(
                  title: Text(_capitalizarPrimer(metodo)),
                  value: metodo,
                  groupValue: _metodoPago,
                  onChanged: _cargando
                      ? null
                      : (value) {
                          setState(() {
                            _metodoPago = value ?? 'transferencia';
                          });
                        },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSeccionServicios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios Adicionales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<ServicioProvider>(
          builder: (context, servicioProvider, _) {
            final cantidad = servicioProvider.idsServiciosSeleccionados.length;
            return GestureDetector(
              onTap: () async {
                final resultado = await context.pushNamed('serviciosSeleccion');
                if (resultado != null && resultado is List<int>) {
                  setState(() {
                    _serviciosSeleccionados = resultado;
                  });
                  servicioProvider.cargarServiciosSeleccionados(_serviciosSeleccionados);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: cantidad > 0 ? Colors.amber.shade300 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: cantidad > 0 ? Colors.amber.shade50 : Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cantidad == 0
                              ? 'Sin servicios seleccionados'
                              : '$cantidad servicio${cantidad > 1 ? 's' : ''} seleccionado${cantidad > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cantidad > 0 ? Colors.amber.shade900 : Colors.grey,
                          ),
                        ),
                        if (cantidad > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Toca para editar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Icon(
                      Icons.edit,
                      color: cantidad > 0 ? Colors.amber.shade700 : Colors.grey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSeccionObservaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _observacionesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Agrega observaciones adicionales...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenPrecio() {
    final precioUnitario = widget.reserva.precioPorPersona ?? 0;
    final precioTotal = _calcularPrecioTotal();

    return Consumer<ServicioProvider>(
      builder: (context, servicioProvider, _) {
        final serviciosTotal = servicioProvider.totalServiciosSeleccionados;
        final totalConServicios = precioTotal + serviciosTotal;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Precio por persona:'),
                  Text('\$${precioUnitario.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cantidad:'),
                  Text('$_cantidadPersonas'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Experiencia:'),
                  Text('\$${precioTotal.toStringAsFixed(2)}'),
                ],
              ),
              if (serviciosTotal > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Servicios:'),
                    Text(
                      '\$${serviciosTotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.amber),
                    ),
                  ],
                ),
              ],
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$${totalConServicios.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBotones() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cargando ? null : () => context.pop(),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _cargando ? null : _actualizarReserva,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Actualizar'),
          ),
        ),
      ],
    );
  }

  String _capitalizarPrimer(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
}
