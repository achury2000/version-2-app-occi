import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/programacion.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/programacion_provider.dart';
import '../catalogo/finca_detail_screen.dart';
import '../catalogo/rutas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatCiudadPais(String? ciudad, String? pais) {
    final partes = [
      ciudad,
      pais,
    ].where((value) => value != null && value.isNotEmpty).toList();
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
      context.read<ProgramacionProvider>().cargarProgramaciones();

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Fincas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.hiking), label: 'Rutas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
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
                    style: TextStyle(fontSize: 14, color: Colors.white70),
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

                    // Programación semanal destacada
                    _buildProgramacionSemanalSection(),

                    const SizedBox(height: 28),

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
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (catalogoProvider.fincas.isEmpty) {
                          return const Text('No hay fincas disponibles');
                        }

                        return SizedBox(
                          height: 238,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: catalogoProvider.fincas.length.clamp(
                              0,
                              5,
                            ),
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
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (catalogoProvider.rutas.isEmpty) {
                          return const Text('No hay rutas disponibles');
                        }

                        return SizedBox(
                          height: 238,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: catalogoProvider.rutas.length.clamp(
                              0,
                              5,
                            ),
                            itemBuilder: (context, index) {
                              final ruta = catalogoProvider.rutas[index];
                              return _buildRutaCard(ruta);
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),
                    _buildConfianzaSection(),
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
                  return const Center(child: Text('No hay fincas disponibles'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 285,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: catalogoProvider.fincas.length,
                  itemBuilder: (context, index) {
                    return _buildFincaGridItem(catalogoProvider.fincas[index]);
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
    return const RutasScreen();
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
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                          await clienteProvider.loadCliente(
                            authProvider.usuario!.id,
                          );
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
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop(); // Cerrar diálogo
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

  DateTime _inicioSemana(DateTime fecha) {
    final base = DateTime(fecha.year, fecha.month, fecha.day);
    return base.subtract(Duration(days: base.weekday - 1));
  }

  DateTime _finSemana(DateTime fecha) {
    final inicio = _inicioSemana(fecha);
    return DateTime(inicio.year, inicio.month, inicio.day + 6, 23, 59, 59);
  }

  List<Programacion> _programacionesSemana(List<Programacion> todas) {
    final inicio = _inicioSemana(DateTime.now());
    final fin = _finSemana(DateTime.now());

    final filtradas = todas.where((programacion) {
      final fecha = programacion.fechaSalida;
      if (fecha == null) return false;
      if (fecha.isBefore(inicio) || fecha.isAfter(fin)) return false;
      return programacion.tieneCupos;
    }).toList();

    filtradas.sort((a, b) {
      final fechaA = a.fechaSalida ?? DateTime(2099);
      final fechaB = b.fechaSalida ?? DateTime(2099);
      return fechaA.compareTo(fechaB);
    });

    return filtradas;
  }

  String _mesCorto(int mes) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return meses[(mes - 1).clamp(0, 11)];
  }

  String _diaCorto(int weekday) {
    const dias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];
    return dias[(weekday - 1).clamp(0, 6)];
  }

  String _fechaCorta(DateTime? fecha) {
    if (fecha == null) return 'Sin fecha';
    return '${_diaCorto(fecha.weekday)} ${fecha.day} ${_mesCorto(fecha.month)}';
  }

  String _rangoSemanaActual() {
    final inicio = _inicioSemana(DateTime.now());
    final fin = _finSemana(DateTime.now());
    return '${inicio.day} ${_mesCorto(inicio.month)} - ${fin.day} ${_mesCorto(fin.month)}';
  }

  Widget _buildProgramacionSemanalSection() {
    return Consumer<ProgramacionProvider>(
      builder: (context, programacionProvider, _) {
        final semana = _programacionesSemana(
          programacionProvider.programaciones,
        );
        final cuposTotales = semana.fold<int>(
          0,
          (total, prog) => total + (prog.cuposDisponibles ?? 0),
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D9488), Color(0xFF0EA5E9)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Programacion de esta semana',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _rangoSemanaActual(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/disponibilidades');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildWeeklyKpi('Salidas', semana.length.toString()),
                  const SizedBox(width: 10),
                  _buildWeeklyKpi('Cupos', cuposTotales.toString()),
                ],
              ),
              const SizedBox(height: 14),
              if (programacionProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.8,
                    ),
                  ),
                )
              else if (semana.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No hay salidas programadas para esta semana. Revisa disponibilidades para próximas fechas.',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                )
              else
                SizedBox(
                  height: 146,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: semana.length.clamp(0, 6),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return _buildProgramacionSemanalCard(semana[index]);
                    },
                  ),
                ),
              if (!programacionProvider.isLoading &&
                  programacionProvider.error != null &&
                  programacionProvider.error!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Algunas programaciones no pudieron cargarse. Puedes actualizar.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context
                              .read<ProgramacionProvider>()
                              .cargarProgramaciones();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Actualizar'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyKpi(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramacionSemanalCard(Programacion programacion) {
    final cupos = programacion.cuposDisponibles ?? 0;
    final ruta = (programacion.nombreRuta ?? 'Ruta sin nombre').trim();
    final hora = (programacion.horaSalida ?? 'Sin hora').trim();

    return Container(
      width: 210,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _fechaCorta(programacion.fechaSalida),
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.timer_outlined,
                size: 14,
                color: Color(0xFF0F766E),
              ),
              const SizedBox(width: 4),
              Text(
                hora,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ruta,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 15,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 5),
              Text(
                '$cupos cupos',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  context.go('/disponibilidades');
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Reservar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0EA5E9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF0EA5E9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFincaCard(dynamic finca) {
    String nombre = '';
    double precio = 0;
    double rating = 4.8;
    String ubicacion = '';
    String imagenPrincipal = '';

    if (finca is Map) {
      nombre = (finca['nombre'] ?? '').toString();
      precio = (finca['precio_por_noche'] ?? 0).toDouble();
      rating = (finca['rating'] ?? 4.8).toDouble();
      ubicacion = (finca['ubicacion'] ?? '').toString();
      imagenPrincipal = (finca['imagen_principal'] ?? finca['imagen'] ?? '')
          .toString()
          .trim();
    } else {
      nombre = finca.nombre ?? '';
      precio = finca.precioNoche ?? 0;
      rating = (finca.rating ?? 4.8).toDouble();
      ubicacion = (finca.ubicacion ?? '').toString();
      imagenPrincipal = (finca.imagen ?? '').toString().trim();
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
      child: Container(
        width: 184,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 118,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imagenPrincipal.startsWith('http')
                        ? Image.network(
                            imagenPrincipal,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.green.shade200,
                                child: const Icon(Icons.image, size: 35),
                              );
                            },
                          )
                        : Container(
                            color: Colors.green.shade200,
                            child: const Icon(Icons.image, size: 35),
                          ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0x77000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          ubicacion.isEmpty
                              ? 'Ubicacion por confirmar'
                              : ubicacion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                      color: Color(0xFF166534),
                      fontSize: 13,
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

  Widget _buildRutaCard(dynamic ruta) {
    String nombre = '';
    double precio = 0;
    double rating = 4.8;
    String dificultad = '';
    double duracion = 0;
    String imagenUrl = '';

    if (ruta is Map) {
      nombre = (ruta['nombre'] ?? '').toString();
      precio = (ruta['precio'] ?? 0).toDouble();
      rating = (ruta['rating'] ?? 4.8).toDouble();
      dificultad = (ruta['dificultad'] ?? '').toString();
      duracion = (ruta['duracion'] ?? 0).toDouble();
      imagenUrl = (ruta['imagen_principal'] ??
              ruta['imagen_url'] ??
              ruta['imagen'] ??
              '')
          .toString();
    } else {
      nombre = ruta.nombre ?? '';
      precio = ruta.precio ?? 0;
      rating = (ruta.rating ?? 4.8).toDouble();
      dificultad = (ruta.dificultad ?? '').toString();
      duracion = (ruta.duracion ?? 0).toDouble();
      imagenUrl = (ruta.imagen ?? '').toString();
    }

    final assetPrincipal = _rutaPrincipalAssetFromName(nombre);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = 2);
      },
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 118,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildRutaPopularImage(
                      imageUrl: imagenUrl,
                      assetPrincipal: assetPrincipal,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0x6A000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        dificultad.isEmpty ? 'Ruta' : dificultad,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '$rating',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duracion > 0
                            ? '${duracion.toStringAsFixed(0)} h'
                            : 'Tiempo flexible',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${precio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF166534),
                      fontSize: 14,
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

  Widget _buildConfianzaSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Por que reservar con Occitours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conectamos viajeros con experiencias autenticas y hospedajes rurales de confianza, impulsando el turismo local responsable.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.verified_user_outlined,
            'Experiencias verificadas con anfitriones locales',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            Icons.lock_clock_outlined,
            'Reserva segura y confirmacion rapida',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            Icons.forest_outlined,
            'Turismo responsable en el Occidente de Antioquia',
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/disponibilidades'),
              icon: const Icon(Icons.calendar_month),
              label: const Text('Ver disponibilidades y reservar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ),
      ],
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
            child: imagenPrincipal.startsWith('http')
                ? Image.network(
                    imagenPrincipal,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.white30,
                            ),
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
                        Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.white30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Imagen no disponible',
                          style: TextStyle(fontSize: 10, color: Colors.white30),
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
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey,
                      ),
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
                          label: const Text(
                            'Ver',
                            style: TextStyle(fontSize: 12),
                          ),
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
                          label: const Text(
                            'Reservar',
                            style: TextStyle(fontSize: 12),
                          ),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildRutaPopularImage({
    required String imageUrl,
    required String assetPrincipal,
  }) {
    final cleanedUrl = imageUrl.trim();

    if (cleanedUrl.isNotEmpty && cleanedUrl.startsWith('http')) {
      return Image.network(
        cleanedUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          if (assetPrincipal.isNotEmpty) {
            return Image.asset(
              assetPrincipal,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildRutaPopularFallback(),
            );
          }
          return _buildRutaPopularFallback();
        },
      );
    }

    if (assetPrincipal.isNotEmpty) {
      return Image.asset(
        assetPrincipal,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildRutaPopularFallback(),
      );
    }

    return _buildRutaPopularFallback();
  }

  Widget _buildRutaPopularFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.hiking,
          size: 50,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  String _rutaPrincipalAssetFromName(String nombre) {
    final folder = _rutaFolderFromName(nombre);
    if (folder.isEmpty) return '';
    return 'assets/rutas/$folder/principal.png';
  }

  String _rutaFolderFromName(String nombre) {
    final normalized = _normalizeRutaNombre(nombre);

    if (normalized.contains('bote') ||
        (normalized.contains('paseo') && normalized.contains('nicolas'))) {
      return 'bote_paseo_san_nicolas';
    }
    if (normalized.contains('city') && normalized.contains('santa')) {
      return 'city_tours_santa_fe';
    }
    if (normalized.contains('city') && normalized.contains('tierra')) {
      return 'city_tours_tierra_frutas';
    }
    if (normalized.contains('experiencia') && normalized.contains('vina')) {
      return 'experiencia_viña_tigre';
    }
    if (normalized.contains('paseo') && normalized.contains('caballo')) {
      return 'paseo_caballo_bosque';
    }
    if (normalized.contains('ruta') && normalized.contains('uva')) {
      return 'ruta_uva_sopetran';
    }
    if (normalized.contains('senderismo') && normalized.contains('ecologico')) {
      return 'senderismo_ecologico';
    }
    if (normalized.contains('cascada')) {
      return 'tours_tres_cascadas';
    }
    if (normalized.contains('puente')) {
      return 'tour_al_puente_occidente';
    }
    if (normalized.contains('cata') && normalized.contains('vino')) {
      return 'tour_cata_vinos';
    }
    if (normalized.contains('cuatrimoto')) {
      return 'tour_cuatrimotos';
    }
    if (normalized.contains('chocolate')) {
      return 'tour_del_chocolate';
    }
    if (normalized.contains('avistamiento')) {
      return 'avistamiento_aves';
    }

    return '';
  }

  String _normalizeRutaNombre(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u')
        .trim();
  }
}
