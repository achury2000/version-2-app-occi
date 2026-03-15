import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../data/fincas_data.dart';
import 'finca_detail_screen.dart';

class FincasScreen extends StatefulWidget {
  const FincasScreen({Key? key}) : super(key: key);

  @override
  State<FincasScreen> createState() => _FincasScreenState();
}

class _FincasScreenState extends State<FincasScreen> {
  final _searchController = TextEditingController();
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 500;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                colors: [Colors.green.shade400, Colors.green.shade600],
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
                // Busqueda
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
                      Text('Filtros'),
                    ],
                  ),
                ),
                Consumer<CatalogoProvider>(
                  builder: (context, catalogoProvider, _) {
                    return Text(
                      '${catalogoProvider.fincas.length} resultados',
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
                    'Rango de Precio',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(_selectedMinPrice, _selectedMaxPrice),
                    min: 0,
                    max: 1000,
                    onChanged: (RangeValues values) {
                      setState(() {
                        _selectedMinPrice = values.start;
                        _selectedMaxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${_selectedMinPrice.toStringAsFixed(0)}'),
                      Text('\$${_selectedMaxPrice.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),

          // Lista de Fincas
          Expanded(
            child: Consumer<CatalogoProvider>(
              builder: (context, catalogoProvider, _) {
                if (catalogoProvider.isLoadingFincas) {
                  return const Center(child: CircularProgressIndicator());
                }

                List fincas = catalogoProvider.fincas;

                // Buscar
                if (_searchController.text.isNotEmpty) {
                  fincas =
                      catalogoProvider.searchFincas(_searchController.text);
                }

                // Filtrar por precio
                fincas = fincas
                    .where((f) {
                      double precio = 0;
                      if (f is Map) {
                        precio = (f['precio_por_noche'] ?? 0).toDouble();
                      } else {
                        precio = f.precioNoche;
                      }
                      return precio >= _selectedMinPrice &&
                          precio <= _selectedMaxPrice;
                    })
                    .toList();

                if (fincas.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron fincas'),
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
                  itemCount: fincas.length,
                  itemBuilder: (context, index) {
                    final finca = fincas[index];
                    return _buildFincaCard(finca);
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

  Widget _buildFincaCard(dynamic finca) {
    // Extraer datos según el tipo
    int id = 0;
    String nombre = '';
    String ubicacion = '';
    double precio = 0;
    
    if (finca is Map) {
      id = finca['id'] ?? 0;
      nombre = finca['nombre'] ?? '';
      ubicacion = finca['ubicacion'] ?? '';
      precio = (finca['precio_por_noche'] ?? 0).toDouble();
    } else {
      id = finca.id ?? 0;
      nombre = finca.nombre ?? '';
      ubicacion = finca.ubicacion ?? '';
      precio = finca.precioNoche ?? 0;
    }

    return GestureDetector(
      onTap: () {
        // Obtener datos completos de la finca desde FincasData
        dynamic fincaCompleta;
        
        if (finca is Map) {
          fincaCompleta = finca;
        } else {
          fincaCompleta = FincasData.getFincaById(id) ??
              {
                'nombre': nombre,
                'ubicacion': ubicacion,
                'capacidad_personas': finca.capacidad,
                'precio_por_noche': precio.toInt(),
                'descripcion': finca.descripcion,
              };
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FincaDetailScreen(finca: fincaCompleta),
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
                  // Cargar imagen si existe
                  _getImageWidget(finca),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '4.8',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                    const Spacer(),
                    Text(
                      '\$${precio.toStringAsFixed(0)}/noche',
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
          ],
        ),
      ),
    );
  }

  /// Cargar imagen de la finca
  Widget _getImageWidget(dynamic finca) {
    String? imagenPath;
    
    if (finca is Map) {
      imagenPath = finca['imagen_principal'] as String?;
    } else {
      imagenPath = finca.imagenPrincipal;
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
        child: Icon(Icons.image, size: 40, color: Colors.grey),
      ),
    );
  }
}

