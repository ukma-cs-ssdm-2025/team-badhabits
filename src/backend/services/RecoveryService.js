/**
 * Recovery Recommendations Service (FR-006)
 *
 * Analyzes workout sessions to provide personalized recovery recommendations.
 * Uses training load calculation to determine recovery status.
 */

const { getUserWorkoutSessions } = require('./FirebaseService');

// Recovery status thresholds
const TRAINING_LOAD_THRESHOLDS = {
  READY: 300, // < 300 = ready to train
  MODERATE: 600, // 300-600 = moderate recovery needed
  // > 600 = overtraining, rest needed
};

// Recovery status types
const RECOVERY_STATUS = {
  READY: 'ready',
  MODERATE: 'moderate',
  OVERTRAINING: 'overtraining',
};

/**
 * Calculate training load from workout sessions
 * Training Load = Σ (duration_minutes × difficulty_rating) for last N days
 *
 * @param {Array} sessions - Workout sessions
 * @returns {number} - Total training load
 */
function calculateTrainingLoad(sessions) {
  if (!sessions || sessions.length === 0) {
    return 0;
  }

  return sessions.reduce((total, session) => {
    const duration = session.total_duration_seconds
      ? Math.round(session.total_duration_seconds / 60)
      : session.duration_minutes || 30;
    const difficulty = session.difficulty_rating || 3;
    return total + duration * difficulty;
  }, 0);
}

/**
 * Calculate consecutive hard training days
 * Hard day = difficulty_rating >= 4
 *
 * @param {Array} sessions - Workout sessions sorted by date desc
 * @returns {number} - Number of consecutive hard days
 */
function calculateConsecutiveHardDays(sessions) {
  if (!sessions || sessions.length === 0) {
    return 0;
  }

  // Sort sessions by date (newest first)
  const sortedSessions = [...sessions].sort((a, b) => {
    const dateA = new Date(a.completed_at || a.completedAt);
    const dateB = new Date(b.completed_at || b.completedAt);
    return dateB - dateA;
  });

  // Group sessions by day
  const sessionsByDay = new Map();
  sortedSessions.forEach((session) => {
    const date = new Date(session.completed_at || session.completedAt);
    const dayKey = date.toISOString().split('T')[0];

    if (!sessionsByDay.has(dayKey)) {
      sessionsByDay.set(dayKey, []);
    }
    sessionsByDay.get(dayKey).push(session);
  });

  // Get unique days sorted by date (newest first)
  const days = Array.from(sessionsByDay.keys()).sort().reverse();

  let consecutiveHardDays = 0;

  for (const day of days) {
    const daySessions = sessionsByDay.get(day);
    // Check if any session on this day was hard (rating >= 4)
    const hadHardSession = daySessions.some(
      (s) => (s.difficulty_rating || 0) >= 4
    );

    if (hadHardSession) {
      consecutiveHardDays++;
    } else {
      break; // Stop counting when we hit a non-hard day
    }
  }

  return consecutiveHardDays;
}

/**
 * Determine recovery status based on training load
 *
 * @param {number} trainingLoad - Total training load
 * @returns {string} - Recovery status
 */
function determineRecoveryStatus(trainingLoad) {
  if (trainingLoad < TRAINING_LOAD_THRESHOLDS.READY) {
    return RECOVERY_STATUS.READY;
  }
  if (trainingLoad < TRAINING_LOAD_THRESHOLDS.MODERATE) {
    return RECOVERY_STATUS.MODERATE;
  }
  return RECOVERY_STATUS.OVERTRAINING;
}

/**
 * Generate recommendation message based on status
 *
 * @param {string} status - Recovery status
 * @param {number} trainingLoad - Training load value
 * @param {number} consecutiveHardDays - Number of consecutive hard days
 * @returns {string} - Recommendation message
 */
function generateRecommendationMessage(status, trainingLoad, consecutiveHardDays) {
  let message = '';

  switch (status) {
    case RECOVERY_STATUS.READY:
      message = 'You are well recovered and ready for a full workout. Your body has had adequate rest.';
      break;
    case RECOVERY_STATUS.MODERATE:
      message = 'Light workout recommended. Your body needs moderate recovery time.';
      break;
    case RECOVERY_STATUS.OVERTRAINING:
      message = 'Rest day strongly recommended. High training load detected - your body needs recovery.';
      break;
    default:
      message = 'Unable to determine recovery status.';
  }

  // Add warning for consecutive hard days
  if (consecutiveHardDays >= 3) {
    message += ' Warning: You have trained hard for ' + consecutiveHardDays + ' consecutive days. Consider taking a rest day tomorrow.';
  }

  return message;
}

/**
 * Calculate estimated recovery time in hours
 *
 * @param {number} trainingLoad - Training load value
 * @returns {number} - Recovery time in hours
 */
function calculateRecoveryTimeHours(trainingLoad) {
  if (trainingLoad === 0) {
    return 0;
  }
  return Math.ceil(trainingLoad / 100);
}

/**
 * Determine if user can train today
 *
 * @param {string} status - Recovery status
 * @param {number} consecutiveHardDays - Consecutive hard training days
 * @returns {boolean} - Whether user can train
 */
function canTrainToday(status, consecutiveHardDays) {
  // Don't train if overtraining or 4+ consecutive hard days
  if (status === RECOVERY_STATUS.OVERTRAINING || consecutiveHardDays >= 4) {
    return false;
  }
  return true;
}

/**
 * Get recovery recommendation for a user (FR-006)
 *
 * @param {string} userId - Firebase user ID
 * @param {number} days - Number of days to analyze (default: 7)
 * @returns {Promise<Object>} - Recovery recommendation
 */
async function getRecoveryRecommendation(userId, days = 7) {
  // Get workout sessions from last N days
  const sessions = await getUserWorkoutSessions(userId, days);

  // Calculate metrics
  const trainingLoad = calculateTrainingLoad(sessions);
  const consecutiveHardDays = calculateConsecutiveHardDays(sessions);
  const status = determineRecoveryStatus(trainingLoad);
  const recoveryTimeHours = calculateRecoveryTimeHours(trainingLoad);
  const recommendation = generateRecommendationMessage(status, trainingLoad, consecutiveHardDays);
  const canTrain = canTrainToday(status, consecutiveHardDays);

  return {
    userId,
    status,
    trainingLoad,
    recoveryTimeHours,
    consecutiveHardDays,
    recommendation,
    canTrainToday: canTrain,
    analyzedDays: days,
    sessionsAnalyzed: sessions.length,
    lastWorkout: sessions.length > 0 ? sessions[0].completed_at || sessions[0].completedAt : null,
  };
}

module.exports = {
  getRecoveryRecommendation,
  calculateTrainingLoad,
  calculateConsecutiveHardDays,
  determineRecoveryStatus,
  calculateRecoveryTimeHours,
  canTrainToday,
  generateRecommendationMessage,
  RECOVERY_STATUS,
  TRAINING_LOAD_THRESHOLDS,
};
