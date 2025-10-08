import 'package:flutter_bloc/flutter_bloc.dart';

/// App theme mode state
enum AppThemeMode {
  light,
  dark,
}

/// Cubit for managing app theme
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit() : super(AppThemeMode.light);

  /// Toggle between light and dark theme
  void toggleTheme() {
    emit(state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light);
  }

  /// Set theme explicitly
  void setTheme(AppThemeMode mode) {
    emit(mode);
  }

  /// Check if current theme is dark
  bool get isDark => state == AppThemeMode.dark;
}
