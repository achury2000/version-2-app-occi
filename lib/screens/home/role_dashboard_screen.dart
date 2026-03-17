import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RoleDashboardScreen extends StatelessWidget {
  final String roleTitle;

  const RoleDashboardScreen({
    Key? key,
    required this.roleTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel $roleTitle'),
        backgroundColor: const Color(0xFF0066CC),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 72,
                color: Color(0xFF0066CC),
              ),
              const SizedBox(height: 16),
              Text(
                'Bienvenido al panel de $roleTitle',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Este panel está separado por rol para cumplir la redirección según tipo de usuario.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Mostrar diálogo de confirmación
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('¿Cerrar sesión?'),
                          content: const Text(
                            '¿Estás seguro de que deseas cerrar sesión? Tendrás que iniciar sesión nuevamente para acceder a tu cuenta.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Cancelar
                              },
                              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop(); // Cerrar diálogo
                                // Ejecutar logout
                                await context.read<AuthProvider>().logout();
                                if (!context.mounted) return;
                                context.go('/login?logout=1');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Sí, cerrar sesión'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
