import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/data/datasources/habits_firestore_datasource.dart';
import 'package:frontend/features/habits/data/models/habit_model.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Implementation of [HabitsRepository]
///
/// Handles the business logic and error handling for habits operations
class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl({required this.datasource});
  final HabitsFirestoreDataSource datasource;

  @override
  Future<Either<Failure, List<Habit>>> getHabits(String userId) async {
    try {
      final habits = await datasource.getHabits(userId);
      return Right(habits);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get habits: $e'));
    }
  }

  @override
  Future<Either<Failure, Habit>> createHabit(Habit habit) async {
    try {
      // Convert Habit entity to HabitModel
      final habitModel = HabitModel.fromEntity(habit);
      final createdHabit = await datasource.createHabit(habitModel);
      return Right(createdHabit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to create habit: $e'));
    }
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    try {
      // Convert Habit entity to HabitModel
      final habitModel = HabitModel.fromEntity(habit);
      final updatedHabit = await datasource.updateHabit(habitModel);
      return Right(updatedHabit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to update habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      await datasource.deleteHabit(habitId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to delete habit: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntry>> addEntry(
    String habitId,
    HabitEntry entry,
  ) async {
    try {
      // Convert HabitEntry entity to HabitEntryModel
      final entryModel = HabitEntryModel.fromEntity(entry);
      final addedEntry = await datasource.addEntry(habitId, entryModel);
      return Right(addedEntry);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to add habit entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntry>>> getEntries(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final entries = await datasource.getEntries(habitId, startDate, endDate);
      return Right(entries);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get habit entries: $e'));
    }
  }

  @override
  Future<Either<Failure, HabitEntry?>> getEntryForDate(
    String habitId,
    String date,
  ) async {
    try {
      final entry = await datasource.getEntryForDate(habitId, date);
      return Right(entry);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get habit entry for date: $e'));
    }
  }
}
