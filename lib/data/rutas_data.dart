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
    {
      'id': 3,
      'nombre': 'Tour de cata de vinos',
      'ubicacion': 'Occidente Antioqueño',
      'descripcion':
          'El mejor vino de Colombia y de los mejores del mundo en una experiencia única. En las montañas de Antioquia existe un lugar donde se producen vinos tan '
          'finos que han conquistado el mundo. Un destino exclusivo donde la naturaleza, la tradición y la innovación se unen para crear verdaderas joyas en cada copa.\n\n'
          'Caminarás entre viñedos sorprendentes, descubrirás el proceso que transforma la uva en arte líquido, visitarás el Salón de la Fama repleto de premios '
          'internacionales y terminarás con una cata profesional que despertará todos tus sentidos.\n\n'
          'Aquí no solo pruebas vino. Vives una experiencia memorable, sofisticada y auténticamente colombiana. Un lugar que no se cuenta... se vive.',
      'duracion': 3.0, // en horas
      'distancia': 7.0, // en km aprox
      'precio': 90000, // por persona
      'capacidad': 15,
      'dificultad': 'Fácil',
      'incluye': [
        'Guía sommelier especializado',
        'Acceso a viñedos privados',
        'Cata de vinos profesional',
        'Maridaje gourmet',
        'Visita al Salón de la Fama',
        'Degustación de vinos premium',
      ],
      'imagen_principal': 'assets/rutas/tour_cata_vinos/principal.png',
      'zonas_paso': [
        'Recepción y bienvenida en la bodega',
        'Recorrido por los viñedos',
        'Explicación del proceso de producción',
        'Visita al Salón de la Fama',
        'Cata profesional y maridaje',
      ],
      'mejor_epoca': 'Todo el año',
      'equipo_necesario': [
        'Ropa casual y elegante',
        'Zapatos cómodos',
        'Protección solar',
        'Chaqueta ligera (noches pueden ser frías)',
      ],
      'requisitos': 'Mayores de 18 años',
      'restricciones': 'Personas mayores de 18 años, no se permite conducir después de la cata',
    },
    {
      'id': 4,
      'nombre': 'Tours de tres cascadas',
      'ubicacion': 'Occidente Antioqueño',
      'descripcion':
          'Vive una experiencia completa donde la naturaleza lo tiene todo en un solo recorrido. La Ruta de Tres Cascadas combina la frescura del agua cristalina, la magia de la selva, '
          'la adrenalina de los retos en el camino y el sabor auténtico de la gastronomía campesina. '
          'Cada parada es una nueva aventura: un encuentro con la fuerza del agua, la calma de los paisajes y la energía que solo Sopetrán puede regalar.',
      'duracion': 5.0, // en horas
      'distancia': 10.0, // en km aprox
      'precio': 85000, // por persona
      'capacidad': 15,
      'dificultad': 'Moderado',
      'incluye': [
        'Guía experimentado',
        'Almuerzo campesino (Fiambre)',
        'Acceso permitido a todas las cascadas',
        'Seguro de aventura',
        'Transporte ida y vuelta',
        'Refrigerios y bebidas',
      ],
      'imagen_principal': 'assets/rutas/tours_tres_cascadas/principal.png',
      'zonas_paso': [
        'Primera cascada - Acuatinta - 20 minutos desde el inicio',
        'Segunda cascada - Salto del Ángel - 45 minutos',
        'Tercer cascada - Cascada Brava - 1 hora 30 minutos',
        'Regreso y almuerzo campesino en zona intermedia',
      ],
      'mejor_epoca': 'Todo el año',
      'equipo_necesario': [
        'Ropa de baño',
        'Tenis o zapatos acuáticos que cierren atrás',
        'Ropa cómoda que se pueda mojar',
        'Toalla',
        'Protector solar (resistente al agua)',
        'Gafas de sol',
        'Bolsa impermeable para objetos',
      ],
      'requisitos': 'Saber nadar, condición física moderada',
      'restricciones': 'Menores acompañados por adulto, no apto para personas con lesiones',
    },

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

