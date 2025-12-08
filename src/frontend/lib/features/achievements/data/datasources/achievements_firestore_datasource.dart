import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/features/achievements/data/models/achievement_model.dart';
import 'package:frontend/features/achievements/data/models/user_achievement_model.dart';

/// Achievements Firestore Data Source
///
/// Handles Firestore operations for achievements
class AchievementsFirestoreDataSource {
  AchievementsFirestoreDataSource({
    required this.firestore,
    required this.auth,
  });

  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  /// Get all available achievements
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final snapshot = await firestore
          .collection('achievements')
          .orderBy('type')
          .orderBy('points')
          .get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch achievements: $e');
    }
  }

  /// Get user's achievements
  Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('user_achievements')
          .get();

      return snapshot.docs
          .map((doc) => UserAchievementModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user achievements: $e');
    }
  }

  /// Unlock an achievement for a user
  /// Uses achievementId as document ID to prevent duplicates
  Future<UserAchievementModel> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      // Use achievementId as document ID to prevent duplicates
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('user_achievements')
          .doc(achievementId);

      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        final existingData = existingDoc.data()!;

        // If already fully unlocked, return existing
        if ((existingData['progress'] as num?) == 1.0) {
          return UserAchievementModel.fromJson({
            ...existingData,
            'id': existingDoc.id,
          });
        }

        // If partially complete, update to fully unlocked
        final now = DateTime.now();
        await docRef.update({
          'progress': 1.0,
          'unlocked_at': now.toIso8601String(),
        });

        return UserAchievementModel.fromJson({
          ...existingData,
          'id': existingDoc.id,
          'progress': 1.0,
          'unlocked_at': now.toIso8601String(),
        });
      }

      // Create new unlocked achievement with achievementId as doc ID
      final now = DateTime.now();
      final data = {
        'achievement_id': achievementId,
        'user_id': userId,
        'unlocked_at': now.toIso8601String(),
        'progress': 1.0,
        'is_public': true,
      };

      await docRef.set(data);

      return UserAchievementModel.fromJson({
        ...data,
        'id': achievementId,
      });
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  /// Update achievement progress
  /// Uses achievementId as document ID to prevent duplicates
  Future<UserAchievementModel> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required double progress,
  }) async {
    try {
      // Use achievementId as document ID to prevent duplicates
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('user_achievements')
          .doc(achievementId);

      final existingDoc = await docRef.get();

      if (!existingDoc.exists) {
        // Create new user achievement with progress
        final now = DateTime.now();
        final data = {
          'achievement_id': achievementId,
          'user_id': userId,
          'unlocked_at': now.toIso8601String(),
          'progress': progress,
          'is_public': true,
        };

        await docRef.set(data);

        return UserAchievementModel.fromJson({
          ...data,
          'id': achievementId,
        });
      } else {
        // Update existing progress (only if new progress is higher)
        final existingData = existingDoc.data()!;
        final existingProgress = (existingData['progress'] as num?) ?? 0.0;

        if (progress > existingProgress) {
          await docRef.update({'progress': progress});
        }

        return UserAchievementModel.fromJson({
          ...existingData,
          'id': existingDoc.id,
          'progress': progress > existingProgress ? progress : existingProgress,
        });
      }
    } catch (e) {
      throw Exception('Failed to update achievement progress: $e');
    }
  }
}
