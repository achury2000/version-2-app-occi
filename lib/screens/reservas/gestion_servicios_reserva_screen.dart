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

  /// Mostrar confirmación antes de deseleccionar un servicio
  Future<bool?> _mostrarConfirmacionEliminarServicio(
    String nombreServicio,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Eliminar Servicio'),
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
                    'Servicio:',
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
              '¿Estás seguro de eliminar este servicio de la reserva?',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
        
        String mensajeError = 'Error al actualizar servicios';
        if (e.toString().contains('no autorizado') ||
            e.toString().contains('401') ||
            e.toString().contains('unauthorized')) {
          mensajeError = 'No tienes permiso para realizar esta acción';
        } else if (e.toString().contains('no encontrado') ||
            e.toString().contains('404')) {
          mensajeError = 'La reserva o el servicio no fue encontrado';
        } else if (e.toString().contains('red') || e.toString().contains('Network')) {
          mensajeError = 'Error de conexión. Intenta nuevamente';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $mensajeError'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
                          onChanged: (value) async {
                            if (value == true) {
                              // Agregar servicio sin confirmación
                              setState(() {
                                _serviciosActuales.add(servicio.id);
                              });
                            } else {
                              // Pedir confirmación antes de eliminar
                              final confirmar =
                                  await _mostrarConfirmacionEliminarServicio(
                                servicio.nombre,
                              );
                              if (confirmar == true && mounted) {
                                setState(() {
                                  _serviciosActuales.remove(servicio.id);
                                });
                              }
                            }
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
