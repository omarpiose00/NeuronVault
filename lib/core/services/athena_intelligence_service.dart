// lib/core/services/athena_intelligence_service.dart
// 🧠 NEURONVAULT - ATHENA INTELLIGENCE SERVICE - PHASE 3.4 REVOLUTIONARY
// Core AI Autonomy Engine - AI that selects AI (Meta-orchestration)
// World's first transparent AI decision-making system

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import 'config_service.dart';
import 'storage_service.dart';
import 'mini_llm_analyzer_service.dart';

/// 🎯 AI RECOMMENDATION RESULT
class AIRecommendationResult {
  final List<String> recommendedModels;
  final String recommendedStrategy;
  final Map<String, double> modelConfidenceScores;
  final Map<String, double> recommendedWeights;
  final double overallConfidence;
  final String decisionReasoning;
  final List<DecisionTreeNode> decisionTree;
  final Duration decisionTime;
  final Map<String, dynamic> metadata;

  const AIRecommendationResult({
    required this.recommendedModels,
    required this.recommendedStrategy,
    required this.modelConfidenceScores,
    required this.recommendedWeights,
    required this.overallConfidence,
    required this.decisionReasoning,
    required this.decisionTree,
    required this.decisionTime,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'recommended_models': recommendedModels,
    'recommended_strategy': recommendedStrategy,
    'model_confidence_scores': modelConfidenceScores,
    'recommended_weights': recommendedWeights,
    'overall_confidence': overallConfidence,
    'decision_reasoning': decisionReasoning,
    'decision_tree': decisionTree.map((node) => node.toJson()).toList(),
    'decision_time_ms': decisionTime.inMilliseconds,
    'metadata': metadata,
  };
}

/// 🌳 DECISION TREE NODE - For transparency
class DecisionTreeNode {
  final String id;
  final String question;
  final String answer;
  final double confidence;
  final List<DecisionTreeNode> children;
  final Map<String, dynamic> data;

  const DecisionTreeNode({
    required this.id,
    required this.question,
    required this.answer,
    required this.confidence,
    required this.children,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'confidence': confidence,
    'children': children.map((child) => child.toJson()).toList(),
    'data': data,
  };

  factory DecisionTreeNode.fromJson(Map<String, dynamic> json) {
    return DecisionTreeNode(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      children: (json['children'] as List<dynamic>)
          .map((child) => DecisionTreeNode.fromJson(child as Map<String, dynamic>))
          .toList(),
      data: Map<String, dynamic>.from(json['data'] as Map),
    );
  }
}

/// 📈 AI LEARNING PATTERN
class AILearningPattern {
  final String patternId;
  final String promptType;
  final List<String> successfulModels;
  final String successfulStrategy;
  final double successScore;
  final int usageCount;
  final DateTime createdAt;
  final DateTime lastUsedAt;
  final Map<String, dynamic> context;

  const AILearningPattern({
    required this.patternId,
    required this.promptType,
    required this.successfulModels,
    required this.successfulStrategy,
    required this.successScore,
    required this.usageCount,
    required this.createdAt,
    required this.lastUsedAt,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
    'pattern_id': patternId,
    'prompt_type': promptType,
    'successful_models': successfulModels,
    'successful_strategy': successfulStrategy,
    'success_score': successScore,
    'usage_count': usageCount,
    'created_at': createdAt.toIso8601String(),
    'last_used_at': lastUsedAt.toIso8601String(),
    'context': context,
  };

  factory AILearningPattern.fromJson(Map<String, dynamic> json) {
    return AILearningPattern(
      patternId: json['pattern_id'] as String,
      promptType: json['prompt_type'] as String,
      successfulModels: List<String>.from(json['successful_models'] as List),
      successfulStrategy: json['successful_strategy'] as String,
      successScore: (json['success_score'] as num).toDouble(),
      usageCount: json['usage_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
      context: Map<String, dynamic>.from(json['context'] as Map),
    );
  }
}

/// 🧠 ATHENA INTELLIGENCE SERVICE - WORLD'S FIRST AI AUTONOMY ENGINE
class AthenaIntelligenceService extends ChangeNotifier {
  final ConfigService _configService;
  final StorageService _storageService;
  final MiniLLMAnalyzerService _miniLLMAnalyzer;
  final Logger _logger;

  // 🧠 AI Decision State
  bool _isAutoModeEnabled = false;
  AIRecommendationResult? _lastRecommendation;
  final List<AILearningPattern> _learningPatterns = [];
  final Map<String, double> _modelPerformanceHistory = {};

  // 📊 Performance Tracking
  int _totalRecommendations = 0;
  int _autoAppliedRecommendations = 0;
  int _userOverrides = 0;
  final List<Duration> _decisionTimes = [];
  final Map<String, int> _strategyUsageCount = {};
  final Map<String, double> _strategySuccessRates = {};

  // 🎯 Configuration
  static const int _maxLearningPatterns = 1000;
  static const Duration _patternExpiryDuration = Duration(days: 30);
  static const double _confidenceThreshold = 0.7;
  static const double _autoApplyThreshold = 0.85;

  // Getters
  bool get isAutoModeEnabled => _isAutoModeEnabled;
  AIRecommendationResult? get lastRecommendation => _lastRecommendation;
  List<AILearningPattern> get learningPatterns => List.unmodifiable(_learningPatterns);

  AthenaIntelligenceService({
    required ConfigService configService,
    required StorageService storageService,
    required MiniLLMAnalyzerService miniLLMAnalyzer,
    required Logger logger,
  })  : _configService = configService,
        _storageService = storageService,
        _miniLLMAnalyzer = miniLLMAnalyzer,
        _logger = logger {
    _initializeAthenaSystem();
    _logger.i('🧠 AthenaIntelligenceService initialized - World\'s first AI Autonomy Engine ready');
  }

  /// 🚀 INITIALIZATION
  Future<void> _initializeAthenaSystem() async {
    try {
      await _loadLearningPatterns();
      await _loadPerformanceHistory();
      await _loadUserPreferences();

      _logger.i('✅ Athena Intelligence System initialized with ${_learningPatterns.length} learning patterns');
    } catch (e) {
      _logger.e('❌ Failed to initialize Athena system: $e');
    }
  }

  /// 🎯 CORE AI RECOMMENDATION ENGINE
  Future<AIRecommendationResult> generateAIRecommendation(
      String prompt, {
        required List<String> availableModels,
        List<String>? currentActiveModels,
        String? currentStrategy,
        Map<String, double>? currentWeights,
        Map<String, dynamic>? context,
      }) async {
    final stopwatch = Stopwatch()..start();

    try {
      _logger.d('🧠 Generating AI recommendation for prompt: "${_truncatePrompt(prompt)}"');
      _totalRecommendations++;

      // 🔍 Step 1: Analyze prompt with Mini-LLM
      final promptAnalysis = await _miniLLMAnalyzer.analyzePrompt(
        prompt,
        availableModels: availableModels,
        context: context,
      );

      // 🧬 Step 2: Check learning patterns
      final learningInsights = _getLearningInsights(promptAnalysis, availableModels);

      // 🎯 Step 3: Generate decision tree
      final decisionTree = _buildDecisionTree(
        promptAnalysis,
        learningInsights,
        availableModels,
        currentActiveModels,
        currentStrategy,
      );

      // 🚀 Step 4: Make final recommendations
      final recommendation = _makeIntelligentRecommendation(
        promptAnalysis,
        learningInsights,
        decisionTree,
        availableModels,
        context,
      );

      stopwatch.stop();
      final decisionTime = stopwatch.elapsed;

      // 📊 Track performance
      _decisionTimes.add(decisionTime);
      if (_decisionTimes.length > 100) {
        _decisionTimes.removeAt(0);
      }

      final finalRecommendation = AIRecommendationResult(
        recommendedModels: recommendation['models'] as List<String>,
        recommendedStrategy: recommendation['strategy'] as String,
        modelConfidenceScores: Map<String, double>.from(recommendation['confidence_scores'] as Map),
        recommendedWeights: Map<String, double>.from(recommendation['weights'] as Map),
        overallConfidence: recommendation['overall_confidence'] as double,
        decisionReasoning: recommendation['reasoning'] as String,
        decisionTree: decisionTree,
        decisionTime: decisionTime,
        metadata: {
          'prompt_analysis': promptAnalysis.toJson(),
          'learning_patterns_used': learningInsights.length,
          'decision_method': 'athena_intelligence',
          'available_models_count': availableModels.length,
          'total_recommendations': _totalRecommendations,
          'auto_mode_enabled': _isAutoModeEnabled,
        },
      );

      _lastRecommendation = finalRecommendation;
      notifyListeners();

      _logger.i('🎯 AI recommendation generated in ${decisionTime.inMilliseconds}ms');
      _logger.d('📊 Recommended: ${finalRecommendation.recommendedModels.join(', ')} with ${finalRecommendation.recommendedStrategy} strategy');

      return finalRecommendation;

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('❌ AI recommendation generation failed after ${stopwatch.elapsedMilliseconds}ms',
          error: e, stackTrace: stackTrace);

      return _getFallbackRecommendation(prompt, availableModels, stopwatch.elapsed);
    }
  }

  /// 🧬 GET LEARNING INSIGHTS
  List<AILearningPattern> _getLearningInsights(
      PromptAnalysisResult promptAnalysis,
      List<String> availableModels,
      ) {
    final relevantPatterns = _learningPatterns.where((pattern) {
      // Match by prompt type
      if (pattern.promptType != promptAnalysis.promptType) return false;

      // Check if any of the successful models are available
      final hasAvailableModels = pattern.successfulModels
          .any((model) => availableModels.contains(model));

      return hasAvailableModels;
    }).toList();

    // Sort by success score and usage count
    relevantPatterns.sort((a, b) {
      final scoreComparison = b.successScore.compareTo(a.successScore);
      if (scoreComparison != 0) return scoreComparison;
      return b.usageCount.compareTo(a.usageCount);
    });

    return relevantPatterns.take(5).toList(); // Top 5 relevant patterns
  }

  /// 🌳 BUILD DECISION TREE
  List<DecisionTreeNode> _buildDecisionTree(
      PromptAnalysisResult promptAnalysis,
      List<AILearningPattern> learningInsights,
      List<String> availableModels,
      List<String>? currentActiveModels,
      String? currentStrategy,
      ) {
    final decisionTree = <DecisionTreeNode>[];

    // Root: Prompt Type Analysis
    decisionTree.add(DecisionTreeNode(
      id: 'prompt_type',
      question: 'What type of prompt is this?',
      answer: '${promptAnalysis.promptType} (complexity: ${(promptAnalysis.complexity * 100).round()}%)',
      confidence: 0.95,
      children: [],
      data: {
        'prompt_type': promptAnalysis.promptType,
        'complexity': promptAnalysis.complexity,
        'analysis_method': promptAnalysis.metadata['analysis_method'],
      },
    ));

    // Learning Patterns Branch
    if (learningInsights.isNotEmpty) {
      final bestPattern = learningInsights.first;
      decisionTree.add(DecisionTreeNode(
        id: 'learning_pattern',
        question: 'What do past successful patterns suggest?',
        answer: 'Pattern found: ${bestPattern.successfulModels.join(', ')} with ${bestPattern.successfulStrategy} (success: ${(bestPattern.successScore * 100).round()}%)',
        confidence: bestPattern.successScore,
        children: [],
        data: {
          'pattern_id': bestPattern.patternId,
          'usage_count': bestPattern.usageCount,
          'success_score': bestPattern.successScore,
        },
      ));
    }

    // Model Specialization Branch
    final topModels = promptAnalysis.recommendedModels.take(3).toList();
    decisionTree.add(DecisionTreeNode(
      id: 'model_specialization',
      question: 'Which models are specialized for this task?',
      answer: 'Top matches: ${topModels.join(', ')} based on specialization analysis',
      confidence: topModels.isNotEmpty ? 0.85 : 0.5,
      children: topModels.map((model) => DecisionTreeNode(
        id: 'model_$model',
        question: 'Why $model?',
        answer: 'Confidence: ${((promptAnalysis.modelConfidenceScores[model] ?? 0.5) * 100).round()}%',
        confidence: promptAnalysis.modelConfidenceScores[model] ?? 0.5,
        children: [],
        data: {'model': model, 'specialization_score': promptAnalysis.modelConfidenceScores[model]},
      )).toList(),
      data: {'recommended_models': topModels},
    ));

    // Strategy Selection Branch
    final recommendedStrategy = _selectOptimalStrategy(promptAnalysis, learningInsights);
    decisionTree.add(DecisionTreeNode(
      id: 'strategy_selection',
      question: 'What orchestration strategy is best?',
      answer: '$recommendedStrategy based on prompt complexity and model count',
      confidence: 0.8,
      children: [],
      data: {
        'strategy': recommendedStrategy,
        'reasoning': _getStrategyReasoning(recommendedStrategy, promptAnalysis.complexity, availableModels.length),
      },
    ));

    return decisionTree;
  }

  /// 🚀 MAKE INTELLIGENT RECOMMENDATION
  Map<String, dynamic> _makeIntelligentRecommendation(
      PromptAnalysisResult promptAnalysis,
      List<AILearningPattern> learningInsights,
      List<DecisionTreeNode> decisionTree,
      List<String> availableModels,
      Map<String, dynamic>? context,
      ) {
    // 🎯 Model Selection Logic
    List<String> recommendedModels;
    Map<String, double> confidenceScores;

    if (learningInsights.isNotEmpty && learningInsights.first.successScore > 0.8) {
      // Use learning pattern if highly successful
      final bestPattern = learningInsights.first;
      recommendedModels = bestPattern.successfulModels
          .where((model) => availableModels.contains(model))
          .take(3)
          .toList();
      confidenceScores = {
        for (final model in recommendedModels) model: bestPattern.successScore
      };
    } else {
      // Use prompt analysis recommendations
      recommendedModels = promptAnalysis.recommendedModels
          .where((model) => availableModels.contains(model))
          .take(3)
          .toList();
      confidenceScores = Map<String, double>.from(promptAnalysis.modelConfidenceScores);
    }

    // Ensure at least one model is recommended
    if (recommendedModels.isEmpty && availableModels.isNotEmpty) {
      recommendedModels = [availableModels.first];
      confidenceScores[availableModels.first] = 0.6;
    }

    // 🎯 Strategy Selection
    final recommendedStrategy = learningInsights.isNotEmpty && learningInsights.first.successScore > 0.8
        ? learningInsights.first.successfulStrategy
        : _selectOptimalStrategy(promptAnalysis, learningInsights);

    // 🎯 Weight Calculation
    final recommendedWeights = _calculateOptimalWeights(
      recommendedModels,
      confidenceScores,
      promptAnalysis.complexity,
    );

    // 🎯 Overall Confidence
    final overallConfidence = _calculateOverallConfidence(
      confidenceScores,
      learningInsights,
      promptAnalysis.complexity,
    );

    // 🎯 Decision Reasoning
    final reasoning = _generateDecisionReasoning(
      promptAnalysis,
      learningInsights,
      recommendedModels,
      recommendedStrategy,
      overallConfidence,
    );

    return {
      'models': recommendedModels,
      'strategy': recommendedStrategy,
      'confidence_scores': confidenceScores,
      'weights': recommendedWeights,
      'overall_confidence': overallConfidence,
      'reasoning': reasoning,
    };
  }

  /// 🎯 STRATEGY SELECTION LOGIC
  String _selectOptimalStrategy(PromptAnalysisResult promptAnalysis, List<AILearningPattern> insights) {
    final complexity = promptAnalysis.complexity;
    final promptType = promptAnalysis.promptType;

    // Check learning patterns first
    if (insights.isNotEmpty) {
      final topPattern = insights.first;
      if (topPattern.successScore > 0.8) {
        return topPattern.successfulStrategy;
      }
    }

    // Rule-based strategy selection
    switch (promptType) {
      case 'complex':
        return 'consensus'; // Complex prompts benefit from consensus
      case 'creative':
        return 'parallel'; // Creative tasks benefit from diverse perspectives
      case 'technical':
        return complexity > 0.7 ? 'weighted' : 'parallel';
      case 'analytical':
        return 'weighted'; // Analytical tasks benefit from weighted expertise
      case 'mathematical':
        return 'consensus'; // Math needs agreement
      default:
        return complexity > 0.6 ? 'weighted' : 'parallel';
    }
  }

  /// ⚖️ CALCULATE OPTIMAL WEIGHTS
  Map<String, double> _calculateOptimalWeights(
      List<String> models,
      Map<String, double> confidenceScores,
      double complexity,
      ) {
    final weights = <String, double>{};
    final totalConfidence = confidenceScores.values.fold(0.0, (sum, score) => sum + score);

    if (totalConfidence > 0) {
      for (final model in models) {
        final confidence = confidenceScores[model] ?? 0.5;
        weights[model] = confidence / totalConfidence;
      }
    } else {
      // Equal weights fallback
      final equalWeight = 1.0 / models.length;
      for (final model in models) {
        weights[model] = equalWeight;
      }
    }

    // Adjust weights based on complexity
    if (complexity > 0.8) {
      // Higher complexity: increase weight for high-confidence models
      final sortedEntries = weights.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedEntries.isNotEmpty) {
        final topModel = sortedEntries.first.key;
        weights[topModel] = (weights[topModel]! * 1.2).clamp(0.0, 1.0);

        // Normalize weights
        final totalWeight = weights.values.fold(0.0, (sum, weight) => sum + weight);
        for (final model in weights.keys) {
          weights[model] = weights[model]! / totalWeight;
        }
      }
    }

    return weights;
  }

  /// 📊 CALCULATE OVERALL CONFIDENCE
  double _calculateOverallConfidence(
      Map<String, double> confidenceScores,
      List<AILearningPattern> insights,
      double complexity,
      ) {
    double baseConfidence = 0.0;

    if (confidenceScores.isNotEmpty) {
      baseConfidence = confidenceScores.values.reduce((a, b) => a + b) / confidenceScores.length;
    }

    // Boost confidence if we have good learning patterns
    if (insights.isNotEmpty) {
      final bestPatternScore = insights.first.successScore;
      baseConfidence = (baseConfidence + bestPatternScore) / 2;
    }

    // Adjust for complexity
    if (complexity > 0.8) {
      baseConfidence *= 0.9; // Slightly reduce confidence for very complex prompts
    }

    return baseConfidence.clamp(0.0, 1.0);
  }

  /// 📝 GENERATE DECISION REASONING
  String _generateDecisionReasoning(
      PromptAnalysisResult promptAnalysis,
      List<AILearningPattern> insights,
      List<String> recommendedModels,
      String recommendedStrategy,
      double overallConfidence,
      ) {
    final reasoning = StringBuffer();

    reasoning.write('🧠 AI Analysis: Detected ${promptAnalysis.promptType} prompt with ');
    reasoning.write('${(promptAnalysis.complexity * 100).round()}% complexity. ');

    if (insights.isNotEmpty) {
      final pattern = insights.first;
      reasoning.write('📈 Learning Pattern: Found successful pattern with ');
      reasoning.write('${(pattern.successScore * 100).round()}% success rate (used ${pattern.usageCount} times). ');
    }

    reasoning.write('🎯 Recommendations: ${recommendedModels.join(', ')} using $recommendedStrategy strategy. ');
    reasoning.write('🔍 Confidence: ${(overallConfidence * 100).round()}% based on ');
    reasoning.write('${insights.isNotEmpty ? 'historical patterns and ' : ''}model specializations.');

    return reasoning.toString();
  }

  /// 🎯 AUTO-APPLY LOGIC
  bool shouldAutoApply(AIRecommendationResult recommendation) {
    if (!_isAutoModeEnabled) return false;

    return recommendation.overallConfidence >= _autoApplyThreshold;
  }

  /// 📚 LEARNING METHODS

  Future<void> recordOrchestrationOutcome({
    required String prompt,
    required List<String> usedModels,
    required String usedStrategy,
    required double qualityScore,
    Map<String, dynamic>? context,
  }) async {
    try {
      final promptAnalysis = await _miniLLMAnalyzer.analyzePrompt(prompt);

      final pattern = AILearningPattern(
        patternId: _generatePatternId(prompt, usedModels, usedStrategy),
        promptType: promptAnalysis.promptType,
        successfulModels: usedModels,
        successfulStrategy: usedStrategy,
        successScore: qualityScore,
        usageCount: 1,
        createdAt: DateTime.now(),
        lastUsedAt: DateTime.now(),
        context: context ?? {},
      );

      await _addOrUpdateLearningPattern(pattern);
      _logger.d('📚 Learning pattern recorded: ${pattern.patternId}');

    } catch (e) {
      _logger.e('❌ Failed to record orchestration outcome: $e');
    }
  }

  Future<void> _addOrUpdateLearningPattern(AILearningPattern newPattern) async {
    final existingIndex = _learningPatterns.indexWhere(
          (pattern) => pattern.patternId == newPattern.patternId,
    );

    if (existingIndex >= 0) {
      // Update existing pattern
      final existing = _learningPatterns[existingIndex];
      final updatedPattern = AILearningPattern(
        patternId: existing.patternId,
        promptType: existing.promptType,
        successfulModels: existing.successfulModels,
        successfulStrategy: existing.successfulStrategy,
        successScore: (existing.successScore * existing.usageCount + newPattern.successScore) /
            (existing.usageCount + 1),
        usageCount: existing.usageCount + 1,
        createdAt: existing.createdAt,
        lastUsedAt: DateTime.now(),
        context: newPattern.context,
      );

      _learningPatterns[existingIndex] = updatedPattern;
    } else {
      // Add new pattern
      _learningPatterns.add(newPattern);

      // Maintain maximum pattern count
      if (_learningPatterns.length > _maxLearningPatterns) {
        // Remove oldest patterns with lowest success scores
        _learningPatterns.sort((a, b) {
          final scoreComparison = a.successScore.compareTo(b.successScore);
          if (scoreComparison != 0) return scoreComparison;
          return a.lastUsedAt.compareTo(b.lastUsedAt);
        });
        _learningPatterns.removeAt(0);
      }
    }

    await _saveLearningPatterns();
    notifyListeners();
  }

  /// 💾 PERSISTENCE METHODS

  Future<void> _loadLearningPatterns() async {
    try {
      final patternsJson = await _storageService.getString('athena_learning_patterns');
      if (patternsJson != null) {
        final patternsList = jsonDecode(patternsJson) as List<dynamic>;
        _learningPatterns.clear();
        _learningPatterns.addAll(
            patternsList.map((json) => AILearningPattern.fromJson(json as Map<String, dynamic>))
        );

        // Remove expired patterns
        _learningPatterns.removeWhere((pattern) {
          return DateTime.now().difference(pattern.lastUsedAt) > _patternExpiryDuration;
        });
      }
    } catch (e) {
      _logger.w('⚠️ Failed to load learning patterns: $e');
    }
  }

  Future<void> _saveLearningPatterns() async {
    try {
      final patternsJson = jsonEncode(_learningPatterns.map((p) => p.toJson()).toList());
      await _storageService.setString('athena_learning_patterns', patternsJson);
    } catch (e) {
      _logger.w('⚠️ Failed to save learning patterns: $e');
    }
  }

  Future<void> _loadPerformanceHistory() async {
    try {
      final historyJson = await _storageService.getString('athena_performance_history');
      if (historyJson != null) {
        final history = Map<String, double>.from(jsonDecode(historyJson) as Map);
        _modelPerformanceHistory.addAll(history);
      }
    } catch (e) {
      _logger.w('⚠️ Failed to load performance history: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      _isAutoModeEnabled = await _storageService.getBool('athena_auto_mode') ?? false;
    } catch (e) {
      _logger.w('⚠️ Failed to load user preferences: $e');
    }
  }

  /// 🎛️ CONTROL METHODS

  Future<void> setAutoMode(bool enabled) async {
    _isAutoModeEnabled = enabled;
    await _storageService.setBool('athena_auto_mode', enabled);
    notifyListeners();

    _logger.i('🎛️ Auto mode ${enabled ? 'enabled' : 'disabled'}');
  }

  void recordUserOverride() {
    _userOverrides++;
    _logger.d('👤 User override recorded (total: $_userOverrides)');
  }

  void recordAutoApplication() {
    _autoAppliedRecommendations++;
    _logger.d('🤖 Auto-application recorded (total: $_autoAppliedRecommendations)');
  }

  /// 📊 ANALYTICS

  Map<String, dynamic> getAthenaAnalytics() {
    final avgDecisionTime = _decisionTimes.isNotEmpty
        ? _decisionTimes.fold<int>(0, (sum, time) => sum + time.inMilliseconds) / _decisionTimes.length
        : 0.0;

    return {
      'total_recommendations': _totalRecommendations,
      'auto_applied_recommendations': _autoAppliedRecommendations,
      'user_overrides': _userOverrides,
      'auto_mode_enabled': _isAutoModeEnabled,
      'learning_patterns_count': _learningPatterns.length,
      'average_decision_time_ms': avgDecisionTime,
      'auto_apply_rate': _totalRecommendations > 0 ? _autoAppliedRecommendations / _totalRecommendations : 0.0,
      'user_override_rate': _totalRecommendations > 0 ? _userOverrides / _totalRecommendations : 0.0,
      'strategy_usage': Map<String, int>.from(_strategyUsageCount),
      'strategy_success_rates': Map<String, double>.from(_strategySuccessRates),
      'last_recommendation_confidence': _lastRecommendation?.overallConfidence ?? 0.0,
    };
  }

  /// 🔧 UTILITY METHODS

  String _truncatePrompt(String prompt, {int maxLength = 50}) {
    return prompt.length > maxLength ? '${prompt.substring(0, maxLength)}...' : prompt;
  }

  String _generatePatternId(String prompt, List<String> models, String strategy) {
    final content = '$prompt|${models.join(',')}|$strategy';
    return content.hashCode.abs().toString();
  }

  String _getStrategyReasoning(String strategy, double complexity, int modelCount) {
    switch (strategy) {
      case 'parallel':
        return 'Parallel execution for diverse perspectives';
      case 'consensus':
        return 'Consensus needed for high complexity/accuracy';
      case 'weighted':
        return 'Weighted approach based on model strengths';
      case 'adaptive':
        return 'Adaptive strategy for optimal performance';
      default:
        return 'Standard orchestration approach';
    }
  }

  AIRecommendationResult _getFallbackRecommendation(String prompt, List<String> availableModels, Duration elapsed) {
    return AIRecommendationResult(
      recommendedModels: availableModels.take(2).toList(),
      recommendedStrategy: 'parallel',
      modelConfidenceScores: {
        for (final model in availableModels.take(3)) model: 0.6
      },
      recommendedWeights: {
        for (final model in availableModels.take(2)) model: 0.5
      },
      overallConfidence: 0.5,
      decisionReasoning: 'Fallback recommendation due to analysis error. Using conservative approach.',
      decisionTree: [
        DecisionTreeNode(
          id: 'fallback',
          question: 'System Error',
          answer: 'Using fallback recommendation system',
          confidence: 0.5,
          children: [],
          data: {'error_recovery': true},
        ),
      ],
      decisionTime: elapsed,
      metadata: {
        'analysis_method': 'fallback',
        'error_recovery': true,
        'available_models': availableModels.length,
      },
    );
  }

  /// 🧹 CLEANUP

  @override
  Future<void> dispose() async {
    try {
      await _saveLearningPatterns();
      _logger.i('✅ AthenaIntelligenceService disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing AthenaIntelligenceService: $e');
    }
    super.dispose();
  }
}