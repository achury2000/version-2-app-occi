import 'package:flutter/material.dart';

/// Modelo para notificaciones in-app
class Notificacion {
  final String id;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final DateTime? fechaCreacion;
  bool leida;
  final Duration duracionAuto;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.fechaCreacion,
    this.leida = false,
    this.duracionAuto = const Duration(seconds: 4),
  });

  /// Obtener color basado en tipo
  Color get color {
    switch (tipo) {
      case TipoNotificacion.exito:
        return Colors.green;
      case TipoNotificacion.error:
        return Colors.red;
      case TipoNotificacion.advertencia:
        return Colors.orange;
      case TipoNotificacion.info:
        return Colors.blue;
    }
  }

  /// Obtener icono basado en tipo
  IconData get icono {
    switch (tipo) {
      case TipoNotificacion.exito:
        return Icons.check_circle;
      case TipoNotificacion.error:
        return Icons.error;
      case TipoNotificacion.advertencia:
        return Icons.warning;
      case TipoNotificacion.info:
        return Icons.info;
    }
  }
}

enum TipoNotificacion { exito, error, advertencia, info }
