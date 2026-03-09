# Sistema de Verificación de Correo Electrónico

## 📋 Resumen

Se ha implementado un sistema completo de verificación de correo electrónico para la app Occitours. Cuando un usuario se registra, **el backend** genera y envía automáticamente un código de 6 dígitos al correo del usuario. La app móvil proporciona las interfaces para que el usuario ingrese y verifique este código.

---

## 🔄 Flujo Completo

### 1. **Registro del Usuario**
- El usuario completa el formulario de registro en [`register_screen.dart`](lib/screens/auth/register_screen.dart)
- La app envía los datos al endpoint: `POST /api/auth/register`
- **El backend:**
  - Crea el usuario en la BD
  - Genera un código de verificación de 6 dígitos
  - **Envía el email con el código automáticamente**
  - Guarda el código en la BD con tiempo de expiración
- La app navega automáticamente a la pantalla de verificación

### 2. **Verificación del Email**
- El usuario ve la pantalla [`verify_email_screen.dart`](lib/screens/auth/verify_email_screen.dart)
- Ingresa el código de 6 dígitos recibido en su correo
- La app envía el código al endpoint: `POST /api/auth/verify-email`
- **El backend:**
  - Valida el código
  - Marca el usuario como verificado
  - Retorna confirmación
- La app navega al login tras verificación exitosa

### 3. **Reenvío de Código**
- Si el usuario no recibió el código, puede solicitar un reenvío
- Hay un timer de 60 segundos entre reenvíos
- Endpoint: `POST /api/auth/resend-verification-code`
- **El backend:**
  - Genera un nuevo código
  - **Envía el email nuevamente**

### 4. **Login con Verificación**
- Si un usuario intenta hacer login sin verificar su email
- **El backend rechaza el login** con un mensaje de error
- La app detecta este error y ofrece ir a la pantalla de verificación

---

## 📁 Archivos Creados/Modificados

### ✨ Nuevos Archivos

1. **`lib/screens/auth/verify_email_screen.dart`**
   - Pantalla para ingresar el código de verificación
   - Timer para reenvío del código (60 segundos)
   - Muestra el email enmascarado por seguridad
   - Botones: Verificar, Reenviar código, Volver al login

### 🔧 Archivos Modificados

2. **`lib/services/auth_service.dart`**
   - Agregado: `verifyEmail()` - Verifica el código con el backend
   - Agregado: `resendVerificationCode()` - Solicita reenvío de código

3. **`lib/providers/auth_provider.dart`**
   - Agregado: `verifyEmail()` - Lógica de verificación
   - Agregado: `resendVerificationCode()` - Lógica de reenvío
   - Modificado: `register()` - Ya NO inicia sesión automáticamente
   - Mejorado: `_parseError()` - Maneja errores de verificación

4. **`lib/screens/auth/register_screen.dart`**
   - Integrado con AuthProvider
   - Navega a verificación tras registro exitoso
   - Muestra loading indicator durante el proceso

5. **`lib/screens/auth/login_screen.dart`**
   - Integrado con AuthProvider
   - Detecta error de email no verificado
   - Ofrece navegar a verificación si el email no está verificado
   - Muestra loading indicator durante el proceso

6. **`lib/config/router.dart`**
   - Agregada ruta: `/verify-email?email={email}`
   - Pasa el email como query parameter

---

## 🔐 Seguridad

### En el Backend (ya implementado por ti):
- ✅ El código se genera en el servidor (nunca en el cliente)
- ✅ El código tiene expiración (típicamente 15-30 minutos)
- ✅ El código se guarda hasheado en la BD
- ✅ El envío de email se hace desde el servidor con credenciales seguras
- ✅ Se valida que el código corresponda al usuario correcto
- ✅ No se permite login si el email no está verificado

### En la App Móvil:
- ✅ El email se enmascara en la UI (ej: `jo***n@gmail.com`)
- ✅ Solo se envía el código ingresado por el usuario
- ✅ Timer de 60s entre reenvíos para evitar spam
- ✅ Validación de formato (6 dígitos)
- ✅ Manejo seguro de errores sin exponer detalles del sistema

---

## 🎯 Endpoints del Backend Utilizados

```
POST /api/auth/register
  - Body: { correo, contrasena, nombre, apellido, ... }
  - Retorna: { success, message }
  - BACKEND ENVÍA EMAIL AUTOMÁTICAMENTE

POST /api/auth/verify-email
  - Body: { correo, codigo }
  - Retorna: { success, message }

POST /api/auth/resend-verification-code
  - Body: { correo }
  - Retorna: { success, message }
  - BACKEND ENVÍA EMAIL AUTOMÁTICAMENTE

POST /api/auth/login
  - Body: { correo, contrasena }
  - Retorna: { success, token, usuario } o error si no está verificado
```

---

## 📱 Capturas de Flujo

### Flujo Típico:
```
1. Usuario → Pantalla de Registro
   ↓
2. Completa formulario y tap "Crear Cuenta"
   ↓
3. Backend crea usuario y ENVÍA EMAIL con código
   ↓
4. App navega a → Pantalla de Verificación
   ↓
5. Usuario abre su email y copia el código
   ↓
6. Usuario ingresa código en la app
   ↓
7. App valida con backend
   ↓
8. Email verificado ✅
   ↓
9. App navega a → Pantalla de Login
   ↓
10. Usuario puede iniciar sesión normalmente
```

---

## ⚙️ Configuración Requerida en el Backend

Asegúrate de que tu backend tenga configurado:

1. **Servicio de Email (SMTP)**
   - Host, puerto, usuario, contraseña
   - Típicamente usando NodeMailer, SendGrid, AWS SES, etc.

2. **Generación de Códigos**
   - Aleatorio de 6 dígitos
   - Almacenamiento en BD con timestamp
   - Expiración de 15-30 minutos

3. **Validación en Login**
   - Verificar que `usuario.email_verificado === true`
   - Rechazar login si no está verificado

---

## 🧪 Pruebas Recomendadas

1. **Registro Normal**
   - Registrar un usuario nuevo
   - Verificar que llega el email
   - Ingresar el código correcto
   - Verificar que se puede hacer login

2. **Código Incorrecto**
   - Ingresar un código inválido
   - Verificar mensaje de error apropiado

3. **Código Expirado**
   - Esperar a que expire el código
   - Verificar mensaje de error
   - Reenviar código nuevo

4. **Reenvío de Código**
   - Solicitar reenvío
   - Verificar timer de 60s
   - Verificar que llega nuevo email

5. **Login Sin Verificar**
   - Intentar login sin verificar email
   - Verificar que se muestra diálogo
   - Navegar a verificación desde el diálogo

---

## 🚀 Próximos Pasos Opcionales

1. **Mejorar UX:**
   - Auto-detectar código desde SMS/Email (solo en dispositivos compatibles)
   - Animaciones de transición entre pantallas
   - Campo de código con separadores visuales

2. **Seguridad Adicional:**
   - Límite de intentos fallidos (ej: 5 intentos)
   - Bloqueo temporal tras múltiples fallos
   - Logs de intentos de verificación

3. **Notificaciones:**
   - Push notification de bienvenida tras verificación
   - Email de bienvenida tras verificación

---

## ❓ Resolución de Problemas

### "No recibo el email"
- Verificar configuración SMTP en el backend
- Revisar carpeta de spam
- Verificar que el email es válido

### "Código inválido"
- Verificar que no haya espacios al copiar
- Verificar que no haya expirado (tiempo límite)
- Solicitar reenvío de código

### "Error de conexión"
- Verificar que el backend esté corriendo
- Verificar la URL del API en environment.dart
- Verificar conexión a internet

---

## 📞 Respuesta a tu Pregunta

> "¿Esto se hace desde el back o desde el aplicativo móvil?"

**RESPUESTA:**

El **ENVÍO DEL EMAIL SE HACE DESDE EL BACKEND** por razones de seguridad:

### ❌ NO se hace desde la app móvil porque:
- La app necesitaría credenciales de email (riesgo enorme de seguridad)
- Cualquiera podría descompilar la app y robar las credenciales
- No se puede confiar en el cliente para generar códigos seguros

### ✅ SÍ se hace desde el backend porque:
- Las credenciales de email están seguras en el servidor
- El código se genera de forma segura y aleatoria
- Se puede controlar rate limiting y prevenir abuso
- Se puede auditar y loggear todos los envíos

### 🔁 División de Responsabilidades:

**BACKEND (tu servidor):**
- ✉️ Enviar emails
- 🔐 Generar códigos de verificación
- 💾 Almacenar códigos en BD
- ✅ Validar códigos
- ⏱️ Manejar expiración

**APP MÓVIL (Flutter):**
- 📱 Mostrar interfaces (formularios, pantallas)
- 📤 Enviar datos del usuario al backend
- 📥 Recibir y mostrar errores/confirmaciones
- 🧭 Navegar entre pantallas
- ⏲️ Mostrar timer de reenvío

---

✅ **Implementación Completa**
La app móvil ahora está lista para trabajar con tu backend de verificación de email.
