# Інструкція із запуску проєкту

Цей документ описує як налаштувати середовище розробки та запустити Flutter додаток на різних платформах.

---

## Передумови

### Загальні вимоги
- **Flutter SDK** версії 3.9.2 або новіше
- **Dart SDK** (входить до складу Flutter)
- **Git** для клонування репозиторію

### Перевірка встановлення Flutter
```bash
flutter --version
flutter doctor
```

Команда `flutter doctor` покаже які компоненти встановлені та які потребують налаштування.

---

## Налаштування для Windows

### Варіант 1: Visual Studio Code

**Встановлення:**
1. Встановити [Visual Studio Code](https://code.visualstudio.com/)
2. Встановити розширення Flutter та Dart з Marketplace
3. Встановити [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
4. Додати Flutter до PATH (зазвичай `C:\src\flutter\bin`)

**Для Android розробки:**
1. Встановити [Android Studio](https://developer.android.com/studio)
2. Встановити Android SDK через Android Studio (Tools → SDK Manager)
3. Встановити Android SDK Command-line Tools
4. Прийняти Android licenses: `flutter doctor --android-licenses`
5. Створити або підключити Android емулятор через AVD Manager

**Запуск проєкту:**
```bash
# Клонувати репозиторій
git clone <repository-url>
cd team-badhabits/src/frontend

# Встановити залежності
flutter pub get

# Перевірити підключені пристрої
flutter devices

# Запустити на Android емуляторі
flutter run

# Або вибрати конкретний пристрій
flutter run -d <device-id>
```

### Варіант 2: Android Studio

**Встановлення:**
1. Встановити [Android Studio](https://developer.android.com/studio)
2. При встановленні вибрати "Custom" та включити Android SDK, Android SDK Platform, Android Virtual Device
3. Встановити Flutter plugin (File → Settings → Plugins → Marketplace → Flutter)
4. Встановити [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
5. Налаштувати Flutter SDK path в Android Studio (File → Settings → Languages & Frameworks → Flutter)

**Запуск проєкту:**
1. Відкрити проєкт: File → Open → вибрати папку `src/frontend`
2. Почекати на завершення `flutter pub get`
3. Створити або запустити емулятор через AVD Manager (Tools → AVD Manager)
4. Натиснути зелену кнопку "Run" або Shift + F10

**Корисні поради для Windows:**
- Вимкнути антивірус під час першого запуску для прискорення build
- Переконатися що Hyper-V увімкнено для емулятора Android (Windows 10/11 Pro)
- Для Windows Home використовувати Intel HAXM або AMD Hypervisor

---

## Налаштування для macOS

### Варіант 1: Visual Studio Code

**Встановлення:**
1. Встановити [Visual Studio Code](https://code.visualstudio.com/)
2. Встановити розширення Flutter та Dart
3. Встановити Flutter SDK через homebrew або вручну:
   ```bash
   # Через homebrew
   brew install --cask flutter

   # Або завантажити з сайту
   # https://docs.flutter.dev/get-started/install/macos
   ```
4. Додати Flutter до PATH у `~/.zshrc` або `~/.bash_profile`

**Для iOS розробки:**
1. Встановити [Xcode](https://apps.apple.com/app/xcode/id497799835) з App Store
2. Встановити Xcode Command Line Tools:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```
3. Прийняти Xcode license: `sudo xcodebuild -license accept`
4. Встановити CocoaPods: `sudo gem install cocoapods`
5. Налаштувати iOS симулятор через Xcode

**Для Android розробки:**
1. Встановити [Android Studio](https://developer.android.com/studio)
2. Встановити Android SDK
3. Прийняти licenses: `flutter doctor --android-licenses`

**Запуск проєкту:**
```bash
# Клонувати репозиторій
git clone <repository-url>
cd team-badhabits/src/frontend

# Встановити залежності
flutter pub get

# Встановити iOS залежності
cd ios
pod install
cd ..

# Перевірити доступні пристрої
flutter devices

# Запустити на iOS симуляторі
flutter run -d ios

# Запустити на Android емуляторі
flutter run -d android
```

### Варіант 2: Xcode (тільки iOS)

**Встановлення:**
1. Встановити [Xcode](https://apps.apple.com/app/xcode/id497799835)
2. Встановити Flutter SDK (див. вище)
3. Налаштувати CocoaPods

**Запуск проєкту:**
```bash
# Підготувати проєкт
cd team-badhabits/src/frontend
flutter pub get
cd ios
pod install

# Відкрити у Xcode
open Runner.xcworkspace
```

У Xcode:
1. Вибрати симулятор або пристрій
2. Натиснути ▶ (Run) або Cmd + R

### Варіант 3: Android Studio на macOS

Аналогічно до Windows варіанту 2, але з додатковою можливістю iOS розробки якщо встановлено Xcode.

**Корисні поради для macOS:**
- Використовувати `flutter doctor -v` для детальної діагностики
- Для M1/M2 Mac переконатися що використовуєте ARM64 версії всіх інструментів
- Rosetta 2 може знадобитися для деяких інструментів: `softwareupdate --install-rosetta`

---

## Корисні команди

### Загальні команди
```bash
# Встановити залежності
flutter pub get

# Очистити build кеш
flutter clean

# Оновити залежності
flutter pub upgrade

# Перевірити проблеми
flutter doctor -v

# Запустити тести
flutter test

# Перевірити код на помилки
flutter analyze
```

### Запуск на різних платформах
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Конкретний емулятор
flutter run -d <device-id>

# З hot reload у debug режимі (за замовчуванням)
flutter run

# Release build для тестування
flutter run --release
```

### Build команди
```bash
# Android APK
flutter build apk

# Android App Bundle (для Google Play)
flutter build appbundle

# iOS (потребує macOS та Xcode)
flutter build ios

# iOS з archive для App Store
flutter build ipa
```

---

## Типові проблеми та рішення

### Windows

**Проблема:** `flutter doctor` показує помилку з Android licenses
```bash
flutter doctor --android-licenses
```

**Проблема:** Емулятор повільно працює
- Увімкнути Hyper-V (Windows Pro) або Intel HAXM (Windows Home)
- Збільшити RAM для емулятора в AVD Manager
- Використовувати x86_64 образ замість ARM

**Проблема:** Firebase не працює
- Перевірити наявність `google-services.json` в `android/app/`
- Запустити `flutterfire configure`

### macOS

**Проблема:** CocoaPods помилки
```bash
cd ios
pod deintegrate
pod install
cd ..
```

**Проблема:** Xcode build fails
- Очистити build: Product → Clean Build Folder (Cmd + Shift + K)
- Видалити Derived Data: Xcode → Preferences → Locations → Derived Data → стрілка → видалити папку
- Перезапустити Xcode

**Проблема:** M1/M2 Mac сумісність
```bash
# Для Intel-specific залежностей
arch -x86_64 pod install

# Або встановити Rosetta
softwareupdate --install-rosetta
```

### Загальні проблеми

**Проблема:** Залежності не встановлюються
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Проблема:** Hot reload не працює
- Перезапустити додаток натиснувши `R` в терміналі
- Або повний restart: `Shift + R`

**Проблема:** Build займає багато часу
- Додати виключення для антивіруса (папка Flutter SDK та проєкт)
- Увімкнути Gradle daemon (Android)

---

## Додаткові ресурси

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Flutter Community](https://flutter.dev/community)

---
