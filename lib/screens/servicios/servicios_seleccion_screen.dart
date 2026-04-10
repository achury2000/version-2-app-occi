import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/servicio.dart';
import '../../providers/servicio_provider.dart';

/// Pantalla para seleccionar servicios adicionales
/// Se muestra durante el proceso de crear una nueva reserva
class ServiciosSeleccionScreen extends StatefulWidget {
  const ServiciosSeleccionScreen({Key? key}) : super(key: key);

  @override
  State<ServiciosSeleccionScreen> createState() =>
      _ServiciosSeleccionScreenState();
}

class _ServiciosSeleccionScreenState extends State<ServiciosSeleccionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroActual = '';

  @override
  void initState() {
    super.initState();
    // Cargar servicios al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ServicioProvider>().cargarServicios();
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
    return WillPopScope(
      onWillPop: () async {
        // Limpiar búsqueda al salir
        context.read<ServicioProvider>().filtrarServicios('');
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Consumer<ServicioProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D5016)),
              );
            }

            if (provider.error != null && provider.servicios.isEmpty) {
              return _buildErrorWidget(context, provider);
            }

            return Column(
              children: [
                // Barra de búsqueda
                _buildSearchBar(context, provider),
                // Lista de servicios
                Expanded(child: _buildServiciosList(context, provider)),
                // Footer con total y botón
                _buildFooter(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  /// AppBar con título y contador de seleccionados
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2D5016),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.read<ServicioProvider>().filtrarServicios('');
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Selecciona Servicios',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white),
          onPressed: () {
            context.go('/home');
          },
        ),
        Consumer<ServicioProvider>(
          builder: (context, provider, _) {
            final cantidad = provider.serviciosSeleccionados.length;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$cantidad',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Barra de búsqueda y filtrado
  Widget _buildSearchBar(BuildContext context, ServicioProvider provider) {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _filtroActual = value);
          provider.filtrarServicios(value);
        },
        decoration: InputDecoration(
          hintText: 'Busca servicios...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2D5016)),
          suffixIcon: _filtroActual.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _filtroActual = '');
                    provider.filtrarServicios('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  /// Lista de servicios con checkboxes
  Widget _buildServiciosList(BuildContext context, ServicioProvider provider) {
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
        return _buildServicioCard(context, provider, servicio);
      },
    );
  }

  /// Tarjeta individual de servicio
  Widget _buildServicioCard(
    BuildContext context,
    ServicioProvider provider,
    Servicio servicio,
  ) {
    final isSelected = provider.estaSeleccionado(servicio.id);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF2D5016) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? const Color(0xFF2D5016).withOpacity(0.05) : null,
      ),
      child: InkWell(
        onTap: () => provider.toggleSeleccionServicio(servicio.id),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: isSelected,
                onChanged: (_) => provider.toggleSeleccionServicio(servicio.id),
                activeColor: const Color(0xFF2D5016),
              ),
              const SizedBox(width: 12),
              // Información del servicio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio.nombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      servicio.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Precio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5016),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '\$${servicio.precio.toStringAsFixed(0)}',
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

  /// Footer con total y botón de confirmar
  Widget _buildFooter(BuildContext context, ServicioProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // Información de total
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Subtotal servicios:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Consumer<ServicioProvider>(
                  builder: (context, provider, _) {
                    final total = provider.totalServiciosSeleccionados;
                    return Text(
                      '\$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5016),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Botón confirmar
          ElevatedButton(
            onPressed: () {
              // Devolver servicios seleccionados al volver
              Navigator.pop(context, provider.idsServiciosSeleccionados);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5016),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget para mostrar error
  Widget _buildErrorWidget(BuildContext context, ServicioProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            provider.error ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.cargarServicios(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5016),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
