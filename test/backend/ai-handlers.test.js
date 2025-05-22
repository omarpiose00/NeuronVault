// test/backend/ai-handlers.test.js

const request = require('supertest');
const express = require('express');
const router = require('../../assets/backend/ai-handlers/router');

// Mock per gli handler AI
jest.mock('../../assets/backend/ai-handlers/gpt_handler');
jest.mock('../../assets/backend/ai-handlers/claude_handler');
jest.mock('../../assets/backend/ai-handlers/deepseek_handler');

describe('AI Router Tests', () => {
  let app;

  beforeAll(() => {
    app = express();
    app.use(express.json());

    // Inizializza il router con chiavi API mock
    router.initialize({
      'openai': 'mock-openai-key',
      'anthropic': 'mock-anthropic-key',
      'deepseek': 'mock-deepseek-key'
    });
  });

  describe('Router Initialization', () => {
    test('should initialize with API keys', () => {
      expect(router.handlers.gpt.isAvailable).toBe(true);
      expect(router.handlers.claude.isAvailable).toBe(true);
      expect(router.handlers.deepseek.isAvailable).toBe(true);
    });

    test('should handle missing API keys gracefully', () => {
      const testRouter = require('../../assets/backend/ai-handlers/router');
      testRouter.initialize({});

      expect(testRouter.handlers.gpt.isAvailable).toBe(false);
    });
  });

  describe('Request Processing', () => {
    test('should process valid request', async () => {
      const mockRequest = {
        prompt: 'Test prompt',
        conversationId: 'test-conv-1',
        modelConfig: { gpt: true, claude: true }
      };

      const result = await router.processRequest(mockRequest);

      expect(result).toHaveProperty('conversation');
      expect(result).toHaveProperty('responses');
      expect(result.conversation).toBeInstanceOf(Array);
    });

    test('should handle empty model config', async () => {
      const mockRequest = {
        prompt: 'Test prompt',
        conversationId: 'test-conv-2',
        modelConfig: {}
      };

      const result = await router.processRequest(mockRequest);

      expect(result).toHaveProperty('error');
      expect(result.error).toContain('Nessun modello AI abilitato');
    });

    test('should synthesize multiple responses', async () => {
      const mockRequest = {
        prompt: 'Test synthesis',
        conversationId: 'test-conv-3',
        modelConfig: { gpt: true, claude: true, deepseek: true }
      };

      const result = await router.processRequest(mockRequest);

      expect(result.conversation.length).toBeGreaterThan(1);
      expect(result.responses).toHaveProperty('gpt');
      expect(result.responses).toHaveProperty('claude');
    });
  });

  describe('Error Handling', () => {
    test('should handle API timeout', async () => {
      // Mock timeout scenario
      jest.setTimeout(10000);

      const mockRequest = {
        prompt: 'Test timeout',
        conversationId: 'test-timeout',
        modelConfig: { gpt: true }
      };

      const result = await router.processRequest(mockRequest);

      expect(result).toBeDefined();
    });

    test('should handle malformed request', async () => {
      const mockRequest = {
        // Missing required fields
        conversationId: 'test-malformed'
      };

      const result = await router.processRequest(mockRequest);

      expect(result).toHaveProperty('error');
    });
  });
});