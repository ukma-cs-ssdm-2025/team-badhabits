/**
 * Adaptive Workout Routes - TypeScript Integration
 * Lab 6: Testing & Debugging
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');

// Import TypeScript service (will be transpiled)
// For testing, we'll use mock implementation
const mockAdaptiveService = {
  generateWorkout: (userData) => {
    // Mock implementation for testing
    const { AdaptiveWorkoutService } = require('../services/AdaptiveWorkoutService');
    const service = new AdaptiveWorkoutService();
    return service.generateWorkout(userData);
  },
};

/**
 * @swagger
 * /api/v1/adaptive/recommend:
 *   post:
 *     summary: Generate personalized adaptive workout
 *     tags: [Adaptive Workouts]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_data
 *             properties:
 *               user_data:
 *                 type: object
 *     responses:
 *       200:
 *         description: Workout generated successfully
 *       400:
 *         description: Invalid request data
 */
router.post(
  '/recommend',
  [
    body('user_data').exists().withMessage('user_data is required'),
    body('user_data.user_id').isString().withMessage('user_id must be a string'),
    body('user_data.fitness_level')
      .isIn(['beginner', 'intermediate', 'advanced', 'expert'])
      .withMessage('Invalid fitness_level'),
  ],
  (req, res, next) => {
    try {
      // Validate request
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: errors.array()[0].msg,
            details: errors.array(),
          },
        });
      }

      const { user_data } = req.body;

      // Generate workout
      const workout = mockAdaptiveService.generateWorkout(user_data);

      // Return response
      return res.json({
        success: true,
        data: {
          workout,
          message: 'Workout generated successfully',
        },
      });
    } catch (error) {
      return next(error);
    }
  }
);

module.exports = router;
