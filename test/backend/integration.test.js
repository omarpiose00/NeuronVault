// test/backend/integration.test.js

const request = require('supertest');
const app = require('../../assets/backend/index');

describe('Integration Tests', () => {
  describe('Multi-Agent Endpoint', () => {
    test('should handle basic chat request', async () => {
      const response = await request(app)
        .post('/multi-agent')
        .send({
          prompt: 'Hello, how are you?',
          conversationId: 'test-integration-1',
          modelConfig: { gpt: true }
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('conversation');
      expect(response.body.conversation).toBeInstanceOf(Array);
    });

    test('should return error for empty prompt', async () => {
      const response = await request(app)
        .post('/multi-agent')
        .send({
          prompt: '',
          conversationId: 'test-integration-2',
          modelConfig: { gpt: true }
        });

      expect(response.status).toBe(400);
      expect(response.body).toHaveProperty('error');
    });

    test('should handle multiple models', async () => {
      const response = await request(app)
        .post('/multi-agent')
        .send({
          prompt: 'What is artificial intelligence?',
          conversationId: 'test-integration-3',
          modelConfig: { gpt: true, claude: true, deepseek: true }
        });

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('responses');

      // Should have responses from multiple models
      const responseKeys = Object.keys(response.body.responses || {});
      expect(responseKeys.length).toBeGreaterThanOrEqual(1);
    });
  });

  describe('Conversation Management', () => {
    const testConvId = 'test-conversation-mgmt';

    test('should retrieve conversation', async () => {
      // First, create a conversation
      await request(app)
        .post('/multi-agent')
        .send({
          prompt: 'Initial message',
          conversationId: testConvId,
          modelConfig: { gpt: true }
        });

      // Then retrieve it
      const response = await request(app)
        .get(`/multi-agent/conversation/${testConvId}`);

      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('conversation');
      expect(response.body.conversation.length).toBeGreaterThan(0);
    });

    test('should delete conversation', async () => {
      const deleteResponse = await request(app)
        .delete(`/multi-agent/conversation/${testConvId}`);

      expect(deleteResponse.status).toBe(200);
      expect(deleteResponse.body).toHaveProperty('success', true);

      // Verify it's deleted
      const getResponse = await request(app)
        .get(`/multi-agent/conversation/${testConvId}`);

      expect(getResponse.status).toBe(404);
    });
  });
});

module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/test/setup.js'],
  testMatch: ['**/test/**/*.test.js'],
  collectCoverageFrom: [
    'assets/backend/**/*.js',
    '!assets/backend/node_modules/**',
    '!assets/backend/package*.json'
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html']
};