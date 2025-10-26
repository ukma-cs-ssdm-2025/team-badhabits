# Стратегія Тестування - Проєкт Wellity

**Дата:** 26.10.2025 | **Lab 06 Deliverable**

---

## 1. Поточний Статус Тестування

**Модульні тести:** ✅ 70 тестів у `tests/unit/` та `tests/integration/`

**Unit Tests:**
- `tests/unit/adaptiveWorkout.test.ts` - алгоритм адаптації тренувань (FR-014)
- `tests/unit/payment.test.ts` - обробка платежів та підписок (FR-012, SEC-004)

**Integration Tests:**
- `tests/integration/api.test.ts` - API endpoints: `/api/v1/adaptive/recommend`, `/api/v1/payments/subscribe`, `/health`

**Покриття коду:**
- Backend API: **92.98%** Statements, **94.37%** Lines, **100%** Functions (Jest 29.7.0, Supertest 6.3.4)
- Frontend: **<20%** (flutter_test, integration_test, mockito 5.4.4)
- Coverage report: `coverage/lcov-report/index.html`

**CI/CD:** ✅ GitHub Actions автоматизовано (`backend-tests.yml`, `flutter-ci.yml`, `code-quality.yml`)

**Best Practices:** Fixtures, mocks, параметризовані тести, паттерн AAA (Arrange-Act-Assert)

---

## 2. Плани для Інтеграційних, Системних та Приймальних Тестів

### 2.1 Інтеграційні Тести (Weeks 3-4)
**Backend API:**
- Endpoints: `/api/v1/adaptive/recommend`, `/api/v1/payments/subscribe`, `/api/v1/auth/*`
- Mock Firebase Admin SDK, Supertest для HTTP validation
- Тестові сценарії: Success cases, помилки (400, 401, 422, 500)

**Firebase Integration:**
- Firestore CRUD операції (REL-002)
- Real-time sync multi-device ≤2с (REL-004)
- Offline-first conflict resolution

**Cross-Platform:** iOS (iPhone 12+, iOS 14.0+) + Android (Pixel 6, API 24+) у CI

**Ціль:** ≥80% покриття інтеграційних шляхів

### 2.2 Системні Тести (E2E, Weeks 4-5)
**Критичні сценарії:**
1. Реєстрація → Профіль → Перша звичка (USAB-001, FR-001, FR-002)
2. Створення звички → Логування → Статистика (FR-002, FR-003, FR-005)
3. Workout: старт → виконання → оцінка → адаптація (FR-013, FR-014)
4. Платіж → доступ до Premium (FR-012, SEC-004)
5. Offline → Sync → Online consistency (REL-003, REL-004)

**Інструменти:** `integration_test` (Flutter), Supertest + Firebase Emulators

**Ціль:** 100% критичних user flows

### 2.3 Приймальні Тести (Weeks 5-6)
**Підхід:** BDD-тести (Дано-Коли-Тоді) для FR-001 до FR-017

**Приклад:**
```
Дано: Користувач увійшов у систему
Коли: Створює звичку "Ранкова медитація"
Тоді: Звичка відображається у списку
  І Можна залогувати перший entry
  І Streak counter = 1
```

**Ціль:** 100% функціональних вимог

---

## 3. Плани для Performance, Security та Property-Based Тестування

### 3.1 Performance Testing (Weeks 4-5)
**Load Testing (JMeter/k6):**
- 100 користувачів одночасно логують звички
- 50 одночасних workout сесій
- Рендеринг статистики за 365 днів

**Цільові показники:**
- Запис звички ≤1с (PERF-001)
- Запуск додатку ≤3с (PERF-002)
- Статистика ≤2с (PERF-003)
- Workout генерація ≤3с (PERF-004)

### 3.2 Security Testing (Ongoing)
**Automated:**
- OWASP ZAP - vulnerability scanning
- npm audit / snyk - dependency vulnerabilities
- Firebase Security Rules testing

**Manual (Quarterly):**
- Authentication bypass attempts (SEC-001, SEC-003)
- Session hijacking tests
- XSS/CSRF validation

**Вимоги:**
- SHA-256+ password hashing (SEC-001)
- HTTPS + certificate pinning (SEC-002)
- Session timeout ≤24 год (SEC-003)
- PCI DSS compliance, Stripe токенізація (SEC-004)

**Ціль:** 0 критичних уразливостей

### 3.3 Property-Based Testing (Weeks 5-6)
**Підхід:** Генерація випадкових даних для виявлення edge cases

**Області:**
- Habit Tracking: валідація полів (rating ∈ [1..5], habit name ≤100 chars)
- Workout Adaptation: `∀ rating ∈ [1..5] → intensity ∈ [0.0, 1.0]`
- Date/Time: streak counting, timezone conversions
- Sync Logic: детерміноване вирішення конфліктів (REL-004)

**Інструменти:** Backend (`fast-check`) | Frontend (`flutter_test` з custom generators)

**Приклад:**
```javascript
fc.assert(fc.property(fc.integer(1, 5), (rating) => {
  const workout = adaptWorkout(baseWorkout, rating);
  return workout.intensity >= 0.0 && workout.intensity <= 1.0;
}));
```

---

## 4. Інтеграція Тестів у CI/CD Pipeline

### 4.1 Існуюча CI/CD Інтеграція ✅
**GitHub Actions:** `.github/workflows/backend-tests.yml`

**Workflow структура:**
```yaml
Тригер: push/PR до main, develop, lab*
Jobs:
├── test (Node 18.x, 20.x matrix)
│   ├── TypeScript compiler check (tsc --noEmit)
│   ├── ESLint code quality (npm run lint)
│   ├── Unit tests (npm run test:unit)
│   ├── Integration tests (npm run test:integration)
│   ├── Coverage report (threshold ≥70%)
│   ├── Upload to Codecov ✅
│   └── Archive artifacts (30 days retention)
└── quality-gate
    └── Перевірка успішності всіх тестів перед merge
```

**Додаткові workflows:**
- `flutter-ci.yml` - Frontend testing
- `code-quality.yml` - Загальна якість коду
- `release-android.yml` - Android releases

**Локальне виконання:**
```bash
cd src/backend
npm run test:unit          # Unit tests only
npm run test:integration   # Integration tests only
npm run test:coverage      # Повний coverage report
npm run lint               # ESLint check
```

**Quality Gates:**
- Мінімальне покриття: ≥80% (критичні модулі ≥90%)
- Критичні баги: 0
- Уразливості: 0
- Якість коду: ≥B

### 4.2 Розширений Pipeline (Weeks 3-6)
**Full Pipeline:**
```
Коміт → CI → Unit + Integration Tests → Quality Gates →
E2E Tests → Build → Staging → Smoke Tests → Approval → Production
```

**Notifications:** Slack (failures), Email (deploys), GitHub (PR checks)

**Branch Strategy:**
- `main`: Production-ready, всі тести проходять
- `develop`: ≥80% покриття required
- `feature/*`: unit tests required

**Test Parallelization:**
- Unit tests: Jest `--maxWorkers=4`
- E2E tests: sequential (avoid race conditions)

**Target:** CI pipeline ≤10 хвилин

---

## 5. Дорожня Карта

| Фаза | Терміни | Завдання | Статус |
|------|---------|----------|--------|
| **Lab 06 Foundation** | Weeks 1-2 | 70 модульних тестів<br>Coverage 92.98% (Backend)<br>Debugging log<br>Testing strategy | ✅ Complete |
| **Integration** | Weeks 3-4 | E2E критичні flows<br>Cross-platform CI<br>Performance benchmarks | ⏳ Planned |
| **Maturity** | Weeks 5-6 | Coverage → 80%<br>Property testing<br>Security scans<br>Codecov | ⏳ Planned |

---

## Посилання

- **Модульні тести:** `src/backend/tests/unit/`, `src/backend/tests/integration/`
- **Coverage report:** `src/backend/coverage/lcov-report/index.html`
- **Debugging log:** `docs/testing/debugging-log.md` (Avatar Update Race Condition)
- **CI/CD:** `.github/workflows/` (backend-tests.yml, flutter-ci.yml, code-quality.yml)
- **Вимоги:** `docs/requirements/requirements.md` (FR-001-017, PERF/REL/SEC-001-004)
