// assets/backend/ai-handlers/synthesizer.js

/**
 * Classe per la sintesi delle risposte da diversi modelli AI
 */
class AISynthesizer {
  constructor() {
    // Pesi predefiniti per ciascun modello
    this.defaultWeights = {
      'gpt': 1.0,        // OpenAI
      'claude': 1.0,     // Anthropic
      'deepseek': 1.0,   // DeepSeek
      'gemini': 1.0,     // Google
      'mistral': 1.0,    // Mistral
      'cohere': 1.0,     // Cohere
      'llama': 1.0,      // Meta (locale)
      'ollama': 1.0,     // Ollama (locale)
    };

    // Pesi correnti (possono essere modificati in base alle performance)
    this.currentWeights = { ...this.defaultWeights };

    // Storico delle valutazioni per auto-adattamento
    this.performanceHistory = {};
  }

  /**
   * Combina le risposte di vari modelli AI in un'unica risposta sintetizzata
   * @param {Object} responses - Oggetto con le risposte dei vari modelli
   * @param {Object} modelConfig - Configurazione dei modelli (abilitati/disabilitati)
   * @param {Object} customWeights - Pesi personalizzati per ciascun modello (opzionale)
   * @returns {String} - Risposta sintetizzata
   */
  async synthesize(responses, modelConfig, customWeights = null) {
    // Usa pesi personalizzati se forniti
    const weights = customWeights || this.currentWeights;

    // Se c'è solo una risposta, restituiscila direttamente
    const activeModels = Object.keys(responses);
    if (activeModels.length === 1) {
      return responses[activeModels[0]];
    }

    // Se ci sono più risposte, sintetizzale
    // In questa prima implementazione, usiamo un approccio semplice
    // In futuro, possiamo usare un modello locale per la sintesi

    // Estrai le risposte e i loro pesi
    const weightedResponses = activeModels.map(model => ({
      model,
      response: responses[model],
      weight: weights[model] || 1.0
    }));

    // Ordina le risposte per peso (dalla più alta alla più bassa)
    weightedResponses.sort((a, b) => b.weight - a.weight);

    // Costruisci una risposta sintetizzata
    // Per ora, prendiamo la risposta con il peso maggiore come base,
    // e integriamo elementi dalle altre risposte

    const primaryResponse = weightedResponses[0].response;

    // Se ci sono solo 1-2 risposte, restituiamo la principale
    if (weightedResponses.length <= 2) {
      return primaryResponse;
    }

    // Altrimenti, costruiamo una sintesi
    let synthesis = `Analizzando le risposte da diversi modelli AI:\n\n`;

    // Aggiungi punti chiave da ciascun modello
    weightedResponses.forEach(({ model, response }) => {
      // Estrai una versione sintetica della risposta
      const summary = this._extractSummary(response);
      synthesis += `${this._getModelDisplayName(model)} suggerisce: ${summary}\n\n`;
    });

    // Aggiungi una conclusione
    synthesis += `Sintesi: ${primaryResponse}`;

    return synthesis;
  }

  /**
   * Estrae un sommario da una risposta
   * @param {String} response - Risposta completa
   * @returns {String} - Sommario
   */
  _extractSummary(response) {
    // Semplice implementazione: prendi le prime 2 frasi
    const sentences = response.split(/[.!?]/).filter(s => s.trim().length > 0);
    return sentences.slice(0, 2).join('. ') + '.';
  }

  /**
   * Ottiene il nome visualizzato per un modello
   * @param {String} modelKey - Chiave del modello
   * @returns {String} - Nome visualizzato
   */
  _getModelDisplayName(modelKey) {
    const displayNames = {
      'gpt': 'GPT',
      'claude': 'Claude',
      'deepseek': 'DeepSeek',
      'gemini': 'Gemini',
      'mistral': 'Mistral',
      'cohere': 'Cohere',
      'llama': 'Llama',
      'ollama': 'Ollama'
    };

    return displayNames[modelKey] || modelKey;
  }

  /**
   * Aggiorna i pesi in base al feedback dell'utente
   * @param {String} preferredModel - Modello preferito dall'utente
   * @param {Number} rating - Valutazione da 1 a 5
   */
  updateWeights(preferredModel, rating) {
    // Incrementa il peso del modello preferito
    if (this.currentWeights[preferredModel]) {
      // Normalizza il rating tra 0.1 e 0.5
      const adjustment = (rating / 5) * 0.4 + 0.1;
      this.currentWeights[preferredModel] += adjustment;

      // Aggiorna la storia delle performance
      if (!this.performanceHistory[preferredModel]) {
        this.performanceHistory[preferredModel] = [];
      }
      this.performanceHistory[preferredModel].push(rating);

      // Normalizza i pesi per evitare valori troppo alti
      this._normalizeWeights();
    }
  }

  /**
   * Normalizza i pesi per mantenerli in un range ragionevole
   */
  _normalizeWeights() {
    // Trova il peso massimo
    const maxWeight = Math.max(...Object.values(this.currentWeights));

    // Se il peso massimo è troppo alto, normalizza tutti i pesi
    if (maxWeight > 3.0) {
      const factor = 3.0 / maxWeight;
      for (const model in this.currentWeights) {
        this.currentWeights[model] *= factor;
      }
    }
  }

  /**
   * Resetta i pesi ai valori predefiniti
   */
  resetWeights() {
    this.currentWeights = { ...this.defaultWeights };
    this.performanceHistory = {};
  }

  /**
   * Ottiene i pesi correnti
   * @returns {Object} - Pesi correnti
   */
  getWeights() {
    return { ...this.currentWeights };
  }
}

module.exports = new AISynthesizer();