import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/cliente_provider.dart';
import '../../models/servicio.dart';
import '../../services/servicio_service.dart';
import '../../services/reserva_service.dart';
import '../../services/finca_service.dart';
import '../reservas/reserva_detalle_screen.dart';

class FincaDetailScreen extends StatefulWidget {
  final dynamic finca;

  const FincaDetailScreen({Key? key, required this.finca}) : super(key: key);

  @override
  State<FincaDetailScreen> createState() => _FincaDetailScreenState();
}

class _FincaDetailScreenState extends State<FincaDetailScreen> {
  int _selectedImageIndex = 0;
  late final PageController _pageController;
  final ReservaService _reservaService = ReservaService();
  final FincaService _fincaService = FincaService();
  final ServicioService _servicioService = ServicioService();

  late List<String> _images;

  /// Formatea precio con puntos como separador de miles (estilo colombiano)
  /// Ej: 250000 → $250.000
  String _formatPrice(num value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
      count++;
    }
    return '\$${buffer.toString().split('').reversed.join()}';
  }

  int _fincaId() {
    if (widget.finca is Map) {
      final id = widget.finca['id'] ?? widget.finca['id_finca'];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String _fincaImagePrincipal() {
    if (widget.finca is Map) {
      return (widget.finca['imagen_principal'] ?? widget.finca['imagen'] ?? '')
          .toString();
    }
    return '';
  }

  Future<void> _loadFincaImages() async {
    final idFinca = _fincaId();
    final urls = idFinca > 0
        ? await _fincaService.getImagenes(idFinca)
        : <String>[];

    if (!mounted) return;

    if (urls.isNotEmpty) {
      setState(() => _images = urls);
      return;
    }

    final principal = _fincaImagePrincipal();
    if (principal.isNotEmpty && principal.startsWith('http')) {
      setState(() => _images = [principal]);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _images = [];
    _loadFincaImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatUiDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  String _dayKey(DateTime day) {
    final normalized = _normalizeDay(day);
    final y = normalized.year.toString().padLeft(4, '0');
    final m = normalized.month.toString().padLeft(2, '0');
    final d = normalized.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _isPastDay(DateTime day) {
    final today = _normalizeDay(DateTime.now());
    return _normalizeDay(day).isBefore(today);
  }

  bool _rangeHasReserved(DateTime start, DateTime end, Set<String> reserved) {
    var current = _normalizeDay(start);
    final last = _normalizeDay(end);
    while (!current.isAfter(last)) {
      if (reserved.contains(_dayKey(current))) return true;
      current = current.add(const Duration(days: 1));
    }
    return false;
  }

  /// Mostrar confirmación antes de agregar un servicio (para uso en modal)
  Future<bool?> _mostrarConfirmacionAgregarServicioEnModal(
    String nombreServicio,
    double precio,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('➕ Agregar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicio a agregar:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombreServicio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Precio: ${_formatPrice((precio is num ? precio : num.tryParse(precio.toString()) ?? 0))}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5016),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro de agregar este servicio a tu reserva?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5016),
            ),
            child: const Text(
              'Sí, agregar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar confirmación antes de quitar un servicio (para uso en modal)
  Future<bool?> _mostrarConfirmacionQuitarServicioEnModal(
    String nombreServicio,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Quitar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicio a quitar:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombreServicio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro de quitar este servicio de tu reserva?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sí, quitar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReservaForm(ClienteProvider clienteProvider) async {
    if (!clienteProvider.perfilCompleto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Debes completar tu perfil antes de hacer reservas'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final idCliente = clienteProvider.cliente?.id;
    if (idCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se encontró el perfil de cliente para reservar'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final nombre = (widget.finca['nombre'] ?? 'Finca').toString();
    final capacidad = (widget.finca['capacidad_personas'] ?? 1) as int;
    final precio = (widget.finca['precio_por_noche'] ?? 0).toDouble();
    final notasController = TextEditingController();
    final personalizadosController = TextEditingController();
    final fincaId = _fincaId();

    DateTime? fechaInicio;
    DateTime? fechaFin;
    int cantidadPersonas = 1;
    bool isSaving = false;
    final Set<int> serviciosSeleccionados = {};
    List<Servicio> serviciosDisponiblesModal = [];
    bool serviciosModalLoading = false;
    String? serviciosModalError;
    final Set<String> fechasOcupadas = {};
    bool isLoadingFechas = false;
    String? errorFechas;
    bool fechasInicializadas = false;
    DateTime focusedDay = DateTime.now();
    RangeSelectionMode rangeSelectionMode = RangeSelectionMode.toggledOn;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void safeSetModalState(VoidCallback fn) {
              if (!context.mounted) return;
              setModalState(fn);
            }

            if (!fechasInicializadas) {
              fechasInicializadas = true;
              Future.microtask(() async {
                if (fincaId <= 0) {
                  errorFechas = 'No se pudo determinar la finca.';
                  safeSetModalState(() {});
                  return;
                }
                safeSetModalState(() {
                  isLoadingFechas = true;
                  errorFechas = null;
                });
                try {
                  final fechas = await _fincaService.getFechasOcupadas(fincaId);
                  fechasOcupadas
                    ..clear()
                    ..addAll(fechas);
                } catch (_) {
                  errorFechas = 'No se pudieron cargar las fechas ocupadas.';
                } finally {
                  safeSetModalState(() {
                    isLoadingFechas = false;
                  });
                }
              });
            }
            final noches =
                (fechaInicio != null &&
                    fechaFin != null &&
                    fechaFin!.isAfter(fechaInicio!))
                ? fechaFin!.difference(fechaInicio!).inDays
                : 0;
            final total = precio * noches;
            bool isReservedDay(DateTime day) =>
                fechasOcupadas.contains(_dayKey(day));
            bool isDisabledDay(DateTime day) =>
                _isPastDay(day) || isReservedDay(day);
            final theme = Theme.of(context);

            Widget buildCalendarCell(
              DateTime day, {
              bool isSelected = false,
              bool isToday = false,
              bool isOutside = false,
            }) {
              final isPast = _isPastDay(day);
              final isReserved = isReservedDay(day);
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

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Reservar finca',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Cupos máximos: $capacidad personas'),
                            const SizedBox(height: 6),
                            Text(
                              'Precio por noche: ${_formatPrice(precio)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fechas de estadía *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingFechas)
                        Row(
                          children: const [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Cargando disponibilidad...'),
                          ],
                        )
                      else if (errorFechas != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            'No se pudieron cargar las reservas. Puedes elegir fechas, pero confirma con soporte.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      TableCalendar(
                        key: ValueKey<String>('finca_reserva_cal_$fincaId'),
                        firstDay: _normalizeDay(DateTime.now()),
                        lastDay: _normalizeDay(
                          DateTime.now(),
                        ).add(const Duration(days: 730)),
                        focusedDay: focusedDay,
                        selectedDayPredicate: (day) =>
                            fechaInicio != null && isSameDay(fechaInicio, day),
                        rangeStartDay: fechaInicio,
                        rangeEndDay: fechaFin,
                        rangeSelectionMode: rangeSelectionMode,
                        enabledDayPredicate: (day) => !isDisabledDay(day),
                        onDaySelected: (selectedDay, focused) {
                          if (isDisabledDay(selectedDay)) return;
                          setModalState(() {
                            fechaInicio = selectedDay;
                            fechaFin = null;
                            focusedDay = focused;
                            rangeSelectionMode = RangeSelectionMode.toggledOn;
                          });
                        },
                        onRangeSelected: (start, end, focused) {
                          if (start == null) return;
                          if (end == null) {
                            setModalState(() {
                              fechaInicio = start;
                              fechaFin = null;
                              focusedDay = focused;
                              rangeSelectionMode = RangeSelectionMode.toggledOn;
                            });
                            return;
                          }

                          if (isDisabledDay(start) || isDisabledDay(end)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pueden seleccionar fechas pasadas o reservadas',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (_rangeHasReserved(start, end, fechasOcupadas)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'El rango seleccionado contiene fechas ocupadas',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() {
                            fechaInicio = start;
                            fechaFin = end;
                            focusedDay = focused;
                            rangeSelectionMode = RangeSelectionMode.toggledOn;
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        availableGestures: AvailableGestures.horizontalSwipe,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          rangeHighlightColor: theme.colorScheme.primary
                              .withOpacity(0.12),
                          rangeStartDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          withinRangeTextStyle: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) =>
                              buildCalendarCell(day),
                          todayBuilder: (context, day, focusedDay) =>
                              buildCalendarCell(day, isToday: true),
                          selectedBuilder: (context, day, focusedDay) =>
                              buildCalendarCell(day, isSelected: true),
                          disabledBuilder: (context, day, focusedDay) =>
                              buildCalendarCell(day),
                          outsideBuilder: (context, day, focusedDay) =>
                              buildCalendarCell(day, isOutside: true),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                fechaInicio != null
                                    ? 'Entrada: ${_formatUiDate(fechaInicio!)}'
                                    : 'Entrada: seleccionar',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                fechaFin != null
                                    ? 'Salida: ${_formatUiDate(fechaFin!)}'
                                    : 'Salida: seleccionar',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Disponible',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pasado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ocupado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Número de personas *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                isSaving || cantidadPersonas <= 1
                                ? null
                                : () => setModalState(() => cantidadPersonas--),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$cantidadPersonas',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving || cantidadPersonas >= capacidad
                                ? null
                                : () => setModalState(() => cantidadPersonas++),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      Text(
                        'Máximo $capacidad personas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Notas adicionales (opcional)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notasController,
                        enabled: !isSaving,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Solicitudes especiales, alergias, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Servicios: carga local (evita Consumer + notifyListeners al cerrar el modal).
                      ExpansionTile(
                        title: const Text(
                          'Servicios adicionales',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          serviciosSeleccionados.isEmpty
                              ? 'Ninguno seleccionado'
                              : '${serviciosSeleccionados.length} seleccionados',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onExpansionChanged: (expanded) {
                          if (!expanded ||
                              serviciosModalLoading ||
                              serviciosDisponiblesModal.isNotEmpty) {
                            return;
                          }
                          Future.microtask(() async {
                            safeSetModalState(() {
                              serviciosModalLoading = true;
                              serviciosModalError = null;
                            });
                            try {
                              final lista = await _servicioService
                                  .obtenerServiciosDisponibles();
                              if (!context.mounted) return;
                              safeSetModalState(() {
                                serviciosDisponiblesModal = lista;
                                serviciosModalLoading = false;
                              });
                            } catch (e) {
                              if (!context.mounted) return;
                              safeSetModalState(() {
                                serviciosModalError = e.toString();
                                serviciosModalLoading = false;
                              });
                            }
                          });
                        },
                        children: [
                          if (serviciosModalLoading)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: Color(0xFF2D5016),
                              ),
                            )
                          else if (serviciosModalError != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No se pudieron cargar servicios',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          else if (serviciosDisponiblesModal.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No hay servicios disponibles'),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: serviciosDisponiblesModal.map((servicio) {
                                  return CheckboxListTile(
                                    value: serviciosSeleccionados.contains(
                                      servicio.id,
                                    ),
                                    onChanged: (value) async {
                                      if (value == true) {
                                        final confirmar =
                                            await _mostrarConfirmacionAgregarServicioEnModal(
                                          servicio.nombre,
                                          servicio.precio,
                                        );
                                        if (confirmar == true) {
                                          setModalState(() {
                                            serviciosSeleccionados.add(
                                              servicio.id,
                                            );
                                          });
                                        }
                                      } else {
                                        final confirmar =
                                            await _mostrarConfirmacionQuitarServicioEnModal(
                                          servicio.nombre,
                                        );
                                        if (confirmar == true) {
                                          setModalState(() {
                                            serviciosSeleccionados.remove(
                                              servicio.id,
                                            );
                                          });
                                        }
                                      }
                                    },
                                    title: Text(servicio.nombre),
                                    subtitle: Text(
                                      '${_formatPrice(servicio.precio)}',
                                      style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                      // Sección de Espacios
                      Builder(
                        builder: (context) {
                          // Extraer zonas_comunes de la finca
                          final List<String> zonasComunes = [];
                          if (widget.finca is Map) {
                            final zonas = widget.finca['zonas_comunes'];
                            if (zonas is List) {
                              zonasComunes.addAll(
                                zonas.map((z) => z.toString()),
                              );
                            }
                          }

                          return ExpansionTile(
                            title: const Text(
                              'Espacios',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              zonasComunes.isEmpty
                                  ? 'Sin información'
                                  : '${zonasComunes.length} disponibles',
                              style: TextStyle(fontSize: 12),
                            ),
                            children: [
                              if (zonasComunes.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'No hay información de espacios disponibles',
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: zonasComunes.map((zona) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2D5016),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                zona,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      // Sección de Opciones Personalizadas
                      ExpansionTile(
                        title: const Text(
                          'Opciones personalizadas',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          personalizadosController.text.isEmpty
                              ? 'Sin opciones'
                              : '${personalizadosController.text.split('\n').length} opciones',
                          style: TextStyle(fontSize: 12),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: TextField(
                              controller: personalizadosController,
                              enabled: !isSaving,
                              maxLines: 3,
                              minLines: 2,
                              decoration: InputDecoration(
                                hintText:
                                    'Ej: Decoración especial, música en vivo\n(Una por línea)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resumen de Reserva',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Precio por noche: ${_formatPrice(precio)}',
                            ),
                            Text('Noches: $noches'),
                            Text('Número de personas: $cantidadPersonas'),
                            const Divider(),
                            Text(
                              'Total estimado: ${_formatPrice(total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Banner de política de reserva
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.info_outline, color: Color(0xFFB45309), size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Información importante',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Al confirmar tu reserva, aseguras tu cupo en la experiencia. Los pagos no aplican para reembolso en caso de cancelación o no asistencia.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF4B5563), height: 1.5),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: const [
                                Icon(Icons.phone, color: Color(0xFF92400E), size: 12),
                                SizedBox(width: 4),
                                Text(
                                  '+57 304 3898018',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (fechaInicio == null ||
                                          fechaFin == null) {
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Selecciona fecha de entrada y salida',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      // Diálogo de política antes de confirmar
                                      final aceptado = await showDialog<bool>(
                                        context: this.context,
                                        barrierDismissible: false,
                                        builder: (ctx) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Row(
                                            children: const [
                                              Icon(Icons.info_outline, color: Color(0xFFB45309)),
                                              SizedBox(width: 8),
                                              Text('Antes de confirmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          content: Container(
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
                                              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.6),
                                            ),
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
                                      if (aceptado != true) return;

                                      if (_isPastDay(fechaInicio!) ||
                                          _isPastDay(fechaFin!)) {
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'No se pueden reservar fechas pasadas',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (_rangeHasReserved(
                                        fechaInicio!,
                                        fechaFin!,
                                        fechasOcupadas,
                                      )) {
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'El rango seleccionado tiene fechas ocupadas',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (fechaFin!.isBefore(fechaInicio!)) {
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'La fecha de salida debe ser al menos un día después de la entrada',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (!fechaFin!.isAfter(fechaInicio!)) {
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'La reserva debe ser de mínimo 1 noche',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => isSaving = true);
                                      var cierreModalPorExito = false;
                                      try {
                                        if (fincaId <= 0) {
                                          throw Exception(
                                            'ID de finca inválido',
                                          );
                                        }

                                        // Construir observaciones con todos los datos
                                        String observaciones =
                                            'Finca: $nombre | Personas: $cantidadPersonas';

                                        if (notasController.text
                                            .trim()
                                            .isNotEmpty) {
                                          observaciones +=
                                              ' | Notas: ${notasController.text.trim()}';
                                        }

                                        if (serviciosSeleccionados.isNotEmpty) {
                                          observaciones +=
                                              ' | Servicios: ${serviciosSeleccionados.join(',')}';
                                        }

                                        if (personalizadosController.text
                                            .trim()
                                            .isNotEmpty) {
                                          observaciones +=
                                              ' | Personalizadas: ${personalizadosController.text.replaceAll('\n', ' | ')}';
                                        }

                                        final reservaBase =
                                            await _reservaService
                                                .crearBaseReserva(
                                                  idCliente: idCliente,
                                                  metodoPago: 'Transferencia',
                                                  observaciones: observaciones,
                                                );

                                        await _reservaService
                                            .agregarFincaDetalle(
                                              idReserva: reservaBase.id,
                                              idFinca: fincaId,
                                              fechaCheckin: fechaInicio!,
                                              fechaCheckout: fechaFin!,
                                              numeroNoches: noches,
                                              precioPorNoche: precio,
                                            );

                                        if (!mounted || !modalContext.mounted) {
                                          return;
                                        }
                                        final idReservaOk = reservaBase.id;
                                        Navigator.of(modalContext).pop();
                                        cierreModalPorExito = true;

                                        // Misma pila que abrió esta pantalla (Navigator.push desde Home).
                                        // No mezclar con GoRouter aquí: evita assert _dependents.isEmpty al desmontar.
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            this.context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                '✅ Reserva de finca creada correctamente',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          if (!mounted) return;
                                          Navigator.of(this.context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  ReservaDetalleScreen(
                                                idReserva: idReservaOk,
                                              ),
                                            ),
                                          );
                                        });
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '❌ No se pudo crear la reserva: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        if (!cierreModalPorExito &&
                                            modalContext.mounted) {
                                          setModalState(
                                            () => isSaving = false,
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('Confirmar Reserva'),
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
        );
      },
    );

    notasController.dispose();
    personalizadosController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Finca'),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              final router = GoRouter.of(context);
              final nav = Navigator.of(context);
              if (nav.canPop()) {
                nav.popUntil((route) => route.isFirst);
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                router.go('/home');
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería de imágenes
            _buildGallery(),

            // Título y precio
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.finca['nombre'] ?? 'Finca',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.finca['ubicacion'] ?? 'No especificado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_formatPrice((widget.finca['precio_por_noche'] ?? 0) is num ? (widget.finca['precio_por_noche'] ?? 0) : num.tryParse(widget.finca['precio_por_noche']?.toString() ?? '0') ?? 0)}/noche',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoBadge(
                        icon: Icons.people,
                        label:
                            '${widget.finca['capacidad_personas'] ?? 0} personas',
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.finca['descripcion'] ?? 'Sin descripción',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nivel 1 - Detalles de acuerdo a si es finca simple o compleja
            if (widget.finca.containsKey('primer_planta')) ...[
              _buildSectionHeader('Primera Planta'),
              _buildAmenitiesList(widget.finca['primer_planta']),
            ],

            if (widget.finca.containsKey('segunda_planta')) ...[
              _buildSectionHeader('Segunda Planta'),
              _buildAmenitiesList(widget.finca['segunda_planta']),
            ],

            if (widget.finca.containsKey('habitaciones')) ...[
              _buildSectionHeader('Habitaciones'),
              Column(
                children: (widget.finca['habitaciones'] as List).map((hab) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hab['nombre'] ?? 'Habitación',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: (hab['detalles'] as List)
                                .map(
                                  (detalle) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0066CC),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          detalle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Depósito y tarifas
            if (widget.finca.containsKey('deposito_daños') ||
                widget.finca.containsKey('tarifa_aseo')) ...[
              _buildSectionHeader('Información Adicional'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.finca.containsKey('deposito_daños'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Depósito por daños:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              _formatPrice((widget.finca['deposito_daños'] ?? 0) is num ? (widget.finca['deposito_daños'] ?? 0) : num.tryParse(widget.finca['deposito_daños']?.toString() ?? '0') ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.finca.containsKey('tarifa_aseo'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tarifa de aseo:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatPrice((widget.finca['tarifa_aseo'] ?? 0) is num ? (widget.finca['tarifa_aseo'] ?? 0) : num.tryParse(widget.finca['tarifa_aseo']?.toString() ?? '0') ?? 0),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (widget.finca.containsKey('caracteristicas_generales')) ...[
              _buildSectionHeader('Características Generales'),
              _buildAmenitiesList(widget.finca['caracteristicas_generales']),
              const SizedBox(height: 24),
            ],

            if (widget.finca.containsKey('zonas_comunes')) ...[
              _buildSectionHeader('Zonas Comunes'),
              _buildAmenitiesList(widget.finca['zonas_comunes']),
              const SizedBox(height: 24),
            ],

            // Botón Reservar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final clienteProvider = context.read<ClienteProvider>();
                    _openReservaForm(clienteProvider);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Reservar Ahora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery() {
    return Stack(
      children: [
        Container(
          height: 300,
          color: Colors.grey[300],
          child: _images.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (index) {
                    setState(() => _selectedImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      _images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 60,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Imagen no disponible',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                )
              : Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                ),
        ),
        // Indicador de foto
        if (_images.length > 1)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedImageIndex + 1}/${_images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (_images.length > 1)
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    final prev = (_selectedImageIndex - 1).clamp(
                      0,
                      _images.length - 1,
                    );
                    _pageController.animateToPage(
                      prev,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ),
        if (_images.length > 1)
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    final next = (_selectedImageIndex + 1).clamp(
                      0,
                      _images.length - 1,
                    );
                    _pageController.animateToPage(
                      next,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0066CC),
        ),
      ),
    );
  }

  Widget _buildAmenitiesList(List<String> amenities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: amenities.map((amenity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066CC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    amenity,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
