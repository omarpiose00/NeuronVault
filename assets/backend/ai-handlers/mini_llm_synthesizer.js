// assets/backend/ai-handlers/mini_llm_synthesizer.js

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

/**
 * Classe per la sintesi delle risposte tramite mini-LLM
 */
class MiniLLMSynthesizer {
  constructor() {
    // Configurazione predefinita
    this.modelPath = '';        // Percorso del modello Mini-LLM (es. Phi-2, Mistral-7B)
    this.executablePath = '';   // Percorso dell'eseguibile per il modello
    this.isInitialized = false;

    // Pesi predefiniti per ciascun modello
    this.defaultWeights = {
      'gpt': 1.0,
      'claude': 1.0,
      'deepseek': 1.0,
      'mistral': 1.0,
      'gemini': 1.0,
      'ollama': 1.0,
      'llama': 1.0,
    };

    // Pesi correnti
    this.currentWeights = { ...this.defaultWeights };

    // Template per la sintesi
    this.synthesisTemplate = `
Hai il compito di sintetizzare le risposte di diversi modelli AI in un'unica risposta coerente.
Ecco le risposte fornite dai modelli AI alla domanda:

{prompt}

Risposte:
{responses}

I modelli hanno i seguenti pesi di affidabilità (maggiore è il peso, più affidabile è il modello):
{weights}

Crea una risposta sintetizzata che:
1. Integri le informazioni più accurate e pertinenti di ogni risposta
2. Consideri maggiormente i modelli con peso più alto
3. Risolva eventuali contraddizioni scegliendo l'informazione più attendibile
4. Sia fluida, coerente e ben strutturata
5. Non menzioni esplicitamente i modelli di origine nella risposta finale

Risposta sintetizzata:`;
  }

  /**
   * Inizializza il sintetizzatore con un modello mini-LLM
   * @param {Object} config - Configurazione
   * @returns {Boolean} - true se l'inizializzazione è avvenuta con successo
   */
  initialize(config) {
    if (!config) return false;

    if (config.modelPath && fs.existsSync(config.modelPath)) {
      this.modelPath = config.modelPath;
    } else {
      console.error('Percorso del modello Mini-LLM non valido');
      return false;
    }

    if (config.executablePath && fs.existsSync(config.executablePath)) {
      this.executablePath = config.executablePath;
    } else {
      console.error('Percorso dell\'eseguibile Mini-LLM non valido');
      return false;
    }

    this.isInitialized = true;
    return true;
  }

  /**
   * Sintetizza le risposte usando il mini-LLM
   * @param {Object} responses - Risposte dei vari modelli
   * @param {Object} modelConfig - Configurazione dei modelli
   * @param {Object} customWeights - Pesi personalizzati (opzionale)
   * @returns {Promise<String>} - Risposta sintetizzata
   */
  async synthesize(responses, modelConfig, prompt, customWeights = null) {
    // Se non è inizializzato, usa un approccio più semplice
    if (!this.isInitialized || Object.keys(responses).length === 0) {
      return this.simpleSynthesize(responses, customWeights);
    }

    // Usa i pesi personalizzati se forniti
    const weights = customWeights || this.currentWeights;

    // Prepara il prompt per il mini-LLM
    const responsesText = Object.entries(responses)
      .map(([model, response]) => `${model.toUpperCase()}: ${response}`)
      .join('\n\n');

    const weightsText = Object.entries(weights)
      .filter(([model, _]) => responses[model])
      .map(([model, weight]) => `${model.toUpperCase()}: ${weight.toFixed(2)}`)
      .join('\n');

    const miniLLMPrompt = this.synthesisTemplate
      .replace('{prompt}', prompt)
      .replace('{responses}', responsesText)
      .replace('{weights}', weightsText);

    try {
      // Elabora con il mini-LLM
      const synthesizedResponse = await this.runMiniLLM(miniLLMPrompt);
      return synthesizedResponse.trim();
    } catch (error) {
      console.error('Errore nella sintesi con Mini-LLM:', error);
      // Fallback alla sintesi semplice in caso di errore
      return this.simpleSynthesize(responses, customWeights);
    }
  }

  /**
   * Esegue il mini-LLM con il prompt fornito
   * @param {String} prompt - Prompt per il mini-LLM
   * @returns {Promise<String>} - Risposta del mini-LLM
   */
  async runMiniLLM(prompt) {
    return new Promise((resolve, reject) => {
      // Argomenti per l'esecuzione del mini-LLM
      const args = [
        '-m', this.modelPath,
        '-p', prompt,
        '--temp', '0.3', // Bassa temperatura per risultati più deterministici
        '--top_p', '0.95',
        '--ctx_size', '4096', // Contesto ampio per gestire prompt lunghi
      ];

      // Esegui il mini-LLM
      const llmProcess = spawn(this.executablePath, args);

      let output = '';
      let errorOutput = '';

      llmProcess.stdout.on('data', (data) => {
        output += data.toString();
      });

      llmProcess.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });

      llmProcess.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(`Mini-LLM terminato con codice ${code}: ${errorOutput}`));
          return;
        }

        // Estrai solo la risposta (rimuovi il prompt)
        const response = output.substring(prompt.length).trim();
        resolve(response);
      });
    });
  }

  /**
   * Sintetizzatore semplice (fallback)
   * @param {Object} responses - Risposte dei vari modelli
   * @param {Object} customWeights - Pesi personalizzati
   * @returns {String} - Risposta sintetizzata
   */
  simpleSynthesize(responses, customWeights = null) {
    const weights = customWeights || this.currentWeights;
    const activeModels = Object.keys(responses);

    if (activeModels.length === 0) {
      return "Nessuna risposta disponibile.";
    }

    if (activeModels.length === 1) {
      return responses[activeModels[0]];
    }

    // Ordina i modelli per peso
    const sortedModels = activeModels.sort((a, b) => {
      const weightA = weights[a] || 1.0;
      const weightB = weights[b] || 1.0;
      return weightB - weightA; // Ordine decrescente
    });

    // Usa la risposta del modello con peso più alto come risposta primaria
    return responses[sortedModels[0]];
  }

  /**
   * Aggiorna i pesi in base al feedback
   * @param {String} preferredModel - Modello preferito
   * @param {Number} rating - Valutazione (1-5)
   */
  updateWeights(preferredModel, rating) {
    if (!this.currentWeights[preferredModel]) return;

    // Normalizza il rating tra 0.1 e 0.3
    const adjustment = (rating / 5) * 0.2 + 0.1;

    // Aumenta il peso del modello preferito
    this.currentWeights[preferredModel] += adjustment;

    // Normalizza i pesi
    this._normalizeWeights();
  }

  /**
   * Normalizza i pesi
   */
  _normalizeWeights() {
    const maxWeight = Math.max(...Object.values(this.currentWeights));

    if (maxWeight > 2.0) {
      const factor = 2.0 / maxWeight;
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
  }

  /**
   * Ottiene i pesi correnti
   * @returns {Object} - Pesi correnti
   */
  getWeights() {
    return { ...this.currentWeights };
  }
}

module.exports = new MiniLLMSynthesizer();