// 🧠 NEURONVAULT - MINI-LLM ANALYZER SERVICE
// PHASE 3.4: Athena Intelligence Engine - Mini-LLM Prompt Analysis
// Revolutionary AI meta-analysis for intelligent model selection

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../state/state_models.dart';
import 'ai_service.dart';
import 'config_service.dart';

/// 🎯 PROMPT ANALYSIS RESULT
class PromptAnalysis {
  final String promptType;
  final String complexity;
  final double creativityRequired;
  final double technicalDepth;
  final double reasoningComplexity;
  final List<String> recommendedModels;
  final List<String> keyTopics;
  final Map<String, double> modelScores;
  final String recommendedStrategy;
  final double confidence;
  final Duration estimatedTime;

  const PromptAnalysis({
    required this.promptType,
    required this.complexity,
    required this.creativityRequired,
    required this.technicalDepth,
    required this.reasoningComplexity,
    required this.recommendedModels,
    required this.keyTopics,
    required this.modelScores,
    required this.recommendedStrategy,
    required this.confidence,
    required this.estimatedTime,
  });

  factory PromptAnalysis.fromJson(Map<String, dynamic> json) {
    return PromptAnalysis(
      promptType: json['prompt_type'] as String? ?? 'general',
      complexity: json['complexity'] as String? ?? 'medium',
      creativityRequired: (json['creativity_required'] as num?)?.toDouble() ?? 0.5,
      technicalDepth: (json['technical_depth'] as num?)?.toDouble() ?? 0.5,
      reasoningComplexity: (json['reasoning_complexity'] as num?)?.toDouble() ?? 0.5,
      recommendedModels: List<String>.from(json['recommended_models'] as List? ?? []),
      keyTopics: List<String>.from(json['key_topics'] as List? ?? []),
      modelScores: Map<String, double>.from(
        (json['model_scores'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      recommendedStrategy: json['recommended_strategy'] as String? ?? 'parallel',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
      estimatedTime: Duration(
        milliseconds: json['estimated_time_ms'] as int? ?? 2000,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_type': promptType,
      'complexity': complexity,
      'creativity_required': creativityRequired,
      'technical_depth': technicalDepth,
      'reasoning_complexity': reasoningComplexity,
      'recommended_models': recommendedModels,
      'key_topics': keyTopics,
      'model_scores': modelScores,
      'recommended_strategy': recommendedStrategy,
      'confidence': confidence,
      'estimated_time_ms': estimatedTime.inMilliseconds,
    };
  }
}

/// 🧠 MINI-LLM ANALYZER SERVICE
/// Uses Claude Haiku for fast prompt analysis and intelligent model recommendations
class MiniLLMAnalyzerService {
  final AIService _aiService;
  final ConfigService _configService;
  final Logger _logger;

  // 📊 Analysis cache to avoid redundant calls
  final Map<String, PromptAnalysis> _analysisCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);

  // 🎯 Model specialization profiles
  static const Map<String, Map<String, double>> _modelProfiles = {
    'claude': {
      'reasoning': 0.95,
      'creativity': 0.85,
      'technical': 0.90,
      'analysis': 0.95,
      'writing': 0.90,
      'coding': 0.85,
      'math': 0.80,
    },
    'gpt': {
      'reasoning': 0.85,
      'creativity': 0.90,
      'technical': 0.85,
      'analysis': 0.80,
      'writing': 0.88,
      'coding': 0.90,
      'math': 0.85,
    },
    'deepseek': {
      'reasoning': 0.80,
      'creativity': 0.70,
      'technical': 0.95,
      'analysis': 0.85,
      'writing': 0.75,
      'coding': 0.95,
      'math': 0.90,
    },
    'gemini': {
      'reasoning': 0.85,
      'creativity': 0.85,
      'technical': 0.80,
      'analysis': 0.85,
      'writing': 0.80,
      'coding': 0.80,
      'math': 0.85,
    },
    'mistral': {
      'reasoning': 0.80,
      'creativity': 0.75,
      'technical': 0.85,
      'analysis': 0.80,
      'writing': 0.80,
      'coding': 0.85,
      'math': 0.80,
    },
  };

  MiniLLMAnalyzerService({
    required AIService aiService,
    required ConfigService configService,
    required Logger logger,
  })  : _aiService = aiService,
        _configService = configService,
        _logger = logger {
    _logger.i('🧠 Mini-LLM Analyzer Service initialized with Athena Intelligence');
  }

  /// 🎯 ANALYZE PROMPT - Main method for intelligent prompt analysis
  Future<PromptAnalysis> analyzePrompt(String prompt) async {
    try {
      _logger.d('🧠 Analyzing prompt: "${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}..."');

      // Check cache first
      final cacheKey = _generateCacheKey(prompt);
      if (_isCacheValid(cacheKey)) {
        _logger.d('💾 Using cached analysis');
        return _analysisCache[cacheKey]!;
      }

      // Perform analysis
      final stopwatch = Stopwatch()..start();
      final analysis = await _performAnalysis(prompt);
      stopwatch.stop();

      // Cache result
      _analysisCache[cacheKey] = analysis;
      _cacheTimestamps[cacheKey] = DateTime.now();

      _logger.i('✅ Prompt analysis completed in ${stopwatch.elapsedMilliseconds}ms');
      _logger.d('🎯 Recommended models: ${analysis.recommendedModels.join(', ')}');
      _logger.d('📊 Confidence: ${(analysis.confidence * 100).round()}%');

      return analysis;

    } catch (e, stackTrace) {
      _logger.e('❌ Prompt analysis failed', error: e, stackTrace: stackTrace);
      return _createFallbackAnalysis(prompt);
    }
  }

  /// 🔍 PERFORM ANALYSIS - Core analysis logic
  Future<PromptAnalysis> _performAnalysis(String prompt) async {
    // Try Mini-LLM analysis first (Claude Haiku)
    try {
      final claudeConfig = await _configService.getModelConfig(AIModel.claude);
      if (claudeConfig.apiKey.isNotEmpty) {
        return await _performClaudeHaikuAnalysis(prompt, claudeConfig);
      }
    } catch (e) {
      _logger.w('⚠️ Claude Haiku analysis failed, falling back to heuristic: $e');
    }

    // Fallback to advanced heuristic analysis
    return await _performHeuristicAnalysis(prompt);
  }

  /// 🤖 CLAUDE HAIKU ANALYSIS - Premium AI-powered analysis
  Future<PromptAnalysis> _performClaudeHaikuAnalysis(String prompt, ModelConfig config) async {
    final analysisPrompt = _buildAnalysisPrompt(prompt);

    try {
      final response = await _aiService.singleRequest(
        analysisPrompt,
        AIModel.claude,
        config.copyWith(
          modelName: 'claude-3-haiku-20240307', // Use fast Haiku model
          maxTokens: 500, // Keep it concise
          temperature: 0.3, // Low temperature for consistent analysis
        ),
      );

      return _parseClaudeResponse(response, prompt);

    } catch (e) {
      _logger.w('⚠️ Claude Haiku request failed: $e');
      rethrow;
    }
  }

  /// 📝 BUILD ANALYSIS PROMPT - Structured prompt for Claude Haiku
  String _buildAnalysisPrompt(String userPrompt) {
    return '''Analyze this user prompt for AI model selection. Respond with ONLY a JSON object:

USER PROMPT: "$userPrompt"

Analyze and respond with this exact JSON structure:
{
  "prompt_type": "creative|technical|analytical|conversational|mixed",
  "complexity": "simple|medium|complex|expert",
  "creativity_required": 0.0-1.0,
  "technical_depth": 0.0-1.0,
  "reasoning_complexity": 0.0-1.0,
  "key_topics": ["topic1", "topic2", "topic3"],
  "model_scores": {
    "claude": 0.0-1.0,
    "gpt": 0.0-1.0,
    "deepseek": 0.0-1.0,
    "gemini": 0.0-1.0,
    "mistral": 0.0-1.0
  },
  "recommended_models": ["model1", "model2", "model3"],
  "recommended_strategy": "parallel|consensus|weighted|adaptive|sequential",
  "confidence": 0.0-1.0,
  "estimated_time_ms": 1000-5000
}

Consider:
- Claude: Best for reasoning, analysis, writing
- GPT: Best for creativity, general tasks, coding
- DeepSeek: Best for technical/coding tasks
- Gemini: Good all-rounder with creative capabilities
- Mistral: Efficient for focused technical tasks

Respond with ONLY the JSON, no other text.''';
  }

  /// 🔍 PARSE CLAUDE RESPONSE - Extract structured analysis from Claude
  PromptAnalysis _parseClaudeResponse(String response, String originalPrompt) {
    try {
      // Clean response and extract JSON
      final cleanedResponse = response.trim();
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(cleanedResponse);

      if (jsonMatch == null) {
        throw Exception('No JSON found in Claude response');
      }

      final jsonString = jsonMatch.group(0)!;
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return PromptAnalysis.fromJson(jsonData);

    } catch (e) {
      _logger.w('⚠️ Failed to parse Claude response: $e');
      _logger.d('Raw response: $response');
      throw Exception('Failed to parse analysis response: $e');
    }
  }

  /// 🧮 HEURISTIC ANALYSIS - Advanced fallback analysis
  Future<PromptAnalysis> _performHeuristicAnalysis(String prompt) async {
    _logger.d('🧮 Performing heuristic analysis');

    final promptLower = prompt.toLowerCase();
    final words = promptLower.split(RegExp(r'\W+'));

    // 🎯 Detect prompt characteristics
    final characteristics = _analyzePromptCharacteristics(promptLower, words);

    // 📊 Calculate model scores
    final modelScores = _calculateModelScores(characteristics);

    // 🏆 Select top models
    final rankedModels = modelScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recommendedModels = rankedModels
        .take(3)
        .map((e) => e.key)
        .toList();

    // 🎯 Determine strategy
    final strategy = _determineOptimalStrategy(characteristics);

    return PromptAnalysis(
      promptType: characteristics['prompt_type'] as String,
      complexity: characteristics['complexity'] as String,
      creativityRequired: characteristics['creativity_required'] as double,
      technicalDepth: characteristics['technical_depth'] as double,
      reasoningComplexity: characteristics['reasoning_complexity'] as double,
      recommendedModels: recommendedModels,
      keyTopics: characteristics['key_topics'] as List<String>,
      modelScores: modelScores,
      recommendedStrategy: strategy,
      confidence: 0.75, // Heuristic confidence
      estimatedTime: _estimateProcessingTime(characteristics),
    );
  }

  /// 📊 ANALYZE PROMPT CHARACTERISTICS
  Map<String, dynamic> _analyzePromptCharacteristics(String promptLower, List<String> words) {
    // 🎨 Creative indicators
    final creativeWords = ['creative', 'imagine', 'story', 'write', 'design', 'art', 'poem', 'novel'];
    final creativityScore = _calculateWordScore(words, creativeWords);

    // 🔧 Technical indicators
    final technicalWords = ['code', 'algorithm', 'function', 'debug', 'api', 'database', 'programming', 'technical'];
    final technicalScore = _calculateWordScore(words, technicalWords);

    // 🧮 Reasoning indicators
    final reasoningWords = ['analyze', 'compare', 'explain', 'why', 'how', 'evaluate', 'assess', 'reason'];
    final reasoningScore = _calculateWordScore(words, reasoningWords);

    // 🎯 Determine prompt type
    String promptType = 'conversational';
    if (technicalScore > 0.3) promptType = 'technical';
    else if (creativityScore > 0.3) promptType = 'creative';
    else if (reasoningScore > 0.3) promptType = 'analytical';
    else if (creativityScore > 0.1 && technicalScore > 0.1) promptType = 'mixed';

    // 📊 Determine complexity
    String complexity = 'medium';
    if (words.length < 10) complexity = 'simple';
    else if (words.length > 50) complexity = 'complex';
    else if (words.length > 100) complexity = 'expert';

    // 🔍 Extract key topics
    final keyTopics = _extractKeyTopics(words);

    return {
      'prompt_type': promptType,
      'complexity': complexity,
      'creativity_required': creativityScore,
      'technical_depth': technicalScore,
      'reasoning_complexity': reasoningScore,
      'key_topics': keyTopics,
    };
  }

  /// 📊 CALCULATE MODEL SCORES
  Map<String, double> _calculateModelScores(Map<String, dynamic> characteristics) {
    final scores = <String, double>{};

    for (final modelName in _modelProfiles.keys) {
      final profile = _modelProfiles[modelName]!;

      double score = 0.0;

      // Base compatibility score
      score += profile['reasoning']! * characteristics['reasoning_complexity'] * 0.3;
      score += profile['creativity']! * characteristics['creativity_required'] * 0.3;
      score += profile['technical']! * characteristics['technical_depth'] * 0.3;

      // Prompt type bonus
      switch (characteristics['prompt_type']) {
        case 'creative':
          score += profile['creativity']! * 0.1;
          break;
        case 'technical':
          score += profile['technical']! * 0.1;
          break;
        case 'analytical':
          score += profile['analysis']! * 0.1;
          break;
      }

      scores[modelName] = score.clamp(0.0, 1.0);
    }

    return scores;
  }

  /// 🎯 DETERMINE OPTIMAL STRATEGY
  String _determineOptimalStrategy(Map<String, dynamic> characteristics) {
    final complexity = characteristics['complexity'] as String;
    final promptType = characteristics['prompt_type'] as String;

    switch (complexity) {
      case 'simple':
        return 'parallel';
      case 'expert':
        return 'consensus';
      default:
        switch (promptType) {
          case 'creative':
            return 'weighted';
          case 'technical':
            return 'sequential';
          default:
            return 'adaptive';
        }
    }
  }

  /// ⏱️ ESTIMATE PROCESSING TIME
  Duration _estimateProcessingTime(Map<String, dynamic> characteristics) {
    final complexity = characteristics['complexity'] as String;

    switch (complexity) {
      case 'simple':
        return const Duration(milliseconds: 1500);
      case 'medium':
        return const Duration(milliseconds: 2500);
      case 'complex':
        return const Duration(milliseconds: 4000);
      case 'expert':
        return const Duration(milliseconds: 6000);
      default:
        return const Duration(milliseconds: 2500);
    }
  }

  /// 🔍 UTILITY METHODS
  double _calculateWordScore(List<String> words, List<String> indicators) {
    final matches = words.where((word) =>
        indicators.any((indicator) => word.contains(indicator))
    ).length;
    return (matches / words.length).clamp(0.0, 1.0);
  }

  List<String> _extractKeyTopics(List<String> words) {
    final topics = <String>[];
    final topicWords = ['ai', 'machine', 'learning', 'data', 'science', 'web', 'mobile', 'design'];

    for (final word in words) {
      for (final topic in topicWords) {
        if (word.contains(topic) && !topics.contains(topic)) {
          topics.add(topic);
        }
      }
    }

    return topics.take(5).toList();
  }

  /// 💾 CACHE MANAGEMENT
  String _generateCacheKey(String prompt) {
    return prompt.hashCode.toString();
  }

  bool _isCacheValid(String cacheKey) {
    if (!_analysisCache.containsKey(cacheKey)) return false;

    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// 🚨 FALLBACK ANALYSIS
  PromptAnalysis _createFallbackAnalysis(String prompt) {
    _logger.w('🚨 Creating fallback analysis');

    return PromptAnalysis(
      promptType: 'general',
      complexity: 'medium',
      creativityRequired: 0.5,
      technicalDepth: 0.5,
      reasoningComplexity: 0.5,
      recommendedModels: ['claude', 'gpt', 'deepseek'],
      keyTopics: ['general'],
      modelScores: {
        'claude': 0.85,
        'gpt': 0.80,
        'deepseek': 0.75,
        'gemini': 0.80,
        'mistral': 0.70,
      },
      recommendedStrategy: 'parallel',
      confidence: 0.6,
      estimatedTime: const Duration(milliseconds: 2500),
    );
  }

  /// 🧹 CLEANUP
  void clearCache() {
    _analysisCache.clear();
    _cacheTimestamps.clear();
    _logger.i('🧹 Analysis cache cleared');
  }

  void dispose() {
    clearCache();
    _logger.d('🧹 Mini-LLM Analyzer Service disposed');
  }
}