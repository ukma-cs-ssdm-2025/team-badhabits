import 'package:equatable/equatable.dart';

/// Achievement Entity (domain layer)
///
/// Represents a single achievement definition in the system
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.name,
    required this.nameUk,
    required this.description,
    required this.descriptionUk,
    required this.type,
    required this.criteria,
    required this.icon,
    required this.tier,
    required this.points,
  });

  final String id;
  final String name;
  final String nameUk;
  final String description;
  final String descriptionUk;
  final AchievementType type;
  final Map<String, dynamic> criteria;
  final String icon;
  final AchievementTier tier;
  final int points;

  @override
  List<Object?> get props => [
        id,
        name,
        nameUk,
        description,
        descriptionUk,
        type,
        criteria,
        icon,
        tier,
        points,
      ];
}

/// Achievement types
enum AchievementType {
  streak,
  habit,
  workout,
  milestone,
  special,
}

/// Achievement tiers (difficulty/rarity)
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}
