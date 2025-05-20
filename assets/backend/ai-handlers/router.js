// assets/backend/ai-handlers/router.js (ulteriore aggiornamento)

const gptHandler = require('./gpt_handler');
const claudeHandler = require('./claude_handler');
const deepseekHandler = require('./deepseek_handler');
const mistralHandler = require('./mistral_handler');
const geminiHandler = require('./gemini_handler');
const ollamaHandler = require('./ollama_handler');
const llamaHandler = require('./llama_handler');
// const synthesizer = require('./synthesizer'); // Commentiamo il vecchio synthesizer
const synthesizer = require('./mini_llm_synthesizer');

/**
 * Router per le richieste AI
 */
class AIRouter {
  constructor() {
    // Mappa degli handler disponibili
    this.handlers = {
      'gpt': gptHandler,
      'claude': claudeHandler,
      'deepseek': deepseekHandler,
      'mistral': mistralHandler,
      'gemini': geminiHandler,
      'ollama': ollamaHandler,
      'llama': llamaHandler,   // Aggiungiamo il nuovo handler
      // Altri handler potranno essere aggiunti in seguito
    };

    // Flag per auto-adattamento dei pesi
    this.autoAdjustWeights = true;
  }

  /**
   * Inizializza gli handler con le chiavi API
   * @param {Object} apiKeys - Chiavi API per ciascun provider
   */
  initialize(apiKeys) {
    for (const [provider, apiKey] of Object.entries(apiKeys)) {
      // Mappa i nomi dei provider ai nomi degli handler
      const handlerMap = {
        'openai': 'gpt',
        'anthropic': 'claude',
        'deepseek': 'deepseek',
        'google': 'gemini',
        'mistral': 'mistral',
        'ollama': 'ollama'
      };

      const handlerName = handlerMap[provider] || provider;

      if (this.handlers[handlerName]) {
        this.handlers[handlerName].initialize(apiKey);
      }
    }
  }

    // Flag per auto-adattamento dei pesi
    this.autoAdjustWeights = true;
  }

  /**
   * Inizializza gli handler con le chiavi API
   * @param {Object} apiKeys - Chiavi API per ciascun provider
   */
  initialize(apiKeys) {
    for (const [provider, apiKey] of Object.entries(apiKeys)) {
      if (this.handlers[provider]) {
        this.handlers[provider].initialize(apiKey);
      }
    }
  }

  /**
   * Elabora una richiesta e routing ai vari handler
   * @param {Object} request - Richiesta da elaborare
   * @returns {Promise<Object>} - Risposta elaborata
   */
  async processRequest(request) {
    const { prompt, conversationId, modelConfig, customWeights } = request;

    try {
      // Determina quali handler utilizzare in base alla configurazione
      const activeHandlers = this._getActiveHandlers(modelConfig);

      if (activeHandlers.length === 0) {
        return {
          error: 'Nessun modello AI abilitato',
          conversation: []
        };
      }

      // Elabora la richiesta con tutti gli handler attivi in parallelo
      const responses = {};
      const promises = activeHandlers.map(async (handlerName) => {
        const handler = this.handlers[handlerName];
        try {
          const response = await handler.process(prompt, conversationId);
          responses[handlerName] = response;
        } catch (error) {
          console.error(`Errore nell'handler ${handlerName}:`, error);
          responses[handlerName] = `Errore in ${handlerName}: ${error.message}`;
        }
      });

      // Attendi che tutte le richieste siano completate
      await Promise.all(promises);

      // Sintetizza le risposte
      const synthesizedResponse = await synthesizer.synthesize(
        responses,
        modelConfig,
        customWeights
      );

      // Costruisci la conversazione
      const conversation = [
        { agent: 'user', message: prompt, timestamp: new Date().toISOString() },
      ];

      // Aggiungi le risposte dei singoli modelli (opzionale, può essere configurato)
      const includeIndividualResponses = false;
      if (includeIndividualResponses) {
        for (const [handlerName, response] of Object.entries(responses)) {
          conversation.push({
            agent: handlerName,
            message: response,
            timestamp: new Date().toISOString(),
          });
        }
      }

      // Aggiungi la risposta sintetizzata
      conversation.push({
        agent: 'system',
        message: synthesizedResponse,
        timestamp: new Date().toISOString(),
      });

      return {
        conversation,
        responses, // Include le singole risposte per debugging
      };
    } catch (error) {
      console.error('Errore nel router AI:', error);
      return {
        error: `Errore nell'elaborazione della richiesta: ${error.message}`,
        conversation: []
      };
    }
  }

  /**
   * Ottiene gli handler attivi in base alla configurazione
   * @param {Object} modelConfig - Configurazione dei modelli
   * @returns {Array<String>} - Nomi degli handler attivi
   */
  _getActiveHandlers(modelConfig) {
    if (!modelConfig) return [];

    return Object.entries(modelConfig)
      .filter(([_, enabled]) => enabled)
      .map(([model, _]) => model)
      .filter(model => this.handlers[model] && this.handlers[model].checkAvailability());
  }

  /**
   * Imposta se auto-adattare i pesi
   * @param {Boolean} enabled - true per abilitare, false per disabilitare
   */
  setAutoAdjustWeights(enabled) {
    this.autoAdjustWeights = enabled;
  }

  /**
   * Aggiorna i pesi in base al feedback dell'utente
   * @param {String} preferredModel - Modello preferito dall'utente
   * @param {Number} rating - Valutazione da 1 a 5
   */
  updateWeights(preferredModel, rating) {
    if (this.autoAdjustWeights) {
      synthesizer.updateWeights(preferredModel, rating);
    }
  }

  /**
   * Resetta i pesi ai valori predefiniti
   */
  resetWeights() {
    synthesizer.resetWeights();
  }

  /**
   * Ottiene i pesi correnti
   * @returns {Object} - Pesi correnti
   */
  getWeights() {
    return synthesizer.getWeights();
  }
}

module.exports = new AIRouter();