/**
 * Script: insert_rutas_supabase.js
 * Propósito: Insertar 14 rutas en tabla 'ruta' de Supabase
 * Fecha: 19 de Marzo 2026
 * Database: BACKOCCI-S (PostgreSQL)
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

// Datos de las 14 rutas
const rutas = [
  {
    nombre: 'Sendero del Cóndor',
    descripcion: 'Una experiencia única de senderismo a través de paisajes montañosos espectaculares donde avistará cóndores en su hábitat natural. Ruta desafiante pero gratificante con vistas panorámicas inolvidables.',
    duracion_dias: 1,
    precio_base: 120000,
    dificultad: 'Difícil',
    imagen_url: 'assets/rutas/sendero_condor/principal.jpg',
  },
  {
    nombre: 'Tour del Chocolate',
    descripcion: 'Una experiencia que nos sumerge en las verdaderas tradiciones y costumbres antioqueñas. A través del cacao, fruto insignia de la región, conocerás su proceso de transformación y la historia campesina que lo rodea.',
    duracion_dias: 1,
    precio_base: 75000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/tour_del_chocolate/principal.png',
  },
  {
    nombre: 'Tour de cata de vinos',
    descripcion: 'El mejor vino de Colombia y de los mejores del mundo en una experiencia única. En las montañas de Antioquia existe un lugar donde se producen vinos tan finos que han conquistado el mundo.',
    duracion_dias: 1,
    precio_base: 90000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/tour_cata_vinos/principal.png',
  },
  {
    nombre: 'Tours de tres cascadas',
    descripcion: 'Vive una experiencia completa donde la naturaleza lo tiene todo en un solo recorrido. La Ruta de Tres Cascadas combina la frescura del agua cristalina, la magia de la selva, la adrenalina de los retos en el camino.',
    duracion_dias: 1,
    precio_base: 85000,
    dificultad: 'Moderado',
    imagen_url: 'assets/rutas/tours_tres_cascadas/principal.png',
  },
  {
    nombre: 'Tour al puente occidente',
    descripcion: 'En esta experiencia recorrerás su historia y su valor cultural. Una visita a los barequeros, guardianes de las tradiciones mineras. El mirador del puente con paisajes que enamoran. Una caminata sobre el puente.',
    duracion_dias: 1,
    precio_base: 65000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/tour_al_puente_occidente/principal.png',
  },
  {
    nombre: 'City tours Santa Fe',
    descripcion: 'Adéntrate en el encanto colonial de Santa Fe de Antioquia, la ciudad madre de Antioquia y patrimonio cultural de Colombia. Sus calles empedradas, sus casas blancas con balcones coloridos y su imponente arquitectura colonial.',
    duracion_dias: 1,
    precio_base: 55000,
    dificultad: 'Muy Fácil',
    imagen_url: 'assets/rutas/city_tours_santa_fe/principal.png',
  },
  {
    nombre: 'Experiencia viña del tigre',
    descripcion: 'Viña del Tigre es un refugio en medio de la naturaleza, donde cada día se convierte en una experiencia auténtica de vida campesina. Aquí te esperan rutas del café, el cacao y la uva; la magia de la granja con sus animales.',
    duracion_dias: 1,
    precio_base: 80000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/experiencia_viña_tigre/principal.png',
  },
  {
    nombre: 'Tour de cuatrimotos',
    descripcion: 'Vive la emoción del tour en cuatrimotos en Sopetrán: una experiencia cargada de adrenalina, donde cada camino te lleva a descubrir paisajes sorprendentes, atravesar bosques encantadores y sentir la fuerza de los ríos.',
    duracion_dias: 1,
    precio_base: 150000,
    dificultad: 'Moderado',
    imagen_url: 'assets/rutas/tour_cuatrimotos/principal.png',
  },
  {
    nombre: 'Senderismo ecológico',
    descripcion: 'Caminar por Sopetrán es adentrarse en un territorio lleno de historia, paisajes y vida. Con 19 rutas identificadas, cada recorrido es una experiencia única que combina aventura, naturaleza y tradición.',
    duracion_dias: 1,
    precio_base: 95000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/senderismo_ecologico/principal.png',
  },
  {
    nombre: 'Paseo a caballo por el bosque',
    descripcion: 'Montar a caballo siempre es una experiencia única. En este recorrido por las riveras del río Tonusco, disfrutarás de senderos tranquilos y paisajes impresionantes, mientras conectas con la naturaleza y la cultura local.',
    duracion_dias: 1,
    precio_base: 75000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/paseo_caballo_bosque/principal.png',
  },
  {
    nombre: 'Bote paseo San Nicolas',
    descripcion: 'Vive la adrenalina navegando por la estrella fluvial del occidente colombiano, el majestuoso río Cauca. Durante este recorrido, sentirás la emoción de deslizarte sobre sus aguas mientras disfrutas del espectacular paisaje del cañón.',
    duracion_dias: 1,
    precio_base: 85000,
    dificultad: 'Fácil',
    imagen_url: 'assets/rutas/bote_paseo_san_nicolas/principal.png',
  },
  {
    nombre: 'Ruta de la uva en Sopetrán',
    descripcion: 'Un tour honrando la tierra de las frutas, Sopetrán. Entre senderos y viñedos, conocerás a don Nato, un campesino auténtico antioqueño. Con él descubrirás la tradición ancestral del cultivo de la uva y la magia de transformarla en vino artesanal.',
    duracion_dias: 1,
    precio_base: 65000,
    dificultad: 'Muy Fácil',
    imagen_url: 'assets/rutas/ruta_uva_sopetran/principal.png',
  },
  {
    nombre: 'City Tours Tierra De Las Frutas',
    descripcion: 'Un recorrido por la memoria y tradición del municipio, visitando el Mirador de Sopetrán, caminos ancestrales y calles de arquitectura republicana. Conocerás antiguas casas de personajes ilustres, instituciones educativas con gran legado.',
    duracion_dias: 1,
    precio_base: 60000,
    dificultad: 'Muy Fácil',
    imagen_url: 'assets/rutas/city_tours_tierra_frutas/principal.png',
  },
  {
    nombre: 'Ruta de avistamiento de aves',
    descripcion: 'Una experiencia de aprendizaje y profundo contacto con la naturaleza, recorriendo senderos que resguardan el bosque seco tropical. Sopetrán es hogar de especies endémicas como el Cucarachero Paisa y el imponente Ara Militaris.',
    duracion_dias: 1,
    precio_base: 110000,
    dificultad: 'Moderado',
    imagen_url: 'assets/rutas/avistamiento_aves/principal.png',
  },
];

/**
 * Función principal para insertar rutas
 */
async function insertarRutas() {
  try {
    console.log('\n🚀 Iniciando inserción de 14 rutas en Supabase...\n');

    // Verificar conexión
    console.log('📡 Verificando conexión con Supabase...');
    const { data: testConnection, error: testError } = await supabase
      .from('ruta')
      .select('id_ruta')
      .limit(1);

    if (testError) {
      throw new Error(`No se pudo conectar a Supabase: ${testError.message}`);
    }
    console.log('✅ Conexión exitosa\n');

    // Insertar cada ruta
    console.log('📝 Insertando rutas...\n');
    let insertados = 0;
    let errores = 0;

    for (let i = 0; i < rutas.length; i++) {
      const ruta = rutas[i];
      const { data, error } = await supabase
        .from('ruta')
        .insert([
          {
            nombre: ruta.nombre,
            descripcion: ruta.descripcion,
            duracion_dias: ruta.duracion_dias,
            precio_base: ruta.precio_base,
            dificultad: ruta.dificultad,
            imagen_url: ruta.imagen_url,
            estado: true,
          },
        ])
        .select();

      if (error) {
        console.error(`   ❌ ${i + 1}. ${ruta.nombre} - Error: ${error.message}`);
        errores++;
      } else {
        console.log(`   ✅ ${i + 1}. ${ruta.nombre} (ID: ${data[0]?.id_ruta || 'N/A'})`);
        insertados++;
      }
    }

    console.log(`\n📊 Resumen de inserción:`);
    console.log(`   ✅ Rutas insertadas: ${insertados}`);
    console.log(`   ❌ Errores: ${errores}`);
    console.log(`   📈 Total procesadas: ${rutas.length}`);

    // Verificación final
    console.log('\n🔍 Verificando datos en la base de datos...\n');
    const { data: statsData, error: statsError } = await supabase
      .from('ruta')
      .select('id_ruta, nombre, precio_base, dificultad, estado');

    if (statsError) {
      throw new Error(`Error al consultar: ${statsError.message}`);
    }

    console.log(`📋 Total de rutas en BD: ${statsData.length}`);
    console.log(`\n📊 Estadísticas:\n`);

    // Agrupar por dificultad
    const porDificultad = {};
    let precioMin = Infinity;
    let precioMax = 0;
    let precioTotal = 0;

    statsData.forEach((ruta) => {
      porDificultad[ruta.dificultad] = (porDificultad[ruta.dificultad] || 0) + 1;
      precioMin = Math.min(precioMin, ruta.precio_base);
      precioMax = Math.max(precioMax, ruta.precio_base);
      precioTotal += ruta.precio_base;
    });

    console.log('   Rutas por dificultad:');
    Object.entries(porDificultad).forEach(([dificultad, cantidad]) => {
      console.log(`      • ${dificultad}: ${cantidad} rutas`);
    });

    console.log(`\n   Rango de precios:`);
    console.log(`      • Mínimo: $${precioMin.toLocaleString('es-CO')}`);
    console.log(`      • Máximo: $${precioMax.toLocaleString('es-CO')}`);
    console.log(`      • Promedio: $${Math.round(precioTotal / statsData.length).toLocaleString('es-CO')}`);

    console.log('\n✨ ¡Inserción completada exitosamente!\n');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error fatal:', error.message);
    console.error(error);
    process.exit(1);
  }
}

// Ejecutar
insertarRutas();
