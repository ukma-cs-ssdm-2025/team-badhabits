/**
 * Jest setup file - runs before all tests
 * Lab 6: Testing & Debugging
 */

// Set environment to test
process.env.NODE_ENV = 'test';

// Mock environment variables
process.env.STRIPE_API_KEY = 'sk_test_mock_key';
process.env.PORT = '3001';

// Global test utilities
global.console = {
  ...console,
  // Suppress console.log in tests unless explicitly needed
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  // Keep error and warn for debugging
  error: console.error,
  warn: console.warn,
};

// Mock Date.now() for consistent timestamps in tests
const MOCK_TIMESTAMP = 1640000000000; // 2021-12-20 12:26:40 UTC

// Store original Date
const OriginalDate = Date;

// Create mock Date constructor
const MockDate = class extends OriginalDate {
  constructor(...args: any[]) {
    if (args.length === 0) {
      super(MOCK_TIMESTAMP);
    } else {
      // @ts-ignore
      super(...args);
    }
  }

  static now() {
    return MOCK_TIMESTAMP;
  }
} as any;

// Replace global Date with mock
global.Date = MockDate;

// Add custom matchers
expect.extend({
  toBeWithinRange(received: number, floor: number, ceiling: number) {
    const pass = received >= floor && received <= ceiling;
    if (pass) {
      return {
        message: () =>
          `expected ${received} not to be within range ${floor} - ${ceiling}`,
        pass: true,
      };
    } else {
      return {
        message: () =>
          `expected ${received} to be within range ${floor} - ${ceiling}`,
        pass: false,
      };
    }
  },
});

// Setup and teardown hooks
beforeAll(() => {
  console.log('🧪 Starting test suite...');
});

afterAll(() => {
  console.log('✅ Test suite completed');
});

// Export test utilities
export const mockFirebase = {
  collection: jest.fn(() => ({
    doc: jest.fn(() => ({
      set: jest.fn(() => Promise.resolve()),
      get: jest.fn(() => Promise.resolve({ exists: true, data: () => ({}) })),
      update: jest.fn(() => Promise.resolve()),
      delete: jest.fn(() => Promise.resolve()),
    })),
    add: jest.fn(() => Promise.resolve({ id: 'mock_id' })),
  })),
};

export const createMockUserData = (overrides = {}) => ({
  user_id: 'test_user_123',
  fitness_level: 'intermediate' as const,
  age: 25,
  weight_kg: 70,
  height_cm: 175,
  injuries: [],
  available_equipment: ['dumbbells'],
  preferred_duration_minutes: 30,
  goals: ['strength', 'endurance'],
  past_ratings: [],
  ...overrides,
});

export const createMockWorkoutRating = (overrides = {}) => ({
  workout_id: 'workout_123',
  user_id: 'test_user_123',
  difficulty_rating: 3 as const,
  enjoyment_rating: 4,
  completion_time_seconds: 1800,
  notes: 'Good workout',
  timestamp: new Date(),
  ...overrides,
});
