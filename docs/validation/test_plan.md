# План Тестування Wellity (Fitness & Habits Tracker)

## Мета

Забезпечити якість застосунку Wellity через структуроване тестування основних модулів: Authentication, Habits Tracking та Notes.

## Огляд Проєкту

**Технологічний стек:** Flutter, Firebase, BLoC
**Архітектура:** Clean Architecture

## План Тестування

| № | Компонент/функція | Рівень тесту | Тип | Очікуваний результат | Власник |
|:-:|-------------------|--------------|-----|----------------------|---------|
| **AUTHENTICATION** |
| 1 | SignInUseCase | Unit | Позитивний | Успішний вхід з валідними credentials (US-008) | Dev Team |
| 2 | SignInUseCase | Unit | Негативний | Помилка при невалідних credentials | Dev Team |
| 3 | SignUpUseCase | Unit | Позитивний | Успішна реєстрація (US-007) | QA Team |
| 4 | SignUpUseCase | Unit | Негативний | Помилка при існуючому email | QA Team |
| **HABITS TRACKING** |
| 5 | CreateHabitUseCase | Unit | Позитивний | Створення звички з полями (FR-002, US-009b) | Dev Team |
| 6 | AddHabitEntryUseCase | Unit | Позитивний | Додавання щоденного запису (FR-003) | QA Team |
| 7 | HabitsBloc | Integration | Позитивний | Коректна зміна станів при CRUD операціях | Dev Team |
| **UI COMPONENTS** |
| 8 | CustomButton | Widget | Позитивний | Відображення та обробка натискання | Dev Team |
| 9 | EmailTextField | Widget | Позитивний | Валідація email формату | QA Team |
| 10 | PasswordTextField | Widget | Позитивний | Валідація довжини пароля (мін 6 символів) | QA Team |
| **PERFORMANCE** |
| 11 | Habit Entry Response | Performance | Позитивний | Фіксація запису ≤ 1 сек (PERF-001) | QA Team |
| 12 | App Startup | Performance | Позитивний | Запуск ≤ 3 сек (PERF-002) | QA Team |

## Зв'язок із Вимогами

| Вимога | Тест-кейси | Статус |
|--------|------------|--------|
| US-007 (Реєстрація) | TC-3, TC-4 | ✅ Покрито |
| US-008 (Вхід) | TC-1, TC-2 | ✅ Покрито |
| US-009b (Habit Trackers) | TC-5, TC-6 | ✅ Покрито |
| FR-002 (Habit CRUD) | TC-5 | ✅ Покрито |
| FR-003 (Щоденне відстеження) | TC-6 | ✅ Покрито |
| PERF-001, PERF-002 | TC-11, TC-12 | ✅ Покрито |

## Стратегія

- **Unit Tests:** Тестування use cases з mock repositories
- **Integration Tests:** Тестування BLoC з реальними use cases
- **Widget Tests:** Перевірка UI компонентів та валідації
- **CI/CD:** Автоматичний запуск тестів при push до репозиторію

## Інструменти

- `flutter_test` - тестування
- `mockito` - мокування
- `build_runner` - генерація моків

## Критерії Прийняття

✅ Покриття ключових функцій
✅ Негативні сценарії
✅ Зв'язок із вимогами
✅ Виконуваність у CI
