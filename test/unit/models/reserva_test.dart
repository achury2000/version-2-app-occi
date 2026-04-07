import 'package:flutter_test/flutter_test.dart';
import 'package:occitours/models/reserva.dart';
import '../../fixtures/reserva_fixture.dart';

void main() {
  group('Reserva Model Tests', () {
    test('Reserva.fromJson() debería parsear correctamente', () {
      final json = {
        'id': 101,
        'id_cliente': 1,
        'id_programacion': 1,
        'cantidad_personas': 3,
        'fecha_reserva': '2026-04-01',
        'fecha_inicio': '2026-04-15',
        'fecha_fin': '2026-04-15',
        'estado': 'Pendiente',
        'estado_pago': 'Pendiente',
        'metodo_pago': 'Transferencia',
        'observaciones': 'Cliente VIP',
        'precio_por_persona': 50.0,
        'precio_total': 150.0,
      };

      final reserva = Reserva.fromJson(json);

      expect(reserva.id, 101);
      expect(reserva.idCliente, 1);
      expect(reserva.idProgramacion, 1);
      expect(reserva.cantidadPersonas, 3);
      expect(reserva.estado, 'Pendiente');
      expect(reserva.estadoPago, 'Pendiente');
      expect(reserva.metodoPago, 'Transferencia');
    });

    test('Reserva.toJson() debería serializar correctamente', () {
      final reserva = ReservaFixture.pendiente();
      final json = reserva.toJson();

      expect(json['id'], 101);
      expect(json['estado'], 'Pendiente');
    });

    test('Precio total debería ser cantidad * precio unitario', () {
      final reserva = ReservaFixture.pendiente();
      final precioCalculado = reserva.cantidadPersonas! * reserva.precioPorPersona!;
      expect(reserva.precioTotal, precioCalculado);
    });

    test('Reserva pendiente debería tener ambos estados "Pendiente"', () {
      final reserva = ReservaFixture.pendiente();
      expect(reserva.estado, 'Pendiente');
      expect(reserva.estadoPago, 'Pendiente');
    });

    test('Reserva confirmada debería tener estado "Confirmada" y pago "Pagado"', () {
      final reserva = ReservaFixture.confirmada();
      expect(reserva.estado, 'Confirmada');
      expect(reserva.estadoPago, 'Pagado');
    });

    test('Reserva cancelada debería tener estado "Cancelada"', () {
      final reserva = ReservaFixture.cancelada();
      expect(reserva.estado, 'Cancelada');
    });

    test('Reserva completada debería tener estado "Completada"', () {
      final reserva = ReservaFixture.completada();
      expect(reserva.estado, 'Completada');
    });

    test('fechaReserva debería parsearse como DateTime', () {
      final reserva = ReservaFixture.pendiente();
      expect(reserva.fechaReserva, isA<DateTime>());
    });

    test('fechaInicio y fechaFin deberían ser DateTime', () {
      final reserva = ReservaFixture.pendiente();
      expect(reserva.fechaInicio, isA<DateTime>());
      expect(reserva.fechaFin, isA<DateTime>());
    });

    test('nombreCliente y apellidoCliente deberían ser válidos', () {
      final reserva = ReservaFixture.pendiente();
      expect(reserva.nombreCliente, isNotNull);
      expect(reserva.apellidoCliente, isNotNull);
    });

    test('Reserva con observaciones null debería manejar correctamente', () {
      final reserva = ReservaFixture.confirmada();
      expect(reserva.observaciones, isNull);
    });

    test('Diferentes métodos de pago debería soportarse', () {
      final reservaPendiente = ReservaFixture.pendiente();
      final reservaConfirmada = ReservaFixture.confirmada();
      final reservaCancelada = ReservaFixture.cancelada();

      expect(
        ['Transferencia', 'Tarjeta', 'Efectivo'].contains(reservaPendiente.metodoPago),
        true,
      );
      expect(
        ['Transferencia', 'Tarjeta', 'Efectivo'].contains(reservaConfirmada.metodoPago),
        true,
      );
      expect(
        ['Transferencia', 'Tarjeta', 'Efectivo'].contains(reservaCancelada.metodoPago),
        true,
      );
    });
  });
}
