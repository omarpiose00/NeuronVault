// assets/backend/ai-handlers/claude_handler.js

const axios = require('axios');
const BaseAIHandler = require('./base_handler');

/**
 * Handler per i modelli Anthropic Claude
 */
class ClaudeHandler extends BaseAIHandler {
  constructor() {
    super('Claude');
    this.apiUrl = 'https://api.anthropic.com/v1/messages';
    this.model = 'claude-3-opus-20240229'; // Modello predefinito
  }

  /**
   * Elabora una prompt e restituisce una risposta
   * @param {String} prompt - Prompt da elaborare
   * @param {String} conversationId - ID della conversazione
   * @returns {Promise<String>} - Risposta elaborata
   */
  async process(prompt, conversationId) {
    if (!this.checkAvailability()) {
      return 'API Anthropic non configurata';
    }

    try {
      const response = await axios.post(
        this.apiUrl,
        {
          model: this.model,
          max_tokens: 1000,
          messages: [{ role: 'user', content: prompt }],
        },
        {
          headers: {
            'x-api-key': this.apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        }
      );

      return response.data.content[0].text.trim();
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * Imposta il modello da utilizzare
   * @param {String} model - Nome del modello
   */
  setModel(model) {
    this.model = model;
  }
}

module.exports = new ClaudeHandler();