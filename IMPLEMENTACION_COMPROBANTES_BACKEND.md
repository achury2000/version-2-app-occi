# Implementación: Guardar Comprobantes por Cliente en Supabase Storage

## Resumen
La app móvil envía comprobantes de pago con metadatos para guardarlos en:
```
comprobantes/<id_cliente>/<nombre_archivo>
```

## Contrato que envía la app

### Endpoint
```
POST /api/pagos/:idPago/comprobante
```

### Query Parameters
```
?bucket=comprobantes&id_cliente=2&carpeta=2
```

### Form Data (multipart)
```
archivo: <archivo binario>
bucket: comprobantes
bucket_name: comprobantes
id_cliente: 2
id_reserva: 13
folder: 2
carpeta: 2
path_prefix: 2
```

---

## Solución: Controllers/pagosController.js

```javascript
const Pago = require('../models/Pago');
const supabase = require('../config/supabase'); // Tu cliente Supabase configurado

/**
 * POST /api/pagos/:idPago/comprobante
 * Subir comprobante de pago a Supabase Storage
 * Ruta: comprobantes/<id_cliente>/<nombre_archivo>
 */
exports.subirComprobantePago = async (req, res) => {
  try {
    const { idPago } = req.params;
    const { id_cliente, id_reserva, bucket = 'comprobantes', carpeta } = req.query;
    
    // Validar que existe archivo
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No se adjuntó archivo',
        message: 'Debes seleccionar un comprobante para subir',
      });
    }

    // Validar id_cliente
    const idCliente = parseInt(id_cliente, 10);
    if (!idCliente || idCliente <= 0) {
      return res.status(400).json({
        success: false,
        error: 'id_cliente inválido',
        message: 'No se puede determinar el cliente',
      });
    }

    // Obtener el pago para validar
    const pago = await Pago.obtenerPorId(idPago);
    if (!pago) {
      return res.status(404).json({
        success: false,
        error: 'Pago no encontrado',
        message: `El pago #${idPago} no existe`,
      });
    }

    // Verificar que el archivo no sea muy grande (máx 5MB)
    const MAX_SIZE = 5 * 1024 * 1024; // 5MB
    if (req.file.size > MAX_SIZE) {
      return res.status(413).json({
        success: false,
        error: 'Archivo muy grande',
        message: 'El máximo es 5MB',
      });
    }

    // Validar tipo MIME
    const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];
    if (!ALLOWED_TYPES.includes(req.file.mimetype)) {
      return res.status(415).json({
        success: false,
        error: 'Tipo de archivo no permitido',
        message: 'Solo se aceptan JPG, PNG o PDF',
      });
    }

    // Construir ruta en Storage
    const carpetaGrabacion = carpeta || idCliente;
    const storagePath = `comprobantes/${carpetaGrabacion}/${req.file.filename}`;

    console.log(`📤 [ComprobantePago] Subiendo a: ${storagePath}`);

    // Subir a Supabase Storage
    const { data: uploadData, error: uploadError } =
      await supabase.storage
        .from(bucket)
        .upload(storagePath, req.file.buffer, {
          contentType: req.file.mimetype,
          upsert: false,
        });

    if (uploadError) {
      console.error('❌ Error al subir a Storage:', uploadError);
      return res.status(500).json({
        success: false,
        error: 'Error al subir archivo',
        message: uploadError.message,
        details: uploadError,
      });
    }

    // Generar URL pública
    const { data: publicUrlData } = supabase.storage
      .from(bucket)
      .getPublicUrl(storagePath);

    const urlComprobante = publicUrlData?.publicUrl;

    if (!urlComprobante) {
      return res.status(500).json({
        success: false,
        error: 'No se pudo generar URL del comprobante',
        message: 'Intenta nuevamente',
      });
    }

    // Actualizar registro en BD
    // Opción 1: Si tienes una tabla de pagos
    if (Pago.actualizarComprobante) {
      await Pago.actualizarComprobante(idPago, {
        comprobante_url: urlComprobante,
        nombre_archivo: req.file.filename,
        archivo_path: storagePath,
        fecha_subida: new Date(),
        estado: 'completado', // o 'verificado pendiente'
      });
    }

    // Opción 2: Si guardas comprobantes en tabla de reservas
    if (id_reserva) {
      const Reserva = require('../models/Reserva');
      if (Reserva.actualizarComprobante) {
        await Reserva.actualizarComprobante(id_reserva, {
          comprobante_pago: urlComprobante,
          comprobante_url: urlComprobante,
        });
      }
    }

    console.log(`✅ Comprobante guardado: ${urlComprobante}`);

    return res.status(200).json({
      success: true,
      message: 'Comprobante subido exitosamente',
      data: {
        id_pago: idPago,
        url: urlComprobante,
        path: storagePath,
        archivo: req.file.filename,
        bucket,
        carpeta: carpetaGrabacion,
      },
    });
  } catch (error) {
    console.error('❌ Error en subirComprobantePago:', error);
    return res.status(500).json({
      success: false,
      error: 'Error interno del servidor',
      message: error.message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
};
```

---

## Modelo: models/Pago.js (si no existe)

```javascript
const db = require('../config/database');

class Pago {
  static async obtenerPorId(idPago) {
    const query = `
      SELECT p.* FROM pagos p
      WHERE p.id = $1
    `;
    const result = await db.query(query, [idPago]);
    return result.rows[0] || null;
  }

  static async actualizarComprobante(idPago, datos) {
    const {
      comprobante_url,
      nombre_archivo,
      archivo_path,
      fecha_subida,
      estado,
    } = datos;

    const query = `
      UPDATE pagos
      SET
        comprobante_url = COALESCE($2, comprobante_url),
        nombre_archivo = COALESCE($3, nombre_archivo),
        archivo_path = COALESCE($4, archivo_path),
        fecha_subida = COALESCE($5, fecha_subida),
        estado = COALESCE($6, estado),
        updated_at = NOW()
      WHERE id = $1
      RETURNING *;
    `;

    const result = await db.query(query, [
      idPago,
      comprobante_url,
      nombre_archivo,
      archivo_path,
      fecha_subida,
      estado,
    ]);

    return result.rows[0] || null;
  }
}

module.exports = Pago;
```

---

## Configuración: routes/pagosRoutes.js

```javascript
const express = require('express');
const router = express.Router();
const pagosController = require('../controllers/pagosController');
const { autenticar } = require('../middlewares/auth');
const multer = require('multer');

// Middleware multer para recibir el archivo
const upload = multer({
  storage: multer.memoryStorage(), // Guardar en memoria para Supabase
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});

/**
 * POST /api/pagos/:idPago/comprobante
 * Subir comprobante de pago
 */
router.post(
  '/:idPago/comprobante',
  autenticar, // Validar JWT
  upload.single('archivo'), // Campo 'archivo' en form-data
  pagosController.subirComprobantePago,
);

module.exports = router;
```

---

## SQL: Tabla de pagos (si no existe)

```sql
CREATE TABLE pagos (
  id SERIAL PRIMARY KEY,
  id_reserva INT NOT NULL REFERENCES reservas(id) ON DELETE CASCADE,
  id_cliente INT NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  monto DECIMAL(10, 2) NOT NULL,
  metodo_pago VARCHAR(50),
  
  -- Comprobante de pago
  comprobante_url TEXT,
  nombre_archivo VARCHAR(255),
  archivo_path VARCHAR(500),
  fecha_subida TIMESTAMP,
  
  estado VARCHAR(30) DEFAULT 'pendiente', -- pendiente, completado, verificado
  referencia VARCHAR(255),
  
  notas TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_pagos_reserva ON pagos(id_reserva);
CREATE INDEX idx_pagos_cliente ON pagos(id_cliente);

-- Si quieres guardar comprobante directo en reservas:
ALTER TABLE reservas ADD COLUMN comprobante_pago TEXT;
ALTER TABLE reservas ADD COLUMN comprobante_url TEXT;
```

---

## Configuración Supabase: config/supabase.js

```javascript
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL y SUPABASE_KEY son requeridos');
}

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
```

---

## .env

```env
SUPABASE_URL=https://qswlclvgbmkfouhzapja.supabase.co
SUPABASE_KEY=tu_supabase_api_key
```

---

## Paso a paso para integrar

1. **Copia el controlador** `subirComprobantePago` a tu `controllers/pagosController.js`
   - Adapta la ruta de `require` del modelo Pago según tu estructura
   - Valida que `supabase` esté bien importado

2. **Crea/actualiza la ruta** en `routes/pagosRoutes.js`
   - Agrega el middleware multer
   - Registra el endpoint POST

3. **Crea el modelo Pago** si no existe
   - Implementa `obtenerPorId` y `actualizarComprobante`

4. **Crea/actualiza tabla en BD** con el SQL propuesto

5. **Asegúrate de cargar en app.js**
```javascript
const pagosRoutes = require('./routes/pagosRoutes');
app.use('/api/pagos', pagosRoutes);
```

---

## Testing

### Con curl
```bash
curl -X POST http://localhost:3000/api/pagos/1/comprobante \
  -H "Authorization: Bearer tu_token_jwt" \
  -F "archivo=@comprobante.pdf" \
  -F "id_cliente=2" \
  -F "id_reserva=13" \
  "http://localhost:3000/api/pagos/1/comprobante?bucket=comprobantes&id_cliente=2"
```

### Esperado
```json
{
  "success": true,
  "message": "Comprobante subido exitosamente",
  "data": {
    "id_pago": 1,
    "url": "https://qswlclvgbmkfouhzapja.supabase.co/storage/v1/object/public/comprobantes/2/pago_1_1713612345678.pdf",
    "path": "comprobantes/2/pago_1_1713612345678.pdf",
    "archivo": "pago_1_1713612345678.pdf",
    "bucket": "comprobantes",
    "carpeta": "2"
  }
}
```

---

## Validaciones que hace

✅ Valida JWT (autenticación)
✅ Valida que existe archivo adjunto
✅ Valida id_cliente > 0
✅ Valida que el pago existe
✅ Valida tamaño máximo 5MB
✅ Valida tipos MIME (JPG, PNG, PDF)
✅ Construye ruta por cliente: `comprobantes/<id_cliente>/<nombre>`
✅ Maneja errores de Storage de forma clara
✅ Guarda URL en BD para referencia
✅ Devuelve respuesta JSON estructurada

---

## Notas

- El archivo se renombra en el frontend a `pago_<idPago>_<timestamp>.<ext>` para evitar colisiones
- Storage crea automáticamente la carpeta si no existe
- La URL pública permite descargar el archivo después
- Si quieres verificar comprobantes, agrega estado = 'verificado_pendiente' y crea flujo de validación
