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
    {
      'id': 2,
      'nombre': 'Tour del Chocolate',
      'ubicacion': 'Occidente Antioqueño',
      'descripcion':
          'Una experiencia que nos sumerge en las verdaderas tradiciones y costumbres antioqueñas. A través del cacao, fruto insignia de la región, '
          'conocerás su proceso de transformación y la historia campesina que lo rodea, mientras compartes con las comunidades locales y disfrutas de los sabores '
          'auténticos de nuestra tierra. Todo nuestro proceso es 100% artesanal.\n\n'
          'Durante el recorrido podrás conocer enteramente cómo es el cultivo del cacao, desde su siembra hasta su cosecha. Además realizaremos una cata de granos '
          'de cacao en fresco, todo el proceso de transformación, y podrás disfrutar de un delicioso almuerzo campesino.',
      'duracion': 3.0, // en horas
      'distancia': 5.0, // en km aprox
      'precio': 75000, // por persona
      'capacidad': 15,
      'dificultad': 'Fácil',
      'incluye': [
        'Guía especializado en cacao',
        'Almuerzo campesino auténtico',
        'Cata de granos de cacao en fresco',
        'Demostración del proceso de transformación',
        'Souvenirs artesanales de cacao',
        'Experiencia de cultivo interactivo',
      ],
      'imagen_principal': 'assets/rutas/tour_del_chocolate/principal.png',
      'zonas_paso': [
        'Bienvenida y recorrido por el cultivo de cacao',
        'Observación de granos frescos y proceso de secado',
        'Transformación artesanal del cacao',
        'Almuerzo campesino y degustación',
      ],
      'mejor_epoca': 'Todo el año',
      'equipo_necesario': [
        'Ropa cómoda y ligera',
        'Zapatos para caminar en terreno irregular',
        'Sombrero o gorro',
        'Bloqueador solar',
        'Repelente para insectos',
        'Botella de agua reutilizable',
      ],
      'requisitos': 'Ninguno, apto para todas las edades',
      'restricciones': 'Ninguna restricción',
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

