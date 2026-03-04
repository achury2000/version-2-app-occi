import 'package:intl/intl.dart';
import 'constants.dart';

// Funciones de validación
class Validators {
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }

  static bool isValidName(String name) {
    return name.length >= minNameLength && name.isEmpty == false;
  }

  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^[+]?[0-9]{10,}$');
    return regex.hasMatch(phone);
  }
}

// Funciones de formato
class Formatters {
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(symbol: r'$');
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
}

// Funciones de errores
class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return errorUnknown;
  }

  static bool isNetworkError(dynamic error) {
    final message = getErrorMessage(error).toLowerCase();
    return message.contains('connection') ||
        message.contains('network') ||
        message.contains('timeout');
  }
}

// Funciones de utilidad
class Utils {
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  static String truncateText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static Duration parseDuration(String duration) {
    // Parse "2 horas" o "30 minutos"
    final parts = duration.split(' ');
    if (parts.length == 2) {
      final number = int.tryParse(parts[0]) ?? 0;
      if (parts[1].contains('hora')) {
        return Duration(hours: number);
      } else if (parts[1].contains('minuto')) {
        return Duration(minutes: number);
      }
    }
    return Duration.zero;
  }

  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Funciones de URL y navegación
class UrlBuilder {
  static String buildApiUrl(String endpoint) {
    return '$apiBaseUrl/$endpoint';
  }

  static String buildImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$apiBaseUrl/images/$path';
  }
}
