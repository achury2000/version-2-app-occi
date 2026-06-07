import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cliente_provider.dart';
import '../../models/cliente.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _tipoDocumentoController;
  late TextEditingController _numeroDocumentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _ciudadController;
  late TextEditingController _paisController;
  late TextEditingController _codigoPostalController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _generoController;

  bool _controladoresInicializados = false;

  // Tipo de documento seleccionado actualmente (para adaptar el campo de número)
  String _tipoDocumentoSeleccionado = '';

  bool get _esPasaporte => _tipoDocumentoSeleccionado == 'Pasaporte';
  bool get _esExtranjero => _esPasaporte || _tipoDocumentoSeleccionado == 'Otro';

  final List<String> _tiposDocumento = [
    'Cédula',
    'Pasaporte',
    'Licencia de conducir',
    'Otro'
  ];

  final List<String> _generos = ['Masculino', 'Femenino', 'Otro', 'Prefiero no decir'];

  final List<String> _paises = [
    'Colombia',
    'Ecuador',
    'Perú',
    'Bolivia',
    'Venezuela',
    'Brasil',
    'Argentina',
    'Chile',
    'Paraguay',
    'Uruguay',
    'Costa Rica',
    'Panamá',
    'México',
    'España',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    print('🔍 [ProfileEditScreen] Pantalla abierta');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controladoresInicializados) return;
    _controladoresInicializados = true;
    _initializeControllers();
  }

  void _initializeControllers() {
    final clienteProvider = context.read<ClienteProvider>();
    final cliente = clienteProvider.cliente;

    _tipoDocumentoSeleccionado = cliente?.tipoDocumento ?? '';

    _tipoDocumentoController =
        TextEditingController(text: cliente?.tipoDocumento ?? '');
    _numeroDocumentoController =
        TextEditingController(text: cliente?.numeroDocumento ?? '');
    _telefonoController =
        TextEditingController(text: cliente?.telefono ?? '');
    _direccionController =
        TextEditingController(text: cliente?.direccion ?? '');
    _ciudadController = TextEditingController(text: cliente?.ciudad ?? '');
    _paisController = TextEditingController(text: cliente?.pais ?? '');
    _codigoPostalController =
        TextEditingController(text: cliente?.codigoPostal ?? '');
    _fechaNacimientoController =
        TextEditingController(text: cliente?.fechaNacimiento ?? '');
    _generoController = TextEditingController(text: cliente?.genero ?? '');
  }

  @override
  void dispose() {
    _tipoDocumentoController.dispose();
    _numeroDocumentoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _paisController.dispose();
    _codigoPostalController.dispose();
    _fechaNacimientoController.dispose();
    _generoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _fechaNacimientoController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  bool _validateForm() {
    if (_tipoDocumentoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Tipo de documento requerido')),
      );
      return false;
    }

    final numDoc = _numeroDocumentoController.text.trim();
    if (numDoc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Número de documento requerido')),
      );
      return false;
    }

    // Validar formato según tipo de documento
    if (_esPasaporte) {
      // Pasaporte: letras y números, entre 6 y 20 caracteres
      if (!RegExp(r'^[A-Za-z0-9]{6,20}$').hasMatch(numDoc)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Pasaporte: entre 6 y 20 caracteres alfanuméricos'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    } else {
      // CC, Cédula, etc.: solo dígitos, entre 6 y 15
      if (!RegExp(r'^[0-9]{6,15}$').hasMatch(numDoc)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Número de documento: entre 6 y 15 dígitos'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }

    if (_telefonoController.text.trim().isNotEmpty) {
      final tel = _telefonoController.text.trim();
      if (!RegExp(r'^[0-9+\-\s]{7,15}$').hasMatch(tel)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Teléfono inválido (7-15 dígitos)')),
        );
        return false;
      }
    }

    if (_direccionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Dirección requerida')),
      );
      return false;
    }

    if (_ciudadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Ciudad requerida')),
      );
      return false;
    }

    if (_paisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ País requerido')),
      );
      return false;
    }

    return true;
  }

  Future<void> _guardarPerfil() async {
    if (!_validateForm()) return;

    final authProvider = context.read<AuthProvider>();
    final clienteProvider = context.read<ClienteProvider>();
    final usuarioId = authProvider.usuario?.id;

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Error: Usuario no identificado')),
      );
      return;
    }

    print('🔍 [ProfileEditScreen] Intentando guardar perfil...');
    print('   - ID Usuario: $usuarioId');
    print('   - Rol Usuario: ${authProvider.usuario?.rol}');

    // Construir cliente con todos los campos llenos
    final nuevoCliente = Cliente(
      id: clienteProvider.cliente?.id,
      idUsuario: usuarioId,
      tipoDocumento: _tipoDocumentoController.text.trim(),
      numeroDocumento: _numeroDocumentoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      pais: _paisController.text.trim(),
      codigoPostal: _codigoPostalController.text.trim(),
      fechaNacimiento: _fechaNacimientoController.text.trim(),
      genero: _generoController.text.trim(),
      newsletter: false,
      estado: true,
    );

    print('📋 [ProfileEditScreen] Datos a guardar:');
    print('   - Tipo Doc: ${nuevoCliente.tipoDocumento}');
    print('   - Num Doc: ${nuevoCliente.numeroDocumento}');
    print('   - Dirección: ${nuevoCliente.direccion}');
    print('   - Ciudad: ${nuevoCliente.ciudad}');
    print('   - País: ${nuevoCliente.pais}');

    if (!mounted) return;
    
    final success =
        await clienteProvider.saveCliente(nuevoCliente, usuarioId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✅ Perfil guardado correctamente'),
            backgroundColor: Colors.green),
      );

      Navigator.pop(context, true);
    } else {
      final errorMsg = clienteProvider.error ?? 'Error desconocido';
      print('⚠️ Error al guardar: $errorMsg');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ Error: $errorMsg'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Consumer<ClienteProvider>(
          builder: (context, clienteProvider, _) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                  children: [
                    // Indicador de perfil
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: clienteProvider.perfilCompleto
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: clienteProvider.perfilCompleto
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            clienteProvider.perfilCompleto
                                ? Icons.check_circle
                                : Icons.info,
                            color: clienteProvider.perfilCompleto
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              clienteProvider.perfilCompleto
                                  ? '✅ Perfil completo - ¡Ya puedes hacer reservas!'
                                  : '⚠️ Completa tu perfil para hacer reservas',
                              style: TextStyle(
                                color: clienteProvider.perfilCompleto
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tipo de documento
                    _buildDropdownField(
                      label: 'Tipo de Documento *',
                      controller: _tipoDocumentoController,
                      items: _tiposDocumento,
                      icon: Icons.credit_card,
                      onChanged: (value) {
                        setState(() {
                          _tipoDocumentoSeleccionado = value ?? '';
                          _tipoDocumentoController.text = value ?? '';
                          // Limpiar número al cambiar tipo
                          _numeroDocumentoController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Número de documento (cambia según tipo)
                    if (_esPasaporte) ...[  
                      _buildTextField(
                        label: 'Número de Pasaporte *',
                        controller: _numeroDocumentoController,
                        keyboardType: TextInputType.text,
                        icon: Icons.flight_takeoff,
                        maxLength: 20,
                        helperText: 'Ej: AB123456 (6-20 caracteres alfanuméricos)',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        ],
                      ),
                    ] else ...[
                      _buildTextField(
                        label: 'Número de Documento *',
                        controller: _numeroDocumentoController,
                        keyboardType: TextInputType.number,
                        icon: Icons.numbers,
                        maxLength: 15,
                        helperText: '6-15 dígitos',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Teléfono
                    _buildTextField(
                      label: 'Teléfono',
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone,
                      maxLength: 15,
                      helperText: 'Ej: 3001234567',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Dirección
                    _buildTextField(
                      label: 'Dirección *',
                      controller: _direccionController,
                      icon: Icons.location_on,
                      maxLines: 2,
                      maxLength: 150,
                    ),
                    const SizedBox(height: 18),

                    // Ciudad
                    _buildTextField(
                      label: 'Ciudad *',
                      controller: _ciudadController,
                      icon: Icons.location_city,
                      maxLength: 60,
                    ),
                    const SizedBox(height: 18),

                    // País
                    _buildDropdownField(
                      label: 'País *',
                      controller: _paisController,
                      items: _paises,
                      icon: Icons.public,
                    ),
                    const SizedBox(height: 18),

                    // Código postal
                    _buildTextField(
                      label: 'Código Postal',
                      controller: _codigoPostalController,
                      icon: Icons.markunread_mailbox,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Fecha de nacimiento
                    _buildDateField(
                      label: 'Fecha de Nacimiento',
                      controller: _fechaNacimientoController,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 18),

                    // Género
                    _buildDropdownField(
                      label: 'Género',
                      controller: _generoController,
                      items: _generos,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 32),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed:
                            clienteProvider.isLoading ? null : _guardarPerfil,
                        icon: clienteProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          clienteProvider.isLoading ? 'Guardando...' : 'Guardar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // Indicador de carga
              if (clienteProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
    int? maxLength,
    String? helperText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: icon != null ? Icon(icon) : null,
        counterStyle: const TextStyle(fontSize: 11, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    IconData? icon,
    ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged(value);
        } else if (value != null) {
          controller.text = value;
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0066CC), width: 2),
        ),
      ),
    );
  }
}
