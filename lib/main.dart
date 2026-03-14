import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/catalogo_provider.dart';
import 'providers/reserva_provider.dart';

void main() {
  runApp(const OccitourApp());
}

class OccitourApp extends StatelessWidget {
  const OccitourApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClienteProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogoProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservaProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Occitours',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFAF9F6),
        ),
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }
}
