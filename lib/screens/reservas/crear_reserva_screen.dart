import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/programacion.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/programacion_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/servicio_provider.dart';
import '../../services/reserva_service.dart';
import '../../services/programacion_service.dart';
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
  late ProgramacionService _programacionService;
  int _cantidadPersonas = 1;
  String _metodoPago = 'transferencia';
  List<int> _serviciosSeleccionados = [];
  final List<Map<String, String>> _acompanantes = [];
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
  Set<String> _fechasOcupadas = {};
  bool _cargandoFechasOcupadas = false;
  String? _errorFechasOcupadas;
  DateTime _focusedCalendarDay = DateTime.now();

  bool _proveedoresCapturados = false;
  late ReservaProvider _reservaProvider;
  late ServicioProvider _servicioProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_proveedoresCapturados) return;
    _proveedoresCapturados = true;
    _reservaProvider = context.read<ReservaProvider>();
    _servicioProvider = context.read<ServicioProvider>();
  }

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
    _cantidadPersonas = 1 + _acompanantes.length;
  }

  void _ajustarAcompanantesPorCupo() {
    final maxAcompanantes = _maxAcompanantes();
    if (_acompanantes.length > maxAcompanantes) {
      _acompanantes.removeRange(maxAcompanantes, _acompanantes.length);
    }
    _syncCantidadPersonas();
  }

  /// Formato HH:mm para el backend (no usa [BuildContext]; seguro tras `await`).
  String _horaDeseadaApi(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    _reservaService = ReservaService();
    _solicitudService = SolicitudService();
    _programacionService = ProgramacionService();
    _programacionSeleccionada = widget.programacion;
    _idRutaSeleccionada = widget.idRuta;

    // FIX 2: Si se abrió con una ruta pero sin programación, auto-seleccionar
    // el tab "Reserva personalizada" para evitar mostrar un tab vacío.
    final tieneProgFija =
        widget.idProgramacion != null || widget.programacion != null;
    _usarProgramacion = tieneProgFija;
    _esPersonalizada = !tieneProgFija && widget.idRuta != null;

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

    void cargarProgramacion() {
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
      cargarProgramacion();
      context.read<CatalogoProvider>().fetchRutas();
      if (!_onlyRutaMode) {
        context.read<CatalogoProvider>().fetchFincas();
      }
      try {
        context.read<ProgramacionProvider>().cargarProgramaciones();
        // Cargar servicios según el modo
        final servicioProvider = context.read<ServicioProvider>();
        if (_onlyRutaMode) {
          servicioProvider.cargarServiciosPorTipo('ruta');
        } else {
          // Podrías querer un comportamiento por defecto o diferente aquí
          servicioProvider.cargarServicios();
        }
      } catch (_) {}

      if (_esPersonalizada && _idRutaSeleccionada != null) {
        _cargarFechasOcupadas(_idRutaSeleccionada!);
      }
    });
  }

  Future<void> _pickHoraPersonalizada() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) setState(() => _horaPersonalizada = hora);
  }

  DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  String _dayKey(DateTime day) {
    return DateFormat('yyyy-MM-dd').format(_normalizeDay(day));
  }

  int _duracionDiasRuta() {
    if (_idRutaSeleccionada == null) return 1;
    final ruta = context.read<CatalogoProvider>().getRutaById(
      _idRutaSeleccionada!,
    );
    if (ruta is Map<String, dynamic>) {
      final raw =
          ruta['duracion'] ?? ruta['duracion_dias'] ?? ruta['duracionDias'];
      final valor = raw is num
          ? raw.toDouble()
          : double.tryParse(raw?.toString() ?? '');
      final dias = (valor ?? 1).ceil();
      return dias < 1 ? 1 : dias;
    }
    return 1;
  }

  bool _esDiaPasado(DateTime day) {
    final today = _normalizeDay(DateTime.now());
    return _normalizeDay(day).isBefore(today);
  }

  bool _esDiaOcupado(DateTime day) {
    return _fechasOcupadas.contains(_dayKey(day));
  }

  bool _esRangoBloqueado(DateTime start) {
    final duracion = _duracionDiasRuta();
    for (var offset = 0; offset < duracion; offset++) {
      final day = _normalizeDay(start.add(Duration(days: offset)));
      if (_fechasOcupadas.contains(_dayKey(day))) {
        return true;
      }
    }
    return false;
  }

  bool _esDiaDeshabilitado(DateTime day) {
    return _esDiaPasado(day) || _esRangoBloqueado(day);
  }

  Future<void> _cargarFechasOcupadas(int idRuta) async {
    setState(() {
      _cargandoFechasOcupadas = true;
      _errorFechasOcupadas = null;
      _fechasOcupadas = {};
    });

    try {
      final fechas = await _programacionService.getFechasOcupadasPorRuta(
        idRuta,
      );
      if (!mounted) return;
      setState(() {
        _fechasOcupadas = fechas;
        _cargandoFechasOcupadas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoFechasOcupadas = false;
        _errorFechasOcupadas = 'No se pudieron cargar las fechas ocupadas.';
      });
    }
  }

  void _onRutaSeleccionada(int? value) {
    setState(() {
      _idRutaSeleccionada = value;
      _fechaPersonalizada = null;
    });

    if (_esPersonalizada && value != null && value > 0) {
      _cargarFechasOcupadas(value);
    }
  }

  Widget _buildLegendItem(
    Color color,
    String label, {
    bool bordered = false,
    bool strike = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: bordered ? Border.all(color: Colors.grey.shade500) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            decoration: strike ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final isPast = _esDiaPasado(day);
    final isReserved = _esDiaOcupado(day);
    final isRangeBlocked = !isReserved && _esRangoBloqueado(day);
    final theme = Theme.of(context);

    Color background = Colors.transparent;
    Color textColor = Colors.black87;
    Border? border;
    TextDecoration? decoration;
    FontWeight fontWeight = FontWeight.normal;

    if (isSelected) {
      background = theme.colorScheme.primary;
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
    } else if (isReserved) {
      background = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
      border = Border.all(color: Colors.grey.shade500);
      decoration = TextDecoration.lineThrough;
    } else if (isPast) {
      background = Colors.grey.shade200;
      textColor = Colors.grey.shade500;
      decoration = TextDecoration.lineThrough;
    } else if (isRangeBlocked) {
      background = Colors.grey.shade100;
      textColor = Colors.grey.shade400;
      border = Border.all(color: Colors.grey.shade300);
    }

    if (isOutside) {
      textColor = textColor.withOpacity(0.4);
    }

    if (isToday && !isSelected && !isReserved) {
      border ??= Border.all(color: theme.colorScheme.primary);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          decoration: decoration,
          fontWeight: fontWeight,
        ),
      ),
    );
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
        if (!mounted) return;
        idCliente = clienteProvider.cliente?.id;
      }
    }

    if (!mounted) return;

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

    // Validar acompañantes: todos deben tener nombre y documento
    for (final acompanante in _acompanantes) {
      final nombre = (acompanante['nombre'] ?? '').trim();
      final cedula = (acompanante['numero_documento'] ?? '').trim();
      if (nombre.isEmpty || cedula.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Completa nombre y documento de todos los acompañantes',
            ),
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
      // Si es reserva personalizada, incluir fecha/hora en observaciones
      String personalizadaText = '';
      if (_esPersonalizada &&
          _fechaPersonalizada != null &&
          _horaPersonalizada != null) {
        personalizadaText =
            'Fecha deseada: ${_fechaPersonalizada!.toLocal().toString().split(' ')[0]} ${_horaPersonalizada != null ? _horaDeseadaApi(_horaPersonalizada!) : ''}';
      }

      final observacionesBase = _observacionesController.text.trim();
      final bufferParts = <String>[];
      if (observacionesBase.isNotEmpty) bufferParts.add(observacionesBase);
      if (personalizadaText.isNotEmpty) bufferParts.add(personalizadaText);

      final observacionesFinal = bufferParts.join('\n');

      final acompanantesPayload = _acompanantes.map((acompanante) {
        final nombre = (acompanante['nombre'] ?? '').trim();
        final cedula = (acompanante['numero_documento'] ?? '').trim();
        return {'nombre_completo': nombre, 'numero_documento': cedula};
      }).toList();

      if (_esPersonalizada) {
        // Crear solicitud de reserva personalizada
        await _solicitudService.crear({
          'id_cliente': idCliente,
          'id_ruta': _idRutaSeleccionada!,
          'cantidad_personas': _cantidadPersonas,
          'fecha_salida': _fechaPersonalizada!
              .toIso8601String()
              .split('T')
              .first, // YYYY-MM-DD
          'hora_salida': _horaDeseadaApi(_horaPersonalizada!), // HH:MM
          'observaciones': observacionesFinal,
          'acompanantes': acompanantesPayload,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Solicitud de reserva enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Crear reserva normal
        final reservaCreada = await _reservaService.crear(
          idCliente: idCliente,
          idProgramacion: _programacionSeleccionada?.id,
          idRuta: _idRutaSeleccionada,
          cantidadPersonas: _cantidadPersonas,
          metodoPago: _metodoPago,
          observaciones: observacionesFinal,
          acompanantes: acompanantesPayload,
        );

        // **FASE 2: Asociar servicios después de crear la reserva**
        if (reservaCreada.id > 0 && _serviciosSeleccionados.isNotEmpty) {
          try {
            await _reservaService.asociarServicios(
              idReserva: reservaCreada.id,
              idServicios: _serviciosSeleccionados,
            );
            // Opcional: mostrar un mensaje si la asociación es exitosa
          } catch (e) {
            // La reserva base se creó, pero falló la asociación de servicios.
            // Se podría mostrar un mensaje no bloqueante.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Reserva creada, pero no se pudieron añadir los servicios: $e',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva creada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
      final clienteId = context.read<ClienteProvider>().cliente?.id;
      if (clienteId != null) {
        _reservaProvider.cargarReservas(idCliente: clienteId);
      }
      context.go('/home');
    } catch (e) {
      if (mounted) {
        // FIX 3: Extraer mensaje legible del error del backend
        String mensajeError = 'Ocurrió un error al enviar la solicitud. Intenta de nuevo.';
        final eStr = e.toString();

        // Intentar parsear DioException con respuesta JSON del backend
        try {
          final dioMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(eStr);
          if (dioMatch != null) {
            // Si el toString del error embebe JSON, intentar leerlo
            final jsonStr = dioMatch.group(0)!;
            // Buscar campo message o error en el string
            final msgMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(jsonStr);
            final errMatch = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(jsonStr);
            if (msgMatch != null) {
              mensajeError = msgMatch.group(1)!;
            } else if (errMatch != null) {
              mensajeError = errMatch.group(1)!;
            }
          } else if (eStr.contains('Campos incompletos')) {
            mensajeError = 'Por favor selecciona una fecha y ruta para la reserva personalizada.';
          } else if (eStr.contains('SocketException') || eStr.contains('Connection refused')) {
            mensajeError = 'No se pudo conectar al servidor. Verifica tu conexión.';
          } else if (eStr.isNotEmpty) {
            // Limpiar el prefijo "Exception: " del mensaje
            mensajeError = eStr.replaceAll('Exception: ', '');
          }
        } catch (_) {
          // Si el parseo falla, usar mensaje genérico
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(mensajeError)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
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
          final syncProgramacion = progProvider.programacionSeleccionada;
          if (_programacionSeleccionada == null && syncProgramacion != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (_programacionSeleccionada == null) {
                setState(() => _programacionSeleccionada = syncProgramacion);
              }
            });
          }

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

                /// SECCIÓN 1.5: Recomendaciones
                _buildSeccionRecomendaciones(),
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

                /// SECCIÓN 7: Aviso política de reserva
                _buildAvisoPolitica(),
                const SizedBox(height: 16),

                /// SECCIÓN 8: Botones
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
          onChanged: _cargando ? null : _onRutaSeleccionada,
        ),
        const SizedBox(height: 12),
        if (_idRutaSeleccionada == null)
          const Text(
            'Selecciona una ruta para cargar el calendario de disponibilidad.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          )
        else ...[
          if (_cargandoFechasOcupadas)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Cargando disponibilidad...'),
                ],
              ),
            ),
          if (_errorFechasOcupadas != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'No se pudieron cargar las reservas. Puedes elegir una fecha, pero confirma con soporte.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
              ),
            ),
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
            focusedDay: _focusedCalendarDay,
            selectedDayPredicate: (day) =>
                _fechaPersonalizada != null &&
                isSameDay(_fechaPersonalizada, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (_esDiaDeshabilitado(selectedDay)) return;
              setState(() {
                _fechaPersonalizada = selectedDay;
                _focusedCalendarDay = focusedDay;
              });
            },
            enabledDayPredicate: (day) => !_esDiaDeshabilitado(day),
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day),
              todayBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day, isToday: true),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day, isSelected: true),
              disabledBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day),
              outsideBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day, isOutside: true),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegendItem(Colors.green.shade400, 'Disponible'),
              _buildLegendItem(Colors.grey.shade200, 'Pasado', strike: true),
              _buildLegendItem(
                Colors.grey.shade300,
                'Día reservado/ocupado',
                bordered: true,
                strike: true,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Nota: otros días pueden verse deshabilitados porque el viaje de ${_duracionDiasRuta()} día(s) chocaría con fechas ya ocupadas.',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
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
        ],
        const SizedBox(height: 8),
        const Text('Nota: esta reserva es directa y no pasa por programación.'),
      ],
    );
  }

  Widget _buildSeccionRecomendaciones() {
    if (_idRutaSeleccionada == null || _idRutaSeleccionada! <= 0) {
      return const SizedBox.shrink();
    }

    final ruta = context.read<CatalogoProvider>().getRutaById(
      _idRutaSeleccionada!,
    );
    if (ruta is! Map<String, dynamic>) {
      return const SizedBox.shrink();
    }

    final recomendaciones =
        (ruta['recomendaciones_participantes'] ??
                ruta['recomendacionesParticipantes'] ??
                '')
            .toString()
            .trim();

    if (recomendaciones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recomendaciones para participantes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recomendaciones,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
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
    final maxAcompanantes = _maxAcompanantes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acompañantes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Agrega los datos de cada acompañante para la póliza de seguro.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('Agregados: ${_acompanantes.length}/$maxAcompanantes'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _cargando
                  ? null
                  : () {
                      if (_acompanantes.length >= maxAcompanantes) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Maximo de acompañantes: $maxAcompanantes',
                            ),
                          ),
                        );
                        return;
                      }
                      _showAgregarAcompananteModal();
                    },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_acompanantes.isEmpty)
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
            children: List.generate(_acompanantes.length, (i) {
              final acompanante = _acompanantes[i];
              final nombre = (acompanante['nombre'] ?? '').trim();
              final apellido = (acompanante['apellido'] ?? '').trim();
              final documento = (acompanante['numero_documento'] ?? '').trim();
              final tipoDocumento = (acompanante['tipo_documento'] ?? '')
                  .trim();
              final telefono = (acompanante['telefono'] ?? '').trim();

              final titulo = apellido.isNotEmpty
                  ? '$nombre $apellido'
                  : nombre.isNotEmpty
                  ? nombre
                  : 'Acompañante sin nombre';

              final subtitulo = [
                if (tipoDocumento.isNotEmpty || documento.isNotEmpty)
                  '${tipoDocumento.isNotEmpty ? '$tipoDocumento ' : ''}$documento'
                      .trim(),
                if (telefono.isNotEmpty) 'Tel: $telefono',
              ].where((item) => item.trim().isNotEmpty).join(' • ');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (subtitulo.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                subtitulo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _cargando
                          ? null
                          : () {
                              setState(() {
                                _acompanantes.removeAt(i);
                                _syncCantidadPersonas();
                              });
                            },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  void _showAgregarAcompananteModal() {
    final nombreCtrl = TextEditingController();
    final apellidoCtrl = TextEditingController();
    final documentoCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    DateTime? fechaNacimiento;
    String? tipoDocumento = 'CC';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Agregar acompañante',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(modalContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nombreCtrl,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: const InputDecoration(labelText: 'Nombre *'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: apellidoCtrl,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                      ],
                      decoration: const InputDecoration(labelText: 'Apellido'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tipoDocumento,
                      items: const [
                        DropdownMenuItem(value: 'CC', child: Text('CC - Cédula de Ciudadanía')),
                        DropdownMenuItem(value: 'TI', child: Text('TI - Tarjeta de Identidad')),
                        DropdownMenuItem(value: 'CE', child: Text('CE - Cédula de Extranjería')),
                        DropdownMenuItem(value: 'PP', child: Text('PP - Pasaporte')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro documento')),
                      ],
                      onChanged: (value) => setModalState(() {
                        tipoDocumento = value;
                        documentoCtrl.clear(); // Limpiar al cambiar tipo
                      }),
                      decoration: const InputDecoration(
                        labelText: 'Tipo documento',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: documentoCtrl,
                      keyboardType: (tipoDocumento == 'PP' || tipoDocumento == 'Otro')
                          ? TextInputType.text
                          : TextInputType.number,
                      inputFormatters: [
                        if (tipoDocumento == 'CC' || tipoDocumento == 'TI' || tipoDocumento == 'CE')
                          FilteringTextInputFormatter.digitsOnly,
                        if (tipoDocumento == 'CC' || tipoDocumento == 'TI')
                          LengthLimitingTextInputFormatter(10)
                        else if (tipoDocumento == 'CE')
                          LengthLimitingTextInputFormatter(12)
                        else
                          LengthLimitingTextInputFormatter(15)
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Numero documento *',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: const InputDecoration(labelText: 'Telefono'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() {
                            fechaNacimiento = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        fechaNacimiento == null
                            ? 'Fecha de nacimiento'
                            : '${fechaNacimiento!.year}-${fechaNacimiento!.month.toString().padLeft(2, '0')}-${fechaNacimiento!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final nombre = nombreCtrl.text.trim();
                          final apellido = apellidoCtrl.text.trim();
                          final numeroDocumento = documentoCtrl.text.trim();
                          final telefono = telefonoCtrl.text.trim();

                          if (nombre.isEmpty || numeroDocumento.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nombre y documento son obligatorios',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _acompanantes.add({
                              'nombre': nombre,
                              'apellido': apellido,
                              'tipo_documento': tipoDocumento ?? '',
                              'numero_documento': numeroDocumento,
                              'telefono': telefono,
                              'fecha_nacimiento': fechaNacimiento == null
                                  ? ''
                                  : '${fechaNacimiento!.year}-${fechaNacimiento!.month.toString().padLeft(2, '0')}-${fechaNacimiento!.day.toString().padLeft(2, '0')}',
                            });
                            _syncCantidadPersonas();
                          });

                          Navigator.of(modalContext).pop();
                        },
                        child: const Text('Guardar acompañante'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nombreCtrl.dispose();
      apellidoCtrl.dispose();
      documentoCtrl.dispose();
      telefonoCtrl.dispose();
    });
  }

  Widget _buildSeccionPago() {
    const metodos = ['transferencia', 'efectivo'];

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
              // FIX 2: Deshabilitar tab "Ruta programada" si se entró con ruta
              // directa sin programación (solo aplica en _onlyRutaMode sin prog fija)
              ChoiceChip(
                label: const Text('Ruta programada'),
                selected: _usarProgramacion && !_esPersonalizada,
                // Deshabilitar si la pantalla fue abierta con una ruta sin prog fija
                onSelected: (_onlyRutaMode &&
                        widget.idProgramacion == null &&
                        widget.programacion == null)
                    ? null
                    : _cargando
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
                        if (_idRutaSeleccionada != null) {
                          _cargarFechasOcupadas(_idRutaSeleccionada!);
                        }
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

  Widget _buildAvisoPolitica() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
              SizedBox(width: 8),
              Text(
                'Información importante',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Al confirmar tu reserva, aseguras tu cupo en la experiencia.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 6),
          const Text(
            'Los pagos no aplican para reembolso en caso de cancelación o no asistencia. En situaciones de fuerza mayor, podremos reprogramar tu experiencia.',
            style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.phone, color: Color(0xFF92400E), size: 14),
              SizedBox(width: 6),
              Text(
                '+57 304 3898018',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDialogoConfirmacion() async {
    final aceptado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFFB45309)),
            SizedBox(width: 8),
            Text(
              'Antes de confirmar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Text(
                'Al confirmar tu reserva, aseguras tu cupo en la experiencia.\n\n'
                'Para garantizar la organización del viaje, los pagos no aplican para reembolso en caso de cancelación o no asistencia. En situaciones de fuerza mayor, podremos reprogramar tu experiencia.\n\n'
                '¿Deseas continuar?',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.phone, color: Color(0xFF92400E), size: 14),
                SizedBox(width: 6),
                Text(
                  'Dudas: +57 304 3898018',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí, confirmar'),
          ),
        ],
      ),
    );

    if (aceptado == true) {
      _crearReserva();
    }
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
                : _mostrarDialogoConfirmacion,
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
