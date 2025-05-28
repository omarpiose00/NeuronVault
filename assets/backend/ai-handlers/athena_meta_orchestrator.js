// 🧠 NEURONVAULT - ATHENA META-ORCHESTRATOR
// PHASE 3.4: Backend AI Autonomy Intelligence Layer
// Revolutionary meta-orchestration system that intelligently manages AI handlers

const logger = require('./base_handler').logger || console;

/**
 * 🧠 ATHENA META-ORCHESTRATOR
 * Advanced meta-orchestration system that analyzes prompts and intelligently
 * selects optimal AI models and strategies for superior results
 */
class AthenaMeta‌Orchestrator {
  constructor() {
    this.isInitialized = false;
    this.performanceHistory = new Map(); // Model performance tracking
    this.strategyHistory = new Map();     // Strategy performance tracking
    this.decisionTree = [];               // Decision tree for transparency
    this.analysisCache = new Map();       // Cache for prompt analysis
    this.maxCacheSize = 100;
    this.maxHistorySize = 1000;

    // 🎯 Model specialization profiles
    this.modelProfiles = {
      'claude': {
        reasoning: 0.95,
        creativity: 0.85,
        technical: 0.90,
        analysis: 0.95,
        writing: 0.90,
        coding: 0.85,
        math: 0.80,
        strengths: ['reasoning', 'analysis', 'writing', 'complex_tasks'],
        weaknesses: ['speed', 'code_generation']
      },
      'gpt': {
        reasoning: 0.85,
        creativity: 0.90,
        technical: 0.85,
        analysis: 0.80,
        writing: 0.88,
        coding: 0.90,
        math: 0.85,
        strengths: ['creativity', 'general_tasks', 'coding', 'versatility'],
        weaknesses: ['deep_reasoning', 'accuracy']
      },
      'deepseek': {
        reasoning: 0.80,
        creativity: 0.70,
        technical: 0.95,
        analysis: 0.85,
        writing: 0.75,
        coding: 0.95,
        math: 0.90,
        strengths: ['coding', 'technical_tasks', 'math', 'programming'],
        weaknesses: ['creativity', 'general_writing']
      },
      'gemini': {
        reasoning: 0.85,
        creativity: 0.85,
        technical: 0.80,
        analysis: 0.85,
        writing: 0.80,
        coding: 0.80,
        math: 0.85,
        strengths: ['multimodal', 'balanced_performance', 'integration'],
        weaknesses: ['specialization', 'consistency']
      },
      'mistral': {
        reasoning: 0.80,
        creativity: 0.75,
        technical: 0.85,
        analysis: 0.80,
        writing: 0.80,
        coding: 0.85,
        math: 0.80,
        strengths: ['efficiency', 'focused_tasks', 'consistency'],
        weaknesses: ['creativity', 'complex_reasoning']
      }
    };

    // 🎯 Strategy profiles
    this.strategyProfiles = {
      'parallel': {
        speed: 0.95,
        diversity: 0.90,
        cost: 0.60,
        best_for: ['simple_tasks', 'speed_priority', 'exploration']
      },
      'consensus': {
        speed: 0.70,
        reliability: 0.95,
        cost: 0.40,
        best_for: ['critical_decisions', 'accuracy_priority', 'validation']
      },
      'weighted': {
        speed: 0.80,
        customization: 0.95,
        cost: 0.70,
        best_for: ['specialized_tasks', 'known_preferences', 'optimization']
      },
      'adaptive': {
        speed: 0.75,
        intelligence: 0.90,
        cost: 0.60,
        best_for: ['complex_tasks', 'learning_systems', 'dynamic_content']
      },
      'sequential': {
        speed: 0.60,
        depth: 0.95,
        cost: 0.50,
        best_for: ['iterative_improvement', 'building_context', 'refinement']
      }
    };

    this.initialize();
  }

  /**
   * 🚀 Initialize Athena Meta-Orchestrator
   */
  async initialize() {
    try {
      logger.info('🧠 Initializing Athena Meta-Orchestrator...');

      // Load historical performance data
      await this.loadPerformanceHistory();

      // Initialize decision tree
      this.decisionTree = [];

      // Set default performance scores
      this.initializeDefaultScores();

      this.isInitialized = true;

      logger.info('✅ Athena Meta-Orchestrator initialized successfully');
      logger.info(`📊 Tracking ${this.performanceHistory.size} models`);
      logger.info(`🎯 ${Object.keys(this.strategyProfiles).length} strategies available`);

    } catch (error) {
      logger.error('❌ Failed to initialize Athena Meta-Orchestrator:', error);
      this.isInitialized = false;
    }
  }

  /**
   * 🎯 ANALYZE PROMPT AND GENERATE INTELLIGENT RECOMMENDATIONS
   * Main meta-orchestration method
   */
  async analyzeAndRecommend(prompt, currentModels = [], currentStrategy = 'parallel', options = {}) {
    try {
      if (!this.isInitialized) {
        throw new Error('Athena Meta-Orchestrator not initialized');
      }

      logger.info(`🧠 Athena analyzing prompt: "${prompt.substring(0, 50)}..."`);
      const startTime = Date.now();

      // Step 1: Check cache
      const cacheKey = this.generateCacheKey(prompt);
      if (this.analysisCache.has(cacheKey)) {
        logger.debug('💾 Using cached analysis');
        return this.analysisCache.get(cacheKey);
      }

      // Step 2: Analyze prompt characteristics
      const analysis = await this.analyzePromptCharacteristics(prompt);

      // Step 3: Score models based on analysis
      const modelScores = this.scoreModelsForPrompt(analysis);

      // Step 4: Select optimal strategy
      const optimalStrategy = this.selectOptimalStrategy(analysis, modelScores);

      // Step 5: Generate model recommendations
      const recommendedModels = this.selectOptimalModels(modelScores, analysis);

      // Step 6: Calculate confidence and generate reasoning
      const confidence = this.calculateRecommendationConfidence(analysis, modelScores, optimalStrategy);
      const reasoning = this.generateRecommendationReasoning(analysis, recommendedModels, optimalStrategy);

      // Step 7: Create recommendation object
      const recommendation = {
        recommendedModels,
        recommendedStrategy: optimalStrategy,
        modelScores,
        modelWeights: this.generateModelWeights(modelScores),
        confidence,
        reasoning,
        analysis,
        estimatedTime: this.estimateProcessingTime(analysis, recommendedModels, optimalStrategy),
        metadata: {
          promptLength: prompt.length,
          analysisTime: Date.now() - startTime,
          cacheUsed: false,
          athenaVersion: '3.4',
          timestamp: new Date().toISOString()
        },
        decisionTree: this.generateDecisionTree(analysis, modelScores, optimalStrategy)
      };

      // Step 8: Cache the recommendation
      this.cacheRecommendation(cacheKey, recommendation);

      // Step 9: Log recommendation
      logger.info('✅ Athena recommendation generated successfully');
      logger.info(`🎯 Recommended models: ${recommendedModels.join(', ')}`);
      logger.info(`📊 Strategy: ${optimalStrategy}`);
      logger.info(`🔮 Confidence: ${Math.round(confidence * 100)}%`);
      logger.debug(`⏱️ Analysis time: ${Date.now() - startTime}ms`);

      return recommendation;

    } catch (error) {
      logger.error('❌ Athena analysis failed:', error);
      return this.generateFallbackRecommendation(prompt, currentModels, currentStrategy);
    }
  }

  /**
   * 🔍 ANALYZE PROMPT CHARACTERISTICS
   * Advanced prompt analysis using heuristics and pattern recognition
   */
  async analyzePromptCharacteristics(prompt) {
    const promptLower = prompt.toLowerCase();
    const words = promptLower.split(/\W+/).filter(word => word.length > 2);
    const sentences = prompt.split(/[.!?]+/).filter(s => s.trim().length > 0);

    // 🎨 Analyze creativity requirements
    const creativityIndicators = [
      'creative', 'imagine', 'story', 'write', 'design', 'art', 'poem', 'novel',
      'brainstorm', 'innovative', 'original', 'unique', 'artistic'
    ];
    const creativityScore = this.calculateIndicatorScore(words, creativityIndicators);

    // 🔧 Analyze technical depth
    const technicalIndicators = [
      'code', 'function', 'algorithm', 'debug', 'api', 'database', 'programming',
      'technical', 'implement', 'architecture', 'system', 'software', 'development'
    ];
    const technicalScore = this.calculateIndicatorScore(words, technicalIndicators);

    // 🧮 Analyze reasoning complexity
    const reasoningIndicators = [
      'analyze', 'compare', 'explain', 'why', 'how', 'evaluate', 'assess',
      'reason', 'logic', 'prove', 'demonstrate', 'conclude', 'infer'
    ];
    const reasoningScore = this.calculateIndicatorScore(words, reasoningIndicators);

    // 📝 Analyze writing requirements
    const writingIndicators = [
      'write', 'essay', 'report', 'article', 'document', 'letter', 'email',
      'content', 'blog', 'copy', 'text', 'paragraph', 'summary'
    ];
    const writingScore = this.calculateIndicatorScore(words, writingIndicators);

    // 🔢 Analyze mathematical content
    const mathIndicators = [
      'calculate', 'equation', 'formula', 'math', 'number', 'solve', 'compute',
      'statistics', 'probability', 'algebra', 'geometry', 'calculus'
    ];
    const mathScore = this.calculateIndicatorScore(words, mathIndicators);

    // 🎯 Determine prompt type
    let promptType = 'general';
    const scores = { technical: technicalScore, creative: creativityScore, reasoning: reasoningScore, writing: writingScore, math: mathScore };
    const maxScore = Math.max(...Object.values(scores));

    if (maxScore > 0.3) {
      promptType = Object.keys(scores).find(key => scores[key] === maxScore);
    }
    if (creativityScore > 0.2 && technicalScore > 0.2) promptType = 'mixed';

    // 📊 Determine complexity
    let complexity = 'medium';
    if (words.length < 10) complexity = 'simple';
    else if (words.length > 50) complexity = 'complex';
    else if (words.length > 100 || sentences.length > 10) complexity = 'expert';

    // 🔍 Extract key topics
    const keyTopics = this.extractKeyTopics(words);

    return {
      promptType,
      complexity,
      creativity: creativityScore,
      technical: technicalScore,
      reasoning: reasoningScore,
      writing: writingScore,
      math: mathScore,
      length: prompt.length,
      wordCount: words.length,
      sentenceCount: sentences.length,
      keyTopics,
      urgency: this.detectUrgency(promptLower),
      quality: this.detectQualityRequirements(promptLower)
    };
  }

  /**
   * 📊 SCORE MODELS FOR PROMPT
   * Calculate optimal model scores based on prompt analysis
   */
  scoreModelsForPrompt(analysis) {
    const scores = {};

    for (const [modelName, profile] of Object.entries(this.modelProfiles)) {
      let score = 0;

      // Base capability scoring
      score += profile.creativity * analysis.creativity * 0.25;
      score += profile.technical * analysis.technical * 0.25;
      score += profile.reasoning * analysis.reasoning * 0.25;
      score += profile.writing * analysis.writing * 0.15;
      score += profile.math * analysis.math * 0.10;

      // Prompt type bonus
      switch (analysis.promptType) {
        case 'creative':
          score += profile.creativity * 0.2;
          break;
        case 'technical':
          score += profile.technical * 0.2;
          break;
        case 'reasoning':
          score += profile.reasoning * 0.2;
          break;
        case 'writing':
          score += profile.writing * 0.2;
          break;
        case 'math':
          score += profile.math * 0.2;
          break;
      }

      // Complexity adjustment
      if (analysis.complexity === 'expert' && profile.reasoning > 0.85) {
        score += 0.1;
      }
      if (analysis.complexity === 'simple' && modelName === 'mistral') {
        score += 0.1; // Mistral is efficient for simple tasks
      }

      // Historical performance adjustment
      const historicalScore = this.getModelHistoricalScore(modelName);
      score = (score * 0.8) + (historicalScore * 0.2);

      scores[modelName] = Math.max(0, Math.min(1, score));
    }

    return scores;
  }

  /**
   * 🎯 SELECT OPTIMAL STRATEGY
   * Choose the best orchestration strategy based on analysis
   */
  selectOptimalStrategy(analysis, modelScores) {
    const strategyScores = {};

    for (const [strategyName, profile] of Object.entries(this.strategyProfiles)) {
      let score = 0;

      // Base scoring based on prompt characteristics
      switch (analysis.complexity) {
        case 'simple':
          if (strategyName === 'parallel') score += 0.3;
          break;
        case 'medium':
          if (strategyName === 'adaptive' || strategyName === 'weighted') score += 0.3;
          break;
        case 'complex':
          if (strategyName === 'consensus' || strategyName === 'sequential') score += 0.3;
          break;
        case 'expert':
          if (strategyName === 'sequential' || strategyName === 'consensus') score += 0.4;
          break;
      }

      // Prompt type considerations
      switch (analysis.promptType) {
        case 'creative':
          if (strategyName === 'parallel' || strategyName === 'weighted') score += 0.2;
          break;
        case 'technical':
          if (strategyName === 'sequential' || strategyName === 'consensus') score += 0.2;
          break;
        case 'reasoning':
          if (strategyName === 'consensus' || strategyName === 'adaptive') score += 0.2;
          break;
      }

      // Urgency considerations
      if (analysis.urgency > 0.7) {
        if (strategyName === 'parallel') score += 0.2;
        if (strategyName === 'sequential') score -= 0.2;
      }

      // Quality requirements
      if (analysis.quality > 0.8) {
        if (strategyName === 'consensus') score += 0.2;
        if (strategyName === 'parallel') score -= 0.1;
      }

      // Historical performance
      const historicalScore = this.getStrategyHistoricalScore(strategyName);
      score = (score * 0.8) + (historicalScore * 0.2);

      strategyScores[strategyName] = Math.max(0, score);
    }

    // Return the highest scoring strategy
    return Object.keys(strategyScores).reduce((a, b) =>
      strategyScores[a] > strategyScores[b] ? a : b
    );
  }

  /**
   * 🏆 SELECT OPTIMAL MODELS
   * Choose the best models based on scores and constraints
   */
  selectOptimalModels(modelScores, analysis, maxModels = 4) {
    // Sort models by score
    const rankedModels = Object.entries(modelScores)
      .sort(([,a], [,b]) => b - a)
      .map(([name]) => name);

    // Apply selection logic based on complexity and type
    let selectedCount = 3; // Default

    switch (analysis.complexity) {
      case 'simple':
        selectedCount = 2;
        break;
      case 'expert':
        selectedCount = Math.min(maxModels, 4);
        break;
    }

    // Ensure diversity in selection
    const selected = [];
    const categories = { reasoning: [], creative: [], technical: [] };

    // Categorize models
    for (const modelName of rankedModels) {
      const profile = this.modelProfiles[modelName];
      if (profile.reasoning > 0.9) categories.reasoning.push(modelName);
      if (profile.creativity > 0.85) categories.creative.push(modelName);
      if (profile.technical > 0.9) categories.technical.push(modelName);
    }

    // Select top models ensuring diversity
    for (const modelName of rankedModels) {
      if (selected.length >= selectedCount) break;

      // Always include highest scoring models
      if (selected.length < 2 || modelScores[modelName] > 0.7) {
        selected.push(modelName);
      }
    }

    return selected;
  }

  /**
   * 📊 GENERATE MODEL WEIGHTS
   * Create optimal model weights based on scores
   */
  generateModelWeights(modelScores) {
    const weights = {};
    const totalScore = Object.values(modelScores).reduce((sum, score) => sum + score, 0);

    for (const [modelName, score] of Object.entries(modelScores)) {
      weights[modelName] = totalScore > 0 ? score / totalScore : 1.0 / Object.keys(modelScores).length;
    }

    return weights;
  }

  /**
   * 🔮 CALCULATE RECOMMENDATION CONFIDENCE
   * Determine confidence level for the recommendation
   */
  calculateRecommendationConfidence(analysis, modelScores, strategy) {
    let confidence = 0.5; // Base confidence

    // Increase confidence based on clear indicators
    const maxModelScore = Math.max(...Object.values(modelScores));
    if (maxModelScore > 0.8) confidence += 0.2;
    if (maxModelScore > 0.9) confidence += 0.1;

    // Complexity confidence adjustment
    switch (analysis.complexity) {
      case 'simple':
        confidence += 0.2;
        break;
      case 'expert':
        confidence -= 0.1;
        break;
    }

    // Clear prompt type increases confidence
    if (['creative', 'technical', 'reasoning'].includes(analysis.promptType)) {
      confidence += 0.1;
    }

    // Historical success rate for strategy
    const strategySuccess = this.getStrategyHistoricalScore(strategy);
    confidence = (confidence * 0.8) + (strategySuccess * 0.2);

    return Math.max(0.3, Math.min(1.0, confidence));
  }

  /**
   * 📝 GENERATE RECOMMENDATION REASONING
   * Create human-readable explanation for the recommendation
   */
  generateRecommendationReasoning(analysis, models, strategy) {
    let reasoning = `Athena Intelligence Analysis: `;

    // Describe the prompt
    reasoning += `This ${analysis.complexity} ${analysis.promptType} prompt `;

    if (analysis.creativity > 0.7) reasoning += `requires high creativity, `;
    if (analysis.technical > 0.7) reasoning += `demands technical expertise, `;
    if (analysis.reasoning > 0.7) reasoning += `needs complex reasoning, `;
    if (analysis.writing > 0.7) reasoning += `involves substantial writing, `;
    if (analysis.math > 0.7) reasoning += `includes mathematical content, `;

    // Explain model selection
    reasoning += `so I selected ${models.length} optimal models: `;

    models.forEach((model, index) => {
      const profile = this.modelProfiles[model];
      reasoning += `${model.toUpperCase()} (${profile.strengths.slice(0, 2).join(', ')})`;
      if (index < models.length - 1) reasoning += ', ';
    });

    // Explain strategy
    reasoning += `. Using ${strategy} strategy `;
    const strategyProfile = this.strategyProfiles[strategy];
    reasoning += `optimized for ${strategyProfile.best_for.slice(0, 2).join(' and ')}.`;

    return reasoning;
  }

  /**
   * ⏱️ ESTIMATE PROCESSING TIME
   * Predict how long the orchestration will take
   */
  estimateProcessingTime(analysis, models, strategy) {
    let baseTime = 2000; // Base 2 seconds

    // Complexity adjustment
    switch (analysis.complexity) {
      case 'simple':
        baseTime *= 0.7;
        break;
      case 'complex':
        baseTime *= 1.5;
        break;
      case 'expert':
        baseTime *= 2.0;
        break;
    }

    // Model count adjustment
    baseTime += models.length * 300;

    // Strategy adjustment
    switch (strategy) {
      case 'parallel':
        baseTime *= 0.8;
        break;
      case 'sequential':
        baseTime *= 1.8;
        break;
      case 'consensus':
        baseTime *= 1.3;
        break;
    }

    // Word count adjustment
    baseTime += Math.min(analysis.wordCount * 10, 1000);

    return Math.round(baseTime);
  }

  /**
   * 🌳 GENERATE DECISION TREE
   * Create transparent decision path for UI visualization
   */
  generateDecisionTree(analysis, modelScores, strategy) {
    const tree = [
      {
        id: 'prompt_analysis',
        label: 'Prompt Analysis',
        type: analysis.promptType,
        complexity: analysis.complexity,
        confidence: 0.9,
        timestamp: Date.now()
      },
      {
        id: 'model_scoring',
        label: 'Model Evaluation',
        scores: modelScores,
        topModel: Object.keys(modelScores).reduce((a, b) => modelScores[a] > modelScores[b] ? a : b),
        confidence: 0.85,
        timestamp: Date.now() + 500
      },
      {
        id: 'strategy_selection',
        label: 'Strategy Selection',
        selected: strategy,
        reasoning: `Optimal for ${analysis.promptType} ${analysis.complexity} tasks`,
        confidence: 0.8,
        timestamp: Date.now() + 1000
      }
    ];

    return tree;
  }

  /**
   * 🧮 UTILITY METHODS
   */
  calculateIndicatorScore(words, indicators) {
    const matches = words.filter(word =>
      indicators.some(indicator => word.includes(indicator))
    ).length;
    return Math.min(matches / Math.max(words.length * 0.1, 1), 1.0);
  }

  extractKeyTopics(words) {
    const topicKeywords = {
      'ai': ['ai', 'artificial', 'intelligence', 'machine', 'learning'],
      'web': ['web', 'website', 'html', 'css', 'javascript'],
      'mobile': ['mobile', 'app', 'android', 'ios', 'react'],
      'data': ['data', 'database', 'sql', 'analytics', 'science'],
      'design': ['design', 'ui', 'ux', 'visual', 'graphics']
    };

    const topics = [];
    for (const [topic, keywords] of Object.entries(topicKeywords)) {
      if (keywords.some(keyword => words.includes(keyword))) {
        topics.push(topic);
      }
    }

    return topics.slice(0, 5);
  }

  detectUrgency(promptLower) {
    const urgentWords = ['urgent', 'asap', 'quickly', 'fast', 'immediate', 'rush', 'deadline'];
    return urgentWords.some(word => promptLower.includes(word)) ? 0.8 : 0.3;
  }

  detectQualityRequirements(promptLower) {
    const qualityWords = ['best', 'perfect', 'excellent', 'high-quality', 'professional', 'premium'];
    return qualityWords.some(word => promptLower.includes(word)) ? 0.9 : 0.6;
  }

  /**
   * 📊 PERFORMANCE TRACKING
   */
  getModelHistoricalScore(modelName) {
    const history = this.performanceHistory.get(modelName) || [];
    return history.length > 0 ? history.reduce((sum, score) => sum + score, 0) / history.length : 0.5;
  }

  getStrategyHistoricalScore(strategyName) {
    const history = this.strategyHistory.get(strategyName) || [];
    return history.length > 0 ? history.reduce((sum, score) => sum + score, 0) / history.length : 0.5;
  }

  recordPerformance(modelName, strategy, qualityScore, responseTime, success) {
    // Record model performance
    if (!this.performanceHistory.has(modelName)) {
      this.performanceHistory.set(modelName, []);
    }
    const modelHistory = this.performanceHistory.get(modelName);
    modelHistory.push(qualityScore);
    if (modelHistory.length > this.maxHistorySize) {
      modelHistory.shift();
    }

    // Record strategy performance
    if (!this.strategyHistory.has(strategy)) {
      this.strategyHistory.set(strategy, []);
    }
    const strategyHistory = this.strategyHistory.get(strategy);
    strategyHistory.push(success ? qualityScore : 0);
    if (strategyHistory.length > this.maxHistorySize) {
      strategyHistory.shift();
    }

    logger.debug(`📊 Performance recorded: ${modelName} (${qualityScore.toFixed(2)}), ${strategy} (${success})`);
  }

  /**
   * 💾 CACHE MANAGEMENT
   */
  generateCacheKey(prompt) {
    // Simple hash function for caching
    let hash = 0;
    for (let i = 0; i < prompt.length; i++) {
      const char = prompt.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.toString();
  }

  cacheRecommendation(key, recommendation) {
    if (this.analysisCache.size >= this.maxCacheSize) {
      const firstKey = this.analysisCache.keys().next().value;
      this.analysisCache.delete(firstKey);
    }
    this.analysisCache.set(key, recommendation);
  }

  /**
   * 🚨 FALLBACK METHODS
   */
  generateFallbackRecommendation(prompt, currentModels, currentStrategy) {
    logger.warn('🚨 Generating fallback recommendation');

    return {
      recommendedModels: currentModels.length > 0 ? currentModels : ['claude', 'gpt', 'deepseek'],
      recommendedStrategy: currentStrategy || 'parallel',
      modelScores: {
        'claude': 0.85,
        'gpt': 0.80,
        'deepseek': 0.75,
        'gemini': 0.80,
        'mistral': 0.70
      },
      modelWeights: {
        'claude': 0.25,
        'gpt': 0.25,
        'deepseek': 0.20,
        'gemini': 0.20,
        'mistral': 0.10
      },
      confidence: 0.6,
      reasoning: 'Fallback recommendation due to analysis error',
      analysis: {
        promptType: 'general',
        complexity: 'medium',
        creativity: 0.5,
        technical: 0.5,
        reasoning: 0.5
      },
      estimatedTime: 2500,
      metadata: {
        fallback: true,
        timestamp: new Date().toISOString()
      },
      decisionTree: []
    };
  }

  /**
   * 🏁 INITIALIZATION HELPERS
   */
  async loadPerformanceHistory() {
    // In a real implementation, this would load from persistent storage
    logger.debug('💾 Loading performance history...');
    // TODO: Implement actual persistence
  }

  initializeDefaultScores() {
    const defaultModels = ['claude', 'gpt', 'deepseek', 'gemini', 'mistral'];
    const defaultStrategies = ['parallel', 'consensus', 'weighted', 'adaptive', 'sequential'];

    // Initialize with reasonable defaults
    defaultModels.forEach(model => {
      this.performanceHistory.set(model, [0.7, 0.8, 0.75]); // Some initial scores
    });

    defaultStrategies.forEach(strategy => {
      this.strategyHistory.set(strategy, [0.7, 0.8, 0.75]); // Some initial scores
    });
  }

  /**
   * 📊 STATUS AND HEALTH
   */
  getStatus() {
    return {
      initialized: this.isInitialized,
      modelsTracked: this.performanceHistory.size,
      strategiesTracked: this.strategyHistory.size,
      cacheSize: this.analysisCache.size,
      uptime: Date.now() - this.startTime || 0
    };
  }

  getHealthMetrics() {
    const metrics = {
      performance: {},
      strategies: {},
      cache: {
        size: this.analysisCache.size,
        hitRate: 0.85 // Would be calculated in real implementation
      }
    };

    // Calculate average performance for each model
    for (const [model, history] of this.performanceHistory) {
      metrics.performance[model] = {
        averageScore: history.reduce((sum, score) => sum + score, 0) / history.length,
        sampleCount: history.length
      };
    }

    // Calculate success rates for strategies
    for (const [strategy, history] of this.strategyHistory) {
      const successRate = history.filter(score => score > 0.7).length / history.length;
      metrics.strategies[strategy] = {
        successRate,
        sampleCount: history.length
      };
    }

    return metrics;
  }
}

// Create singleton instance
const athenaMetaOrchestrator = new AthenaMeta‌Orchestrator();

module.exports = athenaMetaOrchestrator;