import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../services/reserva_service.dart';

class ReservaProvider extends ChangeNotifier {
  final ReservaService _reservaService = ReservaService();

  // Estado de reservas del cliente
  List<Reserva> _reservas = [];
  bool _isLoading = false;
  String? _error;

  // Para búsqueda y filtros
  List<Reserva> _reservasFiltradas = [];
  String _filtroEstado = '';
  String _queryBusqueda = '';
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  // Getters públicos
  List<Reserva> get reservas => _reservasFiltradas.isEmpty ? _reservas : _reservasFiltradas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get tieneReservas => _reservas.isNotEmpty;

  // Getters para filtros
  String get filtroEstado => _filtroEstado;
  String get queryBusqueda => _queryBusqueda;
  DateTime? get fechaDesde => _fechaDesde;
  DateTime? get fechaHasta => _fechaHasta;

  /// Cargar reservas del cliente
  Future<void> cargarReservas({required int idCliente}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _reservas = await _reservaService.getByCliente(idCliente);

      // Ordenar por fecha más reciente primero
      _reservas.sort((a, b) {
        final aDate = a.fechaReserva ?? a.fechaInicio ?? DateTime(1970);
        final bDate = b.fechaReserva ?? b.fechaInicio ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cargar reservas: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Aplicar filtros y búsqueda
  void aplicarFiltros() {
    _reservasFiltradas = _reservas.where((reserva) {
      // Filtro por estado
      if (_filtroEstado.isNotEmpty) {
        if ((reserva.estado ?? '').toLowerCase() != _filtroEstado.toLowerCase()) {
          return false;
        }
      }

      // Filtro por búsqueda (ID o nombre del cliente)
      if (_queryBusqueda.isNotEmpty) {
        final idStr = reserva.id.toString();
        final nombre = (reserva.nombreCliente ?? '').toLowerCase();
        final busca = _queryBusqueda.toLowerCase();

        if (!idStr.contains(busca) && !nombre.contains(busca)) {
          return false;
        }
      }

      // Filtro por fecha desde
      if (_fechaDesde != null && reserva.fechaInicio != null) {
        if (reserva.fechaInicio!.isBefore(_fechaDesde!)) {
          return false;
        }
      }

      // Filtro por fecha hasta
      if (_fechaHasta != null && reserva.fechaFin != null) {
        if (reserva.fechaFin!.isAfter(_fechaHasta!)) {
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

  /// Establecer rango de fechas
  void setRangoFechas(DateTime? desde, DateTime? hasta) {
    _fechaDesde = desde;
    _fechaHasta = hasta;
    aplicarFiltros();
  }

  /// Limpiar todos los filtros
  void limpiarFiltros() {
    _filtroEstado = '';
    _queryBusqueda = '';
    _fechaDesde = null;
    _fechaHasta = null;
    _reservasFiltradas = [];
    notifyListeners();
  }

  /// Obtener detalle de una reserva
  Future<Reserva> obtenerDetalle(int idReserva) async {
    try {
      return await _reservaService.getById(idReserva);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estadísticas de reservas
  Map<String, int> obtenerEstadisticas() {
    return {
      'total': _reservas.length,
      'activas': _reservas.where((r) => r.estaActiva).length,
      'canceladas': _reservas.where((r) => (r.estado ?? '').toLowerCase() == 'cancelada').length,
      'completadas': _reservas.where((r) => (r.estado ?? '').toLowerCase() == 'completada').length,
    };
  }

  /// Cancelar una reserva con motivo opcional
  Future<void> cancelarReserva(int idReserva, {String? motivo}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final reservaActualizada = await _reservaService.cancelar(idReserva, motivo: motivo);

      // Actualizar lista local con la reserva actualizada del backend
      final index = _reservas.indexWhere((r) => r.id == idReserva);
      if (index >= 0) {
        _reservas[index] = reservaActualizada;
      }

      _isLoading = false;
      aplicarFiltros();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al cancelar reserva: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Crear una nueva reserva
  Future<void> crearReserva({
    required int idCliente,
    required int idProgramacion,
    required int cantidadPersonas,
    String? metodoPago,
    String? observaciones,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final nuevaReserva = await _reservaService.crear(
        idCliente: idCliente,
        idProgramacion: idProgramacion,
        cantidadPersonas: cantidadPersonas,
        metodoPago: metodoPago,
        observaciones: observaciones,
      );

      // Agregar a la lista local
      _reservas.insert(0, nuevaReserva);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Error al crear reserva: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Comparar si la reserva puede ser editada
  bool puedeEditarse(Reserva reserva) {
    if (reserva.estado == null) return false;

    final estado = reserva.estado!.toLowerCase();
    // Solo se pueden editar reservas pendientes o confirmadas, no canceladas/completadas
    return estado != 'cancelada' && estado != 'completada';
  }

  /// Iniciar una reserva con programación seleccionada (para PHASE 4)
  void iniciarReservaConProgramacion({
    required int idProgramacion,
    required String? nombreRuta,
    required double? precio,
  }) {
    // Este método prepara el estado para la creación de una new reserva
    // Será usado en el flujo de check-in en PHASE 4
    _error = null;
    notifyListeners();
  }

  /// Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}

extension ReservaX on Reserva {
  Reserva copyWith({
    int? id,
    int? idCliente,
    String? nombreCliente,
    String? apellidoCliente,
    int? idProgramacion,
    DateTime? fechaReserva,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? cantidadPersonas,
    double? precioTotal,
    double? precioPorPersona,
    String? estado,
    String? estadoPago,
    String? metodoPago,
    String? comprobantePago,
    String? observaciones,
    String? motivoCancelacion,
    List<dynamic>? programaciones,
    List<dynamic>? fincas,
    List<dynamic>? servicios,
    List<dynamic>? acompanantes,
  }) {
    return Reserva(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      apellidoCliente: apellidoCliente ?? this.apellidoCliente,
      idProgramacion: idProgramacion ?? this.idProgramacion,
      fechaReserva: fechaReserva ?? this.fechaReserva,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      cantidadPersonas: cantidadPersonas ?? this.cantidadPersonas,
      precioTotal: precioTotal ?? this.precioTotal,
      precioPorPersona: precioPorPersona ?? this.precioPorPersona,
      estado: estado ?? this.estado,
      estadoPago: estadoPago ?? this.estadoPago,
      metodoPago: metodoPago ?? this.metodoPago,
      comprobantePago: comprobantePago ?? this.comprobantePago,
      observaciones: observaciones ?? this.observaciones,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      programaciones: programaciones ?? this.programaciones,
      fincas: fincas ?? this.fincas,
      servicios: servicios ?? this.servicios,
      acompanantes: acompanantes ?? this.acompanantes,
    );
  }
}
