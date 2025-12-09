import 'package:flutter/material.dart';
import 'package:frontend/features/workouts/domain/entities/recovery_status.dart';

/// Widget to display recovery status and recommendations (FR-006)
class RecoveryStatusCard extends StatelessWidget {
  const RecoveryStatusCard({
    required this.recoveryStatus,
    super.key,
  });

  final RecoveryStatus recoveryStatus;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _getStatusColor(),
            width: 2,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                _getStatusColor().withValues(alpha: 0.1),
                _getStatusColor().withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTrainingLoadIndicator(),
                const SizedBox(height: 16),
                _buildRecommendation(),
                const SizedBox(height: 12),
                _buildStats(),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader() => Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getStatusIcon(),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recovery Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recoveryStatus.status.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          if (recoveryStatus.canTrainToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Can Train',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pause_circle, color: Colors.orange, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Rest Day',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _buildTrainingLoadIndicator() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Training Load',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${recoveryStatus.trainingLoad}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: recoveryStatus.trainingLoadPercentage,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Light',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
              Text(
                'Moderate',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
              Text(
                'Heavy',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      );

  Widget _buildRecommendation() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: _getStatusColor(),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                recoveryStatus.recommendation,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildStats() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatItem(
              Icons.calendar_today,
              '${recoveryStatus.analyzedDays}',
              'Days',
            ),
            const SizedBox(width: 24),
            _buildStatItem(
              Icons.fitness_center,
              '${recoveryStatus.sessionsAnalyzed}',
              'Sessions',
            ),
            const SizedBox(width: 24),
            if (recoveryStatus.consecutiveHardDays > 0)
              _buildStatItem(
                Icons.local_fire_department,
                '${recoveryStatus.consecutiveHardDays}',
                'Hard Days',
                isWarning: recoveryStatus.hasHighConsecutiveHardDays,
              ),
            if (recoveryStatus.consecutiveHardDays > 0 &&
                recoveryStatus.recoveryTimeHours > 0)
              const SizedBox(width: 24),
            if (recoveryStatus.recoveryTimeHours > 0)
              _buildStatItem(
                Icons.timer,
                '${recoveryStatus.recoveryTimeHours}h',
                'Recovery',
              ),
          ],
        ),
      );

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label, {
    bool isWarning = false,
  }) =>
      Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isWarning ? Colors.orange : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? Colors.orange : null,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      );

  Color _getStatusColor() {
    switch (recoveryStatus.status) {
      case RecoveryStatusType.ready:
        return Colors.green;
      case RecoveryStatusType.moderate:
        return Colors.orange;
      case RecoveryStatusType.overtraining:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (recoveryStatus.status) {
      case RecoveryStatusType.ready:
        return Icons.check_circle;
      case RecoveryStatusType.moderate:
        return Icons.warning_amber;
      case RecoveryStatusType.overtraining:
        return Icons.dangerous;
    }
  }
}
