import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/programacion_personal.dart';
import '../../providers/programacion_personal_provider.dart';
import '../../providers/auth_provider.dart';

class AgregarProgramacionPersonalScreen extends StatefulWidget {
  final ProgramacionPersonal? programacionParaEditar;

  const AgregarProgramacionPersonalScreen({
    Key? key,
    this.programacionParaEditar,
  }) : super(key: key);

  @override
  State<AgregarProgramacionPersonalScreen> createState() =>
      _AgregarProgramacionPersonalScreenState();
}

class _AgregarProgramacionPersonalScreenState
    extends State<AgregarProgramacionPersonalScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _horaController;

  DateTime? _fechaSeleccionada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.programacionParaEditar?.titulo ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.programacionParaEditar?.descripcion ?? '',
    );
    _horaController = TextEditingController(
      text: widget.programacionParaEditar?.horaProgramacion ?? '09:00',
    );
    _fechaSeleccionada = widget.programacionParaEditar?.fechaProgramacion;
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );

    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final hora = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _horaController.text = hora;
      });
    }
  }

  Future<void> _guardarProgramacion() async {
    // Validaciones
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es requerido')),
      );
      return;
    }

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una fecha')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final auth = context.read<AuthProvider>();
      final idCliente = auth.usuario?.id;

      if (idCliente == null) {
        throw Exception('No hay cliente autenticado');
      }

      final provider = context.read<ProgramacionPersonalProvider>();

      if (widget.programacionParaEditar != null) {
        // Editar
        await provider.actualizarProgramacion(
          id: widget.programacionParaEditar!.id,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          fechaProgramacion: _fechaSeleccionada,
          horaProgramacion: _horaController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Programación actualizada'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true);
        }
      } else {
        // Crear
        await provider.crearProgramacion(
          idCliente: idCliente,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          fechaProgramacion: _fechaSeleccionada,
          horaProgramacion: _horaController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Programación creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true);
        }
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
    final esEdicion = widget.programacionParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicion
              ? 'Editar Programación'
              : 'Nueva Programación Personal',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título *
              const Text(
                'Título *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  hintText: 'Ej: Comprar víveres',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 20),

              // Descripción
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  hintText: 'Detalles adicionales...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Fecha *
              const Text(
                'Fecha *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _fechaSeleccionada != null
                      ? '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}'
                      : 'Seleccionar fecha',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Hora
              const Text(
                'Hora',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _horaController,
                readOnly: true,
                onTap: _seleccionarHora,
                decoration: InputDecoration(
                  hintText: 'Ej: 09:00',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botones
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardarProgramacion,
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
                      _guardando
                          ? 'Guardando...'
                          : (esEdicion ? 'Actualizar' : 'Crear'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _guardando ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                '* Campos requeridos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _horaController.dispose();
    super.dispose();
  }
}
