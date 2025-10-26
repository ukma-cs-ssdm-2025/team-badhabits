import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:intl/intl.dart';

/// Bar chart widget for displaying habit rating field data
class HabitBarChart extends StatelessWidget {
  const HabitBarChart({
    required this.entries,
    required this.fieldLabel,
    this.maxRating = 5,
    super.key,
  });

  final List<HabitEntry> entries;
  final String fieldLabel;
  final int maxRating;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    final barGroups = _prepareBarGroups();

    if (barGroups.isEmpty) {
      return _buildEmptyState();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fieldLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildAverageBadge(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                _buildBarChartData(barGroups, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Prepare bar groups from entries
  List<BarChartGroupData> _prepareBarGroups() {
    final groups = <BarChartGroupData>[];

    // Sort entries by date
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final value = entry.values[fieldLabel];

      if (value != null && value is num) {
        final rating = value.toInt().clamp(0, maxRating);
        final color = _getRatingColor(rating);

        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: rating.toDouble(),
                color: color,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        );
      }
    }

    return groups;
  }

  /// Get color based on rating value
  Color _getRatingColor(int rating) {
    if (rating <= 2) {
      return Colors.red;
    }
    if (rating == 3) {
      return Colors.orange;
    }
    return Colors.green;
  }

  /// Calculate average rating
  double _calculateAverage() {
    final values = <num>[];

    for (final entry in entries) {
      final value = entry.values[fieldLabel];
      if (value != null && value is num) {
        values.add(value);
      }
    }

    if (values.isEmpty) {
      return 0;
    }

    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Build average badge
  Widget _buildAverageBadge() {
    final avg = _calculateAverage();
    if (avg == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(avg.round()).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: _getRatingColor(avg.round()),
          ),
          const SizedBox(width: 4),
          Text(
            avg.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getRatingColor(avg.round()),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bar chart data
  BarChartData _buildBarChartData(
    List<BarChartGroupData> barGroups,
    BuildContext context,
  ) {
    final avg = _calculateAverage();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxRating.toDouble(),
      minY: 0,
      barGroups: barGroups,
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < 0 || value.toInt() > maxRating) {
                return const SizedBox.shrink();
              }
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= entries.length) {
                return const SizedBox.shrink();
              }

              final sortedEntries = entries.toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              final date = DateTime.parse(sortedEntries[index].date);

              // Show label for every Nth point
              final interval = (entries.length / 5).ceil();
              if (index % interval != 0 && index != entries.length - 1) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('MM/dd').format(date),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
      ),
      borderData: FlBorderData(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final sortedEntries = entries.toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            final date = DateTime.parse(sortedEntries[group.x].date);
            final rating = rod.toY.toInt();

            return BarTooltipItem(
              '${DateFormat('MMM dd').format(date)}\nRating: $rating/$maxRating',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      // Draw average line
      extraLinesData: avg > 0
          ? ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: avg,
                  color: Colors.blue.withValues(alpha: 0.8),
                  dashArray: [5, 5],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    labelResolver: (line) => 'Avg: ${avg.toStringAsFixed(1)}',
                  ),
                ),
              ],
            )
          : null,
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking to see your ratings',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    ),
  );
}
