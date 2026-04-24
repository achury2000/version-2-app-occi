import 'package:flutter/material.dart';
import '../models/espacio.dart';
import '../services/espacio_service.dart';

/// Provider para gestionar espacios/amenidades
class EspacioProvider extends ChangeNotifier {
  final EspacioService _service = EspacioService();

  List<Espacio> _espacios = [];
  List<Espacio> _espaciosFiltrados = [];
  bool _isLoading = false;
  String? _error;
  String _filtro = '';

  // Getters
  List<Espacio> get espacios => _espacios;
  List<Espacio> get espaciosFiltrados => _espaciosFiltrados;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get tieneEspacios => _espacios.isNotEmpty;

  /// Cargar todos los espacios
  Future<void> cargarEspacios() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _espacios = await _service.obtenerEspacios();
      _espaciosFiltrados = List.from(_espacios);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cargar espacios: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Filtrar espacios por nombre
  void filtrarEspacios(String filtro) {
    _filtro = filtro.toLowerCase();
    if (_filtro.isEmpty) {
      _espaciosFiltrados = List.from(_espacios);
    } else {
      _espaciosFiltrados = _espacios
          .where((e) =>
              e.nombre.toLowerCase().contains(_filtro) ||
              (e.descripcion?.toLowerCase().contains(_filtro) ?? false))
          .toList();
    }
    notifyListeners();
  }

  /// Obtener espacio por ID
  Future<Espacio> obtenerEspacioById(int id) async {
    try {
      return await _service.obtenerEspacioById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nuevo espacio
  Future<Espacio> crearEspacio({
    required String nombre,
    String? descripcion,
    String? icono,
    double? precio,
  }) async {
    try {
      final nuevoEspacio = await _service.crearEspacio(
        nombre: nombre,
        descripcion: descripcion,
        icono: icono,
        precio: precio,
      );
      _espacios.add(nuevoEspacio);
      filtrarEspacios(_filtro);
      notifyListeners();
      return nuevoEspacio;
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar espacio
  Future<Espacio> actualizarEspacio({
    required int id,
    required String nombre,
    String? descripcion,
    String? icono,
    double? precio,
    required bool disponible,
  }) async {
    try {
      final espacioActualizado = await _service.actualizarEspacio(
        id: id,
        nombre: nombre,
        descripcion: descripcion,
        icono: icono,
        precio: precio,
        disponible: disponible,
      );
      final index = _espacios.indexWhere((e) => e.id == id);
      if (index >= 0) {
        _espacios[index] = espacioActualizado;
        filtrarEspacios(_filtro);
      }
      notifyListeners();
      return espacioActualizado;
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar espacio
  Future<void> eliminarEspacio(int id) async {
    try {
      await _service.eliminarEspacio(id);
      _espacios.removeWhere((e) => e.id == id);
      filtrarEspacios(_filtro);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
