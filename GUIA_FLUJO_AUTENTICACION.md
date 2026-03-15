# 🔐 Guía de Flujo de Autenticación - Occitours

## Problema Actual

**Error al guardar perfil:** `Acceso denegado: No tienes permisos para esta acción`

Este error (HTTP 403 Forbidden) ocurre cuando:
- ✅ El usuario está autenticado (tiene token JWT)
- ❌ PERO no tiene el rol "Cliente" asignado correctamente en el servidor

---

## ✅ Flujo Correcto de Registro y Verificación

### 1️⃣ **REGISTRARSE**
```
┌─────────────────────────────────────────┐
│ Pantalla: Register                       │
│ ✏️ Ingresar email y contraseña          │
│ 📧 Hacer click en "Registrarse"         │
└────────────────┬────────────────────────┘
                 │
                 ▼
🌐 Backend recibe: POST /auth/register
   - email
   - contrasena
   
✅ Backend asigna rol "Cliente" automáticamente
   (esto es importante - debe ocurrir en el servidor)
                 │
                 ▼
┌─────────────────────────────────────────┐
│ Backend envía email de verificación      │
│ Mensaje: "Te enviamos un código a..."    │
└────────────────┬────────────────────────┘
                 │
                 ▼
📧 Usuario recibe email con código
```

### 2️⃣ **VERIFICAR EMAIL**
```
┌─────────────────────────────────────────┐
│ Pantalla: Verify Email                   │
│ 📝 Ingresar código de 6 dígitos          │
│ ✅ Hacer click en "Verificar"            │
└────────────────┬────────────────────────┘
                 │
                 ▼
🌐 Backend recibe: POST /auth/verificar-email
   - email
   - codigo (6 dígitos)
   
✅ Backend marca email como verificado
                 │
                 ▼
✅ Usuario puede ahora hacer LOGIN
   (Código se desecha después)
```

### 3️⃣ **INICIAR SESIÓN (LOGIN)**
```
┌─────────────────────────────────────────┐
│ Pantalla: Login                          │
│ 📧 Ingresar email que registraste        │
│ 🔑 Ingresar contraseña                   │
│ ✅ Hacer click en "Iniciar Sesión"       │
└────────────────┬────────────────────────┘
                 │
                 ▼
🌐 Backend recibe: POST /auth/login
   - correo: email
   - contrasena: contraseña
   
✅ Backend VALIDA:
   ✓ Usuario existe
   ✓ Contraseña es correcta
   ✓ Email está verificado ← IMPORTANTE
   
✅ Backend DEVUELVE:
   - token (JWT)
   - usuario (con rol, email, etc.)
                 │
                 ▼
📱 Frontend almacena TOKEN
   (se añade automáticamente a headers)
                 │
                 ▼
✅ Usuario AUTENTICADO
   Router lo lleva a HOME
```

### 4️⃣ **COMPLETAR PERFIL**
```
┌─────────────────────────────────────────┐
│ Pantalla: Home                           │
│ Ver botón "Completar Perfil" o ir a:     │
│ Menu > Perfil > Completar Perfil         │
└────────────────┬────────────────────────┘
                 │
                 ▼
🔍 Frontend VERIFICA:
   ✓ Usuario tiene token ← SI, obtenido en login
   ✓ Usuario tiene rol "Cliente" ← AQUÍ ES EL PROBLEMA
   
Si rol = null:
   ⚠️ Mostrar: "Tu usuario no tiene rol asignado.
               Intenta cerrar sesión y vuelve a iniciar"
                 │
                 ▼
┌─────────────────────────────────────────┐
│ Pantalla: Completar Perfil               │
│ Formulario con campos:                   │
│  - Tipo de Documento *                   │
│  - Número de Documento *                 │
│  - Teléfono                              │
│  - Dirección *                           │
│  - Ciudad *                              │
│  - País *                                │
│  - Código Postal                         │
│  - Fecha de Nacimiento                   │
│  - Género                                │
│                                          │
│ 💾 Botón "Guardar"                       │
└────────────────┬────────────────────────┘
                 │
                 ▼
🌐 Frontend envía: POST /clientes
   Authorization: Bearer {token}
   Body: {
     idUsuario: 123,
     tipoDocumento: "Cédula",
     numeroDocumento: "1234567890",
     ... resto de campos
   }
   
❌ SI FALLA CON 403:
   Error: "Acceso denegado"
   Razón: Rol usuario NO es "Cliente"
   
✅ SI FUNCIONA:
   Status 200 OK
   Body: { success: true, cliente: {...} }
                 │
                 ▼
✅ PERFIL GUARDADO CORRECTAMENTE
   ✓ Usuario ya puede hacer reservas
   ✓ Perfil marca como "Completo"
```

---

## 🔧 Diagnóstico: ¿Qué Ver en Consola?

### ✅ Logs que ESPERAMOS VER:

```
🔐 [ApiService] Token incluido en header: eyJhbGciOi...
📤 [ClienteService] JSON enviado: {idUsuario: 123, ...}
🌐 [ClienteService] Enviando POST a /clientes...
🔐 [ClienteService] Token verificado: eyJhbGciOi...
📥 [ClienteService] Respuesta: {success: true, cliente: {...}}
✅ [ClienteService] Perfil de cliente creado exitosamente
```

### ❌ Logs que INDICAN PROBLEMA:

```
❌ [ClienteService] NO HAY TOKEN - Usuario no está autenticado!
   → Debes hacer LOGIN primero

🔐 [ApiService] Error 403 - Acceso Denegado
🔐 [ProfileEditScreen] Rol Usuario: null
   → ROL NO ESTÁ ASIGNADO EN SERVIDOR
   → Solución: Revisar backend - no asignó rol en registro

⚠️ [ClienteService] Error en respuesta: Acceso denegado...
   → El servidor rechaza por falta de permisos
```

---

## 📋 Checklist: ¿Qué Revisar?

### Del Usuario (Frontend):
- [ ] ¿Ya hiciste **Registrar**?
- [ ] ¿Verificaste tu **email** con el código?
- [ ] ¿Hiciste **Login** correctamente?
- [ ] ¿Estás viendo la pantalla **Home** (significa autenticado)?
- [ ] ¿Ves el botón **"Completar Perfil"**?

### Del Servidor (Backend):
- [ ] ¿Asigna rol "Cliente" automáticamente en POST `/auth/register`?
- [ ] ¿Verifica que email está verificado en POST `/auth/login`?
- [ ] ¿Retorna token JWT válido en login?
- [ ] ¿Valida middleware que usuario tiene rol "Cliente" en POST `/clientes`?
- [ ] ¿Devuelve error 403 Si falta rol?

---

## 🚀 Soluciones Posibles

### Opción 1: Rol NO fue asignado en registro
**Backend debe hacer:**
```javascript
// En POST /auth/register
// Después de crear usuario:
await db('usuarios').update({
  id_roles: 3  // ID del rol "Cliente"
});
```

### Opción 2: Middleware valida rol demasiado estrictamente
**Backend debe permitir:**
```javascript
// En middleware de /clientes
// Si usuario está autenticado Y el rol NO es null
//  → permitir acceso
// Else si rol es null
//  → error 403 con mensaje claro
```

### Opción 3: Frontend - Mejorar error
**Ya implementado:**
- ✅ Verificar rol en ProfileEditScreen
- ✅ Mostrar warning si rol = null
- ✅ Mejorar mensaje de error 403
- ✅ Logging detallado en consola

---

## 📞 Próximos Pasos

Si aún ves el error 403:

1. **Abre la consola del navegador** (F12)
2. **Busca los logs** con emojis: 🔐 📥 ❌
3. **Copia el log exacto** del error
4. **Verifica en backend** si:
   - Usuario tiene `id_roles = 3` (Cliente)
   - El endpoint valida correctamente

**Mensaje de soporte:**
> "Error 403 al guardar perfil. Usuario: {email}. 
> Logs muestran: {copiar desde consola}"

---

## 📱 Resumen Visual

```
REGISTRO ──► EMAIL VERIFICACIÓN ──► LOGIN ──► HOME ──► COMPLETAR PERFIL
   ✅              ✅                 ✅       ✅              ✅
  POST        POST verificar        POST      Token            POST
  /register   /email               /login     JWT              /clientes
                                             ↓  ↓  ↓
                            Bearer {token} en Authorization
```

**¡Todos los pasos deben funcionar para poder guardar el perfil!**
