import 'package:flutter/material.dart';
import '../models/programacion.dart';
import '../services/programacion_service.dart';

/// Provider para gestionar el estado de Programaciones.
///
/// Responsable de:
/// - Cargar programaciones disponibles
/// - Filtrar y buscar programaciones
/// - Gestionar estado de carga y errores
class ProgramacionProvider extends ChangeNotifier {
  final ProgramacionService _programacionService = ProgramacionService();

  // Estado de programaciones
  List<Programacion> _programaciones = [];
  Programacion? _programacionSeleccionada;
  bool _isLoading = false;
  String? _error;

  // Para búsqueda y filtros
  List<Programacion> _programacionesFiltradas = [];
  String _queryBusqueda = '';
  String _filtroEstado = 'activa'; // Por defecto mostrar solo activas
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  int? _filtroIdRuta;

  // Getters públicos
  List<Programacion> get programaciones =>
      _programacionesFiltradas.isEmpty ? _programaciones : _programacionesFiltradas;
  Programacion? get programacionSeleccionada => _programacionSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get tieneProgramaciones => _programaciones.isNotEmpty;

  // Getters para filtros
  String get queryBusqueda => _queryBusqueda;
  String get filtroEstado => _filtroEstado;
  DateTime? get fechaDesde => _fechaDesde;
  DateTime? get fechaHasta => _fechaHasta;
  int? get filtroIdRuta => _filtroIdRuta;

  /// Obtener mapa de filtros actuales
  Map<String, dynamic> get filtros => {
        'estado': _filtroEstado,
        'busqueda': _queryBusqueda,
        'fechaDesde': _fechaDesde,
        'fechaHasta': _fechaHasta,
        'idRuta': _filtroIdRuta,
      };

  /// Cargar todas las programaciones disponibles
  Future<void> cargarProgramaciones() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _programaciones = await _programacionService.getDisponibles();

      // Ordenar por fecha más cercana primero
      _programaciones.sort((a, b) {
        final aDate = a.fechaSalida ?? DateTime(2099);
        final bDate = b.fechaSalida ?? DateTime(2099);
        return aDate.compareTo(bDate);
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cargar programaciones: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Cargar programaciones de una ruta específica
  Future<void> cargarProgramacionesDeRuta(int idRuta) async {
    try {
      _isLoading = true;
      _error = null;
      _filtroIdRuta = idRuta;
      notifyListeners();

      _programaciones = await _programacionService.getByRuta(idRuta);

      _isLoading = false;
      aplicarFiltros();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cargar programaciones: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Obtener detalle de una programación
  Future<void> cargarDetalleProgramacion(int idProgramacion) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _programacionSeleccionada =
          await _programacionService.getById(idProgramacion);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cargar detalle: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Aplicar filtros y búsqueda
  void aplicarFiltros() {
    _programacionesFiltradas = _programaciones.where((prog) {
      // Filtro por estado (por defecto activa)
      if (_filtroEstado.isNotEmpty) {
        if ((prog.estado ?? '').toLowerCase() != _filtroEstado.toLowerCase()) {
          return false;
        }
      }

      // Filtro por búsqueda (nombre de ruta)
      if (_queryBusqueda.isNotEmpty) {
        final nombre = (prog.nombreRuta ?? '').toLowerCase();
        final busca = _queryBusqueda.toLowerCase();

        if (!nombre.contains(busca)) {
          return false;
        }
      }

      // Filtro por fecha desde
      if (_fechaDesde != null && prog.fechaSalida != null) {
        if (prog.fechaSalida!.isBefore(_fechaDesde!)) {
          return false;
        }
      }

      // Filtro por fecha hasta
      if (_fechaHasta != null && prog.fechaSalida != null) {
        if (prog.fechaSalida!.isAfter(_fechaHasta!)) {
          return false;
        }
      }

      // Filtro por ruta
      if (_filtroIdRuta != null && prog.idRuta != _filtroIdRuta) {
        return false;
      }

      // Filtro: Solo mostrar con cupos disponibles
      if (!prog.tieneCupos) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Establecer búsqueda por nombre
  void setBusqueda(String query) {
    _queryBusqueda = query;
    aplicarFiltros();
  }

  /// Establecer filtro por estado
  void setFiltroEstado(String estado) {
    _filtroEstado = estado;
    aplicarFiltros();
  }

  /// Establecer rango de fechas
  void setRangoFechas(DateTime? desde, DateTime? hasta) {
    _fechaDesde = desde;
    _fechaHasta = hasta;
    aplicarFiltros();
  }

  /// Limpiar todos los filtros
  void limpiarFiltros() {
    _queryBusqueda = '';
    _filtroEstado = 'activa';
    _fechaDesde = null;
    _fechaHasta = null;
    _filtroIdRuta = null;
    _programacionesFiltradas = [];
    notifyListeners();
  }

  /// Obtener programaciones con cupos disponibles
  List<Programacion> obtenerConCuposDisponibles() {
    return _programaciones.where((prog) => prog.tieneCupos).toList();
  }

  /// Verificar si una programación tiene cupos para X personas
  bool tieneCapacidad(int idProgramacion, int personas) {
    final prog = _programaciones.firstWhere(
      (p) => p.id == idProgramacion,
      orElse: () => Programacion(id: -1),
    );

    if (prog.id == -1) return false;
    return (prog.cuposDisponibles ?? 0) >= personas;
  }

  /// Obtener precio de una programación
  double? obtenerPrecio(int idProgramacion) {
    final prog = _programaciones.firstWhere(
      (p) => p.id == idProgramacion,
      orElse: () => Programacion(id: -1),
    );

    if (prog.id == -1) return null;
    return prog.precio;
  }

  /// Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  /// Limpiar selección
  void limpiarSeleccion() {
    _programacionSeleccionada = null;
    notifyListeners();
  }
}
