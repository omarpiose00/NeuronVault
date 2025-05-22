// assets/backend/ai-handlers/advanced_streaming_orchestrator.js
const { EventEmitter } = require('events');
const WebSocket = require('ws');

/**
 * Advanced AI Streaming Orchestrator con strategie intelligenti
 */
class AdvancedStreamingOrchestrator extends EventEmitter {
  constructor() {
    super();
    this.activeStreams = new Map();
    this.modelPerformanceMetrics = new Map();
    this.adaptiveWeights = new Map();

    // Configurazioni avanzate
    this.config = {
      maxConcurrentStreams: 12,
      adaptiveWeightingEnabled: true,
      consensusThreshold: 0.7,
      streamingStrategies: {
        PARALLEL: 'parallel',
        SEQUENTIAL: 'sequential',
        ADAPTIVE: 'adaptive',
        CONSENSUS: 'consensus'
      },
      qualityMetrics: {
        responseTime: 0.3,
        completeness: 0.4,
        coherence: 0.3
      }
    };
  }

  /**
   * Avvia streaming intelligente con strategia adattiva
   */
  async startIntelligentStreaming(request, streamInfo) {
    const { prompt, modelConfig, customWeights, mode } = request;
    const { conversationId } = streamInfo;

    try {
      // Analizza il prompt per determinare la strategia ottimale
      const strategy = this._determineOptimalStrategy(prompt, modelConfig, mode);

      this.emit('strategy_selected', { conversationId, strategy, reasoning: strategy.reasoning });

      // Esegui streaming secondo la strategia selezionata
      switch (strategy.type) {
        case this.config.streamingStrategies.PARALLEL:
          return await this._executeParallelStreaming(request, streamInfo);

        case this.config.streamingStrategies.SEQUENTIAL:
          return await this._executeSequentialStreaming(request, streamInfo);

        case this.config.streamingStrategies.ADAPTIVE:
          return await this._executeAdaptiveStreaming(request, streamInfo);

        case this.config.streamingStrategies.CONSENSUS:
          return await this._executeConsensusStreaming(request, streamInfo);

        default:
          return await this._executeParallelStreaming(request, streamInfo);
      }
    } catch (error) {
      this.emit('streaming_error', { conversationId, error: error.message });
      throw error;
    }
  }

  /**
   * Determina la strategia ottimale basata sul context analysis
   */
  _determineOptimalStrategy(prompt, modelConfig, mode) {
    const promptAnalysis = this._analyzePrompt(prompt);
    const modelCount = Object.keys(modelConfig).filter(m => modelConfig[m]).length;

    // Strategia basata su complessità e contesto
    if (promptAnalysis.complexity === 'high' && promptAnalysis.requiresDebate) {
      return {
        type: this.config.streamingStrategies.CONSENSUS,
        reasoning: 'High complexity prompt requiring multi-perspective consensus'
      };
    }

    if (promptAnalysis.urgency === 'high' && modelCount <= 3) {
      return {
        type: this.config.streamingStrategies.PARALLEL,
        reasoning: 'High urgency with manageable model count'
      };
    }

    if (promptAnalysis.requiresSequencing || modelCount > 5) {
      return {
        type: this.config.streamingStrategies.ADAPTIVE,
        reasoning: 'Large model set requiring adaptive orchestration'
      };
    }

    return {
      type: this.config.streamingStrategies.PARALLEL,
      reasoning: 'Default parallel strategy for optimal performance'
    };
  }

  /**
   * Analizza il prompt per determinare caratteristiche
   */
  _analyzePrompt(prompt) {
    const analysis = {
      complexity: 'medium',
      urgency: 'medium',
      requiresDebate: false,
      requiresSequencing: false,
      expectedLength: 'medium'
    };

    // Analisi complessità
    const complexityIndicators = [
      'analizza', 'confronta', 'valuta', 'critica', 'approfondisci',
      'detailed analysis', 'comprehensive', 'thorough', 'in-depth'
    ];

    if (complexityIndicators.some(indicator =>
        prompt.toLowerCase().includes(indicator.toLowerCase()))) {
      analysis.complexity = 'high';
    }

    // Analisi urgency
    const urgencyIndicators = [
      'velocemente', 'rapidamente', 'subito', 'urgente',
      'quickly', 'fast', 'urgent', 'immediate'
    ];

    if (urgencyIndicators.some(indicator =>
        prompt.toLowerCase().includes(indicator.toLowerCase()))) {
      analysis.urgency = 'high';
    }

    // Analisi debate requirement
    const debateIndicators = [
      'dibattito', 'opinioni diverse', 'punti di vista', 'confronto',
      'debate', 'different opinions', 'perspectives', 'compare views'
    ];

    if (debateIndicators.some(indicator =>
        prompt.toLowerCase().includes(indicator.toLowerCase()))) {
      analysis.requiresDebate = true;
    }

    return analysis;
  }

  /**
   * Streaming parallelo ottimizzato
   */
  async _executeParallelStreaming(request, streamInfo) {
    const { conversationId } = streamInfo;
    const activeModels = this._getActiveModels(request.modelConfig);

    this.emit('parallel_streaming_started', {
      conversationId,
      models: activeModels,
      estimatedDuration: this._estimateStreamingDuration(activeModels)
    });

    // Avvia tutti i modelli in parallelo con load balancing
    const streamPromises = activeModels.map(model =>
      this._streamFromModelWithMetrics(model, request, streamInfo)
    );

    // Attesa con early completion se possibile
    const results = await this._waitForStreamsWithEarlyCompletion(
      streamPromises,
      streamInfo,
      0.8 // Complete when 80% of models finish
    );

    return results;
  }

  /**
   * Streaming adattivo basato su performance real-time
   */
  async _executeAdaptiveStreaming(request, streamInfo) {
    const { conversationId } = streamInfo;
    const activeModels = this._getActiveModels(request.modelConfig);

    // Ordina modelli per performance storica
    const orderedModels = this._orderModelsByPerformance(activeModels);

    // Avvia i primi 3 modelli più performanti
    const firstBatch = orderedModels.slice(0, 3);
    const remainingModels = orderedModels.slice(3);

    this.emit('adaptive_streaming_started', {
      conversationId,
      firstBatch,
      remainingBatch: remainingModels
    });

    // Prima ondata
    const firstResults = await this._executeParallelBatch(firstBatch, request, streamInfo);

    // Decisione adattiva per i modelli rimanenti
    if (this._shouldContinueWithRemainingModels(firstResults, remainingModels)) {
      const remainingResults = await this._executeParallelBatch(remainingModels, request, streamInfo);
      return { ...firstResults, ...remainingResults };
    }

    return firstResults;
  }

  /**
   * Streaming con consensus intelligente
   */
  async _executeConsensusStreaming(request, streamInfo) {
    const { conversationId } = streamInfo;
    const activeModels = this._getActiveModels(request.modelConfig);

    // Fase 1: Streaming parallelo iniziale
    const initialResults = await this._executeParallelStreaming(request, streamInfo);

    // Fase 2: Analisi consenso
    const consensusAnalysis = this._analyzeConsensus(initialResults);

    this.emit('consensus_analysis', {
      conversationId,
      consensusScore: consensusAnalysis.score,
      agreements: consensusAnalysis.agreements,
      disagreements: consensusAnalysis.disagreements
    });

    // Fase 3: Risoluzione disagreements se necessario
    if (consensusAnalysis.score < this.config.consensusThreshold) {
      const refinedResults = await this._resolveDisagreements(
        initialResults,
        consensusAnalysis,
        request,
        streamInfo
      );
      return refinedResults;
    }

    return initialResults;
  }

  /**
   * Streaming da modello singolo con metriche avanzate
   */
  async _streamFromModelWithMetrics(model, request, streamInfo) {
    const startTime = Date.now();
    const { conversationId } = streamInfo;

    try {
      const handler = this._getModelHandler(model);
      if (!handler || !handler.checkAvailability()) {
        throw new Error(`Model ${model} not available`);
      }

      // Inizializza metriche
      const metrics = {
        model,
        startTime,
        chunks: [],
        totalTime: 0,
        averageChunkTime: 0,
        qualityScore: 0
      };

      // Stream con tracking
      let fullResponse = '';
      const chunkTimes = [];

      if (handler.supportsStreaming) {
        // Streaming nativo
        const stream = await handler.processStream(request.prompt, conversationId);

        stream.on('data', (chunk) => {
          const chunkTime = Date.now();
          chunkTimes.push(chunkTime - (chunkTimes.length > 0 ? chunkTimes[chunkTimes.length - 1] : startTime));

          fullResponse += chunk;
          metrics.chunks.push({
            content: chunk,
            timestamp: chunkTime,
            cumulativeLength: fullResponse.length
          });

          this.emit('model_chunk_with_metrics', {
            conversationId,
            model,
            chunk,
            metrics: {
              chunkIndex: metrics.chunks.length,
              responseTime: chunkTime - startTime,
              totalLength: fullResponse.length
            }
          });
        });

        return new Promise((resolve, reject) => {
          stream.on('end', () => {
            metrics.totalTime = Date.now() - startTime;
            metrics.averageChunkTime = chunkTimes.reduce((a, b) => a + b, 0) / chunkTimes.length;
            metrics.qualityScore = this._calculateQualityScore(fullResponse, metrics);

            this._updateModelMetrics(model, metrics);
            resolve(fullResponse);
          });

          stream.on('error', reject);
        });
      } else {
        // Simulated streaming con chunking intelligente
        const response = await handler.process(request.prompt, conversationId);
        await this._simulateIntelligentStreaming(model, response, conversationId, streamInfo, metrics);

        metrics.totalTime = Date.now() - startTime;
        metrics.qualityScore = this._calculateQualityScore(response, metrics);

        this._updateModelMetrics(model, metrics);
        return response;
      }
    } catch (error) {
      this.emit('model_streaming_error', { conversationId, model, error: error.message });
      throw error;
    }
  }

  /**
   * Simula streaming intelligente per modelli non-streaming
   */
  async _simulateIntelligentStreaming(model, fullResponse, conversationId, streamInfo, metrics) {
    // Chunking semantico invece di word-based
    const chunks = this._createSemanticChunks(fullResponse);

    for (let i = 0; i < chunks.length; i++) {
      const chunk = chunks[i];
      const delay = this._calculateAdaptiveDelay(chunk, i, chunks.length);

      metrics.chunks.push({
        content: chunk,
        timestamp: Date.now(),
        semanticType: chunk.type
      });

      this.emit('model_chunk_with_metrics', {
        conversationId,
        model,
        chunk: chunk.content,
        metrics: {
          chunkIndex: i,
          semanticType: chunk.type,
          totalChunks: chunks.length,
          progress: (i + 1) / chunks.length
        }
      });

      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }

  /**
   * Crea chunks semantici basati su contenuto
   */
  _createSemanticChunks(text) {
    const sentences = text.split(/[.!?]+/).filter(s => s.trim());
    const chunks = [];

    let currentChunk = '';
    let chunkType = 'introduction';

    sentences.forEach((sentence, index) => {
      const trimmed = sentence.trim();
      if (!trimmed) return;

      // Determina il tipo semantico
      if (index === 0) chunkType = 'introduction';
      else if (index >= sentences.length - 2) chunkType = 'conclusion';
      else if (trimmed.toLowerCase().includes('tuttavia') ||
               trimmed.toLowerCase().includes('però') ||
               trimmed.toLowerCase().includes('however')) {
        chunkType = 'transition';
      } else {
        chunkType = 'elaboration';
      }

      currentChunk += trimmed + '. ';

      // Crea chunk ogni 2-3 frasi o al cambio di tipo semantico
      if (currentChunk.split('.').length >= 3 || index === sentences.length - 1) {
        chunks.push({
          content: currentChunk.trim(),
          type: chunkType
        });
        currentChunk = '';
      }
    });

    return chunks;
  }

  /**
   * Calcola delay adattivo basato su contenuto
   */
  _calculateAdaptiveDelay(chunk, index, totalChunks) {
    const baseDelay = 200; // ms
    const typeMultipliers = {
      'introduction': 1.2,
      'elaboration': 1.0,
      'transition': 1.5,
      'conclusion': 1.3
    };

    const progressFactor = 1 - (index / totalChunks) * 0.3; // Accelera verso la fine
    const typeMultiplier = typeMultipliers[chunk.type] || 1.0;

    return Math.round(baseDelay * typeMultiplier * progressFactor);
  }

  /**
   * Calcola score di qualità della risposta
   */
  _calculateQualityScore(response, metrics) {
    let score = 0;

    // Response time score (30%)
    const responseTimeScore = Math.max(0, 1 - (metrics.totalTime / 10000)); // 10s max
    score += responseTimeScore * 0.3;

    // Completeness score (40%)
    const completenessScore = Math.min(1, response.length / 500); // 500 chars ideal
    score += completenessScore * 0.4;

    // Coherence score (30%) - heuristic basata su struttura
    const coherenceScore = this._calculateCoherenceScore(response);
    score += coherenceScore * 0.3;

    return Math.round(score * 100) / 100;
  }

  /**
   * Calcola score di coerenza (heuristic)
   */
  _calculateCoherenceScore(response) {
    // Analisi semplificata di coerenza
    const sentences = response.split(/[.!?]+/).filter(s => s.trim());
    if (sentences.length === 0) return 0;

    // Penalizza risposte troppo corte o troppo lunghe
    if (sentences.length < 2) return 0.5;
    if (sentences.length > 20) return 0.7;

    // Verifica connettori logici
    const connectors = ['inoltre', 'tuttavia', 'quindi', 'pertanto', 'infatti'];
    const connectorsFound = connectors.filter(conn =>
      response.toLowerCase().includes(conn)).length;

    const connectorScore = Math.min(1, connectorsFound / 3);

    // Verifica struttura paragrafi
    const paragraphs = response.split('\n\n').filter(p => p.trim());
    const structureScore = paragraphs.length > 1 ? 0.8 : 0.6;

    return (connectorScore + structureScore) / 2;
  }

  /**
   * Aggiorna metriche modello per learning adattivo
   */
  _updateModelMetrics(model, newMetrics) {
    if (!this.modelPerformanceMetrics.has(model)) {
      this.modelPerformanceMetrics.set(model, {
        totalRequests: 0,
        averageResponseTime: 0,
        averageQualityScore: 0,
        reliability: 1.0,
        history: []
      });
    }

    const metrics = this.modelPerformanceMetrics.get(model);
    metrics.totalRequests++;

    // Moving average per performance
    const alpha = 0.2; // Learning rate
    metrics.averageResponseTime = (1 - alpha) * metrics.averageResponseTime +
                                 alpha * newMetrics.totalTime;
    metrics.averageQualityScore = (1 - alpha) * metrics.averageQualityScore +
                                 alpha * newMetrics.qualityScore;

    // Mantieni storia limitata
    metrics.history.push({
      timestamp: Date.now(),
      responseTime: newMetrics.totalTime,
      qualityScore: newMetrics.qualityScore
    });

    if (metrics.history.length > 50) {
      metrics.history = metrics.history.slice(-50);
    }

    this.modelPerformanceMetrics.set(model, metrics);

    // Aggiorna pesi adattivi se abilitato
    if (this.config.adaptiveWeightingEnabled) {
      this._updateAdaptiveWeights(model, newMetrics);
    }
  }

  /**
   * Ordina modelli per performance
   */
  _orderModelsByPerformance(models) {
    return models.sort((a, b) => {
      const metricsA = this.modelPerformanceMetrics.get(a) || { averageQualityScore: 0.5 };
      const metricsB = this.modelPerformanceMetrics.get(b) || { averageQualityScore: 0.5 };

      const scoreA = metricsA.averageQualityScore * metricsA.reliability;
      const scoreB = metricsB.averageQualityScore * metricsB.reliability;

      return scoreB - scoreA; // Descending order
    });
  }

  /**
   * Ottieni handler per modello
   */
  _getModelHandler(model) {
    const handlers = {
      'gpt': require('./gpt_handler'),
      'claude': require('./claude_handler'),
      'deepseek': require('./deepseek_handler'),
      'gemini': require('./gemini_handler'),
      'mistral': require('./mistral_handler'),
      'ollama': require('./ollama_handler'),
      'llama': require('./llama_handler'),
    };

    return handlers[model];
  }

  /**
   * Ottieni modelli attivi
   */
  _getActiveModels(modelConfig) {
    return Object.entries(modelConfig)
      .filter(([_, enabled]) => enabled)
      .map(([model, _]) => model);
  }

  /**
   * Stima durata streaming
   */
  _estimateStreamingDuration(models) {
    const averageTime = models.reduce((acc, model) => {
      const metrics = this.modelPerformanceMetrics.get(model);
      return acc + (metrics ? metrics.averageResponseTime : 3000);
    }, 0) / models.length;

    return Math.round(averageTime);
  }

  /**
   * Ottieni statistiche performance
   */
  getPerformanceStats() {
    const stats = {};
    for (const [model, metrics] of this.modelPerformanceMetrics.entries()) {
      stats[model] = {
        requests: metrics.totalRequests,
        avgResponseTime: Math.round(metrics.averageResponseTime),
        avgQuality: Math.round(metrics.averageQualityScore * 100) / 100,
        reliability: Math.round(metrics.reliability * 100) / 100
      };
    }
    return stats;
  }
}

module.exports = new AdvancedStreamingOrchestrator();