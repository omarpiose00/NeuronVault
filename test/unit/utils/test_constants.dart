// 🧪 test/unit/utils/test_constants.dart
// Test Constants Foundation for NeuronVault Testing - Enterprise Grade 2025
// Centralized constants for consistent testing across the platform

import 'dart:io';
import 'dart:ui';

/// 🎯 **ENTERPRISE TEST CONSTANTS FOUNDATION**
///
/// Provides centralized constants for all NeuronVault testing:
/// - Timeout configurations
/// - Performance thresholds
/// - Mock data defaults
/// - Test environment settings
/// - Assertion thresholds
/// - Error codes and messages

class TestConstants {
  // ==========================================================================
  // ⏱️ TIMEOUT CONFIGURATIONS
  // ==========================================================================

  /// Default timeout for most test operations
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Timeout for quick operations (UI interactions, simple computations)
  static const Duration quickTimeout = Duration(seconds: 3);

  /// Timeout for async operations (network requests, file operations)
  static const Duration asyncTimeout = Duration(seconds: 15);

  /// Timeout for integration tests (full user journeys)
  static const Duration integrationTimeout = Duration(seconds: 30);

  /// Timeout for performance tests (must be fast)
  static const Duration performanceTimeout = Duration(seconds: 5);

  /// Timeout for WebSocket connection establishment
  static const Duration websocketTimeout = Duration(seconds: 8);

  /// Timeout for AI model responses during testing
  static const Duration aiResponseTimeout = Duration(seconds: 20);

  // ==========================================================================
  // 🚀 PERFORMANCE THRESHOLDS
  // ==========================================================================

  /// Maximum acceptable time for widget builds
  static const Duration performanceThreshold = Duration(milliseconds: 16); // 60 FPS

  /// Maximum time for provider state updates
  static const Duration stateUpdateThreshold = Duration(milliseconds: 100);

  /// Maximum time for SharedPreferences operations
  static const Duration storageThreshold = Duration(milliseconds: 50);

  /// Maximum memory usage during tests (in MB)
  static const int maxMemoryUsageMB = 512;

  /// Minimum FPS for 3D particle system
  static const double minAcceptableFPS = 58.0;

  /// Maximum acceptable latency for WebSocket messages
  static const Duration maxWebSocketLatency = Duration(milliseconds: 200);

  /// Maximum time for achievement unlock processing
  static const Duration achievementProcessingThreshold = Duration(milliseconds: 300);

  // ==========================================================================
  // 📊 ACCURACY & ASSERTION THRESHOLDS
  // ==========================================================================

  /// Floating point comparison epsilon for test assertions
  static const double floatEpsilon = 0.0001;

  /// Percentage tolerance for performance measurements
  static const double performanceTolerancePercent = 0.1; // 10%

  /// Minimum confidence score for AI responses in tests
  static const double minAIConfidence = 0.8;

  /// Maximum acceptable error rate for orchestrations
  static const double maxErrorRate = 0.05; // 5%

  /// Minimum user satisfaction score for UX tests
  static const double minUserSatisfaction = 0.85;

  /// Particle animation smoothness threshold (variance)
  static const double animationSmoothnessThreshold = 0.02;

  // ==========================================================================
  // 🧪 TEST DATA CONFIGURATIONS
  // ==========================================================================

  /// Default SharedPreferences data for test initialization
  static const Map<String, dynamic> defaultSharedPrefsData = {
    'first_launch': false,
    'user_id': 'test_user_123',
    'app_version': '1.0.0+1',
    'onboarding_completed': true,
    'analytics_enabled': false, // Disabled for testing
    'crash_reporting_enabled': false, // Disabled for testing
  };

  /// Mock WebSocket server configuration
  static const Map<String, dynamic> mockWebSocketConfig = {
    'host': 'localhost',
    'port': 3001, // Different from production to avoid conflicts
    'reconnect_interval': 1000, // Fast reconnection for testing
    'max_reconnect_attempts': 3,
    'heartbeat_interval': 5000,
  };

  /// Default test user profile
  static const Map<String, dynamic> testUserProfile = {
    'user_id': 'test_user_123',
    'username': 'Test User',
    'preferences': {
      'theme': 'cosmos',
      'audio_enabled': false, // Disabled for testing
      'particles_enabled': true,
      'notifications_enabled': false, // Disabled for testing
    },
    'statistics': {
      'total_orchestrations': 0,
      'session_count': 1,
      'achievement_count': 0,
    },
  };

  // ==========================================================================
  // 🎨 UI TEST CONSTANTS
  // ==========================================================================

  /// Standard test screen sizes for responsive testing
  static const Map<String, Size> testScreenSizes = {
    'mobile': Size(375, 667), // iPhone 8
    'tablet': Size(768, 1024), // iPad
    'desktop': Size(1920, 1080), // Full HD
    'wide': Size(3440, 1440), // Ultrawide
  };

  /// Neural theme test variants
  static const List<String> neuralThemeVariants = [
    'cosmos',
    'matrix',
    'sunset',
    'ocean',
    'midnight',
    'aurora',
  ];

  /// Particle system test configurations
  static const Map<String, Map<String, dynamic>> particleTestConfigs = {
    'minimal': {
      'particle_count': 50,
      'connection_density': 0.3,
      'animation_speed': 0.5,
    },
    'standard': {
      'particle_count': 150,
      'connection_density': 0.7,
      'animation_speed': 1.0,
    },
    'maximum': {
      'particle_count': 300,
      'connection_density': 1.0,
      'animation_speed': 2.0,
    },
  };

  // ==========================================================================
  // 🤖 AI ORCHESTRATION TEST CONSTANTS
  // ==========================================================================

  /// Available AI models for testing
  static const List<String> testAIModels = [
    'claude',
    'gpt',
    'deepseek',
    'gemini',
    'mistral',
    'llama',
    'ollama',
  ];

  /// Orchestration strategies for testing
  static const List<String> orchestrationStrategies = [
    'parallel',
    'sequential',
    'consensus',
    'weighted',
    'adaptive',
  ];

  /// Mock prompt categories for Athena testing
  static const List<String> promptCategories = [
    'technical_analysis',
    'creative_writing',
    'data_analysis',
    'conversational',
    'problem_solving',
    'code_generation',
    'research',
  ];

  /// Expected response time ranges for different AI models (in milliseconds)
  static const Map<String, Map<String, int>> modelResponseTimeRanges = {
    'claude': {'min': 800, 'max': 2000, 'average': 1200},
    'gpt': {'min': 600, 'max': 1500, 'average': 950},
    'deepseek': {'min': 700, 'max': 1800, 'average': 1100},
    'gemini': {'min': 650, 'max': 1600, 'average': 1050},
  };

  // ==========================================================================
  // 🏆 ACHIEVEMENT SYSTEM TEST CONSTANTS
  // ==========================================================================

  /// Achievement categories for testing
  static const List<String> achievementCategories = [
    'particles',
    'orchestration',
    'themes',
    'audio',
    'analytics',
    'exploration',
  ];

  /// Achievement rarity levels
  static const List<String> achievementRarities = [
    'common',
    'rare',
    'epic',
    'legendary',
  ];

  /// Expected achievement unlock thresholds
  static const Map<String, int> achievementThresholds = {
    'first_synthesis': 1,
    'ai_conductor': 50,
    'neural_marathon': 1000,
    'theme_collector': 6,
    'speed_demon': 10,
    'feature_explorer': 12,
  };

  // ==========================================================================
  // 🔊 AUDIO SYSTEM TEST CONSTANTS
  // ==========================================================================

  /// Audio event types for testing
  static const List<String> audioEventTypes = [
    'neural_fire',
    'synapse_connect',
    'ai_thinking',
    'orchestration_start',
    'orchestration_complete',
    'achievement_unlock',
    'theme_switch',
    'error_sound',
  ];

  /// Volume level ranges for different audio categories
  static const Map<String, Map<String, double>> volumeRanges = {
    'ui_sounds': {'min': 0.0, 'max': 0.3, 'default': 0.2},
    'neural_sounds': {'min': 0.0, 'max': 0.8, 'default': 0.5},
    'notifications': {'min': 0.0, 'max': 1.0, 'default': 0.7},
    'background': {'min': 0.0, 'max': 0.4, 'default': 0.1},
  };

  // ==========================================================================
  // 📊 ANALYTICS TEST CONSTANTS
  // ==========================================================================

  /// Metrics that should be tracked during testing
  static const List<String> trackedMetrics = [
    'session_duration',
    'orchestration_count',
    'error_rate',
    'response_time',
    'user_satisfaction',
    'feature_usage',
    'performance_metrics',
  ];

  /// Expected ranges for key performance indicators
  static const Map<String, Map<String, double>> kpiRanges = {
    'success_rate': {'min': 0.95, 'max': 1.0, 'target': 0.98},
    'response_time': {'min': 500.0, 'max': 3000.0, 'target': 1200.0}, // milliseconds
    'user_satisfaction': {'min': 0.8, 'max': 1.0, 'target': 0.92},
    'error_rate': {'min': 0.0, 'max': 0.05, 'target': 0.02},
  };

  // ==========================================================================
  // 🔐 SECURITY TEST CONSTANTS
  // ==========================================================================

  /// Test encryption keys (NOT for production use)
  static const String testEncryptionKey = 'test_key_32_bytes_long_for_aes_256';
  static const String testInitializationVector = 'test_iv_16_bytes';

  /// Security test scenarios
  static const List<String> securityTestScenarios = [
    'encrypted_storage',
    'secure_websocket',
    'api_key_protection',
    'user_data_privacy',
    'session_management',
  ];

  // ==========================================================================
  // 🧩 INTEGRATION TEST CONSTANTS
  // ==========================================================================

  /// User journey test scenarios
  static const List<String> userJourneyScenarios = [
    'first_time_user_onboarding',
    'power_user_workflow',
    'error_recovery_journey',
    'theme_customization_flow',
    'achievement_hunting_session',
    'analytics_exploration',
    'audio_configuration_journey',
  ];

  /// Integration test checkpoints
  static const List<String> integrationCheckpoints = [
    'app_launch_successful',
    'websocket_connected',
    'first_orchestration_complete',
    'achievement_unlocked',
    'theme_switched',
    'analytics_populated',
    'graceful_shutdown',
  ];

  // ==========================================================================
  // 📱 PLATFORM-SPECIFIC CONSTANTS
  // ==========================================================================

  /// Platform-specific test configurations
  static const Map<String, Map<String, dynamic>> platformConfigs = {
    'windows': {
      'window_size': Size(1200, 800),
      'supports_haptics': false,
      'audio_latency': 50, // milliseconds
    },
    'macos': {
      'window_size': Size(1200, 800),
      'supports_haptics': true,
      'audio_latency': 30,
    },
    'linux': {
      'window_size': Size(1200, 800),
      'supports_haptics': false,
      'audio_latency': 80,
    },
  };

  /// Current platform detection for conditional testing
  static String get currentPlatform {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  /// Platform-specific timeout adjustments
  static Duration getPlatformAdjustedTimeout(Duration baseTimeout) {
    final multiplier = platformConfigs[currentPlatform]?['timeout_multiplier'] ?? 1.0;
    return Duration(milliseconds: (baseTimeout.inMilliseconds * multiplier).round());
  }

  // ==========================================================================
  // 🎯 GOLDEN TEST CONSTANTS
  // ==========================================================================

  /// Golden test configuration
  static const Map<String, dynamic> goldenTestConfig = {
    'threshold': 0.01, // 1% pixel difference tolerance
    'ignore_colors': false,
    'ignore_text': false,
    'generate_on_failure': false, // Set to true only when updating goldens
  };

  /// Golden test variants to generate
  static const List<String> goldenTestVariants = [
    'light_theme',
    'dark_theme',
    'cosmos_theme',
    'matrix_theme',
    'desktop_size',
    'tablet_size',
    'mobile_size',
  ];

  // ==========================================================================
  // 🔧 UTILITY METHODS
  // ==========================================================================

  /// Gets timeout based on test type
  static Duration getTimeoutForTestType(String testType) {
    switch (testType) {
      case 'unit':
        return quickTimeout;
      case 'widget':
        return defaultTimeout;
      case 'integration':
        return integrationTimeout;
      case 'performance':
        return performanceTimeout;
      default:
        return defaultTimeout;
    }
  }

  /// Determines if current environment is CI/CD
  static bool get isRunningInCI {
    return Platform.environment.containsKey('CI') ||
        Platform.environment.containsKey('GITHUB_ACTIONS') ||
        Platform.environment.containsKey('GITLAB_CI');
  }

  /// Gets adjusted thresholds for CI environment (usually more lenient)
  static Duration getAdjustedTimeout(Duration baseTimeout) {
    return isRunningInCI
        ? Duration(milliseconds: (baseTimeout.inMilliseconds * 1.5).round())
        : baseTimeout;
  }

  /// Validates test environment setup
  static bool validateTestEnvironment() {
    // Check if required test dependencies are available
    try {
      // Verify mock data is accessible
      if (defaultSharedPrefsData.isEmpty) return false;

      // Verify test screen sizes are valid
      if (testScreenSizes.values.any((size) => size.width <= 0 || size.height <= 0)) {
        return false;
      }

      // Verify AI model configurations
      if (testAIModels.isEmpty || orchestrationStrategies.isEmpty) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets memory limit based on test type
  static int getMemoryLimitMB(String testType) {
    switch (testType) {
      case 'performance':
        return maxMemoryUsageMB ~/ 2; // Stricter for performance tests
      case 'integration':
        return maxMemoryUsageMB; // Full limit for integration tests
      default:
        return (maxMemoryUsageMB * 0.75).round(); // Conservative for unit tests
    }
  }
}