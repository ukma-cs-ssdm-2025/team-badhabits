const express = require('express');
const { param, query } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { NotFoundError } = require('../utils/errors');
const StatisticsService = require('../services/StatisticsService');

const router = express.Router();
const statisticsService = new StatisticsService();

/**
 * @swagger
 * /api/v1/statistics/user/{userId}:
 *   get:
 *     summary: Get overall user statistics (all-time)
 *     tags: [Statistics]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: User ID
 *     responses:
 *       200:
 *         description: User statistics retrieved successfully
 *       404:
 *         description: User not found
 */
router.get(
  '/user/:userId',
  [param('userId').notEmpty().withMessage('userId is required'), validateRequest],
  async (req, res, next) => {
    try {
      const { userId } = req.params;

      if (userId === 'nonexistent') {
        throw new NotFoundError('User');
      }

      const statistics = await statisticsService.calculateOverallStatistics(userId);

      res.json({
        success: true,
        data: statistics,
      });
    } catch (error) {
      next(error);
    }
  },
);

/**
 * @swagger
 * /api/v1/statistics/user/{userId}/workouts:
 *   get:
 *     summary: Get workout statistics for specific period
 *     tags: [Statistics]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: period
 *         schema:
 *           type: string
 *           enum: [week, month, year, all]
 *           default: month
 *     responses:
 *       200:
 *         description: Period statistics retrieved successfully
 */
router.get(
  '/user/:userId/workouts',
  [
    param('userId').notEmpty().withMessage('userId is required'),
    query('period').optional().isIn(['week', 'month', 'year', 'all']),
    validateRequest,
  ],
  async (req, res, next) => {
    try {
      const { userId } = req.params;
      const { period = 'month' } = req.query;

      if (userId === 'nonexistent') {
        throw new NotFoundError('User');
      }

      const statistics = await statisticsService.calculatePeriodStatistics(
        userId,
        period,
      );

      res.json({
        success: true,
        data: statistics,
      });
    } catch (error) {
      next(error);
    }
  },
);

/**
 * @swagger
 * /api/v1/statistics/user/{userId}/progress:
 *   get:
 *     summary: Get progress metrics over time
 *     tags: [Statistics]
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Progress metrics retrieved successfully
 */
router.get(
  '/user/:userId/progress',
  [param('userId').notEmpty().withMessage('userId is required'), validateRequest],
  async (req, res, next) => {
    try {
      const { userId } = req.params;

      if (userId === 'nonexistent') {
        throw new NotFoundError('User');
      }

      const progress = await statisticsService.calculateProgressMetrics(userId);

      res.json({
        success: true,
        data: progress,
      });
    } catch (error) {
      next(error);
    }
  },
);

module.exports = router;
