// assets/backend/ai-handlers/router.js - Versione corretta senza duplicazioni

const gptHandler = require('./gpt_handler');
const claudeHandler = require('./claude_handler');
const deepseekHandler = require('./deepseek_handler');
const mistralHandler = require('./mistral_handler');
const geminiHandler = require('./gemini_handler');
const ollamaHandler = require('./ollama_handler');
const llamaHandler = require('./llama_handler');
const synthesizer = require('./mini_llm_synthesizer');

/**
 * Router centralizzato per le richieste AI
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
      'llama': llamaHandler,
    };

    // Configurazioni globali
    this.config = {
      maxRetries: 3,
      timeout: 30000,
      autoAdjustWeights: true,
      parallelProcessing: true,
      fallbackEnabled: true
    };

    // Cache per le risposte (TTL: 5 minuti)
    this.responseCache = new Map();
    this.cacheTTL = 5 * 60 * 1000;

    // Statistiche per monitoring
    this.stats = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageResponseTime: 0,
      modelUsage: {},
      errorCounts: {}
    };

    // Cleanup cache ogni 10 minuti
    setInterval(() => this._cleanupCache(), 10 * 60 * 1000);
  }

  /**
   * Inizializza gli handler con le chiavi API
   * @param {Object} apiKeys - Chiavi API per ciascun provider
   */
  initialize(apiKeys) {
    console.log('🔧 Initializing AI Router...');

    // Mappa dei nomi provider ai nomi handler
    const providerMap = {
      'openai': 'gpt',
      'anthropic': 'claude',
      'deepseek': 'deepseek',
      'google': 'gemini',
      'mistral': 'mistral',
      'ollama': 'ollama',
      'llama': 'llama'
    };

    let initializedCount = 0;

    for (const [provider, apiKey] of Object.entries(apiKeys)) {
      const handlerName = providerMap[provider] || provider;
      const handler = this.handlers[handlerName];

      if (handler) {
        try {
          // Inizializza l'handler
          const initialized = handler.initialize(apiKey);

          if (initialized) {
            initializedCount++;
            console.log(`✅ ${handlerName.toUpperCase()} initialized`);

            // Inizializza statistiche per questo modello
            this.stats.modelUsage[handlerName] = {
              requests: 0,
              successes: 0,
              failures: 0,
              totalResponseTime: 0,
              averageResponseTime: 0
            };
          } else {
            console.log(`❌ ${handlerName.toUpperCase()} failed to initialize`);
          }
        } catch (error) {
          console.error(`💥 Error initializing ${handlerName}:`, error.message);
          this.stats.errorCounts[handlerName] = (this.stats.errorCounts[handlerName] || 0) + 1;
        }
      } else {
        console.warn(`⚠️  Unknown handler: ${handlerName}`);
      }
    }

    // Inizializza il synthesizer se disponibile
    try {
      const synthesizerConfig = this._getSynthesizerConfig(apiKeys);
      if (synthesizerConfig) {
        synthesizer.initialize(synthesizerConfig);
        console.log('✅ Mini-LLM Synthesizer initialized');
      }
    } catch (error) {
      console.warn('⚠️  Mini-LLM Synthesizer not available:', error.message);
    }

    console.log(`🎯 AI Router initialized with ${initializedCount} models`);
    return initializedCount > 0;
  }

  /**
   * Elabora una richiesta e routing ai vari handler
   * @param {Object} request - Richiesta da elaborare
   * @returns {Promise<Object>} - Risposta elaborata
   */
  async processRequest(request) {
    const startTime = Date.now();
    const requestId = this._generateRequestId();

    console.log(`🚀 Processing request ${requestId}`);

    this.stats.totalRequests++;

    try {
      // Validazione input
      const validatedRequest = this._validateRequest(request);

      // Cache lookup
      const cacheKey = this._generateCacheKey(validatedRequest);
      const cachedResponse = this._getCachedResponse(cacheKey);

      if (cachedResponse) {
        console.log(`💾 Cache hit for request ${requestId}`);
        return cachedResponse;
      }

      // Determina quali handler utilizzare
      const activeHandlers = this._getActiveHandlers(validatedRequest.modelConfig);

      if (activeHandlers.length === 0) {
        throw new Error('Nessun modello AI abilitato o disponibile');
      }

      console.log(`🎭 Using models: ${activeHandlers.join(', ')}`);

      // Elabora la richiesta con gli handler attivi
      const responses = await this._processWithHandlers(activeHandlers, validatedRequest, requestId);

      // Sintetizza le risposte
      const synthesizedResponse = await this._synthesizeResponses(
        responses,
        validatedRequest,
        requestId
      );

      // Costruisci la risposta finale
      const finalResponse = this._buildFinalResponse(
        validatedRequest,
        responses,
        synthesizedResponse,
        startTime
      );

      // Cache della risposta
      this._cacheResponse(cacheKey, finalResponse);

      // Aggiorna statistiche
      this._updateStats(activeHandlers, startTime, true);

      this.stats.successfulRequests++;

      const processingTime = Date.now() - startTime;
      console.log(`✅ Request ${requestId} completed in ${processingTime}ms`);

      return finalResponse;

    } catch (error) {
      const processingTime = Date.now() - startTime;
      console.error(`❌ Request ${requestId} failed after ${processingTime}ms:`, error.message);

      this.stats.failedRequests++;
      this._updateStats([], startTime, false);

      return {
        error: error.message,
        conversation: this._buildErrorConversation(request, error),
        requestId,
        processingTime
      };
    }
  }

  /**
   * Elabora le richieste con gli handler specificati
   * @private
   */
  async _processWithHandlers(handlerNames, request, requestId) {
    const responses = {};
    const errors = {};

    if (this.config.parallelProcessing) {
      // Elaborazione parallela
      const promises = handlerNames.map(async (handlerName) => {
        return this._processWithSingleHandler(handlerName, request, requestId);
      });

      const results = await Promise.allSettled(promises);

      handlerNames.forEach((handlerName, index) => {
        const result = results[index];
        if (result.status === 'fulfilled') {
          responses[handlerName] = result.value;
        } else {
          errors[handlerName] = result.reason.message;
          console.error(`Handler ${handlerName} failed:`, result.reason.message);
        }
      });

    } else {
      // Elaborazione sequenziale
      for (const handlerName of handlerNames) {
        try {
          responses[handlerName] = await this._processWithSingleHandler(handlerName, request, requestId);
        } catch (error) {
          errors[handlerName] = error.message;
          console.error(`Handler ${handlerName} failed:`, error.message);

          // Se fallback è disabilitato, interrompi
          if (!this.config.fallbackEnabled) {
            throw error;
          }
        }
      }
    }

    // Se nessuna risposta è riuscita
    if (Object.keys(responses).length === 0) {
      throw new Error(`Tutti i modelli hanno fallito: ${JSON.stringify(errors)}`);
    }

    // Log degli errori parziali
    if (Object.keys(errors).length > 0) {
      console.warn(`⚠️  Partial failures in request ${requestId}:`, errors);
    }

    return responses;
  }

  /**
   * Elabora con un singolo handler
   * @private
   */
  async _processWithSingleHandler(handlerName, request, requestId) {
    const handler = this.handlers[handlerName];
    const startTime = Date.now();

    // Aggiorna statistiche
    this.stats.modelUsage[handlerName].requests++;

    try {
      console.log(`🤖 Processing with ${handlerName} for request ${requestId}`);

      // Timeout per singolo handler
      const timeoutPromise = new Promise((_, reject) => {
        setTimeout(() => reject(new Error(`Timeout for ${handlerName}`)), this.config.timeout);
      });

      const responsePromise = handler.process(request.prompt, request.conversationId);
      const response = await Promise.race([responsePromise, timeoutPromise]);

      const responseTime = Date.now() - startTime;

      // Aggiorna statistiche di successo
      this.stats.modelUsage[handlerName].successes++;
      this.stats.modelUsage[handlerName].totalResponseTime += responseTime;
      this.stats.modelUsage[handlerName].averageResponseTime =
        this.stats.modelUsage[handlerName].totalResponseTime /
        this.stats.modelUsage[handlerName].successes;

      console.log(`✅ ${handlerName} responded in ${responseTime}ms`);
      return response;

    } catch (error) {
      const responseTime = Date.now() - startTime;

      // Aggiorna statistiche di fallimento
      this.stats.modelUsage[handlerName].failures++;
      this.stats.errorCounts[handlerName] = (this.stats.errorCounts[handlerName] || 0) + 1;

      console.error(`❌ ${handlerName} failed after ${responseTime}ms:`, error.message);
      throw error;
    }
  }

  /**
   * Sintetizza le risposte usando il synthesizer
   * @private
   */
  async _synthesizeResponses(responses, request, requestId) {
    if (Object.keys(responses).length === 1) {
      // Se c'è solo una risposta, restituiscila direttamente
      return Object.values(responses)[0];
    }

    try {
      console.log(`🔄 Synthesizing ${Object.keys(responses).length} responses for request ${requestId}`);

      const synthesized = await synthesizer.synthesize(
        responses,
        request.modelConfig,
        request.prompt,
        request.customWeights
      );

      console.log(`✅ Synthesis completed for request ${requestId}`);
      return synthesized;

    } catch (error) {
      console.warn(`⚠️  Synthesis failed for request ${requestId}, using fallback:`, error.message);

      // Fallback: usa la risposta del modello con peso maggiore
      return this._fallbackSynthesis(responses, request.customWeights);
    }
  }

  /**
   * Fallback synthesis - usa la risposta del modello con peso maggiore
   * @private
   */
  _fallbackSynthesis(responses, customWeights = null) {
    const weights = customWeights || synthesizer.getWeights();

    let bestModel = null;
    let bestWeight = 0;

    for (const [model, response] of Object.entries(responses)) {
      const weight = weights[model] || 1.0;
      if (weight > bestWeight) {
        bestWeight = weight;
        bestModel = model;
      }
    }

    return bestModel ? responses[bestModel] : Object.values(responses)[0];
  }

  /**
   * Costruisce la risposta finale
   * @private
   */
  _buildFinalResponse(request, responses, synthesizedResponse, startTime) {
    const conversation = [
      {
        agent: 'user',
        message: request.prompt,
        timestamp: new Date().toISOString(),
        metadata: {
          mode: request.mode || 'chat',
          models: Object.keys(responses)
        }
      }
    ];

    // Aggiungi risposte individuali se richiesto
    if (request.includeIndividualResponses) {
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
      metadata: {
        synthesized: true,
        sourceModels: Object.keys(responses),
        weights: request.customWeights || synthesizer.getWeights()
      }
    });

    return {
      conversation,
      responses,
      weights: request.customWeights || synthesizer.getWeights(),
      synthesizedResponse,
      metadata: {
        processingTime: Date.now() - startTime,
        modelsUsed: Object.keys(responses),
        requestId: this._generateRequestId(),
        cacheHit: false
      }
    };
  }

  /**
   * Costruisce una conversazione di errore
   * @private
   */
  _buildErrorConversation(request, error) {
    return [
      {
        agent: 'user',
        message: request.prompt || 'Richiesta non valida',
        timestamp: new Date().toISOString(),
      },
      {
        agent: 'system',
        message: `Errore: ${error.message}`,
        timestamp: new Date().toISOString(),
        metadata: {
          error: true,
          errorType: error.constructor.name
        }
      }
    ];
  }

  /**
   * Ottiene gli handler attivi in base alla configurazione
   * @private
   */
  _getActiveHandlers(modelConfig) {
    if (!modelConfig || typeof modelConfig !== 'object') {
      return [];
    }

    return Object.entries(modelConfig)
      .filter(([_, enabled]) => enabled === true)
      .map(([model, _]) => model)
      .filter(model =>
        this.handlers[model] &&
        this.handlers[model].checkAvailability()
      );
  }

  /**
   * Valida la richiesta in ingresso
   * @private
   */
  _validateRequest(request) {
    const required = ['prompt'];
    const missing = required.filter(field => !request[field]);

    if (missing.length > 0) {
      throw new Error(`Campi richiesti mancanti: ${missing.join(', ')}`);
    }

    return {
      prompt: request.prompt.trim(),
      conversationId: request.conversationId || 'default',
      modelConfig: request.modelConfig || { gpt: true },
      customWeights: request.customWeights || null,
      mode: request.mode || 'chat',
      includeIndividualResponses: request.includeIndividualResponses || false,
      context: request.context || []
    };
  }

  /**
   * Genera una chiave per il cache
   * @private
   */
  _generateCacheKey(request) {
    const keyData = {
      prompt: request.prompt,
      models: Object.keys(request.modelConfig).filter(k => request.modelConfig[k]).sort(),
      weights: request.customWeights,
      mode: request.mode
    };

    return Buffer.from(JSON.stringify(keyData)).toString('base64');
  }

  /**
   * Recupera risposta dalla cache
   * @private
   */
  _getCachedResponse(cacheKey) {
    const cached = this.responseCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < this.cacheTTL) {
      const response = { ...cached.data };
      response.metadata.cacheHit = true;
      return response;
    }
    return null;
  }

  /**
   * Salva risposta in cache
   * @private
   */
  _cacheResponse(cacheKey, response) {
    this.responseCache.set(cacheKey, {
      data: response,
      timestamp: Date.now()
    });
  }

  /**
   * Pulisce cache scaduta
   * @private
   */
  _cleanupCache() {
    const now = Date.now();
    for (const [key, value] of this.responseCache.entries()) {
      if (now - value.timestamp > this.cacheTTL) {
        this.responseCache.delete(key);
      }
    }
  }

  /**
   * Aggiorna statistiche
   * @private
   */
  _updateStats(handlerNames, startTime, success) {
    const responseTime = Date.now() - startTime;

    // Aggiorna tempo di risposta medio
    const totalTime = this.stats.averageResponseTime * (this.stats.totalRequests - 1) + responseTime;
    this.stats.averageResponseTime = totalTime / this.stats.totalRequests;
  }

  /**
   * Genera ID richiesta univoco
   * @private
   */
  _generateRequestId() {
    return `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Ottiene configurazione per il synthesizer
   * @private
   */
  _getSynthesizerConfig(apiKeys) {
    // Cerca configurazioni per Mini-LLM
    if (process.env.MINI_LLM_EXECUTABLE && process.env.MINI_LLM_MODEL) {
      return {
        executablePath: process.env.MINI_LLM_EXECUTABLE,
        modelPath: process.env.MINI_LLM_MODEL
      };
    }
    return null;
  }

  /**
   * Imposta configurazione del router
   */
  setConfig(newConfig) {
    this.config = { ...this.config, ...newConfig };
    console.log('🔧 Router configuration updated:', this.config);
  }

  /**
   * Aggiorna i pesi in base al feedback dell'utente
   */
  updateWeights(preferredModel, rating) {
    if (this.config.autoAdjustWeights) {
      synthesizer.updateWeights(preferredModel, rating);
      console.log(`📊 Weights updated for ${preferredModel} with rating ${rating}`);
    }
  }

  /**
   * Resetta i pesi ai valori predefiniti
   */
  resetWeights() {
    synthesizer.resetWeights();
    console.log('🔄 Weights reset to default values');
  }

  /**
   * Ottiene i pesi correnti
   */
  getWeights() {
    return synthesizer.getWeights();
  }

  /**
   * Ottiene statistiche del router
   */
  getStats() {
    return {
      ...this.stats,
      cacheSize: this.responseCache.size,
      availableHandlers: Object.keys(this.handlers).filter(
        key => this.handlers[key].checkAvailability()
      ),
      config: this.config
    };
  }

  /**
   * Reset statistiche
   */
  resetStats() {
    this.stats = {
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageResponseTime: 0,
      modelUsage: {},
      errorCounts: {}
    };

    // Reinizializza statistiche per modelli attivi
    Object.keys(this.handlers).forEach(handlerName => {
      if (this.handlers[handlerName].checkAvailability()) {
        this.stats.modelUsage[handlerName] = {
          requests: 0,
          successes: 0,
          failures: 0,
          totalResponseTime: 0,
          averageResponseTime: 0
        };
      }
    });

    console.log('📊 Statistics reset');
  }
}

// Crea istanza singleton
const aiRouter = new AIRouter();

module.exports = aiRouter;