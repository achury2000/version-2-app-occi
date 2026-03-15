/// Datos de rutas con información completa
/// Este archivo contiene la información detallada de las rutas
/// Luego será reemplazado por datos del backend

class RutasData {
  static final List<Map<String, dynamic>> rutas = [
    {
      'id': 1,
      'nombre': 'Sendero del Cóndor',
      'ubicacion': 'Occidente Antioqueño',
      'descripcion':
          'Una experiencia única de senderismo a través de paisajes montañosos espectaculares donde avistará cóndores en su hábitat natural. '
          'Ruta desafiante pero gratificante con vistas panorámicas inolvidables.',
      'duracion': 8.0, // en horas
      'distancia': 12.0, // en km
      'precio': 120000, // por persona
      'capacidad': 12,
      'dificultad': 'Difícil',
      'incluye': [
        'Guía certificado',
        'Equipo de seguridad completo',
        'Almuerzo incluido',
        'Snacks y agua',
        'Transporte desde punto de encuentro',
        'Binoculares para avistamiento',
      ],
      'imagen_principal': 'assets/rutas/sendero_condor/principal.jpg',
      'zonas_paso': [
        'Laguna de la Virgen - Inicio a 2100m',
        'Campamento Alto - Descanso a 2800m',
        'Mirador del Cóndor - Punto máximo a 3200m',
        'Retorno por sendero alternativo',
      ],
      'mejor_epoca': 'Diciembre a Marzo',
      'equipo_necesario': [
        'Botas de senderismo impermeables',
        'Ropa abrigada',
        'Capa impermeable',
        'Gafas de sol',
        'Bloqueador solar',
        'Botella de agua reutilizable',
      ],
      'requisitos': 'Condición física alta, experiencia en alturas',
      'restricciones': 'Mayores de 16 años, certificado médico recomendado',
    },
  ];

  /// Obtener ruta por ID
  static Map<String, dynamic>? getRutaById(int id) {
    try {
      return rutas.firstWhere((ruta) => ruta['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener todas las rutas
  static List<Map<String, dynamic>> getAllRutas() {
    return rutas;
  }

  /// Buscar rutas por dificultad
  static List<Map<String, dynamic>> getRutasByDifficulty(String dificultad) {
    return rutas.where((r) => r['dificultad'] == dificultad).toList();
  }

  /// Filtrar rutas por precio máximo
  static List<Map<String, dynamic>> getRutasByMaxPrice(double maxPrice) {
    return rutas.where((r) => (r['precio'] ?? 0) <= maxPrice).toList();
  }
}

