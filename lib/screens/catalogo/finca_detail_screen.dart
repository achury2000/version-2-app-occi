import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cliente_provider.dart';
import '../../services/reserva_service.dart';

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

  // Fotos de la finca (por ahora solo una, luego agregaremos más)
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final name = (widget.finca is Map)
        ? (widget.finca['nombre']?.toString() ?? '')
        : '';
    final folder = _folderFromFincaName(name);

    _images = [
      'assets/fincas/$folder/principal.png',
      'assets/fincas/$folder/foto2.png',
      'assets/fincas/$folder/foto3.png',
      'assets/fincas/$folder/foto4.png',
      'assets/fincas/$folder/foto5.png',
    ];

    if (_images.isEmpty) {
      _images = ['assets/fincas/las_margaritas/principal.png'];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _folderFromFincaName(String name) {
    final normalized = name
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.startsWith('las margaritas')) return 'las_margaritas';
    if (normalized.startsWith('las heliconias')) return 'las_heliconias';
    if (normalized.startsWith('las palmas')) return 'las_palmas';
    if (normalized.startsWith('la ilusion')) return 'la_ilusion';
    if (normalized.startsWith('la maria')) return 'la_maria';

    return normalized.replaceAll(' ', '_');
  }

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
          content: Text(
            '❌ Debes completar tu perfil antes de hacer reservas',
          ),
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
            final noches =
                (fechaInicio != null &&
                    fechaFin != null &&
                    fechaFin!.isAfter(fechaInicio!))
                ? fechaFin!.difference(fechaInicio!).inDays
                : 0;
            final total = precio * noches;
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
                              'Precio por noche: \$${precio.toStringAsFixed(0)}',
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
                        'Fecha de entrada *',
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
                                  lastDate: DateTime.now().add(const Duration(days: 730)),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    fechaInicio = picked;
                                    if (fechaFin != null && !fechaFin!.isAfter(picked)) {
                                      fechaFin = picked.add(const Duration(days: 1));
                                    }
                                  });
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            fechaInicio != null
                                ? _formatUiDate(fechaInicio!)
                                : 'Seleccionar fecha de entrada',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Fecha de salida *',
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
                                  lastDate: DateTime.now().add(const Duration(days: 730)),
                                );
                                if (picked != null) {
                                  setModalState(() => fechaFin = picked);
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            fechaFin != null
                                ? _formatUiDate(fechaFin!)
                                : 'Seleccionar fecha de salida',
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
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                            Text('Precio por noche: \$${precio.toStringAsFixed(0)}'),
                            Text('Noches: $noches'),
                            Text('Número de personas: $cantidadPersonas'),
                            const Divider(),
                            Text(
                              'Total estimado: \$${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
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
                                      if (fechaInicio == null || fechaFin == null) {
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Selecciona fecha de entrada y salida'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (fechaFin!.isBefore(fechaInicio!)) {
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          const SnackBar(
                                            content: Text('La fecha de salida debe ser al menos un día después de la entrada'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      if (!fechaFin!.isAfter(fechaInicio!)) {
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          const SnackBar(
                                            content: Text('La reserva debe ser de mínimo 1 noche'),
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
                                          observaciones:
                                              'Finca: $nombre${notasController.text.trim().isNotEmpty ? ' | ${notasController.text.trim()}' : ''}',
                                        );

                                        if (!mounted || !modalContext.mounted) {
                                          return;
                                        }
                                        Navigator.of(modalContext).pop();
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          const SnackBar(
                                            content: Text('✅ Reserva creada correctamente'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          SnackBar(
                                            content: Text('❌ No se pudo crear la reserva: $e'),
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Finca'),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 0,
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
                    '\$${widget.finca['precio_por_noche']?.toString() ?? '0'}/noche',
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
                        label: '${widget.finca['capacidad_personas'] ?? 0} personas',
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                                .map((detalle) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color:
                                                  const Color(0xFF0066CC),
                                              borderRadius:
                                                  BorderRadius.circular(3),
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
                                    ))
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
                              '\$${widget.finca['deposito_daños'].toString()}',
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
                            '\$${widget.finca['tarifa_aseo'].toString()}',
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
                child: Consumer<ClienteProvider>(
                  builder: (context, clienteProvider, _) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        _openReservaForm(clienteProvider);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Reservar Ahora'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
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
                    return Image.asset(
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
                  child: Icon(
                    Icons.image,
                    size: 80,
                    color: Colors.grey[400],
                  ),
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
                    final prev = (_selectedImageIndex - 1).clamp(0, _images.length - 1);
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
                    final next = (_selectedImageIndex + 1).clamp(0, _images.length - 1);
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
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
