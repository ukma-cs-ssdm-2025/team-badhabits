import 'package:equatable/equatable.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';

/// Base class for all workout states
abstract class WorkoutsState extends Equatable {
  const WorkoutsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WorkoutsInitial extends WorkoutsState {
  const WorkoutsInitial();
}

/// Loading state
class WorkoutsLoading extends WorkoutsState {
  const WorkoutsLoading();
}

/// State when workouts are successfully loaded
class WorkoutsLoaded extends WorkoutsState {
  const WorkoutsLoaded({required this.workouts});

  final List<Workout> workouts;

  @override
  List<Object?> get props => [workouts];
}

/// State when specific workout details are loaded
class WorkoutDetailsLoaded extends WorkoutsState {
  const WorkoutDetailsLoaded({required this.workout});

  final Workout workout;

  @override
  List<Object?> get props => [workout];
}

/// State when filtered workouts are loaded
class FilteredWorkoutsLoaded extends WorkoutsState {
  const FilteredWorkoutsLoaded({required this.workouts});

  final List<Workout> workouts;

  @override
  List<Object?> get props => [workouts];
}

/// State when workout session is started (FR-013)
class WorkoutSessionStarted extends WorkoutsState {
  const WorkoutSessionStarted({required this.session});

  final WorkoutSession session;

  @override
  List<Object?> get props => [session];
}

/// State when active workout session is loaded
class ActiveWorkoutSessionLoaded extends WorkoutsState {
  const ActiveWorkoutSessionLoaded({required this.session});

  final WorkoutSession? session;

  @override
  List<Object?> get props => [session];
}

/// State when workout session is completed
class WorkoutSessionCompleted extends WorkoutsState {
  const WorkoutSessionCompleted();
}

/// State when recommended workout is loaded (FR-014)
class RecommendedWorkoutLoaded extends WorkoutsState {
  const RecommendedWorkoutLoaded({required this.workout});

  final Workout workout;

  @override
  List<Object?> get props => [workout];
}

/// State when workout history is loaded
class WorkoutHistoryLoaded extends WorkoutsState {
  const WorkoutHistoryLoaded({required this.sessions});

  final List<WorkoutSession> sessions;

  @override
  List<Object?> get props => [sessions];
}

/// Error state
class WorkoutsError extends WorkoutsState {
  const WorkoutsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
