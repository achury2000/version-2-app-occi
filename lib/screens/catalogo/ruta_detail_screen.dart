import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cliente_provider.dart';
import '../../services/reserva_service.dart';

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

  String _formatApiDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatUiDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
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
                              'Precio por persona: \$${precioPersona.toStringAsFixed(0)}',
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
                                      fechaFin =
                                          picked.add(const Duration(days: 1));
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
                                : () =>
                                      setModalState(() => cantidadPersonas--),
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
                            onPressed:
                                isSaving || cantidadPersonas >= capacidad
                                    ? null
                                    : () => setModalState(
                                          () => cantidadPersonas++,
                                        ),
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
                              'Precio por persona: \$${precioPersona.toStringAsFixed(0)}',
                            ),
                            Text('Número de personas: $cantidadPersonas'),
                            const Divider(),
                            Text(
                              'Total estimado: \$${total.toStringAsFixed(0)}',
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
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
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
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'La reserva debe ser de mínimo 1 día',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setModalState(() => isSaving = true);
                                      try {
                                        // Usar el nuevo flujo: crear reserva para una programación
                                        await _reservaService.crear(
                                          idCliente: idCliente,
                                          idProgramacion: 0, // TODO: Obtener de programación seleccionada
                                          cantidadPersonas: cantidadPersonas,
                                          metodoPago: 'transferencia',
                                          observaciones:
                                              'Ruta: $nombre${notasController.text.trim().isNotEmpty ? ' | ${notasController.text.trim()}' : ''}',
                                        );

                                        if (!mounted || !modalContext.mounted) {
                                          return;
                                        }
                                        Navigator.of(modalContext).pop();
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '✅ Reserva de ruta creada correctamente',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(this.context)
                                            .showSnackBar(
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
    
    // Construir lista de imágenes basada en la ruta
    String nombreCarpeta = '';
    if (widget.ruta is Map) {
      final nombre = widget.ruta['nombre'] ?? '';
      nombreCarpeta = nombre.toLowerCase().replaceAll(' - ', '_').replaceAll(' ', '_');
    }
    
    _images = [];
    if (nombreCarpeta.isNotEmpty) {
      _images.add('assets/rutas/$nombreCarpeta/principal.jpg');
      _images.add('assets/rutas/$nombreCarpeta/foto2.jpg');
      _images.add('assets/rutas/$nombreCarpeta/foto3.jpg');
      _images.add('assets/rutas/$nombreCarpeta/foto4.jpg');
      _images.add('assets/rutas/$nombreCarpeta/foto5.jpg');
    } else {
      _images.add('assets/rutas/sendero_condor/principal.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      _buildCharacteristic('⏱️', '${widget.ruta['duracion']?.toString() ?? '0'}h', 'Duración'),
                      _buildCharacteristic('🗺️', '${widget.ruta['distancia']?.toString() ?? '0'} km', 'Distancia'),
                      _buildCharacteristic('📈', widget.ruta['dificultad'] ?? 'Moderado', 'Dificultad'),
                      _buildCharacteristic('👥', widget.ruta['capacidad']?.toString() ?? '0', 'Máx personas'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    '\$${widget.ruta['precio']?.toString() ?? '0'} por persona',
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
                      _buildInfoRow('Restricciones:', widget.ruta['restricciones']),
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
                      _openReservaForm(clienteProvider);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Reservar Ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
          height: 300,
          color: Colors.grey[300],
          child: _images.isNotEmpty
              ? Image.asset(
                  _images[_selectedImageIndex],
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
                )
              : Center(
                  child: Icon(
                    Icons.image,
                    size: 80,
                    color: Colors.grey[400],
                  ),
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAmenitiesList(List<dynamic> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items
            .map<Widget>((item) => Padding(
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
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
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
