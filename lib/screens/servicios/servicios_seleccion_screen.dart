import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/servicio_provider.dart';
import '../../providers/espacio_provider.dart';

/// Pantalla para seleccionar servicios, espacios y opciones personalizadas
class ServiciosSeleccionScreen extends StatefulWidget {
  final String? tipoServicio;

  const ServiciosSeleccionScreen({Key? key, this.tipoServicio})
      : super(key: key);

  @override
  State<ServiciosSeleccionScreen> createState() =>
      _ServiciosSeleccionScreenState();
}

class _ServiciosSeleccionScreenState extends State<ServiciosSeleccionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _personalizadosController =
      TextEditingController();
  String _filtroActual = '';
  late TabController _tabController;
  int _tabActual = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final servicioProvider = context.read<ServicioProvider>();
        if (widget.tipoServicio != null && widget.tipoServicio!.isNotEmpty) {
          servicioProvider.cargarServiciosPorTipo(widget.tipoServicio!);
        } else {
          servicioProvider.cargarServicios();
        }
        // context.read<EspacioProvider>().cargarEspacios();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _personalizadosController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<ServicioProvider>().filtrarServicios('');
        context.read<EspacioProvider>().filtrarEspacios('');
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Material(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() => _tabActual = index);
                },
                labelColor: const Color(0xFF2D5016),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2D5016),
                tabs: const [
                  Tab(icon: Icon(Icons.room_service), text: 'Servicios'),
                  Tab(icon: Icon(Icons.home), text: 'Espacios'),
                  Tab(icon: Icon(Icons.add_circle), text: 'Personalizado'),
                ],
              ),
            ),
            if (_tabActual < 2) _buildSearchBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildServiciosTab(context),
                  _buildEspaciosTab(context),
                  _buildPersonalizadosTab(context),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildFooter(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2D5016),
      elevation: 0,
      title: const Text('Selecciona Servicios y Espacios'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.pop();
        },
      ),
    );
  }

  /// Mostrar confirmación antes de quitar un servicio
  Future<bool?> _mostrarConfirmacionQuitarServicio(
    String nombreServicio,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Quitar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicio a quitar:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombreServicio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro de quitar este servicio de tu reserva?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Sí, quitar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostrar confirmación antes de agregar un servicio
  Future<bool?> _mostrarConfirmacionAgregarServicio(
    String nombreServicio,
    double precio,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('➕ Agregar Servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicio a agregar:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nombreServicio,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Precio: \$${precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5016),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro de agregar este servicio a tu reserva?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5016),
            ),
            child: const Text(
              'Sí, agregar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _filtroActual = value);
          if (_tabActual == 0) {
            context.read<ServicioProvider>().filtrarServicios(value);
          } else {
            context.read<EspacioProvider>().filtrarEspacios(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Buscar...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2D5016)),
          suffixIcon: _filtroActual.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filtroActual = '');
                    if (_tabActual == 0) {
                      context.read<ServicioProvider>().filtrarServicios('');
                    } else {
                      context.read<EspacioProvider>().filtrarEspacios('');
                    }
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2D5016)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2D5016), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildServiciosTab(BuildContext context) {
    return Consumer<ServicioProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D5016)),
          );
        }

        if (provider.error != null && provider.servicios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
              ],
            ),
          );
        }

        final servicios = provider.serviciosFiltrados;

        if (servicios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No hay servicios disponibles',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: servicios.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final servicio = servicios[index];
            final isSelected = provider.estaSeleccionado(servicio.id);

            return _buildItemCard(
              selected: isSelected,
              onTap: () async {
                if (!isSelected) {
                  // Agregar servicio: pedir confirmación
                  final confirmar = await _mostrarConfirmacionAgregarServicio(
                    servicio.nombre,
                    servicio.precio,
                  );
                  if (confirmar == true && mounted) {
                    provider.toggleSeleccionServicio(servicio.id);
                  }
                } else {
                  // Quitar servicio: pedir confirmación
                  final confirmar = await _mostrarConfirmacionQuitarServicio(
                    servicio.nombre,
                  );
                  if (confirmar == true && mounted) {
                    provider.toggleSeleccionServicio(servicio.id);
                  }
                }
              },
              title: servicio.nombre,
              subtitle: servicio.descripcion,
              price: '\$${servicio.precio.toStringAsFixed(0)}',
            );
          },
        );
      },
    );
  }

  Widget _buildEspaciosTab(BuildContext context) {
    return Consumer<EspacioProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D5016)),
          );
        }

        if (provider.error != null && provider.espacios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
              ],
            ),
          );
        }

        final espacios = provider.espaciosFiltrados;

        if (espacios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'No hay espacios disponibles',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: espacios.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final espacio = espacios[index];

            return _buildItemCard(
              selected: false,
              onTap: () {},
              title: espacio.nombre,
              subtitle: espacio.descripcion,
              price: espacio.precio != null
                  ? '\$${espacio.precio!.toStringAsFixed(0)}'
                  : 'Gratis',
            );
          },
        );
      },
    );
  }

  Widget _buildPersonalizadosTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agregar opciones personalizadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5016),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ingresa opciones o servicios adicionales que no estén en la lista:',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _personalizadosController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Ej: Decoración especial, música en vivo, etc.\n(Una por línea)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2D5016)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2D5016), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2D5016), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5016).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF2D5016)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Puedes agregar múltiples opciones, una por línea',
                    style: TextStyle(color: Color(0xFF2D5016), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required bool selected,
    required VoidCallback onTap,
    required String title,
    String? subtitle,
    required String price,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? const Color(0xFF2D5016) : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: selected ? const Color(0xFF2D5016).withOpacity(0.05) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: const Color(0xFF2D5016),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Column(
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5016),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5016),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          context.pop();
        },
        child: const Text(
          'Confirmar Selección',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
