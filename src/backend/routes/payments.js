const express = require('express');
const { body } = require('express-validator');
const validateRequest = require('../middleware/validateRequest');
const { NotFoundError, BadRequestError, ConflictError } = require('../utils/errors');
const router = express.Router();

/**
 * @swagger
 * /api/v1/payments/subscribe:
 *   post:
 *     summary: Subscribe to a workout plan
 *     description: Process subscription payment for premium workout access (FR-012)
 *     tags:
 *       - Payments
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - workoutId
 *               - paymentMethod
 *             properties:
 *               userId:
 *                 type: string
 *                 description: User ID from Firebase Auth
 *                 example: "user123"
 *               workoutId:
 *                 type: string
 *                 description: ID of the workout to subscribe to
 *                 example: "workout456"
 *               paymentMethod:
 *                 type: string
 *                 enum: [stripe, paypal]
 *                 description: Payment provider
 *                 example: "stripe"
 *               paymentToken:
 *                 type: string
 *                 description: Payment token from Stripe/PayPal
 *                 example: "tok_1234567890abcdef"
 *               planType:
 *                 type: string
 *                 enum: [monthly, yearly]
 *                 description: Subscription plan duration
 *                 example: "monthly"
 *     responses:
 *       201:
 *         description: Subscription created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 subscriptionId:
 *                   type: string
 *                   example: "sub_1234567890"
 *                 userId:
 *                   type: string
 *                   example: "user123"
 *                 workoutId:
 *                   type: string
 *                   example: "workout456"
 *                 status:
 *                   type: string
 *                   enum: [active, pending, cancelled]
 *                   example: "active"
 *                 startDate:
 *                   type: string
 *                   format: date-time
 *                   example: "2025-10-09T12:00:00Z"
 *                 endDate:
 *                   type: string
 *                   format: date-time
 *                   example: "2025-11-09T12:00:00Z"
 *                 planType:
 *                   type: string
 *                   example: "monthly"
 *                 amount:
 *                   type: number
 *                   description: Subscription price
 *                   example: 9.99
 *                 currency:
 *                   type: string
 *                   example: "USD"
 *                 nextBillingDate:
 *                   type: string
 *                   format: date-time
 *                   example: "2025-11-09T12:00:00Z"
 *       400:
 *         description: Invalid payment data
 *       401:
 *         description: Unauthorized - Invalid or missing token
 *       404:
 *         description: User or workout not found
 *       409:
 *         description: User already has active subscription
 */
router.post('/subscribe', [
  body('userId').notEmpty().withMessage('userId is required'),
  body('workoutId').notEmpty().withMessage('workoutId is required'),
  body('paymentMethod').isIn(['stripe', 'paypal']).withMessage('paymentMethod must be either stripe or paypal'),
  validateRequest,
], (req, res, next) => {
  try {
    const { userId, workoutId, paymentMethod, planType = 'monthly', paymentToken } = req.body;

    // Mock 404 check for non-existent resources
    if (userId === 'nonexistent') {
      throw new NotFoundError('User');
    }

    if (workoutId === 'nonexistent') {
      throw new NotFoundError('Workout');
    }

    // Mock conflict - user already has subscription
    if (userId === 'already_subscribed') {
      throw new ConflictError('User already has an active subscription to this workout');
    }

    // Mock payment failure scenario
    if (paymentToken === 'invalid_token') {
      throw new BadRequestError('Payment could not be processed. Please check payment details');
    }

    const startDate = new Date();
    const endDate = new Date(startDate);

    if (planType === 'monthly') {
      endDate.setMonth(endDate.getMonth() + 1);
    } else if (planType === 'yearly') {
      endDate.setFullYear(endDate.getFullYear() + 1);
    }

    // Dynamic pricing based on plan type
    const pricing = {
      monthly: { amount: 9.99, savings: 0 },
      yearly: { amount: 99.99, savings: 19.89 },
    };

    const selectedPlan = pricing[planType] || pricing.monthly;

    // Mock subscription response
    const mockSubscription = {
      subscriptionId: `sub_${Date.now()}`,
      userId,
      workoutId,
      status: 'active',
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
      planType,
      amount: selectedPlan.amount,
      currency: 'USD',
      nextBillingDate: endDate.toISOString(),
      paymentMethod,
      savings: selectedPlan.savings,
      features: {
        unlimitedAccess: true,
        offlineDownloads: planType === 'yearly',
        prioritySupport: planType === 'yearly',
        personalizedPlans: true,
      },
    };

    // 201 Created - new resource (subscription) created
    res.status(201).json({
      success: true,
      data: mockSubscription,
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
