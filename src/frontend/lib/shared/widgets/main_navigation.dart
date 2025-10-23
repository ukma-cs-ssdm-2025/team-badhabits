// ignore_for_file: deprecated_member_use, discarded_futures, inference_failure_on_instance_creation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/core/di/injection_container.dart' as di;
import 'package:frontend/core/theme/theme_cubit.dart';
import 'package:frontend/features/achievements/presentation/pages/achievements_page.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/habits/presentation/pages/habits_page.dart';
import 'package:frontend/features/notes/presentation/pages/notes_page.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/workouts/presentation/pages/workouts_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    NotesPage(),
    HabitsPage(),
    WorkoutsPage(),
    AchievementsPage(),
  ];

  final List<String> _pageTitles = const [
    'Notes',
    'Habits',
    'Workouts',
    'Achievements',
  ];

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<ProfileBloc>(),
          child: const ProfilePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_pageTitles[_currentIndex]),
      actions: [
        // Theme toggle button
        BlocBuilder<ThemeCubit, AppThemeMode>(
          builder: (context, themeMode) => IconButton(
            icon: Icon(
              themeMode == AppThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
            tooltip: themeMode == AppThemeMode.light
                ? 'Switch to dark theme'
                : 'Switch to light theme',
          ),
        ),
        // Avatar button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is! Authenticated) {
                return const SizedBox.shrink();
              }

              final user = state.user;
              final hasAvatar =
                  user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

              return GestureDetector(
                onTap: _navigateToProfile,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: hasAvatar
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: !hasAvatar
                      ? Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white.withOpacity(0.9),
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    ),
    body: IndexedStack(index: _currentIndex, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.note_alt_outlined),
          selectedIcon: Icon(Icons.note_alt),
          label: 'Notes',
        ),
        NavigationDestination(
          icon: Icon(Icons.check_circle_outline),
          selectedIcon: Icon(Icons.check_circle),
          label: 'Habits',
        ),
        NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Workouts',
        ),
        NavigationDestination(
          icon: Icon(Icons.emoji_events_outlined),
          selectedIcon: Icon(Icons.emoji_events),
          label: 'Awards',
        ),
      ],
    ),
  );
}
