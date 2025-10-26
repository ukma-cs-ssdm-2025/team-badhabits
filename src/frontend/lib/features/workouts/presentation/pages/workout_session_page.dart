import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_bloc.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_event.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_state.dart';

/// Workout Session Page
///
/// Displays active workout session with timer and controls
class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({required this.session, super.key});

  final WorkoutSession session;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late DateTime _startTime;
  int _difficultyRating = 3;
  int _enjoymentRating = 3;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTime = widget.session.startedAt;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getElapsedTime() {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _completeSession(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Complete Workout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How difficult was this workout?'),
              const SizedBox(height: 8),
              Slider(
                value: _difficultyRating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _difficultyRating.toString(),
                onChanged: (value) {
                  setState(() {
                    _difficultyRating = value.toInt();
                  });
                },
              ),
              Text(
                'Difficulty: $_difficultyRating/5',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text('How much did you enjoy it?'),
              const SizedBox(height: 8),
              Slider(
                value: _enjoymentRating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _enjoymentRating.toString(),
                onChanged: (value) {
                  setState(() {
                    _enjoymentRating = value.toInt();
                  });
                },
              ),
              Text(
                'Enjoyment: $_enjoymentRating/5',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'How did you feel during this workout?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutsBloc>().add(
                    CompleteWorkoutSession(
                      sessionId: widget.session.id,
                      difficultyRating: _difficultyRating,
                      enjoymentRating: _enjoymentRating,
                      notes: _notesController.text.isEmpty
                          ? null
                          : _notesController.text,
                    ),
                  );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkoutsBloc, WorkoutsState>(
      listener: (context, state) {
        if (state is WorkoutSessionCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout completed! Great job!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (state is WorkoutsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Active Workout'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Workout title
                Text(
                  widget.session.workoutTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Timer
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Text(
                      _getElapsedTime(),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elapsed Time',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Complete button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _completeSession(context),
                    icon: const Icon(Icons.check_circle, size: 28),
                    label: const Text(
                      'Complete Workout',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Cancel Workout?'),
                          content: const Text(
                            'Are you sure you want to cancel this workout session? Your progress will not be saved.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('No, Continue'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                context.read<WorkoutsBloc>().add(
                                      CancelWorkoutSession(
                                        sessionId: widget.session.id,
                                      ),
                                    );
                              },
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'Cancel Workout',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
