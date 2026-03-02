# 🏗️ ARQUITECTURA - OCCITOURS

```
╔════════════════════════════════════════════════════════════════════════════════╗
║                      ARQUITECTURA COMPLETA DEL PROYECTO                        ║
╚════════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────────┐
│                                CLIENTE MÓVIL                                    │
│                          (Flutter - Android/iOS)                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  lib/                                                                           │
│  ├── main.dart                   ✅ Inicialización con ApiService             │
│  ├── config/                                                                   │
│  │   └── environment.dart        ✅ Gestión de entornos                       │
│  │       (dev/test/prod)                                                      │
│  │                                                                             │
│  ├── services/                                                                 │
│  │   ├── api_service.dart        ✅ Cliente HTTP (DIO) - CORE                │
│  │   │   • GET, POST, PUT, DELETE                                           │
│  │   │   • Manejo de errores centralizados                                  │
│  │   │   • Interceptores para logging                                       │
│  │   │   • Método checkConnection()                                         │
│  │   │                                                                       │
│  │   ├── connection_service.dart ✅ Testing de conexión                      │
│  │   │   • Verifica servidor online                                         │
│  │   │   • Testea endpoints                                                 │
│  │   │   • Genera reportes                                                  │
│  │   │                                                                       │
│  │   └── api_service_examples.dart ✅ Ejemplos de uso                        │
│  │       • 10+ ejemplos prácticos                                           │
│  │       • Provider pattern                                                 │
│  │       • Integración en widgets                                           │
│  │                                                                           │
│  ├── screens/                                                                 │
│  │   ├── home_screen.dart                                                   │
│  │   ├── connection_test_screen.dart ✅ Pantalla de debugging                │
│  │   │   • Reporte en tiempo real                                           │
│  │   │   • Test de endpoints                                                │
│  │   │   • Cambio dinámico de URLs                                          │
│  │   └── ... otras pantallas                                                │
│  │                                                                           │
│  ├── models/                                                                  │
│  │   ├── Cliente.dart                                                       │
│  │   ├── Reserva.dart                                                       │
│  │   └── ... modelos (próximos)                                             │
│  │                                                                           │
│  ├── providers/                                                               │
│  │   ├── app_providers.dart                                                 │
│  │   └── ... providers (próximos)                                           │
│  │                                                                           │
│  ├── utils/                                                                   │
│  │   ├── constants.dart          ✅ URLs configuradas                        │
│  │   ├── helpers.dart                                                       │
│  │   └── custom_widgets.dart                                                │
│  │                                                                           │
│  └── widgets/                                                                 │
│      └── custom_widgets.dart                                                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTP/S
                                      │ (DIO - http package)
                                      │
                    ┌─────────────────▼──────────────────┐
                    │     CONEXIÓN ESTABLECIDA ✅        │
                    │                                    │
                    │  URLs Soportadas:                  │
                    │  ├─ Dev: 10.0.2.2:3000/api        │
                    │  ├─ Test: localhost:3000/api      │
                    │  └─ Prod: api.occitours.com/api   │
                    │                                    │
                    │  Métodos: GET, POST, PUT, DELETE  │
                    │  Timeouts: 15-30 segundos         │
                    │  CORS: ✅ Habilitado              │
                    └─────────────────┬──────────────────┘
                                      │
                                      │ Express.js
                                      │ REST API
                                      │
┌─────────────────────────────────────▼──────────────────────────────────────────┐
│                            BACKEND NODE.JS                                      │
│                     (Express MVC - TypeScript opcional)                         │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  occitours-backend-mvc/                                                     │
│                                                                               │
│  server.js                          ✅ Punto de entrada                      │
│  │                                                                           │
│  ├─ Middlewares                                                              │
│  │  ├─ CORS (habilitado)          ✅                                        │
│  │  ├─ Body Parser JSON           ✅                                        │
│  │  ├─ Logger                     ✅                                        │
│  │  └─ Auth Middleware            ✅                                        │
│  │                                                                           │
│  ├─ Routes (Registro central en routes/index.js)                             │
│  │  ├─ /api/auth               ✅ Autenticación                             │
│  │  ├─ /api/clientes           ✅ CRUD clientes                             │
│  │  ├─ /api/proveedores        ✅ CRUD proveedores                          │
│  │  ├─ /api/servicios          ✅ CRUD servicios                            │
│  │  ├─ /api/reservas           ✅ Sistema de reservas                       │
│  │  ├─ /api/pagos              ✅ Procesamiento de pagos                    │
│  │  ├─ /api/dashboard          ✅ Datos para dashboard                      │
│  │  ├─ /api/fincas             ✅ CRUD fincas                               │
│  │  ├─ /api/empleados          ✅ CRUD empleados                            │
│  │  ├─ /api/programaciones     ✅ Calendarios                               │
│  │  └─ /api/roles              ✅ RBAC                                      │
│  │                                                                           │
│  ├─ Controllers (Lógica de negocio)                                          │
│  │  ├─ authController.js          Module pattern                             │
│  │  ├─ clienteController.js       Query + Update + Delete                   │
│  │  ├─ reservaController.js       Orquestación de datos                     │
│  │  ├─ pagoController.js          Integración QR                             │
│  │  └─ ... más controllers                                                  │
│  │                                                                           │
│  ├─ Models (Sequelize ORM)                                                   │
│  │  ├─ Cliente.js                 Schema + relations                        │
│  │  ├─ Reserva.js                 Has-many relationships                    │
│  │  ├─ Usuario.js                 Auth relations                           │
│  │  └─ ... más modelos                                                      │
│  │                                                                           │
│  ├─ Database                                                                 │
│  │  ├─ schema_completo.sql       ✅ SQL completo                            │
│  │  └─ config/db.js              ✅ Sequelize setup                         │
│  │                                                                           │
│  └─ .env                           ✅ Configuración                         │
│     ├─ DATABASE_URL=postgresql... (Supabase)                               │
│     ├─ PORT=3000                                                            │
│     ├─ NODE_ENV=development                                                │
│     └─ JWT_SECRET=...                                                      │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ SQL (PostgreSQL)
                                      │
┌─────────────────────────────────────▼──────────────────────────────────────────┐
│                          BASE DE DATOS                                         │
│               (PostgreSQL en Supabase - En la nube)                           │
├───────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│  Tablas:                                                                      │
│  ├─ usuarios            Autenticación + RBAC                                │
│  ├─ roles               Gestión de permisos                                 │
│  ├─ clientes            Datos de clientes                                   │
│  ├─ proveedores         Partners y vendors                                  │
│  ├─ servicios           Catálogo de actividades                             │
│  ├─ reservas            Bookings principales                                │
│  ├─ pagos               Transacciones                                       │
│  ├─ fincas              Propiedades turísticas                              │
│  ├─ programaciones      Calendarios y horarios                              │
│  └─ ... más tablas                                                          │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 FLUJO DE CONEXIÓN

```
[Flutter App]
     │
     │ 1. Inicializa ApiService
     │
     ▼
[ApiService.checkConnection()]
     │
     │ 2. Verifica servidor online
     │
     ▼
[HTTP GET: http://10.0.2.2:3000/] (Emulador)
     │
     │ 3. Envía request HTTP
     │
     ▼
[Backend Express] 
     │
     │ 4. Procesa en middleware
     │
     ▼
[CORS Middleware]
     ├─ Verifica origen ✅
     └─ Añade headers CORS
     │
     ▼
[Routes]
     ├─ Identifica endpoint
     ├─ Ejecuta controlador
     └─ Consulta base de datos
     │
     ▼
[Database] (Supabase PostgreSQL)
     │
     │ 5. Ejecuta queries
     │
     ▼
[Respuesta JSON]
     │
     │ 6. Retorna datos
     │
     ▼
[ApiService._handleResponse()]
     │
     │ 7. Parsea respuesta
     │
     ▼
[Flutter App]
     └─ 8. Actualiza UI
```

---

## 📦 DEPENDENCIAS INSTALADAS

### Backend (Node.js)
```json
{
  "express": "^4.18.2",
  "sequelize": "^6.37.7",
  "pg": "^8.11.3",
  "cors": "^2.8.5",
  "jsonwebtoken": "^9.0.2",
  "bcryptjs": "^2.4.3",
  "dotenv": "^16.3.1"
}
```

### Frontend (Flutter)
```yaml
dependencies:
  http: ^1.1.0
  dio: ^5.3.0
  provider: ^6.0.0
  flutter_svg: ^2.0.5
  ... (más dependencias en pubspec.yaml)
```

---

## 🔄 CICLO DE VIDA DE UNA REQUEST

```
Usuario toca botón en Flutter
         │
         ▼
[ApiService.get(endpoint)]
         │
         ├─ Construye URL completa
         ├─ Añade headers (Content-Type, etc)
         ├─ Configura timeouts
         └─ Ejecuta request con DIO
         │
         ▼
[HTTP Transport]
         │
         ├─ Envía en emulador Android:
         │  http://10.0.2.2:3000/api/...
         │
         └─ Espera máximo 15 segundos
         │
         ▼
[Backend recibe request]
         │
         ├─ Logger middleware: Registra
         ├─ CORS middleware: Valida origen
         ├─ Body parser: Parsea JSON
         └─ Auth middleware: Valida token (si aplica)
         │
         ▼
[Router]
         │
         ├─ Identifica ruta coincidente
         └─ Llama controlador
         │
         ▼
[Controlador (Model + Query)]
         │
         ├─ Valida datos entrantes
         ├─ Ejecuta lógica de negocio
         ├─ Consulta base de datos
         └─ Prepara respuesta JSON
         │
         ▼
[Response HTTP 200/201/4xx/5xx]
         │
         ├─ Body: JSON con datos
         ├─ Headers: CORS, Content-Type
         └─ Status code: Indica resultado
         │
         ▼
[Flutter recibe response]
         │
         ├─ ApiService.get() parseaJSON
         ├─ Retorna datos al llamador
         └─ Maneja errores si aplica
         │
         ▼
[Widget refresca con datos]
         │
         └─ Usuario ve resultado
```

---

## 🎯 ENDPOINTS PRINCIPALES DISPONIBLES

| Endpoint | Método | Descripción | Status |
|----------|--------|-------------|--------|
| `/api/auth/login` | POST | Autenticación usuario | ✅ |
| `/api/clientes` | GET | Obtener clientes | ✅ |
| `/api/clientes` | POST | Crear cliente | ✅ |
| `/api/servicios` | GET | Listar servicios | ✅ |
| `/api/reservas` | GET | Ver reservas | ✅ |
| `/api/reservas` | POST | Crear reserva | ✅ |
| `/api/pagos` | POST | Procesar pago | ✅ |
| `/api/dashboard` | GET | Datos dashboard | ✅ |
| `/api/proveedores` | GET | Listar proveedores | ✅ |
| `/api/fincas` | GET | Listar propiedades | ✅ |

---

## 📊 FLUJO DE AUTENTICACIÓN (Próximo)

```
[App abierta]
     │
     ├─ ¿Usuario logueado?
     │  ├─ NO  → Pantalla login
     │  └─ SÍ  → Pantalla principal
     │
[Usuario ingrese credenciales]
     │
[POST /api/auth/login {email, password}]
     │
[Backend valida]
     ├─ Busca usuario en DB
     ├─ Compara contraseña con bcrypt
     └─ Genera JWT token
     │
[Response {token, user}]
     │
[ApiService guarda token]
     ├─ SharedPreferences (local)
     └─ Agrega a headers en siguiente request
        Authorization: Bearer {token}
     │
[Usuario logueado ✅]
```

---

## 🏆 ESTADO DE LA CONEXIÓN

| Componente | Versión | Estado | Documentación |
|-----------|---------|--------|----------------|
| Flutter | ≥3.0.0 | ✅ Listo | pubspec.yaml |
| Backend | Express 4.18 | ✅ Listo | server.js |
| BD | PostgreSQL | ✅ Supabase | .env |
| API Service | v1.0 | ✅ Funcional | api_service.dart |
| Conexión | HTTP/S | ✅ Establecida | GUIA_CONEXION.md |

---

**¡La arquitectura está lista para desarrollo! 🚀**
