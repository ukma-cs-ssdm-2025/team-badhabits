import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection_container.dart' as di;
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_cubit.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/habits/data/models/habit_entry_hive_model.dart';
import 'package:frontend/features/habits/data/models/habit_field_hive_model.dart';
import 'package:frontend/features/habits/data/models/habit_hive_model.dart';
import 'package:frontend/features/habits/data/services/habit_sync_service.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/shared/widgets/main_navigation.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive
    ..registerAdapter(HabitFieldHiveModelAdapter())
    ..registerAdapter(HabitHiveModelAdapter())
    ..registerAdapter(HabitEntryHiveModelAdapter());

  // Open Hive boxes
  await Hive.openBox<HabitHiveModel>('habits');
  await Hive.openBox<HabitEntryHiveModel>('habit_entries');

  // Initialize dependency injection
  await di.init();

  // Start habit sync service
  di.sl<HabitSyncService>().startListening();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => di.sl<AuthBloc>()..add(const AuthCheckRequested()),
      ),
      BlocProvider(create: (context) => di.sl<ThemeCubit>()),
    ],
    child: BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, themeMode) => MaterialApp(
        title: 'BadHabits',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode == AppThemeMode.light
            ? ThemeMode.light
            : ThemeMode.dark,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthInitial || state is AuthLoading) {
              // Show loading screen while checking auth state
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is Authenticated) {
              // User is authenticated, show main navigation
              return const MainNavigation();
            } else {
              // User is not authenticated, show login page
              return const LoginPage();
            }
          },
        ),
      ),
    ),
  );
}
