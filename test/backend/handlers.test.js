// test/backend/handlers.test.js

const BaseAIHandler = require('../../assets/backend/ai-handlers/base_handler');
const GPTHandler = require('../../assets/backend/ai-handlers/gpt_handler');
const ClaudeHandler = require('../../assets/backend/ai-handlers/claude_handler');

describe('AI Handlers Tests', () => {
  describe('BaseAIHandler', () => {
    test('should initialize with name', () => {
      const handler = new BaseAIHandler('TestHandler');
      expect(handler.name).toBe('TestHandler');
      expect(handler.isAvailable).toBe(false);
    });

    test('should become available when API key is set', () => {
      const handler = new BaseAIHandler('TestHandler');
      const result = handler.initialize('test-api-key');

      expect(result).toBe(true);
      expect(handler.isAvailable).toBe(true);
      expect(handler.apiKey).toBe('test-api-key');
    });

    test('should throw error when process method is not implemented', async () => {
      const handler = new BaseAIHandler('TestHandler');
      handler.initialize('test-key');

      await expect(handler.process('test prompt', 'test-conv'))
        .rejects.toThrow('Il metodo process deve essere implementato dalle sottoclassi');
    });

    test('should handle errors properly', () => {
      const handler = new BaseAIHandler('TestHandler');
      const error = new Error('Test error');

      const result = handler.handleError(error);

      expect(result).toContain('TestHandler');
      expect(result).toContain('Test error');
    });
  });

  describe('GPTHandler', () => {
    test('should have correct default configuration', () => {
      expect(GPTHandler.name).toBe('GPT');
      expect(GPTHandler.apiUrl).toBe('https://api.openai.com/v1/chat/completions');
      expect(GPTHandler.model).toBe('gpt-4o');
    });

    test('should set custom model', () => {
      GPTHandler.setModel('gpt-3.5-turbo');
      expect(GPTHandler.model).toBe('gpt-3.5-turbo');

      // Reset to default
      GPTHandler.setModel('gpt-4o');
    });
  });

  describe('ClaudeHandler', () => {
    test('should have correct default configuration', () => {
      expect(ClaudeHandler.name).toBe('Claude');
      expect(ClaudeHandler.apiUrl).toBe('https://api.anthropic.com/v1/messages');
      expect(ClaudeHandler.model).toBe('claude-3-opus-20240229');
    });

    test('should set custom model', () => {
      ClaudeHandler.setModel('claude-3-sonnet-20240229');
      expect(ClaudeHandler.model).toBe('claude-3-sonnet-20240229');

      // Reset to default
      ClaudeHandler.setModel('claude-3-opus-20240229');
    });
  });
});