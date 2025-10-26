import 'package:flutter/material.dart';
import 'package:frontend/features/habits/domain/usecases/get_habit_statistics.dart';

/// Grid with 4 summary cards for key habit metrics
class HabitSummaryCards extends StatelessWidget {
  const HabitSummaryCards({
    required this.statistics,
    super.key,
  });

  final HabitStatistics statistics;

  @override
  Widget build(BuildContext context) {
    // Calculate completion rate
    final totalDays = DateTime.now().difference(statistics.habit.createdAt).inDays + 1;
    final completionRate = totalDays > 0
        ? (statistics.totalEntries / totalDays * 100).clamp(0, 100)
        : 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          context,
          title: 'Current Streak',
          value: '${statistics.currentStreak}',
          suffix: statistics.currentStreak == 1 ? 'day' : 'days',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        _buildCard(
          context,
          title: 'Longest Streak',
          value: '${statistics.longestStreak}',
          suffix: statistics.longestStreak == 1 ? 'day' : 'days',
          icon: Icons.emoji_events,
          color: Colors.amber,
        ),
        _buildCard(
          context,
          title: 'Completion Rate',
          value: completionRate.toStringAsFixed(0),
          suffix: '%',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildCard(
          context,
          title: 'Total Entries',
          value: '${statistics.totalEntries}',
          suffix: '',
          icon: Icons.list_alt,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    required String suffix,
    required IconData icon,
    required Color color,
  }) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffix.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      suffix,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
