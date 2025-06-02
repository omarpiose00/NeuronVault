// 🧪 test_config/flutter_test_config.dart
// NEURONVAULT ENTERPRISE TEST CONFIGURATION - 2025 FOUNDATION FIXED
// Ultimate testing infrastructure for AI orchestration platform

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Import service types for registerFallbackValue
import 'package:neuronvault/core/services/websocket_orchestration_service.dart';

/// 🎯 **ENTERPRISE TEST CONFIGURATION FOUNDATION - FIXED**
///
/// Provides comprehensive testing infrastructure for NeuronVault:
/// - Service layer mocking with enterprise patterns
/// - Socket.IO and WebSocket testing utilities
/// - AI orchestration simulation frameworks
/// - Performance and load testing tools
/// - Deterministic fake data generation
/// - Resource management and cleanup
/// - Cross-platform test compatibility

class NeuronVaultTestConfig {
  static late Logger _testLogger;
  static final Map<String, dynamic> _globalTestData = {};
  static final List<StreamController> _activeControllers = [];
  static final List<Timer> _activeTimers = [];

  // ==========================================================================
  // 🚀 CORE INITIALIZATION
  // ==========================================================================

  /// Initialize enterprise-grade test environment
  ///
  /// Call this in main() of test files or in setUpAll()
  ///
  /// Features:
  /// - Logger configuration optimized for testing
  /// - Global mock setup and fallback registration
  /// - SharedPreferences mock initialization
  /// - Socket.IO mock infrastructure
  /// - Memory leak prevention
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   NeuronVaultTestConfig.initializeTestEnvironment();
  ///   // Your tests here
  /// }
  /// ```
  static void initializeTestEnvironment() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup enterprise test logger
    _testLogger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: false, // Disabled for CI/CD compatibility
        printEmojis: true,
        printTime: true,
        noBoxingByDefault: true, // Cleaner output
      ),
      level: Level.debug,
      filter: ProductionFilter(), // Only log in test environment
    );

    // Register global fallback values for mocktail
    _registerFallbackValues();

    // Initialize mock SharedPreferences with NeuronVault defaults
    _setupMockSharedPreferences();

    // Setup Socket.IO mock infrastructure
    _setupSocketIOMockInfrastructure();

    _testLogger.i('🧪 NeuronVault Enterprise Test Environment Initialized');
  }

  /// Register fallback values for all mocktail mocks - FIXED & COMPLETE
  static void _registerFallbackValues() {
    // Basic types
    registerFallbackValue(Level.info);
    registerFallbackValue(Level.debug);
    registerFallbackValue(Level.warning);
    registerFallbackValue(Level.error);
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(Uri.parse('https://test.neuronvault.com'));
    registerFallbackValue(DateTime.now());

    // Collection types for WebSocket service
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<String>[]);
    registerFallbackValue(<String, double>{});
    registerFallbackValue(<int>[]);

    // WebSocket Orchestration Service specific types - CRITICAL FIX
    registerFallbackValue(OrchestrationStrategy.parallel);
    registerFallbackValue(AIResponse(
      modelName: 'test_model',
      content: 'test_content',
      confidence: 0.8,
      responseTime: const Duration(milliseconds: 1000),
      timestamp: DateTime.now(),
    ));
    registerFallbackValue(OrchestrationProgress(
      completedModels: 0,
      totalModels: 1,
      currentPhase: 'test_phase',
      overallProgress: 0.0,
    ));

    // Socket.IO types
    registerFallbackValue(FakeSocket());

    // Function types for callbacks
    registerFallbackValue((dynamic data) {});
    registerFallbackValue(() {});

    _testLogger.d('✅ Fallback values registered for all custom types');
  }

  /// Setup mock SharedPreferences with NeuronVault specific data
  static void _setupMockSharedPreferences() {
    final defaultPrefs = {
      // App configuration
      'neuronvault_app_version': '2.5.0',
      'neuronvault_first_launch': false,
      'neuronvault_user_id': 'test_user_neuronvault_123',

      // AI orchestration settings
      'neuronvault_default_strategy': 'parallel',
      'neuronvault_auto_connect': true,
      'neuronvault_preferred_port': 3001,

      // Theme and UI
      'neuronvault_theme': 'cosmos',
      'neuronvault_dark_mode': true,
      'neuronvault_particles_enabled': true,

      // Audio settings (disabled for testing)
      'neuronvault_spatial_audio': false,
      'neuronvault_haptic_feedback': false,

      // Performance settings
      'neuronvault_max_concurrent_models': 4,
      'neuronvault_response_timeout': 30000,

      // Privacy settings (disabled for testing)
      'neuronvault_analytics_enabled': false,
      'neuronvault_crash_reporting': false,

      // Achievement system
      'neuronvault_achievements_v3': jsonEncode({}),
      'neuronvault_achievement_progress_v3': jsonEncode({}),

      // Test-specific flags
      'neuronvault_test_mode': true,
      'neuronvault_mock_backend': true,
    };

    SharedPreferences.setMockInitialValues(defaultPrefs);
    _testLogger.d('✅ Mock SharedPreferences initialized with NeuronVault defaults');
  }

  /// Setup Socket.IO mock infrastructure
  static void _setupSocketIOMockInfrastructure() {
    // Socket.IO testing will be handled by specific mock classes
    // This sets up the foundation for Socket.IO testing
    _globalTestData['socket_io_mock_enabled'] = true;
    _globalTestData['socket_io_auto_connect'] = false;
    _globalTestData['socket_io_simulation_delay'] = 50; // milliseconds

    _testLogger.d('✅ Socket.IO mock infrastructure ready');
  }

  // ==========================================================================
  // 🎭 MOCK CREATION UTILITIES
  // ==========================================================================

  /// Create a clean Riverpod container for isolated testing
  ///
  /// Each test gets a fresh container with no shared state
  ///
  /// Example:
  /// ```dart
  /// final container = NeuronVaultTestConfig.createTestContainer([
  ///   myProvider.overrideWith((ref) => mockValue),
  /// ]);
  /// ```
  static ProviderContainer createTestContainer({
    List<Override>? overrides,
    ProviderContainer? parent,
  }) {
    return ProviderContainer(
      overrides: overrides ?? [],
      parent: parent,
    );
  }

  /// Create test widget wrapper with NeuronVault theme and providers
  ///
  /// Supports all 6 neural luxury themes for comprehensive UI testing
  ///
  /// [child] - Widget to wrap
  /// [container] - Optional ProviderContainer
  /// [theme] - Neural theme ('cosmos', 'matrix', 'sunset', 'ocean', 'midnight', 'aurora')
  /// [screenSize] - Screen size for responsive testing
  ///
  /// Example:
  /// ```dart
  /// await tester.pumpWidget(
  ///   NeuronVaultTestConfig.createTestWrapper(
  ///     child: MyWidget(),
  ///     theme: 'matrix',
  ///     screenSize: Size(1920, 1080),
  ///   ),
  /// );
  /// ```
  static Widget createTestWrapper({
    required Widget child,
    ProviderContainer? container,
    String theme = 'cosmos',
    Size? screenSize,
  }) {
    final testContainer = container ?? createTestContainer();

    Widget wrappedChild = child;

    // Apply screen size if specified
    if (screenSize != null) {
      wrappedChild = SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: wrappedChild,
      );
    }

    return ProviderScope(
      parent: testContainer,
      child: MaterialApp(
        title: 'NeuronVault Test Environment',
        theme: _createTestThemeData(theme),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: wrappedChild,
        ),
      ),
    );
  }

  /// Create neural luxury theme data for testing
  static ThemeData _createTestThemeData(String themeName) {
    final neuralThemes = {
      'cosmos': {
        'primary': const Color(0xFF6366f1), // Indigo
        'secondary': const Color(0xFF8b5cf6), // Purple
        'accent': const Color(0xFF06b6d4), // Cyan
      },
      'matrix': {
        'primary': const Color(0xFF10b981), // Emerald
        'secondary': const Color(0xFF059669), // Dark emerald
        'accent': const Color(0xFF34d399), // Light emerald
      },
      'sunset': {
        'primary': const Color(0xFFf59e0b), // Amber
        'secondary': const Color(0xFFef4444), // Red
        'accent': const Color(0xFFfbbf24), // Yellow
      },
      'ocean': {
        'primary': const Color(0xFF3b82f6), // Blue
        'secondary': const Color(0xFF1e40af), // Dark blue
        'accent': const Color(0xFF60a5fa), // Light blue
      },
      'midnight': {
        'primary': const Color(0xFF6b7280), // Gray
        'secondary': const Color(0xFF374151), // Dark gray
        'accent': const Color(0xFF9ca3af), // Light gray
      },
      'aurora': {
        'primary': const Color(0xFF14b8a6), // Teal
        'secondary': const Color(0xFF0891b2), // Sky
        'accent': const Color(0xFF06b6d4), // Cyan
      },
    };

    final theme = neuralThemes[themeName] ?? neuralThemes['cosmos']!;

    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: theme['primary']!,
        secondary: theme['secondary']!,
        tertiary: theme['accent']!,
        surface: const Color(0xFF111827),
        background: const Color(0xFF0f172a),
      ),
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // ==========================================================================
  // 🌐 SOCKET.IO TESTING UTILITIES - FIXED
  // ==========================================================================

  /// Mock Socket.IO client for WebSocket orchestration testing
  ///
  /// Provides complete Socket.IO simulation without real network calls
  static MockSocketIO createMockSocketIO() {
    return MockSocketIO();
  }

  /// Create controlled Socket.IO event simulator
  ///
  /// Allows deterministic testing of Socket.IO event sequences
  ///
  /// Example:
  /// ```dart
  /// final simulator = NeuronVaultTestConfig.createSocketEventSimulator();
  /// simulator.simulateConnect();
  /// simulator.simulateEvent('individual_response', responseData);
  /// ```
  static SocketEventSimulator createSocketEventSimulator() {
    return SocketEventSimulator();
  }

  // ==========================================================================
  // 🧬 AI ORCHESTRATION TESTING DATA
  // ==========================================================================

  /// Generate realistic AI response for testing
  ///
  /// [modelName] - AI model name ('claude', 'gpt', 'deepseek', etc.)
  /// [prompt] - Original prompt
  /// [variation] - Response variation (0-4)
  static Map<String, dynamic> generateMockAIResponse({
    required String modelName,
    required String prompt,
    int variation = 0,
  }) {
    final responses = _getModelResponses(modelName, prompt);
    final selectedResponse = responses[variation % responses.length];

    return {
      'model_name': modelName,
      'model': modelName,
      'content': selectedResponse,
      'response': selectedResponse,
      'confidence': 0.8 + (variation * 0.05),
      'response_time_ms': 1000 + (variation * 200),
      'timestamp': DateTime.now().toIso8601String(),
      'metadata': {
        'tokens_used': selectedResponse.length ~/ 4,
        'processing_time': 1000 + (variation * 200),
        'model_version': _getModelVersion(modelName),
      },
    };
  }

  /// Get model-specific response variations
  static List<String> _getModelResponses(String modelName, String prompt) {
    final baseResponses = {
      'claude': [
        "I'll approach '$prompt' systematically. Let me break this down into key components and provide a structured analysis.",
        "Based on my understanding of '$prompt', I can offer a comprehensive perspective that considers multiple angles.",
        "Let me think through '$prompt' carefully. Here's my detailed analysis with supporting reasoning.",
        "I'd be happy to help with '$prompt'. This requires thoughtful consideration of several factors.",
        "Regarding '$prompt', I'll provide a thorough response that addresses the core elements.",
      ],
      'gpt': [
        "For '$prompt', I can provide a practical solution based on my training data and patterns.",
        "Here's my take on '$prompt': I'll combine several approaches to give you a comprehensive answer.",
        "I understand you're asking about '$prompt'. Let me break this down and provide actionable insights.",
        "Great question about '$prompt'! I'll share some practical perspectives and recommendations.",
        "Looking at '$prompt', I can offer both theoretical background and practical applications.",
      ],
      'deepseek': [
        "Through deep analysis of '$prompt', I've identified key technical patterns and optimal approaches.",
        "My technical assessment of '$prompt' reveals several important considerations and methodologies.",
        "Based on deep computational analysis, '$prompt' can be addressed through these technical frameworks.",
        "DeepSeek analysis of '$prompt' shows optimal pathways for implementation and execution.",
        "Technical evaluation of '$prompt' indicates these are the most efficient and effective solutions.",
      ],
      'gemini': [
        "I can help with '$prompt' by providing creative and multi-faceted perspectives from various angles.",
        "For '$prompt', let me combine analytical thinking with creative problem-solving approaches.",
        "Here's my multi-dimensional take on '$prompt', considering both conventional and innovative solutions.",
        "I'll address '$prompt' by integrating different viewpoints and offering comprehensive insights.",
        "Looking at '$prompt' from multiple perspectives, I can provide both analytical and creative solutions.",
      ],
      'mistral': [
        "Regarding '$prompt', I'll provide a balanced analysis with practical recommendations.",
        "Here's my structured approach to '$prompt' with clear, actionable guidance.",
        "For '$prompt', I can offer efficient solutions based on proven methodologies.",
        "My response to '$prompt' focuses on practical implementation and effective strategies.",
        "Addressing '$prompt' with a systematic approach that emphasizes clarity and efficiency.",
      ],
    };

    return baseResponses[modelName.toLowerCase()] ?? [
      "Here's my analysis of '$prompt' with detailed insights and recommendations.",
      "I can help with '$prompt' by providing comprehensive and well-reasoned responses.",
      "For '$prompt', let me offer a thorough examination with practical applications.",
    ];
  }

  /// Get model version for metadata
  static String _getModelVersion(String modelName) {
    final versions = {
      'claude': 'claude-3-sonnet-20240307',
      'gpt': 'gpt-4o-2024-05-13',
      'deepseek': 'deepseek-chat-v2',
      'gemini': 'gemini-pro-1.5',
      'mistral': 'mistral-medium-2312',
    };
    return versions[modelName.toLowerCase()] ?? '$modelName-v1.0';
  }

  /// Generate orchestration progress data
  static Map<String, dynamic> generateOrchestrationProgress({
    required int completedModels,
    required int totalModels,
    String? currentPhase,
  }) {
    return {
      'completed_models': completedModels,
      'total_models': totalModels,
      'current_phase': currentPhase ?? _generatePhase(completedModels, totalModels),
      'overall_progress': totalModels > 0 ? completedModels / totalModels : 0.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Generate realistic phase name
  static String _generatePhase(int completed, int total) {
    if (completed == 0) return 'Initializing orchestration';
    if (completed == total) return 'Synthesizing responses';
    return 'Processing model $completed/$total';
  }

  // ==========================================================================
  // ⏱️ PERFORMANCE & TIMING UTILITIES
  // ==========================================================================

  /// Measure test performance with detailed metrics
  ///
  /// Example:
  /// ```dart
  /// final metrics = await NeuronVaultTestConfig.measurePerformance(
  ///   testName: 'WebSocket Connection',
  ///   operation: () async {
  ///     await service.connect();
  ///   },
  /// );
  /// expect(metrics['duration_ms'], lessThan(1000));
  /// ```
  static Future<Map<String, dynamic>> measurePerformance({
    required String testName,
    required Future<void> Function() operation,
    int iterations = 1,
  }) async {
    final stopwatch = Stopwatch();
    final durations = <int>[];

    for (int i = 0; i < iterations; i++) {
      stopwatch.reset();
      stopwatch.start();
      await operation();
      stopwatch.stop();
      durations.add(stopwatch.elapsedMilliseconds);
    }

    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final minDuration = durations.reduce((a, b) => a < b ? a : b);
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);

    final metrics = {
      'test_name': testName,
      'iterations': iterations,
      'average_duration_ms': avgDuration.round(),
      'min_duration_ms': minDuration,
      'max_duration_ms': maxDuration,
      'meets_60fps_requirement': avgDuration < 16.67,
      'meets_performance_target': avgDuration < 100,
      'all_durations': durations,
    };

    _testLogger.d('⚡ Performance: $testName - ${avgDuration.round()}ms avg');
    return metrics;
  }

  /// Create deterministic delays for testing
  static Future<void> simulateProcessingTime({
    required String operation,
    int baseDelayMs = 50,
    int variationMs = 20,
  }) async {
    // Deterministic based on operation name for consistent testing
    final hash = operation.hashCode.abs();
    final delay = baseDelayMs + (hash % variationMs);
    await Future.delayed(Duration(milliseconds: delay));
  }

  // ==========================================================================
  // 🧹 RESOURCE MANAGEMENT - FIXED
  // ==========================================================================

  /// Register stream controller for automatic cleanup
  static void registerStreamController(StreamController controller) {
    _activeControllers.add(controller);
  }

  /// Register timer for automatic cleanup
  static void registerTimer(Timer timer) {
    _activeTimers.add(timer);
  }

  /// Cleanup all registered resources - FIXED race conditions
  static Future<void> cleanupResources() async {
    // Close all active stream controllers safely
    final controllersToClose = List<StreamController>.from(_activeControllers);
    _activeControllers.clear();

    for (final controller in controllersToClose) {
      try {
        if (!controller.isClosed) {
          await controller.close();
        }
      } catch (e) {
        // Silently handle already closed controllers
      }
    }

    // Cancel all active timers safely
    final timersToCancel = List<Timer>.from(_activeTimers);
    _activeTimers.clear();

    for (final timer in timersToCancel) {
      try {
        timer.cancel();
      } catch (e) {
        // Silently handle already cancelled timers
      }
    }

    // Clear global test data
    _globalTestData.clear();

    _testLogger.d('🧹 Test resources cleaned up safely');
  }

  /// Global test cleanup (call in tearDownAll)
  static Future<void> globalTestCleanup() async {
    await cleanupResources();
    SharedPreferences.setMockInitialValues({});
    _testLogger.i('✅ Global test cleanup completed');
  }

  // ==========================================================================
  // 📊 TEST REPORTING & DIAGNOSTICS
  // ==========================================================================

  /// Get test environment diagnostics
  static Map<String, dynamic> getDiagnostics() {
    return {
      'test_environment': 'NeuronVault Enterprise',
      'version': '2.5.0',
      'active_controllers': _activeControllers.length,
      'active_timers': _activeTimers.length,
      'global_data_size': _globalTestData.length,
      'logger_level': 'debug', // Static level for testing
      'mock_socket_io_enabled': _globalTestData['socket_io_mock_enabled'] ?? false,
      'shared_preferences_initialized': true,
    };
  }

  /// Get test logger for debugging
  static Logger get testLogger => _testLogger;

  /// Set global test data
  static void setGlobalTestData(String key, dynamic value) {
    _globalTestData[key] = value;
  }

  /// Get global test data
  static T? getGlobalTestData<T>(String key) {
    return _globalTestData[key] as T?;
  }
}

// =============================================================================
// 🎭 SPECIALIZED MOCK CLASSES - FIXED
// =============================================================================

/// Fake Socket for registerFallbackValue - CRITICAL FIX
class FakeSocket extends Fake implements IO.Socket {
  @override
  bool get connected => false;

  @override
  String? get id => 'fake_socket_id';
}

/// Mock Socket.IO client for testing - ENHANCED
class MockSocketIO extends Mock implements IO.Socket {
  final Map<String, List<dynamic Function(dynamic)>> _eventHandlers = {};
  final StreamController<Map<String, dynamic>> _eventController =
  StreamController<Map<String, dynamic>>.broadcast();

  bool _connected = false;
  String? _id;

  @override
  bool get connected => _connected;

  @override
  String? get id => _id;

  /// Simulate connection - FIXED
  void simulateConnect() {
    _connected = true;
    _id = 'mock_socket_${DateTime.now().millisecondsSinceEpoch}';
    _triggerEvent('connect', []);
  }

  /// Simulate disconnection - FIXED
  void simulateDisconnect([String? reason]) {
    _connected = false;
    _triggerEvent('disconnect', [reason ?? 'io client disconnect']);
  }

  /// Simulate receiving an event - FIXED
  void simulateEvent(String event, dynamic data) {
    _triggerEvent(event, [data]);
  }

  /// Trigger event handlers with proper argument handling - FIXED
  void _triggerEvent(String event, List<dynamic> args) {
    final handlers = _eventHandlers[event] ?? [];
    for (final handler in handlers) {
      try {
        if (args.isEmpty) {
          handler(null);
        } else {
          handler(args.length == 1 ? args[0] : args);
        }
      } catch (e) {
        // Silently handle callback errors in tests
      }
    }
  }

  @override
  dynamic Function() on(String event, dynamic Function(dynamic) callback) {
    _eventHandlers.putIfAbsent(event, () => []).add(callback);
    return () {}; // Return a function that can be used to unsubscribe
  }

  @override
  dynamic Function() onConnect(dynamic Function(dynamic) callback) => on('connect', callback);

  @override
  dynamic Function() onDisconnect(dynamic Function(dynamic) callback) => on('disconnect', callback);

  @override
  dynamic Function() onConnectError(dynamic Function(dynamic) callback) => on('connect_error', callback);

  @override
  dynamic Function() onError(dynamic Function(dynamic) callback) => on('error', callback);

  @override
  IO.Socket emit(String event, [dynamic data]) {
    // Simulate emission delay
    Timer(const Duration(milliseconds: 10), () {
      // Echo certain events for testing
      if (event == 'ping') {
        simulateEvent('pong', data);
      }
    });
    return this;
  }

  @override
  IO.Socket connect() {
    Timer(const Duration(milliseconds: 50), () {
      simulateConnect();
    });
    return this;
  }

  @override
  IO.Socket disconnect() {
    simulateDisconnect();
    return this;
  }

  @override
  void dispose() {
    _eventHandlers.clear();
    if (!_eventController.isClosed) {
      _eventController.close();
    }
    _connected = false;
  }
}

/// Socket event simulator for complex testing scenarios - ENHANCED
class SocketEventSimulator {
  final MockSocketIO _socket = MockSocketIO();
  final List<Timer> _scheduledEvents = [];

  MockSocketIO get socket => _socket;

  /// Schedule a sequence of events
  void scheduleEventSequence(List<SocketEvent> events) {
    var delay = 0;

    for (final event in events) {
      final timer = Timer(Duration(milliseconds: delay), () {
        _socket.simulateEvent(event.name, event.data);
      });

      _scheduledEvents.add(timer);
      delay += event.delayMs;
    }
  }

  /// Simulate AI orchestration flow - ENHANCED
  void simulateOrchestrationFlow({
    required List<String> models,
    required String prompt,
    int delayBetweenResponses = 500,
  }) {
    final events = <SocketEvent>[];

    // Start orchestration
    events.add(SocketEvent('orchestration_start', {
      'models': models,
      'prompt': prompt,
    }));

    // Individual responses
    for (int i = 0; i < models.length; i++) {
      events.add(SocketEvent(
        'individual_response',
        NeuronVaultTestConfig.generateMockAIResponse(
          modelName: models[i],
          prompt: prompt,
          variation: i,
        ),
        delayMs: (i + 1) * delayBetweenResponses,
      ));

      events.add(SocketEvent(
        'orchestration_progress',
        NeuronVaultTestConfig.generateOrchestrationProgress(
          completedModels: i + 1,
          totalModels: models.length,
        ),
        delayMs: (i + 1) * delayBetweenResponses + 50,
      ));
    }

    // Final synthesis
    events.add(SocketEvent(
      'synthesis_complete',
      {
        'synthesis': '🧬 Orchestrated synthesis of ${models.length} AI responses for: $prompt',
        'final_response': 'Comprehensive orchestrated response combining multiple AI perspectives.',
      },
      delayMs: models.length * delayBetweenResponses + 300,
    ));

    scheduleEventSequence(events);
  }

  /// Cleanup - FIXED resource management
  void dispose() {
    for (final timer in _scheduledEvents) {
      try {
        timer.cancel();
      } catch (e) {
        // Silently handle already cancelled timers
      }
    }
    _scheduledEvents.clear();
    _socket.dispose();
  }
}

/// Socket event for simulation
class SocketEvent {
  final String name;
  final dynamic data;
  final int delayMs;

  const SocketEvent(this.name, this.data, {this.delayMs = 0});
}

// =============================================================================
// 🎯 TEST CONSTANTS - ENHANCED
// =============================================================================

/// Enterprise test constants for NeuronVault
class TestConstants {
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration socketTimeout = Duration(seconds: 5);
  static const Duration performanceTimeout = Duration(seconds: 2);

  // Performance thresholds
  static const int maxConnectionTimeMs = 1000;
  static const int maxResponseTimeMs = 3000;
  static const int maxMemoryUsageMB = 256;

  // AI Models
  static const List<String> testAIModels = [
    'claude', 'gpt', 'deepseek', 'gemini', 'mistral', 'llama', 'ollama'
  ];

  // Orchestration strategies
  static const List<String> orchestrationStrategies = [
    'parallel', 'consensus', 'weighted', 'adaptive', 'sequential'
  ];

  // Neural themes
  static const List<String> neuralThemes = [
    'cosmos', 'matrix', 'sunset', 'ocean', 'midnight', 'aurora'
  ];

  // Socket.IO events
  static const List<String> socketEvents = [
    'connect', 'disconnect', 'connect_error', 'error',
    'individual_response', 'orchestration_progress', 'synthesis_complete',
    'stream_chunk', 'streaming_completed', 'stream_error'
  ];

  // Test ports for auto-discovery
  static const List<int> testPorts = [3001, 3002, 3003, 3004, 3005];
}