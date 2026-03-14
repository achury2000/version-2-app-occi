# 🎯 Plan de Acción: Resolver Error 403 "Acceso Denegado"

## 🔴 El Problema
Cuando intentas guardar tu perfil, ves:
```
Error: Acceso denegado: No tienes permisos para esta acción. 
Verifica que hayas iniciado sesión correctamente
```

---

## ✅ Mejoras que Ya Hicimos

### 1. **Diagnóstico Automático** ✓
- Al entrar a "Completar Perfil", ahora se muestra:
  - Tu email
  - Tu ID de usuario
  - **Tu rol asignado** ← ESTO ES CLAVE
  
Si ves `Rol: null` → **ESE ES EL PROBLEMA**

### 2. **Logging Detallado** ✓
Antes de intentar guardar, se registra en consola:
```
🔐 [ProfileEditScreen] DIAGNÓSTICO ANTES DE GUARDAR:
  - ID Usuario: 123
  - Rol Usuario: Cliente  ← Si esto dice null, el backend no asignó rol
  - Cliente existente ID: null
  - Perfil completo: false
  - Modo: CREATE
```

### 3. **Validación de Token** ✓
Se verifica automáticamente:
- ¿Tienes token JWT? (obtenido en Login)
- ¿Está incluido en header `Authorization`?

---

## 🔧 Pasos para Resolver

### **PASO 1: Verificar Rol en Consola** 
1. Abre la app en el navegador
2. Presiona **F12** para abrir DevTools
3. Pestaña **Console**
4. Navega a "Completar Perfil"
5. **Busca** la línea que dice:
   ```
   DIAGNÓSTICO ANTES DE GUARDAR:
     - Rol Usuario: ?
   ```

**Si dice `Rol Usuario: null`** → PROBLEMA CONFIRMADO

---

### **PASO 2A: Si Rol = null** ⚠️

**Solución rápida (Frontend):**
1. Haz **Logout**
2. Haz **Login** nuevamente
3. Inicia de nuevo el proceso

**Si persiste:**
- La culpa es del **BACKEND** - no está asignando rol en registro
- El backend debe:
  - En `POST /auth/register`: Asignar `id_roles = 3` (Cliente)
  - Verificar tabla `usuarios.id_roles` tiene valor correcto

---

### **PASO 2B: Si Rol = "Cliente"** ✓

**Significa token y rol están bien, pero el servidor sigue rechazando**

Mira el error exacto en consola:
```
❌ Error en respuesta: {mensaje exacto del backend}
```

**Copia ese mensaje** y revisa en el backend si:
1. ¿El endpoint `/clientes` tiene un middleware de autorización?
2. ¿Está validando correctamente que `rol === "Cliente"`?
3. ¿Está permitiendo usuarios autenticados?

---

## 📊 Tabla de Diagnóstico

| Síntoma | Causa | Solución |
|---------|-------|----------|
| Error 403 + Rol = null | Backend no asignó rol en registro | Backend: Agregar asignación de rol en `/auth/register` |
| Error 403 + Rol = "Cliente" | Middleware rechaza por otra razón | Backend: Revisar validaciones en `POST /clientes` |
| "No estás autenticado" | No hiciste login | Frontend: Hacer Login primero |
| "Token expirado" | Error 401 | Frontend: Logout + Login nuevamente |

---

## 🎬 Captura de Pantalla Esperada

**En modo DEBUG, deberías ver en consola:**

```
✅ [ProfileEditScreen] Iniciando...
🔐 [ProfileEditScreen] Usuario: juan@example.com
🔐 [ProfileEditScreen] ID Usuario: 123
🔐 [ProfileEditScreen] Rol: Cliente ← ✅ BIEN

🔍 [ProfileEditScreen] DIAGNÓSTICO ANTES DE GUARDAR:
  - ID Usuario: 123
  - Rol Usuario: Cliente ← ✅ BIEN
  - Cliente existente ID: null
  - Perfil completo: false
  - Modo: CREATE

📬 [ClienteService] Enviando POST a /clientes...
🔐 [ClienteService] Token verificado: eyJhbGciOi... ← ✅ BIEN
📤 [ClienteService] JSON enviado: {
  "id_usuario": 123,
  "tipo_documento": "Cédula",
  ...
}

📥 [ClienteService] Respuesta: {success: true, cliente: {...}}
✅ [ClienteService] Perfil de cliente creado exitosamente
```

---

## ❌ Si Aún Ves Error

**Copia esta información:**
1. Tu **email**
2. Tu **ID usuario** (de los logs)
3. El **rol exacto** que ves en consola
4. El **código de estado** (403, 401, etc.)
5. El **mensaje de error exacto** del servidor

**Y envía al equipo backend** para que revisen porqué rechaza la solicitud.

---

## 🚀 Pruebas Recomendadas

### Test 1: Verificar Rol
```javascript
// En consola del navegador
console.log("%c Verifica tu rol:", "color: blue; font-size: 14px");
// Busca en logs: "Rol Usuario: ?"
```

### Test 2: Intentar Guardar
1. Completa todos los campos requeridos (*)
2. Haz click en "Guardar"
3. **NO cierres** la página - espera 5 segundos
4. Lee todos los logs en consola
5. **Toma screenshot** del error exacto

### Test 3: Verificar Token
```javascript
// En localStorage del navegador:
// Abre DevTools > Application > Local Storage
// Busca: "occitours_token" o "token"
// Si está vacío = no hay token guardado
```

---

## 🔑 Conclusión

**El error 403 ocurre porque:**
- ✅ Estás autenticado (tienes token)
- ✅ El servidor recibe tu request
- ❌ PERO no tienes el rol "Cliente" asignado

**La solución es del BACKEND:**
- Debe asignar `rol = "Cliente"` cuando se registra
- O debe dejar que usuarios sin rol completen perfil
- O debe devolver error más claro indicando qué falta

**Mientras tanto, desde FRONTEND:**
- ✅ Agregamos diagnóstico automático
- ✅ Mejorado logging para identificar el problema
- ✅ Mensajes más claros en UI

---

## 📝 Próximos Pasos

1. **Prueba los pasos anteriores**
2. **Abre consola (F12)** e intenta guardar
3. **Copia los logs exactos** que ves
4. **Comunícate con el equipo backend** con esa información
5. **Ellos ajustarán** el servidor para permitir el acceso

¡Gracias por tu paciencia! 🙏
