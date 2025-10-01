# Firebase Data Structures

## Firestore Collections

### /users/{userId}
**Поля:**
- email: string
- displayName: string
- role: "user" | "trainer"
- createdAt: timestamp
- subscriptions: array of workout IDs

**Доступ:** користувач може читати/писати лише свій профіль

**Вимоги:** FR-001, FR-009

---

### /workouts/{workoutId}
**Поля:**
- title: string
- trainerId: string
- exercises: array of {name, sets, reps, restSeconds}
- isVerified: boolean
- accessType: "free" | "paid" | "invite"

**Доступ:** читати всі авторизовані, писати лише trainer

**Індекси:** trainerId + accessType, isVerified

**Вимоги:** FR-011, FR-012

---

### /habitTrackers/{trackerId}
**Поля:**
- userId: string
- name: string
- fields: array of {type, label, unit}
- entries: map (date → field values)


**Типи полів:** number, rating, text

**Доступ:** лише власник

**Вимоги:** FR-002, FR-015

---

### /notes/{noteId}
**Поля:**
- userId: string
- content: string
- attachedTo: {type: "workout"|"habitTracker", id: string}
- createdAt: timestamp

**Вимоги:** FR-016, FR-017

---

## Realtime Database

### /activeSessions/{userId}
**Поля:**
- workoutId: string
- startTime: timestamp
- deviceId: string
- locked: boolean

**Призначення:** блокування паралельних workout sessions

**Синхронізація:** ≤2s між пристроями (WebSocket)

**TTL:** 3 години автоочистка

**Вимоги:** FR-013, REL-004

---

## Cloud Storage

**Структура:**
- /workouts/{workoutId}/thumbnail.jpg (max 2MB)
- /workouts/{workoutId}/video.mp4 (max 50MB)
- /users/{userId}/avatar.jpg (max 5MB)

**Доступ:** публічне читання для free workouts, запис тільки trainer