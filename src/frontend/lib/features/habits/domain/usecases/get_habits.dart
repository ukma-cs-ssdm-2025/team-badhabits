import 'package:dartz/dartz.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Use case for retrieving all habits for a user
class GetHabits {
  GetHabits(this.repository);
  final HabitsRepository repository;

  /// Execute the get habits operation
  ///
  /// [userId] - ID of the user whose habits to retrieve
  ///
  /// Returns [List<Habit>] on success or [Failure] on error
  Future<Either<Failure, List<Habit>>> call(String userId) async =>
      repository.getHabits(userId);
}
