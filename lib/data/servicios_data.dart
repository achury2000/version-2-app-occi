/// Datos simulados de Servicios
/// Estos están "quemados" en la app por ahora (como rutas y fincas)
/// Eventualmente se reemplazarán con llamadas a la API

import '../models/servicio.dart';

final serviciosData = [
  Servicio(
    id: 1,
    nombre: 'Guía Especializado',
    descripcion: 'Incluye guía turístico experto durante toda la experiencia con información sobre flora, fauna y ecología.',
    precio: 50000,
    imagenUrl: 'assets/services/guia.png',
    estado: true,
  ),
  Servicio(
    id: 2,
    nombre: 'Almuerzo Incluido',
    descripcion: 'Comida típica de la región preparada con ingredientes locales y frescos.',
    precio: 35000,
    imagenUrl: 'assets/services/almuerzo.png',
    estado: true,
  ),
  Servicio(
    id: 3,
    nombre: 'Transporte Premium',
    descripcion: 'Transporte en vehículo 4x4 o campero adaptado para terrenos montañosos.',
    precio: 40000,
    imagenUrl: 'assets/services/transporte.png',
    estado: true,
  ),
  Servicio(
    id: 4,
    nombre: 'Fotografía Profesional',
    descripcion: 'Sesión de fotos profesional durante la experiencia. Incluye álbum digital.',
    precio: 80000,
    imagenUrl: 'assets/services/fotografia.png',
    estado: true,
  ),
  Servicio(
    id: 5,
    nombre: 'Kit de Campamento',
    descripcion: 'Tienda de campaña, sleeping bag, colchoneta y linterna LED incluida.',
    precio: 60000,
    imagenUrl: 'assets/services/campamento.png',
    estado: true,
  ),
  Servicio(
    id: 6,
    nombre: 'Snorkel en Cascadas',
    descripcion: 'Equipo de snorkel y nado en piscinas naturales con agua cristalina.',
    precio: 45000,
    imagenUrl: 'assets/services/snorkel.png',
    estado: true,
  ),
  Servicio(
    id: 7,
    nombre: 'Taller de Artesanías',
    descripcion: 'Taller donde aprendes técnicas artesanales locales y creas tu propio souvenir.',
    precio: 30000,
    imagenUrl: 'assets/services/artesanias.png',
    estado: true,
  ),
  Servicio(
    id: 8,
    nombre: 'Cata de Café',
    descripcion: 'Degustación de café de la región directamente de la finca. Incluye explicación del proceso.',
    precio: 25000,
    imagenUrl: 'assets/services/cafe.png',
    estado: true,
  ),
  Servicio(
    id: 9,
    nombre: 'Hospedaje una Noche',
    descripcion: 'Alojamiento cómodo en cabaña eco-friendly con baño privado y agua caliente.',
    precio: 120000,
    imagenUrl: 'assets/services/hospedaje.png',
    estado: true,
  ),
  Servicio(
    id: 10,
    nombre: 'Meditación Guiada',
    descripcion: 'Sesión de meditación y yoga en medio de la naturaleza con instructor certificado.',
    precio: 35000,
    imagenUrl: 'assets/services/meditacion.png',
    estado: true,
  ),
  Servicio(
    id: 11,
    nombre: 'Bicicleta de Montaña',
    descripcion: 'Alquiler de bicicleta de montaña de alta gama para recorrido guiado.',
    precio: 55000,
    imagenUrl: 'assets/services/bicicleta.png',
    estado: true,
  ),
  Servicio(
    id: 12,
    nombre: 'Seguro de Viaje',
    descripcion: 'Cobertura de seguro que incluye accidentes, asistencia médica y rescate.',
    precio: 25000,
    imagenUrl: 'assets/services/seguro.png',
    estado: true,
  ),
];
