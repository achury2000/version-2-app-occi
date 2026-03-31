# Estructura de Testing Actual vs. FASE 5 - Occitours

**Fecha:** 31 de marzo de 2026  
**Estado:** Análisis Completo

---

## 📊 ESTADO ACTUAL DEL TESTING

### 1. **Archivos y Directorios Existentes**

```
project/
├── test/
│   └── widget_test.dart              ← Único archivo de test
├── integration_test/                 ← NO EXISTE
└── pubspec.yaml                      ← Solo flutter_test en dev_dependencies
```

### 2. **Widget Test Actual** (`test/widget_test.dart`)

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Occitours App Tests', () {
    testWidgets('Aplicación se carga correctamente',
        (WidgetTester tester) async {
      // Aquí iría el test de la aplicación
      expect(true, true);  // ← PLACEHOLDER VACÍO
    });

    test('Validación de email', () {
      expect(true, true);  // ← PLACEHOLDER VACÍO
    });

    test('Formato de moneda', () {
      expect(true, true);  // ← PLACEHOLDER VACÍO
    });
  });
}
```

**Problemas:**
- ❌ Solo placeholders sin lógica real
- ❌ No carga la aplicación (`App()`)
- ❌ No importa ningún model, service o provider
- ❌ No testea ningún screen
- ❌ No hay mocks de dependencias

### 3. **Tipo de Tests Actuales**

| Tipo | Existe | Cantidad | Estado |
|------|--------|----------|--------|
| **Unit Tests** | ❌ | 0 | No hay |
| **Widget Tests** | 🔄 | 1 archivo vacío | Placeholder |
| **Integration Tests** | ❌ | 0 | Directorio no existe |
| **E2E Tests** | ❌ | 0 | No existe |

---

## 🎯 FASE 5: REQUISITOS DE TESTING

### Contexto FASE 5: "Reservas Cliente Mejorado"

Según el plan maestro, FASE 5 debe implementar:
- DisponibilidadesScreen (listar, filtrar, navegar)
- CrearReservaScreen (crear reserva, validaciones)
- ReservaDetalleScreen (ver detalles, cancelar)
- Flujo E2E completo cliente-reserva

---

## 📍 ESTRUCTURA DE CÓDIGO QUE EXISTE

### Screens a Testear

```
lib/screens/
├── catalogo/
│   └── disponibilidades_screen.dart      ← TESTEAR
├── reservas/
│   ├── crear_reserva_screen.dart         ← TESTEAR
│   └── reserva_detalle_screen.dart       ← TESTEAR
└── (otros screens de auth, home, etc)
```

### Models

```
lib/models/
├── reserva.dart                    ← Modelo principal
├── programacion.dart               ← Datos de programación
├── cliente.dart                    ← Datos del cliente
└── (otros modelos)
```

### Providers

```
lib/providers/
├── reserva_provider.dart           ← Gestiona estado de reservas
├── programacion_provider.dart      ← Gestiona estado de programaciones
├── auth_provider.dart              ← Autenticación
└── (otros providers)
```

### Services

```
lib/services/
├── reserva_service.dart            ← API calls para reservas
├── programacion_service.dart       ← API calls para programaciones
├── api_service.dart                ← Base de HTTP requests
└── (otros servicios)
```

---

## 🔍 QUÉ NECESITA TESTING EN FASE 5

### 1. **DisponibilidadesScreen** (catalogo/disponibilidades_screen.dart)

**Funcionalidades a testear:**

```dart
// WIDGET TESTS
✓ Pantalla se renderiza correctamente
✓ Carga lista de programaciones
✓ Muestra loading mientras carga
✓ Muestra error si falla carga
✓ Filtro por texto busca correctamente
✓ Filtro por estado filtra programaciones
✓ Tab de Rutas y Tab de Fincas funcionan
✓ Tap en item navega a detalle
✓ Botón "Reservar" abre CrearReservaScreen
✓ búsqueda vacía limpias filtros

// INTEGRATION TESTS
✓ Flujo completo: carga → filtra → navega → reserva
```

**Dependencias a mockear:**
- `ProgramacionProvider` 
- `ReservaProvider`
- `GoRouter` para navegación
- `ProgramacionService` (datos)

---

### 2. **CrearReservaScreen** (reservas/crear_reserva_screen.dart)

**Funcionalidades a testear:**

```dart
// WIDGET TESTS - Rendering
✓ Pantalla se renderiza correctamente
✓ Carga detalle de programación
✓ Muestra información correcta (nombre, precio, fechas)
✓ Spinner de cantidad personas aparece
✓ Dropdown de método pago funciona
✓ Campo de observaciones está habilitado

// WIDGET TESTS - Validaciones
✓ Valida cantidad mínima de personas (1)
✓ Valida cantidad máxima de personas (según programación)
✓ Calcula precio total correctamente (cantidad × precio unitario)
✓ Requiere método de pago seleccionado
✓ Requiere aceptación de términos

// WIDGET TESTS - Actions
✓ Botón "Crear Reserva" envía datos
✓ Muestra loading durante creación
✓ Muestra error si falla
✓ Muestra success si se crea
✓ Navega a detalle de reserva tras success

// INTEGRATION TESTS
✓ Flujo: carga → rellena → valida → crea → navega
```

**Dependencias a mockear:**
- `ProgramacionProvider`
- `ReservaProvider`
- `AuthProvider` (obtiene idCliente)
- `ReservaService` (crear reserva)
- `GoRouter` para navegación

---

### 3. **ReservaDetalleScreen** (reservas/reserva_detalle_screen.dart)

**Funcionalidades a testear:**

```dart
// WIDGET TESTS - Rendering
✓ Pantalla se renderiza correctamente
✓ Carga detalle de reserva
✓ Muestra loading mientras carga
✓ Muestra error si falla carga
✓ Muestra información completa: id, cliente, estado, precio, fechas

// WIDGET TESTS - Estado
✓ Muestra estado correcto (pendiente, confirmada, etc)
✓ Muestra estado de pago (pagada, pendiente)
✓ Muestra método de pago usado

// WIDGET TESTS - Actions
✓ Botón cancelar aparece si estado permite
✓ Botón cancelar abre confirmación
✓ Cancelación con confirmación funciona
✓ Muestra error si no se puede cancelar
✓ Botón volver navega atrás

// INTEGRATION TESTS
✓ Flujo: carga → muestra → cancela → valida

// MOCK DATA
- Reservas en diferente estado: pendiente, confirmada, completada, cancelada
```

**Dependencias a mockear:**
- `ReservaProvider`
- `ReservaService` (obtener detalle, cancelar)
- `GoRouter` para navegación

---

### 4. **Flujo E2E Completo Cliente-Reserva**

**Test de integración desde inicio hasta cierre:**

```
Login → Ver Catálogo → Seleccionar Programación → 
Crear Reserva → Ver Detalle → Cancelar (o completar) → 
Ver en Mis Reservas
```

**Targets a validar:**
- ✓ Flow completo sin errores
- ✓ Datos persisten correctamente
- ✓ Navegación funciona entre pantallas
- ✓ Estado se mantiene durante el flujo
- ✓ Errores se manejan adecuadamente

---

## 📁 ESTRUCTURA DE ARCHIVOS A CREAR

```
test/
├── widget_test.dart                              (EXISTENTE - modificar)
├── unit/
│   ├── models/
│   │   ├── reserva_model_test.dart
│   │   ├── programacion_model_test.dart
│   │   └── cliente_model_test.dart
│   ├── providers/
│   │   ├── reserva_provider_test.dart
│   │   └── programacion_provider_test.dart
│   └── services/
│       ├── reserva_service_test.dart
│       └── programacion_service_test.dart
│
├── widget/
│   ├── disponibilidades_screen_test.dart
│   ├── crear_reserva_screen_test.dart
│   ├── reserva_detalle_screen_test.dart
│   └── mocks/
│       ├── mock_providers.dart
│       ├── mock_services.dart
│       ├── mock_data.dart
│       └── mock_router.dart
│
├── integration_test/
│   └── cliente_reserva_flow_test.dart
│
└── fixtures/
    ├── programacion_fixture.json
    ├── reserva_fixture.json
    └── cliente_fixture.json

= TOTAL: ~15-18 archivos nuevos
```

---

## 🛠️ DEPENDENCIAS NECESARIAS EN pubspec.yaml

**Actual (dev_dependencies):**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.6
```

**Agregar para testing:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.6
  
  # Mocking
  mockito: ^5.4.0              ← Para mocks de clases/servicios
  mocktail: ^1.0.0             ← Alternativa más moderna
  
  # Testing utilities
  integration_test:            ← Para tests E2E (incluido en Flutter)
    sdk: flutter
  
  # Fixtures y test data
  fixture: ^1.0.0              ← Datos de prueba

TOTAL: +3 a +4 dependencias
```

---

## 📋 PLAN IMPLEMENTACIÓN TESTING FASE 5

### **Semana 1: Setup & Unit Tests**

| Día | Tarea | Horas | Outputs |
|-----|-------|-------|---------|
| 1 | Actualizar pubspec.yaml, crear estructura directorios | 1h | Dirs creados |
| 2 | Crear mock_providers.dart, mock_services.dart | 2h | Mocks reutilizables |
| 3 | Unit tests para modelos (Reserva, Programacion) | 2h | 2 test files ~30 tests |
| 4 | Unit tests para providers | 3h | 2 test files ~40 tests |
| 5 | Unit tests para services | 3h | 2 test files ~30 tests |

**Subtotal: 11 horas**

---

### **Semana 2: Widget Tests**

| Día | Tarea | Horas | Outputs |
|-----|-------|-------|---------|
| 1 | Widget test DisponibilidadesScreen | 4h | 1 file ~15 tests |
| 2-3 | Widget test CrearReservaScreen | 6h | 1 file ~25 tests |
| 4 | Widget test ReservaDetalleScreen | 4h | 1 file ~15 tests |
| 5 | Refactor widget_test.dart existente | 1h | Cleaned up |

**Subtotal: 15 horas**

---

### **Semana 3: Integration Tests & Documentation**

| Día | Tarea | Horas | Outputs |
|-----|-------|-------|---------|
| 1-2 | Integration test E2E (flujo completo) | 5h | 1 file ~10 tests |
| 3 | Fixture files, test data | 2h | 3 JSON files |
| 4 | Documentation & test guide | 2h | PDF/MD guide |
| 5 | Bug fixes, optimización | 2h | Tests en 95%+ passing |

**Subtotal: 11 horas**

---

### **TOTAL ESTIMADO TESTING FASE 5: 37 horas**

**Breakdown:**
- Setup & Dependencies: 1h
- Mocks & Fixtures: 3h
- Unit Tests: 14h
- Widget Tests: 15h
- Integration Tests: 4h

**Velocidad estimada:**
- Con 4-5 horas/día: ~1 semana (más si hay bugs)
- Con 8 horas/día: ~5 días

---

## ✅ CHECKLIST IMPLEMENTACIÓN

### **Phase 1: Foundation**
- [ ] Actualizar `pubspec.yaml` con dependencias de test
- [ ] Crear estructura de directorios: `test/unit/`, `test/widget/`, `test/fixtures/`
- [ ] Crear `test/widget/mocks/` con archivos base

### **Phase 2: Mocks & Fixtures**
- [ ] `mock_providers.dart` - Mocks de ProvidersI
- [ ] `mock_services.dart` - Mocks de Services
- [ ] `mock_router.dart` - Mock de GoRouter
- [ ] `mock_data.dart` - Datos de prueba
- [ ] Crear fixture JSON files

### **Phase 3: Unit Tests (Modelos)**
- [ ] `reserva_model_test.dart` - Tests del modelo Reserva
- [ ] `programacion_model_test.dart` - Tests del modelo Programacion
- [ ] `cliente_model_test.dart` - Tests del modelo Cliente

### **Phase 4: Unit Tests (Providers)**
- [ ] `reserva_provider_test.dart` - Cargar, filtrar, actualizar
- [ ] `programacion_provider_test.dart` - Cargar, buscar, filtrar

### **Phase 5: Unit Tests (Services)**
- [ ] `reserva_service_test.dart` - API calls simuladas
- [ ] `programacion_service_test.dart` - API calls simuladas

### **Phase 6: Widget Tests**
- [ ] `disponibilidades_screen_test.dart` - Rendering, filtros, navegación
- [ ] `crear_reserva_screen_test.dart` - Validaciones, cálculos, creación
- [ ] `reserva_detalle_screen_test.dart` - Rendering, cancelación

### **Phase 7: Integration Tests**
- [ ] `cliente_reserva_flow_test.dart` - Flujo E2E completo
- [ ] Tests de navegación entre screens
- [ ] Tests de estado compartido

### **Phase 8: Cleanup & Documentation**
- [ ] Refactor de `widget_test.dart` (replacement real)
- [ ] Documentación de estrategia de testing
- [ ] Coverage report

---

## 🔬 EJEMPLOS DE TESTS A IMPLEMENTAR

### **Unit Test - Modelo Reserva**

```dart
void main() {
  group('Reserva Model', () {
    test('Calcular precio total correctamente', () {
      final reserva = Reserva(
        id: 1,
        cantidadPersonas: 3,
        precioPorPersona: 50.0,
        estado: 'confirmada',
      );

      expect(reserva.precioTotal, 150.0);
    });

    test('Validar estado válido', () {
      final reserva = Reserva(
        id: 1,
        estado: 'confirmada',
      );

      expect(['pendiente', 'confirmada', 'completada', 'cancelada']
          .contains(reserva.estado), true);
    });

    test('JSON serialization/deserialization', () {
      final json = {
        'id': 1,
        'estado': 'confirmada',
        'cantidadPersonas': 2,
        'precioTotal': 100.0,
      };

      final reserva = Reserva.fromJson(json);
      expect(reserva.id, 1);
      expect(reserva.toJson()['estado'], 'confirmada');
    });
  });
}
```

### **Widget Test - DisponibilidadesScreen**

```dart
void main() {
  group('DisponibilidadesScreen', () {
    testWidgets('Muestra lista de programaciones', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _createTestApp(
          ProgramacionProvider(
            programaciones: [
              mockProgramacion1,
              mockProgramacion2,
            ],
          ),
        ),
      );

      expect(find.byType(ListView), findsWidgets);
      expect(find.byType(ProgramacionCard), findsNWidgets(2));
    });

    testWidgets('Filtra programaciones por búsqueda',
        (WidgetTester tester) async {
      // Setup con programaciones
      // Ingresa texto en searchField
      await tester.enterText(find.byType(TextField), 'senderismo');
      await tester.pumpAndSettle();
      
      // Verifica que filtra
      expect(find.byType(ProgramacionCard), findsOneWidget);
    });

    testWidgets('Navega a CrearReservaScreen al tocar Reservar',
        (WidgetTester tester) async {
      // Tap on Reservar button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Verificar navegación
      expect(find.byType(CrearReservaScreen), findsOneWidget);
    });
  });
}
```

### **Integration Test - Flujo E2E**

```dart
void main() {
  testWidgets('Cliente: Crear reserva flujo completo',
      (WidgetTester tester) async {
    // Setup app con todos los providers
    await tester.pumpWidget(createMockApp());

    // 1. Ver disponibilidades
    expect(find.byType(DisponibilidadesScreen), findsOneWidget);

    // 2. Filtrar y seleccionar
    await tester.enterText(find.byType(TextField), 'tour');
    await tester.pumpAndSettle();

    // 3. Tap reservar
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // 4. Rellenar formulario
    await tester.enterText(find.byKey(ValueKey('cantidad')), '2');
    await tester.tap(find.byKey(ValueKey('metodoPago')));
    await tester.pumpAndSettle();

    // 5. Crear
    await tester.tap(find.text('Crear Reserva'));
    await tester.pumpAndSettle();

    // 6. Verificar resultado
    expect(find.byType(ReservaDetalleScreen), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);
  });
}
```

---

## 🎯 RECOMENDACIONES PRÁCTICAS

### **Best Practices para Fase 5 Testing**

1. **Mocks reutilizables:** Crear clase base MockProgramacionProvider, MockReservaProvider con datos reales
2. **Test fixtures:** Datos en JSON para facilitar cambios sin tocar código
3. **Golden files (opcional):** Capturar screenshots de UI para detectar cambios visuales
4. **CI/CD Integration:** Ejecutar tests en cada commit (si tienen CI setup)
5. **Coverage minimo:** Apuntar a 75%+ cobertura en screens críticos

### **Herramientas Recomendadas**

```bash
# Ejecutar todos los tests
flutter test

# Tests con coverage
flutter test --coverage

# Generar HTML report
lcov --list coverage/lcov.info

# Watch mode (re-run on changes)
flutter test --watch

# Specific test file
flutter test test/widget/disponibilidades_screen_test.dart
```

### **Organización de Test Files**

- **Unit tests:** Sin UI, solo lógica pura. ~50ms/test
- **Widget tests:** No requieren dispositivo. ~200ms/test
- **Integration tests:** Requieren emulador/device. ~5s/test

*Estrategia: Piramide 70% unit + 20% widget + 10% integration*

---

## 📊 RESUMEN FINAL

| Aspecto | Actual | FASE 5 | Gap |
|---------|--------|--------|-----|
| **Archivos de test** | 1 (vacío) | 15-18 | +14-17 |
| **Tests unitarios** | 0 | 40-50 | +40-50 |
| **Tests widget** | 0 | 50-60 | +50-60 |
| **Tests integración** | 0 | 10-15 | +10-15 |
| **Cobertura estimada** | ~0% | 70-80% | +70-80% |
| **Horas estimadas** | 2h (placeholder) | 37h | +35h |
| **Dependencias** | 3 | 6-7 | +3-4 |

---

## 🚀 PRÓXIMOS PASOS

1. **Esta semana:** Revisar este documento con el equipo
2. **Semana que viene:** Agregar dependencias y crear estructura
3. **Fase 5 propiamente:** Implementar tests en paralelo con feature development
4. **Post-Fase 5:** Expandir a otros screens (admin, asesor, etc)

**Responsabilidad:** En FASE 5 se codea testing desde el inicio (TDD o al menos en paralelo)

---

**Creado:** 31-03-2026  
**Próxima revisión:** Inicio FASE 5  
**Nota:** Este documento evolucionará conforme se implementan los tests
