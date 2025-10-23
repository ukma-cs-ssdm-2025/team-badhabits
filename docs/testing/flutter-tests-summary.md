# Тестування Flutter застосунку

## Огляд

Реалізовано комплексне тестування мобільного застосунку Wellity з використанням Flutter testing framework. Покрито widget тести та integration тести для забезпечення якості UI та E2E сценаріїв.

## Структура тестів

```
src/frontend/
├── test/
│   ├── mocks.dart                   # Firebase mocks (mockito)
│   ├── test_helpers.dart            # Extension methods
│   └── widget/
│       └── login_screen_test.dart   # Widget tests (5 tests)
└── integration_test/
    └── app_test.dart                # E2E tests (2 scenarios)
```

## Widget Tests

**Файл:** `test/widget/login_screen_test.dart`

**Кількість:** 5 тестів ✅

**Покриття:**
- Рендеринг форми
- Email валідація
- Password валідація
- Button interactions
- State management (password visibility)

**Запуск:**
```bash
cd src/frontend
flutter test test/widget/login_screen_test.dart
```

**Результат:**
```
00:01 +5: All tests passed!
```

## Integration Tests

**Файл:** `integration_test/app_test.dart`

**Сценарії:**
1. **DEMO** - Smoke test (швидкий)
2. **E2E** - Повний user flow

**Покриття:**
- Authentication flow
- Navigation між екранами
- CRUD операції
- Scroll functionality
- Menu interactions

**Запуск:**
```bash
# Smoke test (швидко)
flutter test integration_test/app_test.dart --plain-name "DEMO"

# Повний E2E
flutter test integration_test/app_test.dart --plain-name "E2E"
```

**Примітка:** Потребує запущеного емулятора або підключеного пристрою.

## Технології

| Технологія | Призначення |
|------------|-------------|
| **flutter_test** | Widget testing framework |
| **integration_test** | E2E testing на пристрої |
| **mockito** | Mocking Firebase services |
| **build_runner** | Code generation для mocks |

## Команди

```bash
cd src/frontend

# Встановити залежності
flutter pub get

# Згенерувати mocks
flutter pub run build_runner build --delete-conflicting-outputs

# Запустити widget тести
flutter test test/widget/

# Запустити integration тести (потрібен емулятор)
flutter test integration_test/
```

## Статистика

| Тип | Кількість | Статус | Потрібен пристрій |
|-----|-----------|--------|-------------------|
| Widget tests | 5 | ✅ PASS | ❌ Ні |
| Integration tests | 2 | ✅ READY | ✅ Так |
| **Всього** | **7** | ✅ | |

## Credentials для тестування

```
Email: demo.regular@example.com
Password: 12345678
```
