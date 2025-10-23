/**
 * PaymentService - Stripe payment processing integration
 * Lab 6: Testing & Debugging - Payment service implementation
 */

import { PaymentRequest, PaymentResponse } from '../models/Workout';

/**
 * Subscription tier pricing (in cents)
 */
const SUBSCRIPTION_PRICING = {
  basic: 999,      // $9.99/month
  premium: 1999,   // $19.99/month
  pro: 2999,       // $29.99/month
};

/**
 * Supported currencies
 */
const SUPPORTED_CURRENCIES = ['usd', 'eur', 'gbp'];

/**
 * Supported payment methods
 */
const SUPPORTED_PAYMENT_METHODS = ['card', 'paypal', 'apple_pay', 'google_pay'];

export class PaymentService {
  private stripeApiKey: string;
  private isTestMode: boolean;

  constructor(apiKey?: string, testMode: boolean = false) {
    this.stripeApiKey = apiKey || process.env.STRIPE_API_KEY || 'sk_test_mock';
    this.isTestMode = testMode;
  }

  /**
   * Process a payment for subscription
   * @param paymentRequest - Payment request details
   * @returns Payment response with transaction ID or error
   */
  async processPayment(paymentRequest: PaymentRequest): Promise<PaymentResponse> {
    try {
      // Validate payment request
      this.validatePaymentRequest(paymentRequest);

      // In test mode, simulate Stripe API call
      if (this.isTestMode) {
        return this.mockStripePayment(paymentRequest);
      }

      // Real Stripe integration would go here
      // const stripe = require('stripe')(this.stripeApiKey);
      // const paymentIntent = await stripe.paymentIntents.create({...});

      // For now, use mock implementation
      return this.mockStripePayment(paymentRequest);

    } catch (error) {
      return {
        success: false,
        error_message: error instanceof Error ? error.message : 'Unknown payment error',
        timestamp: new Date(),
      };
    }
  }

  /**
   * Validate subscription tier exists and get price
   * @param tier - Subscription tier
   * @returns Price in cents
   */
  getSubscriptionPrice(tier: 'basic' | 'premium' | 'pro'): number {
    const price = SUBSCRIPTION_PRICING[tier];
    if (!price) {
      throw new Error(`Invalid subscription tier: ${tier}`);
    }
    return price;
  }

  /**
   * Validate payment request data
   * @param request - Payment request to validate
   * @throws Error if validation fails
   */
  validatePaymentRequest(request: PaymentRequest): void {
    // Validate user ID
    if (!request.user_id || request.user_id.trim().length === 0) {
      throw new Error('Invalid user_id: must be a non-empty string');
    }

    // Validate amount
    if (typeof request.amount !== 'number' || request.amount <= 0) {
      throw new Error('Invalid amount: must be a positive number');
    }

    // Validate amount is reasonable (between $1 and $1000)
    if (request.amount < 100 || request.amount > 100000) {
      throw new Error('Invalid amount: must be between $1 and $1000');
    }

    // Validate currency
    if (!SUPPORTED_CURRENCIES.includes(request.currency.toLowerCase())) {
      throw new Error(
        `Unsupported currency: ${request.currency}. Supported: ${SUPPORTED_CURRENCIES.join(', ')}`
      );
    }

    // Validate payment method
    if (!SUPPORTED_PAYMENT_METHODS.includes(request.payment_method)) {
      throw new Error(
        `Unsupported payment method: ${request.payment_method}. Supported: ${SUPPORTED_PAYMENT_METHODS.join(', ')}`
      );
    }

    // Validate subscription tier
    if (!['basic', 'premium', 'pro'].includes(request.subscription_tier)) {
      throw new Error(
        `Invalid subscription tier: ${request.subscription_tier}. Must be basic, premium, or pro`
      );
    }

    // Validate amount matches subscription tier
    const expectedPrice = this.getSubscriptionPrice(request.subscription_tier);
    if (request.amount !== expectedPrice) {
      throw new Error(
        `Amount mismatch: expected ${expectedPrice} cents for ${request.subscription_tier} tier, got ${request.amount}`
      );
    }
  }

  /**
   * Cancel a subscription
   * @param userId - User ID
   * @param subscriptionId - Stripe subscription ID
   * @returns Success status
   */
  async cancelSubscription(userId: string, subscriptionId: string): Promise<boolean> {
    if (!userId || !subscriptionId) {
      throw new Error('Invalid user_id or subscription_id');
    }

    // Mock cancellation
    if (this.isTestMode) {
      return true;
    }

    // Real Stripe cancellation would go here
    // const stripe = require('stripe')(this.stripeApiKey);
    // await stripe.subscriptions.del(subscriptionId);

    return true;
  }

  /**
   * Refund a payment
   * @param transactionId - Original transaction ID
   * @param amount - Amount to refund in cents (optional, defaults to full refund)
   * @returns Refund response
   */
  async refundPayment(transactionId: string, amount?: number): Promise<PaymentResponse> {
    try {
      if (!transactionId || transactionId.trim().length === 0) {
        throw new Error('Invalid transaction_id');
      }

      if (amount !== undefined && (amount <= 0 || amount > 100000)) {
        throw new Error('Invalid refund amount');
      }

      // Mock refund
      if (this.isTestMode) {
        return {
          success: true,
          transaction_id: `refund_${transactionId}`,
          timestamp: new Date(),
        };
      }

      // Real Stripe refund would go here
      return {
        success: true,
        transaction_id: `refund_${transactionId}`,
        timestamp: new Date(),
      };

    } catch (error) {
      return {
        success: false,
        error_message: error instanceof Error ? error.message : 'Refund failed',
        timestamp: new Date(),
      };
    }
  }

  // ==================== Private Helper Methods ====================

  /**
   * Mock Stripe payment for testing
   * @param request - Payment request
   * @returns Mock payment response
   */
  private mockStripePayment(request: PaymentRequest): PaymentResponse {
    // Simulate payment processing delay
    const isSuccess = Math.random() > 0.1; // 90% success rate in mock

    // Special test cases for specific user IDs
    if (request.user_id === 'test_fail_user') {
      return {
        success: false,
        error_message: 'Card declined',
        timestamp: new Date(),
      };
    }

    if (request.user_id === 'test_insufficient_funds') {
      return {
        success: false,
        error_message: 'Insufficient funds',
        timestamp: new Date(),
      };
    }

    if (isSuccess) {
      return {
        success: true,
        transaction_id: this.generateTransactionId(),
        timestamp: new Date(),
      };
    } else {
      return {
        success: false,
        error_message: 'Payment processing failed',
        timestamp: new Date(),
      };
    }
  }

  /**
   * Generate a mock transaction ID
   * @returns Transaction ID string
   */
  private generateTransactionId(): string {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 15);
    return `txn_${timestamp}_${random}`;
  }
}
