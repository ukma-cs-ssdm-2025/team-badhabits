# Аналіз надійності системи

Цей документ містить критичні проблеми надійності, виявлені в кодовій базі Wellity, та запропоновані рішення.

---

## Проблема #1: HTTP запит без timeout

**Локація:** `lib/features/workouts/data/datasources/workouts_api_datasource.dart:33`  
**Категорія:** Зовнішні залежності  
**Критичність:** **ВИСОКА**

### Поточний код:
```dart
final response = await client.post(
  url,
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({...}),
);
```

### Аналіз проблеми:
- **Fault:** Відсутній timeout для HTTP POST запиту до Railway backend
- **Error:** Request висить необмежено довго при повільній мережі
- **Failure:** Заморожений UI - користувач бачить застиглий екран, додаток виглядає зависшим

### Запропоноване рішення:
```dart
try {
  final response = await client.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({...}),
  ).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      print('ERROR: Railway API timeout for user $userId');
      throw const ServerException('Request timeout. Please try again.');
    },
  );
  
  if (response.statusCode != 200) {
    print('ERROR: API returned ${response.statusCode}');
    throw const ServerException('Failed to get recommendation');
  }
  
  return WorkoutModel.fromJson(jsonDecode(response.body));
  
} on TimeoutException catch (e) {
  print('ERROR: Network timeout - $e');
  throw const ServerException('Connection timeout. Check your internet.');
} catch (e) {
  print('ERROR: Unexpected error: $e');
  throw const ServerException('Network error. Unable to connect.');
}
```

### Застосовані патерни:
- Timeout (10 секунд)
- Guard Clause (перевірка status code)
- Specific Exception Handling
- Детальне логування
- User-friendly повідомлення про помилки

---

## Проблема #2: Витік внутрішніх деталей через широкий catch

**Локація:** `lib/features/auth/data/repositories/auth_repository_impl.dart:26,46,56,66`  
**Категорія:** Обробка помилок  
**Критичність:** **ВИСОКА**

### Поточний код:
```dart
@override
Future<Either<Failure, UserEntity>> signIn({
  required String email,
  required String password,
}) async {
  try {
    final user = await remoteDataSource.signIn(email: email, password: password);
    return Right(user);
  } catch (e) {
    return Left(ServerFailure(e.toString())); // витік деталей!
  }
}
```

### Аналіз проблеми:
- **Fault:** Широкий `catch (e)` передає `e.toString()` з технічними деталями користувачу
- **Error:** Користувач бачить технічні повідомлення типу "FirebaseAuthException: [firebase_auth/user-not-found]..."
- **Failure:** Проблема безпеки (розкриття внутрішньої архітектури), незрозумілі повідомлення

### Запропоноване рішення:
```dart
@override
Future<Either<Failure, UserEntity>> signIn({
  required String email,
  required String password,
}) async {
  try {
    if (email.isEmpty || password.isEmpty) {
      return const Left(AuthFailure('Будь ласка, введіть email та пароль'));
    }
    
    final user = await remoteDataSource.signIn(email: email, password: password);
    print('INFO: User signed in: ${user.uid}');
    return Right(user);
    
  } on FirebaseAuthException catch (e) {
    print('ERROR: FirebaseAuth error: ${e.code} - ${e.message}');
    
    String userMessage;
    switch (e.code) {
      case 'user-not-found':
        userMessage = 'Користувача з таким email не знайдено';
      case 'wrong-password':
        userMessage = 'Невірний пароль';
      case 'invalid-email':
        userMessage = 'Невірний формат email';
      case 'too-many-requests':
        userMessage = 'Занадто багато спроб. Спробуйте пізніше';
      default:
        userMessage = 'Помилка входу. Спробуйте ще раз';
    }
    return Left(AuthFailure(userMessage));
    
  } catch (e) {
    print('ERROR: Unexpected error in signIn: $e');
    return const Left(AuthFailure('Помилка з\'єднання. Спробуйте пізніше.'));
  }
}
```

### Застосовані патерни:
- Specific Exception Handling (окрема обробка Firebase помилок)
- Error Code Mapping (маппінг на зрозумілі повідомлення)
- Guard Clause (валідація порожніх полів)
- Information Hiding (технічні деталі тільки в логах)

---

## Проблема #3: Порожній userId без обробки помилки

**Локація:** `lib/features/habits/data/repositories/habits_repository_impl.dart:143`  
**Категорія:** Валідація даних  
**Критичність:** **ВИСОКА**

### Поточний код:
```dart
final habit = await localDataSource.getCachedHabit(habitId);
final userId = habit?.userId ?? '';  // порожній userId!

final hiveEntry = HabitEntryHiveModel.fromEntity(
  habitId: habitId,
  userId: userId,  // використовуємо '' як fallback
  entry: entry,
);
await localDataSource.cacheEntry(hiveEntry);
```

### Аналіз проблеми:
- **Fault:** Fallback на порожній string замість помилки при відсутності userId
- **Error:** Entry зберігається з `userId = ''` в локальному кеші
- **Failure:** Втрата даних - entries не синхронізуються з сервером, користувач втрачає прогрес

### Запропоноване рішення:
```dart
final habit = await localDataSource.getCachedHabit(habitId);

if (habit == null) {
  print('ERROR: Habit not found in cache: $habitId');
  return const Left(CacheFailure('Habit not found. Please sync first.'));
}

if (habit.userId.isEmpty) {
  print('ERROR: Empty userId for habit $habitId');
  return const Left(DataIntegrityFailure('Invalid user data. Please re-login.'));
}

final userId = habit.userId;
print('INFO: Adding entry for habit $habitId, user $userId');

final hiveEntry = HabitEntryHiveModel.fromEntity(
  habitId: habitId,
  userId: userId,  // тепер гарантовано валідний
  entry: entry,
);

await localDataSource.cacheEntry(hiveEntry);
```

### Застосовані патерни:
- Guard Clause (перевірка null та порожнього userId)
- Fail-Fast (зупинка виконання при некоректних даних)
- Детальне логування з контекстом
- Actionable error messages

---

## Проблема #4: Відсутня валідація полів звички

**Локація:** `lib/features/habits/presentation/pages/create_edit_habit_page.dart:318-330`  
**Категорія:** Валідація даних  
**Критичність:** **ВИСОКА**

### Поточний код:
```dart
final habitFields = _fields
    .map((field) => HabitField(
          type: field.type,
          label: field.labelController.text.trim(),  // немає валідації!
          unit: field.unitController.text.trim(),
        ))
    .toList();

final habit = Habit(
  name: _nameController.text.trim(),
  fields: habitFields,  // зберігаємо без перевірок
);
```

### Аналіз проблеми:
- **Fault:** Відсутня валідація: порожні назви, дублікати, некоректні символи
- **Error:** Звичка з некоректними полями зберігається в Firestore
- **Failure:** UI показує зламані звички, можливі crashes при додаванні записів

### Запропоноване рішення:
```dart
String? _validateHabitFields(List<_HabitFieldState> fields) {
  if (fields.isEmpty) {
    return 'Додайте хоча б одне поле';
  }
  
  final seenLabels = <String>{};
  
  for (var i = 0; i < fields.length; i++) {
    final label = fields[i].labelController.text.trim();
    
    if (label.isEmpty) {
      return 'Поле #${i + 1}: назва не може бути порожньою';
    }
    
    if (label.length > 50) {
      return 'Поле #${i + 1}: назва занадто довга (макс. 50 символів)';
    }
    
    if (seenLabels.contains(label.toLowerCase())) {
      return 'Дублікат назви: "$label"';
    }
    seenLabels.add(label.toLowerCase());
  }
  
  return null;
}

// У методі збереження:
final fieldsError = _validateHabitFields(_fields);
if (fieldsError != null) {
  print('ERROR: Validation failed: $fieldsError');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(fieldsError), backgroundColor: Colors.red),
  );
  return;
}

final habitFields = _fields.map(...).toList();
```

### Застосовані патерни:
- Extract Method (винесення валідації)
- Guard Clause (перевірки на кожному кроці)
- Data Validation (порожні значення, довжина, дублікати)
- User-friendly повідомлення з номером поля
- Fail-Fast

---

## Проблема #5: Оновлення профілю без транзакції

**Локація:** `lib/features/profile/data/datasources/profile_remote_data_source.dart:74,77`  
**Категорія:** Конкурентний доступ  
**Критичність:** **ВИСОКА**

### Поточний код:
```dart
@override
Future<UserModel> updateUserProfile({
  required String userId,
  String? name,
  String? avatarUrl,
}) async {
  final updateData = <String, dynamic>{};
  if (name != null) updateData['name'] = name;
  if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
  
  // Дві окремі операції без транзакції!
  await firestore.collection('users').doc(userId).update(updateData);  // line 74
  final userDoc = await firestore.collection('users').doc(userId).get();  // line 77
  return UserModel.fromFirestore(userDoc);
}
```

### Аналіз проблеми:
- **Fault:** Update та Get виконуються окремо без транзакції
- **Error:** Race condition - між операціями може статися інший update або збій мережі
- **Failure:** UI показує застарілі дані, concurrent updates можуть бути втрачені

### Запропоноване рішення:
```dart
@override
Future<UserModel> updateUserProfile({
  required String userId,
  String? name,
  String? avatarUrl,
}) async {
  if (userId.isEmpty) {
    throw const ValidationException('Invalid user ID');
  }
  
  final updateData = <String, dynamic>{};
  if (name != null && name.trim().isNotEmpty) {
    updateData['name'] = name.trim();
  }
  if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;
  
  if (updateData.isEmpty) {
    throw const ValidationException('No fields to update');
  }
  
  updateData['updatedAt'] = FieldValue.serverTimestamp();
  print('INFO: Updating profile for $userId');
  
  // Атомарна операція в транзакції
  return await firestore.runTransaction<UserModel>((transaction) async {
    final docRef = firestore.collection('users').doc(userId);
    final snapshot = await transaction.get(docRef);
    
    if (!snapshot.exists) {
      throw const NotFoundException('User not found');
    }
    
    transaction.update(docRef, updateData);
    
    return UserModel.fromJson({
      ...snapshot.data() ?? {},
      ...updateData,
    });
  }).timeout(const Duration(seconds: 15));
}
```

### Застосовані патерни:
- Transaction (атомарна операція)
- Guard Clause (валідація вхідних даних)
- Timeout (15 секунд)
- Data Validation (trim, перевірка на порожні значення)
- Read-after-write в одній транзакції

---

## Підсумок аналізу

**Виявлено критичних проблем:** 5  

**Розподіл за категоріями:**
- Обробка помилок: 1
- Зовнішні залежності: 1
- Валідація даних: 2
- Конкурентний доступ: 1

**Застосовані resilience patterns:**
- Timeout (3 проблеми)
- Guard Clause (5 проблем)
- Specific Exception Handling (5 проблем)
- Детальне логування (5 проблем)
- User-friendly повідомлення (5 проблем)
- Data Validation (3 проблеми)
- Transaction (1 проблема)
- Fail-Fast (2 проблеми)