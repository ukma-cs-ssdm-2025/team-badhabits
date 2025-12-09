import 'package:equatable/equatable.dart';

/// Recovery Status Types (FR-006)
enum RecoveryStatusType {
  ready,
  moderate,
  overtraining,
}

/// Extension to parse status from string
extension RecoveryStatusTypeExtension on RecoveryStatusType {
  static RecoveryStatusType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'ready':
        return RecoveryStatusType.ready;
      case 'moderate':
        return RecoveryStatusType.moderate;
      case 'overtraining':
        return RecoveryStatusType.overtraining;
      default:
        return RecoveryStatusType.ready;
    }
  }

  String get displayName {
    switch (this) {
      case RecoveryStatusType.ready:
        return 'Ready';
      case RecoveryStatusType.moderate:
        return 'Moderate';
      case RecoveryStatusType.overtraining:
        return 'Overtraining';
    }
  }
}

/// Recovery Status Entity (FR-006)
///
/// Represents personalized recovery recommendation based on training load.
class RecoveryStatus extends Equatable {
  const RecoveryStatus({
    required this.userId,
    required this.status,
    required this.trainingLoad,
    required this.recoveryTimeHours,
    required this.consecutiveHardDays,
    required this.recommendation,
    required this.canTrainToday,
    required this.analyzedDays,
    required this.sessionsAnalyzed,
    this.lastWorkout,
  });

  /// User ID
  final String userId;

  /// Recovery status (ready, moderate, overtraining)
  final RecoveryStatusType status;

  /// Total training load over analyzed period
  /// Training Load = Σ (duration_minutes × difficulty_rating)
  final int trainingLoad;

  /// Estimated recovery time in hours
  final int recoveryTimeHours;

  /// Number of consecutive hard training days (rating >= 4)
  final int consecutiveHardDays;

  /// Human-readable recommendation text
  final String recommendation;

  /// Whether user should train today
  final bool canTrainToday;

  /// Number of days analyzed
  final int analyzedDays;

  /// Number of sessions analyzed
  final int sessionsAnalyzed;

  /// Last workout timestamp
  final DateTime? lastWorkout;

  /// Training load as percentage (0-100) for progress indicator
  /// Scale: 0 = 0%, 1000+ = 100%
  double get trainingLoadPercentage {
    const maxLoad = 1000.0;
    return (trainingLoad / maxLoad).clamp(0.0, 1.0);
  }

  /// Whether user has high consecutive hard days (warning threshold)
  bool get hasHighConsecutiveHardDays => consecutiveHardDays >= 3;

  @override
  List<Object?> get props => [
        userId,
        status,
        trainingLoad,
        recoveryTimeHours,
        consecutiveHardDays,
        recommendation,
        canTrainToday,
        analyzedDays,
        sessionsAnalyzed,
        lastWorkout,
      ];
}
