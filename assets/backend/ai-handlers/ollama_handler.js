// assets/backend/ai-handlers/ollama_handler.js

const axios = require('axios');
const BaseAIHandler = require('./base_handler');

/**
 * Handler per i modelli locali Ollama
 */
class OllamaHandler extends BaseAIHandler {
  constructor() {
    super('Ollama');
    this.baseUrl = 'http://localhost:11434'; // Default locale
    this.model = 'llama2'; // Modello predefinito
  }

  /**
   * Inizializza l'handler con l'endpoint
   * @param {String} endpoint - Endpoint Ollama (opzionale)
   */
  initialize(endpoint) {
    // Se l'endpoint è fornito e non è vuoto, usalo per sovrascrivere quello predefinito
    if (endpoint && endpoint.trim() !== '') {
      // Verifica se l'endpoint inizia con http:// o https://
      if (!endpoint.startsWith('http://') && !endpoint.startsWith('https://')) {
        this.baseUrl = `http://${endpoint}`;
      } else {
        this.baseUrl = endpoint;
      }
    }

    this.isAvailable = true;
    this.apiKey = 'local'; // Non serve una chiave API
    return true;
  }

  /**
   * Elabora una prompt e restituisce una risposta
   * @param {String} prompt - Prompt da elaborare
   * @param {String} conversationId - ID della conversazione
   * @returns {Promise<String>} - Risposta elaborata
   */
  async process(prompt, conversationId) {
    if (!this.checkAvailability()) {
      return 'Ollama non configurato o non disponibile';
    }

    try {
      const response = await axios.post(
        `${this.baseUrl}/api/generate`,
        {
          model: this.model,
          prompt: prompt,
          stream: false,
          options: {
            temperature: 0.7,
            num_predict: 1000,
          }
        },
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      return response.data.response.trim();
    } catch (error) {
      return this.handleError(error);
    }
  }

  /**
   * Ottiene la lista dei modelli disponibili
   * @returns {Promise<Array<String>>} - Lista dei modelli
   */
  async getAvailableModels() {
    try {
      const response = await axios.get(
        `${this.baseUrl}/api/tags`,
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      return response.data.models.map(model => model.name);
    } catch (error) {
      console.error('Errore nel recupero dei modelli Ollama:', error);
      return [];
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

module.exports = new OllamaHandler();