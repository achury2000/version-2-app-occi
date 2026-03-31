import 'package:occitours/models/programacion.dart';

class ProgramacionFixture {
  /// Programación de prueba para "Sendero Cóndor"
  static Programacion senderoCondor() => Programacion(
        id: 1,
        idRuta: 1,
        nombreRuta: 'Sendero Cóndor',
        fechaSalida: DateTime(2026, 04, 15),
        horaSalida: '08:00',
        cuposDisponibles: 5,
        cuposTotales: 15,
        precio: 50.0,
        estado: 'Disponible',
        guia: 'Juan Pérez',
        observaciones: 'Traer binoculares',
      );

  /// Programación sin cupos disponibles
  static Programacion sinCupos() => Programacion(
        id: 2,
        idRuta: 1,
        nombreRuta: 'Sendero Cóndor',
        fechaSalida: DateTime(2026, 04, 10),
        horaSalida: '09:00',
        cuposDisponibles: 0,
        cuposTotales: 15,
        precio: 50.0,
        estado: 'Lleno',
        guia: 'María García',
      );

  /// Programación cancelada
  static Programacion cancelada() => Programacion(
        id: 3,
        idRuta: 2,
        nombreRuta: 'Caminata Las Margaritas',
        fechaSalida: DateTime(2026, 04, 20),
        horaSalida: '07:00',
        cuposDisponibles: 10,
        cuposTotales: 20,
        precio: 35.0,
        estado: 'Cancelada',
        guia: 'Carlos López',
      );

  /// Programación con muchos cupos disponibles
  static Programacion conMuchosCupos() => Programacion(
        id: 4,
        idRuta: 3,
        nombreRuta: 'Tour Las Heliconias',
        fechaSalida: DateTime(2026, 04, 25),
        horaSalida: '10:00',
        cuposDisponibles: 20,
        cuposTotales: 30,
        precio: 75.0,
        estado: 'Disponible',
        guia: 'Patricia Ruiz',
        observaciones: null,
      );

  /// Lista de múltiples programaciones de prueba
  static List<Programacion> listaPrueba() => [
        senderoCondor(),
        sinCupos(),
        conMuchosCupos(),
      ];
}
