/**
 * Unit tests for RecoveryService (FR-006)
 *
 * Tests recovery recommendation logic including:
 * - Training load calculation
 * - Consecutive hard days calculation
 * - Recovery status determination
 * - Recommendation generation
 */

import {
  calculateTrainingLoad,
  calculateConsecutiveHardDays,
  determineRecoveryStatus,
  calculateRecoveryTimeHours,
  canTrainToday,
  generateRecommendationMessage,
  RECOVERY_STATUS,
  TRAINING_LOAD_THRESHOLDS,
} from '../../services/RecoveryService';

describe('RecoveryService', () => {
  // ==================== calculateTrainingLoad ====================
  describe('calculateTrainingLoad', () => {
    it('should return 0 for empty sessions array', () => {
      expect(calculateTrainingLoad([])).toBe(0);
    });

    it('should return 0 for null/undefined sessions', () => {
      expect(calculateTrainingLoad(null as any)).toBe(0);
      expect(calculateTrainingLoad(undefined as any)).toBe(0);
    });

    it('should calculate training load correctly', () => {
      // Training Load = Σ (duration × difficulty)
      // Session 1: 30 min × 3 rating = 90
      // Session 2: 45 min × 4 rating = 180
      // Total = 270
      const sessions = [
        { duration_minutes: 30, difficulty_rating: 3 },
        { duration_minutes: 45, difficulty_rating: 4 },
      ];

      expect(calculateTrainingLoad(sessions)).toBe(270);
    });

    it('should use total_duration_seconds when available', () => {
      // 1800 seconds = 30 minutes
      // 30 min × 4 = 120
      const sessions = [
        { total_duration_seconds: 1800, difficulty_rating: 4 },
      ];

      expect(calculateTrainingLoad(sessions)).toBe(120);
    });

    it('should use default values when fields are missing', () => {
      // Default duration = 30 min, default difficulty = 3
      // 30 × 3 = 90
      const sessions = [{}];

      expect(calculateTrainingLoad(sessions)).toBe(90);
    });

    it('should handle mixed session data formats', () => {
      const sessions = [
        { duration_minutes: 20, difficulty_rating: 2 }, // 40
        { total_duration_seconds: 2700, difficulty_rating: 5 }, // 45 min × 5 = 225
        { difficulty_rating: 4 }, // 30 × 4 = 120
      ];

      expect(calculateTrainingLoad(sessions)).toBe(385);
    });
  });

  // ==================== calculateConsecutiveHardDays ====================
  describe('calculateConsecutiveHardDays', () => {
    it('should return 0 for empty sessions', () => {
      expect(calculateConsecutiveHardDays([])).toBe(0);
    });

    it('should return 0 for null/undefined sessions', () => {
      expect(calculateConsecutiveHardDays(null as any)).toBe(0);
      expect(calculateConsecutiveHardDays(undefined as any)).toBe(0);
    });

    it('should count consecutive hard days (rating >= 4)', () => {
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      const twoDaysAgo = new Date(today);
      twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

      const sessions = [
        { completed_at: today.toISOString(), difficulty_rating: 4 },
        { completed_at: yesterday.toISOString(), difficulty_rating: 5 },
        { completed_at: twoDaysAgo.toISOString(), difficulty_rating: 4 },
      ];

      expect(calculateConsecutiveHardDays(sessions)).toBe(3);
    });

    it('should stop counting at non-hard day', () => {
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      const twoDaysAgo = new Date(today);
      twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

      const sessions = [
        { completed_at: today.toISOString(), difficulty_rating: 4 },
        { completed_at: yesterday.toISOString(), difficulty_rating: 2 }, // Not hard
        { completed_at: twoDaysAgo.toISOString(), difficulty_rating: 5 },
      ];

      expect(calculateConsecutiveHardDays(sessions)).toBe(1);
    });

    it('should handle completedAt field (camelCase)', () => {
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);

      const sessions = [
        { completedAt: today.toISOString(), difficulty_rating: 5 },
        { completedAt: yesterday.toISOString(), difficulty_rating: 4 },
      ];

      expect(calculateConsecutiveHardDays(sessions)).toBe(2);
    });

    it('should return 0 when no hard sessions', () => {
      const today = new Date();

      const sessions = [
        { completed_at: today.toISOString(), difficulty_rating: 2 },
        { completed_at: today.toISOString(), difficulty_rating: 3 },
      ];

      expect(calculateConsecutiveHardDays(sessions)).toBe(0);
    });

    it('should handle multiple sessions on same day', () => {
      const today = new Date();
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);

      const sessions = [
        { completed_at: today.toISOString(), difficulty_rating: 3 },
        { completed_at: today.toISOString(), difficulty_rating: 5 }, // Makes today hard
        { completed_at: yesterday.toISOString(), difficulty_rating: 4 },
      ];

      expect(calculateConsecutiveHardDays(sessions)).toBe(2);
    });
  });

  // ==================== determineRecoveryStatus ====================
  describe('determineRecoveryStatus', () => {
    it('should return READY for training load < 300', () => {
      expect(determineRecoveryStatus(0)).toBe(RECOVERY_STATUS.READY);
      expect(determineRecoveryStatus(150)).toBe(RECOVERY_STATUS.READY);
      expect(determineRecoveryStatus(299)).toBe(RECOVERY_STATUS.READY);
    });

    it('should return MODERATE for training load 300-599', () => {
      expect(determineRecoveryStatus(300)).toBe(RECOVERY_STATUS.MODERATE);
      expect(determineRecoveryStatus(450)).toBe(RECOVERY_STATUS.MODERATE);
      expect(determineRecoveryStatus(599)).toBe(RECOVERY_STATUS.MODERATE);
    });

    it('should return OVERTRAINING for training load >= 600', () => {
      expect(determineRecoveryStatus(600)).toBe(RECOVERY_STATUS.OVERTRAINING);
      expect(determineRecoveryStatus(800)).toBe(RECOVERY_STATUS.OVERTRAINING);
      expect(determineRecoveryStatus(1000)).toBe(RECOVERY_STATUS.OVERTRAINING);
    });

    it('should use correct threshold values', () => {
      expect(TRAINING_LOAD_THRESHOLDS.READY).toBe(300);
      expect(TRAINING_LOAD_THRESHOLDS.MODERATE).toBe(600);
    });
  });

  // ==================== calculateRecoveryTimeHours ====================
  describe('calculateRecoveryTimeHours', () => {
    it('should return 0 for 0 training load', () => {
      expect(calculateRecoveryTimeHours(0)).toBe(0);
    });

    it('should calculate recovery time as ceil(load/100)', () => {
      expect(calculateRecoveryTimeHours(100)).toBe(1);
      expect(calculateRecoveryTimeHours(150)).toBe(2);
      expect(calculateRecoveryTimeHours(350)).toBe(4);
      expect(calculateRecoveryTimeHours(600)).toBe(6);
    });

    it('should round up partial hours', () => {
      expect(calculateRecoveryTimeHours(101)).toBe(2);
      expect(calculateRecoveryTimeHours(199)).toBe(2);
      expect(calculateRecoveryTimeHours(201)).toBe(3);
    });
  });

  // ==================== canTrainToday ====================
  describe('canTrainToday', () => {
    it('should return true for READY status', () => {
      expect(canTrainToday(RECOVERY_STATUS.READY, 0)).toBe(true);
      expect(canTrainToday(RECOVERY_STATUS.READY, 2)).toBe(true);
    });

    it('should return true for MODERATE status with < 4 consecutive hard days', () => {
      expect(canTrainToday(RECOVERY_STATUS.MODERATE, 0)).toBe(true);
      expect(canTrainToday(RECOVERY_STATUS.MODERATE, 3)).toBe(true);
    });

    it('should return false for OVERTRAINING status', () => {
      expect(canTrainToday(RECOVERY_STATUS.OVERTRAINING, 0)).toBe(false);
      expect(canTrainToday(RECOVERY_STATUS.OVERTRAINING, 2)).toBe(false);
    });

    it('should return false for 4+ consecutive hard days', () => {
      expect(canTrainToday(RECOVERY_STATUS.READY, 4)).toBe(false);
      expect(canTrainToday(RECOVERY_STATUS.MODERATE, 5)).toBe(false);
    });
  });

  // ==================== generateRecommendationMessage ====================
  describe('generateRecommendationMessage', () => {
    it('should generate READY message', () => {
      const message = generateRecommendationMessage(RECOVERY_STATUS.READY, 200, 1);
      expect(message).toContain('well recovered');
      expect(message).toContain('ready for a full workout');
    });

    it('should generate MODERATE message', () => {
      const message = generateRecommendationMessage(RECOVERY_STATUS.MODERATE, 400, 2);
      expect(message).toContain('Light workout recommended');
      expect(message).toContain('moderate recovery');
    });

    it('should generate OVERTRAINING message', () => {
      const message = generateRecommendationMessage(RECOVERY_STATUS.OVERTRAINING, 700, 2);
      expect(message).toContain('Rest day strongly recommended');
      expect(message).toContain('High training load');
    });

    it('should add warning for 3+ consecutive hard days', () => {
      const message = generateRecommendationMessage(RECOVERY_STATUS.READY, 200, 3);
      expect(message).toContain('Warning');
      expect(message).toContain('3 consecutive days');
      expect(message).toContain('rest day tomorrow');
    });

    it('should not add warning for < 3 consecutive hard days', () => {
      const message = generateRecommendationMessage(RECOVERY_STATUS.READY, 200, 2);
      expect(message).not.toContain('Warning');
    });
  });

  // ==================== Integration scenarios ====================
  describe('Integration scenarios', () => {
    it('should handle new user with no workouts', () => {
      const sessions: any[] = [];
      const load = calculateTrainingLoad(sessions);
      const hardDays = calculateConsecutiveHardDays(sessions);
      const status = determineRecoveryStatus(load);

      expect(load).toBe(0);
      expect(hardDays).toBe(0);
      expect(status).toBe(RECOVERY_STATUS.READY);
      expect(canTrainToday(status, hardDays)).toBe(true);
    });

    it('should identify overtraining from heavy week', () => {
      // 7 days × 60 min × 4 difficulty = 1680
      const sessions = Array(7).fill(null).map((_, i) => {
        const date = new Date();
        date.setDate(date.getDate() - i);
        return {
          completed_at: date.toISOString(),
          duration_minutes: 60,
          difficulty_rating: 4,
        };
      });

      const load = calculateTrainingLoad(sessions);
      const status = determineRecoveryStatus(load);

      expect(load).toBe(1680);
      expect(status).toBe(RECOVERY_STATUS.OVERTRAINING);
    });

    it('should recommend rest after 4 consecutive hard days', () => {
      const sessions = Array(4).fill(null).map((_, i) => {
        const date = new Date();
        date.setDate(date.getDate() - i);
        return {
          completed_at: date.toISOString(),
          duration_minutes: 30,
          difficulty_rating: 5,
        };
      });

      const hardDays = calculateConsecutiveHardDays(sessions);

      expect(hardDays).toBe(4);
      expect(canTrainToday(RECOVERY_STATUS.READY, hardDays)).toBe(false);
    });
  });
});
