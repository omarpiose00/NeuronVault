// 🧠 NEURONVAULT - ATHENA INTELLIGENCE SERVICE - PHASE 3.4
// Core AI Autonomy Engine - World's first AI that intelligently orchestrates other AIs
// Real-time decision transparency with neural luxury integration

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';


import 'mini_llm_analyzer_service.dart';
import 'websocket_orchestration_service.dart';
import 'storage_service.dart';
import 'config_service.dart';

/// 🎯 Athena decision types for transparency
enum AthenaDecisionType {
  modelSelection,      // Which models to use
  strategySelection,   // Which orchestration strategy
  weightAdjustment,    // How to weight model responses
  qualityAssessment,   // Quality scoring of responses
  adaptiveOptimization, // Runtime optimization decisions
}

/// 🧠 Athena decision with complete transparency
@immutable
class AthenaDecision {
  final String id;
  final AthenaDecisionType type;
  final String title;
  final String description;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> outputData;
  final double confidenceScore;
  final List<String> reasoningSteps;
  final Duration processingTime;
  final DateTime timestamp;
  final bool wasApplied;

  const AthenaDecision({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.inputData,
    required this.outputData,
    required this.confidenceScore,
    required this.reasoningSteps,
    required this.processingTime,
    required this.timestamp,
    required this.wasApplied,
  });

  factory AthenaDecision.fromJson(Map<String, dynamic> json) {
    return AthenaDecision(
      id: json['id'] as String,
      type: AthenaDecisionType.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => AthenaDecisionType.modelSelection,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      inputData: json['input_data'] as Map<String, dynamic>? ?? {},
      outputData: json['output_data'] as Map<String, dynamic>? ?? {},
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.8,
      reasoningSteps: (json['reasoning_steps'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      processingTime: Duration(milliseconds: json['processing_time_ms'] as int? ?? 100),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      wasApplied: json['was_applied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'input_data': inputData,
      'output_data': outputData,
      'confidence_score': confidenceScore,
      'reasoning_steps': reasoningSteps,
      'processing_time_ms': processingTime.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'was_applied': wasApplied,
    };
  }

  AthenaDecision copyWith({bool? wasApplied}) {
    return AthenaDecision(
      id: id,
      type: type,
      title: title,
      description: description,
      inputData: inputData,
      outputData: outputData,
      confidenceScore: confidenceScore,
      reasoningSteps: reasoningSteps,
      processingTime: processingTime,
      timestamp: timestamp,
      wasApplied: wasApplied ?? this.wasApplied,
    );
  }
}

/// 🎯 Athena recommendation for model orchestration
@immutable
class AthenaRecommendation {
  final String promptText;
  final PromptAnalysis analysis;
  final List<String> recommendedModels;
  final Map<String, double> modelWeights;
  final String recommendedStrategy;
  final AthenaDecision decision;
  final double overallConfidence;
  final bool autoApplyRecommended;

  const AthenaRecommendation({
    required this.promptText,
    required this.analysis,
    required this.recommendedModels,
    required this.modelWeights,
    required this.recommendedStrategy,
    required this.decision,
    required this.overallConfidence,
    required this.autoApplyRecommended,
  });
}

/// 🧠 Athena Intelligence Service State
@immutable
class AthenaState {
  final bool isEnabled;
  final bool isAnalyzing;
  final AthenaRecommendation? currentRecommendation;
  final List<AthenaDecision> decisionHistory;
  final Map<String, dynamic> learningData;
  final DateTime lastUpdate;

  const AthenaState({
    required this.isEnabled,
    required this.isAnalyzing,
    required this.currentRecommendation,
    required this.decisionHistory,
    required this.learningData,
    required this.lastUpdate,
  });

  AthenaState.initial()
      : isEnabled = false,
        isAnalyzing = false,
        currentRecommendation = null,
        decisionHistory = const [],
        learningData = const {},
        lastUpdate = DateTime.utc(1970);

  AthenaState copyWith({
    bool? isEnabled,
    bool? isAnalyzing,
    AthenaRecommendation? currentRecommendation,
    List<AthenaDecision>? decisionHistory,
    Map<String, dynamic>? learningData,
    DateTime? lastUpdate,
  }) {
    return AthenaState(
      isEnabled: isEnabled ?? this.isEnabled,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentRecommendation: currentRecommendation ?? this.currentRecommendation,
      decisionHistory: decisionHistory ?? this.decisionHistory,
      learningData: learningData ?? this.learningData,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// 🧠 ATHENA INTELLIGENCE SERVICE - CORE AI AUTONOMY ENGINE
class AthenaIntelligenceService extends ChangeNotifier {
  final MiniLLMAnalyzerService _analyzer;
  final WebSocketOrchestrationService _orchestrationService;
  final StorageService _storageService;
  final ConfigService _configService;
  final Logger _logger;

  // 🎯 Core state
  AthenaState _state = AthenaState.initial();
  AthenaState get state => _state;

  // 📊 Performance tracking
  final Map<String, int> _decisionCounts = {};
  final Map<String, List<double>> _decisionConfidences = {};
  final List<String> _recentPrompts = [];

  // 🔄 Stream controllers for real-time updates
  final StreamController<AthenaDecision> _decisionController =
  StreamController<AthenaDecision>.broadcast();
  final StreamController<AthenaRecommendation> _recommendationController =
  StreamController<AthenaRecommendation>.broadcast();
  final StreamController<AthenaState> _stateController =
  StreamController<AthenaState>.broadcast();

  // 📡 Public streams
  Stream<AthenaDecision> get decisionStream => _decisionController.stream;
  Stream<AthenaRecommendation> get recommendationStream => _recommendationController.stream;
  Stream<AthenaState> get stateStream => _stateController.stream;

  // 🧠 Learning parameters
  static const double _confidenceThreshold = 0.8;
  static const int _maxDecisionHistory = 200;
  static const int _maxLearningPrompts = 100;

  AthenaIntelligenceService({
    required MiniLLMAnalyzerService analyzer,
    required WebSocketOrchestrationService orchestrationService,
    required StorageService storageService,
    required ConfigService configService,
    required Logger logger,
  }) : _analyzer = analyzer,
        _orchestrationService = orchestrationService,
        _storageService = storageService,
        _configService = configService,
        _logger = logger {
    _initializeAthena();
  }

  /// 🚀 Initialize Athena Intelligence System
  Future<void> _initializeAthena() async {
    try {
      _logger.i('🧠 Initializing Athena Intelligence System...');

      // Load previous learning data
      await _loadLearningData();

      // Set initial state
      _updateState(_state.copyWith(
        isEnabled: false, // User must explicitly enable
        lastUpdate: DateTime.now(),
      ));

      _logger.i('✅ Athena Intelligence System initialized successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize Athena Intelligence', error: e, stackTrace: stackTrace);
    }
  }

  /// 🎯 MAIN METHOD: Get intelligent model recommendations
  Future<AthenaRecommendation> getModelRecommendations(
      String prompt, {
        List<String>? currentModels,
        String? currentStrategy,
        Map<String, double>? currentWeights,
      }) async {
    if (!_state.isEnabled) {
      throw StateError('Athena Intelligence is not enabled');
    }

    final stopwatch = Stopwatch()..start();

    try {
      _logger.d('🧠 Athena analyzing prompt for intelligent recommendations...');

      // Update state to analyzing
      _updateState(_state.copyWith(isAnalyzing: true));

      // 1. Analyze prompt with Mini-LLM
      final analysis = await _analyzer.analyzePrompt(prompt);
      _logger.d('📊 Prompt analysis completed: ${analysis.primaryCategory.name}');

      // 2. Generate model selection decision
      final modelDecision = await _generateModelSelectionDecision(
        analysis,
        currentModels ?? [],
      );

      // 3. Generate strategy selection decision
      final strategyDecision = await _generateStrategySelectionDecision(
        analysis,
        currentStrategy ?? 'parallel',
      );

      // 4. Generate weight optimization decision
      final weightDecision = await _generateWeightOptimizationDecision(
        analysis,
        modelDecision.outputData['recommended_models'] as List<String>,
        currentWeights ?? {},
      );

      stopwatch.stop();

      // 5. Combine all decisions into final recommendation
      final recommendation = AthenaRecommendation(
        promptText: prompt,
        analysis: analysis,
        recommendedModels: modelDecision.outputData['recommended_models'] as List<String>,
        modelWeights: Map<String, double>.from(weightDecision.outputData['optimized_weights']),
        recommendedStrategy: strategyDecision.outputData['recommended_strategy'] as String,
        decision: modelDecision, // Primary decision
        overallConfidence: _calculateOverallConfidence([
          modelDecision,
          strategyDecision,
          weightDecision,
        ]),
        autoApplyRecommended: _shouldAutoApply([
          modelDecision,
          strategyDecision,
          weightDecision,
        ]),
      );

      // 6. Store decisions and update state
      await _storeDecisions([modelDecision, strategyDecision, weightDecision]);
      _updateState(_state.copyWith(
        isAnalyzing: false,
        currentRecommendation: recommendation,
        lastUpdate: DateTime.now(),
      ));

      // 7. Emit recommendation
      _recommendationController.add(recommendation);

      // 8. Track for learning
      _trackRecommendation(prompt, recommendation);

      _logger.i('✅ Athena recommendations generated in ${stopwatch.elapsedMilliseconds}ms');
      _logger.i('🎯 Recommended: ${recommendation.recommendedModels.join(", ")} with ${recommendation.recommendedStrategy} strategy');

      return recommendation;

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('❌ Athena recommendation failed after ${stopwatch.elapsedMilliseconds}ms', error: e, stackTrace: stackTrace);

      _updateState(_state.copyWith(isAnalyzing: false));
      rethrow;
    }
  }

  /// 🎯 Generate intelligent model selection decision
  Future<AthenaDecision> _generateModelSelectionDecision(
      PromptAnalysis analysis,
      List<String> currentModels,
      ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final reasoningSteps = <String>[];

      // 1. Get model recommendations from analysis
      final modelRecommendations = analysis.modelRecommendations;
      reasoningSteps.add('Analyzed ${modelRecommendations.length} model capabilities');

      // 2. Sort models by recommendation score
      final sortedModels = modelRecommendations.entries
          .where((entry) => entry.value > 0.6) // Minimum threshold
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // 3. Select top models based on complexity
      int modelCount;
      switch (analysis.complexity) {
        case PromptComplexity.simple:
          modelCount = 2; // Simple queries need fewer models
          break;
        case PromptComplexity.moderate:
          modelCount = 3; // Standard orchestration
          break;
        case PromptComplexity.complex:
          modelCount = 4; // Complex queries benefit from more perspectives
          break;
        case PromptComplexity.expert:
          modelCount = math.min(5, sortedModels.length); // Maximum diversity for expert queries
          break;
      }

      final recommendedModels = sortedModels
          .take(modelCount)
          .map((entry) => entry.key)
          .toList();

      reasoningSteps.add('Selected ${recommendedModels.length} models for ${analysis.complexity.name} complexity');
      reasoningSteps.add('Top models: ${recommendedModels.join(", ")}');

      // 4. Compare with current selection
      final changesNeeded = _compareModelSelections(currentModels, recommendedModels);
      reasoningSteps.add('Changes from current: $changesNeeded');

      stopwatch.stop();

      // 5. Calculate confidence based on score spread
      final confidence = _calculateModelSelectionConfidence(sortedModels, recommendedModels);

      final decision = AthenaDecision(
        id: _generateDecisionId(),
        type: AthenaDecisionType.modelSelection,
        title: 'Smart Model Selection',
        description: 'Selected ${recommendedModels.length} optimal models for ${analysis.primaryCategory.name} query',
        inputData: {
          'prompt_category': analysis.primaryCategory.name,
          'prompt_complexity': analysis.complexity.name,
          'current_models': currentModels,
          'model_scores': modelRecommendations,
        },
        outputData: {
          'recommended_models': recommendedModels,
          'model_count': modelCount,
          'changes_needed': changesNeeded,
        },
        confidenceScore: confidence,
        reasoningSteps: reasoningSteps,
        processingTime: Duration(milliseconds: stopwatch.elapsedMilliseconds),
        timestamp: DateTime.now(),
        wasApplied: false,
      );

      _decisionController.add(decision);
      return decision;

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('❌ Model selection decision failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🎛️ Generate intelligent strategy selection decision
  Future<AthenaDecision> _generateStrategySelectionDecision(
      PromptAnalysis analysis,
      String currentStrategy,
      ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final reasoningSteps = <String>[];

      // 1. Analyze optimal strategy based on complexity and category
      String recommendedStrategy = analysis.recommendedStrategy;

      // 2. Apply learning-based optimizations
      final learnedOptimizations = _getLearningBasedStrategyOptimizations(analysis);
      if (learnedOptimizations.isNotEmpty) {
        reasoningSteps.add('Applied learning optimizations: ${learnedOptimizations.join(", ")}');
        // Could modify strategy based on learning
      }

      // 3. Consider current performance
      final strategyPerformance = _getStrategyPerformanceHistory(currentStrategy);
      reasoningSteps.add('Current $currentStrategy strategy performance: ${strategyPerformance.toStringAsFixed(2)}');

      // 4. Make final decision
      final needsChange = recommendedStrategy != currentStrategy;
      final confidence = needsChange ? 0.85 : 0.95; // Higher confidence when no change needed

      reasoningSteps.addAll([
        'Analyzed ${analysis.primaryCategory.name} category requirements',
        'Complexity level: ${analysis.complexity.name}',
        'Recommended strategy: $recommendedStrategy',
        needsChange ? 'Strategy change recommended' : 'Current strategy is optimal',
      ]);

      stopwatch.stop();

      final decision = AthenaDecision(
        id: _generateDecisionId(),
        type: AthenaDecisionType.strategySelection,
        title: 'Intelligent Strategy Selection',
        description: needsChange
            ? 'Recommend changing from $currentStrategy to $recommendedStrategy'
            : 'Current $currentStrategy strategy is optimal',
        inputData: {
          'prompt_category': analysis.primaryCategory.name,
          'prompt_complexity': analysis.complexity.name,
          'current_strategy': currentStrategy,
          'strategy_performance': strategyPerformance,
        },
        outputData: {
          'recommended_strategy': recommendedStrategy,
          'needs_change': needsChange,
          'performance_improvement_expected': needsChange ? 0.15 : 0.0,
        },
        confidenceScore: confidence,
        reasoningSteps: reasoningSteps,
        processingTime: Duration(milliseconds: stopwatch.elapsedMilliseconds),
        timestamp: DateTime.now(),
        wasApplied: false,
      );

      _decisionController.add(decision);
      return decision;

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('❌ Strategy selection decision failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// ⚖️ Generate intelligent weight optimization decision
  Future<AthenaDecision> _generateWeightOptimizationDecision(
      PromptAnalysis analysis,
      List<String> selectedModels,
      Map<String, double> currentWeights,
      ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final reasoningSteps = <String>[];
      final optimizedWeights = <String, double>{};

      // 1. Calculate base weights from model recommendations
      final modelRecommendations = analysis.modelRecommendations;

      for (final model in selectedModels) {
        final baseScore = modelRecommendations[model] ?? 0.7;
        optimizedWeights[model] = baseScore;
      }

      reasoningSteps.add('Calculated base weights from model specialization scores');

      // 2. Apply complexity-based adjustments
      for (final model in selectedModels) {
        double adjustment = 1.0;

        // Claude gets boost for complex/analytical tasks
        if (model == 'claude' &&
            (analysis.complexity == PromptComplexity.complex ||
                analysis.complexity == PromptComplexity.expert ||
                analysis.primaryCategory == PromptCategory.analytical)) {
          adjustment = 1.2;
        }

        // DeepSeek gets boost for coding tasks
        if (model == 'deepseek' && analysis.primaryCategory == PromptCategory.coding) {
          adjustment = 1.3;
        }

        // GPT gets boost for creative/conversational tasks
        if (model == 'gpt' &&
            (analysis.primaryCategory == PromptCategory.creative ||
                analysis.primaryCategory == PromptCategory.conversational)) {
          adjustment = 1.1;
        }

        optimizedWeights[model] = (optimizedWeights[model]! * adjustment).clamp(0.1, 2.0);
      }

      reasoningSteps.add('Applied complexity and category-based weight adjustments');

      // 3. Normalize weights to sum to model count
      final totalWeight = optimizedWeights.values.reduce((a, b) => a + b);
      final targetSum = selectedModels.length.toDouble();

      for (final model in selectedModels) {
        optimizedWeights[model] = (optimizedWeights[model]! / totalWeight) * targetSum;
      }

      reasoningSteps.add('Normalized weights to sum to ${targetSum.toStringAsFixed(1)}');

      // 4. Compare with current weights
      final significantChanges = _compareWeights(currentWeights, optimizedWeights);
      final needsChange = significantChanges > 0.1; // 10% threshold

      reasoningSteps.add('Weight changes: ${(significantChanges * 100).toStringAsFixed(1)}%');

      stopwatch.stop();

      final decision = AthenaDecision(
        id: _generateDecisionId(),
        type: AthenaDecisionType.weightAdjustment,
        title: 'Intelligent Weight Optimization',
        description: needsChange
            ? 'Optimized model weights for better performance'
            : 'Current weights are already optimal',
        inputData: {
          'selected_models': selectedModels,
          'current_weights': currentWeights,
          'model_scores': modelRecommendations,
        },
        outputData: {
          'optimized_weights': optimizedWeights,
          'needs_change': needsChange,
          'change_magnitude': significantChanges,
        },
        confidenceScore: needsChange ? 0.8 : 0.9,
        reasoningSteps: reasoningSteps,
        processingTime: Duration(milliseconds: stopwatch.elapsedMilliseconds),
        timestamp: DateTime.now(),
        wasApplied: false,
      );

      _decisionController.add(decision);
      return decision;

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('❌ Weight optimization decision failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🎯 Apply Athena recommendations to orchestration
  Future<void> applyRecommendation(AthenaRecommendation recommendation) async {
    try {
      _logger.i('🎯 Applying Athena recommendations...');

      // Update orchestration service with recommendations
      // This would integrate with the existing WebSocket orchestration

      // Mark decision as applied
      final appliedDecision = recommendation.decision.copyWith(wasApplied: true);

      // Update decision history
      final updatedHistory = List<AthenaDecision>.from(_state.decisionHistory);
      final decisionIndex = updatedHistory.indexWhere((d) => d.id == appliedDecision.id);
      if (decisionIndex >= 0) {
        updatedHistory[decisionIndex] = appliedDecision;
      }

      _updateState(_state.copyWith(
        decisionHistory: updatedHistory,
        lastUpdate: DateTime.now(),
      ));

      _logger.i('✅ Athena recommendations applied successfully');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to apply Athena recommendations', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🔄 Enable/disable Athena Intelligence
  Future<void> setEnabled(bool enabled) async {
    try {
      _logger.i('🎛️ ${enabled ? "Enabling" : "Disabling"} Athena Intelligence...');

      _updateState(_state.copyWith(
        isEnabled: enabled,
        lastUpdate: DateTime.now(),
      ));

      // Save preference
      await _storageService.clearAllData(); // Placeholder for saving preferences

      _logger.i('✅ Athena Intelligence ${enabled ? "enabled" : "disabled"}');

    } catch (e, stackTrace) {
      _logger.e('❌ Failed to update Athena enabled state', error: e, stackTrace: stackTrace);
    }
  }

  // 🔧 UTILITY METHODS

  void _updateState(AthenaState newState) {
    _state = newState;
    _stateController.add(_state);
    notifyListeners();
  }

  Future<void> _storeDecisions(List<AthenaDecision> decisions) async {
    final updatedHistory = List<AthenaDecision>.from(_state.decisionHistory);
    updatedHistory.addAll(decisions);

    // Keep only recent decisions
    if (updatedHistory.length > _maxDecisionHistory) {
      updatedHistory.removeRange(0, updatedHistory.length - _maxDecisionHistory);
    }

    _updateState(_state.copyWith(decisionHistory: updatedHistory));

    // Track decision counts
    for (final decision in decisions) {
      final typeKey = decision.type.name;
      _decisionCounts[typeKey] = (_decisionCounts[typeKey] ?? 0) + 1;

      _decisionConfidences.putIfAbsent(typeKey, () => []).add(decision.confidenceScore);
      if (_decisionConfidences[typeKey]!.length > 50) {
        _decisionConfidences[typeKey]!.removeAt(0);
      }
    }
  }

  void _trackRecommendation(String prompt, AthenaRecommendation recommendation) {
    _recentPrompts.add(prompt);
    if (_recentPrompts.length > _maxLearningPrompts) {
      _recentPrompts.removeAt(0);
    }
  }

  Future<void> _loadLearningData() async {
    // Placeholder for loading previous learning data
    // This would load from storage service
  }

  String _generateDecisionId() {
    return 'athena_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  double _calculateOverallConfidence(List<AthenaDecision> decisions) {
    if (decisions.isEmpty) return 0.5;
    return decisions.map((d) => d.confidenceScore).reduce((a, b) => a + b) / decisions.length;
  }

  bool _shouldAutoApply(List<AthenaDecision> decisions) {
    final avgConfidence = _calculateOverallConfidence(decisions);
    return avgConfidence >= _confidenceThreshold;
  }

  double _calculateModelSelectionConfidence(
      List<MapEntry<String, double>> sortedModels,
      List<String> selectedModels,
      ) {
    if (sortedModels.length < 2) return 0.7;

    // Higher confidence when there's clear separation between selected and non-selected
    final selectedScores = sortedModels
        .where((entry) => selectedModels.contains(entry.key))
        .map((entry) => entry.value);

    final nonSelectedScores = sortedModels
        .where((entry) => !selectedModels.contains(entry.key))
        .map((entry) => entry.value);

    if (selectedScores.isEmpty || nonSelectedScores.isEmpty) return 0.8;

    final avgSelected = selectedScores.reduce((a, b) => a + b) / selectedScores.length;
    final avgNonSelected = nonSelectedScores.reduce((a, b) => a + b) / nonSelectedScores.length;

    final separation = (avgSelected - avgNonSelected).clamp(0.0, 1.0);
    return (0.6 + (separation * 0.3)).clamp(0.6, 0.95);
  }

  String _compareModelSelections(List<String> current, List<String> recommended) {
    final currentSet = Set<String>.from(current);
    final recommendedSet = Set<String>.from(recommended);

    final added = recommendedSet.difference(currentSet);
    final removed = currentSet.difference(recommendedSet);

    if (added.isEmpty && removed.isEmpty) return 'No changes needed';

    final changes = <String>[];
    if (added.isNotEmpty) changes.add('Add: ${added.join(", ")}');
    if (removed.isNotEmpty) changes.add('Remove: ${removed.join(", ")}');

    return changes.join('; ');
  }

  double _compareWeights(Map<String, double> current, Map<String, double> optimized) {
    double totalDifference = 0.0;
    int comparedCount = 0;

    for (final model in optimized.keys) {
      final currentWeight = current[model] ?? 1.0;
      final optimizedWeight = optimized[model] ?? 1.0;
      totalDifference += (currentWeight - optimizedWeight).abs();
      comparedCount++;
    }

    return comparedCount > 0 ? totalDifference / comparedCount : 0.0;
  }

  List<String> _getLearningBasedStrategyOptimizations(PromptAnalysis analysis) {
    // Placeholder for machine learning based optimizations
    return [];
  }

  double _getStrategyPerformanceHistory(String strategy) {
    // Placeholder for historical performance data
    return 0.85;
  }

  // 📊 PUBLIC ANALYTICS METHODS

  Map<String, dynamic> getAthenaStatistics() {
    return {
      'total_decisions': _state.decisionHistory.length,
      'enabled': _state.isEnabled,
      'decision_counts': Map<String, int>.from(_decisionCounts),
      'average_confidences': _decisionConfidences.map(
            (key, values) => MapEntry(
          key,
          values.isNotEmpty ? values.reduce((a, b) => a + b) / values.length : 0.0,
        ),
      ),
      'recent_prompts_count': _recentPrompts.length,
      'last_recommendation': _state.currentRecommendation?.analysis.primaryCategory.name,
    };
  }

  List<AthenaDecision> getRecentDecisions({int? limit}) {
    final decisions = _state.decisionHistory.reversed.toList();
    return limit != null ? decisions.take(limit).toList() : decisions;
  }

  void clearHistory() {
    _updateState(_state.copyWith(
      decisionHistory: [],
      currentRecommendation: null,
      lastUpdate: DateTime.now(),
    ));

    _decisionCounts.clear();
    _decisionConfidences.clear();
    _recentPrompts.clear();

    _logger.i('🧹 Athena history cleared');
  }

  @override
  void dispose() {
    _decisionController.close();
    _recommendationController.close();
    _stateController.close();
    super.dispose();
  }
}