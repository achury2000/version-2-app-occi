# Checklist E2E - Recuperación de Contraseña

Objetivo: validar en 10-15 minutos el flujo completo con opción B (código manual) y mensajes correctos.

## Precondiciones
- Backend levantado con SMTP funcionando.
- Frontend Flutter ejecutándose.
- Usuario de prueba con correo real accesible.

## Caso 1 - Solicitud de recuperación (correo enviado)
1. Ir a `Olvidé contraseña`.
2. Ingresar correo válido.
3. Presionar `Enviar Instrucciones`.

Resultado esperado:
- Se muestra pantalla de éxito.
- Llega correo con código de verificación (o token/enlace).

## Caso 2 - Restablecimiento exitoso con código manual (Opción B)
1. Desde pantalla de éxito, pulsar `Ya tengo el código/enlace`.
2. Ingresar correo.
3. Pegar código de verificación.
4. Ingresar nueva contraseña válida y confirmar.
5. Presionar `Restablecer Contraseña`.

Resultado esperado:
- Mensaje: `Contraseña actualizada correctamente`.
- Redirección a login.
- Login exitoso con contraseña nueva.
- Login falla con contraseña anterior.

## Caso 3 - Código/token expirado
1. Reutilizar un código vencido o esperar expiración.
2. Intentar restablecer contraseña.

Resultado esperado:
- Mensaje claro de expiración (enlace/código expirado).
- No se cambia contraseña.

## Caso 4 - Código/token ya usado
1. Usar un código válido para cambiar contraseña una vez.
2. Repetir intento con el mismo código.

Resultado esperado:
- Mensaje claro de código/enlace ya usado.
- No se permite segundo cambio.

## Caso 5 - Código/token inválido
1. Ingresar un código alterado o inventado.
2. Intentar restablecer contraseña.

Resultado esperado:
- Mensaje claro de código/enlace inválido.
- No se cambia contraseña.

## Verificación rápida de cierre
- [ ] Forgot password responde correctamente desde frontend.
- [ ] Correo llega al buzón (o spam) con contenido esperado.
- [ ] Reset exitoso funciona por código manual.
- [ ] Mensajes de error diferencian: expirado / usado / inválido.
- [ ] Usuario puede iniciar sesión con nueva contraseña.
