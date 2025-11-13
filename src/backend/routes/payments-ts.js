/**
 * Payment Routes - TypeScript Integration
 * Lab 6: Testing & Debugging
 */

const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');

// Import TypeScript service
const mockPaymentService = {
  processPayment: async (paymentRequest) => {
    const { PaymentService } = require('../services/PaymentService');
    const service = new PaymentService(undefined, true); // Test mode
    return await service.processPayment(paymentRequest);
  },
};

/**
 * @swagger
 * /api/v1/payments/subscribe:
 *   post:
 *     summary: Process subscription payment
 *     tags: [Payments]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_id
 *               - amount
 *               - currency
 *               - payment_method
 *               - subscription_tier
 *     responses:
 *       200:
 *         description: Payment processed successfully
 *       400:
 *         description: Invalid payment data
 *       422:
 *         description: Payment processing failed
 */
router.post(
  '/subscribe',
  [
    body('user_id').isString().notEmpty().withMessage('user_id is required'),
    body('amount').isInt({ min: 1 }).withMessage('amount must be positive'),
    body('currency').isString().notEmpty().withMessage('currency is required'),
    body('payment_method').isString().notEmpty().withMessage('payment_method is required'),
    body('subscription_tier')
      .isIn(['basic', 'premium', 'pro'])
      .withMessage('Invalid subscription_tier'),
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
            details: errors.array(),
          },
        });
      }

      const paymentRequest = req.body;

      // Process payment
      const response = await mockPaymentService.processPayment(paymentRequest);

      // Return response based on success
      if (response.success) {
        return res.json({
          success: true,
          data: {
            transaction_id: response.transaction_id,
            message: 'Payment processed successfully',
          },
        });
      }
      return res.status(422).json({
        success: false,
        error: {
          code: 'PAYMENT_FAILED',
          message: response.error_message,
        },
      });
    } catch (error) {
      return next(error);
    }
  }
);

module.exports = router;
