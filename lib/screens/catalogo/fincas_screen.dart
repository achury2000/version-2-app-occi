import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import 'finca_detail_screen.dart';

class FincasScreen extends StatefulWidget {
  const FincasScreen({Key? key}) : super(key: key);

  @override
  State<FincasScreen> createState() => _FincasScreenState();
}

class _FincasScreenState extends State<FincasScreen> {
  final _searchController = TextEditingController();
  String _selectedCapacidad = 'Todos';
  bool _showFilters = false;

  // Opciones de filtro por capacidad (similar a dificultad en rutas)
  final List<String> _capacidades = [
    'Todos',
    'Hasta 10',
    'Hasta 30',
    'Hasta 50',
    'Más de 50',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CatalogoProvider>();
      if (provider.fincas.isEmpty && !provider.isLoadingFincas) {
        provider.fetchFincas();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Comprueba si una finca cumple el filtro de capacidad seleccionado
  bool _matchesCapacidad(dynamic finca, String selected) {
    if (selected == 'Todos') return true;
    int capacidad = 0;
    if (finca is Map) {
      capacidad = (finca['capacidad_personas'] ?? 0).toInt();
    } else {
      capacidad = (finca.capacidad ?? 0).toInt();
    }
    switch (selected) {
      case 'Hasta 10':
        return capacidad <= 10;
      case 'Hasta 30':
        return capacidad <= 30;
      case 'Hasta 50':
        return capacidad <= 50;
      case 'Más de 50':
        return capacidad > 50;
      default:
        return true;
    }
  }

  /// Formatea precio con puntos como separador de miles (estilo colombiano)
  /// Ej: 250000 → $250.000
  String _formatPrice(double value) {
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
            // ── Header ──────────────────────────────────────────────
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
                    'Fincas',
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
                      hintText: 'Buscar finca...',
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

            // ── Barra filtros ────────────────────────────────────────
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
                        Text('Capacidad'),
                      ],
                    ),
                  ),
                  Consumer<CatalogoProvider>(
                    builder: (context, catalogoProvider, _) {
                      return Text(
                        '${catalogoProvider.fincas.length} fincas',
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

            // ── Panel filtros (chips igual que rutas) ────────────────
            if (_showFilters)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Capacidad de personas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _capacidades
                          .map<Widget>(
                            (cap) => FilterChip(
                              label: Text(
                                cap,
                                style: TextStyle(
                                  color: _selectedCapacidad == cap
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: _selectedCapacidad == cap
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: _selectedCapacidad == cap,
                              selectedColor: Colors.green.shade600,
                              backgroundColor: Colors.white,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: _selectedCapacidad == cap
                                      ? Colors.green.shade600
                                      : Colors.grey.shade300,
                                ),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCapacidad = cap;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

            // ── Lista de Fincas ──────────────────────────────────────
            Expanded(
              child: Consumer<CatalogoProvider>(
                builder: (context, catalogoProvider, _) {
                  if (catalogoProvider.isLoadingFincas) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (catalogoProvider.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Error: ${catalogoProvider.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => catalogoProvider.fetchFincas(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  List fincas = catalogoProvider.fincas;

                  // Filtrar por búsqueda
                  if (_searchController.text.isNotEmpty) {
                    fincas = catalogoProvider.searchFincas(
                      _searchController.text,
                    );
                  }

                  // Filtrar por capacidad
                  if (_selectedCapacidad != 'Todos') {
                    fincas = fincas
                        .where(
                          (finca) =>
                              _matchesCapacidad(finca, _selectedCapacidad),
                        )
                        .toList();
                  }

                  if (fincas.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron fincas'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: catalogoProvider.fetchFincas,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: fincas.length,
                      itemBuilder: (context, index) {
                        final finca = fincas[index];
                        return _buildFincaCard(finca);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card de finca: MISMO DISEÑO que ruta ──────────────────────────
  Widget _buildFincaCard(dynamic finca) {
    String nombre = '';
    String ubicacion = '';
    int capacidad = 0;
    double precio = 0;

    if (finca is Map) {
      nombre = finca['nombre'] ?? '';
      ubicacion = finca['ubicacion'] ?? '';
      capacidad = (finca['capacidad_personas'] ?? 0).toInt();
      precio = (finca['precio_por_noche'] ?? 0).toDouble();
    } else {
      nombre = finca.nombre ?? '';
      ubicacion = finca.ubicacion ?? '';
      capacidad = (finca.capacidad ?? 0).toInt();
      precio = (finca.precioNoche ?? 0).toDouble();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FincaDetailScreen(finca: finca),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FincaDetailScreen(finca: finca),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // ── Imagen ────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _getFincaImageWidget(finca),
                ),
                const SizedBox(width: 16),

                // ── Información central ───────────────────────────
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

                      // Capacidad (equivalente a duración en rutas)
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$capacidad personas',
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

                // ── Badge precio/noche (= badge dificultad+precio rutas) ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'por noche',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(precio),
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

  Widget _getFincaImageWidget(dynamic finca) {
    String? imagenUrl;

    if (finca is Map) {
      imagenUrl =
          (finca['imagen_principal'] ?? finca['imagen_url'] ?? '').toString();
    } else {
      imagenUrl = (finca.imagen ?? '').toString();
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
                child: Icon(Icons.home, size: 40, color: Colors.grey),
              ),
            );
          },
        ),
      );
    }

    return Container(
      color: Colors.green.shade100,
      child: const Center(
        child: Icon(Icons.home, size: 40, color: Colors.green),
      ),
    );
  }
}
