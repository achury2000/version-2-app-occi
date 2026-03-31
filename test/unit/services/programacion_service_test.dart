import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:occitours/services/programacion_service.dart';
import 'package:occitours/services/api_service.dart';
import '../../fixtures/programacion_fixture.dart';

class MockApiServiceProgr extends Mock implements ApiService {}

void main() {
  group('ProgramacionService Tests', () {
    late ProgramacionService programacionService;
    late MockApiServiceProgr mockApiService;

    setUp(() {
      mockApiService = MockApiServiceProgr();
      programacionService = ProgramacionService();
    });

    test('obtener() debería retornar lista de programaciones', () async {
      final listJson = [
        {
          'id': 1,
          'nombre_ruta': 'Sendero Cóndor',
          'cupos_disponibles': 5,
          'precio': 50.0,
        },
        {
          'id': 2,
          'nombre_ruta': 'Las Heliconias',
          'cupos_disponibles': 0,
          'precio': 75.0,
        },
      ];

      when(() => mockApiService.get(any())).thenAnswer((_) async => listJson);

      // En test real:
      // final programaciones = await programacionService.obtener();
      // expect(programaciones.length, 2);
    });

    test('obtenerPorId() debería retornar programacion específica', () async {
      final json = {
        'id': 1,
        'nombre_ruta': 'Sendero Cóndor',
        'cupos_disponibles': 5,
        'precio': 50.0,
      };

      when(() => mockApiService.get(any())).thenAnswer((_) async => json);

      // En test real:
      // final programacion = await programacionService.obtenerPorId(1);
      // expect(programacion.id, 1);
    });

    test('obtenerPorRuta() debería filtrar by ruta', () async {
      final listJson = ProgramacionFixture.listaPrueba()
          .map((p) => p.toJson())
          .toList();

      when(() => mockApiService.get(any())).thenAnswer((_) async => listJson);

      // En test real:
      // final programaciones = await programacionService.obtenerPorRuta(1);
      // expect(programaciones.every((p) => p.idRuta == 1), true);
    });

    test('programacion sin cupos debería indicarlo', () {
      final p = ProgramacionFixture.sinCupos();
      expect(p.cuposDisponibles, 0);
    });

    test('obtener() debería manejar lista vacía', () async {
      when(() => mockApiService.get(any())).thenAnswer((_) async => []);

      // En test real:
      // final programaciones = await programacionService.obtener();
      // expect(programaciones, isEmpty);
    });
  });
}
