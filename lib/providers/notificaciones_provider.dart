import 'package:flutter/material.dart';
import 'dart:async';
import '../models/notificacion.dart';

class NotificacionesProvider extends ChangeNotifier {
  final List<Notificacion> _notificaciones = [];
  final Map<String, Timer> _timers = {};

  // Getters
  List<Notificacion> get notificaciones => _notificaciones;
  List<Notificacion> get noLeidas =>
      _notificaciones.where((n) => !n.leida).toList();
  int get cantidadNoLeidas => noLeidas.length;

  /// Mostrar una notificación de éxito
  void mostrarExito({
    required String titulo,
    required String mensaje,
    Duration duracion = const Duration(seconds: 3),
  }) {
    mostrarNotificacion(
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoNotificacion.exito,
      duracion: duracion,
    );
  }

  /// Mostrar una notificación de error
  void mostrarError({
    required String titulo,
    required String mensaje,
    Duration duracion = const Duration(seconds: 5),
  }) {
    mostrarNotificacion(
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoNotificacion.error,
      duracion: duracion,
    );
  }

  /// Mostrar una notificación de advertencia
  void mostrarAdvertencia({
    required String titulo,
    required String mensaje,
    Duration duracion = const Duration(seconds: 4),
  }) {
    mostrarNotificacion(
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoNotificacion.advertencia,
      duracion: duracion,
    );
  }

  /// Mostrar una notificación de información
  void mostrarInfo({
    required String titulo,
    required String mensaje,
    Duration duracion = const Duration(seconds: 4),
  }) {
    mostrarNotificacion(
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoNotificacion.info,
      duracion: duracion,
    );
  }

  /// Mostrar una notificación genérica
  void mostrarNotificacion({
    required String titulo,
    required String mensaje,
    required TipoNotificacion tipo,
    Duration duracion = const Duration(seconds: 4),
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final notificacion = Notificacion(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      fechaCreacion: DateTime.now(),
      duracionAuto: duracion,
    );

    _notificaciones.add(notificacion);
    notifyListeners();

    // Auto-desaparecer tras duración especificada
    final timer = Timer(duracion, () {
      removerNotificacion(id);
    });

    _timers[id] = timer;
  }

  /// Marcar notificación como leída
  void marcarComoLeida(String id) {
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notificaciones[index].leida = true;
      notifyListeners();
    }
  }

  /// Remover una notificación
  void removerNotificacion(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    _notificaciones.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Limpiar todas las notificaciones
  void limpiarTodas() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _notificaciones.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancelar todos los timers
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    super.dispose();
  }
}
