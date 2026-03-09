/// Barrel file que exporta todos los servicios de la app.
///
/// Uso: import 'package:occitours/services/services.dart';
///
/// Servicios disponibles:
/// - [ApiService]           → Cliente HTTP genérico con interceptor JWT
/// - [TokenService]         → Almacenamiento persistente del token JWT
/// - [AuthService]          → Login, registro, perfil, cambiar contraseña
/// - [ClienteService]       → Gestión de perfil de cliente (completar perfil, actualizar)
/// - [FincaService]         → Consulta de fincas (disponibles, búsqueda, detalle)
/// - [RutaService]          → Consulta de rutas (activas, búsqueda, por dificultad)
/// - [ProgramacionService]  → Consulta de programaciones (disponibles, por ruta)
/// - [ReservaService]       → Gestión de reservas (crear, cancelar, acompañantes)
/// - [ConnectionService]    → Test de conexión con el servidor

export 'api_service.dart';
export 'token_service.dart';
export 'auth_service.dart';
export 'cliente_service.dart';
export 'finca_service.dart';
export 'ruta_service.dart';
export 'programacion_service.dart';
export 'reserva_service.dart';
export 'connection_service.dart';
