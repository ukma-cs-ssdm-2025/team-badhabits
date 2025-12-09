/**
 * Integration tests for Recovery API endpoint (FR-006)
 *
 * Tests the /api/v1/recovery/status endpoint
 */

import request from 'supertest';
import app from '../../app';

// Mock FirebaseService
jest.mock('../../services/FirebaseService', () => ({
  getUserWorkoutSessions: jest.fn().mockImplementation((userId: string, days: number) => {
    // Return different data based on userId for testing
    if (userId === 'new_user') {
      return Promise.resolve([]);
    }

    if (userId === 'overtrained_user') {
      // Heavy training week: 7 sessions × 60 min × rating 5 = 2100 load
      return Promise.resolve(
        Array(7).fill(null).map((_, i) => {
          const date = new Date();
          date.setDate(date.getDate() - i);
          return {
            id: `session_${i}`,
            completed_at: date.toISOString(),
            total_duration_seconds: 3600, // 60 minutes
            difficulty_rating: 5,
            status: 'completed',
          };
        })
      );
    }

    if (userId === 'moderate_user') {
      // Moderate week: 4 sessions × 30 min × rating 3 = 360 load
      return Promise.resolve(
        Array(4).fill(null).map((_, i) => {
          const date = new Date();
          date.setDate(date.getDate() - i * 2); // Every other day
          return {
            id: `session_${i}`,
            completed_at: date.toISOString(),
            total_duration_seconds: 1800, // 30 minutes
            difficulty_rating: 3,
            status: 'completed',
          };
        })
      );
    }

    // Default: light training
    return Promise.resolve([
      {
        id: 'session_1',
        completed_at: new Date().toISOString(),
        total_duration_seconds: 1200, // 20 minutes
        difficulty_rating: 2,
        status: 'completed',
      },
    ]);
  }),
  getWorkoutsByDifficulty: jest.fn().mockResolvedValue([]),
  getUserProfile: jest.fn().mockResolvedValue({ id: 'test', fitness_level: 'intermediate' }),
  calculateAverageRating: jest.fn().mockReturnValue(3),
}));

describe('Recovery API Integration Tests', () => {
  // ==================== GET /api/v1/recovery/status ====================
  describe('GET /api/v1/recovery/status', () => {
    it('should return 400 when userId is missing', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .expect('Content-Type', /json/)
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error.code).toBe('VALIDATION_ERROR');
      expect(response.body.error.message).toContain('userId');
    });

    it('should return recovery status for new user with no workouts', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'new_user' })
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeDefined();

      const data = response.body.data;
      expect(data.userId).toBe('new_user');
      expect(data.status).toBe('ready');
      expect(data.trainingLoad).toBe(0);
      expect(data.recoveryTimeHours).toBe(0);
      expect(data.consecutiveHardDays).toBe(0);
      expect(data.canTrainToday).toBe(true);
      expect(data.sessionsAnalyzed).toBe(0);
    });

    it('should return READY status for light training', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'light_user' })
        .expect(200);

      expect(response.body.success).toBe(true);

      const data = response.body.data;
      expect(data.status).toBe('ready');
      expect(data.trainingLoad).toBeLessThan(300);
      expect(data.canTrainToday).toBe(true);
      expect(data.recommendation).toContain('well recovered');
    });

    it('should return MODERATE status for moderate training', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'moderate_user' })
        .expect(200);

      expect(response.body.success).toBe(true);

      const data = response.body.data;
      expect(data.status).toBe('moderate');
      expect(data.trainingLoad).toBeGreaterThanOrEqual(300);
      expect(data.trainingLoad).toBeLessThan(600);
      expect(data.canTrainToday).toBe(true);
      expect(data.recommendation).toContain('Light workout');
    });

    it('should return OVERTRAINING status for heavy training', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'overtrained_user' })
        .expect(200);

      expect(response.body.success).toBe(true);

      const data = response.body.data;
      expect(data.status).toBe('overtraining');
      expect(data.trainingLoad).toBeGreaterThanOrEqual(600);
      expect(data.canTrainToday).toBe(false);
      expect(data.recommendation).toContain('Rest day');
    });

    it('should accept optional days parameter', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'test_user', days: 14 })
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.analyzedDays).toBe(14);
    });

    it('should return 400 for invalid days parameter', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'test_user', days: 0 })
        .expect(400);

      expect(response.body.success).toBe(false);
      expect(response.body.error.message).toContain('days');
    });

    it('should return 400 for days > 30', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'test_user', days: 31 })
        .expect(400);

      expect(response.body.success).toBe(false);
    });

    it('should include all required fields in response', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'test_user' })
        .expect(200);

      const data = response.body.data;

      // Check all required fields
      expect(data).toHaveProperty('userId');
      expect(data).toHaveProperty('status');
      expect(data).toHaveProperty('trainingLoad');
      expect(data).toHaveProperty('recoveryTimeHours');
      expect(data).toHaveProperty('consecutiveHardDays');
      expect(data).toHaveProperty('recommendation');
      expect(data).toHaveProperty('canTrainToday');
      expect(data).toHaveProperty('analyzedDays');
      expect(data).toHaveProperty('sessionsAnalyzed');
    });

    it('should return valid status enum value', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'test_user' })
        .expect(200);

      const validStatuses = ['ready', 'moderate', 'overtraining'];
      expect(validStatuses).toContain(response.body.data.status);
    });

    it('should return numeric values for metrics', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'moderate_user' })
        .expect(200);

      const data = response.body.data;
      expect(typeof data.trainingLoad).toBe('number');
      expect(typeof data.recoveryTimeHours).toBe('number');
      expect(typeof data.consecutiveHardDays).toBe('number');
      expect(typeof data.sessionsAnalyzed).toBe('number');
      expect(typeof data.canTrainToday).toBe('boolean');
    });
  });

  // ==================== CORS ====================
  describe('CORS', () => {
    it('should include CORS headers', async () => {
      const response = await request(app)
        .get('/api/v1/recovery/status')
        .query({ userId: 'test_user' })
        .expect(200);

      expect(response.headers['access-control-allow-origin']).toBeDefined();
    });

    it('should handle OPTIONS preflight', async () => {
      const response = await request(app)
        .options('/api/v1/recovery/status')
        .expect(204);

      expect(response.headers['access-control-allow-methods']).toBeDefined();
    });
  });
});
