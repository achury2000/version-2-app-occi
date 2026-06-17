import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _showPasswordHints = false; // Mostrar indicadores cuando el campo tiene foco

  // Getters de validación de contraseña en tiempo real
  String get _password => _passwordController.text;
  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecialChar => RegExp(r'[^A-Za-z0-9]').hasMatch(_password);
  bool get _passwordIsStrong => _hasMinLength && _hasUppercase && _hasNumber && _hasSpecialChar;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en la contraseña para actualizar indicadores en tiempo real
    _passwordController.addListener(() => setState(() {}));
  }

  String? _validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No molestar si aún no ha escrito
    }
    if (!_passwordIsStrong) {
      return '⚠️ La contraseña no cumple todos los requisitos';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🔵 [REGISTRO] Iniciando registro...');
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    print('🔵 [REGISTRO] Datos: correo=${_emailController.text.trim()}');

    try {
      final success = await authProvider.register(
        correo: _emailController.text.trim(),
        contrasena: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      print('🔵 [REGISTRO] Success: $success');

      if (success) {
        // Registro exitoso - navegar a pantalla de verificación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registro exitoso. Verifica tu correo'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a verificación pasando el email
        print('🔵 [REGISTRO] Navegando a verificación...');
        context.go(
            '/verify-email?email=${Uri.encodeComponent(_emailController.text.trim())}');
      } else {
        // Mostrar error
        print('🔴 [REGISTRO] Error: ${authProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? '❌ Error al registrarse'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('🔴 [REGISTRO] Excepción capturada: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade600, Colors.green.shade900],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                // Email
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.grey.shade700),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(80),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // No molestar si aún no ha escrito
                    }
                    if (!value.contains('@')) {
                      return '💡 Recuerda: el correo debe contener @';
                    }
                    if (!value.contains('.')) {
                      return '💡 El correo debe tener un dominio válido (ej: @gmail.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña
                Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => _showPasswordHints = hasFocus || _password.isNotEmpty);
                  },
                  child: TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: _obscurePassword,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    validator: _validateStrongPassword,
                  ),
                ),

                // Indicadores visuales de contraseña (en tiempo real)
                if (_showPasswordHints || _password.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Requisitos de contraseña:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _PasswordHintRow(
                          label: 'Al menos 8 caracteres',
                          isMet: _hasMinLength,
                        ),
                        _PasswordHintRow(
                          label: 'Una letra mayúscula (A-Z)',
                          isMet: _hasUppercase,
                        ),
                        _PasswordHintRow(
                          label: 'Un número (0-9)',
                          isMet: _hasNumber,
                        ),
                        _PasswordHintRow(
                          label: 'Un carácter especial (!@#\$...)',
                          isMet: _hasSpecialChar,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),


                // Confirmar Contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Confirmar contraseña',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null; // No molestar si aún no ha escrito
                    }
                    if (value != _passwordController.text) {
                      return '⚠️ Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botón Registrarse
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          )
                        : const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Ya tienes cuenta?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra un indicador de requisito de contraseña en tiempo real
class _PasswordHintRow extends StatelessWidget {
  final String label;
  final bool isMet;

  const _PasswordHintRow({
    required this.label,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isMet ? Icons.check_circle : Icons.cancel,
              key: ValueKey(isMet),
              size: 16,
              color: isMet ? Colors.greenAccent : Colors.red.shade300,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.greenAccent : Colors.white70,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
