import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/cliente_provider.dart';
import 'providers/catalogo_provider.dart';
import 'providers/programacion_provider.dart';
import 'providers/reserva_provider.dart';
import 'providers/programacion_personal_provider.dart';
import 'providers/notificaciones_provider.dart';
import 'providers/servicio_provider.dart';
import 'providers/espacio_provider.dart';
import 'widgets/notificaciones_widget.dart';

void main() {
  runApp(const OccitourApp());
}

class OccitourApp extends StatefulWidget {
  const OccitourApp({Key? key}) : super(key: key);

  @override
  State<OccitourApp> createState() => _OccitourAppState();
}

class _OccitourAppState extends State<OccitourApp> {
  @override
  Widget build(BuildContext context) {
    // Paleta de colores principal de Occitours
    const seedColor = Color(0xFF2E7D32); // verde bosque

    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => CatalogoProvider()),
        ChangeNotifierProvider(create: (_) => ProgramacionProvider()),
        ChangeNotifierProvider(create: (_) => ReservaProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
        ChangeNotifierProvider(create: (_) => EspacioProvider()),
        ChangeNotifierProvider(create: (_) => ProgramacionPersonalProvider()),
        ChangeNotifierProvider(create: (_) => NotificacionesProvider()),
      ],
      child: MaterialApp.router(
        title: 'Occitours',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAF9F6),

          // ── Fuente global: Poppins en toda la app ──
          textTheme: baseTextTheme.copyWith(
            displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.w700),
            displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.w600),
            displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w600),
            headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
            headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
            headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
            titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
            bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
            bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
            labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
            labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
          ),

          // ── AppBar con Poppins ──
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            backgroundColor: seedColor,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          // ── Botones elevados con Poppins ──
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),

          // ── Botones de texto con Poppins ──
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Campos de texto con Poppins ──
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
            helperStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            errorStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.red.shade700),
            counterStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),

          // ── Chips, Snackbars, Cards ──
          chipTheme: ChipThemeData(
            labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: GoogleFonts.poppins(fontSize: 14),
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
        builder: (context, child) {
          return NotificacionesWidget(child: child ?? const SizedBox());
        },
      ),
    );
  }
}
