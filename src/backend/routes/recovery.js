/**
 * Recovery Recommendations Routes (FR-006)
 *
 * API endpoints for recovery status and recommendations
 */

const express = require('express');
const { query, validationResult } = require('express-validator');
const { getRecoveryRecommendation } = require('../services/RecoveryService');
const { NotFoundError } = require('../utils/errors');

const router = express.Router();

/**
 * @swagger
 * /api/v1/recovery/status:
 *   get:
 *     summary: Get recovery status and recommendations
 *     description: Returns personalized recovery recommendations based on training load (FR-006)
 *     tags:
 *       - Recovery
 *     parameters:
 *       - in: query
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: Firebase user ID
 *       - in: query
 *         name: days
 *         required: false
 *         schema:
 *           type: integer
 *           default: 7
 *         description: Number of days to analyze
 *     responses:
 *       200:
 *         description: Recovery recommendation retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     userId:
 *                       type: string
 *                     status:
 *                       type: string
 *                       enum: [ready, moderate, overtraining]
 *                     trainingLoad:
 *                       type: number
 *                     recoveryTimeHours:
 *                       type: number
 *                     consecutiveHardDays:
 *                       type: number
 *                     recommendation:
 *                       type: string
 *                     canTrainToday:
 *                       type: boolean
 *       400:
 *         description: Invalid request parameters
 *       404:
 *         description: User not found
 *       500:
 *         description: Server error
 */
router.get(
  '/status',
  [
    query('userId').notEmpty().withMessage('userId is required'),
    query('days')
      .optional()
      .isInt({ min: 1, max: 30 })
      .withMessage('days must be between 1 and 30'),
  ],
  async (req, res, next) => {
    try {
      // Validate request
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: errors.array()[0].msg,
          },
        });
      }

      const { userId, days } = req.query;
      const analyzeDays = days ? parseInt(days, 10) : 7;

      // Get recovery recommendation
      const recommendation = await getRecoveryRecommendation(userId, analyzeDays);

      return res.json({
        success: true,
        data: recommendation,
      });
    } catch (error) {
      console.error('Recovery recommendation error:', error);

      if (error.code === 'not-found') {
        return next(new NotFoundError('User'));
      }

      return next(error);
    }
  }
);

module.exports = router;
