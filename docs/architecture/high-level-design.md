# High-Level Architecture Design

## Обраний архітектурний стиль: **Client-Server Architecture**

### Контекст системи

Wellity — це кросплатформенний мобільний застосунок (Flutter) для фітнесу та відстеження звичок з двома типами користувачів (користувач, тренер). Система вимагає:

- **Offline-first можливості** для habit trackers та нотаток
- **Realtime синхронізацію** для workout sessions (блокування паралельних сесій)
- **Адаптивну логіку** для тренувань на основі оцінок користувачів
- **Складну бізнес-логіку** (платежі, верифікація, статистика тренерів)
- **Швидкий час виходу на ринок** (MVP підхід)

### Обґрунтування вибору Client-Server

**Client-Server Architecture** з розподілом відповідальностей між Flutter Client, Firebase (BaaS), та Custom Backend є оптимальним вибором для Wellity з наступних причин:

#### 1. **Відповідність вимогам**
- **PERF-001, PERF-002:** Клієнт контролює UI performance без мережевих затримок для локальних операцій
- **REL-004:** Firebase Realtime Database забезпечує синхронізацію ≤2с між пристроями
- **SEC-001, SEC-002:** Firebase Auth + HTTPS з'єднання out-of-the-box
- **COMP-001:** Flutter працює на iOS/Android з єдиною кодовою базою

#### 2. **Технологічна відповідність**
- **Firebase** вже обрано командою і покриває 60% функціоналу:
  - Authentication (FR-001)
  - Realtime Database для workout sessions (FR-013)
  - Firestore для habit trackers, notes (FR-002, FR-016)
  - Cloud Storage для медіа (зображення/відео у тренуваннях)
  - Cloud Messaging для push-сповіщень (FR-010)

- **Custom Backend** необхідний для складної логіки (40%):
  - Адаптивні тренування (FR-014) — ML/recommendation engine
  - Платежі (FR-012) — Stripe/PayPal integration
  - Агрегація статистики для тренерів (FR-005)
  - Верифікація тренувань (FR-011)

#### 3. **Розподіл відповідальностей**

```
Flutter Client (Presentation + Business Logic)
    ↓ (direct)              ↓ (via REST API)
Firebase (BaaS)         Custom Backend (TBD)
- Auth                  - Adaptive workouts
- Firestore             - Payment processing
- Realtime DB           - Trainer analytics
- Storage               - Workout verification
- FCM                   - Complex queries
```

#### 4. **Переваги над альтернативами**

**vs Monolithic Layered:**
- ✅ Firebase надає готові сервіси (auth, storage, notifications)
- ✅ Розподілене масштабування (Firebase + Backend окремо)
- ❌ Монолітний backend вимагав би реалізації всього з нуля

**vs Microservices:**
- ✅ Менша складність для команди з 4 розробників
- ✅ Швидший час розробки MVP
- ✅ Єдиний Flutter codebase (не потрібен API Gateway)
- ❌ Мікросервіси додали б overhead без реальних переваг на поточному масштабі

**vs Pure Firebase (без Custom Backend):**
- ❌ Cloud Functions не підходять для ML/адаптації тренувань
- ❌ Складні транзакції (платежі) важко налагоджувати
- ❌ Обмежені можливості для складних запитів та агрегацій

### Компроміси та trade-offs

#### Прийняті компроміси:
- **Vendor lock-in Firebase:** Прийнятно для MVP, міграція можлива пізніше
- **Дві точки відмови:** Firebase і Custom Backend — але Firebase має 99.95% SLA
- **Складність синхронізації:** Клієнт іноді йде до Firebase, іноді до Backend — вирішується чіткими правилами в коді

#### Виграні переваги:
- **Швидкість розробки:** Firebase зменшує time-to-market на 40-50%
- **Масштабованість:** Firebase автоматично масштабується, Backend масштабуємо за потреби
- **Надійність:** Firebase забезпечує realtime та offline capabilities
- **Вартість:** Pay-as-you-go модель Firebase оптимальна для старту

### Архітектурні принципи

1. **Separation of Concerns:** Flutter (UI/BL), Firebase (Data/Auth), Backend (Complex Logic)
2. **Offline-First:** Клієнт працює без мережі, синхронізація при підключенні
3. **API-First:** Backend надає REST API для можливості майбутніх клієнтів (Web, Admin Panel)
4. **Scalability by Design:** Firebase + Backend можуть масштабуватися незалежно
5. **Security by Default:** Firebase Rules + Backend authentication перевіряють всі запити
