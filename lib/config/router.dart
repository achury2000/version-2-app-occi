import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/mis_reservas_screen.dart';
import '../screens/home/role_dashboard_screen.dart';
import '../screens/catalogo/disponibilidades_screen.dart';
import '../screens/reservas/crear_reserva_screen.dart';
import '../screens/reservas/reserva_detalle_screen.dart';
import '../screens/reservas/editar_reserva_screen.dart';
import '../screens/reservas/gestion_servicios_reserva_screen.dart';
import '../screens/servicios/servicios_seleccion_screen.dart';
import '../screens/programaciones_personales/lista_programaciones_personales_screen.dart';
import '../screens/programaciones_personales/agregar_programacion_personal_screen.dart';
import '../models/reserva.dart';
import '../models/programacion_personal.dart';
import '../providers/auth_provider.dart';

String _normalizeRole(String? role) {
  final normalized = (role ?? '')
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();
  return normalized;
}

String _homeRouteForRole(String? role) {
  final r = _normalizeRole(role);
  if (r == 'administrador' || r == 'admin') return '/admin-home';
  if (r == 'asesor') return '/asesor-home';
  if (r == 'guia') return '/guia-home';
  return '/home';
}

const Set<String> _authRoutes = {
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
  '/verify-email',
};

const Set<String> _protectedRoutes = {
  '/home',
  '/mis-reservas',
  '/disponibilidades',
  '/crear-reserva',
  '/reserva-detalle',
  '/editar-reserva',
  '/gestion-servicios-reserva',
  '/servicios-seleccion',
  '/programaciones-personales',
  '/agregar-programacion-personal',
  '/editar-programacion-personal',
  '/admin-home',
  '/asesor-home',
  '/guia-home',
};

/// Configuración de rutas para toda la aplicación
final appRouter = GoRouter(
  initialLocation: '/login',
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Página no encontrada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Ruta: ${state.uri.path}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  },
  redirect: (context, state) {
    try {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isLoggedIn;
      final location = state.uri.path;

      if (!isLoggedIn && _protectedRoutes.contains(location)) {
        return '/login';
      }

      if (isLoggedIn) {
        final target = _homeRouteForRole(authProvider.usuario?.rol);

        if (_authRoutes.contains(location)) {
          return target;
        }

        if (_protectedRoutes.contains(location) && location != target) {
          return target;
        }
      }
    } catch (e) {
      // Provider no disponible aún, no redirigir
    }

    return null; // No redirigir
  },
  routes: [
    // ============================================
    // PANTALLAS DE AUTENTICACIÓN
    // ============================================

    // Pantalla de Inicio de Sesión
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final showLogoutMessage = state.uri.queryParameters['logout'] == '1';
        return LoginScreen(showLogoutMessage: showLogoutMessage);
      },
    ),

    // Pantalla de Registro
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Pantalla de Verificación de Email
    GoRoute(
      path: '/verify-email',
      name: 'verifyEmail',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyEmailScreen(email: email);
      },
    ),

    // Pantalla de Recuperar Contraseña
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/reset-password',
      name: 'resetPassword',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ??
            state.uri.queryParameters['correo'] ??
            '';
        final token = state.uri.queryParameters['token'] ??
            state.uri.queryParameters['codigo'] ??
            '';
        return ResetPasswordScreen(email: email, token: token);
      },
    ),

    // ============================================
    // PANTALLAS DE APLICACIÓN PRINCIPAL
    // ============================================

    // Pantalla Home
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/mis-reservas',
      name: 'misReservas',
      builder: (context, state) => const MisReservasScreen(),
    ),
    GoRoute(
      path: '/disponibilidades',
      name: 'disponibilidades',
      builder: (context, state) => const DisponibilidadesScreen(),
    ),
    GoRoute(
      path: '/crear-reserva',
      name: 'crearReserva',
      builder: (context, state) {
        final idProgramacion = state.uri.queryParameters['idProgramacion'];
        return CrearReservaScreen(
          idProgramacion:
              idProgramacion != null ? int.tryParse(idProgramacion) : null,
        );
      },
    ),
    GoRoute(
      path: '/reserva-detalle',
      name: 'reservaDetalle',
      builder: (context, state) {
        final idReserva = state.uri.queryParameters['id'];
        int? id;
        if (idReserva != null) {
          id = int.tryParse(idReserva);
        } else if (state.extra is int) {
          id = state.extra as int;
        }
        
        if (id == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
              child: Text('ID de reserva inválido'),
            ),
          );
        }

        return ReservaDetalleScreen(idReserva: id);
      },
    ),
    GoRoute(
      path: '/editar-reserva',
      name: 'editarReserva',
      builder: (context, state) {
        final reserva = state.extra;
        if (reserva == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Reserva no encontrada')),
          );
        }
        return EditarReservaScreen(reserva: reserva as Reserva);
      },
    ),
    GoRoute(
      path: '/gestion-servicios-reserva',
      name: 'gestionServiciosReserva',
      builder: (context, state) {
        final reserva = state.extra;
        if (reserva == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Reserva no encontrada')),
          );
        }
        return GestionServiciosReservaScreen(reserva: reserva as Reserva);
      },
    ),
    GoRoute(
      path: '/servicios-seleccion',
      name: 'serviciosSeleccion',
      builder: (context, state) => const ServiciosSeleccionScreen(),
    ),

    // ============================================
    // PROGRAMACIONES PERSONALES
    // ============================================

    GoRoute(
      path: '/programaciones-personales',
      name: 'programacionesPersonales',
      builder: (context, state) => const ListaProgramacionesPersonalesScreen(),
    ),
    GoRoute(
      path: '/agregar-programacion-personal',
      name: 'agregarProgramacionPersonal',
      builder: (context, state) => const AgregarProgramacionPersonalScreen(),
    ),
    GoRoute(
      path: '/editar-programacion-personal',
      name: 'editarProgramacionPersonal',
      builder: (context, state) {
        final programacion = state.extra;
        if (programacion == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Programación no encontrada')),
          );
        }
        return AgregarProgramacionPersonalScreen(
          programacionParaEditar: programacion as ProgramacionPersonal,
        );
      },
    ),

    GoRoute(
      path: '/admin-home',
      name: 'adminHome',
      builder: (context, state) => const RoleDashboardScreen(
        roleTitle: 'Administrador',
      ),
    ),
    GoRoute(
      path: '/asesor-home',
      name: 'asesorHome',
      builder: (context, state) => const RoleDashboardScreen(
        roleTitle: 'Asesor',
      ),
    ),
    GoRoute(
      path: '/guia-home',
      name: 'guiaHome',
      builder: (context, state) => const RoleDashboardScreen(
        roleTitle: 'Guía',
      ),
    ),
  ],
);
