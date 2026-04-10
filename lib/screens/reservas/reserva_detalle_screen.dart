import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/reserva.dart';
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

  final ReservaService _reservaService = ReservaService();

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  void _cargarDetalle() async {
    try {
      final provider = context.read<ReservaProvider>();
      final reserva = await provider.obtenerDetalle(widget.idReserva);
      if (mounted) {
        setState(() {
          _reserva = reserva;
          _cargando = false;
        });
      }
      await _cargarQr(reserva.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar detalle: $e';
          _cargando = false;
        });
      }
    }
  }

  Future<void> _cargarQr(int idReserva) async {
    if (!mounted) return;

    setState(() {
      _cargandoQr = true;
    });

    final url = await _reservaService.getQrReserva(idReserva);

    if (!mounted) return;
    setState(() {
      _qrUrl = url;
      _cargandoQr = false;
    });
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
      await context.read<ReservaProvider>().cancelarReserva(
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
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _reserva == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Reserva'),
          centerTitle: true,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildFilaDetalle(
          'Programación ID',
          '#${reserva.idProgramacion}',
          Icons.schedule,
        ),
      ],
    );
  }

  Widget _buildSeccionFechas(Reserva reserva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fechas de Estadía',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildFilaDetalle(
          'Entrada',
          _formatDate(reserva.fechaInicio),
          Icons.check_circle_outline,
          colors: Colors.green,
        ),
        _buildFilaDetalle(
          'Salida',
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
          '${reserva.cantidadPersonas}',
          Icons.people,
        ),
        if (reserva.acompanantes != null &&
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
                '${reserva.cantidadPersonas}',
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
                          DropdownMenuItem(value: 'QR', child: Text('QR')),
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
                                      await _reservaService
                                          .subirComprobantePago(
                                            idPago: idPago,
                                            archivo: comprobante!,
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
          if (_cargandoQr)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_qrUrl != null && _qrUrl!.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  _qrUrl!,
                  width: 210,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No fue posible cargar el QR.'),
                  ),
                ),
              ),
            )
          else
            const Text(
              'El QR de pago no esta disponible aun para esta reserva.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
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
    final puedeEditar = context.read<ReservaProvider>().puedeEditarse(reserva);
    final puedesCancelar = reserva.puedeSerCancelada;

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
