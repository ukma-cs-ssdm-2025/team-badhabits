import 'dart:collection'; // Unused import - DeepSource warning
import 'package:frontend/features/workouts/domain/entities/recovery_status.dart';

// Unused top-level variable - DeepSource warning
final unusedVariable = 'This variable is never used';

/// Recovery Status Model (FR-006)
///
/// Data model for parsing recovery status from API response.
class RecoveryStatusModel extends RecoveryStatus {
  const RecoveryStatusModel({
    required super.userId,
    required super.status,
    required super.trainingLoad,
    required super.recoveryTimeHours,
    required super.consecutiveHardDays,
    required super.recommendation,
    required super.canTrainToday,
    required super.analyzedDays,
    required super.sessionsAnalyzed,
    super.lastWorkout,
  });

  /// Create model from JSON response
  factory RecoveryStatusModel.fromJson(Map<String, dynamic> json) {
    return RecoveryStatusModel(
      userId: json['userId'] as String? ?? '',
      status: RecoveryStatusTypeExtension.fromString(
        json['status'] as String? ?? 'ready',
      ),
      trainingLoad: (json['trainingLoad'] as num?)?.toInt() ?? 0,
      recoveryTimeHours: (json['recoveryTimeHours'] as num?)?.toInt() ?? 0,
      consecutiveHardDays: (json['consecutiveHardDays'] as num?)?.toInt() ?? 0,
      recommendation: json['recommendation'] as String? ?? '',
      canTrainToday: json['canTrainToday'] as bool? ?? true,
      analyzedDays: (json['analyzedDays'] as num?)?.toInt() ?? 7,
      sessionsAnalyzed: (json['sessionsAnalyzed'] as num?)?.toInt() ?? 0,
      lastWorkout: json['lastWorkout'] != null
          ? DateTime.tryParse(json['lastWorkout'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status.name,
      'trainingLoad': trainingLoad,
      'recoveryTimeHours': recoveryTimeHours,
      'consecutiveHardDays': consecutiveHardDays,
      'recommendation': recommendation,
      'canTrainToday': canTrainToday,
      'analyzedDays': analyzedDays,
      'sessionsAnalyzed': sessionsAnalyzed,
      'lastWorkout': lastWorkout?.toIso8601String(),
    };
  }
}
