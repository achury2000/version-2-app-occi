# Contrato Backend - Recuperación de Contraseña

Fecha: 12-03-2026

## 1) Solicitar recuperación

La app ya intenta estos endpoints (en este orden):
- POST /auth/forgot-password
- POST /auth/recuperar-contrasena
- POST /auth/olvide-contrasena

### Request recomendado
```json
{
  "correo": "usuario@correo.com"
}
```

### Response éxito
```json
{
  "success": true,
  "message": "Si el correo existe, enviamos instrucciones de recuperación."
}
```

### Reglas
- No revelar si el correo existe o no (mensaje neutro).
- Generar token/código temporal (expira, por ejemplo 15 min).
- Token/código de un solo uso.
- Enviar correo con enlace seguro HTTPS.
- Aplicar rate limit por IP/correo.

## 2) Restablecer contraseña

La app ya intenta estos endpoints (en este orden):
- POST /auth/reset-password
- POST /auth/restablecer-contrasena
- POST /auth/confirm-reset-password

Y prueba estos formatos de body para compatibilidad:

### Body opción A (preferida)
```json
{
  "correo": "usuario@correo.com",
  "token": "TOKEN_O_CODIGO",
  "nuevaContrasena": "Password@123"
}
```

### Body opción B
```json
{
  "correo": "usuario@correo.com",
  "codigo": "TOKEN_O_CODIGO",
  "nuevaContrasena": "Password@123"
}
```

### Body opción C
```json
{
  "email": "usuario@correo.com",
  "token": "TOKEN_O_CODIGO",
  "password": "Password@123"
}
```

### Response éxito
```json
{
  "success": true,
  "message": "Contraseña actualizada correctamente."
}
```

### Response error ejemplo
```json
{
  "success": false,
  "message": "Token inválido o expirado"
}
```

## 3) Reglas de seguridad mínimas
- Validar complejidad de nueva contraseña en backend.
- Invalidar token inmediatamente al usarse.
- Registrar auditoría (fecha, IP, usuario/correo).
- Notificar por correo que la contraseña fue cambiada.
- Requerir HTTPS siempre.
