// ============================================================================
// SCRIPT NODE.JS: Inserción de 5 Fincas en Supabase
// Generado: 19 de Marzo 2026
// Base de datos: BACKOCCI-S (Supabase)
// Tabla: public.finca
// Basado en: lib/data/fincas_data.dart
// ============================================================================

require('dotenv').config()
const { createClient } = require('@supabase/supabase-js')

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_KEY = process.env.SUPABASE_KEY

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Error: SUPABASE_URL o SUPABASE_KEY no están configuradas en .env')
  process.exit(1)
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

const fincas = [
  {
    nombre: 'Las Margaritas',
    descripcion: 'Una finca de lujo ubicada en las montañas de Sopetrán con vistas espectaculares. Cuenta con 5 habitaciones, piscina, zona de yoga, restaurante gourmet y servicios de spa. Perfecta para familias o grupos. Amenidades: WiFi, aire acondicionado, TV por cable, cocina gourmet, jacuzzi, zona de meditación, estacionamiento cubierto, jardinería landscaping. Incluye: Desayuno gourmet, acceso a piscina, servicios de limpieza diaria, personal de seguridad 24/7. Deposito de daños requerido.',
    ubicacion: 'Sopetrán, 10 minutos del parque principal',
    capacidad_personas: 25,
    precio_por_noche: 250000,
    imagen_url: 'assets/fincas/las_margaritas/principal.jpg',
    estado: true
  },
  {
    nombre: 'Las Heliconias',
    descripcion: 'Finca moderna con arquitectura contemporánea ubicada en un entorno natural privilegiado. Ofrece 4 suites con baño privado, piscina infinity, sauna, sala de conferencias y espacios amplios para eventos. Ideal para retiros corporativos. Amenidades: Biblioteca, tv inteligente, mini bar, aire acondicionado inteligente, terraza con vistas panorámicas, zona de reuniones, área de descanso. Incluye: Desayuno buffet, acceso a piscina, decoración floral diaria, WiFi de alta velocidad. Tarifa de aseo incluida.',
    ubicacion: 'Sopetrán, 10 minutos del parque principal',
    capacidad_personas: 20,
    precio_por_noche: 280000,
    imagen_url: 'assets/fincas/las_heliconias/principal.jpg',
    estado: true
  },
  {
    nombre: 'Las Palmas',
    descripcion: 'Finca elegante rodeada de palmeras y vegetación tropical exuberante. Posee 3 habitaciones amplias, piscina climatizada, restaurante a la carta, bar con vista panorámica. Excelente para luna de miel o vacaciones románticas. Amenidades: Terraza con hamacas, zona de hidromasaje, cocina completamente equipada, sistema de sonido ambiental, iluminación inteligente, jardinería de lujo. Incluye: Cena de bienvenida, acceso a piscina, servicio de room service, desayuno en la habitación. Deposito de daños: 20% del total.',
    ubicacion: 'Sopetrán, ubicación privilegiada con vistas al valle',
    capacidad_personas: 18,
    precio_por_noche: 300000,
    imagen_url: 'assets/fincas/las_palmas/principal.jpg',
    estado: true
  },
  {
    nombre: 'La Ilusión',
    descripcion: 'Finca tradicional antioqueña con toque moderno, ubicada en zona rural auténtica. Ofrece 4 habitaciones, piscina natural, granja con animales, y experiencias de turismo rural. Perfecta para familias que quieren conectar con la naturaleza. Amenidades: Zona de recreación infantil, cabras y gallinas libres, huerta orgánica, asadero tradicional, zona de hamacas, biblioteca de naturaleza. Incluye: Desayuno con productos locales, acceso a granja, actividades con animales, tours guiados por la propiedad. Tarifa de limpieza: $50,000 adicionales.',
    ubicacion: 'Sopetrán, zona rural a 15 minutos del pueblo',
    capacidad_personas: 20,
    precio_por_noche: 270000,
    imagen_url: 'assets/fincas/la_ilusion/principal.jpg',
    estado: true
  },
  {
    nombre: 'La María',
    descripcion: 'Finca boutique con decoración artesanal y arte local en cada rincón. Cuenta con 4 habitaciones con baño compartido (estilo hostal de lujo), sala común acogedora, cocina compartida, y espacios para convivencia. Ideal para viajeros mochileros con presupuesto medio-alto. Amenidades: Lounge bar, biblioteca de viajes, plantas decorativas en ambientes, decoración boho-chic, terraza común, juegos de mesa, música en vivo. Incluye: Desayuno simple, acceso a wifi, actividades comunitarias, recorridos locales. Deposito: $30,000. Tarifa aseo: $25,000 por día.',
    ubicacion: 'Sopetrán, a 5 minutos de la plaza principal',
    capacidad_personas: 22,
    precio_por_noche: 260000,
    imagen_url: 'assets/fincas/la_maria/principal.jpg',
    estado: true
  }
]

async function insertFincas() {
  try {
    // Verificar conexión
    const { data: testData, error: testError } = await supabase
      .from('finca')
      .select('count()', { count: 'exact' })
      .limit(1)

    if (testError) {
      console.error('❌ Error de conexión a Supabase:', testError.message)
      return
    }

    console.log('✅ Conexión exitosa a Supabase')
    console.log(`\n📍 Insertando ${fincas.length} fincas...\n`)

    let insertedCount = 0
    const errors = []

    // Insertar cada finca
    for (const finca of fincas) {
      try {
        const { data, error } = await supabase
          .from('finca')
          .insert([finca])
          .select()

        if (error) {
          console.error(`❌ Error insertando ${finca.nombre}:`, error.message)
          errors.push({ finca: finca.nombre, error: error.message })
        } else {
          console.log(`✅ ${finca.nombre} - Insertada correctamente (ID: ${data[0]?.id_finca})`)
          insertedCount++
        }
      } catch (err) {
        console.error(`❌ Excepción al insertar ${finca.nombre}:`, err.message)
        errors.push({ finca: finca.nombre, error: err.message })
      }
    }

    // Estadísticas finales
    console.log('\n' + '='.repeat(60))
    console.log('📊 ESTADÍSTICAS FINALES:')
    console.log('='.repeat(60))

    const { data: stats, error: statsError } = await supabase
      .from('finca')
      .select('*')

    if (!statsError && stats) {
      const capacidad_total = stats.reduce((sum, f) => sum + f.capacidad_personas, 0)
      const capacidad_promedio = (capacidad_total / stats.length).toFixed(2)
      const precios = stats.map(f => f.precio_por_noche)
      const precio_min = Math.min(...precios)
      const precio_max = Math.max(...precios)
      const precio_promedio = (precios.reduce((a, b) => a + b, 0) / precios.length).toFixed(0)

      console.log(`📈 Total de fincas: ${stats.length}`)
      console.log(`👥 Capacidad Total: ${capacidad_total} personas`)
      console.log(`📊 Capacidad Promedio: ${capacidad_promedio} personas por finca`)
      console.log(`💰 Precio Mínimo: $${precio_min.toLocaleString('es-CO')} por noche`)
      console.log(`💰 Precio Máximo: $${precio_max.toLocaleString('es-CO')} por noche`)
      console.log(`💰 Precio Promedio: $${precio_promedio.toLocaleString('es-CO')} por noche`)
    }

    console.log('='.repeat(60))
    console.log(`\n✨ Inserción completada: ${insertedCount}/${fincas.length} fincas`)

    if (errors.length > 0) {
      console.log('\n⚠️  Errores encontrados:')
      errors.forEach(e => console.log(`   - ${e.finca}: ${e.error}`))
    }

  } catch (error) {
    console.error('❌ Error general:', error.message)
  }
}

// Ejecutar
insertFincas()
