// test/unit/mocks/test_data.dart
// 🧪 NEURONVAULT - COMPREHENSIVE TEST DATA FACTORY
// Enterprise-grade test data generation for all components
// Supports PHASE 3.4 - Athena AI Integration + Achievement System

import 'package:flutter/material.dart' hide ConnectionState;
import '../../../lib/core/state/state_models.dart';

/// 🏭 Comprehensive Test Data Factory
/// Generates realistic test data for all NeuronVault components
class TestDataFactory {
  static int _messageCounter = 0;
  static int _achievementCounter = 0;
  static int _requestCounter = 0;

  // 🎲 UTILITIES
  static String generateTestId([String prefix = 'test']) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${_requestCounter++}';
  }

  static DateTime generateRandomPastDate([int maxDaysAgo = 30]) {
    final now = DateTime.now();
    final daysAgo = (DateTime.now().millisecondsSinceEpoch % maxDaysAgo) + 1;
    return now.subtract(Duration(days: daysAgo));
  }

  // 💬 CHAT MESSAGE TEST DATA
  static ChatMessage createUserMessage({
    String? id,
    String? content,
    DateTime? timestamp,
    String? requestId,
  }) {
    return ChatMessage(
      id: id ?? generateTestId('user_msg'),
      content: content ?? 'Test user message ${++_messageCounter}',
      type: MessageType.user,
      timestamp: timestamp ?? DateTime.now(),
      requestId: requestId,
      metadata: {
        'test': true,
        'counter': _messageCounter,
      },
    );
  }

  static ChatMessage createAssistantMessage({
    String? id,
    String? content,
    DateTime? timestamp,
    AIModel? sourceModel,
    String? requestId,
  }) {
    return ChatMessage(
      id: id ?? generateTestId('assistant_msg'),
      content: content ?? 'Test assistant response ${++_messageCounter}',
      type: MessageType.assistant,
      timestamp: timestamp ?? DateTime.now(),
      sourceModel: sourceModel ?? AIModel.claude,
      requestId: requestId,
      metadata: {
        'test': true,
        'counter': _messageCounter,
        'model': sourceModel?.name ?? 'claude',
      },
    );
  }

  static ChatMessage createErrorMessage({
    String? id,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? generateTestId('error_msg'),
      content: content ?? 'Test error message ${++_messageCounter}',
      type: MessageType.error,
      timestamp: timestamp ?? DateTime.now(),
      isError: true,
      metadata: {
        'test': true,
        'error_type': 'test_error',
      },
    );
  }

  static List<ChatMessage> createChatHistory({int messageCount = 10}) {
    final messages = <ChatMessage>[];
    final baseTime = DateTime.now().subtract(const Duration(hours: 1));

    for (int i = 0; i < messageCount; i++) {
      final timestamp = baseTime.add(Duration(minutes: i * 2));

      if (i % 2 == 0) {
        messages.add(createUserMessage(
          content: 'User message $i',
          timestamp: timestamp,
        ));
      } else {
        messages.add(createAssistantMessage(
          content: 'Assistant response to message ${i - 1}',
          timestamp: timestamp.add(const Duration(seconds: 30)),
          sourceModel: AIModel.values[i % AIModel.values.length],
        ));
      }
    }

    return messages;
  }

  // 🤖 AI MODEL CONFIGURATION TEST DATA
  static ModelConfig createModelConfig({
    String? name,
    String? apiKey,
    String? baseUrl,
    bool enabled = true,
    double weight = 1.0,
    int maxTokens = 4000,
    double temperature = 0.7,
  }) {
    return ModelConfig(
      name: name ?? 'test-model',
      apiKey: apiKey ?? 'test_api_key_${generateTestId()}',
      baseUrl: baseUrl ?? 'https://api.test.com',
      enabled: enabled,
      weight: weight,
      maxTokens: maxTokens,
      temperature: temperature,
      parameters: {
        'test': true,
        'provider': 'test',
      },
    );
  }

  static ModelHealth createModelHealth({
    HealthStatus status = HealthStatus.healthy,
    int responseTime = 150,
    double successRate = 0.95,
    int totalRequests = 100,
    int failedRequests = 5,
  }) {
    return ModelHealth(
      status: status,
      responseTime: responseTime,
      successRate: successRate,
      totalRequests: totalRequests,
      failedRequests: failedRequests,
      lastCheck: DateTime.now(),
    );
  }

  static ModelsState createModelsState({
    Map<AIModel, ModelConfig>? models,
    Map<AIModel, bool>? activeModels,
    double totalBudgetUsed = 15.50,
    double budgetLimit = 100.0,
  }) {
    final defaultModels = models ?? {
      AIModel.claude: createModelConfig(name: 'claude-3-sonnet'),
      AIModel.gpt: createModelConfig(name: 'gpt-4-turbo'),
      AIModel.deepseek: createModelConfig(name: 'deepseek-chat'),
      AIModel.gemini: createModelConfig(name: 'gemini-pro'),
    };

    final defaultActiveModels = activeModels ?? {
      AIModel.claude: true,
      AIModel.gpt: true,
      AIModel.deepseek: false,
      AIModel.gemini: true,
    };

    return ModelsState(
      availableModels: defaultModels,
      activeModels: defaultActiveModels,
      totalBudgetUsed: totalBudgetUsed,
      budgetLimit: budgetLimit,
      lastHealthCheck: DateTime.now(),
    );
  }

  // 🎛️ STRATEGY & ORCHESTRATION TEST DATA
  static StrategyState createStrategyState({
    OrchestrationStrategy strategy = OrchestrationStrategy.parallel,
    Map<AIModel, double>? modelWeights,
    bool isProcessing = false,
    double confidenceThreshold = 0.8,
  }) {
    final defaultWeights = modelWeights ?? {
      AIModel.claude: 1.0,
      AIModel.gpt: 0.9,
      AIModel.deepseek: 0.7,
      AIModel.gemini: 0.8,
    };

    return StrategyState(
      activeStrategy: strategy,
      modelWeights: defaultWeights,
      isProcessing: isProcessing,
      confidenceThreshold: confidenceThreshold,
      maxConcurrentRequests: 5,
      timeoutSeconds: 30,
    );
  }

  static AIResponse createAIResponse({
    String? modelName,
    String? content,
    DateTime? timestamp,
    String? requestId,
    double confidence = 0.9,
  }) {
    return AIResponse(
      modelName: modelName ?? 'test-model',
      content: content ?? 'Test AI response content',
      timestamp: timestamp ?? DateTime.now(),
      requestId: requestId,
      confidence: confidence,
      metadata: {
        'test': true,
        'tokens': 150,
        'cost': 0.002,
      },
    );
  }

  static OrchestrationProgress createOrchestrationProgress({
    String? requestId,
    int completedModels = 2,
    int totalModels = 4,
    List<String>? activeModels,
  }) {
    return OrchestrationProgress(
      requestId: requestId ?? generateTestId('orchestration'),
      completedModels: completedModels,
      totalModels: totalModels,
      activeModels: activeModels ?? ['claude', 'gpt', 'gemini'],
      startTime: DateTime.now().subtract(const Duration(seconds: 30)),
      estimatedCompletion: DateTime.now().add(const Duration(seconds: 10)),
    );
  }

  // 🌐 CONNECTION TEST DATA
  static ConnectionState createConnectionState({
    ConnectionStatus status = ConnectionStatus.connected,
    String serverUrl = 'localhost',
    int port = 8080,
    int latencyMs = 85,
  }) {
    return ConnectionState(
      status: status,
      serverUrl: serverUrl,
      port: port,
      latencyMs: latencyMs,
      reconnectAttempts: 0,
      maxReconnects: 3,
      lastConnectionTime: DateTime.now(),
    );
  }

  // 💬 CHAT STATE TEST DATA
  static ChatState createChatState({
    List<ChatMessage>? messages,
    String currentInput = '',
    bool isTyping = false,
    bool isGenerating = false,
    String? activeRequestId,
  }) {
    final defaultMessages = messages ?? createChatHistory(messageCount: 5);

    return ChatState(
      messages: defaultMessages,
      currentInput: currentInput,
      isTyping: isTyping,
      isGenerating: isGenerating,
      activeRequestId: activeRequestId,
      messageCount: defaultMessages.length,
      lastMessageTime: defaultMessages.isNotEmpty ? defaultMessages.last.timestamp : null,
    );
  }

  // 🏆 ACHIEVEMENT SYSTEM TEST DATA
  static Achievement createAchievement({
    String? id,
    String? title,
    String? description,
    AchievementCategory category = AchievementCategory.exploration,
    AchievementRarity rarity = AchievementRarity.common,
    bool isUnlocked = false,
    int currentProgress = 0,
    int targetProgress = 1,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? generateTestId('achievement'),
      title: title ?? 'Test Achievement ${++_achievementCounter}',
      description: description ?? 'Test achievement description for testing',
      category: category,
      rarity: rarity,
      isUnlocked: isUnlocked,
      currentProgress: currentProgress,
      targetProgress: targetProgress,
      unlockedAt: isUnlocked ? (unlockedAt ?? DateTime.now()) : null,
      metadata: {
        'test': true,
        'points': _getAchievementPoints(rarity),
      },
    );
  }

  static AchievementProgress createAchievementProgress({
    String? achievementId,
    int currentValue = 0,
    int targetValue = 10,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? generateTestId('achievement'),
      currentValue: currentValue,
      targetValue: targetValue,
      lastUpdated: DateTime.now(),
      progressData: {
        'test': true,
        'percentage': targetValue > 0 ? (currentValue / targetValue * 100) : 0,
      },
    );
  }

  static AchievementNotification createAchievementNotification({
    Achievement? achievement,
    bool isShown = false,
  }) {
    return AchievementNotification(
      id: generateTestId('notification'),
      achievement: achievement ?? createAchievement(isUnlocked: true),
      timestamp: DateTime.now(),
      isShown: isShown,
      displayDuration: const Duration(seconds: 5),
    );
  }

  static AchievementStats createAchievementStats({
    int totalAchievements = 50,
    int unlockedAchievements = 15,
    double completionPercentage = 30.0,
  }) {
    return AchievementStats(
      totalAchievements: totalAchievements,
      unlockedAchievements: unlockedAchievements,
      commonUnlocked: (unlockedAchievements * 0.6).round(),
      rareUnlocked: (unlockedAchievements * 0.3).round(),
      epicUnlocked: (unlockedAchievements * 0.08).round(),
      legendaryUnlocked: (unlockedAchievements * 0.02).round(),
      completionPercentage: completionPercentage,
      lastAchievementDate: DateTime.now().subtract(const Duration(hours: 2)),
      totalPoints: unlockedAchievements * 25,
      unlockRate: 2.5,
      favoriteCategory: 'exploration',
      streakDays: 7,
      averageUnlockTime: const Duration(hours: 3),
    );
  }

  static AchievementState createAchievementState({
    Map<String, Achievement>? achievements,
    Map<String, AchievementProgress>? progress,
    bool isInitialized = true,
  }) {
    final defaultAchievements = achievements ?? _createTestAchievementMap();
    final defaultProgress = progress ?? _createTestProgressMap(defaultAchievements);
    final stats = createAchievementStats(
      totalAchievements: defaultAchievements.length,
      unlockedAchievements: defaultAchievements.values.where((a) => a.isUnlocked).length,
    );

    return AchievementState(
      achievements: defaultAchievements,
      progress: defaultProgress,
      notifications: [],
      stats: stats,
      isInitialized: isInitialized,
    );
  }

  // 🧠 ATHENA AI TEST DATA (PHASE 3.4)
  static Map<String, dynamic> createAthenaDecisionData({
    String? type,
    double confidence = 0.85,
    Map<String, dynamic>? recommendations,
  }) {
    return {
      'id': generateTestId('athena_decision'),
      'type': type ?? 'model_selection',
      'confidence': confidence,
      'timestamp': DateTime.now().toIso8601String(),
      'recommendations': recommendations ?? {
        'suggested_models': ['claude', 'gpt'],
        'suggested_strategy': 'parallel',
        'confidence_boost': 0.15,
      },
      'reasoning': 'Test reasoning for automated decision',
      'metadata': {
        'test': true,
        'prompt_analysis': 'complex_reasoning',
      },
    };
  }

  static Map<String, dynamic> createAthenaAnalyticsData() {
    return {
      'total_decisions': 25,
      'decisions_applied': 18,
      'average_confidence': 0.82,
      'favorite_strategy': 'adaptive',
      'model_preferences': {
        'claude': 0.9,
        'gpt': 0.8,
        'gemini': 0.7,
      },
      'success_rate': 0.89,
      'time_saved_minutes': 47,
      'recommendations_generated': 31,
    };
  }

  // 📊 COMPLETE APP STATE TEST DATA
  static AppState createAppState({
    StrategyState? strategy,
    ModelsState? models,
    ChatState? chat,
    ConnectionState? connection,
    AchievementState? achievements,
    String theme = 'neural',
    bool isDarkMode = true,
  }) {
    return AppState(
      strategy: strategy ?? createStrategyState(),
      models: models ?? createModelsState(),
      chat: chat ?? createChatState(),
      connection: connection ?? createConnectionState(),
      achievements: achievements ?? createAchievementState(),
      theme: theme,
      isDarkMode: isDarkMode,
    );
  }

  // 🔧 CONFIGURATION TEST DATA
  static Map<String, dynamic> createAppConfigData() {
    return {
      'version': '2.5.0',
      'theme': 'neural',
      'isDarkMode': true,
      'features': {
        'athena_enabled': true,
        'achievements_enabled': true,
        'spatial_audio_enabled': false,
        'analytics_enabled': true,
      },
      'orchestration': {
        'default_strategy': 'parallel',
        'max_concurrent_requests': 5,
        'timeout_seconds': 30,
        'confidence_threshold': 0.8,
      },
      'ai_models': {
        'claude': {'enabled': true, 'weight': 1.0},
        'gpt': {'enabled': true, 'weight': 0.9},
        'deepseek': {'enabled': false, 'weight': 0.7},
        'gemini': {'enabled': true, 'weight': 0.8},
      },
      'achievement_settings': {
        'notifications_enabled': true,
        'sound_enabled': true,
        'auto_unlock': false,
      },
      'last_update': DateTime.now().toIso8601String(),
    };
  }

  // 📈 ANALYTICS & PERFORMANCE TEST DATA
  static Map<String, dynamic> createAnalyticsData() {
    return {
      'session_duration_minutes': 45,
      'messages_sent': 12,
      'orchestrations_completed': 8,
      'achievements_unlocked': 2,
      'themes_changed': 1,
      'errors_encountered': 0,
      'average_response_time_ms': 1250,
      'successful_requests': 8,
      'failed_requests': 0,
      'features_used': ['chat', 'orchestration', 'achievements'],
      'favorite_models': ['claude', 'gpt'],
      'session_start': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
    };
  }

  // 🛡️ ERROR SCENARIOS TEST DATA
  static Map<String, dynamic> createErrorScenarios() {
    return {
      'network_errors': [
        {'type': 'connection_timeout', 'count': 2},
        {'type': 'api_rate_limit', 'count': 1},
      ],
      'model_errors': [
        {'model': 'claude', 'error': 'api_key_invalid', 'count': 1},
        {'model': 'gpt', 'error': 'quota_exceeded', 'count': 0},
      ],
      'orchestration_errors': [
        {'type': 'synthesis_failed', 'count': 1},
        {'type': 'timeout', 'count': 0},
      ],
      'storage_errors': [
        {'type': 'write_failed', 'count': 0},
        {'type': 'encryption_failed', 'count': 0},
      ],
    };
  }

  // 🎯 BULK DATA GENERATORS
  static List<ChatMessage> generateBulkMessages(int count) {
    return List.generate(count, (index) {
      if (index % 2 == 0) {
        return createUserMessage(content: 'Bulk user message $index');
      } else {
        return createAssistantMessage(content: 'Bulk assistant response $index');
      }
    });
  }

  static List<Achievement> generateBulkAchievements(int count) {
    return List.generate(count, (index) {
      final category = AchievementCategory.values[index % AchievementCategory.values.length];
      final rarity = AchievementRarity.values[index % AchievementRarity.values.length];

      return createAchievement(
        title: 'Bulk Achievement $index',
        description: 'Generated bulk achievement for testing purposes',
        category: category,
        rarity: rarity,
        isUnlocked: index % 3 == 0, // Unlock every 3rd achievement
      );
    });
  }

  // 🔧 PRIVATE HELPERS
  static Map<String, Achievement> _createTestAchievementMap() {
    final achievements = <String, Achievement>{};

    for (final category in AchievementCategory.values) {
      for (final rarity in AchievementRarity.values) {
        final achievement = createAchievement(
          title: '${category.displayName} ${rarity.displayName}',
          description: 'Test ${rarity.displayName.toLowerCase()} achievement for ${category.displayName.toLowerCase()}',
          category: category,
          rarity: rarity,
          isUnlocked: rarity.index <= 1, // Unlock common and rare
        );
        achievements[achievement.id] = achievement;
      }
    }

    return achievements;
  }

  static Map<String, AchievementProgress> _createTestProgressMap(Map<String, Achievement> achievements) {
    final progress = <String, AchievementProgress>{};

    for (final achievement in achievements.values) {
      progress[achievement.id] = createAchievementProgress(
        achievementId: achievement.id,
        currentValue: achievement.isUnlocked ? achievement.targetProgress : achievement.currentProgress,
        targetValue: achievement.targetProgress,
      );
    }

    return progress;
  }

  static int _getAchievementPoints(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 10;
      case AchievementRarity.rare:
        return 25;
      case AchievementRarity.epic:
        return 50;
      case AchievementRarity.legendary:
        return 100;
    }
  }

  // 🧹 RESET COUNTERS (for tests)
  static void resetCounters() {
    _messageCounter = 0;
    _achievementCounter = 0;
    _requestCounter = 0;
  }
}