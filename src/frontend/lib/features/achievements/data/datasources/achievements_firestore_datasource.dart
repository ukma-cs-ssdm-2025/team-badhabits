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
  Future<UserAchievementModel> unlockAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('user_achievements')
          .doc();

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
        'id': docRef.id,
      });
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  /// Update achievement progress
  Future<UserAchievementModel> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required double progress,
  }) async {
    try {
      // Find existing user achievement
      final query = await firestore
          .collection('users')
          .doc(userId)
          .collection('user_achievements')
          .where('achievement_id', isEqualTo: achievementId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        // Create new user achievement with progress
        final docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('user_achievements')
            .doc();

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
          'id': docRef.id,
        });
      } else {
        // Update existing progress
        final doc = query.docs.first;
        await doc.reference.update({'progress': progress});

        return UserAchievementModel.fromJson({
          ...doc.data(),
          'id': doc.id,
          'progress': progress,
        });
      }
    } catch (e) {
      throw Exception('Failed to update achievement progress: $e');
    }
  }
}
