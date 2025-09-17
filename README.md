# Team BadHabits — Wellity

## Команда

- **Супроводжувач репозиторію**: Дмитро (GitHub: @AvdieienkoDmytro, електронна пошта НаУКМА: d.avdieienko@ukma.edu.ua)
- **Супроводжувач CI**: Андрій (GitHub: @kepeld, електронна пошта НаУКМА: a.kozin@ukma.edu.ua)
- **Керівник документації**: Дарина (GitHub: @dahl1a-bloom, електронна пошта НаУКМА: d.savarina@ukma.edu.ua)
- **Керівник трекера завдань**: Андрій (GitHub: @kepeld, електронна пошта НаУКМА: a.kozin@ukma.edu.ua)

## Опис проєкту

Wellity – застосунок, який допомагає користувачам відстежувати свої звички, формувати корисні щоденні ритуали та візуалізувати прогрес через інтерактивний календар. Він забезпечує соціальну взаємодію та обмін досягненнями між користувачами, підтримуючи мотивацію та стимулюючи регулярне виконання завдань.

Назва Wellity походить від поєднання слів "wellness" (здоров’я, гарний стан) та "activity" (активність), що підкреслює головну мету розробників застосунку – створити інтерактивний та кросплатформенний простір, котрий допомагає користувачам підтримувати активний та здоровий спосіб життя.

## Технології

- Backend: [TBD]
- Frontend: Flutter
- Database: [TBD]
- CI/CD: GitHub Actions

## Робочий процес (GitHub Flow)

1. **Основна гілка**: `main` - завжди стабільна і готова до розгортання
2. **Feature гілки**: `feature/feature-name` для нових функцій
3. **Bug fix гілки**: `fix/bug-name` для виправлень
4. **Усі зміни через Pull Requests** з обов'язковим code review
5. **Мінімум 1 схвалення** для злиття PR

### Конвенції назв гілок:
- `feature/user-authentication`
- `feature/product-catalog`
- `fix/login-validation`
- `docs/api-documentation`
- `refactor/database-schema`

### Правила комітів:
- Використовуйте англійську мову
- Формат: `<type>: <description>`
- Приклади:
  - `feat: add user registration endpoint`
  - `fix: resolve login validation issue`
  - `docs: update API documentation`
  - `refactor: simplify database queries`

## Структура проєкту

```bash
team-badhabits/
├── .github/
│   ├── workflows/
│   │   └── ci.yml
│   └── pull_request_template.md
├── src/
│   ├── backend/
│   ├── frontend/
│   └── shared/
├── docs/
├── tests/
├── README.md
├── TeamCharter.md
└── Project-Description.md
```

## Команди Git для розробки
```bash
# Створення нової feature гілки
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# Робота з змінами
git add .
git commit -m "feat: add your feature description"
git push origin feature/your-feature-name

# Після злиття PR - очищення
git checkout main
git pull origin main
git branch -d feature/your-feature-name
```