import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:frontend/core/error/exceptions.dart';
import 'package:frontend/features/workouts/data/models/workout_model.dart';
import 'package:http/http.dart' as http;

/// Response model for adaptive recommendation API
class AdaptiveRecommendationResponse {
  AdaptiveRecommendationResponse({
    required this.workout,
    required this.recommendation,
  });

  factory AdaptiveRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return AdaptiveRecommendationResponse(
      workout: WorkoutModel.fromJson(data['workout'] as Map<String, dynamic>),
      recommendation:
          RecommendationInfo.fromJson(data['recommendation'] as Map<String, dynamic>),
    );
  }

  final WorkoutModel workout;
  final RecommendationInfo recommendation;
}

/// Recommendation metadata from backend
class RecommendationInfo {
  RecommendationInfo({
    required this.reason,
    required this.basedOnSessions,
    required this.averageRating,
    required this.targetDifficulty,
    required this.userFitnessLevel,
  });

  factory RecommendationInfo.fromJson(Map<String, dynamic> json) =>
      RecommendationInfo(
        reason: json['reason'] as String? ?? 'Personalized for you',
        basedOnSessions: json['basedOnSessions'] as int? ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        targetDifficulty: json['targetDifficulty'] as String? ?? 'intermediate',
        userFitnessLevel: json['userFitnessLevel'] as String? ?? 'intermediate',
      );

  final String reason;
  final int basedOnSessions;
  final double? averageRating;
  final String targetDifficulty;
  final String userFitnessLevel;
}

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
  /// Calls GET /api/v1/adaptive/recommend?userId=xxx
  /// Backend adapts workout based on user's workout history and ratings (FR-014)
  Future<AdaptiveRecommendationResponse> getRecommendedWorkout({
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/adaptive/recommend').replace(
        queryParameters: {'userId': userId},
      );

      developer.log(
        'Fetching recommendation for user $userId from $url',
        name: 'workouts.datasource',
      );

      final response = await client
          .get(
            url,
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              developer.log(
                'Railway API timeout after 15s for user $userId',
                name: 'workouts.datasource',
                level: 1000,
              );
              throw const ServerException(
                'Request timeout. Server is taking too long to respond.',
              );
            },
          );

      developer.log(
        'Recommendation API response: ${response.statusCode}',
        name: 'workouts.datasource',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for success flag
        if (json['success'] == false) {
          final error = json['error'] as Map<String, dynamic>?;
          throw ServerException(
            error?['message'] as String? ?? 'Failed to get recommendation',
          );
        }

        return AdaptiveRecommendationResponse.fromJson(json);
      } else if (response.statusCode == 400) {
        throw const ServerException('Invalid request: userId is required');
      } else if (response.statusCode == 422) {
        throw const ServerException('Validation error: Invalid request');
      } else if (response.statusCode == 500) {
        throw const ServerException('Server error: Backend is unavailable');
      } else {
        throw ServerException(
          'Failed to get recommendation (${response.statusCode})',
        );
      }
    } on TimeoutException catch (e) {
      developer.log(
        'Network timeout - $e',
        name: 'workouts.datasource',
        level: 1000,
      );
      throw const ServerException(
        'Connection timeout. Please check your internet connection.',
      );
    } catch (e, stackTrace) {
      if (e is ServerException) {
        rethrow;
      }
      developer.log(
        'Unexpected error in getRecommendedWorkout: $e\nType: ${e.runtimeType}\nStack: $stackTrace',
        name: 'workouts.datasource',
        level: 1000,
      );
      throw ServerException('Network error: ${e.runtimeType} - $e');
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
