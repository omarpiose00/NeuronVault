// test/backend/synthesizer.test.js

const synthesizer = require('../../assets/backend/ai-handlers/synthesizer');

describe('AI Synthesizer Tests', () => {
  beforeEach(() => {
    synthesizer.resetWeights();
  });

  describe('Basic Synthesis', () => {
    test('should return single response when only one model responds', async () => {
      const responses = {
        'gpt': 'This is a GPT response'
      };
      const modelConfig = { gpt: true };

      const result = await synthesizer.synthesize(responses, modelConfig);

      expect(result).toBe('This is a GPT response');
    });

    test('should synthesize multiple responses', async () => {
      const responses = {
        'gpt': 'GPT thinks this is correct.',
        'claude': 'Claude agrees with the analysis.',
        'deepseek': 'DeepSeek provides additional context.'
      };
      const modelConfig = { gpt: true, claude: true, deepseek: true };

      const result = await synthesizer.synthesize(responses, modelConfig);

      expect(result).toContain('GPT thinks this is correct');
      expect(typeof result).toBe('string');
      expect(result.length).toBeGreaterThan(0);
    });
  });

  describe('Weight Management', () => {
    test('should update model weights', () => {
      const initialWeight = synthesizer.getWeights()['gpt'];

      synthesizer.updateWeights('gpt', 4);

      const updatedWeight = synthesizer.getWeights()['gpt'];
      expect(updatedWeight).toBeGreaterThan(initialWeight);
    });

    test('should normalize weights when they get too high', () => {
      // Boost one model significantly
      for (let i = 0; i < 10; i++) {
        synthesizer.updateWeights('gpt', 5);
      }

      const weights = synthesizer.getWeights();
      const maxWeight = Math.max(...Object.values(weights));

      expect(maxWeight).toBeLessThanOrEqual(3.0);
    });

    test('should reset weights to default', () => {
      synthesizer.updateWeights('gpt', 5);
      synthesizer.resetWeights();

      const weights = synthesizer.getWeights();
      expect(weights['gpt']).toBe(1.0);
      expect(weights['claude']).toBe(1.0);
    });
  });

  describe('Custom Weights', () => {
    test('should use custom weights when provided', async () => {
      const responses = {
        'gpt': 'GPT response',
        'claude': 'Claude response'
      };
      const modelConfig = { gpt: true, claude: true };
      const customWeights = { gpt: 2.0, claude: 0.5 };

      const result = await synthesizer.synthesize(responses, modelConfig, customWeights);

      // Should prioritize GPT due to higher weight
      expect(result).toContain('GPT response');
    });
  });
});