// ignore_for_file: avoid_print
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/core/network/network_info.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/habits/data/datasources/habits_firestore_datasource.dart';
import 'package:frontend/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:frontend/features/habits/data/models/habit_entry_hive_model.dart';
import 'package:frontend/features/habits/data/models/habit_model.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/domain/repositories/habits_repository.dart';

/// Implementation of [HabitsRepository]
///
/// Handles the business logic and error handling for habits operations
/// with offline support using local cache
class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final HabitsFirestoreDataSource remoteDataSource;
  final HabitsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Habit>>> getHabits(String userId) async {
    try {
      print('🔵 HabitsRepository: Getting habits for user $userId');
      final isConnected = await networkInfo.isConnected;
      print('🌐 HabitsRepository: Network connected = $isConnected');

      if (isConnected) {
        // Online: fetch from Firestore and cache
        print('📡 HabitsRepository: Fetching from Firestore...');
        final habits = await remoteDataSource.getHabits(userId);
        print('✅ HabitsRepository: Got ${habits.length} habits from Firestore');
        await localDataSource.cacheHabits(habits);
        print('💾 HabitsRepository: Cached habits locally');
        return Right(habits);
      } else {
        // Offline: return cached data
        print('📴 HabitsRepository: Offline - loading from cache...');
        final cachedHabits = await localDataSource.getCachedHabits(userId);
        print('💾 HabitsRepository: Got ${cachedHabits.length} habits from cache');
        return Right(cachedHabits);
      }
    } on FirebaseException catch (e) {
      // Fallback to cache on Firebase error
      print('🔴 HabitsRepository: Firebase error: ${e.message}');
      print('💾 HabitsRepository: Falling back to cache...');
      try {
        final cachedHabits = await localDataSource.getCachedHabits(userId);
        print('✅ HabitsRepository: Returned ${cachedHabits.length} habits from cache');
        return Right(cachedHabits);
      } catch (cacheError) {
        print('🔴 HabitsRepository: Cache error: $cacheError');
        return Left(ServerFailure('Firebase error: ${e.message}'));
      }
    } catch (e) {
      print('🔴 HabitsRepository: Unexpected error: $e');
      return Left(ServerFailure('Failed to get habits: $e'));
    }
  }

  @override
  Future<Either<Failure, Habit>> createHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);

      if (await networkInfo.isConnected) {
        // Online: save to Firestore and cache
        final createdHabit = await remoteDataSource.createHabit(habitModel);
        await localDataSource.cacheHabit(createdHabit);
        return Right(createdHabit);
      } else {
        // Offline: save locally with pending sync flag
        await localDataSource.cacheHabit(habitModel, isPending: true);
        return Right(habitModel);
      }
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to create habit: $e'));
    }
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    try {
      final habitModel = HabitModel.fromEntity(habit);

      if (await networkInfo.isConnected) {
        // Online: update in Firestore and cache
        final updatedHabit = await remoteDataSource.updateHabit(habitModel);
        await localDataSource.cacheHabit(updatedHabit);
        return Right(updatedHabit);
      } else {
        // Offline: save locally with pending sync flag
        await localDataSource.cacheHabit(habitModel, isPending: true);
        return Right(habitModel);
      }
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to update habit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      if (await networkInfo.isConnected) {
        // Online: delete from Firestore and cache
        await remoteDataSource.deleteHabit(habitId);
        await localDataSource.deleteCachedHabit(habitId);
        return const Right(null);
      } else {
        // Offline: just remove from cache
        // TODO: Add to deletion queue for later sync
        await localDataSource.deleteCachedHabit(habitId);
        return const Right(null);
      }
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
      final entryModel = HabitEntryModel.fromEntity(entry);

      // Get habit to obtain userId for local storage
      final habit = await localDataSource.getCachedHabit(habitId);
      final userId = habit?.userId ?? '';

      // Create HabitEntryHiveModel for local storage
      final entryId = '${habitId}_${entry.date}';
      final hiveEntry = HabitEntryHiveModel.fromEntity(
        id: entryId,
        habitId: habitId,
        userId: userId,
        entry: entry,
      );

      if (await networkInfo.isConnected) {
        // Online: save to Firestore and cache
        final addedEntry =
            await remoteDataSource.addEntry(habitId, entryModel);
        await localDataSource.cacheEntry(hiveEntry);
        return Right(addedEntry);
      } else {
        // Offline: save locally with pending sync flag
        await localDataSource.cacheEntry(hiveEntry, isPending: true);
        return Right(entryModel);
      }
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
      if (await networkInfo.isConnected) {
        // Online: fetch from Firestore and cache
        final entries =
            await remoteDataSource.getEntries(habitId, startDate, endDate);

        // Get userId for caching
        final habit = await localDataSource.getCachedHabit(habitId);
        final userId = habit?.userId ?? '';

        // Cache entries
        final hiveEntries = entries
            .map(
              (e) => HabitEntryHiveModel.fromEntity(
                id: '${habitId}_${e.date}',
                habitId: habitId,
                userId: userId,
                entry: e,
              ),
            )
            .toList();
        await localDataSource.cacheEntries(hiveEntries);

        return Right(entries);
      } else {
        // Offline: return cached data
        final cachedEntries = await localDataSource.getCachedEntries(habitId);
        final entries = cachedEntries.map((e) => e.toEntity()).toList();
        return Right(entries);
      }
    } on FirebaseException catch (e) {
      // Fallback to cache on Firebase error
      try {
        final cachedEntries = await localDataSource.getCachedEntries(habitId);
        final entries = cachedEntries.map((e) => e.toEntity()).toList();
        return Right(entries);
      } catch (_) {
        return Left(ServerFailure('Firebase error: ${e.message}'));
      }
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
      if (await networkInfo.isConnected) {
        // Online: fetch from Firestore
        final entry = await remoteDataSource.getEntryForDate(habitId, date);
        return Right(entry);
      } else {
        // Offline: return cached data
        final cachedEntry =
            await localDataSource.getCachedEntryForDate(habitId, date);
        return Right(cachedEntry?.toEntity());
      }
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get habit entry for date: $e'));
    }
  }
}
