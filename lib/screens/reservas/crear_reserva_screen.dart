import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/programacion.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/programacion_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/servicio_provider.dart';
import '../../services/reserva_service.dart';

class CrearReservaScreen extends StatefulWidget {
  final int? idProgramacion;
  final int? idRuta;
  final Programacion? programacion;

  const CrearReservaScreen({
    Key? key,
    this.idProgramacion,
    this.idRuta,
    this.programacion,
  }) : super(key: key);

  @override
  State<CrearReservaScreen> createState() => _CrearReservaScreenState();
}

class _CrearReservaScreenState extends State<CrearReservaScreen> {
  late ReservaService _reservaService;
  int _cantidadPersonas = 1;
  String _metodoPago = 'transferencia';
  List<int> _serviciosSeleccionados = [];
  final TextEditingController _observacionesController =
      TextEditingController();
  bool _cargando = false;
  Programacion? _programacionSeleccionada;
  int? _idRutaSeleccionada;
  bool _usarProgramacion = true;

  @override
  void initState() {
    super.initState();
    _reservaService = ReservaService();
    _programacionSeleccionada = widget.programacion;
    _idRutaSeleccionada = widget.idRuta;
    _usarProgramacion =
        widget.idProgramacion != null || widget.programacion != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProgramacion();
      context.read<CatalogoProvider>().fetchRutas();
    });
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  void _cargarProgramacion() {
    if (widget.idProgramacion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProgramacionProvider>().cargarDetalleProgramacion(
              widget.idProgramacion!,
            );
      });
    }
  }

  Future<void> _crearReserva() async {
    if (_usarProgramacion && _programacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una programación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_usarProgramacion &&
        (_idRutaSeleccionada == null || _idRutaSeleccionada! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una ruta normal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final clienteProvider = context.read<ClienteProvider>();

    int? idCliente = clienteProvider.cliente?.id;

    if (idCliente == null) {
      final idUsuario = authProvider.usuario?.id;
      if (idUsuario != null) {
        await clienteProvider.loadCliente(idUsuario);
        idCliente = clienteProvider.cliente?.id;
      }
    }

    if (idCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No se encontró el id de cliente para crear la reserva'),
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
        idProgramacion:
            _usarProgramacion ? _programacionSeleccionada?.id : null,
        idRuta: _usarProgramacion ? null : _idRutaSeleccionada,
        cantidadPersonas: _cantidadPersonas,
        metodoPago: _metodoPago,
        observaciones: _observacionesController.text,
      );

      if (!mounted) return;

      // Actualizar lista de reservas en el provider
      if (mounted) {
        // ignore: use_build_context_synchronously
        await context.read<ReservaProvider>().cargarReservas(
              idCliente: idCliente,
            );
      }

      if (!mounted) return;

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Reserva #${nuevaReserva.id} creada exitosamente'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navegar a detalle de la nueva reserva
      if (mounted) {
        // Limpiar servicios seleccionados para próxima reserva
        context.read<ServicioProvider>().limpiarSeleccion();

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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              context.go('/home');
            },
          ),
        ],
      ),
      body: Consumer<ProgramacionProvider>(
        builder: (context, progProvider, _) {
          _programacionSeleccionada ??= progProvider.programacionSeleccionada;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// SECCIÓN 0: Tipo de reserva
                _buildSeccionTipoReserva(),
                const SizedBox(height: 24),

                /// SECCIÓN 1: Seleccionar Programación
                _buildSeccionProgramacion(progProvider),
                const SizedBox(height: 24),

                /// SECCIÓN 2: Cantidad de Personas
                _buildSeccionCantidad(),
                const SizedBox(height: 24),

                /// SECCIÓN 3: Método de Pago
                _buildSeccionPago(),
                const SizedBox(height: 24),

                /// SECCIÓN 3.1: Información de pago por QR
                _buildSeccionInfoQr(),
                const SizedBox(height: 24),

                /// SECCIÓN 4: Servicios Adicionales
                _buildSeccionServicios(),
                const SizedBox(height: 24),

                /// SECCIÓN 5: Observaciones
                _buildSeccionObservaciones(),
                const SizedBox(height: 24),

                /// SECCIÓN 6: Resumen de Precio
                _buildResumenPrecio(),
                const SizedBox(height: 24),

                /// SECCIÓN 7: Botones
                _buildBotones(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeccionProgramacion(ProgramacionProvider provider) {
    if (!_usarProgramacion) {
      return _buildSeccionRutaNormal();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Programación Seleccionada',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    color:
                        (_programacionSeleccionada?.cuposDisponibles ?? 0) > 0
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
    final maxPersonas = _usarProgramacion
        ? (_programacionSeleccionada?.cuposDisponibles ?? 1)
        : 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad de Personas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildSeccionInfoQr() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.qr_code_2, color: Colors.teal),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Al confirmar la reserva podras ver el QR de pago en el detalle de tu reserva para completar el pago.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionTipoReserva() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de reserva',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Ruta programada'),
                selected: _usarProgramacion,
                onSelected: _cargando
                    ? null
                    : (selected) {
                        if (!selected) return;
                        setState(() => _usarProgramacion = true);
                      },
              ),
              ChoiceChip(
                label: const Text('Ruta normal'),
                selected: !_usarProgramacion,
                onSelected: _cargando
                    ? null
                    : (selected) {
                        if (!selected) return;
                        setState(() => _usarProgramacion = false);
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionRutaNormal() {
    return Consumer<CatalogoProvider>(
      builder: (context, catalogoProvider, _) {
        final rutas = catalogoProvider.rutas;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ruta Normal Seleccionada',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (catalogoProvider.isLoadingRutas)
              const Center(child: CircularProgressIndicator())
            else if (rutas.isEmpty)
              const Text('No hay rutas disponibles')
            else
              DropdownButtonFormField<int>(
                value: _idRutaSeleccionada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: rutas
                    .whereType<Map<String, dynamic>>()
                    .map<DropdownMenuItem<int>>((map) {
                      final idRaw = map['id_ruta'] ?? map['id'];
                      final id = idRaw is int
                          ? idRaw
                          : int.tryParse(idRaw?.toString() ?? '') ?? 0;
                      final nombre = (map['nombre'] ?? 'Ruta').toString();
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(nombre),
                      );
                    })
                    .where((item) => item.value != null && item.value! > 0)
                    .toList(),
                onChanged: _cargando
                    ? null
                    : (value) {
                        setState(() => _idRutaSeleccionada = value);
                      },
              ),
            const SizedBox(height: 8),
            const Text(
              'Los servicios predefinidos de la ruta se incluiran automaticamente en backend.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeccionObservaciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones (Opcional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _observacionesController,
          enabled: !_cargando,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Añade alguna nota especial para tu reserva...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenPrecio() {
    double precioUnitario = _programacionSeleccionada?.precio ?? 0;
    if (!_usarProgramacion && _idRutaSeleccionada != null) {
      final ruta = context.read<CatalogoProvider>().getRutaById(
            _idRutaSeleccionada!,
          );
      if (ruta is Map<String, dynamic>) {
        final raw = ruta['precio'] ?? 0;
        if (raw is num) {
          precioUnitario = raw.toDouble();
        } else {
          precioUnitario = double.tryParse(raw.toString()) ?? 0;
        }
      }
    }
    final precioTotal = precioUnitario * _cantidadPersonas;

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
                  const Text('Cantidad:', style: TextStyle(color: Colors.grey)),
                  Text(
                    '$_cantidadPersonas persona${_cantidadPersonas > 1 ? 's' : ''}',
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
                    'Experiencia:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '\$${precioTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (serviciosTotal > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Servicios:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '\$${serviciosTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            onPressed: _cargando ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _cargando ||
                    (_usarProgramacion && _programacionSeleccionada == null) ||
                    (!_usarProgramacion && _idRutaSeleccionada == null)
                ? null
                : _crearReserva,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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

  /// Construir sección de servicios adicionales
  Widget _buildSeccionServicios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios Adicionales',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  // Actualizar el provider con los servicios seleccionados
                  servicioProvider.cargarServiciosSeleccionados(
                    _serviciosSeleccionados,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: cantidad > 0
                        ? Colors.amber.shade300
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color:
                      cantidad > 0 ? Colors.amber.shade50 : Colors.grey.shade50,
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
                            color: cantidad > 0
                                ? Colors.amber.shade900
                                : Colors.grey,
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
}
