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
  double _selectedMinPrice = 0;
  double _selectedMaxPrice = 500;
  bool _showFilters = false;

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
                    fincas = catalogoProvider.searchFincas(
                      _searchController.text,
                    );
                  }

                  // Filtrar por precio
                  fincas = fincas.where((f) {
                    double precio = 0;
                    if (f is Map) {
                      precio = (f['precio_por_noche'] ?? 0).toDouble();
                    } else {
                      precio = f.precioNoche;
                    }
                    return precio >= _selectedMinPrice &&
                        precio <= _selectedMaxPrice;
                  }).toList();

                  if (fincas.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron fincas'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
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
    int capacidad = 0;
    double precio = 0;
    String imagenPrincipal = '';

    if (finca is Map) {
      id = finca['id'] ?? 0;
      nombre = finca['nombre'] ?? '';
      ubicacion = finca['ubicacion'] ?? '';
      capacidad = (finca['capacidad_personas'] ?? 0).toInt();
      precio = (finca['precio_por_noche'] ?? 0).toDouble();
      imagenPrincipal = (finca['imagen_principal'] ?? '').toString();
    } else {
      id = finca.id ?? 0;
      nombre = finca.nombre ?? '';
      ubicacion = finca.ubicacion ?? '';
      capacidad = finca.capacidad ?? 0;
      precio = finca.precioNoche ?? 0;
      imagenPrincipal = (finca.imagen ?? '').toString();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
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
              // Icono
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (imagenPrincipal.isNotEmpty &&
                          imagenPrincipal.startsWith('http'))
                      ? Image.network(
                          imagenPrincipal,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.home,
                              size: 40,
                              color: Colors.green,
                            );
                          },
                        )
                      : const Icon(Icons.home, size: 40, color: Colors.green),
                ),
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

                    // Capacidad
                    Row(
                      children: [
                        const Icon(Icons.people, size: 12, color: Colors.grey),
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

              // Precio
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${precio.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '/noche',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
