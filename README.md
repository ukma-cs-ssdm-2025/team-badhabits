[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=20493604)

# Team BadHabits — Wellity <br> (Fitnes & Habits Tracker)

[![CI Test](https://github.com/ukma-cs-ssdm-2025/team-badhabits/actions/workflows/flutter-ci.yml/badge.svg?branch=main)](https://github.com/ukma-cs-ssdm-2025/team-badhabits/actions/workflows/flutter-ci.yml)

## 📄 General Docs

  - Уся документація проекту щодо реалізації програмного забезпечення: [docs](docs)

  - Окремі посилання:

    - [ProjectDescription.md](ProjectDescription.md) - опис та функціонал проекту  <br>
    
    - [TeamCharter.md](TeamCharter.md) - інформація про організацію процесів впровадження <br> та контролю співпраці, а також 
    спільного робочого середовища команди проекту
    
    - [requirements.md](docs/requirements/requirements.md) - FR & NFR проекту
    
    - [rtm.md](docs/requirements/rtm.md) - матриця простежуваності вимог проекту
    
    - [user-stories.md](docs/requirements/user-stories.md) - користувацькі історії
    
    - [architecture](docs/architecture/high-level-design.md) - загальний огляд архітектури додатку
    
    - [diagrams](docs/diagrams) - uml-представлення імплементування додатку
    
    - [decisions](docs/decisions) - записи архітектурних рішень додатку
  
    - [api](docs/api) - загальна інформація про api
    
    - [code-quality](docs/code-quality) - документування оцінки якості коду
  
    - [testing](docs/testing) - документування тестування

## ▶️ Запуск проекту

- Остання верісія apk проекту: [latest_android_apk](latest_android_apk)

- Інструкцію, як локально запустити проект на комп'ютері, можна знайти ось тут:  [setup](src\frontend\SETUP.md).

## 🚀 Production Deployment

**Backend API:** [https://wellity-backend-production.up.railway.app](https://wellity-backend-production.up.railway.app)

**API Documentation:** [https://wellity-backend-production.up.railway.app/api-docs](https://wellity-backend-production.up.railway.app/api-docs)

**Platform:** Railway.app | **Region:** Europe West | **Status:** ✅ Always On

[deployment documentation](docs/deployment/railway-deployment.md)

## 🕸️ Структура проєкту

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
│   ├── api/
│   ├── architecture/
│   ├── code-quality/
│   ├── decisions/
│   ├── deployment/
│   ├── diagrams/
│   ├── requirements/
│   ├── testing/
│   ├── RELEASES.md
│   └── index.html
├── tests/
├── Labs/
├── .gitignore
├── .railwayignore
├── CHANGELOG.md
├── ProjectDescription.md
├── README.md
├── TeamCharter.md
├── firestore.rules
└── railway.json
```

## 📞 Контакти команди авторів проекту:
- Андрій (GitHub: @kepeld)
- Дарина (GitHub: @dahl1a-bloom)
- Давид (GitHub: @DavydKod)
- Дмитро (GitHub: @AvdieienkoDmytro)
