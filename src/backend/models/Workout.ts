/**
 * TypeScript interfaces and types for Workout domain models
 * Lab 6: Testing & Debugging - Type definitions
 */

export type FitnessLevel = 'beginner' | 'intermediate' | 'advanced' | 'expert';
export type InjuryType = 'knee' | 'shoulder' | 'back' | 'ankle' | 'wrist' | 'none';
export type DifficultyRating = 1 | 2 | 3 | 4 | 5; // 1=too easy, 5=too hard

/**
 * Individual exercise within a workout
 */
export interface Exercise {
  name: string;
  sets: number;
  reps: number;
  duration_seconds?: number;
  rest_seconds: number;
  difficulty: number; // 1-10
  equipment?: string;
  affected_areas: string[]; // muscle groups: chest, back, legs, etc.
  calories_burned?: number;
}

/**
 * User rating for a completed workout
 */
export interface WorkoutRating {
  workout_id: string;
  user_id: string;
  difficulty_rating: DifficultyRating;
  enjoyment_rating?: number; // 1-5
  completion_time_seconds?: number;
  notes?: string;
  timestamp: Date;
}

/**
 * User profile data for personalized workout generation
 */
export interface UserData {
  user_id: string;
  fitness_level: FitnessLevel;
  age: number;
  weight_kg?: number;
  height_cm?: number;
  injuries: InjuryType[];
  available_equipment: string[];
  preferred_duration_minutes: number;
  goals: string[];
  past_ratings: WorkoutRating[];
}

/**
 * Complete workout plan
 */
export interface Workout {
  id?: string;
  user_id: string;
  title: string;
  description?: string;
  exercises: Exercise[];
  total_duration_minutes: number;
  estimated_calories: number;
  difficulty: FitnessLevel;
  difficulty_score: number; // 1-10 numeric representation
  created_at: Date;
  is_verified: boolean;
  tags: string[];
}

/**
 * Request payload for generating a new workout
 */
export interface WorkoutGenerationRequest {
  user_data: UserData;
  target_muscle_groups?: string[];
  exclude_exercises?: string[];
  intensity_override?: number; // 1-10
}

/**
 * Request to adapt workout based on user feedback
 */
export interface WorkoutAdaptationRequest {
  workout_id: string;
  rating: WorkoutRating;
  user_data: UserData;
}

/**
 * Payment-related interfaces
 */
export interface PaymentRequest {
  user_id: string;
  amount: number;
  currency: string;
  payment_method: string;
  subscription_tier: 'basic' | 'premium' | 'pro';
}

export interface PaymentResponse {
  success: boolean;
  transaction_id?: string;
  error_message?: string;
  timestamp: Date;
}

/**
 * Helper functions for workout validation
 */
export class WorkoutValidator {
  static isValidFitnessLevel(level: string): level is FitnessLevel {
    return ['beginner', 'intermediate', 'advanced', 'expert'].includes(level);
  }

  static isValidDifficultyRating(rating: number): rating is DifficultyRating {
    return [1, 2, 3, 4, 5].includes(rating);
  }

  static validateExercise(exercise: Exercise): boolean {
    return (
      exercise.name.length > 0 &&
      exercise.sets >= 1 && exercise.sets <= 10 &&
      exercise.reps >= 1 && exercise.reps <= 100 &&
      exercise.rest_seconds >= 0 && exercise.rest_seconds <= 600 &&
      exercise.difficulty >= 1 && exercise.difficulty <= 10 &&
      exercise.affected_areas.length > 0
    );
  }

  static validateWorkout(workout: Workout): boolean {
    return (
      workout.user_id.length > 0 &&
      workout.exercises.length >= 1 &&
      workout.exercises.every(ex => this.validateExercise(ex)) &&
      workout.total_duration_minutes >= 5 &&
      workout.difficulty_score >= 1 && workout.difficulty_score <= 10 &&
      this.isValidFitnessLevel(workout.difficulty)
    );
  }
}
