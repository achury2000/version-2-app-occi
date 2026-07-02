import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/cliente_provider.dart';
import '../../services/reserva_service.dart';
import '../../services/ruta_service.dart';

class RutaDetailScreen extends StatefulWidget {
  final dynamic ruta;

  const RutaDetailScreen({Key? key, required this.ruta}) : super(key: key);

  @override
  State<RutaDetailScreen> createState() => _RutaDetailScreenState();
}

class _RutaDetailScreenState extends State<RutaDetailScreen> {
  int _selectedImageIndex = 0;
  late List<String> _images;
  final ReservaService _reservaService = ReservaService();
  final RutaService _rutaService = RutaService();

  /// Formatea precio con puntos como separador de miles (estilo colombiano)
  /// Ej: 85000 → $85.000
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

  int _rutaId() {
    if (widget.ruta is Map) {
      final id = widget.ruta['id'] ?? widget.ruta['id_ruta'];
      if (id is int) return id;
      return int.tryParse(id?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String _rutaImagePrincipal() {
    if (widget.ruta is Map) {
      return (widget.ruta['imagen_principal'] ??
              widget.ruta['imagen_url'] ??
              '')
          .toString();
    }
    return '';
  }

  String _rutaStringValue(List<String> keys) {
    if (widget.ruta is! Map) return '';
    for (final key in keys) {
      final value = widget.ruta[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  Future<void> _loadRutaImages() async {
    final idRuta = _rutaId();
    final urls = idRuta > 0
        ? await _rutaService.getImagenes(idRuta)
        : <String>[];

    if (!mounted) return;

    if (urls.isNotEmpty) {
      setState(() => _images = urls);
      return;
    }

    final principal = _rutaImagePrincipal();
    if (principal.isNotEmpty && principal.startsWith('http')) {
      setState(() => _images = [principal]);
    }
  }

  String _formatUiDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _irACrearReservaRuta(ClienteProvider clienteProvider) async {
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

    final idRuta = _rutaId();
    if (idRuta <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No se pudo identificar la ruta seleccionada'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!mounted) return;
    await context.push('/crear-reserva?idRuta=$idRuta');
  }

  // ignore: unused_element
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

    final nombre = (widget.ruta['nombre'] ?? 'Ruta').toString();
    final capacidad = (widget.ruta['capacidad'] ?? 1) as int;
    final precioPersona = (widget.ruta['precio'] ?? 0).toDouble();
    final notasController = TextEditingController();

    DateTime? fechaInicio;
    DateTime? fechaFin;
    int cantidadPersonas = 1;
    bool isSaving = false;

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
            final total = precioPersona * cantidadPersonas;

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
                            'Reservar ruta',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(modalContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
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
                              'Precio por persona: ${_formatPrice(precioPersona)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fecha de inicio *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isSaving
                            ? null
                            : () async {
                                final tomorrow = DateTime.now().add(
                                  const Duration(days: 1),
                                );
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: tomorrow,
                                  firstDate: tomorrow,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 730),
                                  ),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    fechaInicio = picked;
                                    if (fechaFin != null &&
                                        !fechaFin!.isAfter(picked)) {
                                      fechaFin = picked.add(
                                        const Duration(days: 1),
                                      );
                                    }
                                  });
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            fechaInicio != null
                                ? _formatUiDate(fechaInicio!)
                                : 'Seleccionar fecha de inicio',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Fecha de fin *',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: isSaving
                            ? null
                            : () async {
                                final minDate = (fechaInicio ?? DateTime.now())
                                    .add(const Duration(days: 1));
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: minDate,
                                  firstDate: minDate,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 730),
                                  ),
                                );
                                if (picked != null) {
                                  setModalState(() => fechaFin = picked);
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            fechaFin != null
                                ? _formatUiDate(fechaFin!)
                                : 'Seleccionar fecha de fin',
                          ),
                        ),
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
                            onPressed: isSaving || cantidadPersonas <= 1
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
                          hintText: 'Condiciones médicas, logística, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
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
                              'Precio por persona: ${_formatPrice(precioPersona)}',
                            ),
                            Text('Número de personas: $cantidadPersonas'),
                            const Divider(),
                            Text(
                              'Total estimado: ${_formatPrice(total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                  : () => Navigator.of(modalContext).pop(),
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
                                              'Selecciona fecha de inicio y fin',
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
                                              'La reserva debe ser de mínimo 1 día',
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
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Sí, confirmar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (aceptado != true) return;

                                      setModalState(() => isSaving = true);
                                      try {
                                        // Usar el nuevo flujo: crear reserva para una programación
                                        await _reservaService.crear(
                                          idCliente: idCliente,
                                          idProgramacion:
                                              0, // TODO: Obtener de programación seleccionada
                                          cantidadPersonas: cantidadPersonas,
                                          observaciones:
                                              'Ruta: $nombre${notasController.text.trim().isNotEmpty ? ' | ${notasController.text.trim()}' : ''}',
                                        );

                                        if (!mounted || !modalContext.mounted) {
                                          return;
                                        }
                                        Navigator.of(modalContext).pop();
                                        ScaffoldMessenger.of(
                                          this.context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Reserva de ruta creada correctamente',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
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
                                        if (mounted) {
                                          setModalState(() => isSaving = false);
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
  }

  @override
  void initState() {
    super.initState();

    _images = [];
    _loadRutaImages();
  }

  @override
  Widget build(BuildContext context) {
    final recomendacionesParticipantes = _rutaStringValue([
      'recomendaciones_participantes',
      'recomendacionesParticipantes',
      'recomendaciones',
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Ruta'),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galería
            _buildGallery(),

            // Información principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ruta['nombre'] ?? 'Ruta',
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
                          widget.ruta['ubicacion'] ?? 'No especificado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Características principales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCharacteristic(
                        '⏱️',
                        '${widget.ruta['duracion']?.toString() ?? '0'}h',
                        'Duración',
                      ),
                      _buildCharacteristic(
                        '🗺️',
                        '${widget.ruta['distancia']?.toString() ?? '0'} km',
                        'Distancia',
                      ),
                      _buildCharacteristic(
                        '📈',
                        widget.ruta['dificultad'] ?? 'Moderado',
                        'Dificultad',
                      ),
                      _buildCharacteristic(
                        '👥',
                        widget.ruta['capacidad']?.toString() ?? '0',
                        'Máx personas',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '${_formatPrice((widget.ruta['precio'] ?? 0) is num ? (widget.ruta['precio'] ?? 0) : num.tryParse(widget.ruta['precio']?.toString() ?? '0') ?? 0)} por persona',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // Descripción
            _buildSection('Descripción', widget.ruta['descripcion'] ?? ''),

            if (recomendacionesParticipantes.isNotEmpty)
              _buildSection(
                'Recomendaciones para participantes',
                recomendacionesParticipantes,
              ),

            // Qué incluye
            if (widget.ruta.containsKey('incluye')) ...[
              _buildSectionHeader('¿Qué Incluye?'),
              _buildAmenitiesList(widget.ruta['incluye']),
            ],

            // Zonas de paso
            if (widget.ruta.containsKey('zonas_paso')) ...[
              _buildSectionHeader('Zonas de Paso'),
              _buildAmenitiesList(widget.ruta['zonas_paso']),
            ],

            // Equipo necesario
            if (widget.ruta.containsKey('equipo_necesario')) ...[
              _buildSectionHeader('Equipo Necesario'),
              _buildAmenitiesList(widget.ruta['equipo_necesario']),
            ],

            // Información adicional
            if (widget.ruta.containsKey('mejor_epoca') ||
                widget.ruta.containsKey('requisitos') ||
                widget.ruta.containsKey('restricciones')) ...[
              _buildSectionHeader('Información Importante'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.ruta.containsKey('mejor_epoca'))
                      _buildInfoRow('Mejor Época:', widget.ruta['mejor_epoca']),
                    if (widget.ruta.containsKey('requisitos'))
                      _buildInfoRow('Requisitos:', widget.ruta['requisitos']),
                    if (widget.ruta.containsKey('restricciones'))
                      _buildInfoRow(
                        'Restricciones:',
                        widget.ruta['restricciones'],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Botón Reservar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Consumer<ClienteProvider>(
                builder: (context, clienteProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      _irACrearReservaRuta(clienteProvider);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Reservar Ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
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
          width: double.infinity,
          height: 300,
          color: Colors.grey[300],
          child: _images.isNotEmpty
              ? SizedBox.expand(
                  child: Image.network(
                    _images[_selectedImageIndex],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
                  ),
                )
              : Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
                ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedImageIndex = index);
                  },
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedImageIndex == index
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacteristic(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAmenitiesList(List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items
            .map<Widget>(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
