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
