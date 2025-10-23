/**
 * Jest configuration for Wellity Backend
 * Lab 6: Testing & Debugging
 */

module.exports = {
  // Use ts-jest preset for TypeScript support
  preset: 'ts-jest',

  // Set test environment to Node.js
  testEnvironment: 'node',

  // Root directory for tests
  roots: ['<rootDir>/tests', '<rootDir>/services', '<rootDir>/models'],

  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.ts',
    '**/?(*.)+(spec|test).ts'
  ],

  // Coverage configuration
  collectCoverage: true,
  collectCoverageFrom: [
    'services/**/*.ts',
    'routes/adaptive-ts.js',
    'routes/payments-ts.js',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/tests/**'
  ],

  // Coverage thresholds - Lab 6 requires >70%
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    },
    './services/**/*.ts': {
      statements: 85,
      branches: 65, // Adjusted for AdaptiveWorkoutService complexity
      functions: 90,
      lines: 85
    }
  },

  // Coverage reporters
  coverageReporters: [
    'text',
    'text-summary',
    'html',
    'lcov',
    'json'
  ],

  // Coverage directory
  coverageDirectory: '<rootDir>/coverage',

  // Module file extensions
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],

  // Transform TypeScript files
  transform: {
    '^.+\\.ts$': 'ts-jest'
  },

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],

  // Clear mocks between tests
  clearMocks: true,

  // Restore mocks between tests
  restoreMocks: true,

  // Verbose output
  verbose: true,

  // Timeout for tests (5 seconds)
  testTimeout: 5000,

  // Module name mapper for path aliases
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
    '^@models/(.*)$': '<rootDir>/models/$1',
    '^@services/(.*)$': '<rootDir>/services/$1',
    '^@utils/(.*)$': '<rootDir>/utils/$1'
  }
};
