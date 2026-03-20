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

  final List<String> _difficulties = [
    'Todos',
    'Fácil',
    'Moderado',
    'Difícil',
  ];

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
                colors: [const Color.fromARGB(255, 89, 175, 93), Colors.green.shade600],
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
                        .map<Widget>((difficulty) => FilterChip(
                              label: Text(difficulty),
                              selected: _selectedDifficulty == difficulty,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                              },
                            ))
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
                  rutas = catalogoProvider.searchRutas(_searchController.text);
                }

                // Filtrar por dificultad
                if (_selectedDifficulty != 'Todos') {
                  rutas = rutas
                      .where(
                        (ruta) => _matchesDifficulty(ruta, _selectedDifficulty),
                      )
                      .toList();
                }

                if (rutas.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron rutas'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
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
          MaterialPageRoute(
            builder: (context) => RutaDetailScreen(ruta: ruta),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  _getImageWidget(ruta),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getDifficultyColor(dificultad),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.signal_cellular_alt, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            dificultad,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 10, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            ubicacion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 10, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          '${duracion}h',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '\$${precio.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RutaDetailScreen(ruta: ruta),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('Ver', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$nombre agregada al carrito'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart, size: 14),
                      label: const Text('Reservar', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getImageWidget(dynamic ruta) {
    String? imagenPath;
    
    if (ruta is Map) {
      imagenPath = ruta['imagen_principal'] as String?;
    } else {
      imagenPath = ruta.imagenUrl;
    }

    if (imagenPath != null && imagenPath.isNotEmpty) {
      return Image.asset(
        imagenPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.green.shade100,
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    }

    return Container(
      color: Colors.green.shade100,
      child: const Center(
        child: Icon(Icons.hiking, size: 40, color: Colors.grey),
      ),
    );
  }
}
