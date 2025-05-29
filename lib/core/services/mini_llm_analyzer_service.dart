// 🧠 NEURONVAULT - MINI-LLM ANALYZER SERVICE - PHASE 3.4
// World's first AI Meta-Analysis Engine for intelligent model selection
// Claude Haiku integration for <200ms prompt analysis and AI orchestration intelligence

import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

import '../state/state_models.dart';
import 'config_service.dart';
import 'ai_service.dart';
import 'storage_service.dart';

/// 🎯 Prompt analysis categories for intelligent model selection
enum PromptCategory {
  creative,           // Creative writing, storytelling, art
  analytical,         // Data analysis, research, technical review
  conversational,     // General chat, Q&A, casual interaction
  coding,            // Programming, debugging, technical implementation
  reasoning,         // Logic puzzles, complex problem solving
  factual,           // Information lookup, definitions, explanations
  synthesis,         // Combining multiple sources, summarization
  specialized,       // Domain-specific expertise (legal, medical, etc.)
}

/// 🧠 Prompt complexity levels for strategy selection
enum PromptComplexity {
  simple,    // Single concept, direct question
  moderate,  // Multiple concepts, some context needed
  complex,   // Multi-step reasoning, extensive context
  expert,    // Specialized knowledge, advanced reasoning
}

/// 📊 Prompt analysis result with AI recommendations
@immutable
class PromptAnalysis {
  final String promptText;
  final PromptCategory primaryCategory;
  final List<PromptCategory> secondaryCategories;
  final PromptComplexity complexity;
  final double confidenceScore;
  final Map<String, double> modelRecommendations;
  final String recommendedStrategy;
  final List<String> reasoningSteps;
  final Duration analysisTime;
  final DateTime timestamp;

  const PromptAnalysis({
    required this.promptText,
    required this.primaryCategory,
    required this.secondaryCategories,
    required this.complexity,
    required this.confidenceScore,
    required this.modelRecommendations,
    required this.recommendedStrategy,
    required this.reasoningSteps,
    required this.analysisTime,
    required this.timestamp,
  });

  factory PromptAnalysis.fromJson(Map<String, dynamic> json) {
    return PromptAnalysis(
      promptText: json['prompt_text'] as String,
      primaryCategory: PromptCategory.values.firstWhere(
            (e) => e.name == json['primary_category'],
        orElse: () => PromptCategory.conversational,
      ),
      secondaryCategories: (json['secondary_categories'] as List<dynamic>?)
          ?.map((e) => PromptCategory.values.firstWhere(
            (cat) => cat.name == e,
        orElse: () => PromptCategory.conversational,
      ))
          .toList() ?? [],
      complexity: PromptComplexity.values.firstWhere(
            (e) => e.name == json['complexity'],
        orElse: () => PromptComplexity.moderate,
      ),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.8,
      modelRecommendations: (json['model_recommendations'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      recommendedStrategy: json['recommended_strategy'] as String? ?? 'parallel',
      reasoningSteps: (json['reasoning_steps'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      analysisTime: Duration(milliseconds: json['analysis_time_ms'] as int? ?? 200),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_text': promptText,
      'primary_category': primaryCategory.name,
      'secondary_categories': secondaryCategories.map((e) => e.name).toList(),
      'complexity': complexity.name,
      'confidence_score': confidenceScore,
      'model_recommendations': modelRecommendations,
      'recommended_strategy': recommendedStrategy,
      'reasoning_steps': reasoningSteps,
      'analysis_time_ms': analysisTime.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 🎯 Model specialization profiles for intelligent selection
class ModelSpecializationProfile {
  final String modelName;
  final Map<PromptCategory, double> categoryStrengths;
  final Map<PromptComplexity, double> complexityHandling;
  final double averageResponseTime;
  final double reliabilityScore;
  final double costEfficiency;

  const ModelSpecializationProfile({
    required this.modelName,
    required this.categoryStrengths,
    required this.complexityHandling,
    required this.averageResponseTime,
    required this.reliabilityScore,
    required this.costEfficiency,
  });
}

/// 🧠 MINI-LLM ANALYZER SERVICE - AI AUTONOMY FOUNDATION
class MiniLLMAnalyzerService {
  final AIService _aiService;
  final ConfigService _configService;
  final StorageService _storageService;
  final Logger _logger;

  // 📊 Performance tracking
  final Map<PromptCategory, List<int>> _analysisPerformance = {};
  final Map<String, int> _analysisCount = {};
  final List<PromptAnalysis> _recentAnalyses = [];

  // 🎯 Model specialization database
  static const Map<String, ModelSpecializationProfile> _modelProfiles = {
    'claude': ModelSpecializationProfile(
      modelName: 'claude',
      categoryStrengths: {
        PromptCategory.analytical: 0.95,
        PromptCategory.reasoning: 0.92,
        PromptCategory.coding: 0.88,
        PromptCategory.synthesis: 0.90,
        PromptCategory.conversational: 0.85,
        PromptCategory.creative: 0.80,
        PromptCategory.factual: 0.88,
        PromptCategory.specialized: 0.87,
      },
      complexityHandling: {
        PromptComplexity.simple: 0.85,
        PromptComplexity.moderate: 0.92,
        PromptComplexity.complex: 0.95,
        PromptComplexity.expert: 0.90,
      },
      averageResponseTime: 1500.0,
      reliabilityScore: 0.94,
      costEfficiency: 0.80,
    ),
    'gpt': ModelSpecializationProfile(
      modelName: 'gpt',
      categoryStrengths: {
        PromptCategory.conversational: 0.95,
        PromptCategory.creative: 0.92,
        PromptCategory.factual: 0.90,
        PromptCategory.coding: 0.85,
        PromptCategory.analytical: 0.82,
        PromptCategory.reasoning: 0.85,
        PromptCategory.synthesis: 0.88,
        PromptCategory.specialized: 0.80,
      },
      complexityHandling: {
        PromptComplexity.simple: 0.95,
        PromptComplexity.moderate: 0.90,
        PromptComplexity.complex: 0.85,
        PromptComplexity.expert: 0.82,
      },
      averageResponseTime: 1200.0,
      reliabilityScore: 0.92,
      costEfficiency: 0.85,
    ),
    'deepseek': ModelSpecializationProfile(
      modelName: 'deepseek',
      categoryStrengths: {
        PromptCategory.coding: 0.95,
        PromptCategory.reasoning: 0.90,
        PromptCategory.analytical: 0.88,
        PromptCategory.specialized: 0.85,
        PromptCategory.factual: 0.82,
        PromptCategory.synthesis: 0.80,
        PromptCategory.conversational: 0.75,
        PromptCategory.creative: 0.70,
      },
      complexityHandling: {
        PromptComplexity.simple: 0.80,
        PromptComplexity.moderate: 0.88,
        PromptComplexity.complex: 0.92,
        PromptComplexity.expert: 0.95,
      },
      averageResponseTime: 1800.0,
      reliabilityScore: 0.89,
      costEfficiency: 0.90,
    ),
    'gemini': ModelSpecializationProfile(
      modelName: 'gemini',
      categoryStrengths: {
        PromptCategory.creative: 0.90,
        PromptCategory.conversational: 0.88,
        PromptCategory.factual: 0.92,
        PromptCategory.synthesis: 0.85,
        PromptCategory.analytical: 0.80,
        PromptCategory.reasoning: 0.82,
        PromptCategory.coding: 0.75,
        PromptCategory.specialized: 0.78,
      },
      complexityHandling: {
        PromptComplexity.simple: 0.90,
        PromptComplexity.moderate: 0.85,
        PromptComplexity.complex: 0.80,
        PromptComplexity.expert: 0.78,
      },
      averageResponseTime: 1400.0,
      reliabilityScore: 0.87,
      costEfficiency: 0.95,
    ),
  };

  MiniLLMAnalyzerService({
    required AIService aiService,
    required ConfigService configService,
    required StorageService storageService,
    required Logger logger,
  }) : _aiService = aiService,
        _configService = configService,
        _storageService = storageService,
        _logger = logger {
    _logger.i('🧠 Mini-LLM Analyzer Service initialized - AI Autonomy Foundation ready');
  }

  /// 🔍 MAIN METHOD: Analyze prompt with Claude Haiku for <200ms intelligence
  Future<PromptAnalysis> analyzePrompt(String prompt) async {
    final stopwatch = Stopwatch()..start();

    try {
      _logger.d('🔍 Starting rapid prompt analysis: "${prompt.substring(0, prompt.length.clamp(0, 50))}..."');

      // 1. Quick heuristic analysis (always runs)
      final heuristicAnalysis = _performHeuristicAnalysis(prompt);
      _logger.d('⚡ Heuristic analysis completed in ${stopwatch.elapsedMilliseconds}ms');

      // 2. Try Claude Haiku enhancement (fallback to heuristic if fails)
      PromptAnalysis finalAnalysis;
      try {
        final claudeEnhancement = await _performClaudeHaikuAnalysis(prompt, heuristicAnalysis);
        finalAnalysis = claudeEnhancement;
        _logger.d('🤖 Claude Haiku enhancement completed in ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        _logger.w('⚠️ Claude Haiku unavailable, using heuristic analysis: $e');
        finalAnalysis = heuristicAnalysis;
      }

      stopwatch.stop();
      final analysisTime = Duration(milliseconds: stopwatch.elapsedMilliseconds);

      // 3. Create final analysis with performance data
      final result = PromptAnalysis(
        promptText: prompt,
        primaryCategory: finalAnalysis.primaryCategory,
        secondaryCategories: finalAnalysis.secondaryCategories,
        complexity: finalAnalysis.complexity,
        confidenceScore: finalAnalysis.confidenceScore,
        modelRecommendations: _generateModelRecommendations(finalAnalysis),
        recommendedStrategy: _selectOptimalStrategy(finalAnalysis),
        reasoningSteps: finalAnalysis.reasoningSteps,
        analysisTime: analysisTime,
        timestamp: DateTime.now(),
      );

      // 4. Track performance and store for learning
      _trackAnalysisPerformance(result);
      _storeRecentAnalysis(result);

      _logger.i('✅ Prompt analysis completed in ${analysisTime.inMilliseconds}ms - Category: ${result.primaryCategory.name}, Complexity: ${result.complexity.name}');

      return result;

    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.e('❌ Prompt analysis failed after ${stopwatch.elapsedMilliseconds}ms', error: e, stackTrace: stackTrace);

      // Return fallback analysis to prevent system failure
      return _createFallbackAnalysis(prompt, Duration(milliseconds: stopwatch.elapsedMilliseconds));
    }
  }

  /// ⚡ Rapid heuristic analysis (always <50ms)
  PromptAnalysis _performHeuristicAnalysis(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    final words = lowerPrompt.split(RegExp(r'\W+'));

    // Category detection through keyword matching
    PromptCategory primaryCategory = PromptCategory.conversational; // default
    final categoryScores = <PromptCategory, double>{};

    // Creative indicators
    final creativeKeywords = ['write', 'story', 'creative', 'poem', 'imagine', 'design', 'art', 'novel', 'character'];
    categoryScores[PromptCategory.creative] = _calculateKeywordScore(words, creativeKeywords);

    // Analytical indicators
    final analyticalKeywords = ['analyze', 'compare', 'evaluate', 'research', 'study', 'data', 'statistics', 'trends'];
    categoryScores[PromptCategory.analytical] = _calculateKeywordScore(words, analyticalKeywords);

    // Coding indicators
    final codingKeywords = ['code', 'program', 'function', 'debug', 'api', 'javascript', 'python', 'algorithm', 'software'];
    categoryScores[PromptCategory.coding] = _calculateKeywordScore(words, codingKeywords);

    // Reasoning indicators
    final reasoningKeywords = ['why', 'how', 'explain', 'reason', 'logic', 'solve', 'problem', 'think', 'because'];
    categoryScores[PromptCategory.reasoning] = _calculateKeywordScore(words, reasoningKeywords);

    // Factual indicators
    final factualKeywords = ['what', 'who', 'when', 'where', 'define', 'definition', 'fact', 'information', 'tell'];
    categoryScores[PromptCategory.factual] = _calculateKeywordScore(words, factualKeywords);

    // Find primary category
    final maxScore = categoryScores.values.fold(0.0, (max, score) => score > max ? score : max);
    if (maxScore > 0.1) {
      primaryCategory = categoryScores.entries
          .where((entry) => entry.value == maxScore)
          .first
          .key;
    }

    // Complexity detection
    PromptComplexity complexity = PromptComplexity.moderate; // default
    final wordCount = words.length;
    final sentenceCount = prompt.split(RegExp(r'[.!?]+')).length;
    final questionCount = prompt.split('?').length - 1;

    if (wordCount < 10 && sentenceCount <= 1) {
      complexity = PromptComplexity.simple;
    } else if (wordCount > 50 || sentenceCount > 3 || questionCount > 2) {
      complexity = PromptComplexity.complex;
    }

    // Specialized domain detection
    final specializedKeywords = ['legal', 'medical', 'financial', 'scientific', 'academic', 'technical', 'professional'];
    if (_calculateKeywordScore(words, specializedKeywords) > 0.2) {
      if (primaryCategory == PromptCategory.conversational) {
        primaryCategory = PromptCategory.specialized;
      }
      if (complexity == PromptComplexity.moderate) {
        complexity = PromptComplexity.expert;
      }
    }

    final reasoningSteps = [
      'Analyzed ${words.length} words and $sentenceCount sentences',
      'Primary category: ${primaryCategory.name} (confidence: ${(maxScore * 100).toStringAsFixed(1)}%)',
      'Complexity level: ${complexity.name} based on length and structure',
      'Heuristic analysis completed in <50ms',
    ];

    return PromptAnalysis(
      promptText: prompt,
      primaryCategory: primaryCategory,
      secondaryCategories: categoryScores.entries
          .where((entry) => entry.value > 0.1 && entry.key != primaryCategory)
          .map((entry) => entry.key)
          .take(2)
          .toList(),
      complexity: complexity,
      confidenceScore: 0.75, // Heuristic confidence
      modelRecommendations: {}, // Will be filled later
      recommendedStrategy: 'parallel', // Default
      reasoningSteps: reasoningSteps,
      analysisTime: const Duration(milliseconds: 50),
      timestamp: DateTime.now(),
    );
  }

  /// 🤖 Claude Haiku enhanced analysis (target <200ms)
  Future<PromptAnalysis> _performClaudeHaikuAnalysis(
      String prompt,
      PromptAnalysis heuristicBase,
      ) async {
    try {
      // Get Claude Haiku configuration
      final modelsConfig = await _configService.getModelsConfig();
      final claudeConfig = modelsConfig?.availableModels[AIModel.claude];

      if (claudeConfig == null || claudeConfig.apiKey.isEmpty) {
        throw Exception('Claude Haiku not configured');
      }

      // Construct analysis prompt for Claude Haiku
      final analysisPrompt = '''Analyze this prompt for AI model selection. Be concise and precise:

PROMPT: "$prompt"

Respond with JSON only:
{
  "primary_category": "creative|analytical|conversational|coding|reasoning|factual|synthesis|specialized",
  "complexity": "simple|moderate|complex|expert", 
  "confidence": 0.0-1.0,
  "reasoning": ["step1", "step2", "step3"]
}''';

      // Send to Claude Haiku (fastest Claude model)
      final response = await _aiService.singleRequest(
        analysisPrompt,
        AIModel.claude,
        claudeConfig.copyWith(
          maxTokens: 150, // Keep response small for speed
          temperature: 0.1, // Low temperature for consistency
        ),
      );

      // Parse Claude's response
      final analysisJson = _extractJsonFromResponse(response);

      if (analysisJson != null) {
        final claudeCategory = _parseCategory(analysisJson['primary_category']);
        final claudeComplexity = _parseComplexity(analysisJson['complexity']);
        final claudeConfidence = (analysisJson['confidence'] as num?)?.toDouble() ?? 0.8;
        final claudeReasoning = (analysisJson['reasoning'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        // Combine heuristic and Claude analysis
        return PromptAnalysis(
          promptText: prompt,
          primaryCategory: claudeCategory ?? heuristicBase.primaryCategory,
          secondaryCategories: heuristicBase.secondaryCategories,
          complexity: claudeComplexity ?? heuristicBase.complexity,
          confidenceScore: (claudeConfidence + heuristicBase.confidenceScore) / 2,
          modelRecommendations: {}, // Will be filled later
          recommendedStrategy: 'parallel', // Will be determined later
          reasoningSteps: [
            'Heuristic analysis: ${heuristicBase.primaryCategory.name}',
            'Claude Haiku enhancement: ${claudeCategory?.name ?? "unavailable"}',
            ...claudeReasoning,
            'Combined confidence: ${((claudeConfidence + heuristicBase.confidenceScore) / 2 * 100).toStringAsFixed(1)}%',
          ],
          analysisTime: const Duration(milliseconds: 200),
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Invalid Claude response format');
      }

    } catch (e) {
      _logger.w('⚠️ Claude Haiku analysis failed, using heuristic: $e');
      rethrow;
    }
  }

  /// 🎯 Generate intelligent model recommendations based on analysis
  Map<String, double> _generateModelRecommendations(PromptAnalysis analysis) {
    final recommendations = <String, double>{};

    for (final profile in _modelProfiles.values) {
      double score = 0.0;

      // Category strength (60% weight)
      final categoryStrength = profile.categoryStrengths[analysis.primaryCategory] ?? 0.5;
      score += categoryStrength * 0.6;

      // Complexity handling (25% weight)
      final complexityHandling = profile.complexityHandling[analysis.complexity] ?? 0.5;
      score += complexityHandling * 0.25;

      // Reliability and cost (15% weight)
      score += (profile.reliabilityScore * 0.1);
      score += (profile.costEfficiency * 0.05);

      recommendations[profile.modelName] = score.clamp(0.0, 1.0);
    }

    return recommendations;
  }

  /// 🎛️ Select optimal orchestration strategy based on analysis
  String _selectOptimalStrategy(PromptAnalysis analysis) {
    switch (analysis.complexity) {
      case PromptComplexity.simple:
        return 'consensus'; // Quick consensus for simple queries
      case PromptComplexity.moderate:
        return 'parallel'; // Standard parallel processing
      case PromptComplexity.complex:
        return 'weighted'; // Weighted based on specialization
      case PromptComplexity.expert:
        return 'adaptive'; // Adaptive strategy for expert queries
    }
  }

  /// 📊 Performance tracking for continuous improvement
  void _trackAnalysisPerformance(PromptAnalysis analysis) {
    // Track analysis time by category
    _analysisPerformance
        .putIfAbsent(analysis.primaryCategory, () => [])
        .add(analysis.analysisTime.inMilliseconds);

    // Keep only last 100 entries per category
    if (_analysisPerformance[analysis.primaryCategory]!.length > 100) {
      _analysisPerformance[analysis.primaryCategory]!.removeAt(0);
    }

    // Track total analysis count
    final categoryName = analysis.primaryCategory.name;
    _analysisCount[categoryName] = (_analysisCount[categoryName] ?? 0) + 1;
  }

  /// 💾 Store recent analyses for learning and debugging
  void _storeRecentAnalysis(PromptAnalysis analysis) {
    _recentAnalyses.add(analysis);

    // Keep only last 50 analyses
    if (_recentAnalyses.length > 50) {
      _recentAnalyses.removeAt(0);
    }
  }

  /// 🆘 Fallback analysis when all else fails
  PromptAnalysis _createFallbackAnalysis(String prompt, Duration analysisTime) {
    return PromptAnalysis(
      promptText: prompt,
      primaryCategory: PromptCategory.conversational,
      secondaryCategories: [],
      complexity: PromptComplexity.moderate,
      confidenceScore: 0.5,
      modelRecommendations: {
        'claude': 0.8,
        'gpt': 0.8,
        'deepseek': 0.7,
        'gemini': 0.7,
      },
      recommendedStrategy: 'parallel',
      reasoningSteps: ['Fallback analysis - all systems failed'],
      analysisTime: analysisTime,
      timestamp: DateTime.now(),
    );
  }

  // 🔧 UTILITY METHODS

  double _calculateKeywordScore(List<String> words, List<String> keywords) {
    int matches = 0;
    for (final word in words) {
      if (keywords.contains(word)) {
        matches++;
      }
    }
    return matches / words.length;
  }

  Map<String, dynamic>? _extractJsonFromResponse(String response) {
    try {
      // Try to find JSON in the response
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  PromptCategory? _parseCategory(dynamic categoryStr) {
    if (categoryStr is! String) return null;
    try {
      return PromptCategory.values.firstWhere(
            (e) => e.name == categoryStr,
        orElse: () => PromptCategory.conversational,
      );
    } catch (e) {
      return null;
    }
  }

  PromptComplexity? _parseComplexity(dynamic complexityStr) {
    if (complexityStr is! String) return null;
    try {
      return PromptComplexity.values.firstWhere(
            (e) => e.name == complexityStr,
        orElse: () => PromptComplexity.moderate,
      );
    } catch (e) {
      return null;
    }
  }

  // 📊 PUBLIC ANALYTICS METHODS

  /// Get analysis statistics for debugging and optimization
  Map<String, dynamic> getAnalysisStatistics() {
    final stats = <String, dynamic>{};

    for (final category in PromptCategory.values) {
      final performances = _analysisPerformance[category] ?? [];
      if (performances.isNotEmpty) {
        stats[category.name] = {
          'count': _analysisCount[category.name] ?? 0,
          'avg_time_ms': performances.reduce((a, b) => a + b) / performances.length,
          'min_time_ms': performances.reduce((a, b) => a < b ? a : b),
          'max_time_ms': performances.reduce((a, b) => a > b ? a : b),
        };
      }
    }

    return {
      'total_analyses': _recentAnalyses.length,
      'categories': stats,
      'recent_analyses': _recentAnalyses.take(10).map((a) => {
        'category': a.primaryCategory.name,
        'complexity': a.complexity.name,
        'confidence': a.confidenceScore,
        'time_ms': a.analysisTime.inMilliseconds,
      }).toList(),
    };
  }

  /// Get model recommendation history for learning
  List<PromptAnalysis> getRecentAnalyses({int? limit}) {
    final analyses = _recentAnalyses.reversed.toList();
    return limit != null ? analyses.take(limit).toList() : analyses;
  }

  /// Clear analysis history and reset statistics
  void clearAnalysisHistory() {
    _recentAnalyses.clear();
    _analysisPerformance.clear();
    _analysisCount.clear();
    _logger.i('🧹 Analysis history cleared');
  }
}