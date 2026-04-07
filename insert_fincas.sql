-- ============================================================================
-- SCRIPT SQL: Inserción de 5 Fincas Occitours en Supabase
-- Generado: 19 de Marzo 2026
-- Base de datos: BACKOCCI-S PostgreSQL
-- Tabla: public.finca (ya creada)
-- Basado en: lib/data/fincas_data.dart
-- ============================================================================

-- INSERCIÓN DE 5 FINCAS

INSERT INTO public.finca (nombre, descripcion, ubicacion, capacidad_personas, precio_por_noche, imagen_url, estado)
VALUES

-- FINCA 1: Las Margaritas
(
  'Las Margaritas',
  'Una finca de lujo ubicada en las montañas de Sopetrán con vistas espectaculares. Cuenta con 5 habitaciones, piscina, zona de yoga, restaurante gourmet y servicios de spa. Perfecta para familias o grupos. Amenidades: WiFi, aire acondicionado, TV por cable, cocina gourmet, jacuzzi, zona de meditación, estacionamiento cubierto, jardinería landscaping. Incluye: Desayuno gourmet, acceso a piscina, servicios de limpieza diaria, personal de seguridad 24/7. Deposito de daños requerido.',
  'Sopetrán, 10 minutos del parque principal',
  25,
  250000,
  'assets/fincas/las_margaritas/principal.jpg',
  true
),

-- FINCA 2: Las Heliconias
(
  'Las Heliconias',
  'Finca moderna con arquitectura contemporánea ubicada en un entorno natural privilegiado. Ofrece 4 suites con baño privado, piscina infinity, sauna, sala de conferencias y espacios amplios para eventos. Ideal para retiros corporativos. Amenidades: Biblioteca, tv inteligente, mini bar, aire acondicionado inteligente, terraza con vistas panorámicas, zona de reuniones, área de descanso. Incluye: Desayuno buffet, acceso a piscina, decoración floral diaria, WiFi de alta velocidad. Tarifa de aseo incluida.',
  'Sopetrán, 10 minutos del parque principal',
  20,
  280000,
  'assets/fincas/las_heliconias/principal.jpg',
  true
),

-- FINCA 3: Las Palmas
(
  'Las Palmas',
  'Finca elegante rodeada de palmeras y vegetación tropical exuberante. Posee 3 habitaciones amplias, piscina climatizada, restaurante a la carta, bar con vista panorámica. Excelente para luna de miel o vacaciones románticas. Amenidades: Terraza con hamacas, zona de hidromasaje, cocina completamente equipada, sistema de sonido ambiental, iluminación inteligente, jardinería de lujo. Incluye: Cena de bienvenida, acceso a piscina, servicio de room service, desayuno en la habitación. Deposito de daños: 20% del total.',
  'Sopetrán, ubicación privilegiada con vistas al valle',
  18,
  300000,
  'assets/fincas/las_palmas/principal.jpg',
  true
),

-- FINCA 4: La Ilusión
(
  'La Ilusión',
  'Finca tradicional antioqueña con toque moderno, ubicada en zona rural auténtica. Ofrece 4 habitaciones, piscina natural, granja con animales, y experiencias de turismo rural. Perfecta para familias que quieren conectar con la naturaleza. Amenidades: Zona de recreación infantil, cabras y gallinas libres, huerta orgánica, asadero tradicional, zona de hamacas, biblioteca de naturaleza. Incluye: Desayuno con productos locales, acceso a granja, actividades con animales, tours guiados por la propiedad. Tarifa de limpieza: $50,000 adicionales.',
  'Sopetrán, zona rural a 15 minutos del pueblo',
  20,
  270000,
  'assets/fincas/la_ilusion/principal.jpg',
  true
),

-- FINCA 5: La María
(
  'La María',
  'Finca boutique con decoración artesanal y arte local en cada rincón. Cuenta con 4 habitaciones con baño compartido (estilo hostal de lujo), sala común acogedora, cocina compartida, y espacios para convivencia. Ideal para viajeros mochileros con presupuesto medio-alto. Amenidades: Lounge bar, biblioteca de viajes, plantas decorativas en ambientes, decoración boho-chic, terraza común, juegos de mesa, música en vivo. Incluye: Desayuno simple, acceso a wifi, actividades comunitarias, recorridos locales. Deposito: $30,000. Tarifa aseo: $25,000 por día.',
  'Sopetrán, a 5 minutos de la plaza principal',
  22,
  260000,
  'assets/fincas/la_maria/principal.jpg',
  true
);

-- SELECT de verificación
SELECT id_finca, nombre, ubicacion, capacidad_personas, precio_por_noche, estado, fecha_creacion
FROM public.finca
ORDER BY id_finca;
