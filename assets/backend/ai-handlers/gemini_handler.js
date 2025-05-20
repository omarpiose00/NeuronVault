// assets/backend/ai-handlers/gemini_handler.js

const axios = require('axios');
const BaseAIHandler = require('./base_handler');

/**
 * Handler per i modelli Google Gemini
 */
class GeminiHandler extends BaseAIHandler {
  constructor() {
    super('Gemini');
    this.model = 'gemini-1.5-pro'; // Modello predefinito
  }

  /**
   * Elabora una prompt e restituisce una risposta
   * @param {String} prompt - Prompt da elaborare
   * @param {String} conversationId - ID della conversazione
   * @returns {Promise<String>} - Risposta elaborata
   */
  async process(prompt, conversationId) {
    if (!this.checkAvailability()) {
      return 'API Google Gemini non configurata';
    }

    try {
      // L'API Gemini ha un formato leggermente diverso
      const apiUrl = `https://generativelanguage.googleapis.com/v1/models/${this.model}:generateContent?key=${this.apiKey}`;

      const response = await axios.post(
        apiUrl,
        {
          contents: [{
            role: 'user',
            parts: [{text: prompt}]
          }],
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1000,
          }
        },
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      // Estrai il testo dalla risposta
      const content = response.data.candidates[0].content;
      const text = content.parts[0].text;

      return text.trim();
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

module.exports = new GeminiHandler();