const { firestore } = require('../config/firebase-admin');

class StatisticsService {
  async getUserWorkoutSessions(userId) {
    const sessionsRef = firestore
      .collection('users')
      .doc(userId)
      .collection('workout_sessions')
      .where('status', '==', 'completed')
      .orderBy('completedAt', 'desc');

    const snapshot = await sessionsRef.get();

    if (snapshot.empty) {
      return [];
    }

    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
  }

  async calculateOverallStatistics(userId) {
    const sessions = await this.getUserWorkoutSessions(userId);

    if (sessions.length === 0) {
      return this._getEmptyStatistics(userId);
    }

    const totalWorkouts = sessions.length;
    const totalDurationSeconds = sessions.reduce(
      (sum, s) => sum + (s.totalDurationSeconds || 0),
      0,
    );
    const totalDurationMinutes = Math.round(totalDurationSeconds / 60);
    const averageDurationMinutes = Math.round(totalDurationMinutes / totalWorkouts);

    const totalCalories = sessions.reduce(
      (sum, s) => sum + (s.caloriesBurned || 0),
      0,
    );
    const averageCalories = Math.round(totalCalories / totalWorkouts);

    const ratingsData = sessions.filter((s) => s.difficultyRating);
    const avgDifficulty =
      ratingsData.length > 0
        ? (
            ratingsData.reduce((sum, s) => sum + s.difficultyRating, 0) /
            ratingsData.length
          ).toFixed(1)
        : 0;

    const enjoymentData = sessions.filter((s) => s.enjoymentRating);
    const avgEnjoyment =
      enjoymentData.length > 0
        ? (
            enjoymentData.reduce((sum, s) => sum + s.enjoymentRating, 0) /
            enjoymentData.length
          ).toFixed(1)
        : 0;

    const { currentStreak, longestStreak } = this._calculateStreaks(sessions);

    const lastWorkoutDate = sessions[0]?.completedAt || null;

    return {
      userId,
      statistics: {
        totalWorkouts,
        totalDurationMinutes,
        averageDurationMinutes,
        totalCaloriesBurned: totalCalories,
        averageCaloriesPerWorkout: averageCalories,
        averageDifficultyRating: parseFloat(avgDifficulty),
        averageEnjoymentRating: parseFloat(avgEnjoyment),
        currentStreak,
        longestStreak,
        lastWorkoutDate,
      },
    };
  }

  async calculatePeriodStatistics(userId, period = 'month') {
    const sessions = await this.getUserWorkoutSessions(userId);

    const dateRange = this._getDateRange(period);

    const filteredSessions = sessions.filter((s) => {
      const completedDate = new Date(s.completedAt);
      return completedDate >= dateRange.start && completedDate <= dateRange.end;
    });

    if (filteredSessions.length === 0) {
      return {
        userId,
        period,
        dateRange: {
          start: dateRange.start.toISOString(),
          end: dateRange.end.toISOString(),
        },
        statistics: this._getEmptyPeriodStatistics(),
      };
    }

    const totalWorkouts = filteredSessions.length;
    const totalDurationSeconds = filteredSessions.reduce(
      (sum, s) => sum + (s.totalDurationSeconds || 0),
      0,
    );
    const totalDurationMinutes = Math.round(totalDurationSeconds / 60);
    const averageDurationMinutes = Math.round(totalDurationMinutes / totalWorkouts);

    const totalCalories = filteredSessions.reduce(
      (sum, s) => sum + (s.caloriesBurned || 0),
      0,
    );

    const ratingsData = filteredSessions.filter((s) => s.difficultyRating);
    const avgDifficulty =
      ratingsData.length > 0
        ? (
            ratingsData.reduce((sum, s) => sum + s.difficultyRating, 0) /
            ratingsData.length
          ).toFixed(1)
        : 0;

    const workoutsByDay = this._calculateWorkoutsByDay(filteredSessions, dateRange);

    return {
      userId,
      period,
      dateRange: {
        start: dateRange.start.toISOString(),
        end: dateRange.end.toISOString(),
      },
      statistics: {
        totalWorkouts,
        totalDurationMinutes,
        averageDurationMinutes,
        totalCaloriesBurned: totalCalories,
        averageDifficultyRating: parseFloat(avgDifficulty),
        workoutsByDay,
      },
    };
  }

  async calculateProgressMetrics(userId) {
    const sessions = await this.getUserWorkoutSessions(userId);

    if (sessions.length === 0) {
      return {
        userId,
        progressMetrics: {
          weeklyWorkouts: [],
          averageDifficultyTrend: [],
          caloriesTrend: [],
        },
      };
    }

    const weeklyWorkouts = this._groupByWeek(sessions);
    const difficultyTrend = this._calculateDifficultyTrend(sessions);
    const caloriesTrend = this._groupCaloriesByWeek(sessions);

    return {
      userId,
      progressMetrics: {
        weeklyWorkouts,
        averageDifficultyTrend: difficultyTrend,
        caloriesTrend,
      },
    };
  }

  _getEmptyStatistics(userId) {
    return {
      userId,
      statistics: {
        totalWorkouts: 0,
        totalDurationMinutes: 0,
        averageDurationMinutes: 0,
        totalCaloriesBurned: 0,
        averageCaloriesPerWorkout: 0,
        averageDifficultyRating: 0,
        averageEnjoymentRating: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastWorkoutDate: null,
      },
    };
  }

  _getEmptyPeriodStatistics() {
    return {
      totalWorkouts: 0,
      totalDurationMinutes: 0,
      averageDurationMinutes: 0,
      totalCaloriesBurned: 0,
      averageDifficultyRating: 0,
      workoutsByDay: [],
    };
  }

  _calculateStreaks(sessions) {
    const sorted = [...sessions].sort(
      (a, b) => new Date(a.completedAt) - new Date(b.completedAt),
    );

    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    let lastDate = null;

    for (const session of sorted) {
      const sessionDate = new Date(session.completedAt);
      sessionDate.setHours(0, 0, 0, 0);

      if (!lastDate) {
        tempStreak = 1;
      } else {
        const daysDiff = Math.floor(
          (sessionDate - lastDate) / (1000 * 60 * 60 * 24),
        );

        if (daysDiff === 1) {
          tempStreak += 1;
        } else if (daysDiff === 0) {
          continue;
        } else {
          tempStreak = 1;
        }
      }

      longestStreak = Math.max(longestStreak, tempStreak);
      lastDate = sessionDate;
    }

    if (sorted.length > 0) {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const lastWorkoutDate = new Date(sorted[sorted.length - 1].completedAt);
      lastWorkoutDate.setHours(0, 0, 0, 0);

      const daysSinceLastWorkout = Math.floor(
        (today - lastWorkoutDate) / (1000 * 60 * 60 * 24),
      );

      if (daysSinceLastWorkout <= 1) {
        currentStreak = tempStreak;
      } else {
        currentStreak = 0;
      }
    }

    return { currentStreak, longestStreak };
  }

  _getDateRange(period) {
    const now = new Date();
    const end = new Date(now);
    let start = new Date(now);

    switch (period) {
      case 'week':
        start.setDate(now.getDate() - 7);
        break;
      case 'month':
        start.setMonth(now.getMonth() - 1);
        break;
      case 'year':
        start.setFullYear(now.getFullYear() - 1);
        break;
      case 'all':
      default:
        start = new Date(0);
        break;
    }

    start.setHours(0, 0, 0, 0);
    end.setHours(23, 59, 59, 999);

    return { start, end };
  }

  _calculateWorkoutsByDay(sessions, dateRange) {
    const days = [];
    const currentDate = new Date(dateRange.start);

    const workoutCounts = {};
    sessions.forEach((session) => {
      const date = new Date(session.completedAt);
      const dateKey = date.toISOString().split('T')[0];
      workoutCounts[dateKey] = (workoutCounts[dateKey] || 0) + 1;
    });

    while (currentDate <= dateRange.end) {
      const dateKey = currentDate.toISOString().split('T')[0];
      days.push({
        date: dateKey,
        count: workoutCounts[dateKey] || 0,
      });
      currentDate.setDate(currentDate.getDate() + 1);
    }

    return days;
  }

  _groupByWeek(sessions) {
    const weeklyData = {};

    sessions.forEach((session) => {
      const date = new Date(session.completedAt);
      const year = date.getFullYear();
      const week = this._getWeekNumber(date);
      const weekKey = `${year}-W${week.toString().padStart(2, '0')}`;

      weeklyData[weekKey] = (weeklyData[weekKey] || 0) + 1;
    });

    return Object.entries(weeklyData)
      .map(([week, count]) => ({ week, count }))
      .sort((a, b) => a.week.localeCompare(b.week));
  }

  _calculateDifficultyTrend(sessions) {
    const monthlyData = {};

    sessions.forEach((session) => {
      if (!session.difficultyRating) return;

      const date = new Date(session.completedAt);
      const monthKey = `${date.getFullYear()}-${(date.getMonth() + 1)
        .toString()
        .padStart(2, '0')}`;

      if (!monthlyData[monthKey]) {
        monthlyData[monthKey] = { sum: 0, count: 0 };
      }

      monthlyData[monthKey].sum += session.difficultyRating;
      monthlyData[monthKey].count += 1;
    });

    return Object.entries(monthlyData)
      .map(([month, data]) => ({
        month,
        average: parseFloat((data.sum / data.count).toFixed(1)),
      }))
      .sort((a, b) => a.month.localeCompare(b.month));
  }

  _groupCaloriesByWeek(sessions) {
    const weeklyData = {};

    sessions.forEach((session) => {
      const date = new Date(session.completedAt);
      const year = date.getFullYear();
      const week = this._getWeekNumber(date);
      const weekKey = `${year}-W${week.toString().padStart(2, '0')}`;

      weeklyData[weekKey] =
        (weeklyData[weekKey] || 0) + (session.caloriesBurned || 0);
    });

    return Object.entries(weeklyData)
      .map(([week, total]) => ({ week, total }))
      .sort((a, b) => a.week.localeCompare(b.week));
  }

  _getWeekNumber(date) {
    const d = new Date(
      Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()),
    );
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((d - yearStart) / 86400000 + 1) / 7);
  }
}

module.exports = StatisticsService;
