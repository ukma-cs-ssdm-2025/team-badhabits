const express = require('express');
const { param, query } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { NotFoundError, BadRequestError } = require('../utils/errors');
const router = express.Router();

/**
 * @swagger
 * /api/v1/analytics/trainer/{id}:
 *   get:
 *     summary: Get trainer analytics and statistics
 *     description: Returns aggregated statistics for a trainer including workout performance, subscriber count, and revenue (FR-005)
 *     tags:
 *       - Analytics
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Trainer ID
 *         example: "trainer101"
 *       - in: query
 *         name: period
 *         schema:
 *           type: string
 *           enum: [week, month, quarter, year]
 *         description: Time period for analytics
 *         example: "month"
 *     responses:
 *       200:
 *         description: Trainer statistics retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 trainerId:
 *                   type: string
 *                   example: "trainer101"
 *                 displayName:
 *                   type: string
 *                   example: "John Doe"
 *                 period:
 *                   type: string
 *                   example: "month"
 *                 statistics:
 *                   type: object
 *                   properties:
 *                     totalWorkouts:
 *                       type: integer
 *                       description: Total number of workouts created
 *                       example: 45
 *                     verifiedWorkouts:
 *                       type: integer
 *                       description: Number of verified workouts
 *                       example: 38
 *                     totalSubscribers:
 *                       type: integer
 *                       description: Total active subscribers
 *                       example: 1250
 *                     newSubscribers:
 *                       type: integer
 *                       description: New subscribers in period
 *                       example: 87
 *                     totalRevenue:
 *                       type: number
 *                       description: Total revenue in USD
 *                       example: 12487.50
 *                     averageRating:
 *                       type: number
 *                       description: Average workout rating (1-5)
 *                       example: 4.6
 *                     totalCompletions:
 *                       type: integer
 *                       description: Total workout completions by users
 *                       example: 5432
 *                     completionRate:
 *                       type: number
 *                       description: Percentage of started workouts completed
 *                       example: 87.5
 *                 topWorkouts:
 *                   type: array
 *                   description: Top 5 most popular workouts
 *                   items:
 *                     type: object
 *                     properties:
 *                       workoutId:
 *                         type: string
 *                         example: "workout789"
 *                       title:
 *                         type: string
 *                         example: "HIIT Cardio Blast"
 *                       completions:
 *                         type: integer
 *                         example: 892
 *                       averageRating:
 *                         type: number
 *                         example: 4.8
 *                 engagement:
 *                   type: object
 *                   properties:
 *                     dailyActiveUsers:
 *                       type: integer
 *                       example: 234
 *                     weeklyActiveUsers:
 *                       type: integer
 *                       example: 567
 *                     monthlyActiveUsers:
 *                       type: integer
 *                       example: 1089
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *       403:
 *         description: Forbidden - User is not a trainer or accessing another trainer's data
 *       404:
 *         description: Trainer not found
 */
router.get('/trainer/:id', [
  param('id').notEmpty().withMessage('trainerId is required'),
  query('period').optional().isIn(['week', 'month', 'quarter', 'year']).withMessage('period must be one of: week, month, quarter, year'),
  validateRequest
], (req, res, next) => {
  try {
    const { id } = req.params;
    const { period = 'month' } = req.query;

    // Mock 404 check for non-existent trainer
    if (id === 'nonexistent') {
      throw new NotFoundError('Тренер');
    }

    // Dynamic statistics based on period
    const periodMultipliers = {
      week: { mult: 0.25, newSubs: 20, revenue: 3000 },
      month: { mult: 1, newSubs: 87, revenue: 12487.50 },
      quarter: { mult: 3, newSubs: 245, revenue: 35420 },
      year: { mult: 12, newSubs: 980, revenue: 142350 }
    };

    const periodData = periodMultipliers[period] || periodMultipliers.month;

    // Dynamic engagement based on period
    const baseEngagement = {
      week: { daily: 234, weekly: 567, monthly: 1089 },
      month: { daily: 289, weekly: 712, monthly: 1250 },
      quarter: { daily: 345, weekly: 892, monthly: 1450 },
      year: { daily: 398, weekly: 1034, monthly: 1689 }
    };

    const engagement = baseEngagement[period] || baseEngagement.month;

    // Mock trainer analytics
    const mockAnalytics = {
      trainerId: id,
      displayName: 'John Doe',
      period: period,
      dateRange: {
        start: new Date(Date.now() - (periodData.mult * 30 * 24 * 60 * 60 * 1000)).toISOString(),
        end: new Date().toISOString()
      },
      statistics: {
        totalWorkouts: Math.floor(45 * periodData.mult),
        verifiedWorkouts: Math.floor(38 * periodData.mult),
        totalSubscribers: 1250,
        newSubscribers: periodData.newSubs,
        totalRevenue: periodData.revenue,
        averageRating: 4.6,
        totalCompletions: Math.floor(5432 * periodData.mult),
        completionRate: 87.5
      },
      topWorkouts: [
        {
          workoutId: 'workout789',
          title: 'HIIT Cardio Blast',
          completions: Math.floor(892 * periodData.mult),
          averageRating: 4.8
        },
        {
          workoutId: 'workout234',
          title: 'Upper Body Strength',
          completions: Math.floor(765 * periodData.mult),
          averageRating: 4.7
        },
        {
          workoutId: 'workout567',
          title: 'Core & Abs Intensive',
          completions: Math.floor(654 * periodData.mult),
          averageRating: 4.5
        },
        {
          workoutId: 'workout890',
          title: 'Yoga Flow',
          completions: Math.floor(543 * periodData.mult),
          averageRating: 4.9
        },
        {
          workoutId: 'workout345',
          title: 'Leg Day Power',
          completions: Math.floor(432 * periodData.mult),
          averageRating: 4.4
        }
      ],
      engagement: {
        dailyActiveUsers: engagement.daily,
        weeklyActiveUsers: engagement.weekly,
        monthlyActiveUsers: engagement.monthly
      },
      trends: {
        subscriberGrowth: periodData.newSubs > 200 ? 'high' : periodData.newSubs > 50 ? 'moderate' : 'steady',
        revenueGrowth: periodData.revenue > 100000 ? 'excellent' : periodData.revenue > 30000 ? 'good' : 'stable'
      }
    };

    // 200 OK - успішне отримання статистики
    res.status(200).json({
      success: true,
      data: mockAnalytics
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
