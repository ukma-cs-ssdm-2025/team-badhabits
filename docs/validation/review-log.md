# Review Log - Peer Review Тест-Плану

## Наша Рефлексія

### Внесені Зміни

1. **Зміна:** Виправлено баг з редагуванням профілю

   **Чому:** ProfileBloc створювався без ініціалізації стану, використовувався антипатерн з вкладеним BlocProvider, і виникала помилка type cast при роботі з Firestore timestamp.

   **Виправлення:**
   - ProfileBloc тепер ініціалізується з завантаженням профілю в `main_navigation.dart`
   - Видалено вкладений BlocProvider у `profile_page.dart`
   - Замінено Firestore transaction на update + read у `profile_remote_data_source.dart`
   - Додано безпечну обробку типів для поля `createdAt` у `user_model.dart`

---

**Дата оновлення:** 09.12.2025
