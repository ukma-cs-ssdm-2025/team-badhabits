const express = require('express');
const { body } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { NotFoundError } = require('../utils/errors');
const router = express.Router();

/**
 * @swagger
 * /api/v1/adaptive/recommend:
 *   post:
 *     summary: Get adaptive workout recommendation
 *     description: Returns a personalized workout recommendation based on user ratings and performance history (FR-014)
 *     tags:
 *       - Adaptive Workouts
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - previousWorkoutId
 *               - userRating
 *             properties:
 *               userId:
 *                 type: string
 *                 description: User ID from Firebase Auth
 *                 example: "user123"
 *               previousWorkoutId:
 *                 type: string
 *                 description: ID of the completed workout
 *                 example: "workout456"
 *               userRating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 description: User's rating of workout difficulty
 *                 example: 4
 *               performanceMetrics:
 *                 type: object
 *                 properties:
 *                   completionRate:
 *                     type: number
 *                     description: Percentage of workout completed
 *                     example: 95.5
 *                   averageHeartRate:
 *                     type: integer
 *                     example: 145
 *     responses:
 *       200:
 *         description: Workout recommendation generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 workoutId:
 *                   type: string
 *                   example: "workout789"
 *                 title:
 *                   type: string
 *                   example: "Full Body Strength - Intermediate"
 *                 trainerId:
 *                   type: string
 *                   example: "trainer101"
 *                 exercises:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       name:
 *                         type: string
 *                         example: "Push-ups"
 *                       sets:
 *                         type: integer
 *                         example: 3
 *                       reps:
 *                         type: integer
 *                         example: 12
 *                       restSeconds:
 *                         type: integer
 *                         example: 60
 *                 difficultyLevel:
 *                   type: string
 *                   enum: [beginner, intermediate, advanced]
 *                   example: "intermediate"
 *                 estimatedDuration:
 *                   type: integer
 *                   description: Duration in minutes
 *                   example: 45
 *                 adaptationReason:
 *                   type: string
 *                   example: "Increased intensity based on positive rating and high completion rate"
 *       400:
 *         description: Invalid request parameters
 *       401:
 *         description: Unauthorized - Invalid or missing token
 */
router.post('/recommend', [
  body('userId').notEmpty().withMessage('userId is required'),
  body('previousWorkoutId').notEmpty().withMessage('previousWorkoutId is required'),
  body('userRating').isInt({ min: 1, max: 5 }).withMessage('userRating must be between 1 and 5'),
  validateRequest,
], (req, res, next) => {
  try {
    const { userId, previousWorkoutId, userRating, performanceMetrics } = req.body;

    // Mock 404 check for non-existent resources
    if (userId === 'nonexistent') {
      throw new NotFoundError('User');
    }

    if (previousWorkoutId === 'nonexistent') {
      throw new NotFoundError('Previous workout');
    }

    // Determine difficulty level based on rating
    const difficultyLevel = userRating >= 4 ? 'advanced' : userRating >= 3 ? 'intermediate' : 'beginner';

    // Dynamic exercises based on difficulty
    const exercisesByDifficulty = {
      beginner: [
        { name: 'Wall Push-ups', sets: 2, reps: 10, restSeconds: 90 },
        { name: 'Bodyweight Squats', sets: 2, reps: 12, restSeconds: 90 },
        { name: 'Knee Plank', sets: 2, reps: 1, restSeconds: 90 },
        { name: 'Standing Lunges', sets: 2, reps: 8, restSeconds: 90 },
      ],
      intermediate: [
        { name: 'Push-ups', sets: 3, reps: 12, restSeconds: 60 },
        { name: 'Squats', sets: 4, reps: 15, restSeconds: 90 },
        { name: 'Plank', sets: 3, reps: 1, restSeconds: 60 },
        { name: 'Lunges', sets: 3, reps: 10, restSeconds: 60 },
      ],
      advanced: [
        { name: 'Diamond Push-ups', sets: 4, reps: 15, restSeconds: 45 },
        { name: 'Jump Squats', sets: 4, reps: 20, restSeconds: 60 },
        { name: 'Plank with Leg Raise', sets: 4, reps: 1, restSeconds: 45 },
        { name: 'Jumping Lunges', sets: 4, reps: 12, restSeconds: 45 },
      ],
    };

    // Dynamic duration based on difficulty and performance
    const baseDuration = { beginner: 30, intermediate: 45, advanced: 60 };
    const completionRate = performanceMetrics?.completionRate || 100;
    const durationAdjustment = completionRate < 80 ? -5 : completionRate > 95 ? 5 : 0;
    const estimatedDuration = baseDuration[difficultyLevel] + durationAdjustment;

    // Mock adaptive workout recommendation
    const mockRecommendation = {
      workoutId: `workout_${Date.now()}`,
      title: `Full Body Strength - ${difficultyLevel.charAt(0).toUpperCase() + difficultyLevel.slice(1)}`,
      trainerId: 'trainer101',
      exercises: exercisesByDifficulty[difficultyLevel],
      difficultyLevel,
      estimatedDuration,
      adaptationReason: userRating >= 4
        ? 'Increased intensity based on positive rating and high completion rate'
        : userRating <= 2
          ? 'Reduced intensity based on difficulty feedback'
          : 'Maintained current difficulty level',
    };

    // 200 OK - successful recommendation generation
    res.status(200).json({
      success: true,
      data: mockRecommendation,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
