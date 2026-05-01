import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../services/solicitud_service.dart';

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
  late SolicitudService _solicitudService;
  int _cantidadPersonas = 1;
  String _metodoPago = 'transferencia';
  List<int> _serviciosSeleccionados = [];
  List<Map<String, String>> _acompanantes = [];
  int _numeroAcompanantes = 0;
  final List<TextEditingController> _nombreAcompCtrls = [];
  final List<TextEditingController> _cedulaAcompCtrls = [];
  final TextEditingController _observacionesController =
      TextEditingController();
  bool _cargando = false;
  Programacion? _programacionSeleccionada;
  int? _idRutaSeleccionada;
  bool _usarProgramacion = true;
  bool _esPersonalizada = false;
  bool _seleccionarFincaDirecta = false;
  bool _onlyRutaMode =
      false; // si true, ocultar cualquier opción relacionada con fincas
  DateTime? _fechaPersonalizada;
  TimeOfDay? _horaPersonalizada;

  int _maxPersonas() {
    if (_usarProgramacion) {
      return _programacionSeleccionada?.cuposDisponibles ?? 1;
    }
    return 20;
  }

  int _maxAcompanantes() {
    final max = _maxPersonas() - 1;
    return max < 0 ? 0 : max;
  }

  void _syncCantidadPersonas() {
    _cantidadPersonas = 1 + _numeroAcompanantes;
  }

  void _ajustarAcompanantesPorCupo() {
    final maxAcompanantes = _maxAcompanantes();
    if (_numeroAcompanantes > maxAcompanantes) {
      _numeroAcompanantes = maxAcompanantes;
      while (_nombreAcompCtrls.length > maxAcompanantes) {
        _nombreAcompCtrls.removeLast().dispose();
      }
      while (_cedulaAcompCtrls.length > maxAcompanantes) {
        _cedulaAcompCtrls.removeLast().dispose();
      }
    }
    _syncCantidadPersonas();
  }

  @override
  void initState() {
    super.initState();
    _reservaService = ReservaService();
    _solicitudService = SolicitudService();
    _programacionSeleccionada = widget.programacion;
    _idRutaSeleccionada = widget.idRuta;
    _usarProgramacion =
        widget.idProgramacion != null || widget.programacion != null;
    _onlyRutaMode =
        widget.idRuta != null ||
        widget.idProgramacion != null ||
        widget.programacion != null;
    if (_onlyRutaMode) {
      _seleccionarFincaDirecta = false;
      if (widget.idRuta != null &&
          (_idRutaSeleccionada == null || _idRutaSeleccionada == 0)) {
        _idRutaSeleccionada = widget.idRuta;
      }
    }

    void _cargarProgramacion() {
      if (widget.idProgramacion != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<ProgramacionProvider>().cargarDetalleProgramacion(
            widget.idProgramacion!,
          );
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProgramacion();
      context.read<CatalogoProvider>().fetchRutas();
      if (!_onlyRutaMode) {
        context.read<CatalogoProvider>().fetchFincas();
      }
      try {
        context.read<ProgramacionProvider>().cargarProgramaciones();
      } catch (_) {}
    });
  }

  Future<void> _pickFechaPersonalizada() async {
    final now = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (fecha != null) setState(() => _fechaPersonalizada = fecha);
  }

  Future<void> _pickHoraPersonalizada() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) setState(() => _horaPersonalizada = hora);
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

    // Validación: si usamos una programación, verificar que hay cupos suficientes
    if (_usarProgramacion) {
      if (_programacionSeleccionada?.estaDesactivada ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esta programacion esta desactivada'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _syncCantidadPersonas();
      final cuposDisp = _programacionSeleccionada?.cuposDisponibles ?? 0;
      if (_cantidadPersonas > cuposDisp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay suficientes cupos: disponibles $cuposDisp'),
          ),
        );
        return;
      }
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

    // Si es personalizada, asegurarse de que se haya escogido la ruta/finca
    if (_esPersonalizada &&
        (_idRutaSeleccionada == null || _idRutaSeleccionada! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona una ruta o finca para la reserva personalizada',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_esPersonalizada && _seleccionarFincaDirecta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La reserva personalizada solo aplica para rutas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_esPersonalizada &&
        (_fechaPersonalizada == null || _horaPersonalizada == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona fecha y hora para la reserva personalizada',
          ),
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
          content: Text(
            'No se encontró el id de cliente para crear la reserva',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar acompañantes: si se indicó número > 0, todos deben tener nombre y documento
    for (var i = 0; i < _numeroAcompanantes; i++) {
      final nombre = i < _nombreAcompCtrls.length
          ? _nombreAcompCtrls[i].text.trim()
          : '';
      final cedula = i < _cedulaAcompCtrls.length
          ? _cedulaAcompCtrls[i].text.trim()
          : '';
      if (nombre.isEmpty || cedula.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa nombre y cédula de todos los acompañantes'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (cedula.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ingresa un número de documento válido para los acompañantes',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _cargando = true;
    });

    try {
      // Construir string de acompañantes a partir de los controllers
      final parts = <String>[];
      for (var i = 0; i < _numeroAcompanantes; i++) {
        final nombre = i < _nombreAcompCtrls.length
            ? _nombreAcompCtrls[i].text.trim()
            : '';
        final cedula = i < _cedulaAcompCtrls.length
            ? _cedulaAcompCtrls[i].text.trim()
            : '';
        if (nombre.isNotEmpty || cedula.isNotEmpty) {
          parts.add(
            '${nombre.isNotEmpty ? nombre : ''} ${cedula.isNotEmpty ? cedula : ''}'
                .trim(),
          );
        }
      }

      final acompText = parts.join(' , ');

      // Si es reserva personalizada, incluir fecha/hora en observaciones
      String personalizadaText = '';
      if (_esPersonalizada &&
          _fechaPersonalizada != null &&
          _horaPersonalizada != null) {
        personalizadaText =
            'Fecha deseada: ${_fechaPersonalizada!.toLocal().toString().split(' ')[0]} ${_horaPersonalizada!.format(context)}';
      }

      final observacionesBase = _observacionesController.text.trim();
      final bufferParts = <String>[];
      if (observacionesBase.isNotEmpty) bufferParts.add(observacionesBase);
      if (personalizadaText.isNotEmpty) bufferParts.add(personalizadaText);
      if (acompText.isNotEmpty) bufferParts.add('Acompañantes: $acompText');

      final observacionesFinal = bufferParts.join('\n');

      final acompanantesPayload =
          List.generate(_numeroAcompanantes, (i) {
                final nombre = i < _nombreAcompCtrls.length
                    ? _nombreAcompCtrls[i].text.trim()
                    : '';
                final cedula = i < _cedulaAcompCtrls.length
                    ? _cedulaAcompCtrls[i].text.trim()
                    : '';
                return {'nombre_completo': nombre, 'numero_documento': cedula};
              })
              .where(
                (m) =>
                    (m['nombre_completo']?.isNotEmpty ?? false) ||
                    (m['numero_documento']?.isNotEmpty ?? false),
              )
              .toList();

      if (_esPersonalizada) {
        final payload = <String, dynamic>{
          'id_cliente': idCliente,
          'id_ruta': _idRutaSeleccionada,
          'cantidad_personas': _cantidadPersonas,
          'fecha_deseada': _fechaPersonalizada!
              .toIso8601String()
              .split('T')
              .first,
          'hora_deseada': _horaPersonalizada!.format(context),
          'observaciones': observacionesFinal,
          if (acompanantesPayload.isNotEmpty)
            'acompanantes': acompanantesPayload,
        };

        final solicitudId = await _solicitudService.crear(payload);
        if (!mounted) return;

        if (solicitudId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Solicitud #$solicitudId enviada'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop();
          return;
        }

        throw Exception('No se pudo crear la solicitud personalizada');
      }

      final nuevaReserva = await _reservaService.crear(
        idCliente: idCliente,
        idProgramacion: _usarProgramacion
            ? _programacionSeleccionada?.id
            : null,
        idRuta: _usarProgramacion ? null : _idRutaSeleccionada,
        cantidadPersonas: _cantidadPersonas,
        metodoPago: _metodoPago,
        observaciones: observacionesFinal,
        acompanantes: acompanantesPayload,
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

                /// SECCIÓN 2.5: Acompañantes
                _buildSeccionAcompanantes(),
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
      if (_esPersonalizada) {
        return _buildSeccionReservaPersonalizada();
      }
      return _buildSeccionRutaNormal();
    }

    final programacionesVisibles = provider.programaciones
        .where(
          (prog) =>
              _idRutaSeleccionada == null || prog.idRuta == _idRutaSeleccionada,
        )
        .toList();

    final tieneActivas = programacionesVisibles.any(
      (prog) => prog.tieneCupos && !prog.estaDesactivada,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Programación Seleccionada',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (programacionesVisibles.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: const Text(
              'No hay programaciones disponibles para esta ruta',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          DropdownButtonFormField<int>(
            value: _programacionSeleccionada?.id,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: programacionesVisibles.map((prog) {
              final fecha = _formatDate(prog.fechaSalida);
              final hora = prog.horaSalida ?? 'N/A';
              final cupos = prog.cuposDisponibles ?? 0;
              final nombre = prog.nombreRuta ?? 'Ruta';
              final habilitada = prog.tieneCupos && !prog.estaDesactivada;
              final estadoTexto = prog.estaDesactivada
                  ? 'Desactivada'
                  : (prog.tieneCupos ? 'Activa' : 'Sin cupos');
              return DropdownMenuItem<int>(
                value: prog.id,
                enabled: habilitada,
                child: Text(
                  '$nombre - $fecha $hora ($cupos cupos) - $estadoTexto',
                ),
              );
            }).toList(),
            onChanged: _cargando
                ? null
                : (value) {
                    if (value == null) return;
                    final seleccionada = programacionesVisibles.firstWhere(
                      (p) => p.id == value,
                      orElse: () => programacionesVisibles.first,
                    );
                    setState(() {
                      _programacionSeleccionada = seleccionada;
                      _ajustarAcompanantesPorCupo();
                    });
                  },
          ),
        if (!tieneActivas) ...[
          const SizedBox(height: 8),
          const Text(
            'No hay programaciones activas con cupos. Las desactivadas aparecen en gris.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
        if (_programacionSeleccionada != null) ...[
          const SizedBox(height: 12),
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
      ],
    );
  }

  Widget _buildSeccionReservaPersonalizada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reserva personalizada de ruta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Se enviara una solicitud al administrador para aprobar la salida.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _idRutaSeleccionada,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: context
              .read<CatalogoProvider>()
              .rutas
              .map<DropdownMenuItem<int>>((map) {
                final idRaw = map['id_ruta'] ?? map['id'];
                final id = idRaw is int
                    ? idRaw
                    : int.tryParse(idRaw?.toString() ?? '') ?? 0;
                final nombre = (map['nombre'] ?? 'Item').toString();
                return DropdownMenuItem<int>(value: id, child: Text(nombre));
              })
              .toList(),
          onChanged: _cargando
              ? null
              : (v) => setState(() => _idRutaSeleccionada = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickFechaPersonalizada,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _fechaPersonalizada == null
                      ? 'Seleccionar fecha'
                      : _fechaPersonalizada!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickHoraPersonalizada,
                icon: const Icon(Icons.schedule),
                label: Text(
                  _horaPersonalizada == null
                      ? 'Seleccionar hora'
                      : _horaPersonalizada!.format(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Nota: esta reserva es directa y no pasa por programación.'),
      ],
    );
  }

  Widget _buildSeccionCantidad() {
    final maxPersonas = _maxPersonas();
    final maxAcompanantes = _maxAcompanantes();
    _syncCantidadPersonas();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad de Personas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$_cantidadPersonas',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Máximo disponible: $maxPersonas personas (acompañantes: $maxAcompanantes)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        const Text(
          'La cantidad se calcula automaticamente: titular + acompañantes.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSeccionAcompanantes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acompañantes (se guardarán en Observaciones)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Esta informacion es crucial para la obtencion de polizas de seguro.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Número de acompañantes:'),
            const SizedBox(width: 12),
            IconButton(
              onPressed: _cargando || _numeroAcompanantes <= 0
                  ? null
                  : () {
                      setState(() {
                        _numeroAcompanantes--;
                        if (_nombreAcompCtrls.isNotEmpty)
                          _nombreAcompCtrls.removeLast().dispose();
                        if (_cedulaAcompCtrls.isNotEmpty)
                          _cedulaAcompCtrls.removeLast().dispose();
                        _syncCantidadPersonas();
                      });
                    },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_numeroAcompanantes'),
            IconButton(
              onPressed: _cargando
                  ? null
                  : () {
                      final maxAcompanantes = _maxAcompanantes();
                      if (_numeroAcompanantes >= maxAcompanantes) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Maximo de acompañantes: $maxAcompanantes',
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() {
                        _numeroAcompanantes++;
                        _nombreAcompCtrls.add(TextEditingController());
                        _cedulaAcompCtrls.add(TextEditingController());
                        _syncCantidadPersonas();
                      });
                    },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_numeroAcompanantes == 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('No hay acompañantes definidos'),
          )
        else
          Column(
            children: List.generate(_numeroAcompanantes, (i) {
              final nombreCtrl = _nombreAcompCtrls.length > i
                  ? _nombreAcompCtrls[i]
                  : TextEditingController();
              final cedulaCtrl = _cedulaAcompCtrls.length > i
                  ? _cedulaAcompCtrls[i]
                  : TextEditingController();
              if (_nombreAcompCtrls.length <= i)
                _nombreAcompCtrls.add(nombreCtrl);
              if (_cedulaAcompCtrls.length <= i)
                _cedulaAcompCtrls.add(cedulaCtrl);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: nombreCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nombre completo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: cedulaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Cédula',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  void _showAgregarAcompananteDialog() {
    final nombreCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo acompañante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            TextField(
              controller: cedulaCtrl,
              decoration: const InputDecoration(labelText: 'Número documento'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = nombreCtrl.text.trim();
              final cedula = cedulaCtrl.text.trim();
              if (nombre.isEmpty || cedula.isEmpty) return;
              setState(() {
                final maxAcompanantes = _maxAcompanantes();
                if (_numeroAcompanantes >= maxAcompanantes) {
                  return;
                }
                // Mantener lista histórica y sincronizar con los controllers mostrados
                _acompanantes.add({'nombreCompleto': nombre, 'cedula': cedula});
                _numeroAcompanantes++;
                _nombreAcompCtrls.add(TextEditingController(text: nombre));
                _cedulaAcompCtrls.add(TextEditingController(text: cedula));
                _syncCantidadPersonas();
              });
              Navigator.of(context).pop();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
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
                selected: _usarProgramacion && !_esPersonalizada,
                onSelected: _cargando
                    ? null
                    : (selected) {
                        if (!selected) return;
                        setState(() {
                          _usarProgramacion = true;
                          _esPersonalizada = false;
                        });
                      },
              ),
              ChoiceChip(
                label: const Text('Reserva personalizada'),
                selected: !_usarProgramacion && _esPersonalizada,
                onSelected: _cargando
                    ? null
                    : (selected) {
                        if (!selected) return;
                        setState(() {
                          _usarProgramacion = false;
                          _esPersonalizada = true;
                          _seleccionarFincaDirecta = false;
                        });
                      },
              ),
              if (!_onlyRutaMode)
                ChoiceChip(
                  label: const Text('Ruta/Finca directa'),
                  selected: !_usarProgramacion && !_esPersonalizada,
                  onSelected: _cargando
                      ? null
                      : (selected) {
                          if (!selected) return;
                          setState(() {
                            _usarProgramacion = false;
                            _esPersonalizada = false;
                          });
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
            else if (rutas.isEmpty && catalogoProvider.fincas.isEmpty)
              const Text('No hay rutas ni fincas disponibles')
            else
              Column(
                children: [
                  if (!_onlyRutaMode)
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Ruta'),
                          selected: !_seleccionarFincaDirecta,
                          onSelected: (s) =>
                              setState(() => _seleccionarFincaDirecta = !s),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Finca'),
                          selected: _seleccionarFincaDirecta,
                          onSelected: (s) =>
                              setState(() => _seleccionarFincaDirecta = s),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _idRutaSeleccionada,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        (_onlyRutaMode
                                ? rutas
                                : (_seleccionarFincaDirecta
                                      ? catalogoProvider.fincas
                                      : rutas))
                            .whereType<Map<String, dynamic>>()
                            .map<DropdownMenuItem<int>>((map) {
                              final idRaw =
                                  (_onlyRutaMode || !_seleccionarFincaDirecta)
                                  ? (map['id_ruta'] ?? map['id'])
                                  : (map['id_finca'] ?? map['id']);
                              final id = idRaw is int
                                  ? idRaw
                                  : int.tryParse(idRaw?.toString() ?? '') ?? 0;
                              final nombre = (map['nombre'] ?? 'Item')
                                  .toString();
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(nombre),
                              );
                            })
                            .where(
                              (item) => item.value != null && item.value! > 0,
                            )
                            .toList(),
                    onChanged: _cargando
                        ? null
                        : (value) {
                            setState(() => _idRutaSeleccionada = value);
                          },
                  ),
                ],
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
            onPressed:
                _cargando ||
                    (_usarProgramacion && _programacionSeleccionada == null) ||
                    (!_usarProgramacion && _idRutaSeleccionada == null) ||
                    (_esPersonalizada &&
                        (_fechaPersonalizada == null ||
                            _horaPersonalizada == null))
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
                : Text(
                    _esPersonalizada ? 'Enviar solicitud' : 'Confirmar Reserva',
                  ),
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
                  color: cantidad > 0
                      ? Colors.amber.shade50
                      : Colors.grey.shade50,
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
