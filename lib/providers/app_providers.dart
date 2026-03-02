import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TourProvider extends ChangeNotifier {
  // final ApiService _apiService = ApiService(); // No usado en versión simplificada

  List<Tour> _tours = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Tour> get tours => _tours;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Obtener todos los tours
  Future<void> fetchTours() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Aquí llamarías a tu API
      // final response = await _apiService.get('tours');
      // _tours = (response as List)
      //     .map((tour) => Tour.fromJson(tour))
      //     .toList();

      // Por ahora, usamos datos de ejemplo
      _tours = [
        Tour(
          id: '1',
          name: 'Tour por Barcelona',
          description: 'Explora la hermosa ciudad de Barcelona',
          image: 'assets/images/barcelona.jpg',
          rating: 4.8,
          price: 99.99,
          location: 'Barcelona, España',
          duration: '4 horas',
        ),
        Tour(
          id: '2',
          name: 'Tour por París',
          description: 'Visita los lugares icónicos de París',
          image: 'assets/images/paris.jpg',
          rating: 4.9,
          price: 129.99,
          location: 'París, Francia',
          duration: '6 horas',
        ),
      ];
    } catch (e) {
      _errorMessage = 'Error al cargar los tours: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un tour específico
  Future<Tour?> getTourById(String id) async {
    try {
      // final response = await _apiService.get('tours/$id');
      // return Tour.fromJson(response);
      return _tours.firstWhere((tour) => tour.id == id);
    } catch (e) {
      _errorMessage = 'Error al cargar el tour: $e';
      notifyListeners();
      return null;
    }
  }

  // Buscar tours por criterios
  Future<void> searchTours(String query) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // final response = await _apiService.get('tours/search?q=$query');
      // _tours = (response as List)
      //     .map((tour) => Tour.fromJson(tour))
      //     .toList();
    } catch (e) {
      _errorMessage = 'Error en la búsqueda: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Implementar lógica de login
      _currentUser = User(
        id: '1',
        name: 'Usuario',
        email: email,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  // Signup
  Future<void> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = User(
        id: '1',
        name: name,
        email: email,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
