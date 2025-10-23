import 'package:flutter/material.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Habits tracking coming soon',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      heroTag: 'habits_fab',
      onPressed: () {
        // TODO: Add habit functionality
      },
      child: const Icon(Icons.add),
    ),
  );
}
