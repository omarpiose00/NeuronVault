// 🧠 NEURONVAULT - ATHENA INTELLIGENCE SERVICE
// PHASE 3.4: Core AI Autonomy Engine - Revolutionary Meta-Orchestration
// The first AI system that intelligently orchestrates other AI systems

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import '../providers/providers_main.dart';
import 'mini_llm_analyzer_service.dart';
import 'ai_service.dart';
import 'config_service.dart';
import 'storage_service.dart';
import 'analytics_service.dart';

/// 🎯 ATHENA RECOMMENDATION
class AthenaRecommendation {
  final List<String> recommendedModels;
  final String recommendedStrategy;
  final Map<String, double> modelWeights;
  final Map<String, double> modelConfidences;
  final String reasoning;
  final double overallConfidence;
  final Duration estimatedTime;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const AthenaRecommendation({
    required this.recommendedModels,
    required this.recommendedStrategy,
    required this.modelWeights,
    required this.modelConfidences,
    required this.reasoning,
    required this.overallConfidence,
    required this.estimatedTime,
    required this.metadata,
    required this.timestamp,
  });

  factory AthenaRecommendation.fromAnalysis(PromptAnalysis analysis) {
    return AthenaRecommendation(
      recommendedModels: analysis.recommendedModels,
      recommendedStrategy: analysis.recommendedStrategy,
      modelWeights: analysis.modelScores,
      modelConfidences: analysis.modelScores,
      reasoning: _generateReasoning(analysis),
      overallConfidence: analysis.confidence,
      estimatedTime: analysis.estimatedTime,
      metadata: {
        'prompt_type': analysis.promptType,
        'complexity': analysis.complexity,
        'creativity_required': analysis.creativityRequired,
        'technical_depth': analysis.technicalDepth,
        'reasoning_complexity': analysis.reasoningComplexity,
        'key_topics': analysis.keyTopics,
      },
      timestamp: DateTime.now(),
    );
  }

  static String _generateReasoning(PromptAnalysis analysis) {
    final buffer = StringBuffer();

    buffer.write('Athena Analysis: ');
    buffer.write('This ${analysis.complexity} ${analysis.promptType} prompt ');

    if (analysis.creativityRequired > 0.7) {
      buffer.write('requires high creativity, ');
    }
    if (analysis.technicalDepth > 0.7) {
      buffer.write('demands technical expertise, ');
    }
    if (analysis.reasoningComplexity > 0.7) {
      buffer.write('needs complex reasoning. ');
    }

    buffer.write('Selected ${analysis.recommendedModels.length} optimal models ');
    buffer.write('using ${analysis.recommendedStrategy} strategy ');
    buffer.write('with ${(analysis.confidence * 100).round()}% confidence.');

    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'recommended_models': recommendedModels,
      'recommended_strategy': recommendedStrategy,
      'model_weights': modelWeights,
      'model_confidences': modelConfidences,
      'reasoning': reasoning,
      'overall_confidence': overallConfidence,
      'estimated_time_ms': estimatedTime.inMilliseconds,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 🎯 ATHENA INTELLIGENCE STATE
class AthenaIntelligenceState {
  final bool isInitialized;
  final bool isAnalyzing;
  final bool autoSelectionEnabled;
  final PromptAnalysis? currentAnalysis;
  final AthenaRecommendation? currentRecommendation;
  final List<AthenaRecommendation> recommendationHistory;
  final Map<String, double> modelPerformanceScores;
  final Map<String, int> modelUsageCount;
  final Map<String, double> strategySuccessRates;
  final DateTime? lastAnalysisTime;
  final String? lastError;

  const AthenaIntelligenceState({
    this.isInitialized = false,
    this.isAnalyzing = false,
    this.autoSelectionEnabled = false,
    this.currentAnalysis,
    this.currentRecommendation,
    this.recommendationHistory = const [],
    this.modelPerformanceScores = const {},
    this.modelUsageCount = const {},
    this.strategySuccessRates = const {},
    this.lastAnalysisTime,
    this.lastError,
  });

  AthenaIntelligenceState copyWith({
    bool? isInitialized,
    bool? isAnalyzing,
    bool? autoSelectionEnabled,
    PromptAnalysis? currentAnalysis,
    AthenaRecommendation? currentRecommendation,
    List<AthenaRecommendation>? recommendationHistory,
    Map<String, double>? modelPerformanceScores,
    Map<String, int>? modelUsageCount,
    Map<String, double>? strategySuccessRates,
    DateTime? lastAnalysisTime,
    String? lastError,
  }) {
    return AthenaIntelligenceState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      autoSelectionEnabled: autoSelectionEnabled ?? this.autoSelectionEnabled,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      currentRecommendation: currentRecommendation ?? this.currentRecommendation,
      recommendationHistory: recommendationHistory ?? this.recommendationHistory,
      modelPerformanceScores: modelPerformanceScores ?? this.modelPerformanceScores,
      modelUsageCount: modelUsageCount ?? this.modelUsageCount,
      strategySuccessRates: strategySuccessRates ?? this.strategySuccessRates,
      lastAnalysisTime: lastAnalysisTime ?? this.lastAnalysisTime,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// 🧠 ATHENA INTELLIGENCE SERVICE
/// Revolutionary AI autonomy engine that intelligently orchestrates other AI systems
class AthenaIntelligenceService extends ChangeNotifier {
  final MiniLLMAnalyzerService _analyzerService;
  final AIService _aiService;
  final ConfigService _configService;
  final StorageService _storageService;
  final AnalyticsService _analyticsService;
  final Logger _logger;

  // 📊 STATE
  AthenaIntelligenceState _state = const AthenaIntelligenceState();
  AthenaIntelligenceState get state => _state;

  // 🎯 LEARNING SYSTEM
  final Map<String, List<double>> _modelPerformanceHistory = {};
  final Map<String, List<double>> _strategyPerformanceHistory = {};
  static const int _maxHistoryLength = 100;

  // 📈 RECOMMENDATION STREAM
  final StreamController<AthenaRecommendation> _recommendationController =
  StreamController<AthenaRecommendation>.broadcast();
  Stream<AthenaRecommendation> get recommendationStream => _recommendationController.stream;

  // ⚡ ANALYSIS STREAM
  final StreamController<PromptAnalysis> _analysisController =
  StreamController<PromptAnalysis>.broadcast();
  Stream<PromptAnalysis> get analysisStream => _analysisController.stream;

  AthenaIntelligenceService({
    required MiniLLMAnalyzerService analyzerService,
    required AIService aiService,
    required ConfigService configService,
    required StorageService storageService,
    required AnalyticsService analyticsService,
    required Logger logger,
  })  : _analyzerService = analyzerService,
        _aiService = aiService,
        _configService = configService,
        _storageService = storageService,
        _analyticsService = analyticsService,
        _logger = logger {
    _initialize();
  }

  /// 🚀 INITIALIZE ATHENA INTELLIGENCE
  Future<void> _initialize() async {
    try {
      _logger.i('🧠 Initializing Athena Intelligence Engine...');

      // Load historical performance data
      await _loadPerformanceHistory();

      // Load recommendation history
      await _loadRecommendationHistory();

      // Initialize model performance scores
      await _initializeModelScores();

      _state = _state.copyWith(
        isInitialized: true,
        lastAnalysisTime: DateTime.now(),
      );

      _logger.i('✅ Athena Intelligence Engine initialized successfully');
      _logger.i('🎯 Auto-selection: ${_state.autoSelectionEnabled ? 'ENABLED' : 'DISABLED'}');
      _logger.i('📊 Historical recommendations: ${_state.recommendationHistory.length}');

      notifyListeners();

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize Athena Intelligence', error: e, stackTrace: stackTrace);
      _state = _state.copyWith(
        isInitialized: false,
        lastError: 'Initialization failed: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  /// 🎯 ANALYZE PROMPT AND GENERATE RECOMMENDATIONS
  /// Main method for intelligent AI orchestration
  Future<AthenaRecommendation> analyzeAndRecommend(String prompt) async {
    if (!_state.isInitialized) {
      throw Exception('Athena Intelligence not initialized');
    }

    try {
      _logger.d('🧠 Athena analyzing prompt: "${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}..."');

      _state = _state.copyWith(
        isAnalyzing: true,
        lastError: null,
      );
      notifyListeners();

      // Step 1: Analyze prompt
      final analysis = await _analyzerService.analyzePrompt(prompt);

      _state = _state.copyWith(currentAnalysis: analysis);
      _analysisController.add(analysis);
      notifyListeners();

      // Step 2: Enhance with performance history
      final enhancedAnalysis = await _enhanceWithPerformanceHistory(analysis);

      // Step 3: Generate final recommendation
      final recommendation = await _generateRecommendation(enhancedAnalysis);

      // Step 4: Update state and history
      _state = _state.copyWith(
        isAnalyzing: false,
        currentRecommendation: recommendation,
        recommendationHistory: [..._state.recommendationHistory, recommendation],
        lastAnalysisTime: DateTime.now(),
      );

      // Step 5: Save recommendation
      await _saveRecommendation(recommendation);

      // Step 6: Track analytics
      _trackRecommendationAnalytics(recommendation);

      _recommendationController.add(recommendation);
      notifyListeners();

      _logger.i('✅ Athena recommendation generated successfully');
      _logger.d('🎯 Recommended: ${recommendation.recommendedModels.join(', ')}');
      _logger.d('📊 Strategy: ${recommendation.recommendedStrategy}');
      _logger.d('🔮 Confidence: ${(recommendation.overallConfidence * 100).round()}%');

      return recommendation;

    } catch (e, stackTrace) {
      _logger.e('❌ Athena analysis failed', error: e, stackTrace: stackTrace);

      _state = _state.copyWith(
        isAnalyzing: false,
        lastError: 'Analysis failed: ${e.toString()}',
      );
      notifyListeners();

      rethrow;
    }
  }

  /// 🚀 AUTO-APPLY RECOMMENDATIONS
  /// Automatically apply Athena recommendations to orchestration
  Future<void> autoApplyRecommendations(WidgetRef ref) async {
    if (!_state.autoSelectionEnabled || _state.currentRecommendation == null) {
      return;
    }

    try {
      final recommendation = _state.currentRecommendation!;

      _logger.i('🤖 Auto-applying Athena recommendations...');

      // Update active models
      ref.read(activeModelsProvider.notifier).state = recommendation.recommendedModels;

      // Update strategy
      ref.read(currentStrategyProvider.notifier).state = recommendation.recommendedStrategy;

      // Update model weights
      ref.read(modelWeightsProvider.notifier).state = recommendation.modelWeights;

      _logger.i('✅ Athena recommendations applied automatically');
      _logger.d('🎯 Models: ${recommendation.recommendedModels.join(', ')}');
      _logger.d('📊 Strategy: ${recommendation.recommendedStrategy}');

      // Track achievement
      _trackAutoApplyAchievement();

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to auto-apply recommendations', error: e, stackTrace: stackTrace);
    }
  }

  /// 📈 ENHANCE WITH PERFORMANCE HISTORY
  Future<PromptAnalysis> _enhanceWithPerformanceHistory(PromptAnalysis analysis) async {
    final enhancedScores = <String, double>{};

    for (final modelName in analysis.modelScores.keys) {
      final baseScore = analysis.modelScores[modelName]!;
      final performanceScore = _state.modelPerformanceScores[modelName] ?? 0.5;

      // Combine analysis score with historical performance
      final enhancedScore = (baseScore * 0.7) + (performanceScore * 0.3);
      enhancedScores[modelName] = enhancedScore.clamp(0.0, 1.0);
    }

    // Re-rank models based on enhanced scores
    final rankedModels = enhancedScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final enhancedRecommendedModels = rankedModels
        .take(3)
        .map((e) => e.key)
        .toList();

    return PromptAnalysis(
      promptType: analysis.promptType,
      complexity: analysis.complexity,
      creativityRequired: analysis.creativityRequired,
      technicalDepth: analysis.technicalDepth,
      reasoningComplexity: analysis.reasoningComplexity,
      recommendedModels: enhancedRecommendedModels,
      keyTopics: analysis.keyTopics,
      modelScores: enhancedScores,
      recommendedStrategy: _enhanceStrategyWithHistory(analysis.recommendedStrategy),
      confidence: analysis.confidence,
      estimatedTime: analysis.estimatedTime,
    );
  }

  /// 🎯 ENHANCE STRATEGY WITH HISTORY
  String _enhanceStrategyWithHistory(String baseStrategy) {
    final strategyScores = <String, double>{};

    for (final strategy in ['parallel', 'consensus', 'weighted', 'adaptive', 'sequential']) {
      final successRate = _state.strategySuccessRates[strategy] ?? 0.5;
      strategyScores[strategy] = successRate;
    }

    // If base strategy has good success rate, keep it
    final baseSuccessRate = strategyScores[baseStrategy] ?? 0.5;
    if (baseSuccessRate > 0.7) {
      return baseStrategy;
    }

    // Otherwise, suggest the best performing strategy
    final bestStrategy = strategyScores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return bestStrategy;
  }

  /// 🏆 GENERATE RECOMMENDATION
  Future<AthenaRecommendation> _generateRecommendation(PromptAnalysis analysis) async {
    return AthenaRecommendation.fromAnalysis(analysis);
  }

  /// 📊 RECORD ORCHESTRATION PERFORMANCE
  /// Called after orchestration completes to learn from results
  Future<void> recordOrchestrationPerformance({
    required List<String> usedModels,
    required String usedStrategy,
    required double qualityScore,
    required Duration actualTime,
    required bool wasSuccessful,
  }) async {
    try {
      _logger.d('📊 Recording orchestration performance...');

      // Update model performance scores
      for (final modelName in usedModels) {
        _updateModelPerformance(modelName, qualityScore);
      }

      // Update strategy performance
      _updateStrategyPerformance(usedStrategy, qualityScore);

      // Update model usage counts
      final updatedUsageCount = Map<String, int>.from(_state.modelUsageCount);
      for (final modelName in usedModels) {
        updatedUsageCount[modelName] = (updatedUsageCount[modelName] ?? 0) + 1;
      }

      _state = _state.copyWith(
        modelUsageCount: updatedUsageCount,
      );

      // Save performance data
      await _savePerformanceData();

      notifyListeners();

      _logger.i('✅ Performance recorded successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to record performance', error: e, stackTrace: stackTrace);
    }
  }

  /// 📈 UPDATE MODEL PERFORMANCE
  void _updateModelPerformance(String modelName, double score) {
    // Add to history
    _modelPerformanceHistory.putIfAbsent(modelName, () => []);
    _modelPerformanceHistory[modelName]!.add(score);

    // Keep history limited
    if (_modelPerformanceHistory[modelName]!.length > _maxHistoryLength) {
      _modelPerformanceHistory[modelName]!.removeAt(0);
    }

    // Calculate average performance
    final history = _modelPerformanceHistory[modelName]!;
    final averageScore = history.reduce((a, b) => a + b) / history.length;

    // Update performance scores
    final updatedScores = Map<String, double>.from(_state.modelPerformanceScores);
    updatedScores[modelName] = averageScore;

    _state = _state.copyWith(modelPerformanceScores: updatedScores);
  }

  /// 🎯 UPDATE STRATEGY PERFORMANCE
  void _updateStrategyPerformance(String strategy, double score) {
    // Add to history
    _strategyPerformanceHistory.putIfAbsent(strategy, () => []);
    _strategyPerformanceHistory[strategy]!.add(score);

    // Keep history limited
    if (_strategyPerformanceHistory[strategy]!.length > _maxHistoryLength) {
      _strategyPerformanceHistory[strategy]!.removeAt(0);
    }

    // Calculate success rate
    final history = _strategyPerformanceHistory[strategy]!;
    final successRate = history.where((s) => s > 0.7).length / history.length;

    // Update success rates
    final updatedRates = Map<String, double>.from(_state.strategySuccessRates);
    updatedRates[strategy] = successRate;

    _state = _state.copyWith(strategySuccessRates: updatedRates);
  }

  /// ⚙️ TOGGLE AUTO-SELECTION
  void toggleAutoSelection() {
    _state = _state.copyWith(
      autoSelectionEnabled: !_state.autoSelectionEnabled,
    );

    notifyListeners();

    _logger.i('🤖 Auto-selection ${_state.autoSelectionEnabled ? 'ENABLED' : 'DISABLED'}');

    // Track achievement
    if (_state.autoSelectionEnabled) {
      _trackAutoSelectionAchievement();
    }
  }

  /// 💾 PERSISTENCE METHODS
  Future<void> _loadPerformanceHistory() async {
    try {
      // Load from storage (implement based on storage service)
      _logger.d('💾 Loading performance history...');
      // TODO: Implement storage loading
    } catch (e) {
      _logger.w('⚠️ Failed to load performance history: $e');
    }
  }

  Future<void> _loadRecommendationHistory() async {
    try {
      _logger.d('💾 Loading recommendation history...');
      // TODO: Implement recommendation history loading
    } catch (e) {
      _logger.w('⚠️ Failed to load recommendation history: $e');
    }
  }

  Future<void> _saveRecommendation(AthenaRecommendation recommendation) async {
    try {
      _logger.d('💾 Saving recommendation...');
      // TODO: Implement recommendation saving
    } catch (e) {
      _logger.w('⚠️ Failed to save recommendation: $e');
    }
  }

  Future<void> _savePerformanceData() async {
    try {
      _logger.d('💾 Saving performance data...');
      // TODO: Implement performance data saving
    } catch (e) {
      _logger.w('⚠️ Failed to save performance data: $e');
    }
  }

  /// 🏆 INITIALIZE MODEL SCORES
  Future<void> _initializeModelScores() async {
    final initialScores = <String, double>{
      'claude': 0.85,
      'gpt': 0.80,
      'deepseek': 0.75,
      'gemini': 0.80,
      'mistral': 0.70,
    };

    _state = _state.copyWith(modelPerformanceScores: initialScores);
  }

  /// 📊 ANALYTICS TRACKING
  void _trackRecommendationAnalytics(AthenaRecommendation recommendation) {
    _analyticsService.trackEvent('athena_recommendation_generated', data: {
      'models_count': recommendation.recommendedModels.length,
      'strategy': recommendation.recommendedStrategy,
      'confidence': recommendation.overallConfidence,
      'estimated_time_ms': recommendation.estimatedTime.inMilliseconds,
    });
  }

  void _trackAutoApplyAchievement() {
    // TODO: Track achievement for auto-apply
  }

  void _trackAutoSelectionAchievement() {
    // TODO: Track achievement for enabling auto-selection
  }

  /// 📊 GETTERS FOR UI
  bool get isReady => _state.isInitialized && !_state.isAnalyzing;
  bool get hasRecommendation => _state.currentRecommendation != null;
  bool get hasError => _state.lastError != null;

  String get statusText {
    if (!_state.isInitialized) return 'Initializing...';
    if (_state.isAnalyzing) return 'Analyzing...';
    if (_state.lastError != null) return 'Error: ${_state.lastError}';
    if (_state.currentRecommendation != null) return 'Ready';
    return 'Waiting for prompt';
  }

  /// 🧹 CLEANUP
  @override
  void dispose() {
    _recommendationController.close();
    _analysisController.close();
    super.dispose();
  }
}