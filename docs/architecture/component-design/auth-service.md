# Authentication Service

## Інтерфейс: Flutter → Firebase Auth

**Протокол:** Firebase SDK (HTTPS)

**Операції:**

### Реєстрація
```
Input: email, password
Output: userId, JWT token
Validation: email format, password ≥8 символів
```

### Вхід
```
Input: email, password
Output: JWT token
Session: 24 години (SEC-003)
```

### Отримання токена
```
Output: JWT token для Backend API
Refresh: автоматично Firebase SDK
```

---

## Інтерфейс: Flutter → Custom Backend

**Протокол:** REST API (HTTPS)

**Authentication:**
```
Authorization: Bearer {JWT_TOKEN}
```
**Всі endpoints вимагають валідний JWT токен**

---

## Інтерфейс: Backend → Firebase

**Протокол:** Firebase Admin SDK

**Операція:** верифікація JWT токена
```
Input: token з header
Output: userId або 401 Unauthorized
```

---

## Ролі

**Типи:**
- user: базовий користувач
- trainer: може створювати workouts

**Перевірка:** читання з /users/{userId}/role

---

## Вимоги
- FR-001: Реєстрація та автентифікація
- SEC-001: SHA-256 шифрування (Firebase default)
- SEC-002: HTTPS only
- SEC-003: Session timeout ≤24 год