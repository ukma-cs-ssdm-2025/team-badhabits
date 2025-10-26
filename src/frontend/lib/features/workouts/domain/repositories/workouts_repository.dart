import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';

/// Workouts Repository Interface (domain layer)
///
/// Defines contract for workouts data operations.
/// Implementations in data layer will handle Firebase and API calls.
abstract class WorkoutsRepository {
  /// Get all workouts for the current user
  ///
  /// Returns list of personalized workouts from Firestore
  Future<Either<Failure, List<Workout>>> getWorkouts();

  /// Get workout by ID
  ///
  /// Returns workout details from Firestore
  Future<Either<Failure, Workout>> getWorkoutById(String workoutId);

  /// Get workouts filtered by criteria
  ///
  /// [duration] - filter by duration (15, 30, 45 minutes) - US-005
  /// [equipment] - filter by required equipment
  /// [difficulty] - filter by difficulty level
  Future<Either<Failure, List<Workout>>> getFilteredWorkouts({
    int? duration,
    List<String>? equipment,
    String? difficulty,
  });

  /// Start a new workout session
  ///
  /// Creates a new session in Firestore and Realtime Database
  /// Implements FR-013: блокування паралельних сесій
  Future<Either<Failure, WorkoutSession>> startWorkoutSession({
    required String workoutId,
    required String workoutTitle,
  });

  /// Get active workout session
  ///
  /// Check if user has an active session (for FR-013)
  Future<Either<Failure, WorkoutSession?>> getActiveWorkoutSession();

  /// Complete workout session with rating
  ///
  /// Updates session status and saves rating
  /// Implements US-006: оцінка складності тренування
  Future<Either<Failure, void>> completeWorkoutSession({
    required String sessionId,
    required int difficultyRating,
    int? enjoymentRating,
    String? notes,
  });

  /// Cancel workout session
  ///
  /// Cancels active session and removes lock from Realtime Database
  Future<Either<Failure, void>> cancelWorkoutSession({
    required String sessionId,
  });

  /// Get recommended workout based on user ratings
  ///
  /// Calls Railway backend API for adaptive recommendation (FR-014)
  /// Backend URL: https://wellity-backend-production.up.railway.app/api/v1/adaptive/recommend
  Future<Either<Failure, Workout>> getRecommendedWorkout({
    required String workoutId,
    required int difficultyRating,
  });

  /// Get user's workout history
  ///
  /// Returns list of completed sessions for statistics (US-001)
  Future<Either<Failure, List<WorkoutSession>>> getWorkoutHistory();
}
