# Code Review: Team Circus

**Reviewed Team:** Circus (Markdown Circus Docs)

**Reviewed By:** Team BadHabits (by @AvdieienkoDmytro)

**Date:** 2025-10-23

---

## Проблеми для покращення

### Безпека

- **Критично:** Паролі зберігаються у plain text без хешування (`backend/internal/handler/auth/login.go:61`).
- **Критично:** Відсутній rate limiting на authentication endpoints - можливі brute-force атаки.
- `SECRET_TOKEN` читається через `os.Getenv()` у кожному handler/middleware замість централізованої конфігурації (`backend/internal/handler/auth/login.go:67`, `backend/internal/middleware/auth.go:30`).
- Відсутня валідація формату email - перевіряється лише довжина (`backend/internal/handler/reg/requests/register.go:16`).
- Слабкі вимоги до паролів - дозволені паролі довжиною від 1 символу (`backend/internal/handler/reg/requests/register.go:17`).
- Cookie з JWT встановлюються з `secure: true`, але немає примусового HTTPS у production (`backend/internal/handler/auth/login.go:101-102`).
- API клієнт на frontend не включає `credentials: 'include'` для передачі cookies (`frontend/src/services/api.ts:20-26`).

### Якість коду

- Дублювання логіки обробки помилок у handlers - два ідентичні if блоки (`backend/internal/handler/reg/register.go:48-65`).
- Закоментований код у middleware без пояснення (`backend/internal/middleware/auth.go:79`).
- Typo у назві файлу: `entitties.go` замість `entities.go` (`backend/internal/domain/entitties.go`).

### Інструментарій

- Відсутній статичний аналіз для Go (golangci-lint, gosec).
- Не знайдено eslint конфігурацію для frontend.

---

## Позитивні аспекти

- Чітка архітектура з розділенням на layers (handler, service, repository).
- Swagger документація для API (`@Summary`, `@Description` коментарі).
- Structured logging з zap.
- Dependency injection через interfaces.
- Валідація request моделей з ozzo-validation.
- TypeScript для type safety на frontend.
- Наявність unit та functional тестів.
- Код відповідає Go conventions та використовує gofmt.