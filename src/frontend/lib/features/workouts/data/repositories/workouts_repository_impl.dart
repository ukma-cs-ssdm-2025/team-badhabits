import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/workouts/data/datasources/workouts_api_datasource.dart';
import 'package:frontend/features/workouts/data/datasources/workouts_firestore_datasource.dart';
import 'package:frontend/features/workouts/domain/entities/workout.dart';
import 'package:frontend/features/workouts/domain/entities/workout_session.dart';
import 'package:frontend/features/workouts/domain/repositories/workouts_repository.dart';

/// Workouts Repository Implementation (data layer)
///
/// Implements WorkoutsRepository interface using Firestore and API data sources
class WorkoutsRepositoryImpl implements WorkoutsRepository {
  WorkoutsRepositoryImpl({
    required this.firestoreDataSource,
    required this.apiDataSource,
    required this.auth,
  });

  final WorkoutsFirestoreDataSource firestoreDataSource;
  final WorkoutsApiDataSource apiDataSource;
  final FirebaseAuth auth;

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts() async {
    try {
      final workoutModels = await firestoreDataSource.getWorkouts();
      final workouts =
          workoutModels.map((model) => model.toEntity()).toList();
      return Right(workouts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get workouts: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> getWorkoutById(String workoutId) async {
    try {
      final workoutModel =
          await firestoreDataSource.getWorkoutById(workoutId);
      return Right(workoutModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get workout: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getFilteredWorkouts({
    int? duration,
    List<String>? equipment,
    String? difficulty,
  }) async {
    try {
      final workoutModels = await firestoreDataSource.getFilteredWorkouts(
        duration: duration,
        equipment: equipment,
        difficulty: difficulty,
      );
      final workouts =
          workoutModels.map((model) => model.toEntity()).toList();
      return Right(workouts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get filtered workouts: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkoutSession>> startWorkoutSession({
    required String workoutId,
    required String workoutTitle,
  }) async {
    try {
      final sessionModel = await firestoreDataSource.startWorkoutSession(
        workoutId: workoutId,
        workoutTitle: workoutTitle,
      );
      return Right(sessionModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to start workout session: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkoutSession?>> getActiveWorkoutSession() async {
    try {
      final sessionModel =
          await firestoreDataSource.getActiveWorkoutSession();
      return Right(sessionModel?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get active session: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeWorkoutSession({
    required String sessionId,
    required int difficultyRating,
    int? enjoymentRating,
    String? notes,
  }) async {
    try {
      await firestoreDataSource.completeWorkoutSession(
        sessionId: sessionId,
        difficultyRating: difficultyRating,
        enjoymentRating: enjoymentRating,
        notes: notes,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to complete workout session: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelWorkoutSession({
    required String sessionId,
  }) async {
    try {
      await firestoreDataSource.cancelWorkoutSession(sessionId: sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel workout session: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> getRecommendedWorkout({
    required String workoutId,
    required int difficultyRating,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      // TODO(team): Get actual user profile data
      final workoutModel = await apiDataSource.getRecommendedWorkout(
        userId: user.uid,
        workoutId: workoutId,
        difficultyRating: difficultyRating,
        fitnessLevel: 'intermediate', // TODO(team): Get from user profile
        injuries: const [], // TODO(team): Get from user profile
        availableEquipment: const [], // TODO(team): Get from user profile
        preferredDurationMinutes: 30, // TODO(team): Get from user profile
      );

      return Right(workoutModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get recommendation: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSession>>> getWorkoutHistory() async {
    try {
      final sessionModels = await firestoreDataSource.getWorkoutHistory();
      final sessions =
          sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get workout history: $e'));
    }
  }
}
