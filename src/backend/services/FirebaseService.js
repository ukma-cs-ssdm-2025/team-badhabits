const admin = require('firebase-admin');

if (!admin.apps.length) {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    // Use service account file
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
  } else if (process.env.FIREBASE_PROJECT_ID) {
    // Use env variables (for Railway deployment)
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      }),
    });
  } else {
    // Default (for Google Cloud environments)
    admin.initializeApp();
  }
}

const db = admin.firestore();

async function getUserWorkoutSessions(userId, days = 90) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);

  const snapshot = await db
    .collection('users')
    .doc(userId)
    .collection('workout_sessions')
    .where('status', '==', 'completed')
    .limit(50)
    .get();

  const sessions = snapshot.docs
    .map(doc => ({ id: doc.id, ...doc.data() }))
    .filter(s => {
      if (!s.completed_at) return false;
      const completedAt = new Date(s.completed_at);
      return completedAt >= cutoffDate;
    })
    .sort((a, b) => new Date(b.completed_at) - new Date(a.completed_at))
    .slice(0, 20);

  return sessions;
}

async function getWorkoutsByDifficulty(difficulty, limit = 5) {
  // First try with difficulty filter
  let snapshot = await db
    .collection('workouts')
    .where('difficulty', '==', difficulty)
    .limit(limit)
    .get();

  // If no workouts found with exact difficulty, get any workouts
  if (snapshot.empty) {
    snapshot = await db.collection('workouts').limit(limit).get();
  }

  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data(),
  }));
}

async function getUserProfile(userId) {
  const doc = await db.collection('users').doc(userId).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
}

function calculateAverageRating(sessions) {
  const ratings = sessions
    .filter(s => s.difficulty_rating != null)
    .map(s => s.difficulty_rating);

  if (ratings.length === 0) return null;
  return ratings.reduce((sum, r) => sum + r, 0) / ratings.length;
}

module.exports = {
  db,
  getUserWorkoutSessions,
  getWorkoutsByDifficulty,
  getUserProfile,
  calculateAverageRating,
};
