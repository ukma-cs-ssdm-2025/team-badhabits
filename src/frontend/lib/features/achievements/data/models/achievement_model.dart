import 'package:frontend/features/achievements/domain/entities/achievement.dart';

/// Achievement Model (data layer)
///
/// Handles JSON serialization/deserialization for Achievement entity
class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.name,
    required super.nameUk,
    required super.description,
    required super.descriptionUk,
    required super.type,
    required super.criteria,
    required super.icon,
    required super.tier,
    required super.points,
  });

  /// Create AchievementModel from domain entity
  factory AchievementModel.fromEntity(Achievement achievement) =>
      AchievementModel(
        id: achievement.id,
        name: achievement.name,
        nameUk: achievement.nameUk,
        description: achievement.description,
        descriptionUk: achievement.descriptionUk,
        type: achievement.type,
        criteria: achievement.criteria,
        icon: achievement.icon,
        tier: achievement.tier,
        points: achievement.points,
      );

  /// Create AchievementModel from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] as String,
        name: json['name'] as String,
        nameUk: json['name_uk'] as String? ?? json['name'] as String,
        description: json['description'] as String,
        descriptionUk: json['description_uk'] as String? ??
            json['description'] as String,
        type: _parseAchievementType(json['type'] as String),
        criteria: Map<String, dynamic>.from(json['criteria'] as Map),
        icon: json['icon'] as String,
        tier: _parseAchievementTier(json['tier'] as String),
        points: json['points'] as int? ?? 10,
      );

  /// Convert AchievementModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_uk': nameUk,
        'description': description,
        'description_uk': descriptionUk,
        'type': type.name,
        'criteria': criteria,
        'icon': icon,
        'tier': tier.name,
        'points': points,
      };

  /// Convert to domain entity
  Achievement toEntity() => Achievement(
        id: id,
        name: name,
        nameUk: nameUk,
        description: description,
        descriptionUk: descriptionUk,
        type: type,
        criteria: criteria,
        icon: icon,
        tier: tier,
        points: points,
      );

  /// Parse achievement type from string
  static AchievementType _parseAchievementType(String type) {
    switch (type.toLowerCase()) {
      case 'streak':
        return AchievementType.streak;
      case 'habit':
        return AchievementType.habit;
      case 'workout':
        return AchievementType.workout;
      case 'milestone':
        return AchievementType.milestone;
      case 'special':
        return AchievementType.special;
      default:
        return AchievementType.special;
    }
  }

  /// Parse achievement tier from string
  static AchievementTier _parseAchievementTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return AchievementTier.bronze;
      case 'silver':
        return AchievementTier.silver;
      case 'gold':
        return AchievementTier.gold;
      case 'platinum':
        return AchievementTier.platinum;
      default:
        return AchievementTier.bronze;
    }
  }
}
