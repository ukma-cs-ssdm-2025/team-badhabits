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
import 'package:frontend/firebase_options.dart';
import 'package:frontend/shared/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependency injection
  await di.init();

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
