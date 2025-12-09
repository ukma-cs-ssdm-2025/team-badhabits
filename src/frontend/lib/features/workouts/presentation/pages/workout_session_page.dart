import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/workouts/domain/entities/exercise.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_bloc.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_event.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_state.dart';
import 'package:frontend/features/workouts/presentation/widgets/exercise_card.dart';

/// Workout Session Page
///
/// Displays active workout session with exercises, timer and controls
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

  // Exercise tracking
  late PageController _pageController;
  int _currentExerciseIndex = 0;
  final Set<int> _completedExercises = {};
  Workout? _workout;
  bool _isLoadingWorkout = true;
  bool _isCancelling = false;

  // Exercise timer state
  bool _exerciseTimerRunning = false;
  DateTime? _exerciseTimerStart;
  int _exerciseElapsedSeconds = 0;

  // Rest timer state
  bool _restTimerRunning = false;
  DateTime? _restTimerStart;
  int _restTargetSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTime = widget.session.startedAt;
    _pageController = PageController();

    // Load workout details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutsBloc>().add(
            LoadWorkoutDetails(workoutId: widget.session.workoutId),
          );
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _getElapsedTime() {
    final elapsed = DateTime.now().difference(_startTime);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _goToExercise(int index) async {
    if (_workout != null && index >= 0 && index < _workout!.exercises.length) {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startExerciseTimer() {
    setState(() {
      _exerciseTimerRunning = true;
      _exerciseTimerStart = DateTime.now();
    });
  }

  void _pauseExerciseTimer() {
    if (_exerciseTimerStart != null) {
      setState(() {
        _exerciseElapsedSeconds +=
            DateTime.now().difference(_exerciseTimerStart!).inSeconds;
        _exerciseTimerRunning = false;
        _exerciseTimerStart = null;
      });
    }
  }

  void _resetExerciseTimer() {
    setState(() {
      _exerciseTimerRunning = false;
      _exerciseTimerStart = null;
      _exerciseElapsedSeconds = 0;
    });
  }

  int _getExerciseElapsedSeconds() {
    if (_exerciseTimerStart != null) {
      return _exerciseElapsedSeconds +
          DateTime.now().difference(_exerciseTimerStart!).inSeconds;
    }
    return _exerciseElapsedSeconds;
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _restTimerRunning = true;
      _restTimerStart = DateTime.now();
      _restTargetSeconds = seconds;
      _exerciseTimerRunning = false; // Pause exercise timer during rest
    });

    // Auto-stop rest timer when done
    Future.delayed(Duration(seconds: seconds), () {
      if (mounted && _restTimerRunning) {
        setState(() {
          _restTimerRunning = false;
          _restTimerStart = null;
        });
      }
    });
  }

  void _stopRestTimer() {
    setState(() {
      _restTimerRunning = false;
      _restTimerStart = null;
    });
  }

  int _getRestRemainingSeconds() {
    if (_restTimerStart != null) {
      final elapsed = DateTime.now().difference(_restTimerStart!).inSeconds;
      return (_restTargetSeconds - elapsed).clamp(0, _restTargetSeconds);
    }
    return 0;
  }

  void _markExerciseComplete(int index) {
    setState(() {
      _completedExercises.add(index);
    });

    // Reset timers when completing exercise
    _resetExerciseTimer();
    _stopRestTimer();

    // Auto-navigate to next exercise if available
    if (index < (_workout?.exercises.length ?? 0) - 1) {
      unawaited(
        Future.delayed(
          const Duration(milliseconds: 500),
          () => _goToExercise(index + 1),
        ),
      );
    }
  }

  void _completeSession(BuildContext context) {
    final workoutsBloc = context.read<WorkoutsBloc>();

    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (builderContext, setStateDialog) => AlertDialog(
            title: const Text('Complete Workout'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  if (_workout != null) ...[
                    Text(
                      'You completed ${_completedExercises.length} out of ${_workout!.exercises.length} exercises',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('How difficult was this workout?'),
                  const SizedBox(height: 8),
                  Slider(
                    value: _difficultyRating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _difficultyRating.toString(),
                    onChanged: (value) {
                      setStateDialog(() {
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
                      setStateDialog(() {
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
                  workoutsBloc.add(
                    CompleteWorkoutSession(
                      sessionId: widget.session.id,
                      difficultyRating: _difficultyRating,
                      enjoymentRating: _enjoymentRating,
                      notes: _notesController.text.isEmpty
                          ? null
                          : _notesController.text,
                      userId: FirebaseAuth.instance.currentUser?.uid,
                    ),
                  );
                },
                child: const Text('Complete'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<WorkoutsBloc, WorkoutsState>(
        listener: (context, state) {
          if (state is WorkoutDetailsLoaded) {
            setState(() {
              _workout = state.workout;
              _isLoadingWorkout = false;
            });
          } else if (state is WorkoutSessionCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isCancelling
                      ? 'Workout cancelled'
                      : 'Workout completed! Great job!',
                ),
                backgroundColor: _isCancelling ? Colors.orange : Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is WorkoutsError) {
            if (!state.message.contains('Workout details')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.session.workoutTitle),
            actions: [
              // Timer in app bar
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: StreamBuilder<int>(
                    stream: Stream<int>.periodic(
                      const Duration(seconds: 1),
                      (count) => count,
                    ),
                    builder: (context, snapshot) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getElapsedTime(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: _isLoadingWorkout
              ? const Center(child: CircularProgressIndicator())
              : _workout == null || _workout!.exercises.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Progress bar
                        _buildProgressBar(),

                        // Exercise PageView
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentExerciseIndex = index;
                                // Reset timers when changing exercise
                                _resetExerciseTimer();
                                _stopRestTimer();
                              });
                            },
                            itemCount: _workout!.exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = _workout!.exercises[index];
                              final isCompleted =
                                  _completedExercises.contains(index);

                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Exercise Timer Display
                                    if (!isCompleted) _buildExerciseTimerCard(exercise),
                                    const SizedBox(height: 16),

                                    ExerciseCard(
                                      exercise: exercise,
                                      exerciseNumber: index + 1,
                                      isCompleted: isCompleted,
                                    ),
                                    const SizedBox(height: 16),

                                    // Mark as complete button
                                    if (!isCompleted)
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _markExerciseComplete(index),
                                          icon: const Icon(Icons.check_circle),
                                          label: const Text(
                                            'Mark as Complete',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Navigation and action buttons
                        _buildBottomControls(),
                      ],
                    ),
        ),
      );

  Widget _buildExerciseTimerCard(Exercise exercise) => Card(
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: _restTimerRunning
                  ? [
                      Colors.orange.withValues(alpha: 0.1),
                      Colors.orange.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.blue.withValues(alpha: 0.1),
                      Colors.blue.withValues(alpha: 0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // Timer display
              StreamBuilder<int>(
                stream: Stream<int>.periodic(
                  const Duration(seconds: 1),
                  (count) => count,
                ),
                builder: (context, snapshot) {
                  if (_restTimerRunning) {
                    // Rest timer
                    final remaining = _getRestRemainingSeconds();
                    final minutes = remaining ~/ 60;
                    final seconds = remaining % 60;
                    return Column(
                      children: [
                        const Text(
                          'REST TIME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Exercise timer
                    final elapsed = _getExerciseElapsedSeconds();
                    final minutes = elapsed ~/ 60;
                    final seconds = elapsed % 60;
                    return Column(
                      children: [
                        Text(
                          _exerciseTimerRunning
                              ? 'EXERCISE TIME'
                              : 'READY TO START',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _exerciseTimerRunning
                                ? Colors.green
                                : Colors.grey[600],
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: _exerciseTimerRunning
                                ? Colors.green
                                : Colors.grey[700],
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Control buttons
              if (_restTimerRunning)
                // Rest timer controls
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _stopRestTimer,
                        icon: const Icon(Icons.stop),
                        label: const Text('Skip Rest'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Exercise timer controls
                Row(
                  children: [
                    // Start/Pause button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_exerciseTimerRunning) {
                            _pauseExerciseTimer();
                          } else {
                            _startExerciseTimer();
                          }
                        },
                        icon: Icon(_exerciseTimerRunning
                            ? Icons.pause
                            : Icons.play_arrow),
                        label: Text(
                          _exerciseTimerRunning ? 'Pause' : 'Start Exercise',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _exerciseTimerRunning
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_exerciseElapsedSeconds > 0 ||
                        _exerciseTimerStart != null) ...[
                      const SizedBox(width: 12),
                      // Reset button
                      OutlinedButton(
                        onPressed: _resetExerciseTimer,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                        ),
                        child: const Icon(Icons.refresh),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 12),

              // Start rest button
              if (!_restTimerRunning && exercise.restSeconds > 0)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _startRestTimer(exercise.restSeconds),
                    icon: const Icon(Icons.self_improvement),
                    label:
                        Text('Start Rest (${exercise.restSeconds}s)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildProgressBar() {
    final totalExercises = _workout?.exercises.length ?? 0;
    final completedCount = _completedExercises.length;
    final progress = totalExercises > 0 ? completedCount / totalExercises : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '$completedCount / $totalExercises exercises',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 12),

          // Exercise thumbnails
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalExercises,
              itemBuilder: (context, index) {
                final isCompleted = _completedExercises.contains(index);
                final isCurrent = _currentExerciseIndex == index;

                return GestureDetector(
                  onTap: () => _goToExercise(index),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : (isCurrent ? Colors.blue : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrent
                          ? Border.all(color: Colors.blue, width: 3)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation buttons
              Row(
                children: [
                  // Previous button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentExerciseIndex > 0
                          ? () => _goToExercise(_currentExerciseIndex - 1)
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Next button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentExerciseIndex <
                              (_workout?.exercises.length ?? 0) - 1
                          ? () => _goToExercise(_currentExerciseIndex + 1)
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Complete workout button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _completeSession(context),
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: const Text(
                    'Complete Workout',
                    style: TextStyle(fontSize: 16),
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
              const SizedBox(height: 8),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    unawaited(
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
                                setState(() {
                                  _isCancelling = true;
                                });
                                context.read<WorkoutsBloc>().add(
                                      CancelWorkoutSession(
                                        sessionId: widget.session.id,
                                      ),
                                    );
                                // Don't call Navigator.pop(context) here
                                // Let BlocListener handle navigation
                              },
                              child: const Text('Yes, Cancel'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.close),
                  label: const Text(
                    'Cancel Workout',
                    style: TextStyle(fontSize: 16),
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
      );
}
