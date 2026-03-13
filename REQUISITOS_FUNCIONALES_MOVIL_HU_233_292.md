# Requisitos Funcionales Móvil (HU_233 a HU_292)

Fecha: 12-03-2026  
Proyecto: Occitours App Móvil

## 1. Alcance
Este documento consolida las historias de usuario y criterios de aceptación compartidos para:
- Gestión de acceso (autenticación)
- Gestión de programación
- Gestión de reservas
- Gestión de catálogo (rutas, fincas, servicios)

Roles involucrados:
- Administrador
- Asesor
- Guía
- Cliente
- Usuario del sistema (genérico para autenticación)

## 2. Mapa de épicas
- Épica A: Acceso y seguridad (HU_233–HU_235)
- Épica B: Programación (HU_236–HU_257)
- Épica C: Reservas (HU_258–HU_264, HU_271–HU_274, HU_281–HU_286)
- Épica D: Catálogo (rutas, fincas, servicios) (HU_240–HU_241, HU_249, HU_265–HU_270, HU_277–HU_280, HU_289–HU_292)
- Épica E: Programación personal cliente (HU_287–HU_288)

## 3. Historias por dominio

### 3.1 Acceso y seguridad
- HU_233: Iniciar sesión
- HU_234: Cerrar sesión
- HU_235: Recuperar contraseña

Criterios críticos consolidados:
- Formulario de login con usuario/correo y contraseña.
- Validación de credenciales contra cuenta activa.
- Creación e invalidación de sesión en servidor y cliente.
- Redirección por rol tras login.
- HTTPS obligatorio.
- Recuperación con enlace seguro, de un solo uso y expiración.
- Mensajería clara, legible y amigable.

### 3.2 Programación
Administrador:
- HU_236 Crear programación
- HU_237 Listar programación
- HU_238 Buscar programación
- HU_239 Editar programación
- HU_240 Agregar ruta
- HU_241 Eliminar ruta
- HU_242 Eliminar programación
- HU_243 Ver detalle
- HU_244 Cambiar estado

Asesor:
- HU_245 Crear programación
- HU_246 Buscar programación
- HU_247 Listar programación
- HU_248 Editar programación
- HU_249 Agregar ruta
- HU_250 Ver detalle
- HU_251 Cambiar estado

Guía:
- HU_252 Listar programación
- HU_253 Buscar programación
- HU_254 Ver detalle

Cliente:
- HU_255 Listar programación
- HU_256 Buscar programación
- HU_257 Ver detalle

Criterios críticos consolidados:
- Evitar duplicidad por ruta/paquete/finca + fecha/hora.
- Listar con filtros y ordenamientos.
- Búsqueda con validaciones y tiempo de respuesta <= 2s.
- Confirmaciones claras para crear/editar/eliminar/cambiar estado.
- Elementos inactivos no deben estar disponibles para selección/asignación.

### 3.3 Reservas
Administrador:
- HU_258 Crear reservas
- HU_259 Listar reservas
- HU_260 Buscar reservas
- HU_261 Editar reservas
- HU_262 Ver detalle de reservas
- HU_263 Cancelar reservas
- HU_264 Cambiar estado de reservas

Asesor:
- HU_271 Listar una reserva
- HU_272 Buscar una reserva
- HU_273 Editar una reserva
- HU_274 Ver detalle de una reserva

Cliente:
- HU_281 Crear una reserva
- HU_282 Listar mi reserva
- HU_283 Buscar mis reservas
- HU_284 Editar una reserva
- HU_285 Cancelar una reserva
- HU_286 Ver el detalle de una reserva

Criterios críticos consolidados:
- Validar conflictos de horario/recurso.
- Reflejar cambios en estado inmediatamente.
- Soporte a comprobante de pago.
- Manejo de notificaciones de creación/cancelación/cambio.
- Transiciones de estado válidas (máquina de estados).

### 3.4 Catálogo (rutas, fincas, servicios)
Administrador:
- HU_265 Agregar programación/ruta
- HU_266 Agregar finca
- HU_267 Agregar servicios
- HU_268 Eliminar programación/ruta
- HU_269 Eliminar finca
- HU_270 Eliminar servicios

Asesor:
- HU_275 Agregar programación
- HU_276 Eliminar programación
- HU_277 Agregar finca
- HU_278 Eliminar finca
- HU_279 Agregar servicio
- HU_280 Eliminar servicio

Cliente:
- HU_289 Agregar finca
- HU_290 Eliminar finca
- HU_291 Agregar servicio
- HU_292 Eliminar servicio

Criterios críticos consolidados:
- Campos obligatorios y validación de formato.
- Unicidad de código/nombre según entidad.
- Bloqueo de eliminación con dependencias activas.
- Confirmaciones y mensajes de error sin detalle técnico.
- Registro de auditoría en acciones destructivas.

### 3.5 Programación personal del cliente
- HU_287 Agregar programación
- HU_288 Eliminar programación

Criterios críticos consolidados:
- Crear/editar/listar actividades personales.
- Marcar actividad completada.
- Confirmación antes de eliminar.
- Registro de auditoría para eliminación.

## 4. Reglas de negocio transversales
- RN_01: Mensajes de UI deben ser claros, legibles y amigables.
- RN_02: Operaciones de autenticación y sesión deben usar HTTPS.
- RN_03: No revelar detalles técnicos en errores funcionales.
- RN_04: Cambios críticos (eliminar/cancelar/cambiar estado) requieren confirmación.
- RN_05: El sistema debe impedir operaciones inválidas por estado o dependencias.
- RN_06: Registrar auditoría para acciones sensibles.

## 5. Trazabilidad técnica (Flutter)
### 5.1 Módulos actuales detectados
- Auth:
  - `lib/providers/auth_provider.dart`
  - `lib/services/auth_service.dart`
  - `lib/screens/auth/login_screen.dart`
  - `lib/screens/auth/forgot_password_screen.dart`
  - `lib/screens/auth/register_screen.dart`
  - `lib/screens/auth/verify_email_screen.dart`
- Programación:
  - `lib/models/programacion.dart`
  - `lib/services/programacion_service.dart`
- Reservas:
  - `lib/models/reserva.dart`
  - `lib/services/reserva_service.dart`
- Catálogo:
  - `lib/providers/catalogo_provider.dart`
  - `lib/services/finca_service.dart`
  - `lib/services/ruta_service.dart`
  - `lib/screens/catalogo/*`

### 5.2 Fases sugeridas de implementación
- Fase 1 (inmediata): HU_233, HU_234, HU_235
- Fase 2: Programación base (crear/listar/buscar/editar/detalle/cambiar estado)
- Fase 3: Reservas base (crear/listar/buscar/detalle/editar/cancelar/estado)
- Fase 4: Catálogo y reglas de dependencias/auditoría
- Fase 5: Rendimiento, tiempos de respuesta, hardening de seguridad y pruebas E2E

## 6. Matriz corta HU -> componente móvil
- Acceso: `auth_provider`, `auth_service`, `login_screen`, `forgot_password_screen`, `router`.
- Programación: `programacion_service`, pantallas de listado/detalle/edición en módulo `screens/programacion`.
- Reservas: `reserva_service`, futuras pantallas en `screens/reservas`.
- Catálogo: `catalogo_provider`, `finca_service`, `ruta_service`, pantallas de catálogo.

## 7. Definición de Hecho (DoD) por HU
Una HU se considera completada si:
1. Cumple todos los criterios de aceptación asociados.
2. Tiene validaciones de formulario y reglas de negocio implementadas.
3. Maneja estados de carga, éxito y error en UI.
4. Está conectada a backend y persiste correctamente.
5. Incluye prueba funcional manual mínima documentada.

## 8. Notas de normalización
- Se detectaron descripciones repetidas y pequeños errores tipográficos en el origen.
- Este documento conserva el alcance funcional y unifica redacción para implementación.
- Para auditoría formal, mantener un anexo CSV con HU y CA originales textuales.
