const express = require('express');
const { query } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const router = express.Router();

/**
 * @swagger
 * /api/v1/recommendations/recovery:
 *   get:
 *     summary: Get personalized recovery recommendations
 *     description: Returns personalized recovery advice based on workout history, performance metrics, and user profile (FR-006)
 *     tags:
 *       - Recommendations
 *     parameters:
 *       - in: query
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID from Firebase Auth
 *         example: "user123"
 *       - in: query
 *         name: lastWorkoutId
 *         schema:
 *           type: string
 *         description: ID of most recent completed workout
 *         example: "workout456"
 *       - in: query
 *         name: muscleGroup
 *         schema:
 *           type: string
 *           enum: [upper, lower, core, full_body]
 *         description: Target muscle group from last workout
 *         example: "upper"
 *     responses:
 *       200:
 *         description: Recovery recommendations generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 userId:
 *                   type: string
 *                   example: "user123"
 *                 generatedAt:
 *                   type: string
 *                   format: date-time
 *                   example: "2025-10-09T12:45:00Z"
 *                 recoveryStatus:
 *                   type: string
 *                   enum: [fully_recovered, partially_recovered, needs_rest]
 *                   example: "partially_recovered"
 *                 estimatedRecoveryTime:
 *                   type: integer
 *                   description: Hours until full recovery
 *                   example: 24
 *                 recommendations:
 *                   type: object
 *                   properties:
 *                     restDays:
 *                       type: integer
 *                       description: Recommended rest days before next intense workout
 *                       example: 1
 *                     activeRecovery:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           activity:
 *                             type: string
 *                             example: "Light yoga"
 *                           duration:
 *                             type: integer
 *                             description: Duration in minutes
 *                             example: 20
 *                           benefits:
 *                             type: string
 *                             example: "Improves flexibility and reduces muscle tension"
 *                     nutrition:
 *                       type: object
 *                       properties:
 *                         protein:
 *                           type: string
 *                           example: "20-30g within 2 hours post-workout"
 *                         hydration:
 *                           type: string
 *                           example: "2.5-3L water throughout the day"
 *                         supplements:
 *                           type: array
 *                           items:
 *                             type: string
 *                           example: ["BCAAs", "Omega-3"]
 *                     sleep:
 *                       type: object
 *                       properties:
 *                         recommendedHours:
 *                           type: number
 *                           example: 8.5
 *                         qualityTips:
 *                           type: array
 *                           items:
 *                             type: string
 *                           example: ["Maintain consistent sleep schedule", "Avoid screens 1hr before bed"]
 *                     stretching:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           name:
 *                             type: string
 *                             example: "Chest stretch"
 *                           duration:
 *                             type: integer
 *                             description: Hold time in seconds
 *                             example: 30
 *                           targetMuscles:
 *                             type: array
 *                             items:
 *                               type: string
 *                             example: ["Pectorals", "Anterior deltoids"]
 *                 nextWorkoutRecommendation:
 *                   type: object
 *                   properties:
 *                     suggestedDate:
 *                       type: string
 *                       format: date-time
 *                       example: "2025-10-10T14:00:00Z"
 *                     focusArea:
 *                       type: string
 *                       example: "Lower body or core (allow upper body to recover)"
 *                     intensity:
 *                       type: string
 *                       enum: [light, moderate, high]
 *                       example: "moderate"
 *                 warnings:
 *                   type: array
 *                   items:
 *                     type: string
 *                   example: ["Avoid heavy upper body exercises for 24-48 hours"]
 *       400:
 *         description: Invalid request parameters
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *       404:
 *         description: User not found
 */
router.get('/recovery', [
  query('userId').notEmpty().withMessage('userId is required'),
  validateRequest
], (req, res) => {
  try {
    const { userId, lastWorkoutId, muscleGroup = 'upper' } = req.query;

    // Mock 404 check for non-existent user
    if (userId === 'nonexistent') {
      return res.status(404).json({
        error: 'User not found',
        message: 'The specified user does not exist in the system'
      });
    }

    const now = new Date();
    const nextWorkoutDate = new Date(now);

    // Dynamic recovery time based on muscle group
    const recoveryTimes = {
      upper: 24,
      lower: 48,
      core: 18,
      full_body: 36
    };

    const estimatedRecoveryTime = recoveryTimes[muscleGroup] || 24;
    nextWorkoutDate.setHours(nextWorkoutDate.getHours() + estimatedRecoveryTime);

    // Dynamic recovery status based on time
    const recoveryStatus = estimatedRecoveryTime <= 18
      ? 'fully_recovered'
      : estimatedRecoveryTime <= 36
        ? 'partially_recovered'
        : 'needs_rest';

    // Dynamic rest days
    const restDays = Math.ceil(estimatedRecoveryTime / 24);

    // Dynamic stretching based on muscle group
    const stretchingByGroup = {
      upper: [
        { name: 'Chest stretch', duration: 30, targetMuscles: ['Pectorals', 'Anterior deltoids'] },
        { name: 'Shoulder stretch', duration: 30, targetMuscles: ['Deltoids', 'Rotator cuff'] },
        { name: 'Tricep stretch', duration: 30, targetMuscles: ['Triceps brachii'] }
      ],
      lower: [
        { name: 'Hamstring stretch', duration: 40, targetMuscles: ['Hamstrings', 'Calves'] },
        { name: 'Quad stretch', duration: 40, targetMuscles: ['Quadriceps'] },
        { name: 'Hip flexor stretch', duration: 35, targetMuscles: ['Hip flexors', 'Glutes'] }
      ],
      core: [
        { name: 'Cat-cow stretch', duration: 25, targetMuscles: ['Abdominals', 'Lower back'] },
        { name: 'Child\'s pose', duration: 30, targetMuscles: ['Core', 'Spine'] },
        { name: 'Spinal twist', duration: 30, targetMuscles: ['Obliques', 'Back muscles'] }
      ],
      full_body: [
        { name: 'Full body reach', duration: 30, targetMuscles: ['Full body'] },
        { name: 'Downward dog', duration: 35, targetMuscles: ['Hamstrings', 'Shoulders', 'Core'] },
        { name: 'Side stretch', duration: 30, targetMuscles: ['Obliques', 'Lats'] }
      ]
    };

    // Mock recovery recommendations
    const mockRecommendations = {
      userId: userId,
      generatedAt: now.toISOString(),
      recoveryStatus: recoveryStatus,
      estimatedRecoveryTime: estimatedRecoveryTime,
      lastWorkoutId: lastWorkoutId || null,
      targetMuscleGroup: muscleGroup,
      recommendations: {
        restDays: restDays,
        activeRecovery: [
          {
            activity: 'Light yoga',
            duration: 20,
            benefits: 'Improves flexibility and reduces muscle tension'
          },
          {
            activity: 'Walking',
            duration: 30,
            benefits: 'Promotes blood flow and aids recovery without strain'
          },
          {
            activity: 'Foam rolling',
            duration: 15,
            benefits: 'Releases muscle knots and improves mobility'
          }
        ],
        nutrition: {
          protein: muscleGroup === 'lower' || muscleGroup === 'full_body'
            ? '25-35g within 2 hours post-workout'
            : '20-30g within 2 hours post-workout',
          hydration: muscleGroup === 'full_body'
            ? '3-3.5L water throughout the day'
            : '2.5-3L water throughout the day',
          supplements: muscleGroup === 'lower'
            ? ['BCAAs', 'Omega-3', 'Vitamin D', 'Magnesium']
            : ['BCAAs', 'Omega-3', 'Vitamin D']
        },
        sleep: {
          recommendedHours: recoveryStatus === 'needs_rest' ? 9 : 8.5,
          qualityTips: [
            'Maintain consistent sleep schedule',
            'Avoid screens 1hr before bed',
            'Keep room temperature cool (65-68°F)',
            'Consider magnesium supplement before bed'
          ]
        },
        stretching: stretchingByGroup[muscleGroup] || stretchingByGroup.upper
      },
      nextWorkoutRecommendation: {
        suggestedDate: nextWorkoutDate.toISOString(),
        focusArea: muscleGroup === 'upper'
          ? 'Lower body or core (allow upper body to recover)'
          : muscleGroup === 'lower'
            ? 'Upper body or core (allow lower body to recover)'
            : muscleGroup === 'core'
              ? 'Light upper or lower body workout'
              : 'Light full body or active recovery',
        intensity: recoveryStatus === 'fully_recovered'
          ? 'moderate'
          : recoveryStatus === 'partially_recovered'
            ? 'light-moderate'
            : 'light'
      },
      warnings: [
        `Avoid heavy ${muscleGroup} body exercises for ${estimatedRecoveryTime}-${estimatedRecoveryTime + 24} hours`,
        'Listen to your body - extend rest if experiencing persistent soreness',
        'Ensure adequate protein intake for muscle repair',
        ...(recoveryStatus === 'needs_rest' ? ['Consider taking an extra rest day before intense training'] : [])
      ]
    };

    res.json(mockRecommendations);
  } catch (error) {
    console.error('Error generating recovery recommendations:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to generate recovery recommendations'
    });
  }
});

module.exports = router;
