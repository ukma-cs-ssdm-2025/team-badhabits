const request = require('supertest');
const app = require('../../app');

describe('Statistics API Integration Tests', () => {
  const testUserId = 'test_user_123';

  describe('GET /api/v1/statistics/user/:userId', () => {
    it('should return overall statistics for user', async () => {
      const response = await request(app)
        .get(`/api/v1/statistics/user/${testUserId}`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('userId', testUserId);
      expect(response.body.data).toHaveProperty('statistics');
      expect(response.body.data.statistics).toHaveProperty('totalWorkouts');
      expect(response.body.data.statistics).toHaveProperty('totalDurationMinutes');
      expect(response.body.data.statistics).toHaveProperty('averageDifficultyRating');
    });

    it('should return 404 for non-existent user', async () => {
      const response = await request(app)
        .get('/api/v1/statistics/user/nonexistent')
        .expect(404);

      expect(response.body.success).toBe(false);
    });

    it('should return 400 for missing userId', async () => {
      await request(app).get('/api/v1/statistics/user/').expect(404);
    });
  });

  describe('GET /api/v1/statistics/user/:userId/workouts', () => {
    it('should return weekly statistics', async () => {
      const response = await request(app)
        .get(`/api/v1/statistics/user/${testUserId}/workouts?period=week`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data.period).toBe('week');
      expect(response.body.data).toHaveProperty('dateRange');
      expect(response.body.data.statistics).toHaveProperty('workoutsByDay');
    });

    it('should return monthly statistics by default', async () => {
      const response = await request(app)
        .get(`/api/v1/statistics/user/${testUserId}/workouts`)
        .expect(200);

      expect(response.body.data.period).toBe('month');
    });

    it('should return 400 for invalid period', async () => {
      const response = await request(app)
        .get(`/api/v1/statistics/user/${testUserId}/workouts?period=invalid`)
        .expect(400);

      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /api/v1/statistics/user/:userId/progress', () => {
    it('should return progress metrics', async () => {
      const response = await request(app)
        .get(`/api/v1/statistics/user/${testUserId}/progress`)
        .expect(200);

      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('progressMetrics');
      expect(response.body.data.progressMetrics).toHaveProperty('weeklyWorkouts');
      expect(response.body.data.progressMetrics).toHaveProperty('averageDifficultyTrend');
      expect(response.body.data.progressMetrics).toHaveProperty('caloriesTrend');
    });
  });
});
