-- ============================================================================
-- SCRIPT SQL: Inserción de 14 Rutas Occitours en Supabase
-- Generado: 19 de Marzo 2026
-- Base de datos: BACKOCCI-S PostgreSQL
-- Tabla: public.ruta (ya creada)
-- Basado en: lib/data/rutas_data.dart
-- ============================================================================

-- INSERCIÓN DE 14 RUTAS

INSERT INTO public.ruta (nombre, descripcion, duracion_dias, precio_base, dificultad, imagen_url, estado)
VALUES

-- RUTA 1: Sendero del Cóndor
(
  'Sendero del Cóndor',
  'Una experiencia única de senderismo a través de paisajes montañosos espectaculares donde avistará cóndores en su hábitat natural. Ruta desafiante pero gratificante con vistas panorámicas inolvidables. Duración: 8 horas. Distancia: 12 km. Zonas de paso: Laguna de la Virgen (inicio a 2100m), Campamento Alto (descanso a 2800m), Mirador del Cóndor (punto máximo a 3200m), Retorno por sendero alternativo. Mejor época: Diciembre a Marzo. Requisitos: Condición física alta, experiencia en alturas, mayores de 16 años.',
  1,
  120000,
  'Difícil',
  'assets/rutas/sendero_condor/principal.jpg',
  true
),

-- RUTA 2: Tour del Chocolate
(
  'Tour del Chocolate',
  'Una experiencia que nos sumerge en las verdaderas tradiciones y costumbres antioqueñas. A través del cacao, fruto insignia de la región, conocerás su proceso de transformación y la historia campesina que lo rodea. Durante el recorrido podrás conocer enteramente cómo es el cultivo del cacao, desde su siembra hasta su cosecha. Además realizaremos una cata de granos de cacao en fresco, todo el proceso de transformación, y podrás disfrutar de un delicioso almuerzo campesino. Duración: 3 horas. Distancia: 5 km. Incluye: Guía especializado, almuerzo campesino, cata de cacao, demostración del proceso, souvenirs artesanales. Mejor época: Todo el año.',
  1,
  75000,
  'Fácil',
  'assets/rutas/tour_del_chocolate/principal.png',
  true
),

-- RUTA 3: Tour de cata de vinos
(
  'Tour de cata de vinos',
  'El mejor vino de Colombia y de los mejores del mundo en una experiencia única. En las montañas de Antioquia existe un lugar donde se producen vinos tan finos que han conquistado el mundo. Un destino exclusivo donde la naturaleza, la tradición y la innovación se unen para crear verdaderas joyas en cada copa. Caminarás entre viñedos sorprendentes, descubrirás el proceso que transforma la uva en arte líquido, visitarás el Salón de la Fama repleto de premios internacionales y terminarás con una cata profesional. Duración: 3 horas. Distancia: 7 km. Incluye: Guía sommelier, acceso a viñedos, cata profesional, maridaje gourmet, visita al Salón de la Fama. Requiere: Mayores de 18 años.',
  1,
  90000,
  'Fácil',
  'assets/rutas/tour_cata_vinos/principal.png',
  true
),

-- RUTA 4: Tours de tres cascadas
(
  'Tours de tres cascadas',
  'Vive una experiencia completa donde la naturaleza lo tiene todo en un solo recorrido. La Ruta de Tres Cascadas combina la frescura del agua cristalina, la magia de la selva, la adrenalina de los retos en el camino y el sabor auténtico de la gastronomía campesina. Cada parada es una nueva aventura: un encuentro con la fuerza del agua, la calma de los paisajes y la energía que solo Sopetrán puede regalar. Duración: 5 horas. Distancia: 10 km. Zonas: Primera cascada (Acuatinta - 20min), Segunda cascada (Salto del Ángel - 45min), Tercera cascada (Cascada Brava - 1.5h). Incluye: Guía, almuerzo campesino, seguro, transporte, refrigerios. Requisitos: Saber nadar, condición física moderada.',
  1,
  85000,
  'Moderado',
  'assets/rutas/tours_tres_cascadas/principal.png',
  true
),

-- RUTA 5: Tour al puente occidente
(
  'Tour al puente occidente',
  'En esta experiencia recorrerás su historia y su valor cultural mientras disfrutas de: una visita a los barequeros, guardianes de las tradiciones mineras. El mirador del puente, con paisajes que enamoran. Una caminata sobre el puente, sintiendo la majestuosidad de su estructura. El comercio local, lleno de sabores y recuerdos auténticos. La historia viva de una obra que une pasado y presente. Más que un tour, es un viaje al corazón de la tradición, la cultura y el orgullo antioqueño. Duración: 3 horas. Distancia: 4 km. Zonas: Bienvenida, barequeros, mirador, caminata sobre puente, comercio local. Incluye: Guía, acceso al puente, visita comercio, seguro, snacks. Mejor época: Todo el año.',
  1,
  65000,
  'Fácil',
  'assets/rutas/tour_al_puente_occidente/principal.png',
  true
),

-- RUTA 6: City tours Santa Fe
(
  'City tours Santa Fe',
  'Adéntrate en el encanto colonial de Santa Fe de Antioquia, la ciudad madre de Antioquia y patrimonio cultural de Colombia. Sus calles empedradas, sus casas blancas con balcones coloridos y su imponente arquitectura colonial te invitan a un viaje en el tiempo. En este recorrido por el Centro Histórico, vivirás una experiencia única con visitas a: 4 parques y 4 templos llenos de historia, la majestuosa Catedral Basílica, el Museo Juan del Corral Histórico, la Casa Comfama y la Casa de la Cultura, el Taller de Filigrana Carolina Vélez, el Hotel Mariscal Robledo y el Parque de las Artesanías. Duración: 2 horas. Distancia: 3.5 km. Incluye: Guía especializado, acceso a sitios históricos, seguro. Mejor época: Todo el año, ideal Diciembre-Enero.',
  1,
  55000,
  'Muy Fácil',
  'assets/rutas/city_tours_santa_fe/principal.png',
  true
),

-- RUTA 7: Experiencia viña del tigre
(
  'Experiencia viña del tigre',
  'Viña del Tigre es un refugio en medio de la naturaleza, donde cada día se convierte en una experiencia auténtica de vida campesina. Aquí te esperan rutas del café, el cacao y la uva; la magia de la granja con sus animales; y la tranquilidad de un entorno natural que invita a respirar aire puro, caminar senderos, descubrir cascadas y compartir momentos inolvidables en pareja, familia o con amigos. Un lugar para desconectarte del ruido y reconectar con lo esencial. Duración: 5 horas. Distancia: 6 km. Zonas: Recibimiento, ruta del café, campos de cacao, viñedos, senderos naturales con cascadas, zona de animales, almuerzo campesino, meditación natural. Incluye: Rutas guiadas, experiencia en granja, interacción con animales, senderos, cascadas, almuerzo, seguro. Requisitos: Ninguno, apto para todas las edades.',
  1,
  80000,
  'Fácil',
  'assets/rutas/experiencia_viña_tigre/principal.png',
  true
),

-- RUTA 8: Tour de cuatrimotos
(
  'Tour de cuatrimotos',
  'Vive la emoción del tour en cuatrimotos en Sopetrán: una experiencia cargada de adrenalina, donde cada camino te lleva a descubrir paisajes sorprendentes, atravesar bosques encantadores y sentir la fuerza de los ríos que dan vida a la región. Un plan perfecto para aventureros que buscan velocidad, naturaleza y diversión en un solo recorrido. Duración: 4 horas. Distancia: 25 km. Zonas: Punto de encuentro, instrucción de seguridad, senderos de montaña, bosques naturales, cruce de ríos, zona de tiro con rifle. Incluye: Guía especializado, cuatrimoto equipado, equipo de protección completo, seguro de accidente, experiencia de tiro, snacks. Requisitos: Licencia vigente, mayores de 18 años. Mejor época: Verano (diciembre-marzo).',
  1,
  150000,
  'Moderado',
  'assets/rutas/tour_cuatrimotos/principal.png',
  true
),

-- RUTA 9: Senderismo ecológico
(
  'Senderismo ecológico',
  'Caminar por Sopetrán es adentrarse en un territorio lleno de historia, paisajes y vida. Con 19 rutas identificadas, cada recorrido es una experiencia única que combina aventura, naturaleza y tradición, permitiendo descubrir cascadas, montañas, bosques y la esencia misma del campo antioqueño. Más que un recorrido, es una oportunidad de conexión auténtica con las comunidades locales, quienes compartirán sus saberes, su cultura y la calidez campesina que enriquece cada paso. Duración: 6 horas. Distancia: 15 km. Incluye: Guía naturalista, reconocimiento del territorio, acceso a cascadas, seguro, almuerzo local, interacción con comunidades. Zonas: Inicio en zona rural, senderos de 19 rutas, cascadas, bosques, encuentro con comunidades, mirador, almuerzo. Requisitos: Condición física media, apto para todas las edades. Mejor época: Todo el año (evitar lluvias fuertes).',
  1,
  95000,
  'Fácil',
  'assets/rutas/senderismo_ecologico/principal.png',
  true
),

-- RUTA 10: Paseo a caballo por el bosque
(
  'Paseo a caballo por el bosque',
  'Montar a caballo siempre es una experiencia única. En este recorrido por las riveras del río Tonusco, disfrutarás de senderos tranquilos y paisajes impresionantes, mientras conectas con la naturaleza y la cultura local. Durante 2.5 horas, vivirás la aventura de guiar tu propio caballo, cruzarás el río y descubrirás escenarios que solo este lugar puede ofrecer. Combinaremos la pasión por los caballos y la naturaleza en un recorrido donde apreciaremos el imponente bosque seco tropical, conoceremos su importancia para el ecosistema y degustaremos un refrescante refrigerio de la casa. Duración: 2.5 horas. Distancia: 8 km. Incluye: Caballo equipado, guía ecuestre, cruce de río, transporte, refrigerio, seguro. Zonas: Centro de equitación, riveras del río Tonusco, cruce del río, senderos de bosque seco, mirador, descanso y refrigerio. Requisitos: Experiencia básica recomendada, mayores de 10 años.',
  1,
  75000,
  'Fácil',
  'assets/rutas/paseo_caballo_bosque/principal.png',
  true
),

-- RUTA 11: Bote paseo San Nicolas
(
  'Bote paseo San Nicolas',
  'Vive la adrenalina navegando por la estrella fluvial del occidente colombiano, el majestuoso río Cauca. Durante este recorrido, sentirás la emoción de deslizarte sobre sus aguas mientras disfrutas del espectacular paisaje del cañón del río Cauca y conoces el corregimiento de San Nicolás, un antiguo asentamiento lleno de historia y cultura ribereña. Qué harás: Navegar por el imponente río Cauca bajo adrenalina del recorrido, admirar el espectacular paisaje del cañón mientras tu corazón se acelera, conocer el pintoresco pueblo ribereño de San Nicolás. Duración: 3 horas. Distancia: 20 km. Incluye: Bote motorizado, guía experimentado, chaleco salvavidas, transporte, seguro, parada en San Nicolás. Mejor época: Noviembre a abril. Requisitos: Saber nadar, apto para todas las edades.',
  1,
  85000,
  'Fácil',
  'assets/rutas/bote_paseo_san_nicolas/principal.png',
  true
),

-- RUTA 12: Ruta de la uva en Sopetrán
(
  'Ruta de la uva en Sopetrán',
  'Un tour honrando la tierra de las frutas, Sopetrán. Entre senderos y viñedos, conocerás a don Nato, un campesino auténtico antioqueño, recordado por su hospitalidad y su gran sentido del humor. Con él descubrirás la tradición ancestral del cultivo de la uva y la magia de transformarla en vino artesanal. Más que una visita, esta ruta es un homenaje a la cultura campesina y a la riqueza natural del territorio, una experiencia que despierta los sentidos y te invita a vivir el turismo con sentido: cercano, humano y auténtico. Duración: 2.5 horas. Distancia: 5 km. Incluye: Guía especializado en cultivo de uva, encuentro con Don Nato, recorrido por viñedos, degustación de vino artesanal, souvenirs, seguro, refrigerio. Mejor época: Todo el año (cosecha: octubre-noviembre). Requisitos: Ninguno, apto para todas las edades.',
  1,
  65000,
  'Muy Fácil',
  'assets/rutas/ruta_uva_sopetran/principal.png',
  true
),

-- RUTA 13: City Tours Tierra De Las Frutas
(
  'City Tours Tierra De Las Frutas',
  'Un recorrido por la memoria y tradición del municipio, visitando el Mirador de Sopetrán, caminos ancestrales y calles de arquitectura republicana. Conocerás antiguas casas de personajes ilustres, instituciones educativas con gran legado y el Centro de Historia. El tour culmina en la plaza principal, con su imponente Basílica Menor, esculturas emblemáticas y monumentos culturales. Para cerrar con un broche de oro, disfrutarás del sabor tradicional en la panadería artesanal de Don Julio, con más de 70 años de historia. Duración: 2.5 horas. Distancia: 4 km. Zonas: Mirador de Sopetrán, caminos ancestrales, centro histórico, casas de personajes ilustres, instituciones, Centro de Historia, plaza principal, Basílica Menor, panadería Don Julio. Incluye: Guía especializado, acceso a sitios históricos, visita panadería Don Julio, degustación de pan, souvenirs, seguro. Mejor época: Todo el año.',
  1,
  60000,
  'Muy Fácil',
  'assets/rutas/city_tours_tierra_frutas/principal.png',
  true
),

-- RUTA 14: Ruta de avistamiento de aves
(
  'Ruta de avistamiento de aves',
  'Una experiencia de aprendizaje y profundo contacto con la naturaleza, recorriendo senderos que resguardan el bosque seco tropical. Sopetrán es hogar de especies endémicas como el Cucarachero Paisa (Thryophilus sernai) y el imponente Ara Militaris, símbolos de identidad y conservación. A lo largo del recorrido, nuestros guías especializados te acompañarán en la observación de una gran diversidad de aves, compartiendo conocimientos que hacen de este tour un encuentro único con la riqueza natural del territorio y su avifauna. Duración: 3.5 horas. Distancia: 10 km. Dificultad: Moderado. Incluye: Guía especializado en ornitología, binoculares profesionales, mapa de especies endémicas, senderos en bosque seco, seguro, refrigerio y agua. Zonas: Recepción, senderos principales, zonas de avistamiento de especies endémicas, laguna o espejo de agua, mirador ornitológico. Mejor época: Diciembre a abril (migración de aves).',
  1,
  110000,
  'Moderado',
  'assets/rutas/avistamiento_aves/principal.png',
  true
);

-- SELECT de verificación
SELECT id_ruta, nombre, duracion_dias, precio_base, dificultad, estado, fecha_creacion
FROM public.ruta
ORDER BY id_ruta;
