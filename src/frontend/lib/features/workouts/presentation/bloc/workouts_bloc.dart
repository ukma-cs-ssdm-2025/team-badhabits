import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/usecases/complete_workout_session.dart';
import 'package:frontend/features/workouts/domain/usecases/get_active_workout_session.dart';
import 'package:frontend/features/workouts/domain/usecases/get_filtered_workouts.dart';
import 'package:frontend/features/workouts/domain/usecases/get_recommended_workout.dart';
import 'package:frontend/features/workouts/domain/usecases/get_workout_by_id.dart';
import 'package:frontend/features/workouts/domain/usecases/get_workout_history.dart';
import 'package:frontend/features/workouts/domain/usecases/get_workouts.dart';
import 'package:frontend/features/workouts/domain/usecases/start_workout_session.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_event.dart';
import 'package:frontend/features/workouts/presentation/bloc/workouts_state.dart';

/// Workouts BLoC
///
/// Handles business logic for workouts feature
/// Coordinates between UI events and domain use cases
class WorkoutsBloc extends Bloc<WorkoutsEvent, WorkoutsState> {
  WorkoutsBloc({
    required this.getWorkouts,
    required this.getWorkoutById,
    required this.getFilteredWorkouts,
    required this.startWorkoutSession,
    required this.getActiveWorkoutSession,
    required this.completeWorkoutSession,
    required this.getRecommendedWorkout,
    required this.getWorkoutHistory,
  }) : super(const WorkoutsInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<LoadWorkoutDetails>(_onLoadWorkoutDetails);
    on<FilterWorkouts>(_onFilterWorkouts);
    on<StartWorkoutSession>(_onStartWorkoutSession);
    on<LoadActiveWorkoutSession>(_onLoadActiveWorkoutSession);
    on<CompleteWorkoutSession>(_onCompleteWorkoutSession);
    on<GetRecommendedWorkout>(_onGetRecommendedWorkout);
    on<LoadWorkoutHistory>(_onLoadWorkoutHistory);
  }

  final GetWorkouts getWorkouts;
  final GetWorkoutById getWorkoutById;
  final GetFilteredWorkouts getFilteredWorkouts;
  final StartWorkoutSession startWorkoutSession;
  final GetActiveWorkoutSession getActiveWorkoutSession;
  final CompleteWorkoutSession completeWorkoutSession;
  final GetRecommendedWorkout getRecommendedWorkout;
  final GetWorkoutHistory getWorkoutHistory;

  /// Handle LoadWorkouts event
  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await getWorkouts(NoParams());

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (workouts) => emit(WorkoutsLoaded(workouts: workouts)),
    );
  }

  /// Handle LoadWorkoutDetails event
  Future<void> _onLoadWorkoutDetails(
    LoadWorkoutDetails event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await getWorkoutById(
      GetWorkoutByIdParams(workoutId: event.workoutId),
    );

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (workout) => emit(WorkoutDetailsLoaded(workout: workout)),
    );
  }

  /// Handle FilterWorkouts event (US-005)
  Future<void> _onFilterWorkouts(
    FilterWorkouts event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await getFilteredWorkouts(
      GetFilteredWorkoutsParams(
        duration: event.duration,
        equipment: event.equipment,
        difficulty: event.difficulty,
      ),
    );

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (workouts) => emit(FilteredWorkoutsLoaded(workouts: workouts)),
    );
  }

  /// Handle StartWorkoutSession event (FR-013)
  Future<void> _onStartWorkoutSession(
    StartWorkoutSession event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await startWorkoutSession(
      StartWorkoutSessionParams(
        workoutId: event.workoutId,
        workoutTitle: event.workoutTitle,
      ),
    );

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (session) => emit(WorkoutSessionStarted(session: session)),
    );
  }

  /// Handle LoadActiveWorkoutSession event (FR-013)
  Future<void> _onLoadActiveWorkoutSession(
    LoadActiveWorkoutSession event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await getActiveWorkoutSession();

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (session) => emit(ActiveWorkoutSessionLoaded(session: session)),
    );
  }

  /// Handle CompleteWorkoutSession event (US-006)
  Future<void> _onCompleteWorkoutSession(
    CompleteWorkoutSession event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await completeWorkoutSession(
      CompleteWorkoutSessionParams(
        sessionId: event.sessionId,
        difficultyRating: event.difficultyRating,
        enjoymentRating: event.enjoymentRating,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (_) => emit(const WorkoutSessionCompleted()),
    );
  }

  /// Handle GetRecommendedWorkout event (FR-014)
  Future<void> _onGetRecommendedWorkout(
    GetRecommendedWorkout event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await getRecommendedWorkout(
      GetRecommendedWorkoutParams(
        workoutId: event.workoutId,
        difficultyRating: event.difficultyRating,
      ),
    );

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (workout) => emit(RecommendedWorkoutLoaded(workout: workout)),
    );
  }

  /// Handle LoadWorkoutHistory event
  Future<void> _onLoadWorkoutHistory(
    LoadWorkoutHistory event,
    Emitter<WorkoutsState> emit,
  ) async {
    emit(const WorkoutsLoading());

    final result = await getWorkoutHistory(NoParams());

    result.fold(
      (failure) => emit(WorkoutsError(message: _mapFailureToMessage(failure))),
      (sessions) => emit(WorkoutHistoryLoaded(sessions: sessions)),
    );
  }

  /// Map Failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unexpected error occurred';
  }
}
