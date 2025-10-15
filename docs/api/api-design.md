# Документація API Backend

## Зміст
1. [Архітектурний контекст](#архітектурний-контекст)
2. [Документація Endpoints](#документація-endpoints)
3. [Автентифікація](#автентифікація)
4. [Обробка помилок](#обробка-помилок)
5. [Валідація](#валідація)

---

## Архітектурний контекст

### Гібридна архітектура: Firebase (60%) + Custom Backend (40%)

Wellity використовує **гібридну Client-Server архітектуру**, яка розподіляє відповідальності між Firebase (BaaS) та Custom Backend (Node.js/Express). Це рішення задокументовано в [ADR-001: Архітектурний стиль](../decisions/ADR-001-architecture-style.md) та [ADR-003: Дизайн API](../decisions/ADR-003-api-design.md).

#### Огляд архітектури

```
Flutter Client (Presentation + Business Logic)
    ↓ (прямо)               ↓ (через REST API)
Firebase (BaaS)         Custom Backend (Node.js)
- Auth (FR-001)         - Адаптивні тренування (FR-014)
- Firestore             - Обробка платежів (FR-012)
- Realtime DB           - Аналітика тренерів (FR-005)
- Storage               - Верифікація тренувань (FR-011)
- FCM (FR-010)          - Рекомендації відновлення (FR-006)
```

### Навіщо потрібен Custom Backend

Хоча Firebase покриває 60% нашого функціоналу (автентифікація, зберігання даних, realtime синхронізація, push-сповіщення), нам необхідний **Custom Backend для складної бізнес-логіки**, яку Firebase не може ефективно обробляти:

1. **ML/Адаптивні тренування (FR-014)**
   - Recommendation engine на основі оцінок користувачів та метрик продуктивності
   - Алгоритми динамічного налаштування складності
   - Персоналізований підбір вправ

2. **Обробка платежів (FR-012)**
   - Інтеграція зі Stripe та PayPal
   - Відповідність вимогам PCI DSS
   - Складна логіка управління підписками та білінгом

3. **Складна аналітика (FR-005)**
   - Агрегована статистика для тренерів
   - Аналіз даних за періодами (тиждень/місяць/квартал/рік)
   - Розрахунки доходів та трендів зростання

4. **Верифікація тренувань (FR-011)**
   - Автоматизовані перевірки якості та безпеки
   - Робочі процеси ручної верифікації
   - Алгоритми оцінювання якості контенту

5. **Рекомендації з відновлення (FR-006)**
   - Розрахунки часу відновлення м'язів
   - Персоналізовані рекомендації з харчування та сну
   - Динамічні програми розтяжки на основі типу тренування

### Технологічний стек

- **Backend Framework:** Node.js з Express
- **Валідація:** express-validator
- **Стиль API:** REST (згідно з ADR-003)
- **Автентифікація:** Firebase Auth JWT tokens
- **Base URL:** `/api/v1`

---

## Документація Endpoints

### 1. POST /api/v1/adaptive/recommend

**Мета:** Генерація персоналізованих рекомендацій тренувань на основі оцінок користувачів та історії продуктивності (FR-014)

**Автентифікація:** Обов'язкова (Firebase JWT)

**Тіло запиту:**
```json
{
  "userId": "user123",
  "previousWorkoutId": "workout456",
  "userRating": 4,
  "performanceMetrics": {
    "completionRate": 95.5,
    "averageHeartRate": 145
  }
}
```

**Правила валідації:**
- `userId`: Обов'язкове, непорожній рядок
- `previousWorkoutId`: Обов'язкове, непорожній рядок
- `userRating`: Обов'язкове, ціле число від 1 до 5
- `performanceMetrics`: Опціональний об'єкт

**Успішна відповідь (200):**
```json
{
  "workoutId": "workout_1697123456789",
  "title": "Full Body Strength - Advanced",
  "trainerId": "trainer101",
  "exercises": [
    {
      "name": "Diamond Push-ups",
      "sets": 4,
      "reps": 15,
      "restSeconds": 45
    },
    {
      "name": "Jump Squats",
      "sets": 4,
      "reps": 20,
      "restSeconds": 60
    }
  ],
  "difficultyLevel": "advanced",
  "estimatedDuration": 65,
  "adaptationReason": "Increased intensity based on positive rating and high completion rate"
}
```

**Динамічна поведінка:**
- Рівень складності визначається за `userRating`:
  - 1-2: beginner (легші вправи, 30 хв)
  - 3: intermediate (стандартні вправи, 45 хв)
  - 4-5: advanced (складні вправи, 60 хв)
- Тривалість коригується за `completionRate`:
  - <80%: -5 хвилин
  - >95%: +5 хвилин

**Помилки:**
- `400`: Валідація не пройдена (невірний userRating, відсутні поля)
- `404`: Користувач або попереднє тренування не знайдено (`userId === 'nonexistent'`)
- `500`: Внутрішня помилка сервера

---

### 2. POST /api/v1/payments/subscribe

**Мета:** Обробка платежів за підписку для доступу до преміум тренувань (FR-012)

**Автентифікація:** Обов'язкова (Firebase JWT)

**Тіло запиту:**
```json
{
  "userId": "user123",
  "workoutId": "workout456",
  "paymentMethod": "stripe",
  "paymentToken": "tok_1234567890abcdef",
  "planType": "monthly"
}
```

**Правила валідації:**
- `userId`: Обов'язкове, непорожній рядок
- `workoutId`: Обов'язкове, непорожній рядок
- `paymentMethod`: Обов'язкове, enum: `['stripe', 'paypal']`
- `paymentToken`: Опціональний рядок
- `planType`: Опціональний, enum: `['monthly', 'yearly']`, за замовчуванням 'monthly'

**Успішна відповідь (200):**
```json
{
  "subscriptionId": "sub_1697123456789",
  "userId": "user123",
  "workoutId": "workout456",
  "status": "active",
  "startDate": "2025-10-13T12:00:00Z",
  "endDate": "2025-11-13T12:00:00Z",
  "planType": "monthly",
  "amount": 9.99,
  "currency": "USD",
  "nextBillingDate": "2025-11-13T12:00:00Z",
  "paymentMethod": "stripe",
  "savings": 0,
  "features": {
    "unlimitedAccess": true,
    "offlineDownloads": false,
    "prioritySupport": false,
    "personalizedPlans": true
  }
}
```

**Динамічна поведінка:**
- Ціноутворення залежить від плану:
  - `monthly`: $9.99, без знижки
  - `yearly`: $99.99, економія $19.89
- Функції відрізняються за планом:
  - Річний включає: офлайн завантаження, пріоритетну підтримку
  - Місячний: базові функції

**Помилки:**
- `400`: Валідація не пройдена (невірний paymentMethod, відсутні поля)
- `402`: Платіж не вдався (`paymentToken === 'invalid_token'`)
- `404`: Користувач або тренування не знайдено
- `500`: Внутрішня помилка сервера

---

### 3. GET /api/v1/analytics/trainer/:id

**Мета:** Отримання агрегованої аналітики для тренерів, включаючи продуктивність тренувань, підписників та дохід (FR-005)

**Автентифікація:** Обов'язкова (Firebase JWT, роль тренера)

**Параметри шляху:**
- `id`: ID тренера (обов'язковий)

**Параметри запиту:**
- `period`: Часовий період для аналітики (опціональний)
  - Значення: `['week', 'month', 'quarter', 'year']`
  - За замовчуванням: `'month'`

**Приклад запиту:**
```
GET /api/v1/analytics/trainer/trainer101?period=quarter
```

**Правила валідації:**
- `id` (параметр шляху): Обов'язковий, непорожній рядок
- `period` (параметр запиту): Опціональний, одне з: week, month, quarter, year

**Успішна відповідь (200):**
```json
{
  "trainerId": "trainer101",
  "displayName": "John Doe",
  "period": "quarter",
  "dateRange": {
    "start": "2025-07-13T12:00:00Z",
    "end": "2025-10-13T12:00:00Z"
  },
  "statistics": {
    "totalWorkouts": 135,
    "verifiedWorkouts": 114,
    "totalSubscribers": 1250,
    "newSubscribers": 245,
    "totalRevenue": 35420,
    "averageRating": 4.6,
    "totalCompletions": 16296,
    "completionRate": 87.5
  },
  "topWorkouts": [
    {
      "workoutId": "workout789",
      "title": "HIIT Cardio Blast",
      "completions": 2676,
      "averageRating": 4.8
    }
  ],
  "engagement": {
    "dailyActiveUsers": 345,
    "weeklyActiveUsers": 892,
    "monthlyActiveUsers": 1450
  },
  "trends": {
    "subscriberGrowth": "moderate",
    "revenueGrowth": "good"
  }
}
```

**Динамічна поведінка:**
- Статистика масштабується за періодом з використанням множників:
  - `week`: 0.25x (20 нових підписників, $3K доходу)
  - `month`: 1x (87 нових підписників, $12.5K доходу)
  - `quarter`: 3x (245 нових підписників, $35K доходу)
  - `year`: 12x (980 нових підписників, $142K доходу)
- Метрики залученості та тренди налаштовуються відповідно

**Помилки:**
- `400`: Валідація не пройдена (невірне значення period)
- `403`: Заборонено (користувач не є тренером або отримує доступ до даних іншого тренера)
- `404`: Тренер не знайдений (`id === 'nonexistent'`)
- `500`: Внутрішня помилка сервера

---

### 4. POST /api/v1/workouts/:id/verify

**Мета:** Виконання автоматизованої та ручної верифікації контенту тренувань для забезпечення стандартів якості та безпеки (FR-011)

**Автентифікація:** Обов'язкова (Firebase JWT, роль адміністратора/модератора)

**Параметри шляху:**
- `id`: ID тренування для верифікації (обов'язковий)

**Тіло запиту:**
```json
{
  "verifiedBy": "admin789",
  "verificationNotes": "Excellent form demonstrations, clear instructions",
  "autoChecksPassed": true
}
```

**Правила валідації:**
- `id` (параметр шляху): Обов'язковий, непорожній рядок
- `verifiedBy`: Обов'язковий, непорожній рядок
- `verificationNotes`: Опціональний рядок
- `autoChecksPassed`: Опціональний boolean, за замовчуванням true

**Успішна відповідь (200):**
```json
{
  "workoutId": "workout456",
  "isVerified": true,
  "verificationStatus": "approved",
  "verifiedBy": "admin789",
  "verifiedAt": "2025-10-13T12:30:00Z",
  "verificationDetails": {
    "safetyScore": 98,
    "qualityScore": 92,
    "overallScore": 95,
    "checks": {
      "videoQuality": true,
      "exerciseForm": true,
      "instructionClarity": true,
      "safetyGuidelines": true
    },
    "verificationNotes": "Excellent form demonstrations, clear instructions"
  },
  "nextSteps": [
    "Workout is now live and accessible to premium users",
    "Added to trainer's verified workout list",
    "Email notification sent to trainer"
  ]
}
```

**Динамічна поведінка:**
- Оцінки налаштовуються на основі вхідних даних:
  - З детальними нотатками (>10 символів): safetyScore=98, qualityScore=92
  - Без нотаток: safetyScore=95, qualityScore=88
- Статус верифікації на основі загальної оцінки:
  - ≥90: `'approved'` (схвалено)
  - ≥75: `'approved_with_notes'` (схвалено з зауваженнями)
  - <75: `'rejected'` (відхилено)
- Масив `nextSteps` змінюється залежно від статусу

**Помилки:**
- `400`: Валідація не пройдена або автоматичні перевірки не пройдено
  ```json
  {
    "error": "Verification failed",
    "message": "Workout did not pass automated safety and quality checks",
    "failedChecks": ["videoQuality", "safetyGuidelines"],
    "recommendations": [
      "Improve video resolution to at least 720p",
      "Add proper warm-up and cool-down instructions"
    ]
  }
  ```
- `403`: Заборонено (користувач не має прав на верифікацію)
- `404`: Тренування не знайдено (`id === 'nonexistent'`)
- `500`: Внутрішня помилка сервера

---

### 5. GET /api/v1/recommendations/recovery

**Мета:** Генерація персоналізованих рекомендацій з відновлення на основі історії тренувань та профілю користувача (FR-006)

**Автентифікація:** Обов'язкова (Firebase JWT)

**Параметри запиту:**
- `userId`: ID користувача (обов'язковий)
- `lastWorkoutId`: ID останнього тренування (опціональний)
- `muscleGroup`: Цільова група м'язів з останнього тренування (опціональний)
  - Значення: `['upper', 'lower', 'core', 'full_body']`
  - За замовчуванням: `'upper'`

**Приклад запиту:**
```
GET /api/v1/recommendations/recovery?userId=user123&muscleGroup=lower
```

**Правила валідації:**
- `userId`: Обов'язковий, непорожній рядок
- `lastWorkoutId`: Опціональний рядок
- `muscleGroup`: Опціональний, одне з: upper, lower, core, full_body

**Успішна відповідь (200):**
```json
{
  "userId": "user123",
  "generatedAt": "2025-10-13T12:45:00Z",
  "recoveryStatus": "needs_rest",
  "estimatedRecoveryTime": 48,
  "lastWorkoutId": "workout456",
  "targetMuscleGroup": "lower",
  "recommendations": {
    "restDays": 2,
    "activeRecovery": [
      {
        "activity": "Light yoga",
        "duration": 20,
        "benefits": "Improves flexibility and reduces muscle tension"
      },
      {
        "activity": "Walking",
        "duration": 30,
        "benefits": "Promotes blood flow and aids recovery without strain"
      }
    ],
    "nutrition": {
      "protein": "25-35g within 2 hours post-workout",
      "hydration": "2.5-3L water throughout the day",
      "supplements": ["BCAAs", "Omega-3", "Vitamin D", "Magnesium"]
    },
    "sleep": {
      "recommendedHours": 9,
      "qualityTips": [
        "Maintain consistent sleep schedule",
        "Avoid screens 1hr before bed",
        "Keep room temperature cool (65-68°F)"
      ]
    },
    "stretching": [
      {
        "name": "Hamstring stretch",
        "duration": 40,
        "targetMuscles": ["Hamstrings", "Calves"]
      },
      {
        "name": "Quad stretch",
        "duration": 40,
        "targetMuscles": ["Quadriceps"]
      }
    ]
  },
  "nextWorkoutRecommendation": {
    "suggestedDate": "2025-10-15T12:45:00Z",
    "focusArea": "Upper body or core (allow lower body to recover)",
    "intensity": "light"
  },
  "warnings": [
    "Avoid heavy lower body exercises for 48-72 hours",
    "Listen to your body - extend rest if experiencing persistent soreness",
    "Ensure adequate protein intake for muscle repair",
    "Consider taking an extra rest day before intense training"
  ]
}
```

**Динамічна поведінка:**
- Час відновлення залежить від групи м'язів:
  - `upper`: 24 години
  - `lower`: 48 годин
  - `core`: 18 годин
  - `full_body`: 36 годин
- Статус відновлення визначається за часом:
  - ≤18год: `'fully_recovered'` (повністю відновлено)
  - ≤36год: `'partially_recovered'` (частково відновлено)
  - >36год: `'needs_rest'` (потрібен відпочинок)
- Різні вправи на розтяжку для кожної групи м'язів
- Рекомендації з харчування адаптуються до інтенсивності тренування
- Години сну: 9 год для 'needs_rest', 8.5 год в інших випадках
- Додаткові попередження, коли статус 'needs_rest'

**Помилки:**
- `400`: Валідація не пройдена (відсутній userId, невірний muscleGroup)
- `404`: Користувач не знайдений (`userId === 'nonexistent'`)
- `500`: Внутрішня помилка сервера

---

## Автентифікація

### Firebase Auth → JWT Token → Backend Validation

Wellity використовує **Firebase Authentication** як основний провайдер ідентифікації. Потік автентифікації працює наступним чином:

```
1. Вхід користувача (Flutter Client)
   ↓
2. Firebase Auth (перевіряє облікові дані)
   ↓
3. Firebase повертає JWT токен
   ↓
4. Flutter зберігає токен безпечно
   ↓
5. API запити включають токен в заголовку Authorization
   ↓
6. Custom Backend валідує JWT токен
   ↓
7. Backend обробляє запит з контекстом користувача
```

### Поточний статус реалізації

**⚠️ Валідація JWT: Mock реалізація**

Поточна реалізація backend включає **mock endpoints** для розробки та тестування. Валідація JWT токенів буде реалізована в майбутніх ітераціях.

**Поточна поведінка:**
- Усі endpoints приймають запити без валідації токенів
- Mock перевірки існування ресурсів (наприклад, `id === 'nonexistent'`)
- Справжня автентифікація буде додана перед production deployment

**Формат заголовка Authorization:**
```
Authorization: Bearer <firebase-jwt-token>
```

**Майбутня реалізація:**
- Firebase Admin SDK буде перевіряти JWT токени
- Middleware валідації токенів витягне ID користувача та роль
- Role-based access control (RBAC) для endpoints тренерів/адміністраторів

**Міркування безпеки:**
- Вся комунікація API використовує HTTPS (SEC-002)
- Паролі Firebase хешуються з SHA-256 (SEC-001)
- Обробка платежів відповідає стандартам PCI DSS (SEC-004)

---

## Обробка помилок

### HTTP статус коди

API використовує стандартні HTTP статус коди для позначення успіху або невдачі запитів:

| Код | Значення | Використання |
|-----|----------|--------------|
| **200** | OK | Успішний запит з відповіддю |
| **400** | Bad Request | Валідація не пройдена, невірні параметри |
| **402** | Payment Required | Обробка платежу не вдалася |
| **403** | Forbidden | Недостатньо прав доступу |
| **404** | Not Found | Ресурс не існує |
| **500** | Internal Server Error | Неочікувана помилка сервера |

### Формат відповіді з помилкою

Усі відповіді з помилками мають консистентну JSON структуру:

```json
{
  "error": "Тип або категорія помилки",
  "message": "Людиночитабельний опис помилки"
}
```

### Приклади помилок

#### 400 - Помилка валідації
```json
{
  "error": "Validation failed",
  "details": [
    {
      "msg": "userRating must be between 1 and 5",
      "param": "userRating",
      "location": "body",
      "value": 6
    },
    {
      "msg": "userId is required",
      "param": "userId",
      "location": "body"
    }
  ]
}
```

#### 402 - Платіж не вдався
```json
{
  "error": "Payment failed",
  "message": "Payment could not be processed. Please check your payment details.",
  "paymentMethod": "stripe"
}
```

#### 404 - Ресурс не знайдено
```json
{
  "error": "User not found",
  "message": "The specified user does not exist in the system"
}
```

#### 500 - Внутрішня помилка сервера
```json
{
  "error": "Internal server error",
  "message": "Failed to generate workout recommendation"
}
```

### Найкращі практики обробки помилок

1. **Try-Catch блоки:** Усі обробники маршрутів обгорнуті в try-catch блоки
2. **Логування помилок:** Помилки сервера логуються з `console.error()` для налагодження
3. **Зрозумілі повідомлення:** Повідомлення про помилки чіткі та дієві
4. **Валідація спочатку:** Валідація запиту відбувається перед бізнес-логікою
5. **Консистентний формат:** Усі помилки мають однакову JSON структуру

---

## Валідація

### Стратегія валідації

API використовує **express-validator** з централізованим middleware `validateRequest` для консистентної валідації всіх endpoints.

### Middleware валідації

**Розташування:** `src/backend/middleware/validateRequest.js`

```javascript
const { validationResult } = require('express-validator');

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }
  next();
};

module.exports = validateRequest;
```

### Правила валідації за endpoints

#### Адаптивні рекомендації
```javascript
body('userId').notEmpty()
body('previousWorkoutId').notEmpty()
body('userRating').isInt({ min: 1, max: 5 })
```

#### Підписка на платіж
```javascript
body('userId').notEmpty()
body('workoutId').notEmpty()
body('paymentMethod').isIn(['stripe', 'paypal'])
```

#### Аналітика тренерів
```javascript
param('id').notEmpty()
query('period').optional().isIn(['week', 'month', 'quarter', 'year'])
```

#### Верифікація тренувань
```javascript
param('id').notEmpty()
body('verifiedBy').notEmpty()
```

#### Рекомендації з відновлення
```javascript
query('userId').notEmpty()
```

### Можливості валідації

- ✅ **Перевірка типів:** Забезпечує правильні типи даних (string, integer, boolean)
- ✅ **Валідація діапазону:** Застосовує мін/макс значення (напр., userRating: 1-5)
- ✅ **Валідація enum:** Обмежує до дозволених значень (напр., paymentMethod)
- ✅ **Обов'язкові поля:** Перевіряє наявність обов'язкових параметрів
- ✅ **Опціональні поля:** Дозволяє опціональні параметри з валідацією при наявності
- ✅ **Детальні помилки:** Повертає конкретні помилки валідації для кожного поля

---

## Пов'язана документація

- [High-Level Architecture Design](../architecture/high-level-design.md)
- [ADR-001: Архітектурний стиль](../decisions/ADR-001-architecture-style.md)
- [ADR-003: Дизайн API](../decisions/ADR-003-api-design.md)
- [Специфікація вимог](../requirements/requirements.md)
- [Матриця трасування](../requirements/traceability-matrix.md)

---

**Версія документа:** 1.0
**Остання оновлення:** 2025-10-13
**Підтримується:** Команда розробки Backend
