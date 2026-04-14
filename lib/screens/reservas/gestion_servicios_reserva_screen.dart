import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reserva.dart';
import '../../providers/reserva_provider.dart';
import '../../providers/servicio_provider.dart';

class GestionServiciosReservaScreen extends StatefulWidget {
  final Reserva reserva;

  const GestionServiciosReservaScreen({
    Key? key,
    required this.reserva,
  }) : super(key: key);

  @override
  State<GestionServiciosReservaScreen> createState() =>
      _GestionServiciosReservaScreenState();
}

class _GestionServiciosReservaScreenState
    extends State<GestionServiciosReservaScreen> {
  late Set<int> _serviciosActuales;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Inicializar con servicios de la reserva actual
    _serviciosActuales = (widget.reserva.servicios ?? [])
        .map((s) {
          if (s is Map<String, dynamic>) {
            return int.tryParse(s['id']?.toString() ?? '0') ?? 0;
          } else if (s is int) {
            return s;
          }
          return 0;
        })
        .where((id) => id > 0)
        .toSet();

    // Cargar servicios disponibles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicioProvider>().cargarServicios();
    });
  }

  Future<void> _guardarCambios() async {
    // Obtener servicios originales
    final serviciosOriginales = (widget.reserva.servicios ?? [])
        .map((s) {
          if (s is Map<String, dynamic>) {
            return int.tryParse(s['id']?.toString() ?? '0') ?? 0;
          } else if (s is int) {
            return s;
          }
          return 0;
        })
        .where((id) => id > 0)
        .toSet();

    // Calcular servicios a agregar y eliminar
    final aAgregar = _serviciosActuales.difference(serviciosOriginales);
    final aEliminar = serviciosOriginales.difference(_serviciosActuales);

    if (aAgregar.isEmpty && aEliminar.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final provider = context.read<ReservaProvider>();

      // Agregar nuevos servicios
      for (final idServicio in aAgregar) {
        await provider.agregarServicioAReserva(
          idReserva: widget.reserva.id,
          idServicio: idServicio,
        );
      }

      // Eliminar servicios
      for (final idServicio in aEliminar) {
        await provider.eliminarServicioDeReserva(
          idReserva: widget.reserva.id,
          idServicio: idServicio,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Servicios actualizados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios'),
        centerTitle: true,
      ),
      body: Consumer<ServicioProvider>(
        builder: (context, servicioProvider, _) {
          if (servicioProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final servicios = servicioProvider.servicios;

          if (servicios.isEmpty) {
            return const Center(
              child: Text('No hay servicios disponibles'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Encabezado informativo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Servicios actuales:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _serviciosActuales.isEmpty
                            ? 'Sin servicios adicionales'
                            : '${_serviciosActuales.length} servicio(s)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de servicios disponibles
                Expanded(
                  child: ListView.builder(
                    itemCount: servicios.length,
                    itemBuilder: (context, index) {
                      final servicio = servicios[index];
                      final estaSeleccionado =
                          _serviciosActuales.contains(servicio.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: estaSeleccionado,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _serviciosActuales.add(servicio.id);
                              } else {
                                _serviciosActuales.remove(servicio.id);
                              }
                            });
                          },
                          title: Text(
                            servicio.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(servicio.descripcion),
                              if (servicio.precio > 0)
                                Text(
                                  '\$${servicio.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                            ],
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Botones
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _guardando ? null : _guardarCambios,
                      icon: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _guardando ? 'Guardando...' : 'Guardar cambios',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed:
                          _guardando ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
