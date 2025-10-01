# Quality Attribute Scenarios (QAS)

## PERF-001: Час відповіді для фіксації habit trackers ≤ 1с

- **Source of Stimulus:** Користувач
- **Stimulus:** Користувач натискає кнопку “Завершити habit tracker”
- **Environment:** Нормальне навантаження (≤ 1000 одночасних користувачів)
- **Artifact:** HabitTracker Service, Firestore, Realtime Database
- **Response:** Система зберігає дані у БД і підтверджує дію користувачу
- **Response Measure:** Відповідь на пристрій ≤ 1 сек

**How architecture addresses it:**  
Firestore з індексацією та Realtime Database забезпечують низьку латентність. Кешування та offline-first дозволяють швидко відповідати навіть при нестабільному з’єднанні.

---

## REL-004: Синхронізація workout session між пристроями ≤ 2с

- **Source of Stimulus:** Користувач, що відкриває свій акаунт на другому пристрої
- **Stimulus:** Внесення змін у активну workout session
- **Environment:** Середнє навантаження (≤ 5000 активних користувачів)
- **Artifact:** Realtime Database, Flutter App
- **Response:** Дані про сесію передаються на всі підключені пристрої
- **Response Measure:** Затримка синхронізації ≤ 2 секунди

**How architecture addresses it:**  
WebSocket у Firebase Realtime Database гарантує push-синхронізацію з мінімальною затримкою. Offline-first дозволяє синхронізувати зміни після відновлення з’єднання.

---

## SEC-002: Безпечна передача персональних даних

- **Source of Stimulus:** Користувач, що входить у систему
- **Stimulus:** Передача email/пароля до Auth Service
- **Environment:** Нормальне навантаження, використання публічної Wi-Fi мережі
- **Artifact:** Auth Service, Firebase Auth
- **Response:** Дані передаються через зашифроване HTTPS-з’єднання
- **Response Measure:** Відсутність витоку даних при мережевому моніторингу

**How architecture addresses it:**  
Використання TLS 1.2+ у всіх з’єднаннях, інтеграція з Firebase Auth. JWT токени зберігають безпечну ідентифікацію без повторної передачі паролів.

---

## USAB-001: Онбординг ≤ 5 хв

- **Source of Stimulus:** Новий користувач
- **Stimulus:** Встановлення та перший запуск застосунку
- **Environment:** Мінімальні системні вимоги (iOS 14.0+, Android 7.0)
- **Artifact:** Flutter App (UI, онбординг-процес)
- **Response:** Користувач створює акаунт, перший habit tracker або тренування
- **Response Measure:** Успішне завершення ≤ 5 хв

**How architecture addresses it:**  
Інтуїтивний UI у Flutter, готові шаблони habit trackers, швидка автентифікація через Firebase Auth мінімізують час першого налаштування.

---

## COMP-001: Єдина функціональність на iOS та Android

- **Source of Stimulus:** Користувач застосунку
- **Stimulus:** Використання основних функцій (habit trackers, тренування, статистика)
- **Environment:** Мобільні пристрої iOS 14.0+ та Android 7.0+
- **Artifact:** Flutter App
- **Response:** Користувач отримує однаковий набір функцій та узгоджений UI незалежно від платформи
- **Response Measure:** Відсутність відмінностей у функціоналі та інтерфейсі між платформами при тестуванні

**How architecture addresses it:**  
Flutter забезпечує єдину кодову базу, що гарантує однакову бізнес-логіку та UI на iOS і Android.