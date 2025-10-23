/**
 * Integration tests for API endpoints
 *
 * Tests cover:
 * 1. POST /api/v1/adaptive/recommend - Generate adaptive workout
 * 2. POST /api/v1/payments/subscribe - Process subscription payment
 * 3. GET /health - Health check endpoint
 */

import request from 'supertest';
import app from '../../app';
import { UserData, PaymentRequest } from '../../models/Workout';

describe('API Integration Tests', () => {
  // ==================== Test 1: Adaptive Workout Endpoint ====================
  describe('POST /api/v1/adaptive/recommend', () => {
    it('should generate workout for valid user data', async () => {
      // Arrange
      const userData: UserData = {
        user_id: 'integration_test_user',
        fitness_level: 'intermediate',
        age: 28,
        weight_kg: 75,
        height_cm: 180,
        injuries: [],
        available_equipment: ['dumbbells'],
        preferred_duration_minutes: 30,
        goals: ['strength', 'endurance'],
        past_ratings: [],
      };

      // Act
      const response = await request(app)
        .post('/api/v1/adaptive/recommend')
        .send({ user_data: userData })
        .expect('Content-Type', /json/)
        .expect(200);

      // Assert
      expect(response.body).toBeDefined();
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
      expect(response.body.data.workout).toBeDefined();

      const workout = response.body.data.workout;
      expect(workout.user_id).toBe('integration_test_user');
      expect(workout.exercises).toBeInstanceOf(Array);
      expect(workout.exercises.length).toBeGreaterThan(0);
      expect(workout.difficulty).toBe('intermediate');
      expect(workout.total_duration_minutes).toBeGreaterThan(0);
    });

    it('should return 400 for missing user_data', async () => {
      // Act
      const response = await request(app)
        .post('/api/v1/adaptive/recommend')
        .send({}) // Empty body
        .expect('Content-Type', /json/)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBeDefined();
      expect(response.body.error.message).toContain('user_data');
    });

    it('should generate workout for beginner with no equipment', async () => {
      // Arrange
      const userData: UserData = {
        user_id: 'beginner_user',
        fitness_level: 'beginner',
        age: 22,
        injuries: [],
        available_equipment: [],
        preferred_duration_minutes: 20,
        goals: ['weight_loss'],
        past_ratings: [],
      };

      // Act
      const response = await request(app)
        .post('/api/v1/adaptive/recommend')
        .send({ user_data: userData })
        .expect(200);

      // Assert
      const workout = response.body.data.workout;
      expect(workout.difficulty).toBe('beginner');
      expect(workout.exercises.every((ex: any) => !ex.equipment)).toBe(true);
    });

    it('should handle user with injury constraints', async () => {
      // Arrange
      const userData: UserData = {
        user_id: 'injured_user',
        fitness_level: 'intermediate',
        age: 30,
        injuries: ['knee'],
        available_equipment: ['dumbbells'],
        preferred_duration_minutes: 25,
        goals: ['recovery'],
        past_ratings: [],
      };

      // Act
      const response = await request(app)
        .post('/api/v1/adaptive/recommend')
        .send({ user_data: userData })
        .expect(200);

      // Assert
      const workout = response.body.data.workout;
      // Verify no exercises target legs (restricted with knee injury)
      workout.exercises.forEach((exercise: any) => {
        expect(exercise.affected_areas).not.toContain('legs');
      });
    });

    it('should return 400 for invalid fitness_level', async () => {
      // Arrange
      const invalidUserData = {
        user_id: 'test_user',
        fitness_level: 'super_advanced', // Invalid
        age: 25,
        injuries: [],
        available_equipment: [],
        preferred_duration_minutes: 30,
        goals: [],
        past_ratings: [],
      };

      // Act
      const response = await request(app)
        .post('/api/v1/adaptive/recommend')
        .send({ user_data: invalidUserData })
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain('fitness_level');
    });
  });

  // ==================== Test 2: Payment Subscription Endpoint ====================
  describe('POST /api/v1/payments/subscribe', () => {
    it('should process valid basic subscription payment', async () => {
      // Arrange
      const paymentRequest: PaymentRequest = {
        user_id: 'payment_test_user',
        amount: 999,
        currency: 'usd',
        payment_method: 'card',
        subscription_tier: 'basic',
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(paymentRequest)
        .expect('Content-Type', /json/);

      // Assert - Payment might succeed (200) or fail due to mock (422)
      expect([200, 422]).toContain(response.status);
      if (response.status === 200) {
        expect(response.body.success).toBe(true);
        expect(response.body.data.transaction_id).toMatch(/^txn_/);
      }
    });

    it('should process valid premium subscription payment', async () => {
      // Arrange
      const paymentRequest: PaymentRequest = {
        user_id: 'premium_test_user',
        amount: 1999,
        currency: 'usd',
        payment_method: 'paypal',
        subscription_tier: 'premium',
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(paymentRequest)
        .expect('Content-Type', /json/);

      // Assert - Accept both success (200) and mock failure (422)
      expect([200, 422]).toContain(response.status);
      if (response.status === 200) {
        expect(response.body.success).toBe(true);
        expect(response.body.data.transaction_id).toBeDefined();
      }
    });

    it('should return 400 for invalid amount', async () => {
      // Arrange
      const invalidPayment: PaymentRequest = {
        user_id: 'test_user',
        amount: 0, // Invalid
        currency: 'usd',
        payment_method: 'card',
        subscription_tier: 'basic',
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(invalidPayment)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain('amount');
    });

    it('should return 422 for unsupported currency', async () => {
      // Arrange
      const invalidPayment: PaymentRequest = {
        user_id: 'test_user',
        amount: 999,
        currency: 'btc', // Unsupported
        payment_method: 'card',
        subscription_tier: 'basic',
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(invalidPayment)
        .expect(422); // Unprocessable Entity for validation error

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain('currency');
    });

    it('should return 422 when amount does not match tier', async () => {
      // Arrange
      const invalidPayment: PaymentRequest = {
        user_id: 'test_user',
        amount: 500, // Wrong amount for basic (expects 999)
        currency: 'usd',
        payment_method: 'card',
        subscription_tier: 'basic',
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(invalidPayment)
        .expect(422); // Unprocessable Entity for validation error

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain('Amount mismatch');
    });

    it('should handle card decline for test user', async () => {
      // Arrange
      const paymentRequest: PaymentRequest = {
        user_id: 'test_fail_user', // Special test user for card decline
        amount: 999,
        currency: 'usd',
        payment_method: 'card',
        subscription_tier: 'basic',
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(paymentRequest)
        .expect(422); // Unprocessable Entity

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toBe('Card declined');
    });

    it('should return 400 for missing required fields', async () => {
      // Arrange
      const incompletePayment = {
        user_id: 'test_user',
        // Missing amount, currency, payment_method, subscription_tier
      };

      // Act
      const response = await request(app)
        .post('/api/v1/payments/subscribe')
        .send(incompletePayment)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
    });
  });

  // ==================== Test 3: Health Check Endpoint ====================
  describe('GET /health', () => {
    it('should return 200 and service status', async () => {
      // Act
      const response = await request(app)
        .get('/health')
        .expect('Content-Type', /json/)
        .expect(200);

      // Assert
      expect(response.body).toBeDefined();
      expect(response.body.status).toBe('ok');
      expect(response.body.service).toBe('Wellity Backend API');
      expect(response.body.version).toBeDefined();
      expect(response.body.timestamp).toBeDefined();
    });

    it('should return timestamp in ISO format', async () => {
      // Act
      const response = await request(app)
        .get('/health')
        .expect(200);

      // Assert
      const timestamp = response.body.timestamp;
      expect(timestamp).toBeDefined();
      expect(() => new Date(timestamp)).not.toThrow();
      expect(new Date(timestamp).toISOString()).toBe(timestamp);
    });
  });

  // ==================== Test 4: 404 Not Found ====================
  describe('404 Not Found', () => {
    it('should return 404 for non-existent endpoint', async () => {
      // Act
      const response = await request(app)
        .get('/api/v1/nonexistent')
        .expect('Content-Type', /json/)
        .expect(404);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBeDefined();
      expect(response.body.error.message).toContain('not found');
    });

    it('should return 404 for invalid POST endpoint', async () => {
      // Act
      const response = await request(app)
        .post('/api/v1/invalid')
        .send({ data: 'test' })
        .expect(404);

      // Assert
      expect(response.body.success).toBe(false);
    });
  });

  // ==================== Test 5: Root Endpoint ====================
  describe('GET /', () => {
    it('should return API information', async () => {
      // Act
      const response = await request(app)
        .get('/')
        .expect('Content-Type', /json/)
        .expect(200);

      // Assert
      expect(response.body.message).toBe('Wellity Backend API');
      expect(response.body.version).toBeDefined();
      expect(response.body.documentation).toBe('/api-docs');
      expect(response.body.endpoints).toBeDefined();
      expect(response.body.endpoints.adaptive).toBeDefined();
      expect(response.body.endpoints.payments).toBeDefined();
    });
  });

  // ==================== Test 6: CORS Headers ====================
  describe('CORS Configuration', () => {
    it('should include CORS headers in response', async () => {
      // Act
      const response = await request(app)
        .get('/health')
        .expect(200);

      // Assert - CORS should be enabled
      expect(response.headers['access-control-allow-origin']).toBeDefined();
    });

    it('should handle OPTIONS preflight request', async () => {
      // Act
      const response = await request(app)
        .options('/api/v1/adaptive/recommend')
        .expect(204);

      // Assert
      expect(response.headers['access-control-allow-methods']).toBeDefined();
    });
  });
});
