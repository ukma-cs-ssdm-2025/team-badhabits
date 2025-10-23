import 'package:flutter/material.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Workouts feature coming soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'workouts_fab',
      onPressed: () {
        // TODO: Add workout functionality
      },
      child: const Icon(Icons.add),
    ),
  );
}
