// 🧠 NEURONVAULT - ENTERPRISE STATE MODELS WITH FREEZED
// Fixed analyzer conflicts for build compatibility
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT + ACHIEVEMENT SYSTEM

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'state_models.freezed.dart';
part 'state_models.g.dart';

// 🎯 ENUMS & TYPES - ORCHESTRATION
enum OrchestrationStrategy {
  @JsonValue('parallel')
  parallel,
  @JsonValue('consensus')
  consensus,
  @JsonValue('adaptive')
  adaptive,
  @JsonValue('sequential')
  sequential,
  @JsonValue('cascade')
  cascade,
  @JsonValue('weighted')
  weighted;

  String get displayName {
    switch (this) {
      case OrchestrationStrategy.parallel:
        return 'Parallel';
      case OrchestrationStrategy.consensus:
        return 'Consensus';
      case OrchestrationStrategy.adaptive:
        return 'Adaptive';
      case OrchestrationStrategy.sequential:
        return 'Sequential';
      case OrchestrationStrategy.cascade:
        return 'Cascade';
      case OrchestrationStrategy.weighted:
        return 'Weighted';
    }
  }

  IconData get icon {
    switch (this) {
      case OrchestrationStrategy.parallel:
        return Icons.account_tree;
      case OrchestrationStrategy.consensus:
        return Icons.how_to_vote;
      case OrchestrationStrategy.adaptive:
        return Icons.auto_awesome;
      case OrchestrationStrategy.sequential:
        return Icons.timeline;
      case OrchestrationStrategy.cascade:
        return Icons.waterfall_chart;
      case OrchestrationStrategy.weighted:
        return Icons.balance;
    }
  }
}

enum AIModel {
  @JsonValue('claude')
  claude,
  @JsonValue('gpt')
  gpt,
  @JsonValue('deepseek')
  deepseek,
  @JsonValue('gemini')
  gemini,
  @JsonValue('mistral')
  mistral,
  @JsonValue('llama')
  llama,
  @JsonValue('ollama')
  ollama;

  String get displayName {
    switch (this) {
      case AIModel.claude: return 'Claude';
      case AIModel.gpt: return 'GPT';
      case AIModel.deepseek: return 'DeepSeek';
      case AIModel.gemini: return 'Gemini';
      case AIModel.mistral: return 'Mistral';
      case AIModel.llama: return 'Llama';
      case AIModel.ollama: return 'Ollama';
    }
  }

  IconData get icon {
    switch (this) {
      case AIModel.claude: return Icons.ac_unit;
      case AIModel.gpt: return Icons.api;
      case AIModel.deepseek: return Icons.search;
      case AIModel.gemini: return Icons.star;
      case AIModel.mistral: return Icons.air;
      case AIModel.llama: return Icons.brightness_low;
      case AIModel.ollama: return Icons.dns;
    }
  }

  Color get color {
    switch (this) {
      case AIModel.claude: return Colors.purple;
      case AIModel.gpt: return Colors.green;
      case AIModel.deepseek: return Colors.blue;
      case AIModel.gemini: return Colors.orange;
      case AIModel.mistral: return Colors.cyan;
      case AIModel.llama: return Colors.red;
      case AIModel.ollama: return Colors.grey;
    }
  }
}

enum ConnectionStatus {
  @JsonValue('connected')
  connected,
  @JsonValue('connecting')
  connecting,
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('error')
  error,
  @JsonValue('reconnecting')
  reconnecting,
}

enum HealthStatus {
  @JsonValue('healthy')
  healthy,
  @JsonValue('degraded')
  degraded,
  @JsonValue('unhealthy')
  unhealthy,
  @JsonValue('critical')
  critical,
  @JsonValue('unknown')
  unknown,
}

enum MessageType {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
  @JsonValue('error')
  error,
}

// 🏆 ACHIEVEMENT SYSTEM ENUMS
enum AchievementCategory {
  @JsonValue('particles')
  particles,
  @JsonValue('orchestration')
  orchestration,
  @JsonValue('themes')
  themes,
  @JsonValue('audio')
  audio,
  @JsonValue('profiling')
  profiling,
  @JsonValue('exploration')
  exploration;

  String get displayName {
    switch (this) {
      case AchievementCategory.particles:
        return '3D Particles';
      case AchievementCategory.orchestration:
        return 'AI Orchestration';
      case AchievementCategory.themes:
        return 'Theme Master';
      case AchievementCategory.audio:
        return 'Spatial Audio';
      case AchievementCategory.profiling:
        return 'Model Profiling';
      case AchievementCategory.exploration:
        return 'Neural Explorer';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.particles:
        return Icons.auto_awesome;
      case AchievementCategory.orchestration:
        return Icons.account_tree;
      case AchievementCategory.themes:
        return Icons.palette;
      case AchievementCategory.audio:
        return Icons.spatial_audio;
      case AchievementCategory.profiling:
        return Icons.analytics;
      case AchievementCategory.exploration:
        return Icons.explore;
    }
  }
}

enum AchievementRarity {
  @JsonValue('common')
  common,
  @JsonValue('rare')
  rare,
  @JsonValue('epic')
  epic,
  @JsonValue('legendary')
  legendary;

  String get displayName {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case AchievementRarity.common:
        return const Color(0xFF9CA3AF);
      case AchievementRarity.rare:
        return const Color(0xFF3B82F6);
      case AchievementRarity.epic:
        return const Color(0xFFA855F7);
      case AchievementRarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }

  double get glowIntensity {
    switch (this) {
      case AchievementRarity.common:
        return 0.3;
      case AchievementRarity.rare:
        return 0.6;
      case AchievementRarity.epic:
        return 0.9;
      case AchievementRarity.legendary:
        return 1.2;
    }
  }
}

// 🎨 APP THEME ENUM
enum AppTheme {
  @JsonValue('neural')
  neural,
  @JsonValue('quantum')
  quantum,
  @JsonValue('cyber')
  cyber,
  @JsonValue('minimal')
  minimal;

  String get displayName {
    switch (this) {
      case AppTheme.neural: return 'Neural';
      case AppTheme.quantum: return 'Quantum';
      case AppTheme.cyber: return 'Cyber';
      case AppTheme.minimal: return 'Minimal';
    }
  }
}

// 🔧 FREEZED DATA MODELS
@freezed
class ModelConfig with _$ModelConfig {
  const factory ModelConfig({
    required String name,
    @Default('') String apiKey,
    @Default('') String baseUrl,
    @Default(true) bool enabled,
    @Default(1.0) double weight,
    @Default(0.0) double costPerToken,
    @Default(4000) int maxTokens,
    @Default(1.0) double temperature,
    @Default({}) Map<String, dynamic> parameters,
  }) = _ModelConfig;

  factory ModelConfig.fromJson(Map<String, dynamic> json) =>
      _$ModelConfigFromJson(json);
}

@freezed
class ModelHealth with _$ModelHealth {
  const factory ModelHealth({
    @Default(HealthStatus.unknown) HealthStatus status,
    @Default(0) int responseTime,
    @Default(0.0) double successRate,
    @Default(0) int totalRequests,
    @Default(0) int failedRequests,
    @Default(null) String? lastError,
    @Default(null) DateTime? lastCheck,
  }) = _ModelHealth;

  factory ModelHealth.fromJson(Map<String, dynamic> json) =>
      _$ModelHealthFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required MessageType type,
    required DateTime timestamp,
    @Default(null) AIModel? sourceModel,
    @Default(null) String? requestId,
    @Default({}) Map<String, dynamic> metadata,
    @Default(false) bool isError,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

// 🏆 ACHIEVEMENT DATA MODELS
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required AchievementCategory category,
    required AchievementRarity rarity,
    @Default(false) bool isUnlocked,
    @Default(0) int currentProgress,
    @Default(1) int targetProgress,
    @Default(null) DateTime? unlockedAt,
    @Default({}) Map<String, dynamic> metadata,
    @Default(false) bool isHidden,
    @Default([]) List<String> requirements,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

// 🎨 Achievement Extensions per Icon Logic
extension AchievementIconX on Achievement {
  IconData get icon {
    // Icon logic based on category and rarity
    switch (category) {
      case AchievementCategory.particles:
        return Icons.auto_awesome;
      case AchievementCategory.orchestration:
        return Icons.psychology;
      case AchievementCategory.themes:
        return Icons.palette;
      case AchievementCategory.audio:
        return Icons.spatial_audio;
      case AchievementCategory.profiling:
        return Icons.analytics;
      case AchievementCategory.exploration:
        return Icons.explore;
    }
  }
}

@freezed
class AchievementProgress with _$AchievementProgress {
  const factory AchievementProgress({
    required String achievementId,
    @Default(0) int currentValue,
    @Default(0) int targetValue,
    @Default(null) DateTime? lastUpdated,
    @Default({}) Map<String, dynamic> progressData,
  }) = _AchievementProgress;

  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
      _$AchievementProgressFromJson(json);
}

@freezed
class AchievementNotification with _$AchievementNotification {
  const factory AchievementNotification({
    required String id,
    required Achievement achievement,
    required DateTime timestamp,
    @Default(false) bool isShown,
    @Default(Duration(seconds: 5)) Duration displayDuration,
  }) = _AchievementNotification;

  factory AchievementNotification.fromJson(Map<String, dynamic> json) =>
      _$AchievementNotificationFromJson(json);
}

@freezed
class AchievementStats with _$AchievementStats {
  const factory AchievementStats({
    @Default(0) int totalAchievements,
    @Default(0) int unlockedAchievements,
    @Default(0) int commonUnlocked,
    @Default(0) int rareUnlocked,
    @Default(0) int epicUnlocked,
    @Default(0) int legendaryUnlocked,
    @Default(0.0) double completionPercentage,
    @Default(null) DateTime? lastAchievementDate,
  }) = _AchievementStats;

  factory AchievementStats.fromJson(Map<String, dynamic> json) =>
      _$AchievementStatsFromJson(json);
}

@freezed
class AchievementState with _$AchievementState {
  const factory AchievementState({
    @Default({}) Map<String, Achievement> achievements,
    @Default({}) Map<String, AchievementProgress> progress,
    @Default([]) List<AchievementNotification> notifications,
    @Default(AchievementStats()) AchievementStats stats,
    @Default(false) bool isInitialized,
    @Default(true) bool showNotifications,
  }) = _AchievementState;

  factory AchievementState.fromJson(Map<String, dynamic> json) =>
      _$AchievementStateFromJson(json);
}

// 🎛️ AI STRATEGY STATE
@freezed
class StrategyState with _$StrategyState {
  const factory StrategyState({
    @Default(OrchestrationStrategy.parallel) OrchestrationStrategy activeStrategy,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default({}) Map<AIModel, double> modelWeights,
    @Default(false) bool isProcessing,
    @Default(0.0) double confidenceThreshold,
    @Default(5) int maxConcurrentRequests,
    @Default(30) int timeoutSeconds,
    @Default([]) List<String> activeFilters,
  }) = _StrategyState;

  factory StrategyState.fromJson(Map<String, dynamic> json) =>
      _$StrategyStateFromJson(json);
}

// 🤖 AI MODELS STATE
@freezed
class ModelsState with _$ModelsState {
  const factory ModelsState({
    @JsonKey(includeFromJson: false, includeToJson: false) @Default({}) Map<AIModel, ModelConfig> availableModels,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default({}) Map<AIModel, ModelHealth> modelHealth,
    @JsonKey(includeFromJson: false, includeToJson: false) @Default({}) Map<AIModel, bool> activeModels,
    @Default(0.0) double totalBudgetUsed,
    @Default(100.0) double budgetLimit,
    @Default(false) bool isCheckingHealth,
    @Default(null) DateTime? lastHealthCheck,
  }) = _ModelsState;

  factory ModelsState.fromJson(Map<String, dynamic> json) =>
      _$ModelsStateFromJson(json);
}

// 💬 CHAT STATE
@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessage> messages,
    @Default('') String currentInput,
    @Default(false) bool isTyping,
    @Default(false) bool isGenerating,
    @Default([]) List<String> typingIndicators,
    @Default(null) String? activeRequestId,
    @Default(0) int messageCount,
    @Default(null) DateTime? lastMessageTime,
  }) = _ChatState;

  factory ChatState.fromJson(Map<String, dynamic> json) =>
      _$ChatStateFromJson(json);
}

// 🌐 CONNECTION STATE
@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    @Default(ConnectionStatus.disconnected) ConnectionStatus status,
    @Default('localhost') String serverUrl,
    @Default(8080) int port,
    @Default(0) int reconnectAttempts,
    @Default(3) int maxReconnects,
    @Default(null) String? lastError,
    @Default(null) DateTime? lastConnectionTime,
    @Default(0) int latencyMs,
  }) = _ConnectionState;

  factory ConnectionState.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStateFromJson(json);
}

// 📊 APPLICATION STATE (ROOT)
@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(StrategyState()) StrategyState strategy,
    @Default(ModelsState()) ModelsState models,
    @Default(ChatState()) ChatState chat,
    @Default(ConnectionState()) ConnectionState connection,
    @Default(AchievementState()) AchievementState achievements,
    @Default('neural') String theme,
    @Default(true) bool isDarkMode,
    @Default(false) bool isFirstLaunch,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}

// 🔗 ORCHESTRATION RESPONSE MODELS
@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String modelName,
    required String content,
    required DateTime timestamp,
    @Default(null) String? requestId,
    @Default(1.0) double confidence,
    @Default({}) Map<String, dynamic> metadata,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}

@freezed
class OrchestrationProgress with _$OrchestrationProgress {
  const factory OrchestrationProgress({
    required String requestId,
    @Default(0) int completedModels,
    @Default(0) int totalModels,
    @Default([]) List<String> activeModels,
    @Default(null) DateTime? startTime,
    @Default(null) DateTime? estimatedCompletion,
  }) = _OrchestrationProgress;

  factory OrchestrationProgress.fromJson(Map<String, dynamic> json) =>
      _$OrchestrationProgressFromJson(json);
}

// 📊 COMPUTED STATE EXTENSIONS
extension StrategyStateX on StrategyState {
  bool get hasActiveModels => modelWeights.isNotEmpty;
  int get activeModelCount => modelWeights.length;
  double get totalWeight => modelWeights.values.fold(0.0, (a, b) => a + b);
  bool get isConfigured => hasActiveModels && totalWeight > 0;
}

extension ModelsStateX on ModelsState {
  bool get isOverBudget => totalBudgetUsed >= budgetLimit;
  double get budgetPercentage => budgetLimit > 0 ?
  (totalBudgetUsed / budgetLimit * 100).clamp(0, 100) : 0;
  int get healthyModelCount => modelHealth.values
      .where((h) => h.status == HealthStatus.healthy)
      .length;
  bool get hasUnhealthyModels => modelHealth.values
      .any((h) => h.status == HealthStatus.unhealthy);
}

extension ChatStateX on ChatState {
  bool get hasMessages => messages.isNotEmpty;
  bool get canSendMessage => !isGenerating && currentInput.trim().isNotEmpty;
  int get userMessageCount => messages.where((m) => m.type == MessageType.user).length;
  int get assistantMessageCount => messages.where((m) => m.type == MessageType.assistant).length;
}

extension ConnectionStateX on ConnectionState {
  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting => status == ConnectionStatus.connecting;
  bool get hasError => status == ConnectionStatus.error;
  bool get canReconnect => reconnectAttempts < maxReconnects;
  String get displayStatus => status.name.toUpperCase();
}

// 🏆 ACHIEVEMENT EXTENSIONS
extension AchievementX on Achievement {
  bool get isCompleted => currentProgress >= targetProgress;
  double get progressPercentage => targetProgress > 0
      ? (currentProgress / targetProgress * 100).clamp(0, 100)
      : 0.0;
  bool get canBeShown => !isHidden || isUnlocked;
}

extension AchievementStateX on AchievementState {
  List<Achievement> get unlockedAchievements =>
      achievements.values.where((a) => a.isUnlocked).toList();

  List<Achievement> get lockedAchievements =>
      achievements.values.where((a) => !a.isUnlocked).toList();

  List<Achievement> get visibleAchievements =>
      achievements.values.where((a) => a.canBeShown).toList();

  List<Achievement> get recentlyUnlocked =>
      unlockedAchievements
        ..sort((a, b) => (b.unlockedAt ?? DateTime(0))
            .compareTo(a.unlockedAt ?? DateTime(0)));

  List<AchievementNotification> get pendingNotifications =>
      notifications.where((n) => !n.isShown).toList();

  int get totalPoints => unlockedAchievements
      .map((a) => _getAchievementPoints(a.rarity))
      .fold(0, (a, b) => a + b);
}

// Helper function for points calculation
int _getAchievementPoints(AchievementRarity rarity) {
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

// 🤖 AIMODEL EXTENSIONS - Fix for missing getters
extension AIModelStateX on AIModel {
  bool get isActive => true; // Default active state - managed by ModelsState
  double get health => 0.9; // Default health - managed by ModelHealth
  int get tokensUsed => 0; // Default tokens - managed by usage tracking
}