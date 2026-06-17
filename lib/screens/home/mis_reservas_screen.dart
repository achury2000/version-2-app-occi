import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/reserva.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/reserva_provider.dart';
import '../../services/reserva_service.dart';
import '../reservas/reserva_detalle_screen.dart';

/// FASE 3: GESTIÓN DE RESERVAS DEL CLIENTE
/// Funcionalidades:
/// ✅ Listar reservas
/// ✅ Buscar/Filtrar por estado y fechas
/// ✅ Ver detalle completo
/// ✅ Cancelar reserva
/// 🔄 Editar (si es posible según estado)
class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({Key? key}) : super(key: key);

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  final TextEditingController _searchController = TextEditingController();
  String _filtroEstado = '';
  bool _mostrarFiltros = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarReservas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    if (!mounted) return;

    try {
      final clienteProvider = context.read<ClienteProvider>();
      final idCliente = clienteProvider.cliente?.id;

      if (idCliente == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se encontró perfil de cliente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!mounted) return;
      final reservaProvider = context.read<ReservaProvider>();
      await reservaProvider.cargarReservas(idCliente: idCliente);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _abrirRecibo(Reserva reserva) async {
    String? url;
    if (reserva.idPagoReciente != null) {
      url = await _reservaService.obtenerUrlComprobanteFirmada(
        reserva.idPagoReciente!,
      );
    }
    url ??= reserva.comprobantePago?.trim();
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay comprobante disponible. Si subiste uno, inicia sesión de nuevo.',
          ),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enlace de comprobante no válido')),
      );
      return;
    }

    final path = url.split('?').first.toLowerCase();
    final esImagen = path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');

    if (esImagen && !kIsWeb && mounted) {
      await _mostrarComprobanteImagenEnApp(context, url);
      return;
    }

    final ok = await launchUrl(
      uri,
      mode: kIsWeb
          ? LaunchMode.externalApplication
          : LaunchMode.inAppWebView,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el comprobante')),
      );
    }
  }

  Future<void> _mostrarComprobanteImagenEnApp(
    BuildContext context,
    String imageUrl,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        final size = MediaQuery.sizeOf(ctx);
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.black,
          child: SizedBox(
            width: size.width * 0.96,
            height: size.height * 0.86,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (c, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 120,
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No se pudo cargar la imagen.',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    tooltip: 'Cerrar',
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _mostrarDetalle(int idReserva) async {
    if (!mounted) return;

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReservaDetalleScreen(idReserva: idReserva),
        ),
      );

      if (!mounted) return;
      await _cargarReservas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reserva #',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    reserva.id.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDate(reserva.fechaInicio)} → ${_formatDate(reserva.fechaFin)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro de eliminar esta reserva de la finca?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No se hacen reembolsos después de estar abonado o pagado en su totalidad',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Sí, eliminar reserva',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;

    try {
      await _reservaService.cancelar(reserva.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reserva eliminada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if (!mounted) return;
      await _cargarReservas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Color _colorEstado(String? estado) {
    final s = (estado ?? '').toLowerCase();
    if (s == 'confirmada' || s == 'activa') return Colors.green;
    if (s == 'cancelada') return Colors.red;
    if (s == 'pendiente') return Colors.orange;
    return Colors.blueGrey;
  }

  String _iconoEstado(String? estado) {
    final s = (estado ?? '').toLowerCase();
    if (s == 'confirmada' || s == 'activa') return '✅';
    if (s == 'cancelada') return '❌';
    if (s == 'pendiente') return '⏳';
    return '📋';
  }

  Color _colorEstadoPago(String? estadoPago) {
    final s = (estadoPago ?? '').toLowerCase();
    if (s == 'pagada' || s == 'completado') return Colors.green;
    if (s == 'en verificación' || s == 'en verificacion') {
      return Colors.deepPurple;
    }
    if (s == 'rechazado') return Colors.red;
    if (s == 'en proceso' || s == 'proceso') return Colors.blue;
    if (s == 'pendiente') return Colors.orange;
    return Colors.blueGrey;
  }

  String _labelEstadoPago(String? estadoPago) {
    final s = (estadoPago ?? '').toLowerCase();
    if (s == 'pagada') return 'Pagado (confirmado)';
    if (s == 'completado') return 'Completado';
    if (s == 'en verificación' || s == 'en verificacion') {
      return 'En revisión del admin';
    }
    if (s == 'rechazado') return 'Pago rechazado';
    if (s == 'en proceso' || s == 'proceso') return 'En proceso';
    if (s == 'pendiente') return 'Pendiente de pago';
    return 'Sin dato';
  }

  bool _enRevisionAdmin(Reserva reserva) {
    final s = (reserva.estadoPago ?? '').toLowerCase();
    return s.contains('verificación') || s.contains('verificacion');
  }

  Widget _barraFiltros(ReservaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por ID o nombre...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.setBusqueda('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              provider.setBusqueda(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Botones de filtro
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _mostrarFiltros = !_mostrarFiltros);
                  },
                  icon: const Icon(Icons.filter_list),
                  label: Text(_mostrarFiltros ? 'Ocultar' : 'Mostrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (provider.filtroEstado.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    provider.limpiarFiltros();
                    setState(() => _filtroEstado = '');
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Panel de filtros
          if (_mostrarFiltros) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 Filtrar por estado',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filtroChip('Todas', _filtroEstado.isEmpty, () {
                        setState(() => _filtroEstado = '');
                        provider.setFiltroEstado('');
                      }),
                      _filtroChip(
                        'Activas',
                        _filtroEstado.toLowerCase() == 'confirmada',
                        () {
                          setState(() => _filtroEstado = 'confirmada');
                          provider.setFiltroEstado('confirmada');
                        },
                      ),
                      _filtroChip(
                        'Pendientes',
                        _filtroEstado.toLowerCase() == 'pendiente',
                        () {
                          setState(() => _filtroEstado = 'pendiente');
                          provider.setFiltroEstado('pendiente');
                        },
                      ),
                      _filtroChip(
                        'Canceladas',
                        _filtroEstado.toLowerCase() == 'cancelada',
                        () {
                          setState(() => _filtroEstado = 'cancelada');
                          provider.setFiltroEstado('cancelada');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Aviso dentro de la tarjeta cuando el comprobante espera verificación del admin.
  Widget _bannerRevisionAdminCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.shade700.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: Colors.amber.shade900,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tu comprobante está en revisión por el administrador. '
              'Cuando verifiquen el pago, el estado de tu reserva y el pago se actualizarán.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.25,
                color: Colors.brown.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String label, bool seleccionado, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: seleccionado,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF0066CC),
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Mis Reservas'),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Ir a inicio',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              context.go('/home');
            },
          ),
          IconButton(
            tooltip: 'Ir a perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              context.go('/completar-perfil');
            },
          ),
        ],
      ),
      body: Consumer<ReservaProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _cargarReservas,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 12),
                            Text(provider.error!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cargarReservas,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : !provider.tieneReservas
                ? ListView(
                    children: const [
                      SizedBox(height: 140),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Sin reservas registradas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Haz una nueva reserva para verla aquí',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _barraFiltros(provider),
                      Expanded(
                        child: provider.reservas.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'No hay reservas que coincidan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: provider.reservas.length,
                                itemBuilder: (context, index) {
                                  final reserva = provider.reservas[index];
                                  final colorEstado = _colorEstado(
                                    reserva.estado,
                                  );
                                  final iconoEstado = _iconoEstado(
                                    reserva.estado,
                                  );
                                  final colorPago = _colorEstadoPago(
                                    reserva.estadoPago,
                                  );

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    child: InkWell(
                                      onTap: () => _mostrarDetalle(reserva.id),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          iconoEstado,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          'Reserva #${reserva.id}',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      reserva.nombreExperiencia,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .teal.shade800,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${_formatDate(reserva.fechaInicio)} - ${_formatDate(reserva.fechaFin)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colorEstado
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    (reserva.estado ??
                                                            'pendiente')
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: colorEstado,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colorPago.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Pago: ${_labelEstadoPago(reserva.estadoPago)}',
                                                    style: TextStyle(
                                                      color: colorPago,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (_enRevisionAdmin(
                                              reserva,
                                            )) ...[
                                              const SizedBox(height: 10),
                                              _bannerRevisionAdminCard(),
                                            ],
                                            if (reserva.tieneComprobante) ...[
                                              const SizedBox(height: 10),
                                              _ComprobantePreviewCard(
                                                reserva: reserva,
                                                service: _reservaService,
                                                onVerCompleto: () =>
                                                    _abrirRecibo(reserva),
                                                revisionPendiente:
                                                    _enRevisionAdmin(reserva),
                                              ),
                                            ],
                                            if (reserva.montoPendienteListado !=
                                                null) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                reserva.montoPendienteListado! <=
                                                        0
                                                    ? 'Resumen: total cubierto'
                                                    : 'Saldo pendiente: \$${reserva.montoPendienteListado!.toStringAsFixed(0)} · Pagado: \$${(reserva.montoPagadoListado ?? 0).toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.people,
                                                  size: 16,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${reserva.cantidadPersonas ?? 0} persona(s)',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(
                                                  Icons.attach_money,
                                                  size: 16,
                                                  color: Colors.green.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '\$${reserva.precioTotal?.toStringAsFixed(0) ?? 'N/D'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _mostrarDetalle(
                                                          reserva.id,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.visibility,
                                                    ),
                                                    label: const Text(
                                                      'Detalles',
                                                    ),
                                                  ),
                                                ),
                                                if (reserva.tieneComprobante) ...[
                                                  const SizedBox(width: 8),
                                                  IconButton.filledTonal(
                                                    onPressed: () =>
                                                        _abrirRecibo(reserva),
                                                    icon: const Icon(
                                                      Icons.receipt_long,
                                                    ),
                                                    tooltip: 'Ver comprobante',
                                                  ),
                                                ],
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed:
                                                        reserva.estaActiva
                                                        ? () =>
                                                              _cancelarReserva(
                                                                reserva,
                                                              )
                                                        : null,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    icon: const Icon(
                                                      Icons.cancel,
                                                    ),
                                                    label: const Text(
                                                      'Cancelar',
                                                    ),
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
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

/// Miniatura del comprobante en el listado (imagen o PDF) + leyenda.
class _ComprobantePreviewCard extends StatefulWidget {
  final Reserva reserva;
  final ReservaService service;
  final VoidCallback onVerCompleto;
  final bool revisionPendiente;

  const _ComprobantePreviewCard({
    required this.reserva,
    required this.service,
    required this.onVerCompleto,
    required this.revisionPendiente,
  });

  @override
  State<_ComprobantePreviewCard> createState() =>
      _ComprobantePreviewCardState();
}

class _ComprobantePreviewCardState extends State<_ComprobantePreviewCard> {
  late final Future<String?> _futureUrl;

  @override
  void initState() {
    super.initState();
    _futureUrl = _resolverUrlVisual();
  }

  Future<String?> _resolverUrlVisual() async {
    if (widget.reserva.idPagoReciente != null) {
      final firmada = await widget.service.obtenerUrlComprobanteFirmada(
        widget.reserva.idPagoReciente!,
      );
      if (firmada != null && firmada.isNotEmpty) return firmada;
    }
    final u = widget.reserva.comprobantePago?.trim();
    return (u != null && u.isNotEmpty) ? u : null;
  }

  static bool _pareceImagen(String url) {
    final path = url.split('?').first.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  static bool _parecePdf(String url) {
    return url.split('?').first.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _futureUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 88,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final url = snapshot.data;
        if (url == null || url.isEmpty) {
          return Semantics(
            label: 'Comprobante no disponible en vista previa',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onVerCompleto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                    color: Colors.orange.shade50.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.orange.shade900,
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No se pudo obtener la vista previa. '
                          'Asegúrate de estar con sesión iniciada o abre el comprobante con el botón Recibo.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final esImagen = _pareceImagen(url);
        final esPdf = _parecePdf(url);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onVerCompleto,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
                color: Colors.teal.shade50.withValues(alpha: 0.35),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: esImagen
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _fallbackThumb(
                              context,
                              esPdf,
                            ),
                          )
                        : _fallbackThumb(context, esPdf),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 18,
                                color: Colors.teal.shade800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Comprobante adjunto',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.revisionPendiente
                                ? 'Visible solo para tu revisión; el admin lo validará pronto.'
                                : 'Toca la miniatura o este recuadro para abrir el archivo completo.',
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
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
  }

  Widget _fallbackThumb(BuildContext context, bool esPdf) {
    return ColoredBox(
      color: Colors.teal.shade100,
      child: Center(
        child: Icon(
          esPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
          size: 40,
          color: Colors.teal.shade800,
        ),
      ),
    );
  }
}
