import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';

/// UserAchievement Model (data layer)
///
/// Handles JSON serialization/deserialization for UserAchievement entity
class UserAchievementModel extends UserAchievement {
  const UserAchievementModel({
    required super.id,
    required super.achievementId,
    required super.userId,
    required super.unlockedAt,
    required super.progress,
    required super.isPublic,
  });

  /// Create UserAchievementModel from domain entity
  factory UserAchievementModel.fromEntity(UserAchievement userAchievement) =>
      UserAchievementModel(
        id: userAchievement.id,
        achievementId: userAchievement.achievementId,
        userId: userAchievement.userId,
        unlockedAt: userAchievement.unlockedAt,
        progress: userAchievement.progress,
        isPublic: userAchievement.isPublic,
      );

  /// Create UserAchievementModel from JSON
  factory UserAchievementModel.fromJson(Map<String, dynamic> json) =>
      UserAchievementModel(
        id: json['id'] as String,
        achievementId: json['achievement_id'] as String,
        userId: json['user_id'] as String,
        unlockedAt: json['unlocked_at'] is String
            ? DateTime.parse(json['unlocked_at'] as String)
            : (json['unlocked_at'] as DateTime),
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        isPublic: json['is_public'] as bool? ?? true,
      );

  /// Convert UserAchievementModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'achievement_id': achievementId,
        'user_id': userId,
        'unlocked_at': unlockedAt.toIso8601String(),
        'progress': progress,
        'is_public': isPublic,
      };

  /// Convert to domain entity
  UserAchievement toEntity() => UserAchievement(
        id: id,
        achievementId: achievementId,
        userId: userId,
        unlockedAt: unlockedAt,
        progress: progress,
        isPublic: isPublic,
      );
}
