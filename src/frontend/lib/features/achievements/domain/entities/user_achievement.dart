import 'package:equatable/equatable.dart';

/// UserAchievement Entity (domain layer)
///
/// Represents a user's earned achievement
class UserAchievement extends Equatable {
  const UserAchievement({
    required this.id,
    required this.achievementId,
    required this.userId,
    required this.unlockedAt,
    required this.progress,
    required this.isPublic,
  });

  final String id;
  final String achievementId;
  final String userId;
  final DateTime unlockedAt;
  final double progress; // 0.0 to 1.0 (0% to 100%)
  final bool isPublic;

  /// Check if achievement is unlocked
  bool get isUnlocked => progress >= 1.0;

  /// Get progress percentage
  int get progressPercentage => (progress * 100).round();

  @override
  List<Object?> get props => [
        id,
        achievementId,
        userId,
        unlockedAt,
        progress,
        isPublic,
      ];
}
