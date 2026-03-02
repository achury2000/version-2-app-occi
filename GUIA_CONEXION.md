# 🔗 Guía de Conexión Frontend-Backend Occitours

## ✅ Estado Actual de la Conexión

La conexión entre el frontend Flutter y el backend Node.js ha sido configurada exitosamente.

### **Cambios Realizados**

#### 1. **API Service Mejorado** (`lib/services/api_service.dart`)
- Actualizado para usar **DIO** (cliente HTTP más robusto)
- Métodos para GET, POST, PUT, DELETE
- Manejo centralizado de errores
- Interceptadores para logging en desarrollo
- Método `checkConnection()` para verificar conexión con servidor

#### 2. **Constantes Actualizadas** (`lib/utils/constants.dart`)
- URL base configurada para emulador Android: `http://10.0.2.2:3000/api`
- URL alternativa para localhost: `http://localhost:3000/api`

#### 3. **Configuración de Entorno** (`lib/config/environment.dart`)
- Sistema de múltiples entornos (desarrollo, testing, producción)
- Fácil cambio entre servidores
- Métodos de logging en desarrollo

#### 4. **Main.dart Actualizado** (`lib/main.dart`)
- Inicialización correcta de ApiService
- Verificación automática de conexión al servidor
- Provider correctamente configurado

---

## 🚀 Cómo Iniciar el Servidor Backend

### **Opción 1: Desarrollo (Recomendado)**
```powershell
cd c:\Users\USER\Desktop\movil\ Occitours\occitours-backend-mvc
npm install
npm run dev
```
El servidor estará disponible en `http://localhost:3000`

### **Opción 2: Producción**
```powershell
cd c:\Users\USER\Desktop\movil\ Occitours\occitours-backend-mvc
npm install
npm start
```

---

## 📱 Cómo Ejecutar la Aplicación Flutter

### **En Emulador Android**
```powershell
cd c:\Users\USER\Desktop\movil\ Occitours
flutter pub get
flutter run
```

### **En Dispositivo Físico (con WiFi)**
1. Obtén tu IP local: `ipconfig` (busca IPv4)
2. Actualiza la URL en `lib/config/environment.dart`:
   ```dart
   testing: 'http://<tu-ip-local>:3000/api'
   ```

---

## 🔍 Verificación de Conexión

### **Opción 1: Visualizar en Consola Flutter**
La aplicación mostrará automáticamente:
- ✅ `✅ Conectado al backend Occitours`
- ⚠️ Si hay error de conexión

### **Opción 2: Probar Endpoints Manualmente**
```powershell
# GET raíz (info del servidor)
curl http://localhost:3000/

# GET health check
curl http://localhost:3000/api/

# Ver todos los endpoints disponibles
curl http://localhost:3000/
```

---

## 📊 Estructura API Disponible

El backend expone los siguientes endpoints bajo `/api`:

- `/auth` - Autenticación y login
- `/roles` - Gestión de roles
- `/permisos` - Permisos de usuario
- `/usuarios` - Gestión de usuarios
- `/clientes` - Gestión de clientes
- `/empleados` - Gestión de empleados
- `/proveedores` - Proveedores de servicios
- `/servicios` - Catálogo de servicios
- `/reservas` - Sistema de reservas
- `/pagos` - Procesamiento de pagos
- `/dashboard` - Datos para dashboard

---

## 🛠️ Uso en el Código Flutter

### **Ejemplo: Hacer un GET**
```dart
final apiService = ApiService();
try {
  final response = await apiService.get('clientes');
  print('Clientes: $response');
} catch (e) {
  print('Error: $e');
}
```

### **Ejemplo: Hacer un POST**
```dart
try {
  final response = await apiService.post('auth/login', {
    'email': 'usuario@example.com',
    'password': 'contraseña'
  });
  print('Login exitoso: $response');
} catch (e) {
  print('Error de login: $e');
}
```

### **Ejemplo: Cambiar URL en Runtime**
```dart
final apiService = ApiService();
apiService.setBaseUrl('http://tu-nueva-url.com/api');
```

---

## 🔧 Solución de Problemas

### **El App no se conecta al servidor**

1. **Verifica que el servidor esté corriendo:**
   ```powershell
   curl http://localhost:3000/
   ```
   Deberías ver un JSON con info del servidor

2. **En emulador Android, usa `10.0.2.2`** en lugar de `localhost`

3. **Revisa los logs de Flutter:**
   - Busca mensajes ⚠️ o ❌ en la consola
   - Revisa también los logs del servidor backend

4. **Verifica CORS:**
   El backend tiene CORS habilitado para todos los orígenes (en desarrollo)

5. **Puerto incorrecto:**
   Asegúrate de que el puerto es `3000` (configurable en `.env`)

---

## 📝 Variables de Entorno (.env)

El backend usa un archivo `.env` con estas variables:
```
PORT=3000
NODE_ENV=development
DATABASE_URL=postgresql://...
JWT_SECRET=...
JWT_EXPIRES_IN=5m
```

---

## ✨ Próximos Pasos

1. Implementar autenticación JWT
2. Agregar interceptores para tokens
3. Crear modelos Dart para validación
4. Implementar Provider para estado global
5. Agregar caching local con SQLite/Hive

---

## 📞 Contacto

Para más información, consulta:
- Backend: `occitours-backend-mvc/README.md`
- Frontend: Este proyecto Flutter
