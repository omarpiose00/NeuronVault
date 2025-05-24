// 🧠 NEURONVAULT - ENTERPRISE STATE MODELS
// Immutable state models with Freezed for optimal performance
// Part of PHASE 2.5 - QUANTUM STATE MANAGEMENT

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

// 🎛️ AI STRATEGY STATE
@freezed
class StrategyState with _$StrategyState {
  const factory StrategyState({
    @Default(AIStrategy.parallel) AIStrategy activeStrategy,
    @Default({}) Map<AIModel, double> modelWeights,
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
    @Default({}) Map<AIModel, ModelConfig> availableModels,
    @Default({}) Map<AIModel, ModelHealth> modelHealth,
    @Default({}) Map<AIModel, bool> activeModels,
    @Default(0.0) double totalBudgetUsed,
    @Default(100.0) double budgetLimit,
    @Default(false) bool isCheckingHealth,
    DateTime? lastHealthCheck,
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
    DateTime? lastMessageTime,
  }) = _ChatState;

  factory ChatState.fromJson(Map<String, dynamic> json) => 
      _$ChatStateFromJson(json);
}

// 🌐 CONNECTION STATE  
@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    @Default(ConnectionStatus.disconnected) ConnectionStatus status,
    @Default('') String serverUrl,
    @Default(8080) int port,
    @Default(0) int reconnectAttempts,
    @Default(3) int maxReconnects,
    @Default(null) String? lastError,
    DateTime? lastConnectionTime,
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
    @Default(AppTheme.neural) AppTheme theme,
    @Default(false) bool isDarkMode,
    @Default(Locale('en', 'US')) Locale locale,
    @Default(false) bool isFirstLaunch,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) => 
      _$AppStateFromJson(json);
}

// 🎯 ENUMS & TYPES
enum AIStrategy {
  @JsonValue('parallel')
  parallel,
  @JsonValue('consensus')
  consensus,
  @JsonValue('adaptive')
  adaptive,
  @JsonValue('sequential')
  sequential,
  @JsonValue('weighted')
  weighted,
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
  ollama,
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

enum AppTheme {
  @JsonValue('neural')
  neural,
  @JsonValue('quantum')
  quantum,
  @JsonValue('cyber')
  cyber,
  @JsonValue('minimal')
  minimal,
}

// 🔧 COMPLEX TYPES
@freezed
class ModelConfig with _$ModelConfig {
  const factory ModelConfig({
    required String name,
    required String apiKey,
    required String baseUrl,
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
    DateTime? lastCheck,
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

enum HealthStatus {
  @JsonValue('healthy')
  healthy,
  @JsonValue('degraded')
  degraded,
  @JsonValue('unhealthy')
  unhealthy,
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

// 📊 COMPUTED STATE EXTENSIONS
extension StrategyStateX on StrategyState {
  bool get hasActiveModels => modelWeights.isNotEmpty;
  int get activeModelCount => modelWeights.length;
  double get totalWeight => modelWeights.values.fold(0.0, (a, b) => a + b);
  bool get isConfigured => hasActiveModels && totalWeight > 0;
}

extension ModelsStateX on ModelsState {
  bool get isOverBudget => totalBudgetUsed >= budgetLimit;
  double get budgetPercentage => (totalBudgetUsed / budgetLimit * 100).clamp(0, 100);
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