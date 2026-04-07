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
      'imagen_principal': 'assets/rutas/sendero_condor/principal.png',
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
    {
      'id': 5,
      'nombre': 'Tour al puente occidente',
      'ubicacion': 'Occidente Antioqueño',
      'descripcion':
          'En esta experiencia recorrerás su historia y su valor cultural mientras disfrutas de: una visita a los barequeros, guardianes de las tradiciones mineras. '
          'El mirador del puente, con paisajes que enamoran. Una caminata sobre el puente, sintiendo la majestuosidad de su estructura. '
          'El comercio local, lleno de sabores y recuerdos auténticos. '
          'La historia viva de una obra que une pasado y presente.\n\n'
          'Más que un tour, es un viaje al corazón de la tradición, la cultura y el orgullo antioqueño.',
      'duracion': 3.0, // en horas
      'distancia': 4.0, // en km aprox
      'precio': 65000, // por persona
      'capacidad': 20,
      'dificultad': 'Fácil',
      'incluye': [
        'Guía especializado en historia local',
        'Acceso al puente',
        'Visita a comercio local',
        'Seguro de viajero',
        'Snacks y bebidas',
      ],
      'imagen_principal': 'assets/rutas/tour_al_puente_occidente/principal.png',
      'zonas_paso': [
        'Bienvenida y explicación histórica',
        'Encuentro con barequeros y tradiciones mineras',
        'Mirador con vistas panorámicas',
        'Caminata sobre el puente',
        'Recorrido por comercio local',
        'Cierre y despedida',
      ],
      'mejor_epoca': 'Todo el año',
      'equipo_necesario': [
        'Ropa cómoda',
        'Zapatos con buen agarre',
        'Cámara fotográfica',
        'Protector solar',
        'Gafas de sol',
        'Bolsa para compras en comercio local',
      ],
      'requisitos': 'Ninguno, apto para todas las edades',
      'restricciones': 'Ninguna restricción especial',
    },
    {
      'id': 6,
      'nombre': 'City tours Santa Fe',
      'ubicacion': 'Centro Histórico, Santa Fe de Antioquia',
      'descripcion':
          'Adéntrate en el encanto colonial de Santa Fe de Antioquia, la ciudad madre de Antioquia y patrimonio cultural de Colombia. Sus calles empedradas, sus casas blancas con balcones coloridos y su imponente arquitectura colonial te invitan a un viaje en el tiempo.\n\n'
          'En este recorrido por el Centro Histórico, vivirás una experiencia única con visitas a:\n'
          '• 4 parques y 4 templos llenos de historia\n'
          '• La majestuosa Catedral Basílica\n'
          '• El Museo Juan del Corral Histórico\n'
          '• La Casa Comfama y la Casa de la Cultura, guardianas de la memoria del pueblo\n'
          '• El Taller de Filigrana Carolina Vélez, el taller principal de la Casa de la Cultura\n'
          '• El tradicional Hotel Mariscal Robledo y el Parque de las Artesanías',
      'duracion': 2.0, // en horas
      'distancia': 3.5, // en km aprox
      'precio': 55000, // por persona
      'capacidad': 12,
      'dificultad': 'Muy Fácil',
      'incluye': [
        'Guía especializado en historia colonial',
        'Acceso a sitios históricos',
        'Seguro de viajero',
      ],
      'imagen_principal': 'assets/rutas/city_tours_santa_fe/principal.png',
      'zonas_paso': [
        'Centro Histórico - Inicio del recorrido',
        'Parque Principal y Catedral Basílica',
        'Templos históricos (4 templos)',
        'Casa Comfama y Casa de la Cultura',
        'Taller de Filigrana Carolina Vélez',
        'Parque de las Artesanías y Hotel Mariscal Robledo',
      ],
      'mejor_epoca': 'Todo el año (ideal Diciembre-Enero festividades)',
      'equipo_necesario': [
        'Calzado cómodo para caminata urbana',
        'Cámara fotográfica',
        'Protector solar',
        'Gafas de sol',
        'Bolsa para compras de artesanías',
      ],
      'requisitos': 'Ninguno, apto para todas las edades',
      'restricciones': 'Ninguna restricción especial',
    },
    {
      'id': 7,
      'nombre': 'Experiencia viña del tigre',
      'ubicacion': 'Occidente Antioqueño',
      'descripcion':
          'Viña del Tigre es un refugio en medio de la naturaleza, donde cada día se convierte en una experiencia auténtica de vida campesina. '
          'Aquí te esperan rutas del café, el cacao y la uva; la magia de la granja con sus animales; '
          'y la tranquilidad de un entorno natural que invita a respirar aire puro, caminar senderos, descubrir cascadas '
          'y compartir momentos inolvidables en pareja, familia o con amigos.\n\n'
          'Un lugar para desconectarte del ruido y reconectar con lo esencial.',
      'duracion': 5.0, // en horas
      'distancia': 6.0, // en km aprox
      'precio': 80000, // por persona
      'capacidad': 20,
      'dificultad': 'Fácil',
      'incluye': [
        'Rutas guiadas del café, cacao y uva',
        'Experiencia de vida en la granja',
        'Interacción con animales',
        'Senderos naturales',
        'Cascadas y piscinas naturales',
        'Almuerzo típico',
        'Seguro de viajero',
      ],
      'imagen_principal': 'assets/rutas/experiencia_viña_tigre/principal.png',
      'zonas_paso': [
        'Recibimiento en la granja',
        'Ruta del café - cultivo y proceso',
        'Campos de cacao - recolección y transformación',
        'Viñedos - uva de mesa y vino local',
        'Senderos naturales con cascadas',
        'Zona de animales y convivencia',
        'Almuerzo campesino',
        'Descanso y meditación natural',
      ],
      'mejor_epoca': 'Todo el año',
      'equipo_necesario': [
        'Ropa cómoda y ligera',
        'Zapatos de senderismo',
        'Protector solar y gafas de sol',
        'Sombrero o gorra',
        'Botella para agua reutilizable',
        'Cámara fotográfica',
        'Repelente de insectos',
      ],
      'requisitos': 'Ninguno, apto para todas las edades',
      'restricciones': 'Ninguna restricción especial',
    },
    {
      'id': 8,
      'nombre': 'Tour de cuatrimotos',
      'ubicacion': 'Sopetrán',
      'descripcion':
          'Vive la emoción del tour en cuatrimotos en Sopetrán: una experiencia cargada de adrenalina, donde cada camino te lleva a descubrir paisajes sorprendentes, '
          'atravesar bosques encantadores y sentir la fuerza de los ríos que dan vida a la región.\n\n'
          'Un plan perfecto para aventureros que buscan velocidad, naturaleza y diversión en un solo recorrido.',
      'duracion': 4.0, // en horas
      'distancia': 25.0, // en km aprox
      'precio': 150000, // por persona
      'capacidad': 10,
      'dificultad': 'Moderado',
      'incluye': [
        'Guía especializado en motos',
        'Cuatrimoto equipado y asegurado',
        'Equipo de protección completo (casco, chaleco)',
        'Seguro de accidente',
        'Experiencia de tiro con rifle',
        'Snacks y bebidas',
      ],
      'imagen_principal': 'assets/rutas/tour_cuatrimotos/principal.png',
      'zonas_paso': [
        'Punto de encuentro y equipamiento',
        'Instrucción de seguridad en cuatrimotos',
        'Senderos de montaña',
        'Bosques naturales',
        'Cruce de ríos y arroyos',
        'Zona de tiro con rifle',
        'Retorno y cierre de experiencia',
      ],
      'mejor_epoca': 'Verano (diciembre-marzo)',
      'equipo_necesario': [
        'Ropa cómoda y resistente',
        'Botas cerradas',
        'Gafas para proteger del polvo',
        'Protector solar',
        'Cámara de acción (GoPro)',
      ],
      'requisitos': 'Licencia de conducción vigente, mayores de 18 años',
      'restricciones': 'No se recomienda para menores de 18 años ni personas con molestias en espalda o cuello',
    },
    {
      'id': 9,
      'nombre': 'Senderismo ecológico',
      'ubicacion': 'Sopetrán',
      'descripcion':
          'Caminar por Sopetrán es adentrarse en un territorio lleno de historia, paisajes y vida. Con 19 rutas identificadas, cada recorrido es una experiencia única que combina aventura, naturaleza y tradición, '
          'permitiendo descubrir cascadas, montañas, bosques y la esencia misma del campo antioqueño.\n\n'
          'Más que un recorrido, es una oportunidad de conexión auténtica con las comunidades locales, quienes compartirán sus saberes, su cultura y la calidez campesina que enriquece cada paso.',
      'duracion': 6.0, // en horas
      'distancia': 15.0, // en km aprox
      'precio': 95000, // por persona
      'capacidad': 15,
      'dificultad': 'Fácil',
      'incluye': [
        'Guía naturalista especializado',
        'Reconocimiento del territorio',
        'Acceso a cascadas y mirador',
        'Seguro de viajero',
        'Almuerzo típico local',
        'Interacción con comunidades',
      ],
      'imagen_principal': 'assets/rutas/senderismo_ecologico/principal.png',
      'zonas_paso': [
        'Inicio en zona rural de Sopetrán',
        'Senderos principales de las 19 rutas',
        'Cascadas y piscinas naturales',
        'Bosques primarios y secundarios',
        'Encuentro con comunidades locales',
        'Mirador con vistas panorámicas',
        'Zona de descanso y almuerzo',
      ],
      'mejor_epoca': 'Todo el año (evitar lluvias fuertes)',
      'equipo_necesario': [
        'Calzado de senderismo impermeables',
        'Ropa ligera pero protectora',
        'Capa impermeable',
        'Protector solar y gafas de sol',
        'Botella de agua reutilizable',
        'Cámara fotográfica',
        'Bolsa impermeable para valuables',
      ],
      'requisitos': 'Condición física media, apto para todas las edades',
      'restricciones': 'Personas con limitaciones de movilidad pueden requerir guía adicional',
    },
    {
      'id': 10,
      'nombre': 'Paseo a caballo por el bosque',
      'ubicacion': 'Río Tonusco',
      'descripcion':
          'Montar a caballo siempre es una experiencia única. En este recorrido por las riveras del río Tonusco, disfrutarás de senderos tranquilos y paisajes impresionantes, '
          'mientras conectas con la naturaleza y la cultura local.\n\n'
          'Durante 2.5 horas, vivirás la aventura de guiar tu propio caballo, cruzarás el río y descubrirás escenarios que solo este lugar puede ofrecer. '
          'Combinaremos la pasión por los caballos y la naturaleza en un recorrido donde apreciaremos el imponente bosque seco tropical, conoceremos su importancia para el ecosistema '
          'y degustaremos un refrescante refrigerio de la casa. Si amas la naturaleza, los caballos y apreciar paisajes sin igual, esta experiencia es para ti.',
      'duracion': 2.5, // en horas
      'distancia': 8.0, // en km aprox
      'precio': 75000, // por persona
      'capacidad': 12,
      'dificultad': 'Fácil',
      'incluye': [
        'Caballo equipado y seleccionado',
        'Guía ecuestre especializado',
        'Cruce de río',
        'Transporte al punto de partida',
        'Refrigerio casero',
        'Seguro de viajero',
      ],
      'imagen_principal': 'assets/rutas/paseo_caballo_bosque/principal.png',
      'zonas_paso': [
        'Centro de equitación - punto de partida',
        'Riveras del río Tonusco',
        'Cruce del río',
        'Senderos del bosque seco tropical',
        'Mirador natural',
        'Zona de descanso y refrigerio',
        'Retorno seguro',
      ],
      'mejor_epoca': 'Todo el año (verano ideal)',
      'equipo_necesario': [
        'Pantalón largo (no muy ajustado)',
        'Botas cerradas o zapatos con apoyo tobillo',
        'Sombrero o gorra',
        'Protector solar',
        'Cámara fotográfica',
        'Ropa cómoda y clima-apropiada',
      ],
      'requisitos': 'Experiencia básica en equitación recomendada, mayores de 10 años',
      'restricciones': 'No recomendado para personas con miedo a caballos o problemas de columna',
    },
    {
      'id': 11,
      'nombre': 'Bote paseo San Nicolas',
      'ubicacion': 'Río Cauca',
      'descripcion':
          'Vive la adrenalina navegando por la estrella fluvial del occidente colombiano, el majestuoso río Cauca. Durante este recorrido, sentirás la emoción de deslizarte sobre sus aguas '
          'mientras disfrutas del espectacular paisaje del cañón del río Cauca y conoces el corregimiento de San Nicolás, '
          'un antiguo asentamiento lleno de historia y cultura ribereña.\n\n'
          'Qué harás:\n'
          '• Navegar por el imponente río Cauca bajo adrenalina del recorrido\n'
          '• Admirar el espectacular paisaje del cañón mientras tu corazón se acelera\n'
          '• Conocer el pintoresco pueblo ribereño de San Nicolás',
      'duracion': 3.0, // en horas
      'distancia': 20.0, // en km aprox
      'precio': 85000, // por persona
      'capacidad': 20,
      'dificultad': 'Fácil',
      'incluye': [
        'Bote motorizado equipado',
        'Guía experimentado en navegación',
        'Chaleco salvavidas',
        'Transporte al embarcadero',
        'Seguro de viajero',
        'Parada en San Nicolás',
      ],
      'imagen_principal': 'assets/rutas/bote_paseo_san_nicolas/principal.png',
      'zonas_paso': [
        'Embarcadero principal',
        'Navegación río Cauca inicio',
        'Cañón del río Cauca',
        'Paisajes panorámicos',
        'Corregimiento San Nicolás',
        'Parada cultural y gastronómica',
        'Retorno por río',
      ],
      'mejor_epoca': 'Noviembre a abril (verano)',
      'equipo_necesario': [
        'Ropa ligera de secado rápido',
        'Sandalias o zapatos de agua',
        'Protector solar resistente al agua',
        'Toalla',
        'Cámara impermeable o funda',
        'Gafas de sol',
        'Sombrero o gorra',
      ],
      'requisitos': 'Saber nadar, apto para todas las edades',
      'restricciones': 'Personas con miedo al agua o en estado de embarazo pueden requerir asesoramiento médico',
    },
    {
      'id': 12,
      'nombre': 'Ruta de la uva en Sopetrán',
      'ubicacion': 'Sopetrán',
      'descripcion':
          'Un tour honrando la tierra de las frutas, Sopetrán. Entre senderos y viñedos, conocerás a don Nato, un campesino auténtico antioqueño, recordado por su hospitalidad y gran sentido del humor. '
          'Con él descubrirás la tradición ancestral del cultivo de la uva y la magia de transformarla en vino artesanal.\n\n'
          'Más que una visita, esta ruta es un homenaje a la cultura campesina y a la riqueza natural del territorio, '
          'una experiencia que despierta los sentidos y te invita a vivir el turismo con sentido: cercano, humano y auténtico.',
      'duracion': 2.5, // en horas
      'distancia': 5.0, // en km aprox
      'precio': 65000, // por persona
      'capacidad': 15,
      'dificultad': 'Muy Fácil',
      'incluye': [
        'Guía especializado en cultivo de uva',
        'Encuentro con don Nato',
        'Recorrido por viñedos',
        'Degustación de vino artesanal',
        'Souvenirs y productos locales',
        'Seguro de viajero',
        'Refrigerio',
      ],
      'imagen_principal': 'assets/rutas/ruta_uva_sopetran/principal.png',
      'zonas_paso': [
        'Centro de recepción',
        'Viñedos principales',
        'Taller de elaboración de vino',
        'Casa de Don Nato',
        'Zona de degustación',
        'Tienda de souvenirs',
      ],
      'mejor_epoca': 'Todo el año (cosecha: octubre-noviembre)',
      'equipo_necesario': [
        'Calzado cómodo',
        'Protector solar',
        'Gafas de sol',
        'Sombrero o gorra',
        'Ropa ligera',
        'Cámara fotográfica',
      ],
      'requisitos': 'Ninguno, apto para todas las edades',
      'restricciones': 'Ninguna restricción especial',
    },
    {
      'id': 13,
      'nombre': 'City Tours Tierra De Las Frutas',
      'ubicacion': 'Sopetrán',
      'descripcion':
          'Un recorrido por la memoria y tradición del municipio, visitando el Mirador de Sopetrán, caminos ancestrales y calles de arquitectura republicana. '
          'Conocerás antiguas casas de personajes ilustres, instituciones educativas con gran legado y el Centro de Historia. '
          'El tour culmina en la plaza principal, con su imponente Basílica Menor, esculturas emblemáticas y monumentos culturales. '
          'Para cerrar con un broche de oro, disfrutarás del sabor tradicional en la panadería artesanal de Don Julio, con más de 70 años de historia.',
      'duracion': 2.5, // en horas
      'distancia': 4.0, // en km aprox
      'precio': 60000, // por persona
      'capacidad': 15,
      'dificultad': 'Muy Fácil',
      'incluye': [
        'Guía especializado en historia local',
        'Acceso a sitios históricos',
        'Visita a panadería Don Julio',
        'Degustación de pan artesanal',
        'Souvenirs locales',
        'Seguro de viajero',
      ],
      'imagen_principal': 'assets/rutas/city_tours_tierra_frutas/principal.png',
      'zonas_paso': [
        'Mirador de Sopetrán',
        'Caminos ancestrales',
        'Centro histórico',
        'Casas de personajes ilustres',
        'Instituciones educativas',
        'Centro de Historia',
        'Plaza principal',
        'Basílica Menor',
        'Panadería Don Julio',
      ],
      'mejor_epoca': 'Todo el año',
      'equipo_necesario': [
        'Calzado cómodo para caminata urbana',
        'Protector solar',
        'Gafas de sol',
        'Sombrero o gorra',
        'Cámara fotográfica',
        'Bolsa para compras de artesanías',
      ],
      'requisitos': 'Ninguno, apto para todas las edades',
      'restricciones': 'Ninguna restricción especial',
    },
    {
      'id': 14,
      'nombre': 'Ruta de avistamiento de aves',
      'ubicacion': 'Del Cauca al Páramo (Sopetrán)',
      'descripcion':
          'Una experiencia de aprendizaje y profundo contacto con la naturaleza, recorriendo senderos que resguardan el bosque seco tropical. '
          'Sopetrán es hogar de especies endémicas como el Cucarachero Paisa (Thryophilus sernai) y el imponente Ara Militaris, símbolos de identidad y conservación.\n\n'
          'A lo largo del recorrido, nuestros guías especializados te acompañarán en la observación de una gran diversidad de aves, '
          'compartiendo conocimientos que hacen de este tour un encuentro único con la riqueza natural del territorio y su avifauna.',
      'duracion': 3.5, // en horas
      'distancia': 10.0, // en km aprox
      'precio': 110000, // por persona
      'capacidad': 12,
      'dificultad': 'Moderado',
      'incluye': [
        'Guía especializado en ornitología',
        'Binoculares profesionales',
        'Mapa de especies endémicas',
        'Senderos en bosque seco tropical',
        'Seguro de viajero',
        'Refrigerio y agua',
      ],
      'imagen_principal': 'assets/rutas/avistamiento_aves/principal.png',
      'zonas_paso': [
        'Centro de recepción y equipamiento',
        'Senderos principales del bosque seco',
        'Zonas de avistamiento especies endémicas',
        'Laguna o espejo de agua',
        'Mirador ornitológico',
        'Zona de descanso y observación',
      ],
      'mejor_epoca': 'Diciembre a abril (migración de aves)',
      'equipo_necesario': [
        'Calzado de senderismo',
        'Ropa neutra (verde, camuflaje)',
        'Protector solar',
        'Gafas de sol y gorra',
        'Botella de agua reutilizable',
        'Cámara télescopio o zoom',
        'Libreta de observaciones',
        'Repelente de insectos',
      ],
      'requisitos': 'Condición física media, paciencia para observación',
      'restricciones': 'Personas con problemas auditivos pueden llevar asistente',
    },
  ];
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

