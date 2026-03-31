import 'package:flutter_test/flutter_test.dart';
import 'package:occitours/models/programacion.dart';
import '../../fixtures/programacion_fixture.dart';

void main() {
  group('Programacion Model Tests', () {
    test('Programacion.fromJson() debería parsear correctamente', () {
      final json = {
        'id': 1,
        'id_ruta': 1,
        'nombre_ruta': 'Sendero Cóndor',
        'fecha_salida': '2026-04-15',
        'hora_salida': '08:00',
        'cupos_disponibles': 5,
        'cupos_totales': 15,
        'precio': 50.0,
        'estado': 'Disponible',
        'guia': 'Juan Pérez',
        'observaciones': 'Traer binoculares',
      };

      final programacion = Programacion.fromJson(json);

      expect(programacion.id, 1);
      expect(programacion.idRuta, 1);
      expect(programacion.nombreRuta, 'Sendero Cóndor');
      expect(programacion.horaSalida, '08:00');
      expect(programacion.cuposDisponibles, 5);
      expect(programacion.cuposTotales, 15);
      expect(programacion.precio, 50.0);
      expect(programacion.estado, 'Disponible');
      expect(programacion.guia, 'Juan Pérez');
    });

    test('Programacion.toJson() debería serializar correctamente', () {
      final programacion = ProgramacionFixture.senderoCondor();
      final json = programacion.toJson();

      expect(json['id'], 1);
      expect(json['estado'], 'Disponible');
      expect(json['precio'], 50.0);
    });

    test('Programacion disponible debería tener cupos > 0', () {
      final programacion = ProgramacionFixture.senderoCondor();
      expect(programacion.cuposDisponibles, greaterThan(0));
    });

    test('Programacion llena debería tener cupos = 0', () {
      final programacion = ProgramacionFixture.sinCupos();
      expect(programacion.cuposDisponibles, 0);
    });

    test('Programacion cancelada debería tener estado "Cancelada"', () {
      final programacion = ProgramacionFixture.cancelada();
      expect(programacion.estado, 'Cancelada');
    });

    test('Programacion debería poder comparar igualdad por ID', () {
      final p1 = ProgramacionFixture.senderoCondor();
      final p2 = Programacion(
        id: 1,
        nombreRuta: 'Otro nombre',
        precio: 100.0,
      );

      expect(p1.id, p2.id);
    });

    test('fechaSalida debería parsearse como DateTime', () {
      final programacion = ProgramacionFixture.senderoCondor();
      expect(programacion.fechaSalida, isA<DateTime>());
      expect(programacion.fechaSalida?.year, 2026);
      expect(programacion.fechaSalida?.month, 4);
      expect(programacion.fechaSalida?.day, 15);
    });

    test('horaSalida debería ser formato HH:mm', () {
      final programacion = ProgramacionFixture.senderoCondor();
      expect(programacion.horaSalida, '08:00');
      expect(programacion.horaSalida?.contains(':'), true);
    });

    test('Programacion con null observaciones debería manejar correctamente', () {
      final programacion = ProgramacionFixture.conMuchosCupos();
      expect(programacion.observaciones, isNull);
    });
  });
}
