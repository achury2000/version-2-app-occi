/**
 * Script: insert_fincas_supabase.js
 * Propósito: Insertar fincas en tabla 'finca' de Supabase
 * Fecha: 19 de Marzo 2026
 * Database: BACKOCCI-S (PostgreSQL)
 * Basado en: lib/data/fincas_data.dart
 */

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

// Configuración Supabase
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Error: Falta SUPABASE_URL o SUPABASE_KEY en .env');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// Datos de las fincas - Información completa extraída de fincas_data.dart
const fincas = [
  {
    nombre: 'Las Margaritas',
    ubicacion: 'Sopetran, 10 min del parque principal',
    descripcion: 'Hermosa finca campestre ubicada en Sopetran a solo 10 minutos del parque principal. Ideal para grupos grandes de hasta 25 personas. Cuenta con cómodas habitaciones, piscina con chorros, áreas de recreación y excelentes servicios. Primera planta: Cocina integral bien dotada, sala con TV, 3 habitaciones, 6 camas, 2 baños, comedor grande, nevera y congelador, corredor con hamacas, fogón a leña, asador. Segunda planta: 4 habitaciones, 6 camas, 1 camarote, 2 tarimas, 1 sofá cama, 1 sala, 2 baños, balcón con muebles. Zonas comunes: Piscina con chorros, pequeño kiosco, billar, hamacas, amplia zona verde, parqueadero amplio.',
    capacidad_personas: 25,
    precio_por_noche: 250000,
    imagen_url: 'assets/fincas/las_margaritas/principal.jpg',
  },
  {
    nombre: 'Las Heliconias',
    ubicacion: 'Sopetrán, 10 minutos del parque principal',
    descripcion: 'Hermosa finca moderna ubicada en Sopetrán. Perfecta para grupos de hasta 20 personas. Diseño contemporáneo con todas las comodidades: dos piscinas, zona BBQ, WiFi, y habitaciones con aire acondicionado. Ideal para disfrutar en familia o con amigos. Zonas comunes: Sala con TV, cocina bien dotada, comedor, sonido, 3 baños, piscina con chorros, piscina de niños, zona verde, parqueadero amplio, 2 neveras, zona BBQ, agua potable, TV con DirecTV, zona WiFi. Habitaciones: Habitación 1 (2 camas dobles, 1 tarima, aire acondicionado), Habitación 2 (2 camas dobles, 1 TV, aire acondicionado), Habitación 3 (1 cama doble, 1 tarima, aire acondicionado, closet), Habitación 4 (2 camas dobles, 1 tarima, aire acondicionado).',
    capacidad_personas: 20,
    precio_por_noche: 280000,
    imagen_url: 'assets/fincas/las_heliconias/principal.jpg',
  },
  {
    nombre: 'Las Palmas',
    ubicacion: 'Sopetran',
    descripcion: 'Hermosa casa de dos niveles ubicada en Sopetran. Perfecta para grupos de hasta 18 personas. Moderno diseño con todas las comodidades: piscina con luces LED, jacuzzi, cascada, zona BBQ, billar y mucho más. Ideal para disfrutar de un fin de semana memorable en familia. Características generales: Casa de dos niveles, 3 habitaciones, 2 aires acondicionados, cocina dotada, comedor, sala de estar y televisión, WiFi, parqueadero. Zonas comunes: Zona verde pequeña, hamaca, billar, fogón de leña ecológico, asador a carbón, sillas asoleadoras, playita para niños, piscina con luces LED, cascada, jacuzzi.',
    capacidad_personas: 18,
    precio_por_noche: 300000,
    imagen_url: 'assets/fincas/las_palmas/principal.jpg',
  },
  {
    nombre: 'La Ilusión - 68 Palma Real',
    ubicacion: 'Sopetrán, 8 minutos del parque principal',
    descripcion: 'Hermosa casa de dos pisos ubicada en Sopetrán a 8 minutos del parque principal. Perfecta para grupos de hasta 20 personas. Cuenta con amplias áreas verdes, piscina con chorros y cascada, zonas de recreación y todos los servicios necesarios para una estancia agradable. Un espacio ideal para disfrutar en familia o con amigos. Características: 2 pisos, 4 habitaciones, áreas verdes amplias, piscina con chorros y cascada, cocina completa, comedor, salas de estar, baños completos, parqueadero.',
    capacidad_personas: 20,
    precio_por_noche: 270000,
    imagen_url: 'assets/fincas/la_ilusion/principal.jpg',
  },
  {
    nombre: 'La María',
    ubicacion: 'Sopetrán, cerca del parque principal',
    descripcion: 'Espectacular finca campestre ubicada en Sopetrán, cercana al parque principal. Ideal para grupos de hasta 22 personas. Ofrece amplias zonas verdes, piscina, zonas de recreación y comodidad en todas sus instalaciones. Perfecta para disfrutar de un retiro en la naturaleza con todas las comodidades. Características: Múltiples habitaciones, piscina, áreas verdes amplias, cocina completa, zonas de entretenimiento, parqueadero, servicios completos para grupos grandes.',
    capacidad_personas: 22,
    precio_por_noche: 260000,
    imagen_url: 'assets/fincas/la_maria/principal.jpg',
  },
];

/**
 * Función principal para insertar fincas
 */
async function insertarFincas() {
  try {
    console.log('\n🚀 Iniciando inserción de fincas en Supabase...\n');

    // Verificar conexión
    console.log('📡 Verificando conexión con Supabase...');
    const { data: testConnection, error: testError } = await supabase
      .from('finca')
      .select('id_finca')
      .limit(1);

    if (testError) {
      throw new Error(`No se pudo conectar a Supabase: ${testError.message}`);
    }
    console.log('✅ Conexión exitosa\n');

    // Insertar cada finca
    console.log('📝 Insertando fincas...\n');
    let insertadas = 0;
    let errores = 0;

    for (let i = 0; i < fincas.length; i++) {
      const finca = fincas[i];
      const { data, error } = await supabase
        .from('finca')
        .insert([
          {
            nombre: finca.nombre,
            descripcion: finca.descripcion,
            ubicacion: finca.ubicacion,
            capacidad_personas: finca.capacidad_personas,
            precio_por_noche: finca.precio_por_noche,
            imagen_url: finca.imagen_url,
            estado: true,
          },
        ])
        .select();

      if (error) {
        console.error(`   ❌ ${i + 1}. ${finca.nombre} - Error: ${error.message}`);
        errores++;
      } else {
        console.log(`   ✅ ${i + 1}. ${finca.nombre} (ID: ${data[0]?.id_finca || 'N/A'})`);
        insertadas++;
      }
    }

    console.log(`\n📊 Resumen de inserción:`);
    console.log(`   ✅ Fincas insertadas: ${insertadas}`);
    console.log(`   ❌ Errores: ${errores}`);
    console.log(`   📈 Total procesadas: ${fincas.length}`);

    // Verificación final
    console.log('\n🔍 Verificando datos en la base de datos...\n');
    const { data: fincasData, error: fincasError } = await supabase
      .from('finca')
      .select('id_finca, nombre, capacidad_personas, precio_por_noche, estado');

    if (fincasError) {
      throw new Error(`Error al consultar: ${fincasError.message}`);
    }

    console.log(`📋 Total de fincas en BD: ${fincasData.length}`);
    console.log(`\n📊 Estadísticas:\n`);

    let capacidadTotal = 0;
    let precioMin = Infinity;
    let precioMax = 0;
    let precioTotal = 0;

    fincasData.forEach((finca) => {
      capacidadTotal += finca.capacidad_personas;
      precioMin = Math.min(precioMin, finca.precio_por_noche);
      precioMax = Math.max(precioMax, finca.precio_por_noche);
      precioTotal += finca.precio_por_noche;
    });

    console.log('   Detalle por finca:');
    fincasData.forEach((finca, index) => {
      console.log(`      ${index + 1}. ${finca.nombre}`);
      console.log(`         • ID: ${finca.id_finca}`);
      console.log(`         • Capacidad: ${finca.capacidad_personas} personas`);
      console.log(`         • Precio: $${finca.precio_por_noche.toLocaleString('es-CO')}/noche`);
    });

    console.log(`\n   Resumen financiero:`);
    console.log(`      • Precio mínimo: $${precioMin.toLocaleString('es-CO')}/noche`);
    console.log(`      • Precio máximo: $${precioMax.toLocaleString('es-CO')}/noche`);
    console.log(`      • Precio promedio: $${Math.round(precioTotal / fincasData.length).toLocaleString('es-CO')}/noche`);
    console.log(`      • Capacidad total: ${capacidadTotal} personas`);
    console.log(`      • Capacidad promedio: ${Math.round(capacidadTotal / fincasData.length)} personas/finca`);

    console.log('\n✨ ¡Inserción completada exitosamente!\n');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error fatal:', error.message);
    console.error(error);
    process.exit(1);
  }
}

// Ejecutar
insertarFincas();
