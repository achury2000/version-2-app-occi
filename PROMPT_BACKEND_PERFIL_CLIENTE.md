# Prompt Backend - Perfil de Cliente enlazado con Usuario

Necesito que implementes o ajustes el backend de Occitours para soportar correctamente el flujo móvil de completar perfil de cliente.

## Objetivo funcional

El flujo esperado es este:

1. El usuario se registra y su cuenta queda en la tabla usuarios.
2. El usuario inicia sesión.
3. En la app móvil entra a Completar Perfil.
4. Al guardar el formulario, el backend debe crear o actualizar su registro en la tabla clientes.
5. Ese registro debe quedar enlazado por clientes.id_usuario = usuarios.id.

## Importante

- No quiero una solución nueva desligada de la arquitectura actual.
- Si el proyecto backend ya tiene módulos de auth, usuarios y clientes, adapta la implementación a esa estructura.
- Prioriza seguridad, consistencia de datos y compatibilidad con la app Flutter actual.

## Contrato que ya espera la app Flutter

Endpoints actuales consumidos por la app:

- POST /api/auth/login
- GET /api/auth/profile
- GET /api/clientes/usuario/:idUsuario
- POST /api/clientes
- PUT /api/clientes/:id

La app móvil actualmente hace esto:

- Busca primero el cliente por id_usuario.
- Si existe, actualiza.
- Si no existe, crea.
- Si POST devuelve duplicado, reintenta como update.
- El frontend tolera respuestas con payload en cliente, data, perfil o result, pero la respuesta preferida sigue siendo cliente.

## Requerimientos técnicos obligatorios

### 1. Modelo de datos

La tabla clientes debe tener relación única con usuarios:

- clientes.id_usuario NOT NULL
- FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
- UNIQUE (id_usuario)

Si hoy no existe esa restricción, crea la migración o SQL necesario.

### 2. Crear perfil de cliente

Implementar o ajustar:

- POST /api/clientes

Reglas:

- Debe validar JWT.
- Debe operar con el usuario autenticado.
- Si el body trae id_usuario, debes validar que coincida con req.user.id o ignorarlo y usar el id del token.
- No debe permitir crear perfiles para otro usuario salvo un rol administrativo explícito.
- Si ya existe cliente para ese id_usuario, puedes:
   - responder 409, o
   - hacer upsert controlado si la arquitectura actual lo permite.

### 3. Actualizar perfil de cliente

Implementar o ajustar:

- PUT /api/clientes/:id

Reglas:

- Debe validar JWT.
- Solo debe permitir editar el propio cliente autenticado, salvo permisos administrativos explícitos.
- Debe validar que el cliente realmente pertenezca al req.user.id cuando el rol no sea administrativo.

### 4. Consultar cliente por usuario

Implementar o ajustar:

- GET /api/clientes/usuario/:idUsuario

Debe devolver el cliente asociado a ese usuario.

Respuesta preferida:

```json
{
   "success": true,
   "cliente": {
      "id": 10,
      "id_usuario": 25,
      "tipo_documento": "Cédula",
      "numero_documento": "123456789",
      "telefono": "3001234567",
      "direccion": "Calle 1 # 2 - 3",
      "ciudad": "Pitalito",
      "pais": "Colombia",
      "codigo_postal": "417030",
      "fecha_nacimiento": "1998-05-10",
      "genero": "Masculino",
      "nacionalidad": "Colombiana",
      "preferencias": null,
      "notas": null,
      "newsletter": false,
      "estado": true,
      "created_at": "2026-03-16T10:00:00.000Z",
      "updated_at": "2026-03-16T10:00:00.000Z"
   }
}
```

Si no existe cliente para ese usuario:

- puedes responder 404, o
- success false con mensaje claro,

pero debe ser consistente.

## Body esperado para crear o actualizar cliente

El backend debe aceptar como mínimo este payload:

```json
{
   "id_usuario": 25,
   "tipo_documento": "Cédula",
   "numero_documento": "123456789",
   "telefono": "3001234567",
   "direccion": "Calle 1 # 2 - 3",
   "ciudad": "Pitalito",
   "pais": "Colombia",
   "codigo_postal": "417030",
   "fecha_nacimiento": "1998-05-10",
   "genero": "Masculino",
   "nacionalidad": "Colombiana",
   "preferencias": "Ecoturismo",
   "notas": "Cliente frecuente",
   "newsletter": false,
   "estado": true
}
```

## Respuestas esperadas

### Éxito en POST y PUT

```json
{
   "success": true,
   "message": "Perfil de cliente guardado correctamente",
   "cliente": {
      "id": 10,
      "id_usuario": 25
   }
}
```

### Errores mínimos

- 401 si no hay token o expiró.
- 403 si el rol no puede operar o intenta tocar datos de otro usuario.
- 404 si el cliente no existe en GET o PUT.
- 409 si ya existe un cliente para ese id_usuario y no se hace upsert.
- 422 para errores de validación.

## Validaciones mínimas

Campos obligatorios:

- tipo_documento
- numero_documento
- direccion
- ciudad
- pais

Adicionalmente:

- validar formato si el proyecto ya usa DTOs, schemas o class-validator.
- no confiar en id_usuario enviado desde frontend cuando ya existe req.user en JWT.

## Seguridad y reglas de autorización

- No permitir crear o editar cliente de otro usuario salvo rol administrativo explícito.
- Tomar req.user.id como fuente de verdad cuando aplique.
- Registrar auditoría de creación y actualización si el proyecto ya tiene infraestructura para ello.
- Mantener mensajes funcionales claros sin filtrar detalles internos innecesarios.

## Opción preferida si quieres dejarlo más limpio

Si la arquitectura backend lo permite, prefiero además un endpoint idempotente para perfil propio:

- PUT /api/clientes/mi-perfil

Comportamiento esperado:

- Usa req.user.id del token.
- Si no existe cliente para ese usuario, lo crea.
- Si ya existe, lo actualiza.
- Devuelve el cliente actualizado.

Si implementas este endpoint, puedes mantener también los endpoints actuales por compatibilidad.

## Definición de terminado

Considero esto completo si me entregas:

1. Controlador o handlers.
2. Servicio o lógica de negocio.
3. Rutas.
4. Validaciones.
5. SQL o migración de tabla clientes.
6. Reglas de autorización.
7. Ejemplos de request y response.
8. Si hubo cambios de compatibilidad, explicar cuáles fueron.

## Prioridad de implementación

Si quieres hacerlo por fases, hazlo en este orden:

1. Relación única clientes.id_usuario.
2. GET /api/clientes/usuario/:idUsuario.
3. POST /api/clientes seguro.
4. PUT /api/clientes/:id seguro.
5. Opcional: PUT /api/clientes/mi-perfil como upsert idempotente.

Implementa sobre la base actual del proyecto, sin inventar otra arquitectura ni cambiar contratos ya usados por el frontend salvo que expliques la compatibilidad.