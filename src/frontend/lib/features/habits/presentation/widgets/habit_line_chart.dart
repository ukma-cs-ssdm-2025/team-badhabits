import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:intl/intl.dart';

/// Line chart widget for displaying habit number field data over time
class HabitLineChart extends StatelessWidget {
  const HabitLineChart({
    required this.entries,
    required this.fieldLabel,
    this.unit,
    super.key,
  });

  final List<HabitEntry> entries;
  final String fieldLabel;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    final dataPoints = _prepareDataPoints();

    if (dataPoints.isEmpty) {
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
            Text(
              fieldLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (unit != null)
              Text(
                'Unit: $unit',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                _buildLineChartData(dataPoints, context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Prepare data points from entries
  List<FlSpot> _prepareDataPoints() {
    final spots = <FlSpot>[];

    // Sort entries by date
    final sortedEntries = entries.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final value = entry.values[fieldLabel];

      if (value != null && value is num) {
        spots.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }

    return spots;
  }

  /// Build line chart data
  LineChartData _buildLineChartData(
    List<FlSpot> spots,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Calculate min/max for y-axis
    final values = spots.map((spot) => spot.y).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);

    // Add padding to y-axis
    final yPadding = (maxY - minY) * 0.1;
    final adjustedMinY = (minY - yPadding).clamp(0.0, double.infinity);
    final adjustedMaxY = maxY + yPadding;

    return LineChartData(
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
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            ),
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

              // Sort entries to match data points order
              final sortedEntries = entries.toList()
                ..sort((a, b) => a.date.compareTo(b.date));

              final date = DateTime.parse(sortedEntries[index].date);

              // Show label for every Nth point based on data size
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
      minY: adjustedMinY,
      maxY: adjustedMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
              radius: 4,
              color: primaryColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: primaryColor.withValues(alpha: 0.1),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
            final sortedEntries = entries.toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            final date = DateTime.parse(
              sortedEntries[spot.x.toInt()].date,
            );
            final value = spot.y;

            return LineTooltipItem(
              '${DateFormat('MMM dd').format(date)}\n${value.toStringAsFixed(1)}${unit != null ? ' $unit' : ''}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ),
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
            Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking to see your progress',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    ),
  );
}
