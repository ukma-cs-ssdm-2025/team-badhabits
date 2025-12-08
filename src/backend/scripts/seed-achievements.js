/**
 * Seed script for Achievements collection in Firestore
 *
 * Run this script to populate the achievements collection with all available achievements.
 *
 * Usage:
 *   node scripts/seed-achievements.js
 *
 * Make sure you have Firebase Admin SDK configured with proper credentials.
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin with service account
if (!admin.apps.length) {
  // Try to load service account from file
  try {
    const serviceAccount = require(path.join(__dirname, '../.service-account.json'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log('✅ Initialized with service account file\n');
  } catch {
    // Fallback to environment variables
    if (process.env.FIREBASE_PROJECT_ID) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
      });
      console.log('✅ Initialized with environment variables\n');
    } else {
      console.error('❌ No credentials found. Please provide:');
      console.error('   - .service-account.json file in src/backend/');
      console.error('   - Or FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY env vars');
      process.exit(1);
    }
  }
}

const db = admin.firestore();

// Achievement definitions
const achievements = [
  // ============================================
  // HABIT ACHIEVEMENTS
  // ============================================
  {
    id: 'habit_starter',
    name: 'Habit Starter',
    name_uk: 'Початківець звичок',
    description: 'Create your first habit',
    description_uk: 'Створи свою першу звичку',
    type: 'habit',
    tier: 'bronze',
    points: 5,
    icon: 'track_changes',
    criteria: { habits_created: 1 },
  },
  {
    id: 'habit_builder',
    name: 'Habit Builder',
    name_uk: 'Будівник звичок',
    description: 'Create 5 habits',
    description_uk: 'Створи 5 звичок',
    type: 'habit',
    tier: 'silver',
    points: 20,
    icon: 'track_changes',
    criteria: { habits_created: 5 },
  },
  {
    id: 'habit_expert',
    name: 'Habit Expert',
    name_uk: 'Експерт звичок',
    description: 'Track a habit for 30 days',
    description_uk: 'Відстежуй звичку 30 днів',
    type: 'habit',
    tier: 'gold',
    points: 75,
    icon: 'track_changes',
    criteria: { tracking_days: 30 },
  },
  {
    id: 'habit_master',
    name: 'Habit Master',
    name_uk: 'Майстер звичок',
    description: 'Create 10 habits',
    description_uk: 'Створи 10 звичок',
    type: 'habit',
    tier: 'platinum',
    points: 150,
    icon: 'track_changes',
    criteria: { habits_created: 10 },
  },

  // ============================================
  // STREAK ACHIEVEMENTS
  // ============================================
  {
    id: 'streak_beginner',
    name: 'Streak Beginner',
    name_uk: 'Початківець серій',
    description: 'Achieve a 7-day streak',
    description_uk: 'Досягни серії 7 днів',
    type: 'streak',
    tier: 'bronze',
    points: 10,
    icon: 'local_fire_department',
    criteria: { streak_days: 7 },
  },
  {
    id: 'streak_warrior',
    name: 'Streak Warrior',
    name_uk: 'Воїн серій',
    description: 'Achieve a 14-day streak',
    description_uk: 'Досягни серії 14 днів',
    type: 'streak',
    tier: 'silver',
    points: 30,
    icon: 'local_fire_department',
    criteria: { streak_days: 14 },
  },
  {
    id: 'streak_master',
    name: 'Streak Master',
    name_uk: 'Майстер серій',
    description: 'Achieve a 30-day streak',
    description_uk: 'Досягни серії 30 днів',
    type: 'streak',
    tier: 'gold',
    points: 100,
    icon: 'local_fire_department',
    criteria: { streak_days: 30 },
  },
  {
    id: 'streak_legend',
    name: 'Streak Legend',
    name_uk: 'Легенда серій',
    description: 'Achieve a 100-day streak',
    description_uk: 'Досягни серії 100 днів',
    type: 'streak',
    tier: 'platinum',
    points: 500,
    icon: 'local_fire_department',
    criteria: { streak_days: 100 },
  },

  // ============================================
  // WORKOUT ACHIEVEMENTS
  // ============================================
  {
    id: 'workout_rookie',
    name: 'Workout Rookie',
    name_uk: 'Новачок тренувань',
    description: 'Complete your first workout',
    description_uk: 'Заверши своє перше тренування',
    type: 'workout',
    tier: 'bronze',
    points: 5,
    icon: 'fitness_center',
    criteria: { workouts_completed: 1 },
  },
  {
    id: 'workout_warrior',
    name: 'Workout Warrior',
    name_uk: 'Воїн тренувань',
    description: 'Complete 10 workouts',
    description_uk: 'Заверши 10 тренувань',
    type: 'workout',
    tier: 'silver',
    points: 25,
    icon: 'fitness_center',
    criteria: { workouts_completed: 10 },
  },
  {
    id: 'workout_champion',
    name: 'Workout Champion',
    name_uk: 'Чемпіон тренувань',
    description: 'Complete 25 workouts',
    description_uk: 'Заверши 25 тренувань',
    type: 'workout',
    tier: 'gold',
    points: 75,
    icon: 'fitness_center',
    criteria: { workouts_completed: 25 },
  },
  {
    id: 'fitness_champion',
    name: 'Fitness Champion',
    name_uk: 'Фітнес чемпіон',
    description: 'Complete 50 workouts',
    description_uk: 'Заверши 50 тренувань',
    type: 'workout',
    tier: 'platinum',
    points: 200,
    icon: 'fitness_center',
    criteria: { workouts_completed: 50 },
  },

  // ============================================
  // MILESTONE ACHIEVEMENTS
  // ============================================
  {
    id: 'getting_started',
    name: 'Getting Started',
    name_uk: 'Початок шляху',
    description: 'Complete your profile',
    description_uk: 'Заповни свій профіль',
    type: 'milestone',
    tier: 'bronze',
    points: 5,
    icon: 'flag',
    criteria: { profile_completed: true },
  },
  {
    id: 'first_week',
    name: 'First Week',
    name_uk: 'Перший тиждень',
    description: 'Use the app for 7 days',
    description_uk: 'Користуйся додатком 7 днів',
    type: 'milestone',
    tier: 'bronze',
    points: 15,
    icon: 'flag',
    criteria: { app_days: 7 },
  },
  {
    id: 'first_month',
    name: 'First Month',
    name_uk: 'Перший місяць',
    description: 'Use the app for 30 days',
    description_uk: 'Користуйся додатком 30 днів',
    type: 'milestone',
    tier: 'silver',
    points: 50,
    icon: 'flag',
    criteria: { app_days: 30 },
  },
  {
    id: 'dedicated_user',
    name: 'Dedicated User',
    name_uk: 'Відданий користувач',
    description: 'Use the app for 100 days',
    description_uk: 'Користуйся додатком 100 днів',
    type: 'milestone',
    tier: 'gold',
    points: 150,
    icon: 'flag',
    criteria: { app_days: 100 },
  },

  // ============================================
  // SPECIAL ACHIEVEMENTS
  // ============================================
  {
    id: 'early_bird',
    name: 'Early Bird',
    name_uk: 'Рання пташка',
    description: 'Complete a habit before 7 AM',
    description_uk: 'Виконай звичку до 7 ранку',
    type: 'special',
    tier: 'bronze',
    points: 10,
    icon: 'star',
    criteria: { before_7am: true },
  },
  {
    id: 'night_owl',
    name: 'Night Owl',
    name_uk: 'Нічна сова',
    description: 'Complete a workout after 10 PM',
    description_uk: 'Заверши тренування після 22:00',
    type: 'special',
    tier: 'bronze',
    points: 10,
    icon: 'star',
    criteria: { after_10pm: true },
  },
  {
    id: 'perfectionist',
    name: 'Perfectionist',
    name_uk: 'Перфекціоніст',
    description: 'Complete all habits in a single day',
    description_uk: 'Виконай всі звички за один день',
    type: 'special',
    tier: 'silver',
    points: 25,
    icon: 'star',
    criteria: { all_habits_day: true },
  },
];

async function seedAchievements() {
  console.log('🌱 Starting to seed achievements...\n');

  const batch = db.batch();
  let count = 0;

  for (const achievement of achievements) {
    const { id, ...data } = achievement;
    const docRef = db.collection('achievements').doc(id);

    batch.set(docRef, {
      ...data,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    count++;
    console.log(`  ✅ Added: ${achievement.name} (${achievement.tier})`);
  }

  await batch.commit();

  console.log(`\n🎉 Successfully seeded ${count} achievements!`);
  console.log('\nAchievements by type:');

  const byType = achievements.reduce((acc, a) => {
    acc[a.type] = (acc[a.type] || 0) + 1;
    return acc;
  }, {});

  Object.entries(byType).forEach(([type, num]) => {
    console.log(`  - ${type}: ${num}`);
  });
}

// Run the seed function
seedAchievements()
  .then(() => {
    console.log('\n✨ Done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Error seeding achievements:', error);
    process.exit(1);
  });
