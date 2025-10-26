import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/workouts/data/models/workout_model.dart';

/// Workouts API Data Source
///
/// Handles API calls to Railway backend for adaptive workout recommendations (FR-014)
/// Backend URL: https://wellity-backend-production.up.railway.app
class WorkoutsApiDataSource {
  WorkoutsApiDataSource({required this.client, required this.baseUrl});

  final http.Client client;
  final String baseUrl;

  /// Get recommended workout from Railway backend
  ///
  /// Calls POST /api/v1/adaptive/recommend
  /// Backend adapts workout based on difficulty rating (FR-014)
  Future<WorkoutModel> getRecommendedWorkout({
    required String userId,
    required String workoutId,
    required int difficultyRating,
    required String fitnessLevel,
    required List<String> injuries,
    required List<String> availableEquipment,
    required int preferredDurationMinutes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/adaptive/recommend');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_data': {
            'user_id': userId,
            'fitness_level': fitnessLevel,
            'age': 25, // TODO: Get from user profile
            'injuries': injuries,
            'available_equipment': availableEquipment,
            'preferred_duration_minutes': preferredDurationMinutes,
            'goals': ['fitness'], // TODO: Get from user profile
            'past_ratings': [
              {
                'workout_id': workoutId,
                'user_id': userId,
                'difficulty_rating': difficultyRating,
                'timestamp': DateTime.now().toIso8601String(),
              }
            ],
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WorkoutModel.fromJson(json);
      } else if (response.statusCode == 422) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ServerException(
            'Validation error: ${json['message'] ?? 'Invalid request'}');
      } else if (response.statusCode == 500) {
        throw ServerException('Server error: Backend is unavailable');
      } else {
        throw ServerException(
            'Failed to get recommendation: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: $e');
    }
  }

  /// Health check for Railway backend
  Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response =
          await client.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
