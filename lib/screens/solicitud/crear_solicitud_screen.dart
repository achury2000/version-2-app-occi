import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/catalogo_provider.dart';
import '../../services/solicitud_service.dart';

class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({Key? key}) : super(key: key);

  @override
  State<CrearSolicitudScreen> createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends State<CrearSolicitudScreen> {
  final SolicitudService _service = SolicitudService();
  int? _idRutaSeleccionada;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  final TextEditingController _observacionesCtrl = TextEditingController();
  List<Map<String, String>> _acompanantes = [];
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogoProvider>().fetchRutas();
    });
  }

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (fecha != null) setState(() => _fechaSeleccionada = fecha);
  }

  Future<void> _pickHora() async {
    final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (hora != null) setState(() => _horaSeleccionada = hora);
  }

  Future<void> _submit() async {
    if (_idRutaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una ruta')));
      return;
    }

    setState(() => _enviando = true);

    // Concatenar acompañantes en una sola cadena y añadirla a observaciones
    final parts = _acompanantes.map((a) {
      final nombre = (a['nombreCompleto'] ?? '').trim();
      final ced = (a['cedula'] ?? '').trim();
      if (nombre.isEmpty && ced.isEmpty) return '';
      return '${nombre} ${ced}'.trim();
    }).where((s) => s.isNotEmpty).toList();

    final acompText = parts.join(' , ');
    final observacionesCombined = _observacionesCtrl.text.trim().isEmpty
        ? acompText
        : (_observacionesCtrl.text.trim() + (acompText.isNotEmpty ? '\nAcompañantes: $acompText' : ''));

    final payload = <String, dynamic>{
      'id_ruta': _idRutaSeleccionada,
      if (_fechaSeleccionada != null) 'fecha_salida': _fechaSeleccionada!.toIso8601String().split('T').first,
      if (_horaSeleccionada != null) 'hora_salida': _horaSeleccionada!.format(context),
      if (observacionesCombined.isNotEmpty) 'observaciones': observacionesCombined,
      if (_acompanantes.isNotEmpty)
        'acompanantes': _acompanantes.map((a) => {
              'nombre_completo': a['nombreCompleto'] ?? '',
              'numero_documento': a['cedula'] ?? ''
            }).toList(),
    };

    try {
      final id = await _service.crear(payload);
      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud creada: #$id'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      } else {
        throw Exception('ID no devuelto');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _showAgregarAcompananteDialog() {
    final nombreCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo acompañante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre completo')),
            TextField(controller: cedulaCtrl, decoration: const InputDecoration(labelText: 'Número documento')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nombre = nombreCtrl.text.trim();
              final cedula = cedulaCtrl.text.trim();
              if (nombre.isEmpty || cedula.isEmpty) return;
              setState(() => _acompanantes.add({'nombreCompleto': nombre, 'cedula': cedula}));
              Navigator.of(context).pop();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rutas = context.watch<CatalogoProvider>().rutas;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Solicitud')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ruta', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _idRutaSeleccionada,
            items: rutas.map<DropdownMenuItem<int>>((r) {
              final idRaw = r['id_ruta'] ?? r['id'];
              final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '0') ?? 0;
              return DropdownMenuItem<int>(value: id, child: Text((r['nombre'] ?? 'Ruta').toString()));
            }).toList(),
            onChanged: (v) => setState(() => _idRutaSeleccionada = v),
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
              onPressed: _pickFecha,
              icon: const Icon(Icons.calendar_month),
              label: Text(_fechaSeleccionada == null ? 'Seleccionar fecha' : _fechaSeleccionada!.toLocal().toString().split(' ')[0]),
            )),
            const SizedBox(width: 8),
            Expanded(
                child: ElevatedButton.icon(
              onPressed: _pickHora,
              icon: const Icon(Icons.schedule),
              label: Text(_horaSeleccionada == null ? 'Seleccionar hora' : _horaSeleccionada!.format(context)),
            )),
          ]),
          const SizedBox(height: 12),
          const Text('Acompañantes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_acompanantes.isEmpty) const Text('No hay acompañantes agregados')
          else ..._acompanantes.map((a) => ListTile(title: Text(a['nombreCompleto'] ?? ''), subtitle: Text(a['cedula'] ?? ''))),
          ElevatedButton.icon(onPressed: _showAgregarAcompananteDialog, icon: const Icon(Icons.person_add), label: const Text('Agregar acompañante')),
          const SizedBox(height: 12),
          const Text('Observaciones', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _observacionesCtrl, maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: _enviando ? null : _submit, child: Text(_enviando ? 'Enviando...' : 'Enviar solicitud'))),
          ])
        ]),
      ),
    );
  }
}
