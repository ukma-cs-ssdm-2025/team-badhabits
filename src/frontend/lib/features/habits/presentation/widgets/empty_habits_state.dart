import 'package:flutter/material.dart';

/// Widget displayed when user has no habits yet
class EmptyHabitsState extends StatelessWidget {
  const EmptyHabitsState({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 24),
        Text(
          'No habits yet',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Start building better habits by creating your first one',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {
            // Will be handled by parent page
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Your First Habit'),
        ),
      ],
    ),
  );
}
