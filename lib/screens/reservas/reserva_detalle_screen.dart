import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/reserva.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../services/reserva_service.dart';

class ReservaDetalleScreen extends StatefulWidget {
  final int idReserva;

  const ReservaDetalleScreen({Key? key, required this.idReserva})
    : super(key: key);

  @override
  State<ReservaDetalleScreen> createState() => _ReservaDetalleScreenState();
}

class _ReservaDetalleScreenState extends State<ReservaDetalleScreen> {
  Reserva? _reserva;
  bool _cargando = true;
  String? _error;
  bool _cancelando = false;
  bool _cargandoQr = false;
  String? _qrUrl;
  bool _procesandoPago = false;
  bool _puedeEditar = false;
  bool _cargaIniciada = false;

  // Providers capturados en didChangeDependencies — evitar context.read/
  // Provider.of tras await (assertion _dependents.isEmpty en Provider).
  late ReservaProvider _reservaProvider;
  late ClienteProvider _clienteProvider;

  final ReservaService _reservaService = ReservaService();

  /// Compatible con detalle abierto solo con GoRouter o encima de otras
  /// pantallas imperativas (ej. Home → Finca → Detalle): evita mezclar
  /// `go` con una pila `Navigator.push` en el mismo frame y asserts en framework.
  void _irAlInicioSeguro() {
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router.go('/home');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reservaProvider = Provider.of<ReservaProvider>(context, listen: false);
    _clienteProvider = Provider.of<ClienteProvider>(context, listen: false);
    if (!_cargaIniciada) {
      _cargaIniciada = true;
      _cargarDetalle();
    }
  }

  void _cargarDetalle() async {
    try {
      final reserva = await _reservaProvider.obtenerDetalle(widget.idReserva);
      if (!mounted) return;
      setState(() {
        _reserva = reserva;
        _cargando = false;
        _puedeEditar = _reservaProvider.puedeEditarse(reserva);
      });
      await _cargarQr(reserva.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar detalle: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _cargarQr(int idReserva) async {
    if (!mounted) return;

    setState(() {
      _cargandoQr = true;
    });

    final url = await _reservaService.getQrReserva(idReserva);
    final safeUrl = _normalizeQrUrl(url);

    if (!mounted) return;
    setState(() {
      _qrUrl = safeUrl;
      _cargandoQr = false;
    });
  }

  String? _normalizeQrUrl(String? url) {
    if (url == null) return null;
    // 1. Limpiamos cualquier salto de línea, espacios invisibles o retornos de carro
    final cleanUrl = url.replaceAll('\n', '').replaceAll('\r', '').trim();
    if (cleanUrl.isEmpty) return null;
    if (!cleanUrl.startsWith('http')) return null;
    if (cleanUrl.contains('/api/reservas/')) return null;
    // 2. Codificamos la URL para que Flutter soporte nombres como "descarga (1).png"
    try {
      // Uri.parse arregla automáticamente la mayoría de los problemas de formato
      return Uri.parse(cleanUrl).toString();
    } catch (e) {
      return cleanUrl;
    }
  }

  void _mostrarConfirmacionCancelacion() {
    if (_reserva == null) return;

    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Estás seguro de que deseas cancelar esta reserva?\n\nEsta acción no puede revertirse.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Motivo/Justificación (opcional):',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: motivoController,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Escribe el motivo de cancelación...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No, mantener'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cancelarReserva(motivoController.text.trim());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarReserva(String motivo) async {
    if (_reserva == null) return;

    setState(() {
      _cancelando = true;
    });

    try {
      await _reservaProvider.cancelarReserva(
        _reserva!.id,
        motivo: motivo.isNotEmpty ? motivo : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reserva cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar detalle
        _cargarDetalle();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cancelando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Reserva'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: _irAlInicioSeguro,
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _reserva == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Reserva'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: _irAlInicioSeguro,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(_error ?? 'Error desconocido'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final reserva = _reserva!;
    final estadoColor = _getEstadoColor(reserva.estado);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva #${reserva.id}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: _irAlInicioSeguro,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ENCABEZADO CON ESTADO
            _buildEncabezado(reserva, estadoColor),
            const SizedBox(height: 24),

            /// INFORMACIÓN GENERAL
            _buildSeccionGeneral(reserva),
            const SizedBox(height: 20),

            /// FECHAS
            _buildSeccionFechas(reserva),
            const SizedBox(height: 20),

            /// PERSONAS
            _buildSeccionPersonas(reserva),
            const SizedBox(height: 20),

            /// PRECIO Y PAGO
            _buildSeccionPrecio(reserva),
            const SizedBox(height: 20),

            /// PAGO CON QR
            _buildSeccionPagoQr(reserva),
            const SizedBox(height: 20),

            /// SERVICIOS ADICIONALES
            if (reserva.servicios != null &&
                (reserva.servicios as List).isNotEmpty)
              _buildSeccionServicios(reserva),

            /// OBSERVACIONES
            if (reserva.observaciones != null &&
                reserva.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSeccionObservaciones(reserva),
            ],

            /// BOTONES DE ACCIÓN
            const SizedBox(height: 24),
            _buildBotonesAccion(reserva),
          ],
        ),
      ),
    );
  }

  Widget _buildEncabezado(Reserva reserva, Color estadoColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: estadoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: estadoColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reserva.nombreExperiencia,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Cliente: ${reserva.clienteNombreCompleto}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: estadoColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              (reserva.estado ?? 'N/A').toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionGeneral(Reserva reserva) {
    final esFinca = reserva.esReservaFinca;
    final filas = <Widget>[
      const Text(
        'Información General',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 12),
      _buildFilaDetalle(
        'ID Reserva',
        '#${reserva.id}',
        Icons.confirmation_number,
      ),
      _buildFilaDetalle(
        'Fecha de Reserva',
        _formatDate(reserva.fechaReserva),
        Icons.calendar_today,
      ),
    ];

    if (esFinca) {
      final nombreFinca = reserva.fincas != null && reserva.fincas!.isNotEmpty
          ? (() {
              final f = reserva.fincas!.first;
              if (f is Map) {
                final n = f['nombre_finca'] ?? f['nombre'];
                if (n != null && n.toString().trim().isNotEmpty) {
                  return n.toString().trim();
                }
              }
              return null;
            })()
          : null;
      if (nombreFinca != null) {
        filas.add(
          _buildFilaDetalle('Finca', nombreFinca, Icons.holiday_village),
        );
      }
      filas.add(
        _buildFilaDetalle('Tipo', 'Alojamiento (finca)', Icons.night_shelter),
      );
    } else {
      if (reserva.idProgramacion != null && reserva.idProgramacion! > 0) {
        filas.add(
          _buildFilaDetalle(
            'Programación ID',
            '#${reserva.idProgramacion}',
            Icons.schedule,
          ),
        );
      }
      filas.add(
        _buildFilaDetalle('Tipo', 'Salida programada (ruta)', Icons.hiking),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filas,
    );
  }

  Widget _buildSeccionFechas(Reserva reserva) {
    final titulo = reserva.esReservaFinca
        ? 'Fechas de hospedaje'
        : 'Fechas de estadía';
    final entradaLabel = reserva.esReservaFinca ? 'Check-in' : 'Entrada';
    final salidaLabel = reserva.esReservaFinca ? 'Check-out' : 'Salida';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildFilaDetalle(
          entradaLabel,
          _formatDate(reserva.fechaInicio),
          Icons.check_circle_outline,
          colors: Colors.green,
        ),
        _buildFilaDetalle(
          salidaLabel,
          _formatDate(reserva.fechaFin),
          Icons.exit_to_app,
          colors: Colors.red,
        ),
        const SizedBox(height: 8),
        _buildFilaDetalle(
          'Duración',
          '${_calcularDias(reserva.fechaInicio, reserva.fechaFin)} noche${_calcularDias(reserva.fechaInicio, reserva.fechaFin) != 1 ? 's' : ''}',
          Icons.date_range,
        ),
      ],
    );
  }

  Widget _buildSeccionPersonas(Reserva reserva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participantes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildFilaDetalle(
          'Personas',
          '${reserva.cantidadPersonasEfectiva ?? '—'}',
          Icons.people,
        ),
        if (!reserva.esReservaFinca &&
            reserva.acompanantes != null &&
            (reserva.acompanantes as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildFilaDetalle(
              'Acompañantes',
              '${(reserva.acompanantes as List).length}',
              Icons.person_add,
            ),
          ),
      ],
    );
  }

  Widget _buildSeccionPrecio(Reserva reserva) {
    if (reserva.esReservaFinca) {
      final pn = reserva.precioPorNocheFinca;
      final noches = reserva.nochesFinca;
      final subt = reserva.subtotalFinca;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pn != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Precio por noche',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '\$${pn.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (pn != null && noches != null) const SizedBox(height: 8),
            if (noches != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Noches', style: TextStyle(color: Colors.grey)),
                  Text(
                    '$noches',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if ((pn != null || noches != null) &&
                reserva.cantidadPersonasEfectiva != null)
              const SizedBox(height: 8),
            if (reserva.cantidadPersonasEfectiva != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Personas (estimado)',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${reserva.cantidadPersonasEfectiva}',
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
                  'Total hospedaje',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${(subt ?? reserva.precioTotal ?? 0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Precio por persona',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '\$${(reserva.precioPorPersona ?? 0).toStringAsFixed(2)}',
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
              const Text('Cantidad', style: TextStyle(color: Colors.grey)),
              Text(
                '${reserva.cantidadPersonasEfectiva ?? '—'}',
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
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${(reserva.precioTotal ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
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

  Future<void> _mostrarModalCompletarPago(Reserva reserva) async {
    final montoController = TextEditingController(
      text: (reserva.precioTotal ?? 0).toStringAsFixed(0),
    );
    final referenciaController = TextEditingController();
    String metodoPago = (reserva.metodoPago ?? 'Transferencia').toString();
    PlatformFile? comprobante;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                      const Text(
                        'Completar pago de reserva',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: montoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Monto a pagar',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: metodoPago,
                        decoration: const InputDecoration(
                          labelText: 'Metodo de pago',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Transferencia',
                            child: Text('Transferencia'),
                          ),
                          DropdownMenuItem(
                            value: 'Efectivo',
                            child: Text('Efectivo'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            metodoPago = value ?? 'Transferencia';
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: referenciaController,
                        decoration: const InputDecoration(
                          labelText: 'Referencia (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _procesandoPago
                            ? null
                            : () async {
                                final picked = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.custom,
                                      withData: true,
                                      allowedExtensions: const [
                                        'jpg',
                                        'jpeg',
                                        'png',
                                        'pdf',
                                      ],
                                    );
                                if (picked != null && picked.files.isNotEmpty) {
                                  setModalState(() {
                                    comprobante = picked.files.first;
                                  });
                                }
                              },
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          comprobante == null
                              ? 'Adjuntar comprobante'
                              : 'Archivo: ${comprobante!.name}',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _procesandoPago
                              ? null
                              : () async {
                                  final monto = double.tryParse(
                                    montoController.text.trim().replaceAll(
                                      ',',
                                      '.',
                                    ),
                                  );

                                  if (monto == null || monto <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Ingresa un monto valido',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _procesandoPago = true);
                                  try {
                                    final idPago = await _reservaService
                                        .registrarPagoReserva(
                                          idReserva: reserva.id,
                                          monto: monto,
                                          metodoPago: metodoPago,
                                          referencia: referenciaController.text
                                              .trim(),
                                        );

                                    if (idPago != null && comprobante != null) {
                                      final idCliente =
                                          reserva.idCliente ??
                                          _clienteProvider.cliente?.id;

                                      if (idCliente == null) {
                                        throw Exception(
                                          'No se pudo determinar el cliente para guardar el comprobante',
                                        );
                                      }

                                      await _reservaService
                                          .subirComprobantePago(
                                            idPago: idPago,
                                            archivo: comprobante!,
                                            idCliente: idCliente,
                                            idReserva: reserva.id,
                                          );
                                    }

                                    if (!mounted || !modalContext.mounted) {
                                      return;
                                    }
                                    Navigator.of(modalContext).pop();
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Pago registrado exitosamente',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _cargarDetalle();
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(
                                      this.context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'No se pudo registrar el pago: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _procesandoPago = false);
                                    }
                                  }
                                },
                          icon: _procesandoPago
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.payments_outlined),
                          label: const Text(
                            'Registrar pago y subir comprobante',
                          ),
                        ),
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
  }

  Widget _buildSeccionPagoQr(Reserva reserva) {
    final estadoPago = (reserva.estadoPago ?? 'pendiente').toLowerCase();
    final esPendiente = estadoPago == 'pendiente' || estadoPago == 'en proceso';
    final colorPago = esPendiente ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorPago.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorPago.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pago y QR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colorPago,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  estadoPago.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final Widget qrWidget;
              if (_cargandoQr) {
                qrWidget = const SizedBox(
                  width: 160,
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (_qrUrl != null && _qrUrl!.isNotEmpty) {
                qrWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _qrUrl!,
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 160,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'QR no disponible',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              } else {
                qrWidget = Container(
                  width: 160,
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'QR no disponible',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  qrWidget,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transferencia bancaria',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF7A3E00),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Banco: Bancolombia Ahorros',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Cuenta: 24015712755',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Titular: Yeison Uribe Vega',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'CC: 1.001.845.593',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _mostrarModalCompletarPago(reserva);
              },
              icon: const Icon(Icons.payments_outlined),
              label: Text(
                esPendiente ? 'Completar pago' : 'Ver estado de pago',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPago,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionServicios(Reserva reserva) {
    final servicios = reserva.servicios ?? [];

    if (servicios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios Adicionales',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: servicios.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.amber.shade200, height: 12),
            itemBuilder: (context, index) {
              final servicio = servicios[index];
              final nombre = servicio['nombre'] ?? 'Servicio sin nombre';
              final descripcion = servicio['descripcion'] ?? '';
              final precio = (servicio['precio'] as num?)?.toDouble() ?? 0.0;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+\$${precio.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionObservaciones(Reserva reserva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observaciones',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            reserva.observaciones ?? '',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBotonesAccion(Reserva reserva) {
    final puedeEditar = _puedeEditar;
    final puedesCancelar = reserva.puedeSerCancelada;
    final tieneComprobante = reserva.tieneComprobante;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (puedeEditar)
          ElevatedButton.icon(
            onPressed: () {
              context.pushNamed('editarReserva', extra: reserva).then((
                resultado,
              ) {
                if (resultado == true && mounted) {
                  _cargarDetalle();
                }
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Editar Reserva'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        if (puedeEditar && puedesCancelar) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _cancelando ? null : _mostrarConfirmacionCancelacion,
            icon: _cancelando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.cancel),
            label: const Text('Cancelar Reserva'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
        if (puedeEditar) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.pushNamed('gestionServiciosReserva', extra: reserva).then(
                (resultado) {
                  if (resultado == true && mounted) {
                    _cargarDetalle();
                  }
                },
              );
            },
            icon: const Icon(Icons.miscellaneous_services),
            label: const Text('Gestionar Servicios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (!tieneComprobante) ...[
          ElevatedButton.icon(
            onPressed: () {
              _mostrarModalCompletarPago(reserva);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir Comprobante'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (tieneComprobante) ...[
          ElevatedButton.icon(
            onPressed: () {
              context.pushNamed('comprobanteReserva', extra: reserva);
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Ver Comprobante'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Volver'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilaDetalle(
    String label,
    String value,
    IconData icon, {
    Color? colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    const monthNames = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  int _calcularDias(DateTime? desde, DateTime? hasta) {
    if (desde == null || hasta == null) return 0;
    return hasta.difference(desde).inDays;
  }

  Color _getEstadoColor(String? estado) {
    switch ((estado ?? '').toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
      case 'activa':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
