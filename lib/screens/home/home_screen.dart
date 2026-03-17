import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/cliente_provider.dart';
import '../catalogo/finca_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatCiudadPais(String? ciudad, String? pais) {
    final partes = [ciudad, pais]
        .where((value) => value != null && value.isNotEmpty)
        .toList();
    return partes.isEmpty ? '-' : partes.join(', ');
  }

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar catálogos y perfil cuando la pantalla se abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final clienteProvider = context.read<ClienteProvider>();

      context.read<CatalogoProvider>().fetchFincas();
      context.read<CatalogoProvider>().fetchRutas();

      if (authProvider.usuario?.id != null) {
        clienteProvider.loadCliente(authProvider.usuario!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildExploreTab(),
          _buildFincasTab(),
          _buildRutasTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Fincas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hiking),
            label: 'Rutas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // Tab 1: Explorar
  Widget _buildExploreTab() {
    return SafeArea(
      child: SingleChildScrollView(
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
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Text(
                        '¡Hola, ${authProvider.usuario?.nombre ?? 'Usuario'}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Descubre y vive nuevas aventuras',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green.shade50, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Búsqueda
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar experiencias...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sección Fincas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fincas Destacadas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedIndex = 1);
                          },
                          child: const Text('Ver más →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<CatalogoProvider>(
                      builder: (context, catalogoProvider, _) {
                        if (catalogoProvider.isLoadingFincas) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (catalogoProvider.fincas.isEmpty) {
                          return const Text('No hay fincas disponibles');
                        }

                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                catalogoProvider.fincas.length.clamp(0, 5),
                            itemBuilder: (context, index) {
                              final finca = catalogoProvider.fincas[index];
                              return _buildFincaCard(finca);
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Sección Rutas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rutas Populares',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedIndex = 2);
                          },
                          child: const Text('Ver más →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<CatalogoProvider>(
                      builder: (context, catalogoProvider, _) {
                        if (catalogoProvider.isLoadingRutas) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (catalogoProvider.rutas.isEmpty) {
                          return const Text('No hay rutas disponibles');
                        }

                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                catalogoProvider.rutas.length.clamp(0, 5),
                            itemBuilder: (context, index) {
                              final ruta = catalogoProvider.rutas[index];
                              return _buildRutaCard(ruta);
                            },
                          ),
                        );
                      },
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

  // Tab 2: Fincas
  Widget _buildFincasTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            child: const Text(
              'Fincas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Consumer<CatalogoProvider>(
              builder: (context, catalogoProvider, _) {
                if (catalogoProvider.isLoadingFincas) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (catalogoProvider.fincas.isEmpty) {
                  return const Center(
                    child: Text('No hay fincas disponibles'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: catalogoProvider.fincas.length,
                  itemBuilder: (context, index) {
                    return _buildFincaGridItem(
                      catalogoProvider.fincas[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Rutas
  Widget _buildRutasTab() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            child: const Text(
              'Rutas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Consumer<CatalogoProvider>(
              builder: (context, catalogoProvider, _) {
                if (catalogoProvider.isLoadingRutas) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (catalogoProvider.rutas.isEmpty) {
                  return const Center(
                    child: Text('No hay rutas disponibles'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: catalogoProvider.rutas.length,
                  itemBuilder: (context, index) {
                    return _buildRutaListItem(
                      catalogoProvider.rutas[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tab 4: Perfil
  Widget _buildProfileTab() {
    return Consumer2<AuthProvider, ClienteProvider>(
      builder: (context, authProvider, clienteProvider, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Nombre
                Text(
                  authProvider.usuario?.nombre ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                Text(
                  authProvider.usuario?.correo ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Estado del perfil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: clienteProvider.perfilCompleto
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: clienteProvider.perfilCompleto
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        clienteProvider.perfilCompleto
                            ? Icons.check_circle
                            : Icons.warning_amber,
                        color: clienteProvider.perfilCompleto
                            ? Colors.green
                            : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clienteProvider.perfilCompleto
                                  ? '✅ Perfil Completo'
                                  : '❌ Perfil Incompleto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: clienteProvider.perfilCompleto
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              clienteProvider.perfilCompleto
                                  ? 'Puedes hacer reservas'
                                  : 'Completa tu perfil para hacer reservas',
                              style: TextStyle(
                                fontSize: 12,
                                color: clienteProvider.perfilCompleto
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Cards
                _buildInfoCard(
                  'Teléfono',
                  clienteProvider.cliente?.telefono ?? '-',
                  Icons.phone,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Documento',
                  clienteProvider.cliente?.numeroDocumento ?? '-',
                  Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Ciudad / País',
                  _formatCiudadPais(
                    clienteProvider.cliente?.ciudad,
                    clienteProvider.cliente?.pais,
                  ),
                  Icons.location_city,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  'Rol',
                  authProvider.usuario?.rol ?? '-',
                  Icons.badge,
                ),
                const SizedBox(height: 32),

                // Botón Editar/Completar Perfil
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await context.push('/completar-perfil');

                      // Si vuelve con cambios, recargar perfil
                      if (result == true && mounted) {
                        if (authProvider.usuario?.id != null) {
                          await clienteProvider
                              .loadCliente(authProvider.usuario!.id);
                        }
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(
                      clienteProvider.perfilCompleto
                          ? 'Editar Perfil'
                          : 'Completar Perfil',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Mis Reservas
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go('/mis-reservas');
                    },
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Mis Reservas'),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Logout
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mostrar diálogo de confirmación
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('¿Cerrar sesión?'),
                            content: const Text(
                              '¿Estás seguro de que deseas cerrar sesión? Tendrás que iniciar sesión nuevamente para acceder a tu cuenta.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(); // Cancelar
                                },
                                child: const Text('Cancelar',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(dialogContext)
                                      .pop(); // Cerrar diálogo
                                  // Ejecutar logout
                                  await authProvider.logout();
                                  if (!context.mounted) return;
                                  context.go('/login?logout=1');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Sí, cerrar sesión'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widgets auxiliares
  Widget _buildFincaCard(dynamic finca) {
    String nombre = '';
    double precio = 0;
    double rating = 4.8;

    if (finca is Map) {
      nombre = (finca['nombre'] ?? '').toString();
      precio = (finca['precio_por_noche'] ?? 0).toDouble();
      rating = (finca['rating'] ?? 4.8).toDouble();
    } else {
      nombre = finca.nombre ?? '';
      precio = finca.precioNoche ?? 0;
      rating = (finca.rating ?? 4.8).toDouble();
    }

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Icon(Icons.image, size: 35),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text('$rating', style: const TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${precio.toStringAsFixed(0)}/noche',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRutaCard(dynamic ruta) {
    String nombre = '';
    double precio = 0;
    double rating = 4.8;

    if (ruta is Map) {
      nombre = (ruta['nombre'] ?? '').toString();
      precio = (ruta['precio'] ?? 0).toDouble();
      rating = (ruta['rating'] ?? 4.8).toDouble();
    } else {
      nombre = ruta.nombre ?? '';
      precio = ruta.precio ?? 0;
      rating = (ruta.rating ?? 4.8).toDouble();
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Icon(Icons.image, size: 40),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$rating'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFincaGridItem(dynamic finca) {
    // Extraer datos según el tipo
    String nombre = '';
    double precio = 0;
    String ubicacion = '';
    int capacidad = 0;
    String imagenPrincipal = '';

    if (finca is Map) {
      nombre = finca['nombre'] ?? '';
      precio = (finca['precio_por_noche'] ?? 0).toDouble();
      ubicacion = finca['ubicacion'] ?? '';
      capacidad = finca['capacidad_personas'] ?? 0;
      imagenPrincipal =
          (finca['imagen_principal'] ?? finca['imagen'] ?? '').toString();
    } else {
      nombre = finca.nombre ?? '';
      precio = finca.precioNoche ?? 0;
      ubicacion = finca.ubicacion ?? '';
      capacidad = finca.capacidad ?? 0;
      imagenPrincipal = (finca.imagen ?? '').toString();
    }

    if (nombre.isNotEmpty) {
      final folder = _folderFromFincaName(nombre);
      imagenPrincipal = 'assets/fincas/$folder/principal.png';
    }

    // Generar color aleatorio para cada tarjeta
    final colors = [
      Colors.green.shade300,
      Colors.green.shade300,
      Colors.purple.shade300,
      Colors.orange.shade300,
      Colors.pink.shade300,
    ];
    final colorIndex = nombre.hashCode % colors.length;
    final backgroundColor = colors[colorIndex];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: backgroundColor,
            ),
            child: imagenPrincipal.isNotEmpty
                ? Image.asset(
                    imagenPrincipal,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported,
                                size: 40, color: Colors.white30),
                            SizedBox(height: 4),
                            Text(
                              'Imagen no disponible',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            size: 40, color: Colors.white30),
                        SizedBox(height: 4),
                        Text(
                          'Imagen no disponible',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$capacidad personas',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${precio.toStringAsFixed(0)}/noche',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FincaDetailScreen(finca: finca),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline, size: 16),
                          label:
                              const Text('Ver', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FincaDetailScreen(finca: finca),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Reservar',
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildRutaListItem(dynamic ruta) {
    String nombre = '';
    double distancia = 0;
    int duracion = 0;
    double precio = 0;

    if (ruta is Map) {
      nombre = (ruta['nombre'] ?? '').toString();
      distancia = (ruta['distancia'] ?? 0).toDouble();
      duracion = (ruta['duracion'] ?? 0).toInt();
      precio = (ruta['precio'] ?? 0).toDouble();
    } else {
      nombre = ruta.nombre ?? '';
      distancia = (ruta.distancia ?? 0).toDouble();
      duracion = (ruta.duracion ?? 0).toInt();
      precio = (ruta.precio ?? 0).toDouble();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          decoration: BoxDecoration(
            color: Colors.green.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.hiking),
        ),
        title: Text(nombre),
        subtitle: Text('${distancia.toStringAsFixed(1)}km - ${duracion}h'),
        trailing: Text(
          '\$${precio.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
