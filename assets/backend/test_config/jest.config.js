// assets/backend/test_config/jest.config.js

/**
 * NeuronVault Enterprise Jest Configuration
 * Enterprise-grade testing configuration for AI orchestration backend
 */

module.exports = {
  // Test environment configuration
  testEnvironment: 'node',

  // Root directory for tests
  roots: ['<rootDir>/tests'],

  // Test file patterns
  testMatch: [
    '**/tests/**/*.test.js',
    '**/tests/**/*.spec.js'
  ],

  // Coverage configuration for enterprise reporting
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: [
    'text',
    'text-summary',
    'html',
    'lcov',
    'json'
  ],

  // Coverage thresholds for enterprise quality
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    // Specific thresholds for critical AI handlers
    './ai-handlers/': {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    },
    './streaming/': {
      branches: 85,
      functions: 85,
      lines: 85,
      statements: 85
    }
  },

  // Files to collect coverage from
  collectCoverageFrom: [
    'ai-handlers/**/*.js',
    'streaming/**/*.js',
    'routes/**/*.js',
    'index.js',
    '!**/node_modules/**',
    '!**/tests/**',
    '!**/coverage/**'
  ],

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/utils/test_setup.js'],

  // Module directories
  moduleDirectories: ['node_modules', '<rootDir>'],

  // Transform configuration (if using ES modules in future)
  transform: {},

  // Timeout for tests (AI operations can be slow)
  testTimeout: 30000,

  // Verbose output for debugging
  verbose: true,

  // Clear mocks between tests
  clearMocks: true,
  restoreMocks: true,

  // Error reporting
  errorOnDeprecated: true,

  // Performance monitoring
  detectLeaks: true,
  detectOpenHandles: true,

  // Parallel execution configuration
  maxWorkers: '50%',

  // Global variables for neural luxury testing
  globals: {
    NEURONVAULT_TEST_MODE: true,
    NEURAL_LUXURY_THEME: 'cosmos',
    AI_ORCHESTRATION_TIMEOUT: 10000,
    WEBSOCKET_TEST_PORT: 3001,
    TEST_AI_MODELS: [
      'claude',
      'gpt',
      'deepseek',
      'gemini',
      'mistral',
      'llama',
      'ollama'
    ]
  },

  // Module name mapping for easier imports
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/$1',
    '^@tests/(.*)$': '<rootDir>/tests/$1',
    '^@handlers/(.*)$': '<rootDir>/ai-handlers/$1',
    '^@streaming/(.*)$': '<rootDir>/streaming/$1'
  }
};