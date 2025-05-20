// assets/backend/ai-handlers/llama_handler.js

const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const BaseAIHandler = require('./base_handler');

/**
 * Handler per i modelli llama.cpp locali
 */
class LlamaHandler extends BaseAIHandler {
  constructor() {
    super('Llama');
    this.executablePath = ''; // Percorso dell'eseguibile llama.cpp
    this.modelPath = '';      // Percorso del modello
    this.modelConfig = {
      contextSize: 2048,      // Dimensione del contesto
      threads: 4,             // Numero di thread
      temperature: 0.7,       // Temperatura per la generazione
      topP: 0.9,              // Top-p sampling
    };
  }

  /**
   * Inizializza l'handler con il percorso dell'eseguibile e del modello
   * @param {Object} config - Configurazione
   * @returns {Boolean} - true se configurato correttamente
   */
  initialize(config) {
    if (!config || !config.executablePath || !config.modelPath) {
      this.isAvailable = false;
      return false;
    }

    this.executablePath = config.executablePath;
    this.modelPath = config.modelPath;

    // Configura opzioni aggiuntive se fornite
    if (config.contextSize) this.modelConfig.contextSize = config.contextSize;
    if (config.threads) this.modelConfig.threads = config.threads;
    if (config.temperature) this.modelConfig.temperature = config.temperature;
    if (config.topP) this.modelConfig.topP = config.topP;

    // Verifica che i file esistano
    if (!fs.existsSync(this.executablePath) || !fs.existsSync(this.modelPath)) {
      this.isAvailable = false;
      return false;
    }

    this.isAvailable = true;
    return true;
  }

  /**
   * Elabora una prompt usando il modello llama.cpp locale
   * @param {String} prompt - Prompt da elaborare
   * @param {String} conversationId - ID conversazione
   * @returns {Promise<String>} - Risposta elaborata
   */
  async process(prompt, conversationId) {
    if (!this.checkAvailability()) {
      return 'Modello Llama non configurato correttamente';
    }

    return new Promise((resolve, reject) => {
      // Costruisci i parametri per llama.cpp
      const args = [
        '-m', this.modelPath,
        '-c', this.modelConfig.contextSize,
        '-t', this.modelConfig.threads,
        '--temp', this.modelConfig.temperature,
        '--top_p', this.modelConfig.topP,
        '-p', prompt
      ];

      // Avvia il processo llama.cpp
      const llamaProcess = spawn(this.executablePath, args);

      let output = '';
      let errorOutput = '';

      // Gestione dell'output
      llamaProcess.stdout.on('data', (data) => {
        output += data.toString();
      });

      // Gestione degli errori
      llamaProcess.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });

      // Completamento del processo
      llamaProcess.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(`llama.cpp terminato con codice ${code}: ${errorOutput}`));
          return;
        }

        // Estrai la risposta generata (escludi il prompt originale)
        const responseText = output.substring(prompt.length).trim();
        resolve(responseText);
      });
    });
  }

  /**
   * Imposta il modello da utilizzare
   * @param {String} modelPath - Percorso del modello
   */
  setModel(modelPath) {
    if (fs.existsSync(modelPath)) {
      this.modelPath = modelPath;
      this.isAvailable = true;
      return true;
    }
    return false;
  }

  /**
   * Aggiorna le configurazioni del modello
   * @param {Object} config - Nuove configurazioni
   */
  updateConfig(config) {
    if (config.contextSize) this.modelConfig.contextSize = config.contextSize;
    if (config.threads) this.modelConfig.threads = config.threads;
    if (config.temperature) this.modelConfig.temperature = config.temperature;
    if (config.topP) this.modelConfig.topP = config.topP;
  }
}

module.exports = new LlamaHandler();