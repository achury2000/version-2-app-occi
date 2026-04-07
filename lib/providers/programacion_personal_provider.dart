import 'package:flutter/material.dart';
import '../models/programacion_personal.dart';
import '../services/programacion_personal_service.dart';

class ProgramacionPersonalProvider extends ChangeNotifier {
  final ProgramacionPersonalService _service = ProgramacionPersonalService();

  // Estado de programaciones personales del cliente
  List<ProgramacionPersonal> _programaciones = [];
  bool _isLoading = false;
  String? _error;

  // Para búsqueda y filtros
  List<ProgramacionPersonal> _programacionesFiltradas = [];
  String _filtroEstado = ''; // pendiente, completada, todas
  String _queryBusqueda = '';

  // Getters públicos
  List<ProgramacionPersonal> get programaciones =>
      _programacionesFiltradas.isEmpty ? _programaciones : _programacionesFiltradas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get tieneProgramaciones => _programaciones.isNotEmpty;

  // Estadísticas
  int get totalProgramaciones => _programaciones.length;
  int get pendientes => _programaciones.where((p) => p.estaPendiente).length;
  int get completadas => _programaciones.where((p) => p.estaCompletada).length;

  // Getters para filtros
  String get filtroEstado => _filtroEstado;
  String get queryBusqueda => _queryBusqueda;

  /// Cargar programaciones personales del cliente
  Future<void> cargarProgramaciones({required int idCliente}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _programaciones = await _service.getByCliente(idCliente);

      // Ordenar por fecha más próxima primero
      _programaciones.sort((a, b) {
        final aDate = a.fechaProgramacion ?? DateTime(9999);
        final bDate = b.fechaProgramacion ?? DateTime(9999);
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

  /// Aplicar filtros y búsqueda
  void aplicarFiltros() {
    _programacionesFiltradas = _programaciones.where((prog) {
      // Filtro por estado
      if (_filtroEstado.isNotEmpty && _filtroEstado != 'todas') {
        if (_filtroEstado == 'pendiente' && !prog.estaPendiente) {
          return false;
        }
        if (_filtroEstado == 'completada' && !prog.estaCompletada) {
          return false;
        }
      }

      // Filtro por búsqueda (título o descripción)
      if (_queryBusqueda.isNotEmpty) {
        final titulo = prog.titulo.toLowerCase();
        final descripcion = (prog.descripcion ?? '').toLowerCase();
        final busca = _queryBusqueda.toLowerCase();

        if (!titulo.contains(busca) && !descripcion.contains(busca)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// Establecer filtro por estado
  void setFiltroEstado(String estado) {
    _filtroEstado = estado;
    aplicarFiltros();
  }

  /// Establecer búsqueda
  void setBusqueda(String query) {
    _queryBusqueda = query;
    aplicarFiltros();
  }

  /// Limpiar filtros
  void limpiarFiltros() {
    _filtroEstado = '';
    _queryBusqueda = '';
    _programacionesFiltradas = [];
    notifyListeners();
  }

  /// Crear una nueva programación personal
  Future<void> crearProgramacion({
    required int idCliente,
    required String titulo,
    String? descripcion,
    DateTime? fechaProgramacion,
    String? horaProgramacion,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final nueva = await _service.crear(
        idCliente: idCliente,
        titulo: titulo,
        descripcion: descripcion,
        fechaProgramacion: fechaProgramacion,
        horaProgramacion: horaProgramacion,
      );

      _programaciones.add(nueva);

      // Re-ordenar
      _programaciones.sort((a, b) {
        final aDate = a.fechaProgramacion ?? DateTime(9999);
        final bDate = b.fechaProgramacion ?? DateTime(9999);
        return aDate.compareTo(bDate);
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al crear programación: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Actualizar una programación personal
  Future<void> actualizarProgramacion({
    required int id,
    String? titulo,
    String? descripcion,
    DateTime? fechaProgramacion,
    String? horaProgramacion,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final actualizada = await _service.actualizar(
        id: id,
        titulo: titulo,
        descripcion: descripcion,
        fechaProgramacion: fechaProgramacion,
        horaProgramacion: horaProgramacion,
      );

      // Actualizar en la lista
      final index = _programaciones.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _programaciones[index] = actualizada;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al actualizar programación: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Marcar una programación como completada
  Future<void> marcarCompletada(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final completada = await _service.marcarCompletada(id);

      // Actualizar en la lista
      final index = _programaciones.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _programaciones[index] = completada;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al marcar como completada: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Eliminar una programación personal con confirmación
  Future<void> eliminarProgramacion(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.eliminar(id);

      // Remover de la lista
      _programaciones.removeWhere((p) => p.id == id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al eliminar programación: $e';
      notifyListeners();
      rethrow;
    }
  }
}
