// Constantes de la aplicación Occitours

// API - Configuración de conexión con el backend
// Para emulador Android: http://10.0.2.2:3000
// Para dispositivo local: http://localhost:3000
// Para red local: http://<tu-ip-local>:3000
const String apiBaseUrl = 'http://10.0.2.2:3000/api';
const String apiBaseUrlLocal = 'http://localhost:3000/api';
const Duration apiTimeout = Duration(seconds: 30);
const int maxRetries = 3;

// Validaciones
const int minPasswordLength = 8;
const int maxPasswordLength = 50;
const int minNameLength = 2;

// Configuración de UI
const double defaultPadding = 16.0;
const double defaultBorderRadius = 12.0;
const double defaultElevation = 4.0;

// Cache
const Duration cacheDuration = Duration(hours: 24);

// Configuración de Mapas
const double defaultMapZoom = 15.0;
const double defaultLatitude = 40.7128;
const double defaultLongitude = -74.0060;

// Configuración de Imágenes
const int maxImageSize = 5242880; // 5MB
const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

// Textos comunes
const String appName = 'Occitours';
const String appVersion = '1.0.0';

// URLs
const String privacyPolicyUrl = 'https://occitours.com/privacy';
const String termsAndConditionsUrl = 'https://occitours.com/terms';
const String supportUrl = 'https://support.occitours.com';

// Errores comunes
const String errorNetworkConnection = 'Error de conexión. Verifica tu internet.';
const String errorServerError = 'Error del servidor. Intenta más tarde.';
const String errorUnknown = 'Ha ocurrido un error desconocido.';
const String errorTimeout = 'La solicitud tardó demasiado. Intenta de nuevo.';
