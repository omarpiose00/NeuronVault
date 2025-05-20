// assets/backend/ai-handlers/base_handler.js

/**
 * Classe base per tutti gli handler AI
 */
class BaseAIHandler {
  constructor(name) {
    this.name = name;
    this.isAvailable = false;
    this.apiKey = null;
  }

  /**
   * Inizializza l'handler con la chiave API
   * @param {String} apiKey - Chiave API
   */
  initialize(apiKey) {
    this.apiKey = apiKey;
    this.isAvailable = !!apiKey;
    return this.isAvailable;
  }

  /**
   * Verifica se l'handler è disponibile
   * @returns {Boolean} - true se disponibile, false altrimenti
   */
  checkAvailability() {
    return this.isAvailable;
  }

  /**
   * Elabora una prompt e restituisce una risposta
   * @param {String} prompt - Prompt da elaborare
   * @param {String} conversationId - ID della conversazione
   * @returns {Promise<String>} - Risposta elaborata
   */
  async process(prompt, conversationId) {
    throw new Error('Il metodo process deve essere implementato dalle sottoclassi');
  }

  /**
   * Gestisce un errore
   * @param {Error} error - Errore da gestire
   * @returns {String} - Messaggio di errore formattato
   */
  handleError(error) {
    const errorMessage = error.message || 'Errore sconosciuto';
    console.error(`[${this.name}] Errore: ${errorMessage}`);
    return `Il modello ${this.name} ha riscontrato un errore: ${errorMessage}`;
  }
}

module.exports = BaseAIHandler;