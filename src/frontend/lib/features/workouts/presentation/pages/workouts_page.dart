import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection_container.dart' as di;
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_bloc.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_event.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_state.dart';

/// Workouts page showing list of personalized workouts
class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  late final String userId;

  // Filters for US-005
  int? _selectedDuration; // 15, 30, 45 minutes
  String? _selectedDifficulty; // beginner, intermediate, advanced
  List<String> _selectedEquipment = []; // dumbbells, resistance_bands, etc.

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
  }

  /// Apply filters (US-005)
  void _applyFilters(BuildContext context) {
    context.read<WorkoutsBloc>().add(FilterWorkouts(
          duration: _selectedDuration,
          difficulty: _selectedDifficulty,
          equipment: _selectedEquipment.isEmpty ? null : _selectedEquipment,
        ));
  }

  /// Clear all filters
  void _clearFilters(BuildContext context) {
    setState(() {
      _selectedDuration = null;
      _selectedDifficulty = null;
      _selectedEquipment = [];
    });
    context.read<WorkoutsBloc>().add(const LoadWorkouts());
  }

  /// Build filter chip
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.blue.withValues(alpha: 0.3),
    );
  }

  /// Build filters section (US-005)
  Widget _buildFiltersSection(BuildContext context) {
    final hasFilters = _selectedDuration != null ||
        _selectedDifficulty != null ||
        _selectedEquipment.isNotEmpty;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (hasFilters)
                  TextButton(
                    onPressed: () => _clearFilters(context),
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Duration filters
            const Text('Duration', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: '15 min',
                  selected: _selectedDuration == 15,
                  onSelected: () {
                    setState(() => _selectedDuration = 15);
                    _applyFilters(context);
                  },
                ),
                _buildFilterChip(
                  label: '30 min',
                  selected: _selectedDuration == 30,
                  onSelected: () {
                    setState(() => _selectedDuration = 30);
                    _applyFilters(context);
                  },
                ),
                _buildFilterChip(
                  label: '45 min',
                  selected: _selectedDuration == 45,
                  onSelected: () {
                    setState(() => _selectedDuration = 45);
                    _applyFilters(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Difficulty filters
            const Text('Difficulty', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: 'Beginner',
                  selected: _selectedDifficulty == 'beginner',
                  onSelected: () {
                    setState(() => _selectedDifficulty = 'beginner');
                    _applyFilters(context);
                  },
                ),
                _buildFilterChip(
                  label: 'Intermediate',
                  selected: _selectedDifficulty == 'intermediate',
                  onSelected: () {
                    setState(() => _selectedDifficulty = 'intermediate');
                    _applyFilters(context);
                  },
                ),
                _buildFilterChip(
                  label: 'Advanced',
                  selected: _selectedDifficulty == 'advanced',
                  onSelected: () {
                    setState(() => _selectedDifficulty = 'advanced');
                    _applyFilters(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No workouts available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for personalized workouts',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
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
                context.read<WorkoutsBloc>().add(const LoadWorkouts());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );

  /// Build workout card
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to workout details page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Opening workout: ${workout.title}'),
                duration: const Duration(seconds: 1)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and verified badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (workout.isVerified)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              if (workout.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    workout.description!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Workout details
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.timer_outlined,
                    label: '${workout.durationMinutes} min',
                  ),
                  _buildInfoChip(
                    icon: Icons.fitness_center,
                    label: workout.difficulty.toUpperCase(),
                  ),
                  _buildInfoChip(
                    icon: Icons.local_fire_department,
                    label: '${workout.caloriesBurned} kcal',
                  ),
                  if (workout.exercises.isNotEmpty)
                    _buildInfoChip(
                      icon: Icons.format_list_numbered,
                      label: '${workout.exercises.length} exercises',
                    ),
                ],
              ),

              // Equipment required
              if (workout.equipmentRequired.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 4,
                    children: workout.equipmentRequired
                        .map((eq) => Chip(
                              label: Text(
                                eq.replaceAll('_', ' '),
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ),

              // Adaptive badge (FR-014)
              if (workout.isAdaptive)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_fix_high,
                            size: 14, color: Colors.purple),
                        SizedBox(width: 4),
                        Text(
                          'Adaptive',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build info chip
  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
      ],
    );
  }

  /// Build workouts list
  Widget _buildWorkoutsList(BuildContext context, List<Workout> workouts) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<WorkoutsBloc>().add(const LoadWorkouts());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: workouts.length + 1, // +1 for filters section
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFiltersSection(context);
          }
          return _buildWorkoutCard(context, workouts[index - 1]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle unauthenticated user
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workouts')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    return BlocProvider(
      create: (context) => di.sl<WorkoutsBloc>()..add(const LoadWorkouts()),
      child: Scaffold(
        body: BlocBuilder<WorkoutsBloc, WorkoutsState>(
          builder: (context, state) {
            // Loading state
            if (state is WorkoutsInitial || state is WorkoutsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Loaded state
            if (state is WorkoutsLoaded) {
              if (state.workouts.isEmpty) {
                return _buildEmptyState();
              }
              return _buildWorkoutsList(context, state.workouts);
            }

            // Filtered workouts state
            if (state is FilteredWorkoutsLoaded) {
              if (state.workouts.isEmpty) {
                return Column(
                  children: [
                    _buildFiltersSection(context),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts match filters',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => _clearFilters(context),
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return _buildWorkoutsList(context, state.workouts);
            }

            // Error state
            if (state is WorkoutsError) {
              return _buildErrorState(context, state.message);
            }

            // Unknown state
            return const Center(child: Text('Unknown state'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'workouts_fab',
          onPressed: () {
            // TODO: Check for active session (FR-013)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Workout session feature coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Workout'),
        ),
      ),
    );
  }
}
