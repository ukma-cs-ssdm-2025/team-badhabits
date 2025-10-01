# Notification Service

## Інтерфейс: Flutter → FCM

**Протокол:** Firebase SDK

**Операції:**

### Реєстрація пристрою
```
Output: FCM token
Зберігається в: /users/{userId}/fcmToken
```

### Отримання сповіщень
```
Protocol: Push notification
Format: {title: string, body: string, data: object}
```

### Обробка натискання
```
Input: notification data
Action: навігація до відповідного екрану
```

---

## Інтерфейс: Backend → FCM

**Протокол:** Firebase Admin SDK

**Операція:** відправка push-сповіщення

**Input:**
- userId
- title: string
- body: string
- data: optional object

**Trigger events:**
- Успішна оплата
- Верифікація workout
- Досягнення (badges)

---

## Типи сповіщень

**Local (Flutter):**
- Daily habit reminders
- Scheduled workout reminders

**Server-sent (Backend):**
- Payment confirmations
- Verification notifications
- Achievement unlocks

---

## Вимоги
- FR-010: Push-сповіщення
- PERF-001: Delivery ≤1s