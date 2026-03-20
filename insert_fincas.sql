-- ============================================================================
-- SCRIPT SQL: Inserción de Fincas Occitours en Supabase
-- Generado: 19 de Marzo 2026
-- Base de datos: BACKOCCI-S PostgreSQL
-- Tabla: public.finca
-- Basado en: lib/data/fincas_data.dart
-- ============================================================================

-- Secuencia para PK
CREATE SEQUENCE IF NOT EXISTS public.finca_id_finca_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Tabla finca
CREATE TABLE IF NOT EXISTS public.finca (
  id_finca integer DEFAULT nextval('public.finca_id_finca_seq'::regclass) PRIMARY KEY,
  nombre character varying NOT NULL,
  descripcion text,
  ubicacion character varying,
  capacidad_personas integer,
  precio_por_noche numeric,
  imagen_url text,
  estado boolean DEFAULT true,
  fecha_creacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Índices / constraints adicionales (si aplican)
-- ALTER TABLE public.finca
--   ADD CONSTRAINT finca_nombre_unique UNIQUE (nombre);

-- ============================================================================
-- INSERCIÓN DE FINCAS
-- ============================================================================

INSERT INTO public.finca (nombre, descripcion, ubicacion, capacidad_personas, precio_por_noche, imagen_url, estado)
VALUES

-- FINCA 1: Las Margaritas
(
  'Las Margaritas',
  'Hermosa finca campestre ubicada en Sopetran a solo 10 minutos del parque principal. Ideal para grupos grandes de hasta 25 personas. Cuenta con cómodas habitaciones, piscina con chorros, áreas de recreación y excelentes servicios. Primera planta: Cocina integral bien dotada, sala con TV, 3 habitaciones, 6 camas, 2 baños, comedor grande, nevera y congelador, corredor con hamacas, fogón a leña, asador. Segunda planta: 4 habitaciones, 6 camas, 1 camarote, 2 tarimas, 1 sofá cama, 1 sala, 2 baños, balcón con muebles. Zonas comunes: Piscina con chorros, pequeño kiosco, billar, hamacas, amplia zona verde, parqueadero amplio.',
  'Sopetran, 10 min del parque principal',
  25,
  250000,
  'assets/fincas/las_margaritas/principal.jpg',
  true
),

-- FINCA 2: Las Heliconias
(
  'Las Heliconias',
  'Hermosa finca moderna ubicada en Sopetrán. Perfecta para grupos de hasta 20 personas. Diseño contemporáneo con todas las comodidades: dos piscinas, zona BBQ, WiFi, y habitaciones con aire acondicionado. Ideal para disfrutar en familia o con amigos. Zonas comunes: Sala con TV, cocina bien dotada, comedor, sonido, 3 baños, piscina con chorros, piscina de niños, zona verde, parqueadero amplio, 2 neveras, zona BBQ, agua potable, TV con DirecTV, zona WiFi. Habitaciones: Habitación 1 (2 camas dobles, 1 tarima, aire acondicionado), Habitación 2 (2 camas dobles, 1 TV, aire acondicionado), Habitación 3 (1 cama doble, 1 tarima, aire acondicionado, closet), Habitación 4 (2 camas dobles, 1 tarima, aire acondicionado). Depósito de daños: 300000. Tarifa aseo: 100000.',
  'Sopetrán, 10 minutos del parque principal',
  20,
  280000,
  'assets/fincas/las_heliconias/principal.jpg',
  true
),

-- FINCA 3: Las Palmas
(
  'Las Palmas',
  'Hermosa casa de dos niveles ubicada en Sopetran. Perfecta para grupos de hasta 18 personas. Moderno diseño con todas las comodidades: piscina con luces LED, jacuzzi, cascada, zona BBQ, billar y mucho más. Ideal para disfrutar de un fin de semana memorable en familia. Características generales: Casa de dos niveles, 3 habitaciones, 2 aires acondicionados, cocina dotada, comedor, sala de estar y televisión, WiFi, parqueadero. Zonas comunes: Zona verde pequeña, hamaca, billar, fogón de leña ecológico, asador a carbón, sillas asoleadoras, playita para niños, piscina con luces LED, cascada, jacuzzi.',
  'Sopetran',
  18,
  300000,
  'assets/fincas/las_palmas/principal.jpg',
  true
),

-- FINCA 4: La Ilusión - 68 Palma Real
(
  'La Ilusión - 68 Palma Real',
  'Hermosa casa de dos pisos ubicada en Sopetrán a 8 minutos del parque principal. Perfecta para grupos de hasta 20 personas. Cuenta con amplias áreas verdes, piscina con chorros y cascada, zonas de recreación y todos los servicios necesarios para una estancia agradable. Un espacio ideal para disfrutar en familia o con amigos. Características: 2 pisos, 4 habitaciones, áreas verdes amplias, piscina con chorros y cascada, cocina completa, comedor, salas de estar, baños completos, parqueadero. Servicios: Agua potable, luz, gas, WiFi, TV, zona BBQ.',
  'Sopetrán, 8 minutos del parque principal',
  20,
  270000,
  'assets/fincas/la_ilusion/principal.jpg',
  true
),

-- FINCA 5: La María
(
  'La María',
  'Espectacular finca campestre ubicada en Sopetrán, cercana al parque principal. Ideal para grupos de hasta 22 personas. Ofrece amplias zonas verdes, piscina, zonas de recreación y comodidad en todas sus instalaciones. Perfecta para disfrutar de un retiro en la naturaleza con todas las comodidades. Características: Múltiples habitaciones, piscina, áreas verdes amplias, cocina completa, zonas de entretenimiento, parqueadero, servicios completos para grupos grandes. Incluye: Salas comunes, comedor, TV, sonido, baños completos, zona BBQ, hamacas, zona verde para actividades.',
  'Sopetrán, cerca del parque principal',
  22,
  260000,
  'assets/fincas/la_maria/principal.jpg',
  true
);

-- ============================================================================
-- VERIFICACIÓN DE INSERCIÓN
-- ============================================================================

SELECT 
  id_finca,
  nombre,
  ubicacion,
  capacidad_personas,
  precio_por_noche,
  estado,
  fecha_creacion
FROM public.finca
ORDER BY id_finca;

-- ============================================================================
-- ESTADÍSTICAS FINALES
-- ============================================================================

SELECT 
  COUNT(*) as total_fincas,
  COUNT(CASE WHEN estado = true THEN 1 END) as fincas_activas,
  SUM(capacidad_personas) as capacidad_total,
  ROUND(AVG(capacidad_personas), 0) as capacidad_promedio,
  MIN(precio_por_noche) as precio_minimo,
  MAX(precio_por_noche) as precio_maximo,
  ROUND(AVG(precio_por_noche), 2) as precio_promedio
FROM public.finca;
