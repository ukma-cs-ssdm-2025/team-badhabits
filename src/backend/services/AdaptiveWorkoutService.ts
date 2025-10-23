/**
 * AdaptiveWorkoutService - ML-based workout generation and adaptation
 * Lab 6: Testing & Debugging - Service implementation
 */

import {
  UserData,
  Workout,
  Exercise,
  WorkoutRating,
  FitnessLevel,
  InjuryType,
} from '../models/Workout';

/**
 * Exercise database with difficulty levels and affected areas
 */
const EXERCISE_DATABASE: Exercise[] = [
  // Beginner exercises
  { name: 'Push-ups', sets: 3, reps: 10, rest_seconds: 60, difficulty: 3, affected_areas: ['chest', 'arms'], calories_burned: 50 },
  { name: 'Bodyweight Squats', sets: 3, reps: 15, rest_seconds: 60, difficulty: 2, affected_areas: ['legs'], calories_burned: 60 },
  { name: 'Plank', sets: 3, reps: 1, duration_seconds: 30, rest_seconds: 60, difficulty: 3, affected_areas: ['core'], calories_burned: 30 },
  { name: 'Wall Sits', sets: 3, reps: 1, duration_seconds: 30, rest_seconds: 60, difficulty: 3, affected_areas: ['legs'], calories_burned: 40 },

  // Intermediate exercises
  { name: 'Burpees', sets: 3, reps: 12, rest_seconds: 60, difficulty: 6, affected_areas: ['full_body'], calories_burned: 100 },
  { name: 'Lunges', sets: 3, reps: 12, rest_seconds: 60, difficulty: 5, affected_areas: ['legs'], calories_burned: 70 },
  { name: 'Mountain Climbers', sets: 3, reps: 20, rest_seconds: 45, difficulty: 6, affected_areas: ['core', 'cardio'], calories_burned: 80 },
  { name: 'Dumbbell Rows', sets: 3, reps: 12, rest_seconds: 60, difficulty: 5, equipment: 'dumbbells', affected_areas: ['back'], calories_burned: 60 },

  // Advanced exercises
  { name: 'Pull-ups', sets: 4, reps: 8, rest_seconds: 90, difficulty: 8, equipment: 'pull-up bar', affected_areas: ['back', 'arms'], calories_burned: 90 },
  { name: 'Pistol Squats', sets: 3, reps: 8, rest_seconds: 90, difficulty: 9, affected_areas: ['legs'], calories_burned: 80 },
  { name: 'Handstand Push-ups', sets: 3, reps: 6, rest_seconds: 120, difficulty: 10, affected_areas: ['shoulders', 'arms'], calories_burned: 100 },
  { name: 'Box Jumps', sets: 4, reps: 10, rest_seconds: 90, difficulty: 7, equipment: 'box', affected_areas: ['legs', 'cardio'], calories_burned: 90 },
];

/**
 * Exercises to avoid based on injury type
 */
const INJURY_RESTRICTIONS: Record<InjuryType, string[]> = {
  knee: ['legs'],
  shoulder: ['shoulders', 'arms'],
  back: ['back', 'core'],
  ankle: ['legs'],
  wrist: ['arms'],
  none: [],
};

export class AdaptiveWorkoutService {
  /**
   * Generate a personalized workout based on user data
   * @param userData - User profile and fitness data
   * @returns Generated workout plan
   */
  generateWorkout(userData: UserData): Workout {
    // Calculate intensity level based on fitness level
    const intensityScore = this.calculateIntensity(userData.fitness_level);

    // Filter exercises based on user constraints
    const availableExercises = this.filterExercisesByConstraints(
      userData,
      intensityScore
    );

    if (availableExercises.length === 0) {
      throw new Error('No suitable exercises found for user constraints');
    }

    // Select exercises for the workout
    const selectedExercises = this.selectExercises(
      availableExercises,
      userData.preferred_duration_minutes,
      intensityScore
    );

    // Calculate workout metrics
    const totalDuration = this.calculateTotalDuration(selectedExercises);
    const estimatedCalories = this.calculateEstimatedCalories(selectedExercises);

    const workout: Workout = {
      id: this.generateWorkoutId(),
      user_id: userData.user_id,
      title: this.generateWorkoutTitle(userData.fitness_level),
      description: `Personalized ${userData.fitness_level} workout`,
      exercises: selectedExercises,
      total_duration_minutes: totalDuration,
      estimated_calories: estimatedCalories,
      difficulty: userData.fitness_level,
      difficulty_score: intensityScore,
      created_at: new Date(),
      is_verified: true,
      tags: this.generateTags(userData),
    };

    return workout;
  }

  /**
   * Calculate intensity score based on fitness level
   * @param fitnessLevel - User's fitness level
   * @returns Intensity score (1-10)
   */
  calculateIntensity(fitnessLevel: FitnessLevel): number {
    const intensityMap: Record<FitnessLevel, number> = {
      beginner: 3,
      intermediate: 6,
      advanced: 8,
      expert: 10,
    };

    return intensityMap[fitnessLevel];
  }

  /**
   * Adapt workout difficulty based on user rating
   * @param rating - User's workout rating
   * @param currentWorkout - Current workout plan
   * @param userData - User profile data
   * @returns Adapted workout plan
   */
  adaptDifficulty(
    rating: WorkoutRating,
    currentWorkout: Workout,
    userData: UserData
  ): Workout {
    let newIntensity = currentWorkout.difficulty_score;

    // Adapt based on difficulty rating
    // 1-2: Too easy, increase difficulty
    // 3: Just right, maintain
    // 4-5: Too hard, decrease difficulty
    if (rating.difficulty_rating <= 2) {
      newIntensity = Math.min(10, newIntensity + 2);
    } else if (rating.difficulty_rating >= 4) {
      newIntensity = Math.max(1, newIntensity - 2);
    }

    // Update fitness level if needed
    const newFitnessLevel = this.getFitnessLevelFromIntensity(newIntensity);

    // Generate new workout with adapted difficulty
    const adaptedUserData: UserData = {
      ...userData,
      fitness_level: newFitnessLevel,
      past_ratings: [...userData.past_ratings, rating],
    };

    return this.generateWorkout(adaptedUserData);
  }

  /**
   * Save workout to Firebase (mock implementation for testing)
   * @param workout - Workout to save
   * @returns Promise with saved workout ID
   */
  async saveWorkoutToFirebase(workout: Workout): Promise<string> {
    // Mock Firebase save - in real implementation, this would call Firebase SDK
    return Promise.resolve(workout.id || this.generateWorkoutId());
  }

  // ==================== Private Helper Methods ====================

  private filterExercisesByConstraints(
    userData: UserData,
    intensityScore: number
  ): Exercise[] {
    let exercises = [...EXERCISE_DATABASE];

    // Filter by difficulty level (±2 points from intensity score)
    exercises = exercises.filter(
      ex => Math.abs(ex.difficulty - intensityScore) <= 3
    );

    // Filter by available equipment
    exercises = exercises.filter(
      ex => !ex.equipment || userData.available_equipment.includes(ex.equipment)
    );

    // Filter by injuries
    const restrictedAreas = userData.injuries.flatMap(
      injury => INJURY_RESTRICTIONS[injury] || []
    );

    if (restrictedAreas.length > 0) {
      exercises = exercises.filter(
        ex => !ex.affected_areas.some(area => restrictedAreas.includes(area))
      );
    }

    return exercises;
  }

  private selectExercises(
    availableExercises: Exercise[],
    targetDuration: number,
    intensityScore: number
  ): Exercise[] {
    const selected: Exercise[] = [];
    let currentDuration = 0;
    const targetDurationSeconds = targetDuration * 60;

    // Shuffle exercises for variety
    const shuffled = [...availableExercises].sort(() => Math.random() - 0.5);

    // Select exercises until we reach target duration
    for (const exercise of shuffled) {
      if (selected.length >= 8) break; // Max 8 exercises per workout

      const exerciseDuration = this.calculateExerciseDuration(exercise);

      if (currentDuration + exerciseDuration <= targetDurationSeconds * 1.2) {
        selected.push(exercise);
        currentDuration += exerciseDuration;
      }

      if (currentDuration >= targetDurationSeconds * 0.8) break;
    }

    // Ensure at least 3 exercises
    if (selected.length < 3 && availableExercises.length >= 3) {
      return availableExercises.slice(0, 3);
    }

    return selected;
  }

  private calculateExerciseDuration(exercise: Exercise): number {
    const repTime = 3; // Assume 3 seconds per rep
    const totalWorkSeconds = exercise.sets * (exercise.reps * repTime + exercise.rest_seconds);
    return totalWorkSeconds;
  }

  private calculateTotalDuration(exercises: Exercise[]): number {
    const totalSeconds = exercises.reduce(
      (sum, ex) => sum + this.calculateExerciseDuration(ex),
      0
    );
    return Math.ceil(totalSeconds / 60);
  }

  private calculateEstimatedCalories(exercises: Exercise[]): number {
    return exercises.reduce((sum, ex) => sum + (ex.calories_burned || 0), 0);
  }

  private generateWorkoutId(): string {
    return `workout_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private generateWorkoutTitle(fitnessLevel: FitnessLevel): string {
    const titles: Record<FitnessLevel, string[]> = {
      beginner: ['Starter Workout', 'Foundation Builder', 'Beginner Blast'],
      intermediate: ['Power Routine', 'Strength Session', 'Balanced Workout'],
      advanced: ['Intense Training', 'Advanced Circuit', 'Elite Routine'],
      expert: ['Extreme Challenge', 'Master Workout', 'Peak Performance'],
    };

    const options = titles[fitnessLevel];
    return options[Math.floor(Math.random() * options.length)];
  }

  private generateTags(userData: UserData): string[] {
    const tags: string[] = [userData.fitness_level];

    if (userData.goals.includes('weight_loss')) tags.push('fat-burn');
    if (userData.goals.includes('muscle_gain')) tags.push('strength');
    if (userData.available_equipment.length === 0) tags.push('bodyweight');

    return tags;
  }

  private getFitnessLevelFromIntensity(intensity: number): FitnessLevel {
    if (intensity <= 3) return 'beginner';
    if (intensity <= 6) return 'intermediate';
    if (intensity <= 8) return 'advanced';
    return 'expert';
  }
}
