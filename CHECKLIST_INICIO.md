# 📋 CHECKLIST DE INICIO - OCCITOURS

## ✅ Verificación Previa

Antes de iniciar la aplicación, verifica que tengas:

- [x] Flutter SDK instalado (`flutter doctor`)
- [x] Dependencias del proyecto instaladas (`flutter pub get`)
- [x] Node.js instalado en la máquina
- [x] Acceso a la base de datos (Supabase)
- [x] Puertos disponibles (3000 para backend, 5037 para emulador)



## 🚀 PASO 1: INICIAR EL BACKEND

### En Windows PowerShell:

```powershell
# 1. Navegar a la carpeta del backend
cd "c:\Users\USER\Desktop\movil Occitours\occitours-backend-mvc"
qetf
# 2. Instalar dependencias (primera vez)
npm install

# 3. Iniciar el servidor en modo desarrollo
npm run dev
```

**Esperado:**
```
✅ Escuchando en puerto 3000
✅ Base de datos conectada
✅ Routes registradas
```

**Verificar que funciona:**
```powershell
# En otra terminal PowerShell
curl http://localhost:3000/
```

Deberías ver un JSON con info del servidor.

---

## 📱 PASO 2: EJECUTAR LA APP FLUTTER

### En otra terminal PowerShell:

```powershell
# 1. Navegar a la carpeta raíz
cd "c:\Users\USER\Desktop\movil Occitours"

# 2. Obtener dependencias (si no lo has hecho)
flutter pub get

# 3. Ejecutar en emulador
flutter run

# Alternativa: Ejecutar en dispositivo físico conectado por USB
flutter run --release
```

**Esperado:**
- App se abre en emulador
- Mensaje en consola: `✅ Conectado al backend Occitours`
- Pantalla de inicio carga correctamente

---

## 🔍 PASO 3: VERIFICAR CONEXIÓN

### Opción A: Revisar logs en consola Flutter

Busca este mensaje después de iniciar la app:
```
✅ Conectado al backend Occitours
```

Si ves esto, está todo bien. Si ves un error:
```
⚠️ No se puede conectar al backend
```

### Opción B: Abrir pantalla de test (Debugging)

1. En tu `lib/screens/home_screen.dart` o donde corresponda, agrega:

```dart
import 'package:occitours/screens/connection_test_screen.dart';

// En tu widget, agrega un botón de debug:
FloatingActionButton(
  onPressed: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const ConnectionTestScreen(),
    ));
  },
  child: const Icon(Icons.bug_report),
),
```

2. Toca el botón y verifica el reporte

### Opción C: Test manual en PowerShell

```powershell
# Verificar que el backend responde
curl http://localhost:3000/

# Obtener lista de clientes
curl http://localhost:3000/api/clientes

# Obtener lista de servicios
curl http://localhost:3000/api/servicios
```

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### ❌ "Connection refused" / "No se puede conectar"

1. **Verifica que el backend esté corriendo:**
   ```powershell
   netstat -ano | findstr :3000
   ```
   Deberías ver un proceso escuchando en puerto 3000

2. **Si no está:**
   - Vuelve a la terminal del backend
   - Ejecuta `npm run dev`
   - Espera a que cargue completamente

3. **En emulador Android:**
   - La app usa `http://10.0.2.2:3000/api` (esto es correcto)
   - NO uses `localhost` en emulador

### ❌ "Port 3000 in use"

```powershell
# Encontrar qué proceso está en puerto 3000
Get-Process | Where-Object {$_.Name -eq 'node'}

# Matar el proceso (ten cuidado)
taskkill /PID <process-id> /F
```

### ❌ "Timeout" / Respuestas lentas

1. Verifica tu conexión a internet
2. Aumenta el timeout en `lib/utils/constants.dart`:
   ```dart
   const Duration apiTimeout = Duration(seconds: 60);
   ```
3. Comprueba si el servidor está procesando muchas requests

### ❌ "CORS error"

- En desarrollo, el CORS está habilitado
- Si ves error CORS en producción, revisar `occitours-backend-mvc/server.js`

### ❌ "Database connection error"

```powershell
# En la terminal del backend, verifica:
# 1. El archivo .env está en: occitours-backend-mvc/.env
# 2. Las credenciales de Supabase son correctas
# 3. La conexión a internet funciona
```

---

## 🎯 PUNTO DE VERIFICACIÓN

Si **TODOS** estos checkpoints funcionan, la conexión está correcta:

```
✅ Backend responde en http://localhost:3000/
✅ Flutter app se abre sin errores
✅ Consola muestra "✅ Conectado al backend Occitours"
✅ Pantalla de test (connection_test_screen) abre sin crasheos
✅ Botones de test rápido pueden hacer requests
✅ curl http://localhost:3000/api/clientes devuelve datos
```

---

## 📊 EJEMPLO COMPLETO DE EJECUCIÓN

### Terminal 1 - Backend
```
C:\Users\USER\Desktop\movil Occitours\occitours-backend-mvc> npm run dev

> occitours-backend-mvc@2.0.0 dev
> nodemon server.js

[nodemon] 3.0.2
[nodemon] to restart at any time, type `rs`
[nodemon] watching path(s): *.*
[nodemon] watching extensions: js,json
[nodemon] starting `node server.js`

🚀 Servidor Occitours escuchando en puerto 3000
✅ Base de datos conectada
📨 CORS habilitado para desarrollo
```

### Terminal 2 - Flutter
```
C:\Users\USER\Desktop\movil Occitours> flutter run

Launching lib\main.dart on emulator-5554 in debug mode...

✅ Conectado al backend Occitours

Running "flutter pub get"...
Building for Android...
Running Gradle build...
Running Gradle assemble...

✨ Built build/app/outputs/flutter-app-release.apk (size).
Installing and launching the android app on the Android Virtual Device...

The Android Virtual Device emulator-5554 is launching...
```

---

## 🔧 CONFIGURACIÓN AVANZADA

### Usar un servidor remoto

1. Edita `lib/config/environment.dart`:
```dart
static const String currentEnvironment = production;

static const Map<String, String> backendUrls = {
  production: 'https://tu-servidor.com/api',
};
```

2. O cambia dinámicamente:
```dart
ApiService().setBaseUrl('https://otro-servidor.com/api');
```

### Testing con velocidad lenta

Usa Chrome DevTools para simular 3G:
```powershell
flutter run -d chrome --profile
```

Luego abre DevTools y simula velocidad de conexión lenta.

---

## 📞 INFORMACIÓN DE CONTACTO Y RECURSOS

- **Backend Docs**: `occitours-backend-mvc/README.md`
- **Guía de Conexión**: `GUIA_CONEXION.md`
- **Resumen**: `RESUMEN_CONEXION.md`
- **Ejemplos**: `lib/services/api_service_examples.dart`

---

## 📝 PRÓXIMAS MEJORAS

Una vez confirmada la conexión, puedes:

1. Seguir los ejemplos en `api_service_examples.dart`
2. Implementar autenticación JWT
3. Crear modelos Dart para validación
4. Implementar gestión de estado con Provider
5. Agregar almacenamiento local
6. Implementar refresh de tokens automático

---

## ✨ ¡LISTO PARA DESARROLLAR!

Una vez completes estos pasos, tu aplicación está lista para:
- ✅ Conectarse al backend
- ✅ Hacer requests HTTP
- ✅ Recibir datos del servidor
- ✅ Manejar errores gracefully
- ✅ Testear endpoints

**¡Adelante con el desarrollo! 🚀**
