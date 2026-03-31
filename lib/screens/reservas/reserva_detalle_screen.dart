import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reserva.dart';
import '../../providers/reserva_provider.dart';

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar detalle: $e';
          _cargando = false;
        });
      }
    }
  }

  void _mostrarConfirmacionCancelacion() {
    if (_reserva == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta reserva? Esta acción no puede revertirse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelarReserva();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarReserva() async {
    if (_reserva == null) return;

    setState(() {
      _cancelando = true;
    });

    try {
      await context
          .read<ReservaProvider>()
          .cancelarReserva(_reserva!.id);

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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
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
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade300,
              ),
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

            /// OBSERVACIONES
            if (reserva.observaciones != null &&
                reserva.observaciones!.isNotEmpty)
              _buildSeccionObservaciones(reserva),

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
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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
        if (reserva.acompanantes != null && (reserva.acompanantes as List).isNotEmpty)
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
              const Text(
                'Cantidad',
                style: TextStyle(color: Colors.grey),
              ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildSeccionPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información de Pago',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildFilaDetalle(
          'Estado de Pago',
          (_reserva?.estadoPago ?? 'N/A').toUpperCase(),
          Icons.payment,
          colors: _getEstadoPagoColor(_reserva?.estadoPago),
        ),
        _buildFilaDetalle(
          'Método',
          _capitalizarPrimer(_reserva?.metodoPago ?? 'N/A'),
          Icons.credit_card,
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
        if (puedeEditar && puedesCancelar)
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
      'dic'
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  int _calcularDias(DateTime? desde, DateTime? hasta) {
    if (desde == null || hasta == null) return 0;
    return hasta.difference(desde).inDays;
  }

  String _capitalizarPrimer(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
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

  Color _getEstadoPagoColor(String? estado) {
    switch ((estado ?? '').toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'pagada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
