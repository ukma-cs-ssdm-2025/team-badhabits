import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection_container.dart' as di;
import 'package:frontend/core/network/network_info.dart';
import 'package:frontend/features/habits/data/services/habit_sync_service.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_bloc.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_event.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_state.dart';
import 'package:frontend/features/habits/presentation/pages/create_edit_habit_page.dart';
import 'package:frontend/features/habits/presentation/pages/habit_tracking_with_stats_page.dart';
import 'package:frontend/features/habits/presentation/pages/habits_onboarding_page.dart';
import 'package:frontend/features/habits/presentation/widgets/habit_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main habits page showing list of user's habits
class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    // Get current user ID from FirebaseAuth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      userId = '';
    } else {
      userId = currentUser.uid;
    }

    // Check if this is the first launch and show onboarding
    unawaited(_checkFirstLaunch());
  }

  /// Check if user has seen onboarding and show it if needed
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('habits_onboarding_seen') ?? false;

    if (!hasSeenOnboarding && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => const HabitsOnboardingPage(),
            ),
          ).then((_) async {
            await prefs.setBool('habits_onboarding_seen', true);
          }),
        );
      });
    }
  }

  /// Show confirmation dialog before deleting habit
  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String habitName,
  ) async =>
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete habit?'),
          content: Text(
            'Are you sure you want to delete "$habitName"? All tracking data will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  /// Build empty state widget
  Widget _buildEmptyState(BuildContext context) => SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.track_changes,
                size: 120,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 32),
              Text(
                'No habits yet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start building better habits by creating your first one!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  // Get BLoC reference before navigation
                  final habitsBloc = context.read<HabitsBloc>();

                  // Navigate to CreateEditHabitPage in create mode
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => di.sl<HabitsBloc>(),
                        child: const CreateEditHabitPage(),
                      ),
                    ),
                  );

                  // Reload if habit was saved
                  if ((result ?? false) && mounted) {
                    habitsBloc.add(LoadHabitsEvent(userId));
                  }
                },
                icon: const Icon(Icons.add, size: 24),
                label: const Text('Create Your First Habit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('habits_onboarding_seen', false);
                  if (!mounted) {
                    return;
                  }
                  unawaited(
                    navigator.push<void>(
                      MaterialPageRoute(
                        builder: (_) => const HabitsOnboardingPage(),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                icon: const Icon(Icons.info_outline),
                label: const Text('View Tutorial'),
              ),
            ],
          ),
        ),
      ),
    );

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          'Loading error',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            context.read<HabitsBloc>().add(LoadHabitsEvent(userId));
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    ),
  );

  /// Build offline banner widget
  Widget _buildOfflineBanner(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.orange.shade100,
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 20, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Offline mode - Changes will sync when online',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );

  /// Manually trigger sync
  Future<void> _manualSync(BuildContext context) async {
    final syncService = di.sl<HabitSyncService>();
    final messenger = ScaffoldMessenger.of(context);
    final habitsBloc = context.read<HabitsBloc>();

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Syncing...'),
        duration: Duration(seconds: 1),
      ),
    );

    final success = await syncService.forceSyncNow();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Sync completed successfully!' : 'No internet connection',
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Reload habits after sync
    if (success && mounted) {
      habitsBloc.add(LoadHabitsEvent(userId));
    }
  }

  /// Build habits list widget
  Widget _buildHabitsList(BuildContext context, List<Habit> habits) =>
      RefreshIndicator(
        onRefresh: () async {
          context.read<HabitsBloc>().add(LoadHabitsEvent(userId));
          // Wait a bit for the bloc to process
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return HabitCard(
              habit: habit,
              onTap: () async {
                // Get BLoC reference before navigation
                final habitsBloc = context.read<HabitsBloc>();

                // Navigate to HabitTrackingWithStatsPage using existing BLoC
                await Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: habitsBloc,
                      child: HabitTrackingWithStatsPage(habit: habit),
                    ),
                  ),
                );

                // Reload habits after returning
                if (mounted) {
                  habitsBloc.add(LoadHabitsEvent(userId));
                }
              },
              onEdit: () async {
                // Get BLoC and messenger references before navigation
                final habitsBloc = context.read<HabitsBloc>();

                // Navigate to CreateEditHabitPage in edit mode
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => di.sl<HabitsBloc>(),
                      child: CreateEditHabitPage(habit: habit),
                    ),
                  ),
                );

                // Reload if habit was saved
                if ((result ?? false) && mounted) {
                  habitsBloc.add(LoadHabitsEvent(userId));
                }
              },
              onDelete: () async {
                // Get references before async gap
                final habitsBloc = context.read<HabitsBloc>();
                final messenger = ScaffoldMessenger.of(context);

                final confirmed = await _showDeleteConfirmation(
                  context,
                  habit.name,
                );

                if ((confirmed ?? false) && mounted) {
                  // Delete the habit
                  habitsBloc.add(DeleteHabitEvent(habit.id));

                  // Show confirmation message
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('${habit.name} deleted'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(
                        bottom: 80,
                        left: 16,
                        right: 16,
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Handle unauthenticated user
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habits')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    final networkInfo = di.sl<NetworkInfo>();

    return BlocProvider(
      create: (context) => di.sl<HabitsBloc>()..add(LoadHabitsEvent(userId)),
      child: Builder(
        builder: (context) => StreamBuilder<bool>(
          stream: networkInfo.onConnectivityChanged,
          initialData: true,
          builder: (context, snapshot) {
            final isOnline = snapshot.data ?? true;

            return Scaffold(
              appBar: AppBar(
                title: const Text('My Habits'),
                actions: [
                  if (!isOnline)
                    Icon(Icons.cloud_off, color: Colors.orange.shade700),
                  IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: 'Sync now',
                    onPressed: () => _manualSync(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'About Habits',
                    onPressed: () {
                      unawaited(
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('About Habits'),
                            content: const Text(
                              'Track your daily habits with custom fields. '
                              'Create habits with number tracking (e.g., water intake), '
                              'rating scales (e.g., mood), or text notes.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  if (!isOnline) _buildOfflineBanner(context),
                  Expanded(
                    child: BlocConsumer<HabitsBloc, HabitsState>(
            listener: (context, state) {
              // Handle errors with snackbar
              if (state is HabitsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              // HabitsInitial and HabitsLoading states
              if (state is HabitsInitial || state is HabitsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // HabitsLoaded state
              if (state is HabitsLoaded) {
                if (state.habits.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildHabitsList(context, state.habits);
              }

              // HabitsError state
              if (state is HabitsError) {
                return _buildErrorState(context, state.message);
              }

              // Unknown state
              return const Center(child: Text('Unknown state'));
            },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                heroTag: 'habits_fab',
                onPressed: () async {
                  // Get BLoC reference before navigation
                  final habitsBloc = context.read<HabitsBloc>();

                  // Navigate to CreateEditHabitPage in create mode
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => di.sl<HabitsBloc>(),
                        child: const CreateEditHabitPage(),
                      ),
                    ),
                  );

                  // Reload if habit was saved
                  if ((result ?? false) && mounted) {
                    habitsBloc.add(LoadHabitsEvent(userId));
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('New Habit'),
              ),
            );
          },
        ),
      ),
    );
  }
}
