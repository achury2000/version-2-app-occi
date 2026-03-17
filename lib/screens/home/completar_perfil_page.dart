import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/cliente_perfil_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/cliente_perfil_service.dart';
import '../../services/token_service.dart';

enum CompletarPerfilViewState {
  initial,
  loading,
  loaded,
  saving,
  error,
}

class CompletarPerfilPage extends StatefulWidget {
  const CompletarPerfilPage({super.key});

  @override
  State<CompletarPerfilPage> createState() => _CompletarPerfilPageState();
}

class _CompletarPerfilPageState extends State<CompletarPerfilPage> {
  final ClientePerfilService _service = ClientePerfilService();
  final TokenService _tokenService = TokenService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tipoDocumentoController =
      TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _numeroDocumentoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _paisController = TextEditingController();
  final TextEditingController _codigoPostalController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _nacionalidadController = TextEditingController();
  final TextEditingController _preferenciasController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();

  bool _newsletter = false;
  bool _estado = true;

  CompletarPerfilViewState _state = CompletarPerfilViewState.initial;
  final Map<String, String> _errors = {};
  String? _generalError;

  ClientePerfilModel? _perfilActual;
  int? _idUsuario;
  String? _token;

  static const List<String> _tiposDocumento = ['CC', 'CE', 'Pasaporte'];
  static const List<String> _generos = ['Masculino', 'Femenino', 'Otro'];

  bool get _isLoading =>
      _state == CompletarPerfilViewState.loading ||
      _state == CompletarPerfilViewState.saving;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _tipoDocumentoController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _numeroDocumentoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _paisController.dispose();
    _codigoPostalController.dispose();
    _fechaNacimientoController.dispose();
    _generoController.dispose();
    _nacionalidadController.dispose();
    _preferenciasController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _state = CompletarPerfilViewState.loading;
      _generalError = null;
      _errors.clear();
    });

    try {
      final authProvider = context.read<AuthProvider>();
      _idUsuario = authProvider.usuario?.id;
      _token = authProvider.token ?? await _tokenService.getToken();

      if (_idUsuario == null || _token == null || _token!.isEmpty) {
        _manejarSesionExpirada();
        return;
      }

      final perfil = await _service.obtenerPerfil(
        idUsuario: _idUsuario!,
        token: _token!,
      );

      _perfilActual = perfil;
      if (perfil != null) {
        _precargarCampos(perfil);
      } else {
        _nombreController.text = authProvider.usuario?.nombre ?? '';
        _apellidoController.text = authProvider.usuario?.apellido ?? '';
      }

      if (!mounted) return;
      setState(() {
        _state = CompletarPerfilViewState.loaded;
      });
    } on ClientePerfilHttpException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        _manejarSesionExpirada();
        return;
      }

      if (!mounted) return;
      setState(() {
        _state = CompletarPerfilViewState.error;
        _generalError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = CompletarPerfilViewState.error;
        _generalError = 'No se pudo cargar el perfil. Intenta nuevamente.';
      });
    }
  }

  void _precargarCampos(ClientePerfilModel perfil) {
    _nombreController.text = perfil.nombre;
    _apellidoController.text = perfil.apellido;
    _tipoDocumentoController.text = perfil.tipoDocumento;
    _numeroDocumentoController.text = perfil.numeroDocumento;
    _telefonoController.text = perfil.telefono;
    _direccionController.text = perfil.direccion;
    _ciudadController.text = perfil.ciudad;
    _paisController.text = perfil.pais;
    _codigoPostalController.text = perfil.codigoPostal ?? '';
    _fechaNacimientoController.text = perfil.fechaNacimiento ?? '';
    _generoController.text = perfil.genero ?? '';
    _nacionalidadController.text = perfil.nacionalidad ?? '';
    _preferenciasController.text = perfil.preferencias ?? '';
    _notasController.text = perfil.notas ?? '';
    _newsletter = perfil.newsletter;
    _estado = perfil.estado;
  }

  Future<void> _onGuardar() async {
    FocusScope.of(context).unfocus();

    final validationErrors = _validarCampos();
    setState(() {
      _errors
        ..clear()
        ..addAll(validationErrors);
      _generalError = null;
    });

    if (validationErrors.isNotEmpty) {
      return;
    }

    if (_idUsuario == null || _token == null || _token!.isEmpty) {
      _manejarSesionExpirada();
      return;
    }

    setState(() {
      _state = CompletarPerfilViewState.saving;
    });

    final perfilEnviar = ClientePerfilModel(
      id: _perfilActual?.id,
      idUsuario: _idUsuario,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      tipoDocumento: _tipoDocumentoController.text.trim(),
      numeroDocumento: _numeroDocumentoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      pais: _paisController.text.trim(),
      codigoPostal: _codigoPostalController.text.trim().isEmpty
          ? null
          : _codigoPostalController.text.trim(),
      fechaNacimiento: _fechaNacimientoController.text.trim().isEmpty
          ? null
          : _fechaNacimientoController.text.trim(),
      genero: _generoController.text.trim().isEmpty
          ? null
          : _generoController.text.trim(),
      nacionalidad: _nacionalidadController.text.trim().isEmpty
          ? null
          : _nacionalidadController.text.trim(),
      preferencias: _preferenciasController.text.trim().isEmpty
          ? null
          : _preferenciasController.text.trim(),
      notas: _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim(),
      newsletter: _newsletter,
      estado: _estado,
    );

    try {
      final perfilGuardado = await _service.guardarMiPerfil(
        perfil: perfilEnviar,
        token: _token!,
      );

      _perfilActual = perfilGuardado;

      if (!mounted) return;
      setState(() {
        _state = CompletarPerfilViewState.loaded;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil guardado correctamente'),
        ),
      );

      Navigator.of(context).pop(true);
    } on ClientePerfilHttpException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        _manejarSesionExpirada();
        return;
      }

      if (!mounted) return;
      setState(() {
        _state = CompletarPerfilViewState.loaded;
        _generalError = _mensajeErrorPorCodigo(e.statusCode, e.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = CompletarPerfilViewState.loaded;
        _generalError = 'No fue posible guardar el perfil. Intenta nuevamente.';
      });
    }
  }

  Map<String, String> _validarCampos() {
    final errors = <String, String>{};

    final tipoDocumento = _tipoDocumentoController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final numeroDocumento = _numeroDocumentoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final direccion = _direccionController.text.trim();
    final ciudad = _ciudadController.text.trim();
    final pais = _paisController.text.trim();
    final fechaNacimiento = _fechaNacimientoController.text.trim();

    if (nombre.isEmpty) {
      errors['nombre'] = 'Este campo es obligatorio';
    }

    if (apellido.isEmpty) {
      errors['apellido'] = 'Este campo es obligatorio';
    }

    if (tipoDocumento.isEmpty) {
      errors['tipo_documento'] = 'Este campo es obligatorio';
    }

    if (numeroDocumento.isEmpty) {
      errors['numero_documento'] = 'Este campo es obligatorio';
    } else {
      final regex = RegExp(r'^[A-Za-z0-9\-\.\s]{3,}$');
      if (!regex.hasMatch(numeroDocumento)) {
        errors['numero_documento'] = 'Documento con formato inválido';
      }
    }

    if (telefono.isEmpty) {
      errors['telefono'] = 'Este campo es obligatorio';
    }

    if (direccion.isEmpty) {
      errors['direccion'] = 'Este campo es obligatorio';
    }

    if (ciudad.isEmpty) {
      errors['ciudad'] = 'Este campo es obligatorio';
    }

    if (pais.isEmpty) {
      errors['pais'] = 'Este campo es obligatorio';
    }

    if (fechaNacimiento.isNotEmpty && !_esFechaValida(fechaNacimiento)) {
      errors['fecha_nacimiento'] = 'Formato inválido. Usa YYYY-MM-DD';
    }

    return errors;
  }

  bool _esFechaValida(String value) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(value)) return false;
    final parsed = DateTime.tryParse(value);
    return parsed != null;
  }

  String _mensajeErrorPorCodigo(int statusCode, String backendMessage) {
    if (statusCode == 422) {
      return backendMessage.isNotEmpty
          ? backendMessage
          : 'Datos inválidos. Revisa el formulario.';
    }
    if (statusCode == 409) {
      return backendMessage.isNotEmpty
          ? backendMessage
          : 'Conflicto al guardar el perfil. Intenta nuevamente.';
    }
    if (statusCode >= 500) {
      return 'Error del servidor. Intenta más tarde.';
    }
    return backendMessage.isNotEmpty
        ? backendMessage
        : 'No se pudo guardar el perfil.';
  }

  void _manejarSesionExpirada() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Sesión expirada. Inicia sesión nuevamente.')),
    );
    context.go('/login?logout=1');
  }

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected != null) {
      final yyyy = selected.year.toString().padLeft(4, '0');
      final mm = selected.month.toString().padLeft(2, '0');
      final dd = selected.day.toString().padLeft(2, '0');
      setState(() {
        _fechaNacimientoController.text = '$yyyy-$mm-$dd';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar perfil'),
      ),
      body: Stack(
        children: [
          if (_state == CompletarPerfilViewState.error)
            _buildErrorState()
          else
            _buildForm(),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _generalError ?? 'Ocurrió un error al cargar el perfil.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPerfil,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _tiposDocumento.contains(_tipoDocumentoController.text)
                  ? _tipoDocumentoController.text
                  : null,
              decoration: InputDecoration(
                labelText: 'Tipo de documento',
                errorText: _errors['tipo_documento'],
              ),
              items: _tiposDocumento
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _tipoDocumentoController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                errorText: _errors['nombre'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apellidoController,
              decoration: InputDecoration(
                labelText: 'Apellido',
                errorText: _errors['apellido'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numeroDocumentoController,
              decoration: InputDecoration(
                labelText: 'Número de documento',
                errorText: _errors['numero_documento'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                errorText: _errors['telefono'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                errorText: _errors['direccion'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ciudadController,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                errorText: _errors['ciudad'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _paisController,
              decoration: InputDecoration(
                labelText: 'País',
                errorText: _errors['pais'],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codigoPostalController,
              decoration: const InputDecoration(
                labelText: 'Código postal (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fechaNacimientoController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento (YYYY-MM-DD)',
                errorText: _errors['fecha_nacimiento'],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickFechaNacimiento,
                ),
              ),
              onTap: _pickFechaNacimiento,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _generos.contains(_generoController.text)
                  ? _generoController.text
                  : null,
              decoration: const InputDecoration(
                labelText: 'Género (opcional)',
              ),
              items: _generos
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _generoController.text = value ?? '';
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nacionalidadController,
              decoration: const InputDecoration(
                labelText: 'Nacionalidad (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _preferenciasController,
              decoration: const InputDecoration(
                labelText: 'Preferencias (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notasController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recibir newsletter'),
              value: _newsletter,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _newsletter = value;
                      });
                    },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Estado activo'),
              value: _estado,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _estado = value;
                      });
                    },
            ),
            if (_generalError != null) ...[
              const SizedBox(height: 12),
              Text(
                _generalError!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onGuardar,
                child: _state == CompletarPerfilViewState.saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar perfil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
