/**
 * TypeScript declarations for RecoveryService (FR-006)
 */

export interface WorkoutSession {
  id?: string;
  completed_at?: string;
  completedAt?: string;
  total_duration_seconds?: number;
  duration_minutes?: number;
  difficulty_rating?: number;
  status?: string;
}

export interface RecoveryRecommendation {
  userId: string;
  status: 'ready' | 'moderate' | 'overtraining';
  trainingLoad: number;
  recoveryTimeHours: number;
  consecutiveHardDays: number;
  recommendation: string;
  canTrainToday: boolean;
  analyzedDays: number;
  sessionsAnalyzed: number;
  lastWorkout: string | null;
}

export const RECOVERY_STATUS: {
  READY: 'ready';
  MODERATE: 'moderate';
  OVERTRAINING: 'overtraining';
};

export const TRAINING_LOAD_THRESHOLDS: {
  READY: number;
  MODERATE: number;
};

export function calculateTrainingLoad(sessions: WorkoutSession[]): number;

export function calculateConsecutiveHardDays(sessions: WorkoutSession[]): number;

export function determineRecoveryStatus(trainingLoad: number): 'ready' | 'moderate' | 'overtraining';

export function calculateRecoveryTimeHours(trainingLoad: number): number;

export function canTrainToday(status: string, consecutiveHardDays: number): boolean;

export function generateRecommendationMessage(
  status: string,
  trainingLoad: number,
  consecutiveHardDays: number
): string;

export function getRecoveryRecommendation(
  userId: string,
  days?: number
): Promise<RecoveryRecommendation>;
