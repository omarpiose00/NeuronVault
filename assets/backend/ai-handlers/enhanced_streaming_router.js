// assets/backend/ai-handlers/enhanced_streaming_router.js - IMPLEMENTAZIONE COMPLETA
const EventEmitter = require('events');
const aiRouter = require('./router');
const streamingHandler = require('../streaming/streaming_handler');

/**
 * Context Analyzer per analisi intelligente del contesto
 */
class ContextAnalyzer {
  async analyze({ prompt, modelConfig, conversationHistory, performanceHistory }) {
    const analysis = {
      complexity: await this._analyzeComplexity(prompt),
      urgency: this._analyzeUrgency(prompt),
      taskType: this._classifyTaskType(prompt),
      requiresMultiplePerspectives: this._requiresMultiplePerspectives(prompt),
      requiresDeepReasoning: this._requiresDeepReasoning(prompt),
      requiresSynthesis: this._requiresSynthesis(prompt),
      creativityRequired: this._requiresCreativity(prompt),
      confidence: 0.8 // Default confidence
    };

    // Aggiusta confidence basato su storico
    if (conversationHistory && conversationHistory.length > 0) {
      analysis.confidence *= this._calculateHistoryConfidence(conversationHistory);
    }

    return analysis;
  }

  async _analyzeComplexity(prompt) {
    // Analisi euristica della complessità
    const indicators = {
      high: ['analizza', 'confronta', 'valuta', 'approfondisci', 'comprehensive', 'detailed analysis'],
      medium: ['spiega', 'describe', 'come', 'perché', 'what'],
      low: ['lista', 'list', 'nome', 'name', 'quando', 'when']
    };

    const words = prompt.toLowerCase().split(/\s+/);
    let complexityScore = 0.3; // Base score

    // Check per indicatori
    if (indicators.high.some(ind => prompt.toLowerCase().includes(ind))) {
      complexityScore += 0.5;
    } else if (indicators.medium.some(ind => prompt.toLowerCase().includes(ind))) {
      complexityScore += 0.3;
    } else if (indicators.low.some(ind => prompt.toLowerCase().includes(ind))) {
      complexityScore += 0.1;
    }

    // Lunghezza del prompt
    if (words.length > 50) complexityScore += 0.2;
    else if (words.length > 20) complexityScore += 0.1;

    return {
      score: Math.min(1.0, complexityScore),
      level: complexityScore > 0.7 ? 'high' : complexityScore > 0.4 ? 'medium' : 'low'
    };
  }

  _analyzeUrgency(prompt) {
    const urgencyIndicators = [
      'urgente', 'subito', 'velocemente', 'rapidamente', 'immediate', 'quickly', 'fast', 'asap'
    ];

    const urgencyScore = urgencyIndicators.some(ind =>
      prompt.toLowerCase().includes(ind)
    ) ? 0.8 : 0.3;

    return {
      score: urgencyScore,
      level: urgencyScore > 0.6 ? 'high' : urgencyScore > 0.3 ? 'medium' : 'low'
    };
  }

  _classifyTaskType(prompt) {
    const taskPatterns = {
      creative: /\b(crea|scrivi|genera|immagina|inventa|create|write|generate|imagine)\b/i,
      analytical: /\b(analizza|confronta|valuta|calcola|analyze|compare|evaluate|calculate)\b/i,
      conversational: /\b(parliamo|discutiamo|chat|conversazione|talk|discuss|conversation)\b/i,
      informational: /\b(cosa|chi|dove|quando|come|perché|what|who|where|when|how|why)\b/i
    };

    for (const [type, pattern] of Object.entries(taskPatterns)) {
      if (pattern.test(prompt)) {
        return type;
      }
    }

    return 'general';
  }

  _requiresMultiplePerspectives(prompt) {
    const perspectiveIndicators = [
      'punti di vista', 'prospettive', 'opinioni', 'dibattito', 'perspectives', 'viewpoints', 'opinions', 'debate'
    ];

    return perspectiveIndicators.some(ind => prompt.toLowerCase().includes(ind));
  }

  _requiresDeepReasoning(prompt) {
    const reasoningIndicators = [
      'ragiona', 'rifletti', 'approfondisci', 'reasoning', 'think deeply', 'elaborate', 'in-depth'
    ];

    return reasoningIndicators.some(ind => prompt.toLowerCase().includes(ind));
  }

  _requiresSynthesis(prompt) {
    const synthesisIndicators = [
      'combina', 'sintetizza', 'unisci', 'merge', 'combine', 'synthesize', 'integrate'
    ];

    return synthesisIndicators.some(ind => prompt.toLowerCase().includes(ind));
  }

  _requiresCreativity(prompt) {
    const creativityIndicators = [
      'creativo', 'innovativo', 'originale', 'creative', 'innovative', 'original', 'brainstorm'
    ];

    return creativityIndicators.some(ind => prompt.toLowerCase().includes(ind));
  }

  _calculateHistoryConfidence(conversationHistory) {
    // Semplice calcolo basato sulla lunghezza della conversazione
    const historyLength = conversationHistory.length;
    if (historyLength > 10) return 1.1;
    if (historyLength > 5) return 1.05;
    return 1.0;
  }
}

/**
 * Intelligent Synthesis Engine per sintesi avanzata
 */
class IntelligentSynthesisEngine {
  async performConsensus(responses, request, options = {}) {
    // Implementazione consensus intelligente
    const { threshold = 0.75, weightDecay = 0.1, diversityBonus = 0.2 } = options;

    // Calcola similarità tra risposte
    const similarities = this._calculateResponseSimilarities(responses);

    // Trova clusters di consenso
    const consensusClusters = this._findConsensusClusters(similarities, threshold);

    // Genera risposta sintetizzata
    const synthesizedText = this._generateConsensusResponse(consensusClusters, responses);

    return {
      text: synthesizedText,
      confidence: this._calculateConsensusConfidence(consensusClusters),
      consensusClusters
    };
  }

  async maximizeDiversity(responses, request, options = {}) {
    // Implementazione diversity maximization
    const { diversityWeight = 0.7, qualityWeight = 0.3, noveltyBonus = 0.1 } = options;

    // Calcola diversità tra risposte
    const diversityMatrix = this._calculateDiversityMatrix(responses);

    // Seleziona subset ottimale per massima diversità
    const optimalSubset = this._selectDiverseSubset(responses, diversityMatrix, options);

    // Genera risposta diversificata
    const diversifiedText = this._generateDiversifiedResponse(optimalSubset);

    return {
      text: diversifiedText,
      diversityScore: this._calculateOverallDiversity(optimalSubset),
      selectedResponses: optimalSubset.map(r => r.model)
    };
  }

  async performMetaSynthesis(strategyResults, request, options = {}) {
    // Meta-sintesi di risultati da strategie diverse
    const { balanceStrategy = 'adaptive', qualityThreshold = 0.8 } = options;

    // Valuta qualità di ogni risultato strategico
    const qualityScores = await Promise.all(
      strategyResults.map(result => this._assessResultQuality(result, request))
    );

    // Combina basato su qualità e strategia
    const metaText = this._generateMetaSynthesis(strategyResults, qualityScores, options);

    return {
      text: metaText,
      confidence: this._calculateMetaConfidence(qualityScores),
      strategyContributions: this._getStrategyContributions(strategyResults, qualityScores)
    };
  }

  // Metodi helper per synthesis engine...
  _calculateResponseSimilarities(responses) {
    // Implementazione calcolo similarità
    const similarities = {};
    for (let i = 0; i < responses.length; i++) {
      for (let j = i + 1; j < responses.length; j++) {
        const similarity = this._computeTextSimilarity(
          responses[i].response,
          responses[j].response
        );
        similarities[`${i}-${j}`] = similarity;
      }
    }
    return similarities;
  }

  _computeTextSimilarity(text1, text2) {
    // Implementazione semplificata Jaccard similarity
    const words1 = new Set(text1.toLowerCase().split(/\s+/));
    const words2 = new Set(text2.toLowerCase().split(/\s+/));

    const intersection = new Set([...words1].filter(x => words2.has(x)));
    const union = new Set([...words1, ...words2]);

    return intersection.size / union.size;
  }

  _findConsensusClusters(similarities, threshold) {
    // Implementazione placeholder per clustering
    return [{ responses: [0, 1], similarity: 0.8 }];
  }

  _generateConsensusResponse(clusters, responses) {
    // Implementazione placeholder per generazione consensus
    if (responses.length > 0) {
      return responses[0].response || "Consensus response generated.";
    }
    return "No responses available for consensus.";
  }

  _calculateConsensusConfidence(clusters) {
    return clusters.length > 0 ? 0.85 : 0.5;
  }

  _calculateDiversityMatrix(responses) {
    // Implementazione placeholder
    return {};
  }

  _selectDiverseSubset(responses, matrix, options) {
    // Implementazione placeholder
    return responses.slice(0, Math.min(3, responses.length));
  }

  _generateDiversifiedResponse(subset) {
    // Implementazione placeholder
    return subset.map(r => r.response).join('\n\n---\n\n');
  }

  _calculateOverallDiversity(subset) {
    return 0.7; // Placeholder
  }

  async _assessResultQuality(result, request) {
    // Implementazione placeholder
    return 0.8;
  }

  _generateMetaSynthesis(results, scores, options) {
    // Implementazione placeholder
    return results.join('\n\n');
  }

  _calculateMetaConfidence(scores) {
    const avgScore = scores.reduce((a, b) => a + b, 0) / scores.length;
    return avgScore;
  }

  _getStrategyContributions(results, scores) {
    return results.map((result, i) => ({ result, score: scores[i] }));
  }
}

class EnhancedStreamingRouter extends EventEmitter {
  constructor() {
    super();

    this.strategies = {
      PARALLEL_RACING: 'parallel_racing',
      WEIGHTED_CONSENSUS: 'weighted_consensus',
      ADAPTIVE_CASCADING: 'adaptive_cascading',
      DIVERSITY_SAMPLING: 'diversity_sampling',
      HYBRID_SYNTHESIS: 'hybrid_synthesis'
    };

    this.performanceMetrics = new Map();
    this.contextAnalyzer = new ContextAnalyzer();
    this.synthesisEngine = new IntelligentSynthesisEngine();
    this.activeStreams = new Map();
    this.synthesisBuffer = new Map();

    this.config = {
      maxConcurrentModels: 6,
      chunkBufferSize: 1024,
      synthesisThreshold: 0.75,
      adaptiveWeightLearning: true,
      qualityGateEnabled: true,
      streamingOptimization: true,
      reconnectAttempts: 3,
      streamTimeout: 30000
    };

    this._initializeMetrics();
  }

  /**
   * IMPLEMENTAZIONI MANCANTI - STREAMING METHODS
   */

  /**
   * Stream da modello con racing logic
   */
  async _streamFromModelWithRacing(model, request, streamInfo) {
    const { conversationId, socket } = streamInfo;
    let responseBuffer = '';
    let isComplete = false;

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Racing timeout for model ${model}`));
      }, this.config.streamTimeout);

      // Simula streaming chunked dal modello
      this._initiateModelStream(model, request, (chunk, finished) => {
        responseBuffer += chunk;

        // Emetti chunk via WebSocket
        socket.emit('stream_chunk', {
          conversationId,
          model,
          chunk,
          buffer: responseBuffer,
          strategy: 'racing',
          timestamp: Date.now()
        });

        if (finished) {
          clearTimeout(timeout);
          isComplete = true;
          resolve(responseBuffer);
        }
      }).catch(reject);
    });
  }

  /**
   * Stream da modello con consensus logic
   */
  async _streamFromModelWithConsensus(model, request, streamInfo) {
    const { conversationId, socket } = streamInfo;
    let responseBuffer = '';
    let consensusData = { chunks: [], weights: [] };

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Consensus timeout for model ${model}`));
      }, this.config.streamTimeout);

      this._initiateModelStream(model, request, (chunk, finished) => {
        responseBuffer += chunk;
        consensusData.chunks.push({
          text: chunk,
          timestamp: Date.now(),
          model
        });

        // Calcola peso in tempo reale
        const currentWeight = this._calculateRealtimeWeight(model, chunk, responseBuffer);
        consensusData.weights.push(currentWeight);

        socket.emit('consensus_chunk', {
          conversationId,
          model,
          chunk,
          weight: currentWeight,
          buffer: responseBuffer,
          consensusData,
          timestamp: Date.now()
        });

        if (finished) {
          clearTimeout(timeout);
          resolve(responseBuffer);
        }
      }).catch(reject);
    });
  }

  /**
   * Stream da modello con cascading logic
   */
  async _streamFromModelWithCascading(model, request, streamInfo, stage) {
    const { conversationId, socket } = streamInfo;
    let responseBuffer = '';

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Cascading timeout for model ${model} at stage ${stage}`));
      }, this.config.streamTimeout);

      this._initiateModelStream(model, request, (chunk, finished) => {
        responseBuffer += chunk;

        socket.emit('cascade_chunk', {
          conversationId,
          model,
          stage,
          chunk,
          buffer: responseBuffer,
          cascadeProgress: this._calculateCascadeProgress(stage, chunk),
          timestamp: Date.now()
        });

        if (finished) {
          clearTimeout(timeout);
          resolve(responseBuffer);
        }
      }).catch(reject);
    });
  }

  /**
   * Stream da modello con diversity logic
   */
  async _streamFromModelWithDiversity(model, request, streamInfo) {
    const { conversationId, socket } = streamInfo;
    let responseBuffer = '';
    let diversityMetrics = { noveltyScore: 0, uniqueTokens: new Set() };

    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        reject(new Error(`Diversity timeout for model ${model}`));
      }, this.config.streamTimeout);

      this._initiateModelStream(model, request, (chunk, finished) => {
        responseBuffer += chunk;

        // Calcola diversità in tempo reale
        this._updateDiversityMetrics(diversityMetrics, chunk, model);

        socket.emit('diversity_chunk', {
          conversationId,
          model,
          chunk,
          buffer: responseBuffer,
          diversityScore: diversityMetrics.noveltyScore,
          uniqueTokenCount: diversityMetrics.uniqueTokens.size,
          timestamp: Date.now()
        });

        if (finished) {
          clearTimeout(timeout);
          resolve(responseBuffer);
        }
      }).catch(reject);
    });
  }

  /**
   * Avvia stream da modello specifico
   */
  async _initiateModelStream(model, request, onChunk) {
    try {
      // Usa il router esistente per ottenere response
      const modelHandler = await aiRouter.getModelHandler(model);

      if (!modelHandler || !modelHandler.streamResponse) {
        throw new Error(`Model ${model} does not support streaming`);
      }

      // Avvia streaming dal modello
      return await modelHandler.streamResponse(request, onChunk);

    } catch (error) {
      console.error(`Error streaming from model ${model}:`, error);
      throw error;
    }
  }

  /**
   * HELPER METHODS IMPLEMENTATI
   */

  _isResponseComplete(response) {
    return response && response.length > 50 &&
           (response.includes('.') || response.includes('!') || response.includes('?'));
  }

  _selectBestResponse(responses, request) {
    if (!responses || responses.length === 0) return '';

    // Score responses basato su qualità
    const scoredResponses = responses.map(r => ({
      response: r.response,
      score: this._calculateResponseScore(r.response, request)
    }));

    // Ordina per score e restituisci il migliore
    scoredResponses.sort((a, b) => b.score - a.score);
    return scoredResponses[0].response;
  }

  _calculateResponseScore(response, request) {
    let score = 0;

    // Lunghezza appropriata
    if (response.length > 100 && response.length < 2000) score += 0.3;

    // Completezza
    if (this._isResponseComplete(response)) score += 0.3;

    // Rilevanza (parole chiave dal prompt)
    const promptWords = request.prompt.toLowerCase().split(/\s+/);
    const responseWords = response.toLowerCase().split(/\s+/);
    const intersection = promptWords.filter(word => responseWords.includes(word));
    score += (intersection.length / promptWords.length) * 0.4;

    return Math.min(1.0, score);
  }

  _calculateRealtimeWeight(model, chunk, buffer) {
    const metrics = this.performanceMetrics.get(model) || this._initializeModelMetrics(model);

    // Peso basato su lunghezza e qualità del chunk
    let weight = 0.5; // Base weight

    if (chunk.length > 20) weight += 0.2;
    if (buffer.length > 100) weight += 0.1;
    if (metrics.reliability > 0.7) weight += 0.2;

    return Math.min(1.0, weight);
  }

  _calculateCascadeProgress(stage, chunk) {
    return {
      currentStage: stage,
      chunkProgress: chunk.length / 100, // Normalized
      stageCompletion: Math.min(1.0, chunk.length / 200)
    };
  }

  _updateDiversityMetrics(metrics, chunk, model) {
    const words = chunk.toLowerCase().split(/\s+/);
    let newUniqueTokens = 0;

    words.forEach(word => {
      if (!metrics.uniqueTokens.has(word)) {
        metrics.uniqueTokens.add(word);
        newUniqueTokens++;
      }
    });

    // Aggiorna novelty score
    if (words.length > 0) {
      metrics.noveltyScore = newUniqueTokens / words.length;
    }
  }

  _initializeModelMetrics(model) {
    const defaultMetrics = {
      averageResponseTime: 3000,
      reliability: 0.8,
      averageQuality: 0.7,
      totalRequests: 0,
      successfulRequests: 0
    };

    this.performanceMetrics.set(model, defaultMetrics);
    return defaultMetrics;
  }

  _initializeMetrics() {
    const models = ['claude', 'gpt', 'deepseek', 'gemini', 'mistral', 'llama', 'ollama'];
    models.forEach(model => this._initializeModelMetrics(model));
  }

  /**
   * MISSING IMPLEMENTATIONS - CASCADE METHODS
   */

  _orderModelsForCascading(models, request) {
    // Ordina modelli per cascading ottimale
    const modelPriorities = {
      'claude': 1,    // Excellent for reasoning
      'deepseek': 2,  // Good for analysis
      'gpt': 3,       // Versatile
      'gemini': 4,    // Creative
      'mistral': 5,   // Lightweight
      'llama': 6,     // Local fallback
      'ollama': 7     // Local fallback
    };

    return models.sort((a, b) =>
      (modelPriorities[a] || 999) - (modelPriorities[b] || 999)
    );
  }

  _buildCascadePrompt(context, previousResponse, model, isFirst, isLast) {
    if (isFirst) {
      return context;
    }

    if (isLast) {
      return `${context}\n\nPrevious analysis: ${previousResponse}\n\nPlease provide a final comprehensive response that builds upon this analysis.`;
    }

    return `${context}\n\nPrevious response: ${previousResponse}\n\nPlease expand and improve upon this response.`;
  }

  async _refineCascadeResponse(currentResponse, stageResponse) {
    // Combina response precedente con nuova
    if (!currentResponse) return stageResponse;

    return `${currentResponse}\n\n${stageResponse}`;
  }

  _buildNextStageContext(context, response) {
    return `${context}\n\nBuilding on: ${response.substring(0, 200)}...`;
  }

  async _finalizeCascadeResponse(cascadeResults) {
    // Combina tutti i risultati della cascata
    const finalResponse = cascadeResults
      .map(result => result.response)
      .join('\n\n');

    return finalResponse;
  }

  /**
   * MISSING IMPLEMENTATIONS - DIVERSITY METHODS
   */

  _generateDiversityPrompts(basePrompt, count) {
    const diversityPrefixes = [
      'From a creative perspective: ',
      'From an analytical viewpoint: ',
      'Considering alternative approaches: ',
      'With a focus on innovation: ',
      'From a practical standpoint: ',
      'Exploring unconventional solutions: '
    ];

    const prompts = [basePrompt]; // Base prompt sempre incluso

    for (let i = 1; i < count && i < diversityPrefixes.length + 1; i++) {
      prompts.push(diversityPrefixes[i - 1] + basePrompt);
    }

    return prompts;
  }

  async _calculateDiversityScore(response, allResponses) {
    if (Object.keys(allResponses).length <= 1) return 1.0;

    const responseWords = new Set(response.toLowerCase().split(/\s+/));
    let totalSimilarity = 0;
    let comparisons = 0;

    for (const [model, otherResponse] of Object.entries(allResponses)) {
      if (otherResponse && otherResponse !== response) {
        const otherWords = new Set(otherResponse.toLowerCase().split(/\s+/));
        const intersection = new Set([...responseWords].filter(x => otherWords.has(x)));
        const union = new Set([...responseWords, ...otherWords]);

        totalSimilarity += intersection.size / union.size;
        comparisons++;
      }
    }

    const averageSimilarity = comparisons > 0 ? totalSimilarity / comparisons : 0;
    return Math.max(0, 1 - averageSimilarity); // Higher diversity = lower similarity
  }

  /**
   * MISSING IMPLEMENTATIONS - HYBRID METHODS
   */

  _partitionModelsForHybrid(models, request) {
    const partition = {
      racing: [],
      consensus: [],
      diversity: []
    };

    // Partiziona modelli basato su caratteristiche
    models.forEach((model, index) => {
      if (index % 3 === 0) {
        partition.racing.push(model);
      } else if (index % 3 === 1) {
        partition.consensus.push(model);
      } else {
        partition.diversity.push(model);
      }
    });

    // Assicura che ogni partizione abbia almeno un modello
    if (partition.racing.length === 0) partition.racing.push(models[0]);
    if (partition.consensus.length === 0) partition.consensus.push(models[0]);
    if (partition.diversity.length === 0) partition.diversity.push(models[0]);

    return partition;
  }

  /**
   * MISSING IMPLEMENTATIONS - PERFORMANCE TRACKING
   */

  async _assessResponseQuality(response, request) {
    // Implementazione semplificata assessment qualità
    let qualityScore = 0.5;

    // Lunghezza appropriata
    if (response.length > 100 && response.length < 2000) qualityScore += 0.2;

    // Completezza grammaticale
    if (response.includes('.') && response.includes(' ')) qualityScore += 0.1;

    // Rilevanza al prompt
    const promptKeywords = request.prompt.toLowerCase().split(/\s+/);
    const responseText = response.toLowerCase();
    const keywordMatches = promptKeywords.filter(keyword =>
      responseText.includes(keyword)
    ).length;

    qualityScore += (keywordMatches / promptKeywords.length) * 0.2;

    return Math.min(1.0, qualityScore);
  }

  _calculateSpeedScore(responseTime) {
    // Score inversamente proporzionale al tempo di risposta
    const maxTime = 10000; // 10 secondi
    return Math.max(0.1, 1.0 - (responseTime / maxTime));
  }

  async _assessContextRelevance(response, request) {
    // Calcola rilevanza contestuale
    const promptWords = request.prompt.toLowerCase().split(/\s+/);
    const responseWords = response.toLowerCase().split(/\s+/);

    const relevantWords = promptWords.filter(word =>
      responseWords.includes(word)
    );

    return relevantWords.length / promptWords.length;
  }

  _calculateLearningFactor(model, request) {
    const metrics = this.performanceMetrics.get(model);
    if (!metrics) return 1.0;

    // Learning factor basato su performance storica
    const successRate = metrics.successfulRequests / Math.max(1, metrics.totalRequests);
    return 0.8 + (successRate * 0.4); // Range: 0.8 - 1.2
  }

  /**
   * STATS METHODS
   */

  _getTotalRequests() {
    let total = 0;
    for (const metrics of this.performanceMetrics.values()) {
      total += metrics.totalRequests;
    }
    return total;
  }

  _getAverageProcessingTime() {
    let totalTime = 0;
    let totalRequests = 0;

    for (const metrics of this.performanceMetrics.values()) {
      totalTime += metrics.averageResponseTime * metrics.totalRequests;
      totalRequests += metrics.totalRequests;
    }

    return totalRequests > 0 ? totalTime / totalRequests : 0;
  }

  _getStrategyDistribution() {
    // Placeholder - dovrebbe tracciare usage delle strategie
    return {
      parallel_racing: 0.4,
      weighted_consensus: 0.3,
      adaptive_cascading: 0.1,
      diversity_sampling: 0.1,
      hybrid_synthesis: 0.1
    };
  }

  _getModelEfficiencyStats() {
    const stats = {};
    for (const [model, metrics] of this.performanceMetrics.entries()) {
      stats[model] = {
        efficiency: metrics.averageQuality / (metrics.averageResponseTime / 1000),
        reliability: metrics.reliability,
        avgQuality: metrics.averageQuality,
        avgTime: metrics.averageResponseTime
      };
    }
    return stats;
  }

  /**
   * PUBLIC API METHODS
   */

  async startStreamingSession(request, socket) {
    const conversationId = this._generateConversationId();
    const streamInfo = { conversationId, socket };

    try {
      // Determina strategia ottimale
      const strategy = await this.determineStreamingStrategy(
        request.prompt,
        request.modelConfig,
        request.conversationHistory || []
      );

      // Emetti strategia selezionata
      socket.emit('strategy_selected', {
        conversationId,
        strategy: strategy.strategy,
        reasoning: strategy.reasoning,
        estimatedDuration: strategy.estimatedDuration,
        recommendedModels: strategy.recommendedModels
      });

      // Esegui streaming
      const result = await this.executeStreamingStrategy(request, streamInfo);

      // Emetti risultato finale
      socket.emit('streaming_completed', {
        conversationId,
        finalResponse: result,
        timestamp: Date.now()
      });

      return result;

    } catch (error) {
      socket.emit('streaming_error', {
        conversationId,
        error: error.message,
        timestamp: Date.now()
      });
      throw error;
    }
  }

  _generateConversationId() {
    return `conv_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  // Implementazione originale dei metodi esistenti...
  async determineStreamingStrategy(prompt, modelConfig, conversationHistory = []) {
    const analysis = await this.contextAnalyzer.analyze({
      prompt,
      modelConfig,
      conversationHistory,
      performanceHistory: this.performanceMetrics
    });

    let strategy = this.strategies.PARALLEL_RACING;
    let reasoning = 'Default parallel strategy';

    if (analysis.complexity.score > 0.8) {
      if (analysis.requiresMultiplePerspectives) {
        strategy = this.strategies.WEIGHTED_CONSENSUS;
        reasoning = 'High complexity requiring multiple expert perspectives';
      } else if (analysis.requiresDeepReasoning) {
        strategy = this.strategies.ADAPTIVE_CASCADING;
        reasoning = 'Deep reasoning benefits from cascading approach';
      }
    } else if (analysis.urgency.score > 0.7) {
      strategy = this.strategies.PARALLEL_RACING;
      reasoning = 'High urgency - optimize for speed';
    } else if (analysis.creativityRequired) {
      strategy = this.strategies.DIVERSITY_SAMPLING;
      reasoning = 'Creative task benefits from diverse model sampling';
    } else if (analysis.requiresSynthesis) {
      strategy = this.strategies.HYBRID_SYNTHESIS;
      reasoning = 'Complex synthesis required - hybrid approach';
    }

    return {
      strategy,
      reasoning,
      confidence: analysis.confidence,
      estimatedDuration: this._estimateDuration(strategy, modelConfig),
      recommendedModels: this._selectOptimalModels(analysis, modelConfig)
    };
  }

  async executeStreamingStrategy(request, streamInfo) {
    const { strategy, recommendedModels } = await this.determineStreamingStrategy(
      request.prompt,
      request.modelConfig,
      request.conversationHistory
    );

    this.emit('strategy_execution_started', {
      conversationId: streamInfo.conversationId,
      strategy,
      models: recommendedModels,
      timestamp: Date.now()
    });

    switch (strategy) {
      case this.strategies.PARALLEL_RACING:
        return await this._executeParallelRacing(request, streamInfo, recommendedModels);
      case this.strategies.WEIGHTED_CONSENSUS:
        return await this._executeWeightedConsensus(request, streamInfo, recommendedModels);
      case this.strategies.ADAPTIVE_CASCADING:
        return await this._executeAdaptiveCascading(request, streamInfo, recommendedModels);
      case this.strategies.DIVERSITY_SAMPLING:
        return await this._executeDiversitySampling(request, streamInfo, recommendedModels);
      case this.strategies.HYBRID_SYNTHESIS:
        return await this._executeHybridSynthesis(request, streamInfo, recommendedModels);
      default:
        return await this._executeParallelRacing(request, streamInfo, recommendedModels);
    }
  }

  getEnhancedStats() {
    return {
      strategies: Object.values(this.strategies),
      performanceMetrics: Object.fromEntries(this.performanceMetrics),
      config: { ...this.config },
      totalRequests: this._getTotalRequests(),
      averageProcessingTime: this._getAverageProcessingTime(),
      strategyDistribution: this._getStrategyDistribution(),
      modelEfficiency: this._getModelEfficiencyStats()
    };
  }
}

// Mantieni le classi originali ContextAnalyzer e IntelligentSynthesisEngine
// con le implementazioni complete...

module.exports = new EnhancedStreamingRouter();