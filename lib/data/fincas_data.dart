/// Datos de fincas con información completa
/// Este archivo contiene la información detallada de las fincas
/// Luego será reemplazado por datos del backend

class FincasData {
  static final List<Map<String, dynamic>> fincas = [
    {
      'id': 1,
      'nombre': 'Las Margaritas',
      'ubicacion': 'Sopetran, 10 min del parque principal',
      'descripcion':
          'Hermosa finca campestre ubicada en Sopetran a solo 10 minutos del parque principal. '
          'Ideal para grupos grandes de hasta 25 personas. Cuenta con cómodas habitaciones, '
          'piscina con chorros, áreas de recreación y excelentes servicios.',
      'capacidad_personas': 25,
      'precio_por_noche': 250000,
      'imagen_principal': 'assets/fincas/las_margaritas/principal.jpg',
      'primer_planta': [
        'Cocina integral bien dotada',
        'Sala con TV',
        '3 habitaciones',
        '6 camas',
        '2 baños',
        'Comedor grande',
        'Nevera y congelador',
        'Corredor con hamacas',
        'Fogón a leña',
        'Asador',
      ],
      'segunda_planta': [
        '4 habitaciones',
        '6 camas',
        '1 camarote',
        '2 tarimas',
        '1 sofá cama',
        '1 sala',
        '2 baños',
        'Balcón con muebles',
      ],
      'zonas_comunes': [
        'Piscina con chorros',
        'Pequeño kiosco',
        'Billar',
        'Hamacas',
        'Amplia zona verde',
        'Parqueadero amplio',
      ],
    },
    {
      'id': 2,
      'nombre': 'Las Heliconias',
      'ubicacion': 'Sopetrán, 10 minutos del parque principal',
      'descripcion':
          'Hermosa finca moderna ubicada en Sopetrán. Perfecta para grupos de hasta 20 personas. '
          'Diseño contemporáneo con todas las comodidades: dos piscinas, zona BBQ, WiFi, '
          'y habitaciones con aire acondicionado. Ideal para disfrutar en familia o con amigos.',
      'capacidad_personas': 20,
      'precio_por_noche': 280000,
      'imagen_principal': 'assets/fincas/las_heliconias/principal.jpg',
      'zonas_comunes': [
        'Sala con TV',
        'Cocina bien dotada',
        'Comedor',
        'Sonido',
        '3 baños',
        'Piscina con chorros',
        'Piscina de niños',
        'Zona verde',
        'Parqueadero amplio',
        '2 neveras',
        'Zona BBQ',
        'Agua potable',
        'TV con DirecTV',
        'Zona WiFi',
      ],
      'habitaciones': [
        {
          'nombre': 'Habitación 1',
          'detalles': [
            '2 camas dobles',
            '1 tarima',
            'Aire acondicionado',
          ],
        },
        {
          'nombre': 'Habitación 2',
          'detalles': [
            '2 camas dobles',
            '1 TV',
            'Aire acondicionado',
          ],
        },
        {
          'nombre': 'Habitación 3',
          'detalles': [
            '1 cama doble',
            '1 tarima',
            'Aire acondicionado',
            'Closet',
          ],
        },
        {
          'nombre': 'Habitación 4',
          'detalles': [
            '2 camas dobles',
            '1 tarima',
            'Aire acondicionado',
          ],
        },
      ],
      'deposito_daños': 300000,
      'tarifa_aseo': 100000,
    },
    {
      'id': 3,
      'nombre': 'Las Palmas',
      'ubicacion': 'Sopetran',
      'descripcion':
          'Hermosa casa de dos niveles ubicada en Sopetran. Perfecta para grupos de hasta 18 personas. '
          'Moderno diseño con todas las comodidades: piscina con luces LED, jacuzzi, cascada, '
          'zona BBQ, billar y mucho más. Ideal para disfrutar de un fin de semana memorable en familia.',
      'capacidad_personas': 18,
      'precio_por_noche': 300000,
      'imagen_principal': 'assets/fincas/las_palmas/principal.jpg',
      'caracteristicas_generales': [
        'Casa de dos niveles',
        '3 Habitaciones',
        '2 Aires acondicionados',
        'Cocina dotada',
        'Comedor',
        'Sala de estar y televisión',
        'WiFi',
        'Parqueadero',
      ],
      'zonas_comunes': [
        'Zona verde pequeña',
        'Hamaca',
        'Billar',
        'Fogón de leña ecológico',
        'Asador a carbón',
        'Sillas asoleadoras',
        'Playita para niños',
        'Piscina con luces LED',
        'Cascada',
        'Jacuzzi',
      ],
    },
    {
      'id': 4,
      'nombre': 'La Ilusión - 68 Palma Real',
      'ubicacion': 'Sopetrán, 15 minutos del parque principal',
      'descripcion':
          'Un lugar ideal para descansar, compartir en familia y disfrutar de la tranquilidad del occidente antioqueño. '
          'La Ilusión ofrece 5 habitaciones cómodas con todas las comodidades necesarias para una estancia memorable. '
          'Perfecta para grupos de hasta 30 personas con amplias zonas comunes y servicios de primera calidad.',
      'capacidad_personas': 30,
      'precio_por_noche': 300000,
      'imagen_principal': 'assets/fincas/la_ilusion/principal.jpg',
      'habitaciones': [
        {
          'nombre': 'Habitación 1',
          'detalles': [
            '2 camas semi dobles',
            '1 cama tarima',
            'Aire acondicionado',
            'Ventiladores',
            'Baño privado',
          ],
        },
        {
          'nombre': 'Habitación 2',
          'detalles': [
            '2 camas semi dobles',
            '1 cama tarima',
            'Aire acondicionado',
            'Ventilador',
            'Baño privado',
          ],
        },
        {
          'nombre': 'Habitación 3',
          'detalles': [
            '2 camas semi dobles',
            '1 cama tarima',
            'Aire acondicionado',
            'Ventilador',
          ],
        },
        {
          'nombre': 'Habitación 4',
          'detalles': [
            '3 camas dobles',
            '1 cama tarima',
            'Aire acondicionado',
            'Baño privado',
          ],
        },
        {
          'nombre': 'Habitación 5',
          'detalles': [
            '2 camas dobles',
            '1 cama tarima',
            'Aire acondicionado',
            'Ventilador',
            'Baño privado',
            'Ropero',
          ],
        },
      ],
      'zonas_comunes': [
        'Sala de estar',
        'Cocina totalmente dotada',
        'Zona WiFi',
        'Cancha de fútbol',
        'Parqueadero amplio (hasta 8 carros)',
        'Kiosco social',
        'Zona BBQ',
        'Piscina con chorros',
        'Asoleadoras',
        'Zona verde',
        'Tenis de mesa',
      ],
    },
    {
      'id': 5,
      'nombre': 'La María',
      'ubicacion': 'Sopetran, 10 minutos del parque principal, sector el palmar',
      'descripcion':
          'Finca gama alta ubicada en el municipio de Sopetran, sector el palmar. '
          'Una propiedad de lujo con todas las comodidades para familias grandes. '
          'Perfecta para grupos de hasta 25 personas que buscan confort, seguridad y espacios amplios para disfrutar.',
      'capacidad_personas': 25,
      'precio_por_noche': 300000,
      'imagen_principal': 'assets/fincas/la_maria/principal.jpg',
      'habitaciones': [
        {
          'nombre': 'Habitación 1',
          'detalles': [
            '2 camas de 1.20',
            '1 cama de 1.40',
            'TV',
            'Baño',
            'Aire acondicionado',
          ],
        },
        {
          'nombre': 'Habitación 2',
          'detalles': [
            '3 camas de 1.40',
            'Baño con armario',
            'Aire acondicionado',
            'TV',
          ],
        },
        {
          'nombre': 'Habitación 3',
          'detalles': [
            '3 camas de 1.20',
            'TV',
            'Baño con armario',
            'Aire acondicionado',
            'Salida a balcón',
          ],
        },
        {
          'nombre': 'Habitación 4',
          'detalles': [
            '2 camas de 1.40',
            'TV',
            'Baño',
            'Aire acondicionado',
            'Clóset',
          ],
        },
        {
          'nombre': 'Habitación 5',
          'detalles': [
            '2 camas de 1.20',
            '1 cama de 1.40',
            'Baño con armario',
            'TV',
            'Aire acondicionado',
          ],
        },
      ],
      'zonas_comunes': [
        'Sala de estar con TV',
        'Sala comedor',
        'Cocina integral bien dotada',
        'Agua potable',
        'Piscina con chorros y playa',
        'Jacuzzi',
        'Turco (sauna)',
        'Kiosco social',
        'Zona BBQ',
        'Parqueadero',
        'Zona verde',
        'Mini cancha',
        'Asoleadoras',
        'Rancho de descanso',
        'Zona de lavado',
        'Cámaras de seguridad',
      ],
    },
  ];

  /// Obtener finca por ID
  static Map<String, dynamic>? getFincaById(int id) {
    try {
      return fincas.firstWhere((finca) => finca['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener todas las fincas
  static List<Map<String, dynamic>> getAllFincas() {
    return fincas;
  }
}
