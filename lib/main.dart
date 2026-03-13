import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/catalogo_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const OccitourApp());
}

class OccitourApp extends StatefulWidget {
  const OccitourApp({Key? key}) : super(key: key);

  @override
  State<OccitourApp> createState() => _OccitourAppState();
}

class _OccitourAppState extends State<OccitourApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = _createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => CatalogoProvider()),
      ],
      child: MaterialApp.router(
        title: 'Occitours',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

GoRouter _createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      const privatePaths = {
        '/home',
      };

      final matchedLocation = state.matchedLocation;
      final uriPath = state.uri.path;
      final fragmentPath = state.uri.fragment.split('?').first;

      final isPrivatePath = privatePaths.contains(matchedLocation) ||
          privatePaths.contains(uriPath) ||
          privatePaths.contains(fragmentPath);

      if (!isLoggedIn && isPrivatePath) {
        return '/login';
      }

      const publicAuthPaths = {
        '/login',
        '/register',
        '/verify-email',
        '/forgot-password',
        '/reset-password',
      };

      final isAuthPath = publicAuthPaths.contains(matchedLocation) ||
          publicAuthPaths.contains(uriPath) ||
          publicAuthPaths.contains(fragmentPath);

      if (isLoggedIn && isAuthPath) {
        return authProvider.getHomeRouteByRole();
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verifyEmail',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),
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
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
