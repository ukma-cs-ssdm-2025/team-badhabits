import 'dart:async';
import 'dart:developer' as developer;

import '../../../../core/network/network_info.dart';
import '../datasources/habits_firestore_datasource.dart';
import '../datasources/habits_local_datasource.dart';
import '../models/habit_model.dart';

/// Service for synchronizing local habit data with Firestore
///
/// Listens to network connectivity changes and automatically syncs
/// pending changes when connection is restored
class HabitSyncService {
  final HabitsLocalDataSource localDataSource;
  final HabitsFirestoreDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  HabitSyncService({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Start listening to connectivity changes
  ///
  /// Automatically syncs pending changes when connection is restored
  void startListening() {
    _connectivitySubscription =
        networkInfo.onConnectivityChanged.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        unawaited(syncPendingChanges());
      }
    });
  }

  /// Stop listening to connectivity changes
  void stopListening() {
    unawaited(_connectivitySubscription?.cancel());
  }

  /// Sync all pending habits and entries to Firestore
  ///
  /// Returns true if sync was successful or if there's nothing to sync,
  /// false if offline or already syncing
  Future<bool> syncPendingChanges() async {
    if (_isSyncing) {
      return false;
    }
    if (!await networkInfo.isConnected) {
      return false;
    }

    _isSyncing = true;

    try {
      // Sync pending habits
      final pendingHabits = await localDataSource.getPendingSyncHabits();
      for (final habit in pendingHabits) {
        try {
          await remoteDataSource.updateHabit(habit);
          await localDataSource.markHabitAsSynced(habit.id);
        } catch (e) {
          // Log error but continue with next item
          developer.log('Failed to sync habit ${habit.id}: $e');
        }
      }

      // Sync pending entries
      final pendingEntries = await localDataSource.getPendingSyncEntries();
      for (final entry in pendingEntries) {
        try {
          // Convert HabitEntryHiveModel to HabitEntryModel for remote sync
          final entryModel = HabitEntryModel.fromEntity(entry.toEntity());
          await remoteDataSource.addEntry(entry.habitId, entryModel);
          await localDataSource.markEntryAsSynced(entry.id);
        } catch (e) {
          developer.log('Failed to sync entry ${entry.id}: $e');
        }
      }

      developer.log(
        'Sync completed: ${pendingHabits.length} habits, ${pendingEntries.length} entries',
      );
      // Always return true if we got this far (we're online and sync completed)
      return true;
    } finally {
      _isSyncing = false;
    }
  }

  /// Manually trigger sync
  ///
  /// Returns true if sync was successful (even if nothing to sync),
  /// false if offline
  Future<bool> forceSyncNow() async {
    if (!await networkInfo.isConnected) {
      return false;
    }
    return syncPendingChanges();
  }

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;
}
