import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/workouts/domain/entities/exercise.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_bloc.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_event.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_state.dart';
import 'package:frontend/features/workouts/presentation/pages/workout_session_page.dart';

/// Workout Details Page
///
/// Displays detailed information about a workout and allows starting a session
class WorkoutDetailsPage extends StatelessWidget {
  const WorkoutDetailsPage({required this.workout, super.key});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          // Verified badge in app bar
          if (workout.isVerified)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.verified, color: Colors.green),
            ),
        ],
      ),
      body: BlocListener<WorkoutsBloc, WorkoutsState>(
        listener: (context, state) {
          if (state is WorkoutSessionStarted) {
            // Navigate to active session page
            final workoutsBloc = context.read<WorkoutsBloc>();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) => BlocProvider.value(
                  value: workoutsBloc,
                  child: WorkoutSessionPage(session: state.session),
                ),
              ),
            );
          } else if (state is WorkoutsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and badges
              _buildHeader(context),
              const SizedBox(height: 16),

              // Description
              if (workout.description.isNotEmpty) ...[
                Text(
                  workout.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick stats
              _buildQuickStats(context),
              const SizedBox(height: 24),

              // Equipment section
              if (workout.equipmentRequired.isNotEmpty) ...[
                _buildEquipmentSection(context),
                const SizedBox(height: 24),
              ],

              // Exercises section
              _buildExercisesSection(context),
              const SizedBox(height: 24),

              // Start workout button
              _buildStartButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Verified badge
            if (workout.isVerified)
              Chip(
                avatar: const Icon(Icons.verified, size: 16, color: Colors.green),
                label: const Text('Verified'),
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                side: BorderSide.none,
              ),
            // Adaptive badge
            if (workout.isAdaptive)
              Chip(
                avatar: const Icon(Icons.auto_fix_high, size: 16, color: Colors.purple),
                label: const Text('Adaptive'),
                backgroundColor: Colors.purple.withValues(alpha: 0.1),
                side: BorderSide.none,
              ),
            // Difficulty badge
            Chip(
              label: Text(
                workout.difficulty.toUpperCase(),
                style: TextStyle(
                  color: _getDifficultyColor(workout.difficulty),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _getDifficultyColor(workout.difficulty).withValues(alpha: 0.1),
              side: BorderSide.none,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.timer_outlined,
              '${workout.durationMinutes} min',
              'Duration',
            ),
            _buildStatItem(
              Icons.local_fire_department_outlined,
              '${workout.estimatedCalories} cal',
              'Calories',
            ),
            _buildStatItem(
              Icons.fitness_center_outlined,
              '${workout.exercises.length} exercises',
              'Exercises',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment Required',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: workout.equipmentRequired
              .map(
                (equipment) => Chip(
                  avatar: const Icon(Icons.fitness_center, size: 16),
                  label: Text(equipment.replaceAll('_', ' ').toUpperCase()),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildExercisesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercises',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...workout.exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exercise.description.isNotEmpty)
                    Text(exercise.description),
                  const SizedBox(height: 4),
                  Text(
                    _buildExerciseDetails(exercise),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        }),
      ],
    );
  }

  String _buildExerciseDetails(Exercise exercise) {
    final details = <String>[];

    if (exercise.sets > 0) {
      details.add('${exercise.sets} sets');
    }

    if (exercise.reps > 0) {
      details.add('${exercise.reps} reps');
    }

    if (exercise.durationSeconds != null && exercise.durationSeconds! > 0) {
      final minutes = exercise.durationSeconds! ~/ 60;
      final seconds = exercise.durationSeconds! % 60;
      if (minutes > 0) {
        details.add('${minutes}m ${seconds}s');
      } else {
        details.add('${seconds}s');
      }
    }

    return details.join(' • ');
  }

  Widget _buildStartButton(BuildContext context) {
    return BlocBuilder<WorkoutsBloc, WorkoutsState>(
      builder: (context, state) {
        final isLoading = state is WorkoutsLoading;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    // Start workout session (FR-013)
                    context.read<WorkoutsBloc>().add(
                          StartWorkoutSession(
                            workoutId: workout.id,
                            workoutTitle: workout.title,
                          ),
                        );
                  },
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.play_arrow, size: 28),
            label: Text(
              isLoading ? 'Starting...' : 'Start Workout',
              style: const TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
