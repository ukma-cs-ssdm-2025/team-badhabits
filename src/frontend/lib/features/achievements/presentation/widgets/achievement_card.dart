import 'package:flutter/material.dart';
import 'package:frontend/features/achievements/domain/entities/achievement.dart';
import 'package:frontend/features/achievements/domain/entities/user_achievement.dart';

/// Achievement card widget displaying a single achievement
class AchievementCard extends StatelessWidget {
  const AchievementCard({
    required this.achievement,
    this.userAchievement,
    this.onTap,
    super.key,
  });

  final Achievement achievement;
  final UserAchievement? userAchievement;
  final VoidCallback? onTap;

  /// Check if achievement is unlocked
  bool get isUnlocked => userAchievement?.isUnlocked ?? false;

  /// Get progress percentage (0.0 to 1.0)
  double get progress => userAchievement?.progress ?? 0.0;

  /// Get type color based on achievement type
  Color _getTypeColor() {
    switch (achievement.type) {
      case AchievementType.streak:
        return Colors.orange;
      case AchievementType.habit:
        return Colors.teal;
      case AchievementType.workout:
        return Colors.blue;
      case AchievementType.milestone:
        return Colors.purple;
      case AchievementType.special:
        return Colors.amber;
    }
  }

  /// Get type icon
  IconData _getTypeIcon() {
    switch (achievement.type) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.habit:
        return Icons.track_changes;
      case AchievementType.workout:
        return Icons.fitness_center;
      case AchievementType.milestone:
        return Icons.flag;
      case AchievementType.special:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor();
    final progressPercent = (progress * 100).toInt();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left side - Icon with colored background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? typeColor.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(),
                  size: 28,
                  color: isUnlocked ? typeColor : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 12),
              // Middle - Title, description, progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isUnlocked ? null : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUnlocked ? Colors.green : typeColor,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$progressPercent%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side - Points with star
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: isUnlocked ? Colors.amber : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.points}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isUnlocked ? null : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
