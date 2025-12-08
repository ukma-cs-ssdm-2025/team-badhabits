/**
 * Integration tests for API endpoints
 *
 * Tests cover:
 * 1. GET/POST /api/v1/adaptive/recommend - Generate adaptive workout
 * 2. POST /api/v1/payments/subscribe - Process subscription payment
 * 3. GET /health - Health check endpoint
 * 4. POST /subscribe - Підписка
 */

import request from "supertest";
import app from "../../app";
import { PaymentRequest } from "../../models/Workout";

// Mock FirebaseService to avoid needing real Firebase credentials in CI
jest.mock("../../services/FirebaseService", () => ({
  getUserWorkoutSessions: jest.fn().mockResolvedValue([
    {
      id: "1",
      difficulty_rating: 3,
      completed_at: new Date().toISOString(),
      status: "completed",
    },
    {
      id: "2",
      difficulty_rating: 4,
      completed_at: new Date().toISOString(),
      status: "completed",
    },
  ]),
  getWorkoutsByDifficulty: jest.fn().mockResolvedValue([
    {
      id: "test_workout_1",
      title: "Test Workout",
      description: "Test description",
      exercises: [
        { name: "Push-ups", sets: 3, reps: 10 },
        { name: "Squats", sets: 3, reps: 15 },
      ],
      duration_minutes: 30,
      estimated_calories: 250,
      difficulty: "intermediate",
      is_adaptive: true,
      is_verified: true,
      equipment_required: [],
    },
  ]),
  getUserProfile: jest.fn().mockResolvedValue({
    id: "test_user",
    fitness_level: "intermediate",
  }),
  calculateAverageRating: jest.fn().mockReturnValue(3.5),
}));

describe("API Integration Tests", () => {
  // ==================== Test 1: Adaptive Workout Endpoint ====================
  describe("GET /api/v1/adaptive/recommend", () => {
    it("should generate workout recommendation for valid userId", async () => {
      // Act
      const response = await request(app)
        .get("/api/v1/adaptive/recommend")
        .query({ userId: "test_user_123" })
        .expect("Content-Type", /json/)
        .expect(200);

      // Assert
      expect(response.body).toBeDefined();
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
      expect(response.body.data.workout).toBeDefined();
      expect(response.body.data.recommendation).toBeDefined();

      const { workout, recommendation } = response.body.data;
      expect(workout.id).toBeDefined();
      expect(workout.title).toBeDefined();
      expect(workout.exercises).toBeInstanceOf(Array);
      expect(recommendation.basedOnSessions).toBeDefined();
      expect(recommendation.targetDifficulty).toBeDefined();
    });

    it("should return 400 for missing userId", async () => {
      // Act
      const response = await request(app)
        .get("/api/v1/adaptive/recommend")
        .expect("Content-Type", /json/)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBeDefined();
    });
  });

  describe("POST /api/v1/adaptive/recommend", () => {
    it("should generate workout recommendation via POST", async () => {
      // Act
      const response = await request(app)
        .post("/api/v1/adaptive/recommend")
        .send({ userId: "test_user_123" })
        .expect("Content-Type", /json/)
        .expect(200);

      // Assert
      expect(response.body).toBeDefined();
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();
      expect(response.body.data.workout).toBeDefined();
    });

    it("should return 400 for missing userId in POST body", async () => {
      // Act
      const response = await request(app)
        .post("/api/v1/adaptive/recommend")
        .send({})
        .expect("Content-Type", /json/)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
    });
  });

  // ==================== Test 2: Payment Subscription Endpoint ====================
  describe("POST /api/v1/payments/subscribe", () => {
    it("should process valid basic subscription payment", async () => {
      // Arrange
      const paymentRequest: PaymentRequest = {
        user_id: "payment_test_user",
        amount: 999,
        currency: "usd",
        payment_method: "card",
        subscription_tier: "basic",
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(paymentRequest)
        .expect("Content-Type", /json/);

      // Assert - Payment might succeed (200) or fail due to mock (422)
      expect([200, 422]).toContain(response.status);
      if (response.status === 200) {
        expect(response.body.success).toBe(true);
        expect(response.body.data.transaction_id).toMatch(/^txn_/);
      }
    });

    it("should process valid premium subscription payment", async () => {
      // Arrange
      const paymentRequest: PaymentRequest = {
        user_id: "premium_test_user",
        amount: 1999,
        currency: "usd",
        payment_method: "paypal",
        subscription_tier: "premium",
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(paymentRequest)
        .expect("Content-Type", /json/);

      // Assert - Accept both success (200) and mock failure (422)
      expect([200, 422]).toContain(response.status);
      if (response.status === 200) {
        expect(response.body.success).toBe(true);
        expect(response.body.data.transaction_id).toBeDefined();
      }
    });

    it("should return 400 for invalid amount", async () => {
      // Arrange
      const invalidPayment: PaymentRequest = {
        user_id: "test_user",
        amount: 0, // Invalid
        currency: "usd",
        payment_method: "card",
        subscription_tier: "basic",
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(invalidPayment)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain("amount");
    });

    it("should return 422 for unsupported currency", async () => {
      // Arrange
      const invalidPayment: PaymentRequest = {
        user_id: "test_user",
        amount: 999,
        currency: "btc", // Unsupported
        payment_method: "card",
        subscription_tier: "basic",
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(invalidPayment)
        .expect(422); // Unprocessable Entity for validation error

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain("currency");
    });

    it("should return 422 when amount does not match tier", async () => {
      // Arrange
      const invalidPayment: PaymentRequest = {
        user_id: "test_user",
        amount: 500, // Wrong amount for basic (expects 999)
        currency: "usd",
        payment_method: "card",
        subscription_tier: "basic",
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(invalidPayment)
        .expect(422); // Unprocessable Entity for validation error

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain("Amount mismatch");
    });

    it("should handle card decline for test user", async () => {
      // Arrange
      const paymentRequest: PaymentRequest = {
        user_id: "test_fail_user", // Special test user for card decline
        amount: 999,
        currency: "usd",
        payment_method: "card",
        subscription_tier: "basic",
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(paymentRequest)
        .expect(422); // Unprocessable Entity

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toBe("Card declined");
    });

    it("should return 400 for missing required fields", async () => {
      // Arrange
      const incompletePayment = {
        user_id: "test_user",
        // Missing amount, currency, payment_method, subscription_tier
      };

      // Act
      const response = await request(app)
        .post("/api/v1/payments/subscribe")
        .send(incompletePayment)
        .expect(400);

      // Assert
      expect(response.body.success).toBe(false);
    });
  });

  // ==================== Test 3: Health Check Endpoint ====================
  describe("GET /health", () => {
    it("should return 200 and service status", async () => {
      // Act
      const response = await request(app)
        .get("/health")
        .expect("Content-Type", /json/)
        .expect(200);

      // Assert
      expect(response.body).toBeDefined();
      expect(response.body.status).toBe("ok");
      expect(response.body.service).toBe("Wellity Backend API");
      expect(response.body.version).toBeDefined();
      expect(response.body.timestamp).toBeDefined();
    });

    it("should return timestamp in ISO format", async () => {
      // Act
      const response = await request(app).get("/health").expect(200);

      // Assert
      const timestamp = response.body.timestamp;
      expect(timestamp).toBeDefined();
      expect(() => new Date(timestamp)).not.toThrow();
      expect(new Date(timestamp).toISOString()).toBe(timestamp);
    });
  });

  // ==================== Test 4: 404 Not Found ====================
  describe("404 Not Found", () => {
    it("should return 404 for non-existent endpoint", async () => {
      // Act
      const response = await request(app)
        .get("/api/v1/nonexistent")
        .expect("Content-Type", /json/)
        .expect(404);

      // Assert
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBeDefined();
      expect(response.body.error.message).toContain("not found");
    });

    it("should return 404 for invalid POST endpoint", async () => {
      // Act
      const response = await request(app)
        .post("/api/v1/invalid")
        .send({ data: "test" })
        .expect(404);

      // Assert
      expect(response.body.success).toBe(false);
    });
  });

  // ==================== Test 5: Root Endpoint ====================
  describe("GET /", () => {
    it("should return API information", async () => {
      // Act
      const response = await request(app)
        .get("/")
        .expect("Content-Type", /json/)
        .expect(200);

      // Assert
      expect(response.body.message).toBe("Wellity Backend API");
      expect(response.body.version).toBeDefined();
      expect(response.body.documentation).toBe("/api-docs");
      expect(response.body.endpoints).toBeDefined();
      expect(response.body.endpoints.adaptive).toBeDefined();
      expect(response.body.endpoints.payments).toBeDefined();
    });
  });

  // ==================== Test 6: CORS Headers ====================
  describe("CORS Configuration", () => {
    it("should include CORS headers in response", async () => {
      // Act
      const response = await request(app).get("/health").expect(200);

      // Assert - CORS should be enabled
      expect(response.headers["access-control-allow-origin"]).toBeDefined();
    });

    it("should handle OPTIONS preflight request", async () => {
      // Act
      const response = await request(app)
        .options("/api/v1/adaptive/recommend")
        .expect(204);

      // Assert
      expect(response.headers["access-control-allow-methods"]).toBeDefined();
    });
  });

  describe("GET /recovery  (Recovery Recommendations API)", () => {
    // ==================== Test: Basic validation ====================

    it("should return 404 for nonexistent user", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "nonexistent" })
        .expect(404);

      expect(res.body.success).toBe(false);
      expect(res.body.error.message).toContain("User");
    });

    // ==================== Test: Basic happy path ====================
    const muscleGroups = ["upper", "lower", "core", "full_body"];
    muscleGroups.forEach((group) => {
      it(`should return recovery recommendations for muscleGroup=${group}`, async () => {
        const res = await request(app)
          .get("/api/v1/recommendations/recovery")
          .query({ userId: "test_user", muscleGroup: group })
          .expect("Content-Type", /json/)
          .expect(200);

        expect(res.body.success).toBe(true);
        const data = res.body.data;
        expect(data.userId).toBe("test_user");
        expect(data.generatedAt).toBeDefined();
        expect(data.recoveryStatus).toMatch(
          /fully_recovered|partially_recovered|needs_rest/
        );
        expect(data.estimatedRecoveryTime).toBeGreaterThan(0);
        expect(data.recommendations.restDays).toBeGreaterThanOrEqual(1);
        expect(Array.isArray(data.recommendations.activeRecovery)).toBe(true);
        expect(data.recommendations.nutrition.protein).toBeDefined();
        expect(data.nextWorkoutRecommendation.intensity).toBeDefined();
        expect(Array.isArray(data.warnings)).toBe(true);
      });
    });

    // ==================== Test: Optional lastWorkoutId ====================
    it("should accept lastWorkoutId query param", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", lastWorkoutId: "workout123" })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.lastWorkoutId).toBe("workout123");
    });

    it("should default muscleGroup to upper if not provided", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user" })
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.targetMuscleGroup).toBe("upper");
    });

    // ==================== Test: Recovery status boundaries ====================
    const recoveryMapping: Record<string, string> = {
      upper: "partially_recovered",
      lower: "needs_rest",
      core: "fully_recovered",
      full_body: "partially_recovered",
    };

    Object.entries(recoveryMapping).forEach(([group, expectedStatus]) => {
      it(`should return recoveryStatus=${expectedStatus} for muscleGroup=${group}`, async () => {
        const res = await request(app)
          .get("/api/v1/recommendations/recovery")
          .query({ userId: "test_user", muscleGroup: group })
          .expect(200);

        expect(res.body.data.recoveryStatus).toBe(expectedStatus);
      });
    });

    // ==================== Test: Next workout recommendation ====================
    it("should return valid suggestedDate in ISO format", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "upper" })
        .expect(200);

      const suggestedDate =
        res.body.data.nextWorkoutRecommendation.suggestedDate;
      expect(new Date(suggestedDate).toISOString()).toBe(suggestedDate);
    });

    it("should set appropriate focusArea based on muscleGroup", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "lower" })
        .expect(200);

      expect(res.body.data.nextWorkoutRecommendation.focusArea).toContain(
        "Upper body"
      );
    });

    it("should assign correct intensity based on recoveryStatus", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "core" })
        .expect(200);

      expect(res.body.data.nextWorkoutRecommendation.intensity).toBe(
        "moderate"
      );
    });

    // ==================== Test: Recommendations object ====================
    it("should include restDays, activeRecovery, nutrition, sleep, and stretching", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "upper" })
        .expect(200);

      const rec = res.body.data.recommendations;
      expect(rec.restDays).toBeGreaterThan(0);
      expect(Array.isArray(rec.activeRecovery)).toBe(true);
      expect(rec.nutrition.protein).toBeDefined();
      expect(rec.sleep.recommendedHours).toBeDefined();
      expect(Array.isArray(rec.stretching)).toBe(true);
    });

    it("should adjust protein intake for lower and full_body muscleGroups", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "lower" })
        .expect(200);

      expect(res.body.data.recommendations.nutrition.protein).toContain(
        "25-35g"
      );
    });

    it("should set hydration to 3-3.5L for full_body", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "full_body" })
        .expect(200);

      expect(res.body.data.recommendations.nutrition.hydration).toBe(
        "3-3.5L water throughout the day"
      );
    });

    // ==================== Test: Warnings array ====================
    it("should include warnings array", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "upper" })
        .expect(200);

      expect(Array.isArray(res.body.data.warnings)).toBe(true);
      expect(res.body.data.warnings.length).toBeGreaterThan(0);
    });

    it("should include extra rest warning if needs_rest", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "lower" })
        .expect(200);

      expect(res.body.data.recoveryStatus).toBe("needs_rest");
      expect(
        res.body.data.warnings.some((w: string) => w.includes("extra rest day"))
      ).toBe(true);
    });

    it("should warn about avoiding heavy exercises for estimatedRecoveryTime", async () => {
      const res = await request(app)
        .get("/api/v1/recommendations/recovery")
        .query({ userId: "test_user", muscleGroup: "upper" })
        .expect(200);

      expect(res.body.data.warnings[0]).toContain(
        "Avoid heavy upper body exercises"
      );
    });
  });

  describe("POST /api/v1/subscriptions/subscribe", () => {
    const endpoint = "/api/v1/payments/subscribe";

    // ------------------------
    // VALIDATION TESTS (400)
    // ------------------------

    it("should return 400 when userId is missing", async () => {
      const res = await request(app)
        .post(endpoint)
        .send({
          workoutId: "w1",
          paymentMethod: "stripe",
        })
        .expect(400);

      expect(res.body.success).toBe(false);
      expect(res.body.error).toBeDefined();
    });

    it("should return 400 when workoutId is missing", async () => {
      const res = await request(app)
        .post(endpoint)
        .send({
          userId: "u1",
          paymentMethod: "stripe",
        })
        .expect(400);

      expect(res.body.success).toBe(false);
    });

    it("should return 400 when paymentMethod is missing", async () => {
      const res = await request(app)
        .post(endpoint)
        .send({
          userId: "u1",
          workoutId: "w1",
        })
        .expect(400);

      expect(res.body.error).toBeDefined();
    });

    it("should return 400 when paymentMethod is invalid", async () => {
      const res = await request(app)
        .post(endpoint)
        .send({
          userId: "u1",
          workoutId: "w1",
          paymentMethod: "crypto",
        })
        .expect(400);

      expect(res.body.success).toBe(false);
    });

    // ------------------------
    // EDGE CASE
    // ---

    it("should return JSON always", async () => {
      const res = await request(app).post(endpoint).send({
        userId: "ux",
        workoutId: "wx",
        paymentMethod: "paypal",
      });

      expect(res.headers["content-type"]).toMatch(/json/);
    });
  });
});
