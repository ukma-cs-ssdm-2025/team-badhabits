import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/workouts/data/models/workout_model.dart';
import 'package:frontend/features/workouts/data/models/workout_session_model.dart';

/// Workouts Firestore Data Source
///
/// Handles all Firebase operations for workouts feature
/// Uses both Firestore (for CRUD) and Realtime Database (for active sessions - FR-013)
class WorkoutsFirestoreDataSource {
  WorkoutsFirestoreDataSource({
    required this.firestoreDb,
    required this.realtimeDatabase,
    required this.auth,
  });

  final firestore.FirebaseFirestore firestoreDb;
  final FirebaseDatabase realtimeDatabase;
  final FirebaseAuth auth;

  /// Get current user ID
  String get _userId {
    final user = auth.currentUser;
    if (user == null) throw ServerException('User not authenticated');
    return user.uid;
  }

  /// Get all workouts for current user
  ///
  /// Returns personalized workouts from /users/{userId}/personalized_workouts
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final snapshot = await firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('personalized_workouts')
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch workouts: $e');
    }
  }

  /// Get workout by ID
  Future<WorkoutModel> getWorkoutById(String workoutId) async {
    try {
      // First try to get from personalized workouts
      final personalizedDoc = await firestore
          .collection('users')
          .doc(_userId)
          .collection('personalized_workouts')
          .doc(workoutId)
          .get();

      if (personalizedDoc.exists) {
        return WorkoutModel.fromJson(
            {...personalizedDoc.data()!, 'id': personalizedDoc.id});
      }

      // If not found, get from public catalog
      final catalogDoc =
          await firestoreDb.collection('workouts').doc(workoutId).get();

      if (!catalogDoc.exists) {
        throw ServerException('Workout not found');
      }

      return WorkoutModel.fromJson({...catalogDoc.data()!, 'id': catalogDoc.id});
    } catch (e) {
      throw ServerException('Failed to fetch workout: $e');
    }
  }

  /// Get filtered workouts
  ///
  /// Filters by duration, equipment, and difficulty
  Future<List<WorkoutModel>> getFilteredWorkouts({
    int? duration,
    List<String>? equipment,
    String? difficulty,
  }) async {
    try {
      dynamic query = firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('personalized_workouts');

      // Apply filters
      if (duration != null) {
        query = query.where('duration_minutes',
            isLessThanOrEqualTo: duration + 5, isGreaterThanOrEqualTo: duration - 5);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get() as firestore.QuerySnapshot<Map<String, dynamic>>;
      var workouts = snapshot.docs
          .map((doc) => WorkoutModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Filter by equipment (client-side, as Firestore doesn't support array-contains for multiple values)
      if (equipment != null && equipment.isNotEmpty) {
        workouts = workouts.where((workout) {
          return workout.equipmentRequired
              .every((req) => equipment.contains(req));
        }).toList();
      }

      return workouts;
    } catch (e) {
      throw ServerException('Failed to fetch filtered workouts: $e');
    }
  }

  /// Start workout session
  ///
  /// Implements FR-013: блокування паралельних сесій
  /// Uses Realtime Database for lock mechanism
  Future<WorkoutSessionModel> startWorkoutSession({
    required String workoutId,
    required String workoutTitle,
  }) async {
    try {
      // Check for active session in Realtime Database (FR-013)
      final activeSessions =
          realtimeDatabase.ref('active_sessions').child(_userId);
      final snapshot = await activeSessions.get();

      if (snapshot.exists) {
        throw ServerException(
            'Active session already exists. Please complete it first.');
      }

      // Create new session
      final sessionId = firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('workout_sessions')
          .doc()
          .id;

      final session = WorkoutSessionModel(
        id: sessionId,
        userId: _userId,
        workoutId: workoutId,
        workoutTitle: workoutTitle,
        status: 'active',
        startedAt: DateTime.now(),
      );

      // Save to Firestore
      await firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('workout_sessions')
          .doc(sessionId)
          .set(session.toJson());

      // Set lock in Realtime Database
      await activeSessions.set({
        'session_id': sessionId,
        'workout_id': workoutId,
        'started_at': DateTime.now().toIso8601String(),
      });

      return session;
    } catch (e) {
      throw ServerException('Failed to start workout session: $e');
    }
  }

  /// Get active workout session
  Future<WorkoutSessionModel?> getActiveWorkoutSession() async {
    try {
      // Check Realtime Database for active session
      final activeSessions =
          realtimeDatabase.ref('active_sessions').child(_userId);
      final snapshot = await activeSessions.get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final sessionId = data['session_id'] as String;

      // Get session details from Firestore
      final sessionDoc = await firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_sessions')
          .doc(sessionId)
          .get();

      if (!sessionDoc.exists) {
        // Clean up orphaned lock
        await activeSessions.remove();
        return null;
      }

      return WorkoutSessionModel.fromJson(
          {...sessionDoc.data()!, 'id': sessionDoc.id});
    } catch (e) {
      throw ServerException('Failed to get active session: $e');
    }
  }

  /// Complete workout session
  Future<void> completeWorkoutSession({
    required String sessionId,
    required int difficultyRating,
    int? enjoymentRating,
    String? notes,
  }) async {
    try {
      final sessionRef = firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('workout_sessions')
          .doc(sessionId);

      // Get session to calculate duration
      final sessionDoc = await sessionRef.get();
      if (!sessionDoc.exists) {
        throw ServerException('Session not found');
      }

      final session = WorkoutSessionModel.fromJson(
          {...sessionDoc.data()!, 'id': sessionDoc.id});
      final durationSeconds =
          DateTime.now().difference(session.startedAt).inSeconds;

      // Update session
      await sessionRef.update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'total_duration_seconds': durationSeconds,
        'difficulty_rating': difficultyRating,
        if (enjoymentRating != null) 'enjoyment_rating': enjoymentRating,
        if (notes != null) 'notes': notes,
      });

      // Remove lock from Realtime Database
      await realtimeDatabase.ref('active_sessions').child(_userId).remove();

      // Save rating to workout_ratings collection for backend adaptation
      await firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('workout_ratings')
          .add({
        'workout_id': session.workoutId,
        'session_id': sessionId,
        'difficulty_rating': difficultyRating,
        'enjoyment_rating': enjoymentRating,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException('Failed to complete workout session: $e');
    }
  }

  /// Get workout history
  Future<List<WorkoutSessionModel>> getWorkoutHistory() async {
    try {
      final snapshot = await firestoreDb
          .collection('users')
          .doc(_userId)
          .collection('workout_sessions')
          .where('status', isEqualTo: 'completed')
          .orderBy('completed_at', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) =>
              WorkoutSessionModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch workout history: $e');
    }
  }
}
