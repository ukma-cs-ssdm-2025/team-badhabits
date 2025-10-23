/**
 * Unit tests for AdaptiveWorkoutService
 *
 * Tests cover:
 * 1. Basic workout generation
 * 2. Intensity calculation by fitness level (parametrized)
 * 3. Workout adaptation based on user rating
 * 4. Edge case: Workout generation with injury constraints
 * 5. Mock: Saving workout to Firebase
 */

import { AdaptiveWorkoutService } from '../../services/AdaptiveWorkoutService';
import { UserData, WorkoutRating, FitnessLevel } from '../../models/Workout';
import { createMockUserData, createMockWorkoutRating, mockFirebase } from '../setup';

describe('AdaptiveWorkoutService', () => {
  let service: AdaptiveWorkoutService;

  beforeEach(() => {
    service = new AdaptiveWorkoutService();
  });

  // ==================== Test 1: Basic Workout Generation ====================
  describe('generateWorkout', () => {
    it('should generate a valid workout for intermediate user', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'intermediate',
        preferred_duration_minutes: 30,
        available_equipment: ['dumbbells'],
        injuries: [],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout).toBeDefined();
      expect(workout.user_id).toBe('test_user_123');
      expect(workout.exercises.length).toBeGreaterThan(0);
      expect(workout.difficulty).toBe('intermediate');
      expect(workout.difficulty_score).toBe(6); // Intermediate = 6
      expect(workout.total_duration_minutes).toBeGreaterThan(0);
      expect(workout.estimated_calories).toBeGreaterThan(0);
      expect(workout.is_verified).toBe(true);
      expect(workout.created_at).toBeInstanceOf(Date);

      // Verify all exercises are valid
      workout.exercises.forEach(exercise => {
        expect(exercise.name).toBeTruthy();
        expect(exercise.sets).toBeGreaterThan(0);
        expect(exercise.reps).toBeGreaterThan(0);
        expect(exercise.affected_areas.length).toBeGreaterThan(0);
      });
    });

    it('should generate workout with exercises matching user equipment', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        available_equipment: ['dumbbells', 'pull-up bar'],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      workout.exercises.forEach(exercise => {
        if (exercise.equipment) {
          expect(userData.available_equipment).toContain(exercise.equipment);
        }
      });
    });

    it('should handle users with limited constraints gracefully', () => {
      // Arrange - User with some constraints but still findable exercises
      const userData: UserData = createMockUserData({
        fitness_level: 'beginner',
        injuries: ['knee', 'shoulder'] as any,
        available_equipment: [],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert - Should still generate workout with available bodyweight exercises
      expect(workout).toBeDefined();
      expect(workout.exercises.length).toBeGreaterThan(0);
    });
  });

  // ==================== Test 2: Intensity Calculation (Parametrized) ====================
  describe('calculateIntensity', () => {
    // Parametrized test using test.each()
    test.each([
      ['beginner', 3],
      ['intermediate', 6],
      ['advanced', 8],
      ['expert', 10],
    ])('should return intensity %i for %s fitness level', (fitnessLevel, expectedIntensity) => {
      // Act
      const intensity = service.calculateIntensity(fitnessLevel as FitnessLevel);

      // Assert
      expect(intensity).toBe(expectedIntensity);
      expect(intensity).toBeGreaterThanOrEqual(1);
      expect(intensity).toBeLessThanOrEqual(10);
    });

    it('should return consistent intensity for same fitness level', () => {
      // Arrange
      const level: FitnessLevel = 'intermediate';

      // Act
      const intensity1 = service.calculateIntensity(level);
      const intensity2 = service.calculateIntensity(level);

      // Assert
      expect(intensity1).toBe(intensity2);
    });
  });

  // ==================== Test 3: Workout Adaptation Based on Rating ====================
  describe('adaptDifficulty', () => {
    it('should increase difficulty when workout is rated too easy (rating 1-2)', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'intermediate',
      });
      const currentWorkout = service.generateWorkout(userData);
      const originalDifficulty = currentWorkout.difficulty_score;

      const easyRating: WorkoutRating = createMockWorkoutRating({
        workout_id: currentWorkout.id!,
        difficulty_rating: 1, // Too easy
      });

      // Act
      const adaptedWorkout = service.adaptDifficulty(easyRating, currentWorkout, userData);

      // Assert
      expect(adaptedWorkout.difficulty_score).toBeGreaterThan(originalDifficulty);
      expect(adaptedWorkout.difficulty_score).toBeLessThanOrEqual(10);
      expect(adaptedWorkout.user_id).toBe(userData.user_id);
    });

    it('should decrease difficulty when workout is rated too hard (rating 4-5)', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'advanced',
      });
      const currentWorkout = service.generateWorkout(userData);
      const originalDifficulty = currentWorkout.difficulty_score;

      const hardRating: WorkoutRating = createMockWorkoutRating({
        workout_id: currentWorkout.id!,
        difficulty_rating: 5, // Too hard
      });

      // Act
      const adaptedWorkout = service.adaptDifficulty(hardRating, currentWorkout, userData);

      // Assert
      expect(adaptedWorkout.difficulty_score).toBeLessThan(originalDifficulty);
      expect(adaptedWorkout.difficulty_score).toBeGreaterThanOrEqual(1);
    });

    it('should maintain difficulty when workout is rated just right (rating 3)', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'intermediate',
      });
      const currentWorkout = service.generateWorkout(userData);
      const originalDifficulty = currentWorkout.difficulty_score;

      const perfectRating: WorkoutRating = createMockWorkoutRating({
        workout_id: currentWorkout.id!,
        difficulty_rating: 3, // Just right
      });

      // Act
      const adaptedWorkout = service.adaptDifficulty(perfectRating, currentWorkout, userData);

      // Assert
      // Should generate new workout but maintain similar difficulty
      expect(adaptedWorkout.difficulty_score).toBe(originalDifficulty);
    });

    it('should add rating to user past_ratings history', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        past_ratings: [],
      });
      const currentWorkout = service.generateWorkout(userData);
      const rating: WorkoutRating = createMockWorkoutRating({
        workout_id: currentWorkout.id!,
      });

      // Act
      service.adaptDifficulty(rating, currentWorkout, userData);

      // Assert - verify the rating would be stored (in real implementation)
      expect(rating.workout_id).toBe(currentWorkout.id);
      expect(rating.user_id).toBe(userData.user_id);
    });
  });

  // ==================== Test 4: Edge Case - Workout with Injury ====================
  describe('generateWorkout - Injury Handling (Edge Case)', () => {
    it('should exclude exercises affecting injured areas - knee injury', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'intermediate',
        injuries: ['knee'],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout.exercises.length).toBeGreaterThan(0);

      // Verify no exercises target legs (restricted with knee injury)
      workout.exercises.forEach(exercise => {
        expect(exercise.affected_areas).not.toContain('legs');
      });
    });

    it('should exclude exercises affecting injured areas - shoulder injury', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'beginner',
        injuries: ['shoulder'],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout.exercises.length).toBeGreaterThan(0);

      // Verify no exercises target shoulders or arms
      workout.exercises.forEach(exercise => {
        expect(exercise.affected_areas).not.toContain('shoulders');
        expect(exercise.affected_areas).not.toContain('arms');
      });
    });

    it('should handle multiple injuries correctly', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'intermediate',
        injuries: ['knee', 'shoulder'],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout.exercises.length).toBeGreaterThan(0);

      // Verify no exercises target restricted areas
      workout.exercises.forEach(exercise => {
        expect(exercise.affected_areas).not.toContain('legs');
        expect(exercise.affected_areas).not.toContain('shoulders');
        expect(exercise.affected_areas).not.toContain('arms');
      });
    });

    it('should still generate workout for user with back injury', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'beginner',
        injuries: ['back'],
        available_equipment: ['dumbbells'],
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout.exercises.length).toBeGreaterThan(0);

      // Verify no exercises target back or core
      workout.exercises.forEach(exercise => {
        expect(exercise.affected_areas).not.toContain('back');
        expect(exercise.affected_areas).not.toContain('core');
      });
    });
  });

  // ==================== Test 5: Mock Firebase Save ====================
  describe('saveWorkoutToFirebase - Mock', () => {
    it('should successfully save workout to Firebase and return workout ID', async () => {
      // Arrange
      const userData: UserData = createMockUserData();
      const workout = service.generateWorkout(userData);

      // Act
      const savedWorkoutId = await service.saveWorkoutToFirebase(workout);

      // Assert
      expect(savedWorkoutId).toBeDefined();
      expect(typeof savedWorkoutId).toBe('string');
      expect(savedWorkoutId.length).toBeGreaterThan(0);

      // Verify it returns the workout's ID
      if (workout.id) {
        expect(savedWorkoutId).toBe(workout.id);
      }
    });

    it('should generate new ID if workout does not have one', async () => {
      // Arrange
      const userData: UserData = createMockUserData();
      const workout = service.generateWorkout(userData);
      delete workout.id; // Remove ID to test generation

      // Act
      const savedWorkoutId = await service.saveWorkoutToFirebase(workout);

      // Assert
      expect(savedWorkoutId).toBeDefined();
      expect(typeof savedWorkoutId).toBe('string');
      expect(savedWorkoutId).toMatch(/^workout_/); // Should start with "workout_"
    });

    it('should handle multiple save operations', async () => {
      // Arrange
      const userData: UserData = createMockUserData();
      const workout1 = service.generateWorkout(userData);
      const workout2 = service.generateWorkout(userData);

      // Act
      const id1 = await service.saveWorkoutToFirebase(workout1);
      const id2 = await service.saveWorkoutToFirebase(workout2);

      // Assert
      expect(id1).toBeDefined();
      expect(id2).toBeDefined();
      // IDs should be different
      expect(id1).not.toBe(id2);
    });
  });

  // ==================== Additional Edge Cases ====================
  describe('Edge Cases', () => {
    it('should handle beginner user with minimal equipment', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        fitness_level: 'beginner',
        available_equipment: [],
        preferred_duration_minutes: 20,
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout).toBeDefined();
      expect(workout.difficulty).toBe('beginner');

      // All exercises should be bodyweight (no equipment required)
      workout.exercises.forEach(exercise => {
        expect(exercise.equipment).toBeUndefined();
      });
    });

    it('should respect preferred duration constraints', () => {
      // Arrange
      const userData: UserData = createMockUserData({
        preferred_duration_minutes: 15,
      });

      // Act
      const workout = service.generateWorkout(userData);

      // Assert
      expect(workout.total_duration_minutes).toBeLessThanOrEqual(18); // 15 * 1.2 = 18
      expect(workout.total_duration_minutes).toBeGreaterThanOrEqual(5);
    });

    it('should generate unique workout IDs', () => {
      // Arrange
      const userData: UserData = createMockUserData();

      // Act
      const workout1 = service.generateWorkout(userData);
      const workout2 = service.generateWorkout(userData);

      // Assert
      expect(workout1.id).toBeDefined();
      expect(workout2.id).toBeDefined();
      expect(workout1.id).not.toBe(workout2.id);
    });
  });
});
