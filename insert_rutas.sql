-- ============================================================================
-- SCRIPT SQL: Inserción de 14 Rutas Occitours en Supabase
-- Generado: 19 de Marzo 2026
-- Base de datos: BACKOCCI-S PostgreSQL
-- Tabla: public.ruta
-- ============================================================================

-- Limpiar datos existentes (opcional - comentar si se desea mantener datos previos)
-- DELETE FROM public.ruta WHERE id_ruta > 0;
-- SELECT setval('public.ruta_id_ruta_seq', 1, false);

-- ============================================================================
-- INSERCIÓN DE RUTAS
-- ============================================================================

INSERT INTO public.ruta (nombre, descripcion, duracion_dias, precio_base, dificultad, imagen_url, estado)
VALUES

-- RUTA 1: Sendero del Cóndor
(
  'Sendero del Cóndor',
  'Una experiencia única de senderismo a través de paisajes montañosos espectaculares donde avistará cóndores en su hábitat natural. Ruta desafiante pero gratificante con vistas panorámicas inolvidables.',
  1,
  120000,
  'Difícil',
  'assets/rutas/sendero_condor/principal.jpg',
  true
),

-- RUTA 2: Tour del Chocolate
(
  'Tour del Chocolate',
  'Una experiencia que nos sumerge en las verdaderas tradiciones y costumbres antioqueñas. A través del cacao, fruto insignia de la región, conocerás su proceso de transformación y la historia campesina que lo rodea.',
  1,
  75000,
  'Fácil',
  'assets/rutas/tour_del_chocolate/principal.png',
  true
),

-- RUTA 3: Tour de cata de vinos
(
  'Tour de cata de vinos',
  'El mejor vino de Colombia y de los mejores del mundo en una experiencia única. En las montañas de Antioquia existe un lugar donde se producen vinos tan finos que han conquistado el mundo.',
  1,
  90000,
  'Fácil',
  'assets/rutas/tour_cata_vinos/principal.png',
  true
),

-- RUTA 4: Tours de tres cascadas
(
  'Tours de tres cascadas',
  'Vive una experiencia completa donde la naturaleza lo tiene todo en un solo recorrido. La Ruta de Tres Cascadas combina la frescura del agua cristalina, la magia de la selva, la adrenalina de los retos en el camino y el sabor auténtico de la gastronomía campesina.',
  1,
  85000,
  'Moderado',
  'assets/rutas/tours_tres_cascadas/principal.png',
  true
),

-- RUTA 5: Tour al puente occidente
(
  'Tour al puente occidente',
  'En esta experiencia recorrerás su historia y su valor cultural. Una visita a los barequeros, guardianes de las tradiciones mineras. El mirador del puente con paisajes que enamoran. Una caminata sobre el puente, sintiendo la majestuosidad de su estructura.',
  1,
  65000,
  'Fácil',
  'assets/rutas/tour_al_puente_occidente/principal.png',
  true
),

-- RUTA 6: City tours Santa Fe
(
  'City tours Santa Fe',
  'Adéntrate en el encanto colonial de Santa Fe de Antioquia, la ciudad madre de Antioquia y patrimonio cultural de Colombia. Sus calles empedradas, sus casas blancas con balcones coloridos y su imponente arquitectura colonial te invitan a un viaje en el tiempo.',
  1,
  55000,
  'Muy Fácil',
  'assets/rutas/city_tours_santa_fe/principal.png',
  true
),

-- RUTA 7: Experiencia viña del tigre
(
  'Experiencia viña del tigre',
  'Viña del Tigre es un refugio en medio de la naturaleza, donde cada día se convierte en una experiencia auténtica de vida campesina. Aquí te esperan rutas del café, el cacao y la uva; la magia de la granja con sus animales.',
  1,
  80000,
  'Fácil',
  'assets/rutas/experiencia_viña_tigre/principal.png',
  true
),

-- RUTA 8: Tour de cuatrimotos
(
  'Tour de cuatrimotos',
  'Vive la emoción del tour en cuatrimotos en Sopetrán: una experiencia cargada de adrenalina, donde cada camino te lleva a descubrir paisajes sorprendentes, atravesar bosques encantadores y sentir la fuerza de los ríos que dan vida a la región.',
  1,
  150000,
  'Moderado',
  'assets/rutas/tour_cuatrimotos/principal.png',
  true
),

-- RUTA 9: Senderismo ecológico
(
  'Senderismo ecológico',
  'Caminar por Sopetrán es adentrarse en un territorio lleno de historia, paisajes y vida. Con 19 rutas identificadas, cada recorrido es una experiencia única que combina aventura, naturaleza y tradición, permitiendo descubrir cascadas, montañas, bosques.',
  1,
  95000,
  'Fácil',
  'assets/rutas/senderismo_ecologico/principal.png',
  true
),

-- RUTA 10: Paseo a caballo por el bosque
(
  'Paseo a caballo por el bosque',
  'Montar a caballo siempre es una experiencia única. En este recorrido por las riveras del río Tonusco, disfrutarás de senderos tranquilos y paisajes impresionantes, mientras conectas con la naturaleza y la cultura local.',
  1,
  75000,
  'Fácil',
  'assets/rutas/paseo_caballo_bosque/principal.png',
  true
),

-- RUTA 11: Bote paseo San Nicolas
(
  'Bote paseo San Nicolas',
  'Vive la adrenalina navegando por la estrella fluvial del occidente colombiano, el majestuoso río Cauca. Durante este recorrido, sentirás la emoción de deslizarte sobre sus aguas mientras disfrutas del espectacular paisaje del cañón.',
  1,
  85000,
  'Fácil',
  'assets/rutas/bote_paseo_san_nicolas/principal.png',
  true
),

-- RUTA 12: Ruta de la uva en Sopetrán
(
  'Ruta de la uva en Sopetrán',
  'Un tour honrando la tierra de las frutas, Sopetrán. Entre senderos y viñedos, conocerás a don Nato, un campesino auténtico antioqueño. Con él descubrirás la tradición ancestral del cultivo de la uva y la magia de transformarla en vino artesanal.',
  1,
  65000,
  'Muy Fácil',
  'assets/rutas/ruta_uva_sopetran/principal.png',
  true
),

-- RUTA 13: City Tours Tierra De Las Frutas
(
  'City Tours Tierra De Las Frutas',
  'Un recorrido por la memoria y tradición del municipio, visitando el Mirador de Sopetrán, caminos ancestrales y calles de arquitectura republicana. Conocerás antiguas casas de personajes ilustres, instituciones educativas con gran legado y el Centro de Historia.',
  1,
  60000,
  'Muy Fácil',
  'assets/rutas/city_tours_tierra_frutas/principal.png',
  true
),

-- RUTA 14: Ruta de avistamiento de aves
(
  'Ruta de avistamiento de aves',
  'Una experiencia de aprendizaje y profundo contacto con la naturaleza, recorriendo senderos que resguardan el bosque seco tropical. Sopetrán es hogar de especies endémicas como el Cucarachero Paisa y el imponente Ara Militaris, símbolos de identidad y conservación.',
  1,
  110000,
  'Moderado',
  'assets/rutas/avistamiento_aves/principal.png',
  true
);

-- ============================================================================
-- VERIFICACIÓN DE INSERCIÓN
-- ============================================================================

SELECT 
  id_ruta,
  nombre,
  duracion_dias,
  precio_base,
  dificultad,
  estado,
  fecha_creacion
FROM public.ruta
ORDER BY id_ruta;

-- ============================================================================
-- ESTADÍSTICAS FINALES
-- ============================================================================

SELECT 
  COUNT(*) as total_rutas,
  COUNT(CASE WHEN estado = true THEN 1 END) as rutas_activas,
  COUNT(DISTINCT dificultad) as niveles_dificultad,
  MIN(precio_base) as precio_minimo,
  MAX(precio_base) as precio_maximo,
  ROUND(AVG(precio_base), 2) as precio_promedio
FROM public.ruta;
