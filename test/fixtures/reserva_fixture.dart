import 'package:occitours/models/reserva.dart';

class ReservaFixture {
  /// Reserva de prueba en estado pendiente
  static Reserva pendiente() => Reserva(
        id: 101,
        idCliente: 1,
        nombreCliente: 'Juan',
        apellidoCliente: 'García Ruiz',
        idProgramacion: 1,
        cantidadPersonas: 3,
        fechaReserva: DateTime(2026, 04, 01),
        fechaInicio: DateTime(2026, 04, 15),
        fechaFin: DateTime(2026, 04, 15),
        estado: 'Pendiente',
        estadoPago: 'Pendiente',
        metodoPago: 'Transferencia',
        observaciones: 'Cliente VIP',
        precioPorPersona: 50.0,
        precioTotal: 150.0,
      );

  /// Reserva confirmada y pagada
  static Reserva confirmada() => Reserva(
        id: 102,
        idCliente: 1,
        nombreCliente: 'María',
        apellidoCliente: 'López Sánchez',
        idProgramacion: 2,
        cantidadPersonas: 2,
        fechaReserva: DateTime(2026, 03, 20),
        fechaInicio: DateTime(2026, 04, 10),
        fechaFin: DateTime(2026, 04, 10),
        estado: 'Confirmada',
        estadoPago: 'Pagado',
        metodoPago: 'Tarjeta',
        observaciones: null,
        precioPorPersona: 50.0,
        precioTotal: 100.0,
      );

  /// Reserva cancelada
  static Reserva cancelada() => Reserva(
        id: 103,
        idCliente: 2,
        nombreCliente: 'Carlos',
        apellidoCliente: 'Martínez Pérez',
        idProgramacion: 1,
        cantidadPersonas: 4,
        fechaReserva: DateTime(2026, 03, 10),
        fechaInicio: DateTime(2026, 04, 05),
        fechaFin: DateTime(2026, 04, 05),
        estado: 'Cancelada',
        estadoPago: 'Reembolsado',
        metodoPago: 'Transferencia',
        observaciones: 'Cliente cambió planes',
        motivoCancelacion: 'Cambio de planes',
        precioPorPersona: 50.0,
        precioTotal: 200.0,
      );

  /// Reserva completada
  static Reserva completada() => Reserva(
        id: 104,
        idCliente: 3,
        nombreCliente: 'Ana',
        apellidoCliente: 'González López',
        idProgramacion: 3,
        cantidadPersonas: 5,
        fechaReserva: DateTime(2026, 02, 01),
        fechaInicio: DateTime(2026, 03, 01),
        fechaFin: DateTime(2026, 03, 01),
        estado: 'Completada',
        estadoPago: 'Pagado',
        metodoPago: 'Efectivo',
        observaciones: 'Excelente experiencia',
        precioPorPersona: 75.0,
        precioTotal: 375.0,
      );

  /// Lista de múltiples reservas de prueba
  static List<Reserva> listaPrueba() => [
        pendiente(),
        confirmada(),
        cancelada(),
        completada(),
      ];
}
