#!/bin/bash

# Script para inicializar el proyecto Occitours
# Ejecuta: bash setup.sh

echo "==================================="
echo "  OCCITOURS - Proceso de Inicializacion"
echo "==================================="
echo ""

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] Flutter no está instalado o no está en el PATH"
    echo "Por favor, sigue la guía en INSTALACION_FLUTTER_DART.md"
    exit 1
fi

echo "[✓] Flutter detectado"
echo ""

# Verificar si Dart está instalado
if ! command -v dart &> /dev/null; then
    echo "[ERROR] Dart no está instalado"
    exit 1
fi

echo "[✓] Dart detectado"
echo ""

# Limpiar proyecto anterior
echo "[*] Limpiando proyecto..."
flutter clean
if [ $? -ne 0 ]; then
    echo "[!] Advertencia: No se pudo limpiar el proyecto"
fi
echo ""

# Obtener dependencias
echo "[*] Descargando dependencias..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "[ERROR] No se pudieron descargar las dependencias"
    exit 1
fi
echo "[✓] Dependencias descargadas"
echo ""

# Generar código (build_runner)
echo "[*] Generando código..."
flutter pub run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "[!] Advertencia: Error al generar código"
fi
echo ""

# Mostrar información del proyecto
echo "[*] Información del proyecto:"
flutter doctor
echo ""

echo "==================================="
echo "  ¡LISTO PARA EMPEZAR!"
echo "==================================="
echo ""
echo "Para ejecutar la aplicación, usa:"
echo "  flutter run"
echo ""
echo "Para ver las opciones disponibles:"
echo "  flutter run --help"
echo ""
