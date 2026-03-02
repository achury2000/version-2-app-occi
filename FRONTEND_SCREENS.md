# 🎨 PANTALLAS FRONTEND CREADAS

## ✅ Estado: Completado

Se han creado **7 pantallas principales** con integración total al backend.

---

## 📱 ESTRUCTURA DE PANTALLAS

```
Occitours/
│
├── 🔐 AUTENTICACIÓN
│   ├── Login Screen .................. lib/screens/auth/login_screen.dart
│   ├── Register Screen ............... lib/screens/auth/register_screen.dart
│   └── Forgot Password Screen ........ lib/screens/auth/forgot_password_screen.dart
│
├── 🏠 PRINCIPAL
│   └── Home Screen ................... lib/screens/home/home_screen.dart
│   
├── 📚 CATÁLOGOS
│   ├── Fincas Screen ................. lib/screens/catalogo/fincas_screen.dart
│   └── Rutas Screen .................. lib/screens/catalogo/rutas_screen.dart
│
└── ⚙️ NAVEGACIÓN
    └── go_router config .............. lib/config/router.dart
```

---

## 🔐 1. LOGIN SCREEN

**Archivo:** [lib/screens/auth/login_screen.dart](lib/screens/auth/login_screen.dart)

**Características:**
- ✅ Formulario con validación de email y contraseña
- ✅ Contraseña visible/oculta
- ✅ Enlace a "Olvidaste la contraseña"
- ✅ Enlace a registro
- ✅ Spinner de carga
- ✅ Mensajes de error
- ✅ Diseño con gradiente azul

**Conexión Backend:**
- POST `/api/auth/login` - Autenticación

**Flujo:**
```
Usuario ingresa email + contraseña
         ↓
ApiService.post('auth/login')
         ↓
Backend valida credenciales
         ↓
Retorna { token, usuario }
         ↓
AuthProvider guarda datos
         ↓
Redirección a Home
```

---

## 📝 2. REGISTER SCREEN

**Archivo:** [lib/screens/auth/register_screen.dart](lib/screens/auth/register_screen.dart)

**Características:**
- ✅ Formulario completo (nombre, email, teléfono, país, contraseña)
- ✅ Selector de país (dropdown)
- ✅ Validación de contraseña
- ✅ Confirmación de contraseña
- ✅ Mensajes de error
- ✅ Spinner de carga

**Conexión Backend:**
- POST `/api/auth/register` - Crear nuevo usuario

**Campos:**
- Nombre completo (mínimo 3 caracteres)
- Email (con validación)
- Teléfono
- País (lista predeterminada)
- Contraseña (mínimo 6 caracteres)
- Confirmar contraseña

---

## 🔐 3. FORGOT PASSWORD SCREEN

**Archivo:** [lib/screens/auth/forgot_password_screen.dart](lib/screens/auth/forgot_password_screen.dart)

**Características:**
- ✅ Pantalla para recuperar contraseña
- ✅ Validación de email
- ✅ Pantalla de éxito con confirmación
- ✅ Redirección a login después

**Conexión Backend:**
- POST `/api/auth/forgot-password` - Enviar email de recuperación

**Flujo:**
```
Usuario ingresa email
         ↓
Se envía a backend
         ↓
Backend envía email de recuperación
         ↓
Muestra pantalla de éxito
         ↓
Vuelve a login
```

---

## 🏠 4. HOME SCREEN

**Archivo:** [lib/screens/home/home_screen.dart](lib/screens/home/home_screen.dart)

**Características:**
- ✅ Bottom Navigation Bar con 4 tabs
- ✅ Tab 1: Explorar (fincas y rutas destacadas)
- ✅ Tab 2: Fincas (grid view)
- ✅ Tab 3: Rutas (list view)
- ✅ Tab 4: Perfil de usuario

**Barra de Navegación:**
```
Tab 1: Inicio      🏠
Tab 2: Fincas      📍
Tab 3: Rutas       🥾
Tab 4: Perfil      👤
```

### Tab 1: Explorar
- Saludo personalizado con nombre del usuario
- Buscador
- Fincas destacadas (scroll horizontal)
- Rutas populares (scroll horizontal)
- Enlaces directos a catálogos

### Tab 2: Fincas Grid
- Vista en grilla de fincas
- Muestra precio y rating
- Cargamento desde backend

### Tab 3: Rutas List
- Vista en lista de rutas
- Información: distancia, duración, precio
- Cargamento desde backend

### Tab 4: Perfil
- Avatar del usuario
- Datos personales (nombre, email, teléfono, país)
- Botón de logout

**Conexión Backend:**
- GET `/api/fincas` - Obtener lista de fincas
- GET `/api/rutas` - Obtener lista de rutas

---

## 🏡 5. FINCAS SCREEN

**Archivo:** [lib/screens/catalogo/fincas_screen.dart](lib/screens/catalogo/fincas_screen.dart)

**Características:**
- ✅ Lista completa de fincas en grilla (2 columnas)
- ✅ Buscador en tiempo real
- ✅ Filtro por rango de precio
- ✅ Detalles en modal bottom sheet
- ✅ Botón de reserva

**Funcionalidades:**
- **Búsqueda:** Por nombre y ubicación
- **Filtro de Precio:** Rango personalizado
- **Detalles de Finca:**
  - Nombre, ubicación
  - Descripción
  - Servicios incluidos
  - Capacidad
  - Precio por noche
  - Rating y reseñas
  - Botón reservar

**Control:**
```
Datos ←→ CatalogoProvider ←→ Backend
Búsqueda y filtros en vivo
```

---

## 🥾 6. RUTAS SCREEN

**Archivo:** [lib/screens/catalogo/rutas_screen.dart](lib/screens/catalogo/rutas_screen.dart)

**Características:**
- ✅ Lista de rutas en formato card
- ✅ Buscador en tiempo real
- ✅ Filtro por nivel de dificultad
- ✅ Detalles en draggable bottom sheet
- ✅ Botón de reserva

**Niveles de Dificultad:**
- 🟢 Fácil (verde)
- 🟠 Moderado (naranja)
- 🔴 Difícil (rojo)

**Detalles de Ruta:**
- Nombre, ubicación
- Descripción completa
- Distancia (km)
- Duración (horas)
- Nivel de dificultad
- Capacidad
- Qué incluye
- Rating y reseñas
- Precio
- Botón reservar

---

## 🔀 7. ROUTER CONFIGURATION

**Archivo:** [lib/config/router.dart](lib/config/router.dart)

**Rutas Configuradas:**

```
/login ..................... LoginScreen
/register .................. RegisterScreen
/forgot-password ........... ForgotPasswordScreen
/home ...................... HomeScreen (con bottom nav)
/fincas .................... FincasScreen
/rutas ..................... RutasScreen
```

**Sistema de Redirección:**
- Si NO está logueado → Redirige a `/login`
- Si está logueado → Redirige a `/home`

---

## 📊 MODELOS DE DATOS

### Usuario
```dart
Usuario {
  id: int
  nombre: String
  email: String
  foto: String?
  telefono: String
  pais: String
  createdAt: DateTime
}
```

### Finca
```dart
Finca {
  id: int
  nombre: String
  descripcion: String
  ubicacion: String
  imagen: String?
  latitud: double
  longitud: double
  precioNoche: double
  capacidad: int
  servicios: List<String>
  rating: double
  resenas: int
  disponible: bool
}
```

### Ruta
```dart
Ruta {
  id: int
  nombre: String
  descripcion: String
  ubicacion: String
  imagen: String?
  duracion: double (horas)
  distancia: double (km)
  precio: double
  capacidad: int
  dificultad: String (fácil/moderado/difícil)
  incluye: List<String>
  rating: double
  resenas: int
  disponible: bool
}
```

---

## 🎯 PROVIDERS UTILIZADOS

### AuthProvider
```dart
// Maneja autenticación
- login(email, password)
- register(nombre, email, password, telefono, pais)
- forgotPassword(email)
- logout()

// Propiedades
- usuario: Usuario?
- token: String?
- isLoggedIn: bool
- isLoading: bool
- error: String?
```

### CatalogoProvider
```dart
// Maneja catálogos
- fetchFincas()
- fetchRutas()
- getFincaById(id)
- getRutaById(id)
- searchFincas(query)
- searchRutas(query)
- filterFincasByPrice(min, max)
- filterRutasByDifficulty(difficulty)

// Propiedades
- fincas: List<Finca>
- rutas: List<Ruta>
- isLoadingFincas: bool
- isLoadingRutas: bool
- error: String?
```

---

## 🎨 DISEÑO VISUAL

### Paleta de Colores
- **Primario:** Azul (Colors.blue)
- **Secundario:** Verde (para rutas)
- **Éxito:** Verde (Colors.green)
- **Error:** Rojo (Colors.red)
- **Warning:** Naranja (Colors.orange)

### Componentes Reutilizables
- TextFormField con validación
- Cards para productos
- GridView para galerías
- BottomSheet para detalles
- BottomNavigationBar para navegación

---

## 🔄 FLUJO DE DATOS

```
[Pantalla] 
    ↓
[Widget consume Provider/ApiService]
    ↓
[Provider hace request HTTP]
    ↓
[Backend procesa]
    ↓
[Retorna JSON]
    ↓
[Provider parseea en modelos]
    ↓
[Notifica cambios]
    ↓
[Widget se reconstruye con datos]
```

---

## 📲 CÓMO USAR

### Agregar nuevo endpoint
1. Crear método en `CatalogoProvider` o `AuthProvider`
2. Llamar `_apiService.get()`, `.post()`, etc.
3. Parsear respuesta a modelo
4. Notificar listeners con `notifyListeners()`

### Agregar nueva pantalla
1. Crear archivo en `lib/screens/`
2. Usar Consumer o watch() para providers
3. Agregar ruta en `lib/config/router.dart`
4. Navigación con `context.go('/ruta')`

### Testing
1. Abrir login
2. Usar credenciales de prueba
3. Verificar que sincroniza con backend
4. Navegar entre pantallas

---

## 🚀 PRÓXIMAS MEJORAS

1. **Reservas completo**
   - Formulario de fechas
   - Cálculo de precio total
   - Confirmación de reserva
   - Historial de reservas

2. **Detalles detallados**
   - Galerías de imágenes
   - Maps integridad
   - Reviews/comentarios
   - Chat con anfitrión

3. **Perfil mejorado**
   - Editar datos personales
   - Cambiar contraseña
   - Historial de reservas
   - Mis favoritos

4. **Pagos**
   - Integración de pasarela
   - Múltiples métodos de pago
   - Recibos/facturas

---

## 📝 NOTAS IMPORTANTES

- ✅ Todas las pantallas están conectadas al backend
- ✅ Validación de formularios funcional
- ✅ Loading states implementados
- ✅ Error handling básico
- ✅ Navegación fluida
- ⏳ Imágenes aún son placeholders (implementar después)
- ⏳ Reservas en desarrollo
- ⏳ Pagos en desarrollo

---

## 🎓 ARCHIVO PRINCIPAL

**[lib/main.dart](lib/main.dart)** - Inicialización de la app
- MultiProvider con AuthProvider y CatalogoProvider
- MaterialApp.router con go_router
- Lógica de redirección por autenticación
- Verificación de conexión con backend

---

**¡Interfaz de usuario completamente funcional! 🚀**
