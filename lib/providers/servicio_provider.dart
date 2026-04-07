import 'package:flutter/material.dart';
import '../models/servicio.dart';
import '../services/servicio_service.dart';
import '../data/servicios_data.dart';

/// Provider para manejar el estado de Servicios
/// Maneja carga desde API, filtrado y selección de servicios
class ServicioProvider extends ChangeNotifier {
  final ServicioService _service = ServicioService();

  List<Servicio> _servicios = [];
  List<Servicio> _serviciosFiltrados = [];
  List<int> _serviciosSeleccionados = [];
  bool _isLoading = false;
  bool _usandoApiReal = false;
  String? _error;

  // Getters
  List<Servicio> get servicios => _servicios;
  List<Servicio> get serviciosFiltrados => _serviciosFiltrados;
  List<Servicio> get serviciosSeleccionados => _servicios
      .where((s) => _serviciosSeleccionados.contains(s.id))
      .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get usandoApiReal => _usandoApiReal;

  /// Calcular precio total de servicios seleccionados
  double get totalServiciosSeleccionados {
    return serviciosSeleccionados.fold(0, (sum, s) => sum + s.precio);
  }

  /// Cargar servicios desde API real
  /// Intenta conectar con backend, si falla usa datos locales
  Future<void> cargarServicios() async {
    _isLoading = true;
    _error = null;
    _usandoApiReal = false;
    notifyListeners();

    try {
      // Intentar cargar desde API
      _servicios = await _service.obtenerServiciosDisponibles();
      _usandoApiReal = true;
      _serviciosFiltrados = List.from(_servicios);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Si falla, usar datos locales como fallback
      debugPrint('Error al conectar con API: $e. Usando datos locales...');
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        _servicios = serviciosData;
        _serviciosFiltrados = List.from(_servicios);
        _usandoApiReal = false;
      } catch (fallbackError) {
        _error = 'Error al cargar servicios: $fallbackError';
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cargar servicios de un tipo específico desde la API
  Future<void> cargarServiciosPorTipo(String tipo) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _servicios = await _service.obtenerServiciosPorTipo(tipo);
      _serviciosFiltrados = List.from(_servicios);
      _usandoApiReal = true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar servicios por tipo: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recargar datos desde API (manual refresh)
  Future<void> recargarDatos() async {
    return cargarServicios();
  }

  /// Filtrar servicios por nombre o descripción
  void filtrarServicios(String query) {
    if (query.isEmpty) {
      _serviciosFiltrados = List.from(_servicios);
    } else {
      final queryLower = query.toLowerCase();
      _serviciosFiltrados = _servicios
          .where((s) =>
              s.nombre.toLowerCase().contains(queryLower) ||
              s.descripcion.toLowerCase().contains(queryLower))
          .toList();
    }
    notifyListeners();
  }

  /// Seleccionar/deseleccionar un servicio
  void toggleSeleccionServicio(int servicioId) {
    if (_serviciosSeleccionados.contains(servicioId)) {
      _serviciosSeleccionados.remove(servicioId);
    } else {
      _serviciosSeleccionados.add(servicioId);
    }
    notifyListeners();
  }

  /// Verificar si un servicio está seleccionado
  bool estaSeleccionado(int servicioId) {
    return _serviciosSeleccionados.contains(servicioId);
  }

  /// Agregar múltiples servicios
  void agregarServicios(List<int> servicioIds) {
    for (final id in servicioIds) {
      if (!_serviciosSeleccionados.contains(id)) {
        _serviciosSeleccionados.add(id);
      }
    }
    notifyListeners();
  }

  /// Remover múltiples servicios
  void removerServicios(List<int> servicioIds) {
    _serviciosSeleccionados
        .removeWhere((id) => servicioIds.contains(id));
    notifyListeners();
  }

  /// Limpiar todos los servicios seleccionados
  void limpiarSeleccion() {
    _serviciosSeleccionados.clear();
    notifyListeners();
  }

  /// Obtener servicio por ID
  Servicio? obtenerServicioPorId(int id) {
    try {
      return _servicios.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener servicios seleccionados como lista de IDs
  List<int> get idsServiciosSeleccionados => List.from(_serviciosSeleccionados);

  /// Cargar servicios seleccionados desde lista de IDs
  void cargarServiciosSeleccionados(List<int> ids) {
    _serviciosSeleccionados = List.from(ids);
    notifyListeners();
  }

  /// Resetear estado (por ejemplo, al crear nueva reserva)
  void reset() {
    _serviciosSeleccionados.clear();
    _serviciosFiltrados = List.from(_servicios);
    _error = null;
    notifyListeners();
  }
}
