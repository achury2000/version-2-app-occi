import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';

void main() {
  runApp(const OccitourApp());
}

class OccitourApp extends StatelessWidget {
  const OccitourApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
        routerConfig: _goRouter,
      ),
    );
  }
}

final _goRouter = GoRouter(
  initialLocation: '/login',
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
  ],
);
