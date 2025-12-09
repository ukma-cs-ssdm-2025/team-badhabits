import {
  db,
  getUserWorkoutSessions,
  getWorkoutsByDifficulty,
  getUserProfile,
  calculateAverageRating,
} from "../../services/FirebaseService";
import admin from "firebase-admin";

// Jest mock for firebase-admin
jest.mock("firebase-admin", () => {
  const firestoreMock = {
    collection: jest.fn(),
  };

  return {
    initializeApp: jest.fn(),
    credential: {
      applicationDefault: jest.fn(),
      cert: jest.fn(),
    },
    firestore: jest.fn(() => firestoreMock),
    apps: [],
  };
});

interface MockDoc {
  id: string;
  data: () => any;
}

function mockSnapshot(docs: MockDoc[]) {
  return {
    empty: docs.length === 0,
    docs,
  };
}

describe("Firebase Service Unit Tests", () => {
  let firestore: any;

  beforeEach(() => {
    firestore = admin.firestore();
    jest.clearAllMocks();
  });

  // -----------------------------
  // getUserWorkoutSessions()
  // -----------------------------
  describe("getUserWorkoutSessions()", () => {
    test("returns only completed sessions within last N days, sorted, max 20", async () => {
      const now = new Date();
      const old = new Date(Date.now() - 200 * 24 * 60 * 60 * 1000);

      const sessions = [
        { id: "1", completed_at: now.toISOString(), status: "completed" },
        { id: "2", completed_at: now.toISOString(), status: "completed" },
        { id: "3", completed_at: old.toISOString(), status: "completed" }, // filtered out
        { id: "4", status: "completed" }, // no completed_at → removed
      ];

      firestore.collection.mockReturnValue({
        doc: () => ({
          collection: () => ({
            where: () => ({
              limit: () => ({
                get: async () =>
                  mockSnapshot(
                    sessions.map((s) => ({
                      id: s.id,
                      data: () => s,
                    }))
                  ),
              }),
            }),
          }),
        }),
      });

      const result = await getUserWorkoutSessions("user123", 90);

      expect(result.length).toBe(2);
      expect(result[0].id).toBe("1");
      expect(result[1].id).toBe("2");
    });

    test("returns empty array if no sessions", async () => {
      firestore.collection.mockReturnValue({
        doc: () => ({
          collection: () => ({
            where: () => ({
              limit: () => ({
                get: async () => mockSnapshot([]),
              }),
            }),
          }),
        }),
      });

      const result = await getUserWorkoutSessions("user123");
      expect(result).toEqual([]);
    });
  });

  // -----------------------------
  // getWorkoutsByDifficulty()
  // -----------------------------
  describe("getWorkoutsByDifficulty()", () => {
    test("returns workouts with matching difficulty", async () => {
      const items = [
        { id: "w1", difficulty: "easy" },
        { id: "w2", difficulty: "easy" },
      ];

      firestore.collection.mockReturnValue({
        where: () => ({
          limit: () => ({
            get: async () =>
              mockSnapshot(items.map((i) => ({ id: i.id, data: () => i }))),
          }),
        }),
      });

      const result = await getWorkoutsByDifficulty("easy", 5);
      expect(result.length).toBe(2);
      expect(result[0].difficulty).toBe("easy");
    });

    test("falls back to any workouts if none match difficulty", async () => {
      const allWorkouts = [
        { id: "a1", difficulty: "medium" },
        { id: "a2", difficulty: "hard" },
      ];

      firestore.collection.mockReturnValue({
        where: () => ({
          limit: () => ({
            get: async () => mockSnapshot([]), // empty first
          }),
        }),
        limit: () => ({
          get: async () =>
            mockSnapshot(allWorkouts.map((w) => ({ id: w.id, data: () => w }))),
        }),
      });

      const result = await getWorkoutsByDifficulty("expert", 5);
      expect(result.length).toBe(2);
      expect(result[0].id).toBe("a1");
    });
  });

  // -----------------------------
  // getUserProfile()
  // -----------------------------
  describe("getUserProfile()", () => {
    test("returns user profile if exists", async () => {
      const data = { name: "John" };

      firestore.collection.mockReturnValue({
        doc: () => ({
          get: async () => ({
            exists: true,
            id: "user123",
            data: () => data,
          }),
        }),
      });

      const result = await getUserProfile("user123");

      expect(result).toEqual({
        id: "user123",
        name: "John",
      });
    });

    test("returns null if user not found", async () => {
      firestore.collection.mockReturnValue({
        doc: () => ({
          get: async () => ({
            exists: false,
          }),
        }),
      });

      const result = await getUserProfile("missing");
      expect(result).toBeNull();
    });
  });

  // -----------------------------
  // calculateAverageRating()
  // -----------------------------
  describe("calculateAverageRating()", () => {
    test("returns average rating", () => {
      const sessions = [
        { difficulty_rating: 5 },
        { difficulty_rating: 4 },
        { difficulty_rating: 3 },
      ];

      const avg = calculateAverageRating(sessions);
      expect(avg).toBe(4);
    });

    test("returns null when no ratings", () => {
      const sessions = [
        { difficulty_rating: null },
        { difficulty_rating: undefined },
      ];

      const avg = calculateAverageRating(sessions);
      expect(avg).toBeNull();
    });
  });
});
