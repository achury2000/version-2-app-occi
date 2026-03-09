import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';

/// Configuración de rutas para toda la aplicación
/// Solo se muestran las pantallas de autenticación
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Pantalla de Inicio de Sesión
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
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
  ],
);
