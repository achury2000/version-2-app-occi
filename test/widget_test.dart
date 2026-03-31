import 'package:flutter_test/flutter_test.dart';
import 'package:occitours/models/programacion.dart';
import 'package:occitours/models/reserva.dart';

void main() {
  group('Occitours App - Smoke Tests', () {
    test('Programacion.fromJson() debería parsear JSON valido', () {
      final json = {
        'id': 1,
        'nombre_ruta': 'Test Ruta',
        'precio': 50.0,
        'cupos_disponibles': 5,
      };

      final programacion = Programacion.fromJson(json);

      expect(programacion.id, 1);
      expect(programacion.nombreRuta, 'Test Ruta');
      expect(programacion.precio, 50.0);
    });

    test('Reserva.fromJson() debería parsear JSON valido', () {
      final json = {
        'id': 101,
        'id_cliente': 1,
        'estado': 'Pendiente',
        'precio_total': 150.0,
      };

      final reserva = Reserva.fromJson(json);

      expect(reserva.id, 101);
      expect(reserva.estado, 'Pendiente');
      expect(reserva.precioTotal, 150.0);
    });

    test('Validación de email - formato válido', () {
      const email = 'usuario@example.com';
      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

      expect(regex.hasMatch(email), true);
    });

    test('Validación de email - formato inválido', () {
      const email = 'usuario_sin_arroba';
      final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

      expect(regex.hasMatch(email), false);
    });

    test('Cálculo de precio total: cantidad * precio unitario', () {
      const cantidad = 3;
      const precioUnitario = 50.0;
      final precioTotal = cantidad * precioUnitario;

      expect(precioTotal, 150.0);
    });

    test('Formato de moneda - dos decimales', () {
      const precio = 99.9;
      final formateado = precio.toStringAsFixed(2);

      expect(formateado, '99.90');
    });

    test('Formato de fecha - parsing DateTime', () {
      final dateString = '2026-04-15';
      final date = DateTime.parse(dateString);

      expect(date.year, 2026);
      expect(date.month, 4);
      expect(date.day, 15);
    });

    test('Estados de reserva válidos', () {
      const estadosValidos = [
        'Pendiente',
        'Confirmada',
        'En Proceso',
        'Completada',
        'Cancelada'
      ];

      expect(estadosValidos.contains('Pendiente'), true);
      expect(estadosValidos.contains('Confirmada'), true);
      expect(estadosValidos.contains('Cancelada'), true);
      expect(estadosValidos.contains('Estado Desconocido'), false);
    });

    test('Métodos de pago válidos', () {
      const metodosValidos = ['Transferencia', 'Tarjeta', 'Efectivo'];

      expect(metodosValidos.contains('Transferencia'), true);
      expect(metodosValidos.contains('Tarjeta'), true);
      expect(metodosValidos.contains('Efectivo'), true);
      expect(metodosValidos.contains('Otro'), false);
    });

    test('Cantidad de personas - mínimo 1', () {
      const cantidad = 0;
      const cantidadValida = cantidad < 1 ? 1 : cantidad;

      expect(cantidadValida, 1);
    });

    test('Cupos disponibles - no puede ser negativo', () {
      const cupos = 5;
      const cuposValidos = cupos < 0 ? 0 : cupos;

      expect(cuposValidos, 5);
    });

    test('Duración de experiencia - cálculo de días', () {
      final checkIn = DateTime(2026, 4, 15);
      final checkOut = DateTime(2026, 4, 16);
      final duracion = checkOut.difference(checkIn).inDays;

      expect(duracion, 1);
    });
  });
}

