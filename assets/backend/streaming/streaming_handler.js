// assets/backend/streaming/streaming_handler.js
const { EventEmitter } = require('events');
const WebSocket = require('ws');

/**
 * Gestore centralizzato per lo streaming delle risposte AI
 * Supporta WebSocket e Server-Sent Events (SSE)
 */
class StreamingHandler extends EventEmitter {
  constructor() {
    super();
    this.activeStreams = new Map(); // conversationId -> streamInfo
    this.wsClients = new Map(); // websocket -> clientInfo
    this.sseClients = new Map(); // response -> clientInfo

    // Configurazioni
    this.config = {
      maxStreamingTime: 30000, // 30 secondi max per stream
      chunkSize: 512, // Dimensione chunk per streaming
      heartbeatInterval: 5000, // Heartbeat ogni 5 secondi
      maxConcurrentStreams: 10,
    };

    // Cleanup streams scaduti ogni minuto
    setInterval(() => this._cleanupExpiredStreams(), 60000);
  }

  /**
   * Inizializza un nuovo stream per una conversazione
   */
  async initializeStream(conversationId, clientInfo, streamType = 'websocket') {
    // Verifica limiti di streaming concorrenti
    if (this.activeStreams.size >= this.config.maxConcurrentStreams) {
      throw new Error('Troppi stream attivi. Riprova più tardi.');
    }

    const streamInfo = {
      conversationId,
      startTime: Date.now(),
      clientInfo,
      streamType,
      isActive: true,
      modelProgress: {}, // Progresso per ogni modello
      totalProgress: 0,
      chunks: [], // Buffer dei chunk ricevuti
    };

    this.activeStreams.set(conversationId, streamInfo);

    console.log(`🔄 Stream inizializzato per conversazione ${conversationId} (${streamType})`);
    return streamInfo;
  }

  /**
   * Processa una richiesta streaming con più modelli AI
   */
  async processStreamingRequest(request, streamInfo) {
    const { conversationId } = streamInfo;
    const { prompt, modelConfig, customWeights } = request;

    try {
      // Determina quali modelli utilizzare
      const activeModels = Object.entries(modelConfig)
        .filter(([_, enabled]) => enabled)
        .map(([model, _]) => model);

      if (activeModels.length === 0) {
        throw new Error('Nessun modello AI abilitato per lo streaming');
      }

      // Inizializza il progresso per ogni modello
      activeModels.forEach(model => {
        streamInfo.modelProgress[model] = {
          status: 'pending',
          progress: 0,
          chunks: [],
          completed: false,
          error: null
        };
      });

      // Emetti evento di inizio streaming
      this._emitStreamEvent(conversationId, 'stream_started', {
        models: activeModels,
        totalModels: activeModels.length
      });

      // Avvia streaming parallelo per tutti i modelli
      const streamPromises = activeModels.map(model =>
        this._streamFromModel(model, prompt, conversationId, streamInfo)
      );

      // Aspetta che tutti i modelli completino
      const modelResponses = await Promise.allSettled(streamPromises);

      // Processa i risultati
      const successfulResponses = {};
      const failedModels = [];

      modelResponses.forEach((result, index) => {
        const model = activeModels[index];
        if (result.status === 'fulfilled' && result.value) {
          successfulResponses[model] = result.value;
        } else {
          failedModels.push(model);
          console.error(`❌ Streaming fallito per ${model}:`, result.reason);
        }
      });

      // Se abbiamo almeno una risposta, procedi con la sintesi
      if (Object.keys(successfulResponses).length > 0) {
        await this._streamSynthesis(successfulResponses, customWeights, streamInfo);
      } else {
        throw new Error('Tutti i modelli hanno fallito durante lo streaming');
      }

    } catch (error) {
      console.error(`💥 Errore durante streaming per ${conversationId}:`, error);
      this._emitStreamEvent(conversationId, 'stream_error', {
        error: error.message,
        timestamp: Date.now()
      });
    } finally {
      // Cleanup stream
      this._completeStream(conversationId);
    }
  }

  /**
   * Streaming da un singolo modello AI
   */
  async _streamFromModel(model, prompt, conversationId, streamInfo) {
    const modelProgress = streamInfo.modelProgress[model];
    modelProgress.status = 'streaming';

    try {
      // Emetti inizio streaming per questo modello
      this._emitStreamEvent(conversationId, 'model_stream_started', {
        model,
        timestamp: Date.now()
      });

      // Ottieni handler per il modello
      const handler = this._getModelHandler(model);
      if (!handler || !handler.checkAvailability()) {
        throw new Error(`Modello ${model} non disponibile`);
      }

      // Avvia streaming specifico per il modello
      let fullResponse = '';
      const chunkBuffer = [];

      // Simula streaming (per modelli che non supportano streaming nativo)
      if (handler.supportsStreaming) {
        // Streaming reale
        const stream = await handler.processStream(prompt, conversationId);

        stream.on('data', (chunk) => {
          fullResponse += chunk;
          chunkBuffer.push(chunk);

          // Emetti chunk
          this._emitStreamEvent(conversationId, 'model_chunk', {
            model,
            chunk,
            progress: this._calculateProgress(fullResponse),
            timestamp: Date.now()
          });
        });

        stream.on('end', () => {
          modelProgress.completed = true;
          modelProgress.status = 'completed';
        });

        return new Promise((resolve, reject) => {
          stream.on('end', () => resolve(fullResponse));
          stream.on('error', reject);
        });

      } else {
        // Simula streaming per modelli che non lo supportano nativamente
        const response = await handler.process(prompt, conversationId);
        await this._simulateStreaming(model, response, conversationId, streamInfo);
        return response;
      }

    } catch (error) {
      modelProgress.status = 'error';
      modelProgress.error = error.message;
      throw error;
    }
  }

  /**
   * Simula streaming per modelli che non lo supportano nativamente
   */
  async _simulateStreaming(model, fullResponse, conversationId, streamInfo) {
    const words = fullResponse.split(' ');
    const chunkSize = Math.ceil(words.length / 10); // Dividi in 10 chunk

    for (let i = 0; i < words.length; i += chunkSize) {
      const chunk = words.slice(i, i + chunkSize).join(' ');
      const progress = Math.min((i + chunkSize) / words.length, 1.0);

      // Emetti chunk
      this._emitStreamEvent(conversationId, 'model_chunk', {
        model,
        chunk: chunk + ' ',
        progress,
        timestamp: Date.now()
      });

      // Pausa realistica per simulare streaming
      await new Promise(resolve => setTimeout(resolve, 100 + Math.random() * 200));
    }

    // Marca come completato
    streamInfo.modelProgress[model].completed = true;
    streamInfo.modelProgress[model].status = 'completed';
  }

  /**
   * Streaming della sintesi finale
   */
  async _streamSynthesis(responses, customWeights, streamInfo) {
    const { conversationId } = streamInfo;

    try {
      // Emetti inizio sintesi
      this._emitStreamEvent(conversationId, 'synthesis_started', {
        models: Object.keys(responses),
        timestamp: Date.now()
      });

      // Carica il synthesizer
      const synthesizer = require('../ai-handlers/synthesizer');

      // Simula streaming della sintesi
      const synthesizedResponse = await synthesizer.synthesize(responses, {}, customWeights);

      // Simula streaming della risposta sintetizzata
      const words = synthesizedResponse.split(' ');
      const chunkSize = Math.ceil(words.length / 15); // Sintesi più lenta

      for (let i = 0; i < words.length; i += chunkSize) {
        const chunk = words.slice(i, i + chunkSize).join(' ');
        const progress = Math.min((i + chunkSize) / words.length, 1.0);

        this._emitStreamEvent(conversationId, 'synthesis_chunk', {
          chunk: chunk + ' ',
          progress,
          timestamp: Date.now()
        });

        await new Promise(resolve => setTimeout(resolve, 150 + Math.random() * 300));
      }

      // Emetti fine sintesi
      this._emitStreamEvent(conversationId, 'synthesis_completed', {
        finalResponse: synthesizedResponse,
        timestamp: Date.now()
      });

    } catch (error) {
      this._emitStreamEvent(conversationId, 'synthesis_error', {
        error: error.message,
        timestamp: Date.now()
      });
      throw error;
    }
  }

  /**
   * Ottiene handler per un modello specifico
   */
  _getModelHandler(model) {
    const handlers = {
      'gpt': require('../ai-handlers/gpt_handler'),
      'claude': require('../ai-handlers/claude_handler'),
      'deepseek': require('../ai-handlers/deepseek_handler'),
      'gemini': require('../ai-handlers/gemini_handler'),
      'mistral': require('../ai-handlers/mistral_handler'),
      'ollama': require('../ai-handlers/ollama_handler'),
      'llama': require('../ai-handlers/llama_handler'),
    };

    return handlers[model];
  }

  /**
   * Calcola progresso basato sulla lunghezza della risposta
   */
  _calculateProgress(response) {
    // Stima basata su lunghezza tipica (500-1500 caratteri)
    const estimatedLength = 1000;
    return Math.min(response.length / estimatedLength, 1.0);
  }

  /**
   * Emette evento di streaming a tutti i client connessi
   */
  _emitStreamEvent(conversationId, eventType, data) {
    const streamInfo = this.activeStreams.get(conversationId);
    if (!streamInfo) return;

    const event = {
      type: eventType,
      conversationId,
      data,
      timestamp: Date.now()
    };

    // WebSocket clients
    this.wsClients.forEach((clientInfo, ws) => {
      if (clientInfo.conversationId === conversationId && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(event));
      }
    });

    // SSE clients
    this.sseClients.forEach((clientInfo, res) => {
      if (clientInfo.conversationId === conversationId && !res.destroyed) {
        res.write(`data: ${JSON.stringify(event)}\n\n`);
      }
    });

    // Emetti anche come evento interno
    this.emit('stream_event', event);
  }

  /**
   * Completa uno stream
   */
  _completeStream(conversationId) {
    const streamInfo = this.activeStreams.get(conversationId);
    if (!streamInfo) return;

    streamInfo.isActive = false;
    streamInfo.endTime = Date.now();

    // Emetti evento di completamento
    this._emitStreamEvent(conversationId, 'stream_completed', {
      duration: streamInfo.endTime - streamInfo.startTime,
      totalChunks: streamInfo.chunks.length
    });

    // Rimuovi stream dalla mappa attiva (dopo un breve delay per cleanup)
    setTimeout(() => {
      this.activeStreams.delete(conversationId);
    }, 5000);

    console.log(`✅ Stream completato per conversazione ${conversationId}`);
  }

  /**
   * Cleanup streams scaduti
   */
  _cleanupExpiredStreams() {
    const now = Date.now();

    for (const [conversationId, streamInfo] of this.activeStreams.entries()) {
      const age = now - streamInfo.startTime;

      if (age > this.config.maxStreamingTime) {
        console.log(`🧹 Cleanup stream scaduto: ${conversationId}`);
        this._completeStream(conversationId);
      }
    }
  }

  /**
   * Registra un client WebSocket
   */
  registerWebSocketClient(ws, conversationId, clientInfo = {}) {
    this.wsClients.set(ws, {
      conversationId,
      connectedAt: Date.now(),
      ...clientInfo
    });

    ws.on('close', () => {
      this.wsClients.delete(ws);
    });
  }

  /**
   * Registra un client SSE
   */
  registerSSEClient(res, conversationId, clientInfo = {}) {
    this.sseClients.set(res, {
      conversationId,
      connectedAt: Date.now(),
      ...clientInfo
    });

    res.on('close', () => {
      this.sseClients.delete(res);
    });
  }

  /**
   * Ottiene statistiche degli stream attivi
   */
  getStreamingStats() {
    return {
      activeStreams: this.activeStreams.size,
      wsClients: this.wsClients.size,
      sseClients: this.sseClients.size,
      totalEventsEmitted: this.listenerCount('stream_event'),
    };
  }
}

// Singleton instance
const streamingHandler = new StreamingHandler();

module.exports = streamingHandler;