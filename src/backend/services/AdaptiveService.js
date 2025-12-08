const {
  getUserWorkoutSessions,
  getWorkoutsByDifficulty,
  getUserProfile,
  calculateAverageRating,
} = require('./FirebaseService');

const DIFFICULTY_LEVELS = ['beginner', 'intermediate', 'advanced'];

const FALLBACK_EXERCISES = {
  beginner: [
    { name: 'Wall Push-ups', sets: 2, reps: 10, restSeconds: 90 },
    { name: 'Bodyweight Squats', sets: 2, reps: 12, restSeconds: 90 },
    { name: 'Knee Plank', sets: 2, reps: 30, restSeconds: 90 },
  ],
  intermediate: [
    { name: 'Push-ups', sets: 3, reps: 12, restSeconds: 60 },
    { name: 'Squats', sets: 4, reps: 15, restSeconds: 60 },
    { name: 'Plank', sets: 3, reps: 45, restSeconds: 60 },
  ],
  advanced: [
    { name: 'Diamond Push-ups', sets: 4, reps: 15, restSeconds: 45 },
    { name: 'Jump Squats', sets: 4, reps: 20, restSeconds: 45 },
    { name: 'Plank with Leg Raise', sets: 4, reps: 60, restSeconds: 45 },
  ],
};

function determineTargetDifficulty(avgRating, currentDifficulty) {
  const currentIndex = DIFFICULTY_LEVELS.indexOf(currentDifficulty);

  if (avgRating === null) {
    return { difficulty: currentDifficulty || 'intermediate', reason: 'No rating history - using default level' };
  }

  // difficulty_rating scale: 1 = too easy, 5 = too hard
  // If avg >= 4: workouts were too hard -> decrease difficulty
  // If avg <= 2: workouts were too easy -> increase difficulty
  // Between 2-4: good balance -> maintain
  if (avgRating >= 4.0) {
    const newIndex = Math.max(currentIndex - 1, 0);
    return {
      difficulty: DIFFICULTY_LEVELS[newIndex],
      reason: `Workouts were too hard (avg: ${avgRating.toFixed(1)}/5) - decreasing intensity`,
    };
  }

  if (avgRating <= 2.0) {
    const newIndex = Math.min(currentIndex + 1, DIFFICULTY_LEVELS.length - 1);
    return {
      difficulty: DIFFICULTY_LEVELS[newIndex],
      reason: `Workouts were too easy (avg: ${avgRating.toFixed(1)}/5) - increasing intensity`,
    };
  }

  return {
    difficulty: currentDifficulty || 'intermediate',
    reason: `Good balance (avg: ${avgRating.toFixed(1)}/5) - maintaining current level`,
  };
}

async function getAdaptiveRecommendation(userId) {
  const [sessions, profile] = await Promise.all([
    getUserWorkoutSessions(userId, 90),
    getUserProfile(userId),
  ]);

  const avgRating = calculateAverageRating(sessions);
  const currentDifficulty = profile?.fitness_level || 'intermediate';

  const { difficulty, reason } = determineTargetDifficulty(avgRating, currentDifficulty);

  const workouts = await getWorkoutsByDifficulty(difficulty, 5);

  let selectedWorkout;
  if (workouts.length > 0) {
    const randomIndex = Math.floor(Math.random() * workouts.length);
    selectedWorkout = workouts[randomIndex];
  } else {
    selectedWorkout = {
      id: `generated_${Date.now()}`,
      title: `${difficulty.charAt(0).toUpperCase() + difficulty.slice(1)} Workout`,
      description: 'Auto-generated adaptive workout',
      exercises: FALLBACK_EXERCISES[difficulty],
      duration_minutes: difficulty === 'beginner' ? 20 : difficulty === 'intermediate' ? 30 : 40,
      estimated_calories: difficulty === 'beginner' ? 150 : difficulty === 'intermediate' ? 250 : 350,
      difficulty,
      is_adaptive: true,
      is_verified: false,
    };
  }

  return {
    workout: {
      id: selectedWorkout.id,
      title: selectedWorkout.title,
      description: selectedWorkout.description || '',
      exercises: selectedWorkout.exercises || FALLBACK_EXERCISES[difficulty],
      duration_minutes: selectedWorkout.duration_minutes || 30,
      estimated_calories: selectedWorkout.estimated_calories || 200,
      difficulty: selectedWorkout.difficulty || difficulty,
      is_adaptive: true,
      is_verified: selectedWorkout.is_verified || false,
      equipment_required: selectedWorkout.equipment_required || [],
    },
    recommendation: {
      reason,
      basedOnSessions: sessions.length,
      averageRating: avgRating,
      targetDifficulty: difficulty,
      userFitnessLevel: profile?.fitness_level || 'intermediate',
    },
  };
}

module.exports = {
  getAdaptiveRecommendation,
  determineTargetDifficulty,
  DIFFICULTY_LEVELS,
};
