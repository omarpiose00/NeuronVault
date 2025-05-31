// 🧪 test/mocks/mock_services.dart
// BUILD-BASED MOCK SERVICES - 100% Type-Safe & Complete Coverage
// Auto-generated mocks + Enhanced fake implementations for complex behaviors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

// 🧠 Core Services - Real Imports for Type Safety
import 'package:neuronvault/core/services/storage_service.dart';
import 'package:neuronvault/core/services/achievement_service.dart'; // For AchievementEvent
import 'package:neuronvault/core/services/websocket_orchestration_service.dart';
import 'package:neuronvault/core/services/ai_service.dart';
import 'package:neuronvault/core/services/mini_llm_analyzer_service.dart';
import 'package:neuronvault/core/services/analytics_service.dart';
import 'package:neuronvault/core/services/athena_intelligence_service.dart';
import 'package:neuronvault/core/services/spatial_audio_service.dart';
import 'package:neuronvault/core/services/theme_service.dart';
import 'package:neuronvault/core/services/config_service.dart';

// 🎯 State Models (for some types)
import 'package:neuronvault/core/state/state_models.dart';

// 📱 Controllers
import 'package:neuronvault/core/controllers/athena_controller.dart';
import 'package:neuronvault/core/controllers/chat_controller.dart';
import 'package:neuronvault/core/controllers/connection_controller.dart';
import 'package:neuronvault/core/controllers/models_controller.dart';
import 'package:neuronvault/core/controllers/strategy_controller.dart';

// 🏗️ BUILD-BASED MOCK ANNOTATIONS
// Run: dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  // 📱 Flutter Core Services
  SharedPreferences,
  FlutterSecureStorage,
  Logger,

  // 🧠 NeuronVault Core Services
  StorageService,
  EnhancedAchievementService,
  AIService,
  MiniLLMAnalyzerService,
  WebSocketOrchestrationService,
  AnalyticsService,
  AthenaIntelligenceService,
  SpatialAudioService,
  ThemeService,
  ConfigService,

  // 🎛️ Controllers
  AthenaController,
  ChatController,
  ConnectionController,
  ModelsController,
  StrategyController,
])
class MockServices {}

// 🎭 ENHANCED FAKE IMPLEMENTATIONS
// For services requiring complex stateful behavior

/// 💾 Enhanced Storage Service Fake - Complete File Operations Simulation
class FakeStorageService implements StorageService {
  final Map<String, String> _sharedPrefs = {};
  final Map<String, String> _secureStorage = {};
  final List<ChatMessage> _chatHistory = [];
  final Map<String, dynamic> _chatMetadata = {};
  final List<String> _exportHistory = [];
  final Map<String, dynamic> _storageStats = {};

  // Simulated directories
  late String _appDocumentsPath;
  late String _chatBackupsPath;
  late String _exportsPath;
  late String _logsPath;

  bool _isInitialized = false;

  FakeStorageService() {
    _initializePaths();
  }

  void _initializePaths() {
    _appDocumentsPath = '/fake/app/documents';
    _chatBackupsPath = '$_appDocumentsPath/chat_backups';
    _exportsPath = '$_appDocumentsPath/exports';
    _logsPath = '$_appDocumentsPath/logs';
    _isInitialized = true;
  }

  @override
  String get appDocumentsPath => _appDocumentsPath;

  @override
  String get chatBackupsPath => _chatBackupsPath;

  @override
  String get exportsPath => _exportsPath;

  @override
  String get logsPath => _logsPath;

  // 💬 CHAT HISTORY MANAGEMENT
  @override
  Future<void> saveMessage(ChatMessage message) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate async

    final existingIndex = _chatHistory.indexWhere((msg) => msg.id == message.id);
    if (existingIndex != -1) {
      _chatHistory[existingIndex] = message;
    } else {
      _chatHistory.add(message);
    }

    await _updateChatMetadata();
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 5));
    return List.from(_chatHistory);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await Future.delayed(const Duration(milliseconds: 5));
    _chatHistory.removeWhere((msg) => msg.id == messageId);
    await _updateChatMetadata();
  }

  @override
  Future<void> clearChatHistory() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _chatHistory.clear();
    _chatMetadata.clear();
  }

  // 🔍 SEARCH & FILTERING
  @override
  Future<List<ChatMessage>> searchMessages(String query) async {
    await Future.delayed(const Duration(milliseconds: 20));
    return _chatHistory
        .where((msg) => msg.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<ChatMessage>> getMessagesByDateRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 15));
    return _chatHistory
        .where((msg) => msg.timestamp.isAfter(start) && msg.timestamp.isBefore(end))
        .toList();
  }

  @override
  Future<List<ChatMessage>> getMessagesByType(MessageType type) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _chatHistory.where((msg) => msg.type == type).toList();
  }

  // 💾 BACKUP & RESTORE
  @override
  Future<List<String>> getAvailableBackups() async {
    await Future.delayed(const Duration(milliseconds: 20));
    return [
      'chat_backup_periodic_2025-01-15T10-30-00.json',
      'chat_backup_full_clear_2025-01-14T16-45-00.json',
      'chat_backup_periodic_2025-01-13T14-20-00.json',
    ];
  }

  @override
  Future<void> restoreFromBackup(String backupFilename) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Simulate loading from backup
    final sampleMessages = [
      ChatMessage(
        id: 'backup_msg_1',
        content: 'Restored message 1',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'backup_msg_2',
        content: 'Restored message 2',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    _chatHistory.clear();
    _chatHistory.addAll(sampleMessages);
    await _updateChatMetadata();
  }

  // 📤 EXPORT & IMPORT
  @override
  Future<String> exportChatHistory([String? format]) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = 'neuronvault_export_$timestamp.json';
    final exportPath = '$_exportsPath/$filename';

    // Track export
    _exportHistory.add(jsonEncode({
      'filename': filename,
      'timestamp': DateTime.now().toIso8601String(),
      'message_count': _chatHistory.length,
    }));

    return exportPath;
  }

  @override
  Future<void> importChatHistory(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Simulate import with sample data
    final importedMessages = [
      ChatMessage(
        id: 'imported_msg_1',
        content: 'Imported message 1',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ChatMessage(
        id: 'imported_msg_2',
        content: 'Imported message 2',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _chatHistory.addAll(importedMessages);
    await _updateChatMetadata();
  }

  // 📊 METADATA & STATISTICS
  @override
  Future<Map<String, dynamic>> getChatMetadata() async {
    await Future.delayed(const Duration(milliseconds: 5));
    return Map.from(_chatMetadata);
  }

  @override
  Future<Map<String, dynamic>> getStorageStatistics() async {
    await Future.delayed(const Duration(milliseconds: 30));

    return {
      'message_count': _chatHistory.length,
      'total_characters': _chatHistory.fold<int>(0, (sum, msg) => sum + msg.content.length),
      'backup_count': 3,
      'backup_size_bytes': 1024 * 50, // 50KB
      'export_size_bytes': 1024 * 25, // 25KB
      'total_size_bytes': 1024 * 75,  // 75KB
      'app_documents_path': _appDocumentsPath,
    };
  }

  Future<void> _updateChatMetadata() async {
    final userMessages = _chatHistory.where((msg) => msg.type == MessageType.user).length;
    final assistantMessages = _chatHistory.where((msg) => msg.type == MessageType.assistant).length;
    final errorMessages = _chatHistory.where((msg) => msg.type == MessageType.error).length;

    _chatMetadata.addAll({
      'total_messages': _chatHistory.length,
      'user_messages': userMessages,
      'assistant_messages': assistantMessages,
      'error_messages': errorMessages,
      'last_updated': DateTime.now().toIso8601String(),
      'first_message': _chatHistory.isNotEmpty ? _chatHistory.first.timestamp.toIso8601String() : null,
      'last_message': _chatHistory.isNotEmpty ? _chatHistory.last.timestamp.toIso8601String() : null,
      'total_characters': _chatHistory.fold<int>(0, (sum, msg) => sum + msg.content.length),
    });
  }

  // 🧹 MAINTENANCE
  @override
  Future<void> performMaintenance() async {
    await Future.delayed(const Duration(milliseconds: 50));
    await _updateChatMetadata();
    await getStorageStatistics();
  }

  @override
  Future<void> clearAllData() async {
    await Future.delayed(const Duration(milliseconds: 30));
    _chatHistory.clear();
    _chatMetadata.clear();
    _exportHistory.clear();
    _storageStats.clear();
    _sharedPrefs.clear();
    _secureStorage.clear();
  }

  // 🧪 TEST UTILITIES
  void addTestMessage(ChatMessage message) {
    _chatHistory.add(message);
    _updateChatMetadata();
  }

  void addTestMessages(List<ChatMessage> messages) {
    _chatHistory.addAll(messages);
    _updateChatMetadata();
  }

  int get messageCount => _chatHistory.length;
  bool get hasMessages => _chatHistory.isNotEmpty;
  ChatMessage? get lastMessage => _chatHistory.isNotEmpty ? _chatHistory.last : null;

  void clearTestData() {
    _chatHistory.clear();
    _chatMetadata.clear();
    _exportHistory.clear();
  }
}

/// 🏆 Enhanced Achievement Service Fake - Complete Achievement System
class FakeEnhancementAchievementService extends ChangeNotifier implements EnhancedAchievementService {
  neuron_models.AchievementState _state = const neuron_models.AchievementState();
  final StreamController<neuron_models.AchievementNotification> _notificationController =
  StreamController<neuron_models.AchievementNotification>.broadcast();

  // Enhanced tracking
  int _currentSessionMinutes = 0;
  bool _maintainedHighPerformance = true;
  final Map<String, int> _sessionStats = {};
  Map<String, dynamic> _liveAnalytics = {};
  final List<AchievementEvent> _eventHistory = [];

  Timer? _performanceTimer;
  Timer? _sessionTimer;
  bool _isDisposed = false;

  @override
  neuron_models.AchievementState get state => _state;

  @override
  Stream<neuron_models.AchievementNotification> get notificationStream => _notificationController.stream;

  @override
  Map<String, dynamic> get liveAnalytics => _liveAnalytics;

  @override
  List<AchievementEvent> get eventHistory => _eventHistory;

  @override
  int get currentSessionMinutes => _currentSessionMinutes;

  @override
  Map<String, int> get sessionStats => _sessionStats;

  FakeEnhancementAchievementService() {
    _initializeTestAchievements();
    _startTestTracking();
  }

  void _initializeTestAchievements() {
    final achievements = <String, neuron_models.Achievement>{};

    // Sample achievements for testing
    achievements['first_synthesis'] = const neuron_models.Achievement(
      id: 'first_synthesis',
      title: 'First Synthesis',
      description: 'Complete your first AI orchestration',
      category: neuron_models.AchievementCategory.orchestration,
      rarity: neuron_models.AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['neural_awakening'] = const neuron_models.Achievement(
      id: 'neural_awakening',
      title: 'Neural Awakening',
      description: 'Witnessed your first 3D neural particle system',
      category: neuron_models.AchievementCategory.particles,
      rarity: neuron_models.AchievementRarity.common,
      targetProgress: 1,
    );

    achievements['speed_demon'] = const neuron_models.Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Maintained 60 FPS for 10 minutes straight',
      category: neuron_models.AchievementCategory.exploration,
      rarity: neuron_models.AchievementRarity.epic,
      targetProgress: 600,
      isHidden: true,
    );

    achievements['theme_collector'] = const neuron_models.Achievement(
      id: 'theme_collector',
      title: 'Theme Collector',
      description: 'Unlocked all 6 neural luxury themes',
      category: neuron_models.AchievementCategory.themes,
      rarity: neuron_models.AchievementRarity.legendary,
      targetProgress: 6,
    );

    _state = _state.copyWith(
      achievements: achievements,
      isInitialized: true,
    );

    _updateTestAnalytics();
  }

  void _startTestTracking() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (_currentSessionMinutes % 60 == 0) {
        _currentSessionMinutes++;
      }

      _updateTestAnalytics();
    });
  }

  @override
  Future<void> trackEnhancedProgress(
      String achievementId, {
        int increment = 1,
        Map<String, dynamic>? data,
        bool playSound = true,
        bool triggerHaptic = true,
      }) async {
    if (!_state.achievements.containsKey(achievementId)) return;

    final achievement = _state.achievements[achievementId]!;
    if (achievement.isUnlocked) return;

    // Record event
    _recordTestEvent(achievementId, increment, data);

    // Update progress
    final currentProgress = _state.progress[achievementId] ??
        neuron_models.AchievementProgress(achievementId: achievementId, targetValue: achievement.targetProgress);

    final newProgress = currentProgress.copyWith(
      currentValue: (currentProgress.currentValue + increment).clamp(0, achievement.targetProgress),
      lastUpdated: DateTime.now(),
    );

    final newProgressMap = Map<String, AchievementProgress>.from(_state.progress);
    newProgressMap[achievementId] = newProgress;

    // Update achievement
    final updatedAchievement = achievement.copyWith(currentProgress: newProgress.currentValue);
    final newAchievements = Map<String, Achievement>.from(_state.achievements);
    newAchievements[achievementId] = updatedAchievement;

    _state = _state.copyWith(
      progress: newProgressMap,
      achievements: newAchievements,
    );

    // Check for unlock
    if (newProgress.currentValue >= achievement.targetProgress) {
      await _unlockTestAchievement(achievementId);
    }

    _updateTestAnalytics();
    notifyListeners();
  }

  Future<void> _unlockTestAchievement(String achievementId) async {
    final achievement = _state.achievements[achievementId];
    if (achievement == null || achievement.isUnlocked) return;

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    final newAchievements = Map<String, neuron_models.Achievement>.from(_state.achievements);
    newAchievements[achievementId] = unlockedAchievement;

    // Create notification
    final notification = neuron_models.AchievementNotification(
      id: 'notif_${achievementId}_${DateTime.now().millisecondsSinceEpoch}',
      achievement: unlockedAchievement,
      timestamp: DateTime.now(),
    );

    final newNotifications = List<neuron_models.AchievementNotification>.from(_state.notifications);
    newNotifications.add(notification);

    _state = _state.copyWith(
      achievements: newAchievements,
      notifications: newNotifications,
    );

    // Emit notification
    _notificationController.add(notification);

    _updateTestAnalytics();
    notifyListeners();
  }

  void _recordTestEvent(String achievementId, int increment, Map<String, dynamic>? data) {
    final event = AchievementEvent(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      achievementId: achievementId,
      eventType: 'progress',
      timestamp: DateTime.now(),
      increment: increment,
      data: data,
    );

    _eventHistory.insert(0, event);

    // Keep only last 100 events for testing
    if (_eventHistory.length > 100) {
      _eventHistory.removeRange(100, _eventHistory.length);
    }
  }

  void _updateTestAnalytics() {
    final achievements = _state.achievements.values.toList();
    final unlocked = achievements.where((a) => a.isUnlocked).toList();

    final stats = neuron_models.AchievementStats(
      totalAchievements: achievements.length,
      unlockedAchievements: unlocked.length,
      completionPercentage: achievements.isNotEmpty ? (unlocked.length / achievements.length * 100) : 0.0,
      totalPoints: unlocked.fold(0, (sum, a) => sum + _getTestPoints(a.rarity)),
      unlockRate: _currentSessionMinutes > 0 ? (unlocked.length / _currentSessionMinutes) : 0.0,
      favoriteCategory: 'orchestration',
      streakDays: 1,
    );

    _state = _state.copyWith(stats: stats);

    _liveAnalytics = {
      'session_duration': _currentSessionMinutes,
      'total_events': _eventHistory.length,
      'unlock_rate': stats.unlockRate,
      'completion_percentage': stats.completionPercentage,
    };
  }

  int _getTestPoints(neuron_models.AchievementRarity rarity) {
    switch (rarity) {
      case neuron_models.AchievementRarity.common: return 10;
      case neuron_models.AchievementRarity.rare: return 25;
      case neuron_models.AchievementRarity.epic: return 50;
      case neuron_models.AchievementRarity.legendary: return 100;
    }
  }

  @override
  Future<void> markNotificationShown(String notificationId) async {
    final index = _state.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _state.notifications[index];
      final updatedNotification = notification.copyWith(isShown: true);

      final newNotifications = List<AchievementNotification>.from(_state.notifications);
      newNotifications[index] = updatedNotification;

      _state = _state.copyWith(notifications: newNotifications);
      notifyListeners();
    }
  }

  // 🎯 Enhanced tracking methods
  @override
  Future<void> trackParticleInteraction({String? particleType, double? intensity}) async {
    await trackEnhancedProgress('neural_awakening');
  }

  @override
  Future<void> trackOrchestration(List<String> modelsUsed, String strategy, {
    double? responseTime,
    int? tokenCount,
    double? qualityScore,
  }) async {
    await trackEnhancedProgress('first_synthesis');
  }

  @override
  Future<void> trackThemeActivation(String themeName, {Duration? usageDuration}) async {
    await trackEnhancedProgress('theme_collector');
  }

  @override
  Future<void> trackAudioActivation({String? soundType, bool? hapticEnabled}) async {
    // Mock implementation
  }

  @override
  Future<void> trackProfilingUsage({Duration? timeSpent}) async {
    // Mock implementation
  }

  @override
  Future<void> trackFeatureUsage(String feature) async {
    // Mock implementation
  }

  // 🧪 TEST UTILITIES
  void unlockTestAchievement(String achievementId) {
    _unlockTestAchievement(achievementId);
  }

  void addTestProgress(String achievementId, int progress) {
    trackEnhancedProgress(achievementId, increment: progress);
  }

  void simulateSessionTime(int minutes) {
    _currentSessionMinutes = minutes;
    _updateTestAnalytics();
  }

  int get achievementCount => _state.achievements.length;
  int get unlockedCount => _state.achievements.values.where((a) => a.isUnlocked).length;

  void clearTestData() {
    _state = const AchievementState();
    _eventHistory.clear();
    _liveAnalytics.clear();
    _sessionStats.clear();
    _currentSessionMinutes = 0;
  }

  @override
  void dispose() {
    if (_isDisposed) return;

    _isDisposed = true;
    _performanceTimer?.cancel();
    _sessionTimer?.cancel();
    _notificationController.close();

    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}

/// 📊 Achievement Event for analytics - Simple Implementation for Testing
class AchievementEvent {
  final String id;
  final String achievementId;
  final String eventType;
  final DateTime timestamp;
  final int increment;
  final Map<String, dynamic>? data;

  AchievementEvent({
    required this.id,
    required this.achievementId,
    required this.eventType,
    required this.timestamp,
    required this.increment,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'achievement_id': achievementId,
    'event_type': eventType,
    'timestamp': timestamp.toIso8601String(),
    'increment': increment,
    'data': data,
  };

  factory AchievementEvent.fromJson(Map<String, dynamic> json) => AchievementEvent(
    id: json['id'],
    achievementId: json['achievement_id'],
    eventType: json['event_type'],
    timestamp: DateTime.parse(json['timestamp']),
    increment: json['increment'],
    data: json['data'],
  );
}

/// 📡 Fake WebSocket Orchestration Service - Complete Implementation
class FakeWebSocketOrchestrationService extends ChangeNotifier implements WebSocketOrchestrationService {
  // 🔗 Connection State
  bool _isConnected = false;
  int _currentPort = 3001;
  OrchestrationStrategy _currentStrategy = OrchestrationStrategy.parallel;

  // 📊 Response Data
  final List<AIResponse> _individualResponses = [];
  String? _synthesizedResponse;

  // 📡 Stream Controllers
  final StreamController<List<AIResponse>> _individualResponsesController =
  StreamController<List<AIResponse>>.broadcast();
  final StreamController<String> _synthesizedResponseController =
  StreamController<String>.broadcast();
  final StreamController<OrchestrationProgress> _orchestrationProgressController =
  StreamController<OrchestrationProgress>.broadcast();

  // 🎯 REQUIRED GETTERS
  @override
  bool get isConnected => _isConnected;

  @override
  int get currentPort => _currentPort;

  @override
  List<AIResponse> get individualResponses => List.from(_individualResponses);

  @override
  String? get synthesizedResponse => _synthesizedResponse;

  @override
  OrchestrationStrategy get currentStrategy => _currentStrategy;

  // 📡 REQUIRED STREAMS
  @override
  Stream<List<AIResponse>> get individualResponsesStream =>
      _individualResponsesController.stream;

  @override
  Stream<String> get synthesizedResponseStream =>
      _synthesizedResponseController.stream;

  @override
  Stream<OrchestrationProgress> get orchestrationProgressStream =>
      _orchestrationProgressController.stream;

  // 🔗 CONNECTION METHODS
  @override
  Future<bool> connect({String? host, int? port}) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Simulate connection attempt
    _currentPort = port ?? 3001;

    // For testing, only succeed on specific test ports
    if (port == 8080 || (host == 'localhost' && port == null)) {
      _isConnected = true;
      notifyListeners();
      return true;
    }

    _isConnected = false;
    return false;
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _isConnected = false;
    notifyListeners();
  }

  // 🚀 AI ORCHESTRATION METHODS - EXACT SIGNATURES FROM REAL SERVICE
  @override
  Future<void> orchestrateAIRequest({
    required String prompt,
    required List<String> selectedModels,
    required OrchestrationStrategy strategy,
    Map<String, double>? modelWeights,
    String? conversationId,
  }) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    _currentStrategy = strategy;

    // Simulate orchestration process
    await _simulateOrchestration(prompt, selectedModels, strategy, modelWeights, conversationId);

    notifyListeners();
  }

  @override
  Future<void> startAIStream({
    required String prompt,
    required List<String> selectedModels,
    required OrchestrationStrategy strategy,
    Map<String, double>? modelWeights,
    String? conversationId,
  }) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    _currentStrategy = strategy;

    // Simulate streaming orchestration
    await _simulateStreamingOrchestration(prompt, selectedModels, strategy, modelWeights, conversationId);

    notifyListeners();
  }

  // 🎭 SIMULATION METHODS
  Future<void> _simulateOrchestration(
      String prompt,
      List<String> selectedModels,
      OrchestrationStrategy strategy,
      Map<String, double>? modelWeights,
      String? conversationId,
      ) async {
    // Clear previous responses
    _individualResponses.clear();
    _synthesizedResponse = null;

    // Simulate progress
    _orchestrationProgressController.add(
      OrchestrationProgress(
        completedModels: 0,
        totalModels: selectedModels.length,
        currentPhase: 'initializing',
        overallProgress: 0.0,
      ),
    );

    // Simulate individual model responses
    for (int i = 0; i < selectedModels.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));

      final response = AIResponse(
        modelName: selectedModels[i],
        content: 'Simulated response from ${selectedModels[i]} for: $prompt',
        confidence: 0.8 + (i * 0.05),
        responseTime: Duration(milliseconds: 1000 + (i * 200)),
        timestamp: DateTime.now(),
      );

      _individualResponses.add(response);
      _individualResponsesController.add(List.from(_individualResponses));

      // Update progress
      _orchestrationProgressController.add(
        OrchestrationProgress(
          completedModels: i + 1,
          totalModels: selectedModels.length,
          currentPhase: 'processing_${selectedModels[i]}',
          overallProgress: (i + 1) / selectedModels.length,
        ),
      );
    }

    // Simulate final synthesis
    await Future.delayed(const Duration(milliseconds: 300));
    _synthesizedResponse = 'Synthesized response combining ${selectedModels.length} models using ${strategy.name} strategy for: $prompt';
    _synthesizedResponseController.add(_synthesizedResponse!);
  }

  Future<void> _simulateStreamingOrchestration(
      String prompt,
      List<String> selectedModels,
      OrchestrationStrategy strategy,
      Map<String, double>? modelWeights,
      String? conversationId,
      ) async {
    // Similar to regular orchestration but with streaming chunks
    await _simulateOrchestration(prompt, selectedModels, strategy, modelWeights, conversationId);

    // Simulate streaming chunks of synthesized response
    final responseText = _synthesizedResponse ?? '';
    final chunks = responseText.split(' ');

    for (final chunk in chunks) {
      await Future.delayed(const Duration(milliseconds: 50));
      _synthesizedResponseController.add(chunk + ' ');
    }
  }

  // 🧪 TEST UTILITIES
  void simulateConnection() {
    _isConnected = true;
    notifyListeners();
  }

  void simulateConnectionLoss() {
    _isConnected = false;
    notifyListeners();
  }

  void simulateResponse(AIResponse response) {
    _individualResponses.add(response);
    _individualResponsesController.add(List.from(_individualResponses));
  }

  void simulateSynthesis(String synthesis) {
    _synthesizedResponse = synthesis;
    _synthesizedResponseController.add(synthesis);
  }

  void clearTestData() {
    _individualResponses.clear();
    _synthesizedResponse = null;
    _currentStrategy = OrchestrationStrategy.parallel;
  }

  @override
  void dispose() {
    _individualResponsesController.close();
    _synthesizedResponseController.close();
    _orchestrationProgressController.close();
    super.dispose();
  }
}

/// 🎵 Test Data Factory - Complete Sample Data Generation
class TestDataFactory {
  // 🏆 Achievement Test Data
  static neuron_models.Achievement sampleAchievement({
    String? id,
    String? title,
    neuron_models.AchievementCategory? category,
    neuron_models.AchievementRarity? rarity,
    bool isUnlocked = false,
    int currentProgress = 0,
    int targetProgress = 10,
  }) {
    return neuron_models.Achievement(
      id: id ?? 'test_achievement',
      title: title ?? 'Test Achievement',
      description: 'A sample achievement for testing purposes',
      category: category ?? neuron_models.AchievementCategory.exploration,
      rarity: rarity ?? neuron_models.AchievementRarity.common,
      isUnlocked: isUnlocked,
      currentProgress: currentProgress,
      targetProgress: targetProgress,
      unlockedAt: isUnlocked ? DateTime.now() : null,
    );
  }

  static neuron_models.AchievementProgress sampleAchievementProgress({
    String? achievementId,
    int currentValue = 5,
    int targetValue = 10,
  }) {
    return neuron_models.AchievementProgress(
      achievementId: achievementId ?? 'test_achievement',
      currentValue: currentValue,
      targetValue: targetValue,
      lastUpdated: DateTime.now(),
    );
  }

  static neuron_models.AchievementNotification sampleAchievementNotification({
    neuron_models.Achievement? achievement,
    bool isShown = false,
  }) {
    return neuron_models.AchievementNotification(
      id: 'test_notification_${DateTime.now().millisecondsSinceEpoch}',
      achievement: achievement ?? sampleAchievement(),
      timestamp: DateTime.now(),
      isShown: isShown,
    );
  }

  // 💬 Chat Test Data
  static neuron_models.ChatMessage sampleChatMessage({
    String? id,
    String? content,
    neuron_models.MessageType? type,
    neuron_models.AIModel? sourceModel,
  }) {
    return neuron_models.ChatMessage(
      id: id ?? 'test_msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content ?? 'Test message content',
      type: type ?? neuron_models.MessageType.user,
      timestamp: DateTime.now(),
      sourceModel: sourceModel,
    );
  }

  static List<neuron_models.ChatMessage> sampleChatHistory({int count = 5}) {
    return List.generate(count, (index) => neuron_models.ChatMessage(
      id: 'msg_$index',
      content: 'Test message ${index + 1}',
      type: index % 2 == 0 ? neuron_models.MessageType.user : neuron_models.MessageType.assistant,
      timestamp: DateTime.now().subtract(Duration(minutes: count - index)),
      sourceModel: index % 2 == 1 ? neuron_models.AIModel.claude : null,
    ));
  }

  // 🤖 AI Model Test Data
  static neuron_models.ModelConfig sampleModelConfig({
    String? name,
    bool enabled = true,
    double weight = 1.0,
  }) {
    return neuron_models.ModelConfig(
      name: name ?? 'test-model',
      enabled: enabled,
      weight: weight,
      apiKey: 'test-api-key',
      baseUrl: 'https://api.test.com',
    );
  }

  static neuron_models.ModelHealth sampleModelHealth({
    neuron_models.HealthStatus? status,
    int responseTime = 100,
    double successRate = 0.95,
  }) {
    return neuron_models.ModelHealth(
      status: status ?? neuron_models.HealthStatus.healthy,
      responseTime: responseTime,
      successRate: successRate,
      totalRequests: 100,
      failedRequests: 5,
      lastCheck: DateTime.now(),
    );
  }

  // 📊 Analytics Test Data
  static Map<String, dynamic> sampleAnalyticsEvent({
    String? eventName,
    Map<String, dynamic>? properties,
  }) {
    return {
      'event': eventName ?? 'test_event',
      'properties': properties ?? {'test_key': 'test_value'},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> sampleWebSocketMessage({
    String? type,
    Map<String, dynamic>? data,
  }) {
    return {
      'type': type ?? 'message',
      'data': data ?? {'content': 'Test WebSocket message'},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // 🎯 State Test Data
  static neuron_models.AppState sampleAppState() {
    return const neuron_models.AppState(
      theme: 'neural_cosmos',
      isDarkMode: true,
      isFirstLaunch: false,
    );
  }

  static neuron_models.ConnectionState sampleConnectionState({
    neuron_models.ConnectionStatus? status,
    int latencyMs = 50,
  }) {
    return neuron_models.ConnectionState(
      status: status ?? neuron_models.ConnectionStatus.connected,
      serverUrl: 'localhost',
      port: 8080,
      latencyMs: latencyMs,
      lastConnectionTime: DateTime.now(),
    );
  }
}