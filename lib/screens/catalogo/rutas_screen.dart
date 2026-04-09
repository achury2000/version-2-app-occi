import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import 'ruta_detail_screen.dart';

class RutasScreen extends StatefulWidget {
  const RutasScreen({Key? key}) : super(key: key);

  @override
  State<RutasScreen> createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  final _searchController = TextEditingController();
  String _selectedDifficulty = 'Todos';
  bool _showFilters = false;

  final List<String> _difficulties = ['Todos', 'Fácil', 'Moderado', 'Difícil'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CatalogoProvider>();
      if (provider.rutas.isEmpty && !provider.isLoadingRutas) {
        provider.fetchRutas();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeDifficulty(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
  }

  bool _matchesDifficulty(dynamic ruta, String selectedDifficulty) {
    if (selectedDifficulty == 'Todos') return true;

    final selected = _normalizeDifficulty(selectedDifficulty);
    String difficulty = '';

    if (ruta is Map) {
      difficulty = (ruta['dificultad'] ?? '').toString();
    } else {
      difficulty = (ruta.dificultad ?? '').toString();
    }

    return _normalizeDifficulty(difficulty) == selected;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 89, 175, 93),
                    Colors.green.shade600,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rutas de Senderismo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Búsqueda
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar ruta...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botón Filtros
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 8),
                        Text('Dificultad'),
                      ],
                    ),
                  ),
                  Consumer<CatalogoProvider>(
                    builder: (context, catalogoProvider, _) {
                      return Text(
                        '${catalogoProvider.rutas.length} rutas',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Panel Filtros
            if (_showFilters)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nivel de Dificultad',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _difficulties
                          .map<Widget>(
                            (difficulty) => FilterChip(
                              label: Text(difficulty),
                              selected: _selectedDifficulty == difficulty,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

            // Lista de Rutas
            Expanded(
              child: Consumer<CatalogoProvider>(
                builder: (context, catalogoProvider, _) {
                  if (catalogoProvider.isLoadingRutas) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List rutas = catalogoProvider.rutas;

                  // Buscar
                  if (_searchController.text.isNotEmpty) {
                    rutas = catalogoProvider.searchRutas(
                      _searchController.text,
                    );
                  }

                  // Filtrar por dificultad
                  if (_selectedDifficulty != 'Todos') {
                    rutas = rutas
                        .where(
                          (ruta) =>
                              _matchesDifficulty(ruta, _selectedDifficulty),
                        )
                        .toList();
                  }

                  if (rutas.isEmpty) {
                    return const Center(child: Text('No se encontraron rutas'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rutas.length,
                    itemBuilder: (context, index) {
                      final ruta = rutas[index];
                      return _buildRutaCard(ruta);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutaCard(dynamic ruta) {
    // Extraer datos según el tipo
    String nombre = '';
    String ubicacion = '';
    String dificultad = '';
    double precio = 0;
    int duracion = 0;

    if (ruta is Map) {
      nombre = ruta['nombre'] ?? '';
      ubicacion = ruta['ubicacion'] ?? '';
      dificultad = ruta['dificultad'] ?? 'Moderado';
      precio = (ruta['precio'] ?? 0).toDouble();
      duracion = (ruta['duracion'] ?? 0).toInt();
    } else {
      nombre = ruta.nombre ?? '';
      ubicacion = ruta.ubicacion ?? '';
      dificultad = ruta.dificultad ?? 'Moderado';
      precio = ruta.precio ?? 0;
      duracion = (ruta.duracion ?? 0).toInt();
    }

    Color getDifficultyColor(String difficulty) {
      switch (difficulty.toLowerCase()) {
        case 'fácil':
          return Colors.green;
        case 'moderado':
          return Colors.orange;
        case 'difícil':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RutaDetailScreen(ruta: ruta)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RutaDetailScreen(ruta: ruta),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _getImageWidget(ruta),
                ),
                const SizedBox(width: 16),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Ubicación
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ubicacion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Duración
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${duracion}h',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dificultad
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: getDifficultyColor(dificultad).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dificultad,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: getDifficultyColor(dificultad),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRutaFolderPath(String nombre) {
    final normalized = nombre
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

    // Mapeo de nombres de rutas a carpetas
    if (normalized.startsWith('sendero') && normalized.contains('condor'))
      return 'sendero_condor';
    if (normalized.startsWith('tour') && normalized.contains('chocolate'))
      return 'tour_del_chocolate';
    if (normalized.contains('tour') &&
        normalized.contains('cata') &&
        normalized.contains('vino'))
      return 'tour_cata_vinos';
    if (normalized.contains('tour') && normalized.contains('cascada'))
      return 'tours_tres_cascadas';
    if (normalized.contains('tour') && normalized.contains('puente'))
      return 'tour_al_puente_occidente';
    if (normalized.contains('city') && normalized.contains('santa'))
      return 'city_tours_santa_fe';
    if (normalized.contains('city') && normalized.contains('tierra'))
      return 'city_tours_tierra_frutas';
    if (normalized.contains('experiencia') && normalized.contains('viña'))
      return 'experiencia_viña_tigre';
    if (normalized.contains('tour') && normalized.contains('cuatrimotos'))
      return 'tour_cuatrimotos';
    if (normalized.contains('senderismo') && normalized.contains('ecologico'))
      return 'senderismo_ecologico';
    if (normalized.contains('paseo') && normalized.contains('caballo'))
      return 'paseo_caballo_bosque';
    if (normalized.contains('bote') ||
        normalized.contains('paseo') && normalized.contains('nicolas'))
      return 'bote_paseo_san_nicolas';
    if (normalized.contains('ruta') && normalized.contains('uva'))
      return 'ruta_uva_sopetran';
    if (normalized.contains('avistamiento')) return 'avistamiento_aves';

    return normalized.replaceAll(' ', '_');
  }

  Widget _getImageWidget(dynamic ruta) {
    String? imagenUrl;

    if (ruta is Map) {
      imagenUrl = (ruta['imagen_principal'] ?? ruta['imagen_url'] ?? '')
          .toString();
    } else {
      imagenUrl = (ruta.imagen ?? '').toString();
    }

    final cleanedUrl = imagenUrl.trim();

    if (cleanedUrl.isNotEmpty && cleanedUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          cleanedUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.green.shade100,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      );
    }

    return Container(
      color: Colors.green.shade100,
      child: const Center(
        child: Icon(Icons.landscape, size: 40, color: Colors.green),
      ),
    );
  }
}
