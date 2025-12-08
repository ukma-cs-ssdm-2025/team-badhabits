const express = require('express');
const { query, validationResult } = require('express-validator');
const { getAdaptiveRecommendation } = require('../services/AdaptiveService');
const { NotFoundError } = require('../utils/errors');

const router = express.Router();

/**
 * @swagger
 * /api/v1/adaptive/recommend:
 *   get:
 *     summary: Get adaptive workout recommendation
 *     description: Returns personalized workout based on user's history (FR-014)
 *     tags:
 *       - Adaptive Workouts
 *     parameters:
 *       - in: query
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: Firebase user ID
 *     responses:
 *       200:
 *         description: Recommendation generated successfully
 *       400:
 *         description: Invalid request parameters
 *       404:
 *         description: User not found
 *       500:
 *         description: Server error
 */
router.get(
  '/recommend',
  [query('userId').notEmpty().withMessage('userId is required')],
  async (req, res, next) => {
    try {
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

      const { userId } = req.query;

      const result = await getAdaptiveRecommendation(userId);

      return res.json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error('Adaptive recommendation error:', error);

      if (error.code === 'not-found') {
        return next(new NotFoundError('User'));
      }

      return next(error);
    }
  }
);

/**
 * @swagger
 * /api/v1/adaptive/recommend:
 *   post:
 *     summary: Get adaptive workout (POST - legacy support)
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
 *             properties:
 *               userId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Recommendation generated
 */
router.post('/recommend', async (req, res, next) => {
  try {
    const userId = req.body.userId || req.body.user_data?.user_id;

    if (!userId) {
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_ERROR', message: 'userId is required' },
      });
    }

    const result = await getAdaptiveRecommendation(userId);

    return res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    console.error('Adaptive recommendation error:', error);
    return next(error);
  }
});

module.exports = router;
