import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/programacion.dart';
import '../../providers/programacion_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/reserva_service.dart';

class CrearReservaScreen extends StatefulWidget {
  final int? idProgramacion;
  final Programacion? programacion;

  const CrearReservaScreen({
    Key? key,
    this.idProgramacion,
    this.programacion,
  }) : super(key: key);

  @override
  State<CrearReservaScreen> createState() => _CrearReservaScreenState();
}

class _CrearReservaScreenState extends State<CrearReservaScreen> {
  late ReservaService _reservaService;
  int _cantidadPersonas = 1;
  String _metodoPago = 'transferencia';
  final TextEditingController _observacionesController = TextEditingController();
  bool _cargando = false;
  Programacion? _programacionSeleccionada;

  @override
  void initState() {
    super.initState();
    _reservaService = ReservaService();
    _programacionSeleccionada = widget.programacion;
    _cargarProgramacion();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  void _cargarProgramacion() {
    if (widget.idProgramacion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<ProgramacionProvider>()
            .cargarDetalleProgramacion(widget.idProgramacion!);
      });
    }
  }

  double _calcularPrecioTotal() {
    if (_programacionSeleccionada == null) return 0;
    return (_programacionSeleccionada?.precio ?? 0) * _cantidadPersonas;
  }

  Future<void> _crearReserva() async {
    if (_programacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una programación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final idCliente = authProvider.usuario?.id;

    if (idCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró perfil de cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final nuevaReserva = await _reservaService.crear(
        idCliente: idCliente,
        idProgramacion: _programacionSeleccionada!.id,
        cantidadPersonas: _cantidadPersonas,
        metodoPago: _metodoPago,
        observaciones: _observacionesController.text,
      );

      if (!mounted) return;

      // Actualizar lista de reservas en el provider
      await context.read<ReservaProvider>().cargarReservas(idCliente: idCliente);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Reserva #${nuevaReserva.id} creada exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navegar a detalle de la nueva reserva
      if (mounted) {
        context.pop();
        // Esperar a que se cierre esta pantalla
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.pushNamed(
              'reservaDetalle',
              queryParameters: {'id': nuevaReserva.id.toString()},
            );
          }
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reserva'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ProgramacionProvider>(
        builder: (context, progProvider, _) {
          _programacionSeleccionada ??= progProvider.programacionSeleccionada;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// SECCIÓN 1: Seleccionar Programación
                _buildSeccionProgramacion(progProvider),
                const SizedBox(height: 24),

                /// SECCIÓN 2: Cantidad de Personas
                _buildSeccionCantidad(),
                const SizedBox(height: 24),

                /// SECCIÓN 3: Método de Pago
                _buildSeccionPago(),
                const SizedBox(height: 24),

                /// SECCIÓN 4: Observaciones
                _buildSeccionObservaciones(),
                const SizedBox(height: 24),

                /// SECCIÓN 5: Resumen de Precio
                _buildResumenPrecio(),
                const SizedBox(height: 24),

                /// SECCIÓN 6: Botones
                _buildBotones(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeccionProgramacion(ProgramacionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Programación Seleccionada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_programacionSeleccionada == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: const Text(
              'No hay programación seleccionada',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _programacionSeleccionada?.nombreRuta ?? 'Sin nombre',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fecha: ${_formatDate(_programacionSeleccionada?.fechaSalida)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      'Hora: ${_programacionSeleccionada?.horaSalida ?? "N/A"}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Cupos disponibles: ${_programacionSeleccionada?.cuposDisponibles ?? 0}/${_programacionSeleccionada?.cuposTotales ?? 0}',
                  style: TextStyle(
                    fontSize: 13,
                    color: (_programacionSeleccionada?.cuposDisponibles ?? 0) > 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSeccionCantidad() {
    final maxPersonas = _programacionSeleccionada?.cuposDisponibles ?? 1;

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
              onPressed: _cargando || _cantidadPersonas <= 1
                  ? null
                  : () {
                      setState(() {
                        _cantidadPersonas--;
                      });
                    },
              icon: const Icon(Icons.remove_circle_outline),
              iconSize: 32,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_cantidadPersonas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _cargando || _cantidadPersonas >= maxPersonas
                  ? null
                  : () {
                      setState(() {
                        _cantidadPersonas++;
                      });
                    },
              icon: const Icon(Icons.add_circle_outline),
              iconSize: 32,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Máximo disponible: $maxPersonas personas',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSeccionPago() {
    const metodos = ['transferencia', 'tarjeta', 'efectivo'];

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

  Widget _buildSeccionObservaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones (Opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _observacionesController,
          enabled: !_cargando,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Añade alguna nota especial para tu reserva...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenPrecio() {
    final precioUnitario = _programacionSeleccionada?.precio ?? 0;
    final precioTotal = _calcularPrecioTotal();

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
              const Text(
                'Precio por persona:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '\$${precioUnitario.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cantidad:',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '$_cantidadPersonas persona${_cantidadPersonas > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precio Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${precioTotal.toStringAsFixed(2)}',
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
  }

  Widget _buildBotones() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cargando ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _cargando || _programacionSeleccionada == null
                ? null
                : _crearReserva,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
                : const Text('Confirmar Reserva'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalizarPrimer(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }
}
