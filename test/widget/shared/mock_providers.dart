// 🧪 test/widget/shared/mock_providers.dart
// Mock Providers Foundation for NeuronVault Testing - Enterprise Grade 2025
// Comprehensive Riverpod provider mocks for isolated testing

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../unit/utils/mock_data.dart';
import '../../unit/utils/test_constants.dart';

/// 🏗️ **ENTERPRISE MOCK PROVIDERS FOUNDATION**
///
/// Provides comprehensive Riverpod provider mocks for testing:
/// - Service layer mocks (Achievement, AI, Analytics, etc.)
/// - Controller mocks (Athena, Chat, Connection, etc.)
/// - State model mocks
/// - Theme and audio service mocks
/// - WebSocket orchestration mocks

// =============================================================================
// 🧪 MOCK SERVICE CLASSES
// =============================================================================

/// Mock AchievementService for testing achievement functionality
class MockAchievementService extends Mock {
  // Achievement state
  final List<String> _unlockedAchievements = [...MockData.unlockedAchievements];
  final Map<String, dynamic> _achievementProgress = {...MockData.achievementProgress};

  /// Mock unlocked achievements list
  List<String> get unlockedAchievements => _unlockedAchievements;

  /// Mock achievement progress
  Map<String, dynamic> get achievementProgress => _achievementProgress;

  /// Simulates unlocking an achievement
  Future<bool> unlockAchievement(String achievementId) async {
    await Future.delayed(TestConstants.achievementProcessingThreshold);
    if (!_unlockedAchievements.contains(achievementId)) {
      _unlockedAchievements.add(achievementId);
      return true;
    }
    return false;
  }

  /// Simulates updating achievement progress
  Future<void> updateProgress(String achievementId, double progress) async {
    _achievementProgress[achievementId] = {
      'current': (progress * 100).round(),
      'target': 100,
      'progress': progress,
    };
  }

  /// Checks if achievement is unlocked
  bool isAchievementUnlocked(String achievementId) {
    return _unlockedAchievements.contains(achievementId);
  }
}

/// Mock AI Service for testing orchestration functionality
class MockAIService extends Mock {
  final Map<String, dynamic> _modelResponses = {...MockData.mockAIResponses};

  /// Simulates AI model response
  Future<Map<String, dynamic>> getModelResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? options,
  }) async {
    // Simulate processing time based on model
    final processingTime = TestConstants.modelResponseTimeRanges[model]?['average'] ?? 1000;
    await Future.delayed(Duration(milliseconds: processingTime));

    return _modelResponses[model] ?? {
      'response': 'Mock response from $model',
      'confidence': 0.85,
      'tokens_used': 100,
      'processing_time': processingTime,
      'status': 'completed',
    };
  }

  /// Simulates synthesis of multiple responses
  Future<Map<String, dynamic>> synthesizeResponses({
    required List<Map<String, dynamic>> responses,
    required String strategy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.mockSynthesisResult;
  }

  /// Simulates available models check
  Future<List<String>> getAvailableModels() async {
    return TestConstants.testAIModels;
  }
}

/// Mock Analytics Service for testing analytics functionality
class MockAnalyticsService extends Mock {
  final Map<String, dynamic> _sessionStats = {...MockData.mockAnalyticsData['session_stats']};
  final Map<String, dynamic> _modelPerformance = {...MockData.mockAnalyticsData['model_performance']};

  /// Mock session statistics
  Map<String, dynamic> get sessionStats => _sessionStats;

  /// Mock model performance data
  Map<String, dynamic> get modelPerformance => _modelPerformance;

  /// Simulates recording an orchestration event
  Future<void> recordOrchestration({
    required String orchestrationId,
    required List<String> models,
    required Duration responseTime,
    required bool success,
  }) async {
    _sessionStats['orchestrations_count'] = (_sessionStats['orchestrations_count'] ?? 0) + 1;
    if (success) {
      _sessionStats['success_rate'] = (_sessionStats['success_rate'] ?? 1.0);
    }
  }

  /// Simulates getting performance heatmap data
  Future<Map<String, dynamic>> getPerformanceHeatmap() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _modelPerformance;
  }
}

/// Mock Athena Intelligence Service for testing AI autonomy
class MockAthenaIntelligenceService extends Mock {
  bool _isEnabled = true;
  final Map<String, dynamic> _lastAnalysis = {...MockData.mockAthenaAnalysis};

  /// Mock Athena enabled state
  bool get isEnabled => _isEnabled;

  /// Mock last AI analysis
  Map<String, dynamic> get lastAnalysis => _lastAnalysis;

  /// Simulates enabling/disabling Athena
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
  }

  /// Simulates prompt analysis
  Future<Map<String, dynamic>> analyzePrompt(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      ..._lastAnalysis,
      'prompt_analyzed': prompt,
      'analysis_timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Simulates model recommendation
  Future<List<String>> recommendModels(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _lastAnalysis['recommended_models'] ?? ['claude', 'gpt'];
  }
}

/// Mock WebSocket Orchestration Service
class MockWebSocketOrchestrationService extends Mock {
  bool _isConnected = false;
  final StreamController<Map<String, dynamic>> _messageController = StreamController.broadcast();
  final List<Map<String, dynamic>> _messageHistory = [];

  /// Mock connection state
  bool get isConnected => _isConnected;

  /// Mock connection quality (mocked as excellent for testing)
  String get connectionQuality => 'EXCELLENT';

  /// Mock latency (simulated)
  int get latency => 45; // milliseconds

  /// Mock message stream
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// Mock message history
  List<Map<String, dynamic>> get messageHistory => List.unmodifiable(_messageHistory);

  /// Simulates connecting to WebSocket
  Future<bool> connect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;

    // Simulate connection established message
    final connectionMessage = {
      'type': 'connection_established',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {'client_id': 'test_client_123'},
    };

    _addMessage(connectionMessage);
    return true;
  }

  /// Simulates disconnecting from WebSocket
  Future<void> disconnect() async {
    _isConnected = false;
    await _messageController.close();
  }

  /// Simulates sending orchestration request
  Future<String> sendOrchestrationRequest({
    required String prompt,
    required List<String> models,
    required String strategy,
  }) async {
    if (!_isConnected) {
      throw Exception('WebSocket not connected');
    }

    final orchestrationId = 'orch_${DateTime.now().millisecondsSinceEpoch}';

    // Simulate orchestration start message
    final startMessage = {
      'type': 'orchestration_start',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        'orchestration_id': orchestrationId,
        'prompt': prompt,
        'selected_models': models,
        'strategy': strategy,
      },
    };

    _addMessage(startMessage);

    // Simulate model responses over time
    _simulateModelResponses(orchestrationId, models);

    return orchestrationId;
  }

  /// Simulates model responses sequence
  void _simulateModelResponses(String orchestrationId, List<String> models) {
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (timer.tick > models.length) {
        timer.cancel();

        // Send final synthesis message
        final synthesisMessage = {
          'type': 'synthesis_complete',
          'timestamp': DateTime.now().toIso8601String(),
          'data': {
            'orchestration_id': orchestrationId,
            'result': MockData.mockSynthesisResult,
          },
        };

        _addMessage(synthesisMessage);
        return;
      }

      final modelIndex = timer.tick - 1;
      if (modelIndex < models.length) {
        final model = models[modelIndex];
        final responseMessage = {
          'type': 'model_response',
          'timestamp': DateTime.now().toIso8601String(),
          'data': {
            'orchestration_id': orchestrationId,
            'model': model,
            'status': 'completed',
            'response': MockData.mockAIResponses[model],
          },
        };

        _addMessage(responseMessage);
      }
    });
  }

  /// Adds message to history and stream
  void _addMessage(Map<String, dynamic> message) {
    _messageHistory.add(message);
    _messageController.add(message);
  }
}

/// Mock Theme Service for testing theme functionality
class MockThemeService extends Mock {
  String _currentTheme = 'cosmos';
  final Map<String, dynamic> _themePreferences = {...MockData.mockThemePreferences};

  /// Mock current theme
  String get currentTheme => _currentTheme;

  /// Mock theme preferences
  Map<String, dynamic> get themePreferences => _themePreferences;

  /// Simulates changing theme
  Future<void> changeTheme(String themeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentTheme = themeId;
    _themePreferences['current_theme'] = themeId;

    // Add to history
    final history = List<String>.from(_themePreferences['theme_history'] ?? []);
    if (!history.contains(themeId)) {
      history.add(themeId);
      _themePreferences['theme_history'] = history;
    }
  }

  /// Gets available themes
  List<String> getAvailableThemes() {
    return TestConstants.neuralThemeVariants;
  }
}

/// Mock Spatial Audio Service for testing audio functionality
class MockSpatialAudioService extends Mock {
  bool _isEnabled = false;
  double _masterVolume = 0.7;
  final Map<String, dynamic> _audioConfig = {...MockData.mockAudioConfig};

  /// Mock audio enabled state
  bool get isEnabled => _isEnabled;

  /// Mock master volume
  double get masterVolume => _masterVolume;

  /// Mock audio configuration
  Map<String, dynamic> get audioConfig => _audioConfig;

  /// Simulates enabling/disabling audio
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    _audioConfig['spatial_audio_enabled'] = enabled;
  }

  /// Simulates setting master volume
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    _audioConfig['master_volume'] = _masterVolume;
  }

  /// Simulates playing audio event
  Future<void> playEvent({
    required String eventType,
    Map<String, double>? position,
    double? volume,
  }) async {
    if (!_isEnabled) return;

    // Simulate audio processing delay
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

// =============================================================================
// 🏗️ MOCK PROVIDER DEFINITIONS
// =============================================================================

/// Mock provider overrides for comprehensive testing
class MockProviders {
  // Service instance mocks
  static final MockAchievementService _achievementService = MockAchievementService();
  static final MockAIService _aiService = MockAIService();
  static final MockAnalyticsService _analyticsService = MockAnalyticsService();
  static final MockAthenaIntelligenceService _athenaService = MockAthenaIntelligenceService();
  static final MockWebSocketOrchestrationService _websocketService = MockWebSocketOrchestrationService();
  static final MockThemeService _themeService = MockThemeService();
  static final MockSpatialAudioService _audioService = MockSpatialAudioService();

  /// Gets all service mock instances for direct testing
  static Map<Type, dynamic> get serviceMocks => {
    MockAchievementService: _achievementService,
    MockAIService: _aiService,
    MockAnalyticsService: _analyticsService,
    MockAthenaIntelligenceService: _athenaService,
    MockWebSocketOrchestrationService: _websocketService,
    MockThemeService: _themeService,
    MockSpatialAudioService: _audioService,
  };

  /// Resets all mock services to initial state
  static void resetAll() {
    // Reset achievement service
    _achievementService._unlockedAchievements.clear();
    _achievementService._unlockedAchievements.addAll(MockData.unlockedAchievements);
    _achievementService._achievementProgress.clear();
    _achievementService._achievementProgress.addAll(MockData.achievementProgress);

    // Reset AI service
    _aiService._modelResponses.clear();
    _aiService._modelResponses.addAll(MockData.mockAIResponses);

    // Reset analytics service
    _analyticsService._sessionStats.clear();
    _analyticsService._sessionStats.addAll(MockData.mockAnalyticsData['session_stats']);
    _analyticsService._modelPerformance.clear();
    _analyticsService._modelPerformance.addAll(MockData.mockAnalyticsData['model_performance']);

    // Reset Athena service
    _athenaService._isEnabled = true;
    _athenaService._lastAnalysis.clear();
    _athenaService._lastAnalysis.addAll(MockData.mockAthenaAnalysis);

    // Reset WebSocket service
    _websocketService._isConnected = false;
    _websocketService._messageHistory.clear();

    // Reset theme service
    _themeService._currentTheme = 'cosmos';
    _themeService._themePreferences.clear();
    _themeService._themePreferences.addAll(MockData.mockThemePreferences);

    // Reset audio service
    _audioService._isEnabled = false;
    _audioService._masterVolume = 0.7;
    _audioService._audioConfig.clear();
    _audioService._audioConfig.addAll(MockData.mockAudioConfig);
  }

  // ==========================================================================
  // 📦 PROVIDER OVERRIDES FOR TESTING
  // ==========================================================================

  /// Creates provider overrides for achievement service testing
  static List<Override> achievementServiceOverrides() {
    return [
      // Add actual provider overrides here when implementing specific services
      // Example: achievementServiceProvider.overrideWith((ref) => _achievementService),
    ];
  }

  /// Creates provider overrides for AI service testing
  static List<Override> aiServiceOverrides() {
    return [
      // Add actual provider overrides here
    ];
  }

  /// Creates provider overrides for analytics service testing
  static List<Override> analyticsServiceOverrides() {
    return [
      // Add actual provider overrides here
    ];
  }

  /// Creates provider overrides for Athena intelligence testing
  static List<Override> athenaServiceOverrides() {
    return [
      // Add actual provider overrides here
    ];
  }

  /// Creates provider overrides for WebSocket service testing
  static List<Override> websocketServiceOverrides() {
    return [
      // Add actual provider overrides here
    ];
  }

  /// Creates provider overrides for theme service testing
  static List<Override> themeServiceOverrides() {
    return [
      // Add actual provider overrides here
    ];
  }

  /// Creates provider overrides for audio service testing
  static List<Override> audioServiceOverrides() {
    return [
      // Add actual provider overrides here
    ];
  }

  /// Creates comprehensive provider overrides for full integration testing
  static List<Override> allServiceOverrides() {
    return [
      ...achievementServiceOverrides(),
      ...aiServiceOverrides(),
      ...analyticsServiceOverrides(),
      ...athenaServiceOverrides(),
      ...websocketServiceOverrides(),
      ...themeServiceOverrides(),
      ...audioServiceOverrides(),
    ];
  }

  // ==========================================================================
  // 🎭 SCENARIO-BASED OVERRIDES
  // ==========================================================================

  /// Creates overrides for first-time user scenario
  static List<Override> firstTimeUserOverrides() {
    // Reset to fresh state
    resetAll();

    // Configure for first-time user
    _achievementService._unlockedAchievements.clear();
    _achievementService._achievementProgress.clear();
    _themeService._currentTheme = 'cosmos'; // Default theme
    _audioService._isEnabled = false; // Audio disabled by default

    return allServiceOverrides();
  }

  /// Creates overrides for power user scenario
  static List<Override> powerUserOverrides() {
    resetAll();

    // Configure for experienced user
    _achievementService._unlockedAchievements.addAll([
      'neural_awakening',
      'first_synthesis',
      'ai_conductor',
      'theme_collector',
      'sound_pioneer',
      'particle_whisperer',
      'feature_explorer',
    ]);

    _athenaService._isEnabled = true;
    _audioService._isEnabled = true;
    _themeService._currentTheme = 'matrix';

    return allServiceOverrides();
  }

  /// Creates overrides for error scenario testing
  static List<Override> errorScenarioOverrides() {
    resetAll();

    // Configure for error testing
    _websocketService._isConnected = false;

    return allServiceOverrides();
  }

  /// Creates overrides for performance testing scenario
  static List<Override> performanceTestOverrides() {
    resetAll();

    // Configure for performance testing (minimal features enabled)
    _audioService._isEnabled = false;
    _athenaService._isEnabled = false;

    return allServiceOverrides();
  }
}

// =============================================================================
// 🧪 TEST UTILITY FUNCTIONS
// =============================================================================

/// Sets up SharedPreferences mocks for testing
void setupMockSharedPreferences() {
  SharedPreferences.setMockInitialValues(MockData.toSharedPreferencesFormat());
}

/// Creates a test container with mock providers
ProviderContainer createMockProviderContainer({
  List<Override>? additionalOverrides,
  String scenario = 'default',
}) {
  List<Override> overrides;

  switch (scenario) {
    case 'first_time_user':
      overrides = MockProviders.firstTimeUserOverrides();
      break;
    case 'power_user':
      overrides = MockProviders.powerUserOverrides();
      break;
    case 'error_scenario':
      overrides = MockProviders.errorScenarioOverrides();
      break;
    case 'performance_test':
      overrides = MockProviders.performanceTestOverrides();
      break;
    default:
      overrides = MockProviders.allServiceOverrides();
  }

  if (additionalOverrides != null) {
    overrides.addAll(additionalOverrides);
  }

  return ProviderContainer(overrides: overrides);
}

/// Waits for all async providers to complete in test container
Future<void> waitForProviders(ProviderContainer container) async {
  await Future.delayed(TestConstants.stateUpdateThreshold);
}