// assets/backend/ai-handlers/mistral_handler.js

const axios = require('axios');
const BaseAIHandler = require('./base_handler');

/**
 * Handler per i modelli Mistral AI
 */
class MistralHandler extends BaseAIHandler {
  constructor() {
    super('Mistral');
    this.apiUrl = 'https://api.mistral.ai/v1/chat/completions';
    this.model = 'mistral-large-latest'; // Modello predefinito
  }

  /**
   * Elabora una prompt e restituisce una risposta
   * @param {String} prompt - Prompt da elaborare
   * @param {String} conversationId - ID della conversazione
   * @returns {Promise<String>} - Risposta elaborata
   */
  async process(prompt, conversationId) {
    if (!this.checkAvailability()) {
      return 'API Mistral non configurata';
    }

    try {
      const response = await axios.post(
        this.apiUrl,
        {
          model: this.model,
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 1000,
          temperature: 0.7,
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json',
          },
        }
      );

      return response.data.choices[0].message.content.trim();
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

module.exports = new MistralHandler();