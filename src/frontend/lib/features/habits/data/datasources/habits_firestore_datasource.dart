import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/features/habits/data/models/habit_model.dart';

/// Remote data source for habits operations
///
/// Handles direct communication with Firestore
abstract class HabitsFirestoreDataSource {
  /// Get all habits for a specific user
  Future<List<HabitModel>> getHabits(String userId);

  /// Create a new habit
  Future<HabitModel> createHabit(HabitModel habit);

  /// Update an existing habit
  Future<HabitModel> updateHabit(HabitModel habit);

  /// Delete a habit by ID
  Future<void> deleteHabit(String habitId);

  /// Add a tracking entry to a habit
  Future<HabitEntryModel> addEntry(String habitId, HabitEntryModel entry);

  /// Get all entries for a habit within a date range
  Future<List<HabitEntryModel>> getEntries(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get a specific entry for a habit on a given date
  Future<HabitEntryModel?> getEntryForDate(String habitId, String date);
}

/// Implementation of [HabitsFirestoreDataSource]
class HabitsFirestoreDataSourceImpl implements HabitsFirestoreDataSource {
  HabitsFirestoreDataSourceImpl({required this.firestore});
  final FirebaseFirestore firestore;

  @override
  Future<List<HabitModel>> getHabits(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('habits')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map(HabitModel.fromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to get habits: $e');
    }
  }

  @override
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      // Generate new document ID
      final docRef = firestore.collection('habits').doc();
      final now = DateTime.now();

      // Create habit with generated ID and current timestamp
      final newHabit = HabitModel(
        id: docRef.id,
        userId: habit.userId,
        name: habit.name,
        fields: habit.fields,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore (without id field)
      await docRef.set(newHabit.toFirestore());

      return newHabit;
    } catch (e) {
      throw Exception('Failed to create habit: $e');
    }
  }

  @override
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      final now = DateTime.now();

      // Create updated habit with new timestamp
      final updatedHabit = HabitModel(
        id: habit.id,
        userId: habit.userId,
        name: habit.name,
        fields: habit.fields,
        createdAt: habit.createdAt,
        updatedAt: now,
      );

      // Update in Firestore
      await firestore
          .collection('habits')
          .doc(habit.id)
          .update(updatedHabit.toFirestore());

      return updatedHabit;
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await firestore.collection('habits').doc(habitId).delete();
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  @override
  Future<HabitEntryModel> addEntry(
    String habitId,
    HabitEntryModel entry,
  ) async {
    try {
      // Update the habit document's entries map field
      // Structure: entries.{date} = {field values}
      await firestore.collection('habits').doc(habitId).update({
        'entries.${entry.date}': entry.values,
      });

      return entry;
    } catch (e) {
      throw Exception('Failed to add habit entry: $e');
    }
  }

  @override
  Future<List<HabitEntryModel>> getEntries(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Read the habit document
      final docSnapshot = await firestore
          .collection('habits')
          .doc(habitId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Habit not found');
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('entries')) {
        return [];
      }

      // Extract entries map
      final entriesMap = data['entries'] as Map<String, dynamic>? ?? {};

      // Filter entries within date range and convert to models
      final entries = <HabitEntryModel>[];
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(endDate);

      for (final dateStr in entriesMap.keys) {
        // Check if date is within range
        if (dateStr.compareTo(startDateStr) >= 0 &&
            dateStr.compareTo(endDateStr) <= 0) {
          entries.add(
            HabitEntryModel(
              date: dateStr,
              values: Map<String, dynamic>.from(entriesMap[dateStr] as Map),
            ),
          );
        }
      }

      // Sort by date descending
      entries.sort((a, b) => b.date.compareTo(a.date));

      return entries;
    } catch (e) {
      throw Exception('Failed to get habit entries: $e');
    }
  }

  @override
  Future<HabitEntryModel?> getEntryForDate(String habitId, String date) async {
    try {
      // Read the habit document
      final docSnapshot = await firestore
          .collection('habits')
          .doc(habitId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Habit not found');
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('entries')) {
        return null;
      }

      // Extract entries map
      final entriesMap = data['entries'] as Map<String, dynamic>? ?? {};

      // Check if entry exists for the given date
      if (!entriesMap.containsKey(date)) {
        return null;
      }

      return HabitEntryModel(
        date: date,
        values: Map<String, dynamic>.from(entriesMap[date] as Map),
      );
    } catch (e) {
      throw Exception('Failed to get habit entry for date: $e');
    }
  }

  /// Helper method to format DateTime to YYYY-MM-DD string
  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
