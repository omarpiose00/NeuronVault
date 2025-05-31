// test/unit/helpers/service_test_base.dart
// 🧪 NEURONVAULT - SERVICE TEST BASE CLASS
// Enterprise-grade testing foundation for all services
// Supports PHASE 3.4 - Athena AI Integration + Achievement System

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../../../lib/core/services/config_service.dart';
import '../../../lib/core/services/storage_service.dart';
import '../../../lib/core/services/ai_service.dart';
import '../../../lib/core/services/analytics_service.dart';
import '../../../lib/core/services/theme_service.dart';
import '../../../lib/core/services/achievement_service.dart';
import '../../../lib/core/services/websocket_orchestration_service.dart';
import '../../../lib/core/state/state_models.dart';
import '../mocks/mock_services.dart' hide TestDataFactory;
import '../mocks/test_data.dart';
import 'test_helpers.dart';

/// 🏗️ Base class for all service tests in NeuronVault
/// Provides common setup, teardown, and utility methods
abstract class ServiceTestBase {
  // 🔧 Core infrastructure
  late SharedPreferences mockPrefs;
  late FlutterSecureStorage mockSecureStorage;
  late Logger mockLogger;
  late TestEnvironment testEnvironment;

  // 📊 Test metrics
  late Stopwatch testStopwatch;
  final List<String> testLogs = [];
  final Map<String, dynamic> testMetrics = {};

  // 🎯 Test configuration
  bool get enablePerformanceTests => false;
  bool get enableIntegrationTests => true;
  bool get enableErrorInjection => true;
  Duration get maxTestDuration => const Duration(seconds: 30);

  /// 🚀 Setup method - call this in your test's setUp()
  Future<void> setUpServiceTest() async {
    testStopwatch = Stopwatch()..start();

    try {
      mockLogger = TestHelpers.createTestLogger(level: Level.debug);
      mockLogger.i('🧪 Starting service test setup...');

      // Initialize test environment
      testEnvironment = await TestHelpers.setupCompleteTestEnvironment(
        logLevel: Level.debug,
      );

      mockPrefs = testEnvironment.preferences;
      mockSecureStorage = testEnvironment.secureStorage as FlutterSecureStorage;

      // Initialize test data
      TestDataFactory.resetCounters();

      // Service-specific setup
      await setUpServiceSpecific();

      final setupTime = testStopwatch.elapsedMilliseconds;
      mockLogger.i('✅ Service test setup completed in ${setupTime}ms');
      testMetrics['setup_time_ms'] = setupTime;

    } catch (e, stackTrace) {
      mockLogger.e('❌ Service test setup failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// 🧹 Teardown method - call this in your test's tearDown()
  Future<void> tearDownServiceTest() async {
    try {
      mockLogger.i('🧹 Starting service test teardown...');

      // Service-specific teardown
      await tearDownServiceSpecific();

      // Cleanup test environment
      await TestHelpers.cleanupTestResources();

      testStopwatch.stop();
      final totalTime = testStopwatch.elapsedMilliseconds;
      testMetrics['total_time_ms'] = totalTime;

      mockLogger.i('✅ Service test teardown completed. Total time: ${totalTime}ms');

      // Performance validation
      if (enablePerformanceTests && totalTime > maxTestDuration.inMilliseconds) {
        mockLogger.w('⚠️ Test exceeded maximum duration: ${totalTime}ms > ${maxTestDuration.inMilliseconds}ms');
      }

    } catch (e, stackTrace) {
      mockLogger.e('❌ Service test teardown failed', error: e, stackTrace: stackTrace);
    }
  }

  /// 🔧 Service-specific setup - override in your service test
  Future<void> setUpServiceSpecific() async {
    // Override in subclasses
  }

  /// 🧹 Service-specific teardown - override in your service test
  Future<void> tearDownServiceSpecific() async {
    // Override in subclasses
  }

  // 📊 COMMON TEST UTILITIES

  /// ⚡ Execute test with performance monitoring
  Future<T> executeWithPerformanceMonitoring<T>(
      String testName,
      Future<T> Function() testFunction, {
        Duration? expectedMaxDuration,
      }) async {
    final stopwatch = Stopwatch()..start();
    mockLogger.d('🚀 Starting performance test: $testName');

    try {
      final result = await testFunction();

      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      testMetrics['${testName}_duration_ms'] = duration;
      mockLogger.i('✅ Performance test completed: $testName in ${duration}ms');

      if (expectedMaxDuration != null && duration > expectedMaxDuration.inMilliseconds) {
        mockLogger.w('⚠️ Performance test exceeded expected duration: $testName');
        fail('Test $testName took ${duration}ms, expected max ${expectedMaxDuration.inMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();
      mockLogger.e('❌ Performance test failed: $testName after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }

  /// 🔄 Execute test with retry logic
  Future<T> executeWithRetry<T>(
      String testName,
      Future<T> Function() testFunction, {
        int maxAttempts = 3,
        Duration delay = const Duration(milliseconds: 100),
      }) async {
    mockLogger.d('🔄 Starting retry test: $testName (max $maxAttempts attempts)');

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        mockLogger.d('📊 Attempt $attempt/$maxAttempts for $testName');
        final result = await testFunction();

        if (attempt > 1) {
          mockLogger.i('✅ Retry test succeeded on attempt $attempt: $testName');
        }

        testMetrics['${testName}_attempts'] = attempt;
        return result;
      } catch (e) {
        if (attempt == maxAttempts) {
          mockLogger.e('❌ Retry test failed after $maxAttempts attempts: $testName');
          testMetrics['${testName}_failed_attempts'] = maxAttempts;
          rethrow;
        }

        mockLogger.w('⚠️ Attempt $attempt failed for $testName, retrying...');
        await Future.delayed(delay);
      }
    }

    throw StateError('Should not reach this point');
  }

  /// 🛡️ Execute test with error injection
  Future<void> executeWithErrorInjection(
      String testName,
      Future<void> Function() testFunction,
      Future<void> Function(dynamic error) errorHandler,
      ) async {
    if (!enableErrorInjection) {
      mockLogger.d('ℹ️ Error injection disabled, running normal test: $testName');
      await testFunction();
      return;
    }

    mockLogger.d('🛡️ Starting error injection test: $testName');

    try {
      await testFunction();
      mockLogger.i('✅ Error injection test completed without errors: $testName');
    } catch (e) {
      mockLogger.d('🎯 Error caught in injection test: $testName - $e');
      await errorHandler(e);
      testMetrics['${testName}_error_handled'] = true;
    }
  }

  /// ⏱️ Wait for async condition with timeout
  Future<void> waitForCondition(
      String conditionName,
      bool Function() condition, {
        Duration timeout = const Duration(seconds: 5),
        Duration checkInterval = const Duration(milliseconds: 50),
      }) async {
    mockLogger.d('⏱️ Waiting for condition: $conditionName');

    await TestHelpers.waitForCondition(
      condition,
      timeout: timeout,
      checkInterval: checkInterval,
      timeoutMessage: 'Condition not met: $conditionName',
    );

    mockLogger.d('✅ Condition met: $conditionName');
  }

  /// 📡 Test stream operations
  Future<List<T>> testStreamOperations<T>(
      String streamName,
      Stream<T> stream, {
        int expectedEventCount = 1,
        Duration timeout = const Duration(seconds: 5),
      }) async {
    mockLogger.d('📡 Testing stream operations: $streamName');

    final events = await TestHelpers.collectStreamEvents<T>(
      stream,
      count: expectedEventCount,
      timeout: timeout,
    );

    mockLogger.i('✅ Stream test completed: $streamName with ${events.length} events');
    testMetrics['${streamName}_events_received'] = events.length;

    return events;
  }

  // 🔧 SERVICE CREATION HELPERS

  /// 🛠️ Create ConfigService with test dependencies
  ConfigService createConfigService() {
    return ConfigService(
      sharedPreferences: mockPrefs,
      secureStorage: mockSecureStorage,
      logger: mockLogger,
    );
  }

  /// 💾 Create StorageService with test dependencies
  StorageService createStorageService() {
    return StorageService(
      sharedPreferences: mockPrefs,
      secureStorage: mockSecureStorage,
      logger: mockLogger,
    );
  }

  /// 📊 Create AnalyticsService with test dependencies
  AnalyticsService createAnalyticsService() {
    final storageService = createStorageService();
    return AnalyticsService(
      storageService: storageService,
      logger: mockLogger,
    );
  }

  /// 🎨 Create ThemeService with test dependencies
  ThemeService createThemeService() {
    final configService = createConfigService();
    return ThemeService(
      configService: configService,
      logger: mockLogger,
    );
  }

  /// 🤖 Create AIService with test dependencies
  AIService createAIService() {
    final configService = createConfigService();
    final storageService = createStorageService();
    return AIService(
      configService: configService,
      logger: mockLogger,
      storageService: storageService,
    );
  }

  // 📊 DATA VALIDATION HELPERS

  /// ✅ Validate service initialization
  void validateServiceInitialization(dynamic service, String serviceName) {
    expect(service, isNotNull, reason: '$serviceName should not be null');
    mockLogger.d('✅ Service validation passed: $serviceName');
  }

  /// 📋 Validate state model structure
  void validateStateModel<T>(T model, String modelName) {
    expect(model, isNotNull, reason: '$modelName should not be null');
    expect(model, isA<T>(), reason: '$modelName should be of correct type');
    mockLogger.d('✅ State model validation passed: $modelName');
  }

  /// 📊 Validate test metrics
  void validateTestMetrics() {
    expect(testMetrics, isNotEmpty, reason: 'Test metrics should be collected');

    if (testMetrics.containsKey('setup_time_ms')) {
      final setupTime = testMetrics['setup_time_ms'] as int;
      expect(setupTime, lessThan(5000), reason: 'Setup should complete within 5 seconds');
    }

    mockLogger.i('✅ Test metrics validation passed');
  }

  // 🎯 SPECIFIC TEST PATTERNS

  /// 🔄 Test save/load operations
  Future<void> testSaveLoadOperation<T>(
      String operationName,
      Future<void> Function(T data) saveFunction,
      Future<T?> Function() loadFunction,
      T testData,
      bool Function(T saved, T loaded) validator,
      ) async {
    mockLogger.d('🔄 Testing save/load operation: $operationName');

    // Save data
    await executeWithPerformanceMonitoring(
      '${operationName}_save',
          () => saveFunction(testData),
      expectedMaxDuration: const Duration(seconds: 2),
    );

    // Load data
    final loadedData = await executeWithPerformanceMonitoring(
      '${operationName}_load',
      loadFunction,
      expectedMaxDuration: const Duration(seconds: 1),
    );

    // Validate
    expect(loadedData, isNotNull, reason: 'Loaded data should not be null');
    expect(validator(testData, loadedData!), isTrue,
        reason: 'Saved and loaded data should match');

    mockLogger.i('✅ Save/load operation test passed: $operationName');
  }

  /// 🧪 Test error scenarios
  Future<void> testErrorScenarios(
      String scenarioName,
      Future<void> Function() operationThatShouldFail,
      Type expectedExceptionType,
      ) async {
    mockLogger.d('🧪 Testing error scenario: $scenarioName');

    bool exceptionThrown = false;
    Type? actualExceptionType;

    try {
      await operationThatShouldFail();
    } catch (e) {
      exceptionThrown = true;
      actualExceptionType = e.runtimeType;
      mockLogger.d('🎯 Expected exception caught: $actualExceptionType');
    }

    expect(exceptionThrown, isTrue,
        reason: 'Operation should throw an exception for scenario: $scenarioName');
    expect(actualExceptionType, equals(expectedExceptionType),
        reason: 'Exception type should match expected for scenario: $scenarioName');

    mockLogger.i('✅ Error scenario test passed: $scenarioName');
  }

  /// 📈 Test performance benchmarks
  Future<void> testPerformanceBenchmark(
      String benchmarkName,
      Future<void> Function() operation,
      Duration maxExpectedDuration,
      {int iterations = 1}
      ) async {
    if (!enablePerformanceTests) {
      mockLogger.d('ℹ️ Performance tests disabled, skipping benchmark: $benchmarkName');
      return;
    }

    mockLogger.d('📈 Running performance benchmark: $benchmarkName');

    final durations = <int>[];

    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      await operation();
      stopwatch.stop();
      durations.add(stopwatch.elapsedMilliseconds);
    }

    final averageDuration = durations.reduce((a, b) => a + b) / durations.length;
    final maxDuration = durations.reduce((a, b) => a > b ? a : b);

    testMetrics['${benchmarkName}_average_ms'] = averageDuration;
    testMetrics['${benchmarkName}_max_ms'] = maxDuration;
    testMetrics['${benchmarkName}_iterations'] = iterations;

    expect(maxDuration, lessThan(maxExpectedDuration.inMilliseconds),
        reason: 'Performance benchmark failed: $benchmarkName');

    mockLogger.i('✅ Performance benchmark passed: $benchmarkName (avg: ${averageDuration.toStringAsFixed(1)}ms)');
  }

  // 🏆 ACHIEVEMENT SYSTEM HELPERS

  /// 🏆 Validate achievement operations
  void validateAchievementOperation(Achievement achievement) {
    expect(achievement.id, isNotEmpty, reason: 'Achievement ID should not be empty');
    expect(achievement.title, isNotEmpty, reason: 'Achievement title should not be empty');
    expect(achievement.category, isNotNull, reason: 'Achievement category should be set');
    expect(achievement.rarity, isNotNull, reason: 'Achievement rarity should be set');
    expect(achievement.targetProgress, greaterThan(0), reason: 'Target progress should be positive');

    if (achievement.isUnlocked) {
      expect(achievement.unlockedAt, isNotNull, reason: 'Unlocked achievement should have unlock date');
      expect(achievement.currentProgress, greaterThanOrEqualTo(achievement.targetProgress),
          reason: 'Unlocked achievement should have completed progress');
    }

    mockLogger.d('✅ Achievement validation passed: ${achievement.title}');
  }

  /// 🔗 Test service integrations
  Future<void> testServiceIntegration(
      String integrationName,
      List<Future<void> Function()> integrationSteps,
      ) async {
    mockLogger.d('🔗 Testing service integration: $integrationName');

    for (int i = 0; i < integrationSteps.length; i++) {
      mockLogger.d('📊 Integration step ${i + 1}/${integrationSteps.length}');
      await integrationSteps[i]();
    }

    mockLogger.i('✅ Service integration test passed: $integrationName');
  }

  // 📊 TEST REPORTING

  /// 📊 Get test metrics summary
  Map<String, dynamic> getTestMetrics() {
    return Map.from(testMetrics);
  }

  /// 📝 Generate test report
  String generateTestReport() {
    final buffer = StringBuffer();
    buffer.writeln('🧪 SERVICE TEST REPORT');
    buffer.writeln('=' * 50);

    if (testMetrics.containsKey('setup_time_ms')) {
      buffer.writeln('⚡ Setup Time: ${testMetrics['setup_time_ms']}ms');
    }

    if (testMetrics.containsKey('total_time_ms')) {
      buffer.writeln('⏱️ Total Time: ${testMetrics['total_time_ms']}ms');
    }

    buffer.writeln('📊 Metrics:');
    testMetrics.forEach((key, value) {
      if (!key.endsWith('_time_ms')) {
        buffer.writeln('  • $key: $value');
      }
    });

    if (testLogs.isNotEmpty) {
      buffer.writeln('📝 Test Logs:');
      for (final log in testLogs.take(10)) { // Show last 10 logs
        buffer.writeln('  • $log');
      }
    }

    return buffer.toString();
  }

  /// 🧹 Memory leak detection
  void checkForMemoryLeaks(dynamic service, String serviceName) {
    TestHelpers.verifyNoMemoryLeaks(service, serviceName: serviceName);
    mockLogger.d('✅ Memory leak check passed: $serviceName');
  }
}