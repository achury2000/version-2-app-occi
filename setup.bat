@echo off
REM Script para inicializar el proyecto Occitours
REM Ejecuta: setup.bat

echo ===================================
echo  OCCITOURS - Proceso de Inicializacion
echo ===================================
echo.

REM Verificar si Flutter está instalado
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter no está instalado o no está en el PATH
    echo Por favor, sigue la guía en INSTALACION_FLUTTER_DART.md
    pause
    exit /b 1
)

echo [✓] Flutter detectado
echo.

REM Verificar si Dart está instalado
dart --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Dart no está instalado
    pause
    exit /b 1
)

echo [✓] Dart detectado
echo.

REM Limpiar proyecto anterior
echo [*] Limpiando proyecto...
call flutter clean
if %errorlevel% neq 0 (
    echo [!] Advertencia: No se pudo limpiar el proyecto
)
echo.

REM Obtener dependencias
echo [*] Descargando dependencias...
call flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] No se pudieron descargar las dependencias
    pause
    exit /b 1
)
echo [✓] Dependencias descargadas
echo.

REM Generar código (build_runner)
echo [*] Generando código...
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo [!] Advertencia: Error al generar código
)
echo.

REM Mostrar información del proyecto
echo [*] Información del proyecto:
call flutter doctor
echo.

echo ===================================
echo  ¡LISTO PARA EMPEZAR!
echo ===================================
echo.
echo Para ejecutar la aplicación, usa:
echo   flutter run
echo.
echo Para ver las opciones disponibles:
echo   flutter run --help
echo.
pause
