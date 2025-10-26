import 'package:flutter/material.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';

/// Card widget for displaying habit information in a list
class HabitCard extends StatelessWidget {
  const HabitCard({
    required this.habit,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.currentStreak,
    super.key,
  });

  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int? currentStreak;

  /// Get icon based on habit name keywords
  IconData _getHabitIcon() {
    final name = habit.name.toLowerCase();
    if (name.contains('water') || name.contains('drink')) {
      return Icons.water_drop;
    } else if (name.contains('exercise') ||
        name.contains('workout') ||
        name.contains('fitness')) {
      return Icons.fitness_center;
    } else if (name.contains('sleep') || name.contains('rest')) {
      return Icons.nightlight_round;
    } else if (name.contains('read') || name.contains('book')) {
      return Icons.menu_book;
    } else if (name.contains('meditat')) {
      return Icons.self_improvement;
    } else if (name.contains('food') || name.contains('meal')) {
      return Icons.restaurant;
    } else if (name.contains('walk') || name.contains('run')) {
      return Icons.directions_walk;
    } else {
      return Icons.track_changes;
    }
  }

  /// Get color based on field types
  Color _getHabitColor() {
    if (habit.fields.any((f) => f.type == 'rating')) {
      return Colors.purple;
    } else if (habit.fields.any((f) => f.type == 'number')) {
      return Colors.blue;
    } else {
      return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = _getHabitColor();
    final habitIcon = _getHabitIcon();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Habit icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      habitIcon,
                      color: habitColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Habit name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${habit.fields.length} ${habit.fields.length == 1 ? 'field' : 'fields'} tracked',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak badge
                  if (currentStreak != null && currentStreak! > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildStreakBadge(),
                    ),
                  // More options button
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Field chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: habit.fields.take(3).map((field) {
                  IconData fieldIcon;
                  if (field.type == 'number') {
                    fieldIcon = Icons.numbers;
                  } else if (field.type == 'rating') {
                    fieldIcon = Icons.star;
                  } else {
                    fieldIcon = Icons.text_fields;
                  }

                  return Chip(
                    avatar: Icon(fieldIcon, size: 16),
                    label: Text(
                      field.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
              if (habit.fields.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${habit.fields.length - 3} more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build streak badge widget
  Widget _buildStreakBadge() {
    final isHotStreak = currentStreak! >= 7;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: isHotStreak
            ? const LinearGradient(
                colors: [Colors.orange, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isHotStreak ? null : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isHotStreak
            ? [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 18,
            color: isHotStreak ? Colors.white : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '$currentStreak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isHotStreak ? Colors.white : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
