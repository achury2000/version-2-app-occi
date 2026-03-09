import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:async';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codigoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  bool _canResend = false;
  int _countdown = 60; // 60 segundos para poder reenviar
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _canResend = false;
    _countdown = 60;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyEmail(
      email: widget.email,
      codigo: _codigoController.text.trim(),
    );

    setState(() => _isVerifying = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Email verificado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '❌ Código incorrecto'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    final authProvider = context.read<AuthProvider>();

    setState(() => _isVerifying = true);
    final success = await authProvider.resendVerificationCode(widget.email);
    setState(() => _isVerifying = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📧 Código reenviado a tu correo'),
          backgroundColor: Colors.blue,
        ),
      );
      _startCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? '❌ Error al reenviar código'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getMaskedEmail() {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '${username[0]}***@$domain';
    }

    return '${username.substring(0, 2)}***${username[username.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Email'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade400,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Icono
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: Colors.blue.shade400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título
                  const Text(
                    'Verifica tu correo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Hemos enviado un código de verificación a:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Email enmascarado
                  Text(
                    _getMaskedEmail(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Campo de código
                  TextFormField(
                    controller: _codigoController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Código de verificación',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon:
                          Icon(Icons.vpn_key, color: Colors.grey.shade700),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Ingresa el código';
                      }
                      if (value!.length != 6) {
                        return 'El código debe tener 6 dígitos';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Botón Verificar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : const Text(
                              'Verificar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reenviar código
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No recibiste el código?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_canResend)
                        TextButton(
                          onPressed: _isVerifying ? null : _handleResend,
                          child: const Text(
                            'Reenviar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Espera ${_countdown}s',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón volver al login
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
