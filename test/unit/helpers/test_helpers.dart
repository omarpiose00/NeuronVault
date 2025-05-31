import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// 🔐 Simple wrapper for FlutterSecureStorage in tests
class TestSecureStorageWrapper {
  final Map<String, String> _storage = {};
  bool _throwErrors = false;

  // For testing error scenarios
  void setThrowErrors(bool shouldThrow) {
    _throwErrors = shouldThrow;
  }

  void _checkErrors() {
    if (_throwErrors) {
      throw Exception('Test storage error');
    }
  }

  Future<String?> read(String key) async {
    _checkErrors();
    return _storage[key];
  }

  Future<void> write(String key, String? value) async {
    _checkErrors();
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  Future<void> delete(String key) async {
    _checkErrors();
    _storage.remove(key);
  }

  Future<void> deleteAll() async {
    _checkErrors();
    _storage.clear();
  }

  Future<Map<String, String>> readAll() async {
    _checkErrors();
    return Map.from(_storage);
  }

  Future<bool> containsKey(String key) async {
    _checkErrors();
    return _storage.containsKey(key);
  }

  // Direct access for testing
  Map<String, String> get storage => Map.from(_storage);
  void clearStorage() => _storage.clear();
  void setStorageData(Map<String, String> data) {
    _storage.clear();
    _storage.addAll(data);
  }
}

// 🔧 Interface for disposable services
abstract class Disposable {
  void dispose();
}

// 📝 Enhanced test logger with capture capability
class TestLogger extends Logger {
  final List<LogEvent> capturedLogs = [];

  TestLogger({Level level = Level.off}) : super(
    level: level,
    printer: PrettyPrinter(methodCount: 0),
  );

  @override
  void log(Level level, dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    capturedLogs.add(LogEvent(level, message, error: error, stackTrace: stackTrace));
    super.log(level, message, time: time, error: error, stackTrace: stackTrace);
  }

  // Helper methods for test verification
  bool hasLoggedLevel(Level level) => capturedLogs.any((log) => log.level == level);
  bool hasLoggedMessage(String message) => capturedLogs.any((log) => log.message.toString().contains(message));
  void clearLogs() => capturedLogs.clear();
  int getLogCount(Level level) => capturedLogs.where((log) => log.level == level).length;
}

// 📊 Log event for captured logs
class LogEvent {
  final Level level;
  final dynamic message;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  LogEvent(this.level, this.message, {this.error, this.stackTrace})
      : timestamp = DateTime.now();
}

// 🧪 Main test helpers class
class TestHelpers {
  static final Map<String, dynamic> _testResources = {};

  // 🔧 Setup shared preferences for testing (ENHANCED)
  static Future<SharedPreferences> setupTestPreferences([Map<String, dynamic>? initialData]) async {
    // Convert to proper Object type for SharedPreferences
    final Map<String, Object> convertedData = {};
    if (initialData != null) {
      initialData.forEach((key, value) {
        if (value is String || value is bool || value is int || value is double || value is List<String>) {
          convertedData[key] = value;
        } else {
          // Convert complex types to strings
          convertedData[key] = value.toString();
        }
      });
    }

    SharedPreferences.setMockInitialValues(convertedData);
    final prefs = await SharedPreferences.getInstance();
    _testResources['preferences'] = prefs;
    return prefs;
  }

  // 🔐 Create mock secure storage with test capabilities
  static TestSecureStorageWrapper createMockSecureStorage({Map<String, String>? initialData}) {
    final storage = TestSecureStorageWrapper();
    if (initialData != null) {
      storage.setStorageData(initialData);
    }
    _testResources['secureStorage'] = storage;
    return storage;
  }

  // 📝 Create enhanced test logger
  static TestLogger createTestLogger({Level level = Level.off, bool captureEnabled = true}) {
    final logger = TestLogger(level: level);
    _testResources['logger'] = logger;
    return logger;
  }

  // ⏰ Create test delay with optional callback
  static Future<void> testDelay([int milliseconds = 100, void Function()? onComplete]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    onComplete?.call();
  }

  // 🎯 Wait for condition to be true (with timeout)
  static Future<void> waitForCondition(
      bool Function() condition, {
        Duration timeout = const Duration(seconds: 5),
        Duration checkInterval = const Duration(milliseconds: 50),
        String? timeoutMessage,
      }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (condition()) return;
      await Future.delayed(checkInterval);
    }

    throw TimeoutException(
      timeoutMessage ?? 'Condition not met within timeout',
      timeout,
    );
  }

  // 📡 Helper for testing streams
  static Future<T> expectStreamEvent<T>(
      Stream<T> stream, {
        Duration timeout = const Duration(seconds: 5),
        bool Function(T)? where,
      }) async {
    if (where != null) {
      return await stream.where(where).first.timeout(timeout);
    }
    return await stream.first.timeout(timeout);
  }

  // 📡 Collect multiple stream events
  static Future<List<T>> collectStreamEvents<T>(
      Stream<T> stream, {
        int count = 1,
        Duration timeout = const Duration(seconds: 5),
      }) async {
    final events = <T>[];
    final subscription = stream.listen(events.add);

    try {
      await waitForCondition(
            () => events.length >= count,
        timeout: timeout,
        timeoutMessage: 'Expected $count events, got ${events.length}',
      );
      return events.take(count).toList();
    } finally {
      await subscription.cancel();
    }
  }

  // 🧪 Enhanced memory leak verification
  static void verifyNoMemoryLeaks(dynamic service, {String? serviceName}) {
    final name = serviceName ?? service.runtimeType.toString();

    expect(service, isNotNull, reason: '$name should not be null');

    // Check if service has dispose method and call it
    if (service is Disposable) {
      expect(
            () => service.dispose(),
        returnsNormally,
        reason: '$name dispose should complete without errors',
      );
    }

    // Additional checks could be added here based on service type
    // For example, checking if streams are closed, timers are cancelled, etc.
  }

  // 🔧 Setup complete test environment
  static Future<TestEnvironment> setupCompleteTestEnvironment({
    Map<String, dynamic>? prefsInitialData,
    Map<String, String>? secureStorageInitialData,
    Level logLevel = Level.off,
  }) async {
    final prefs = await setupTestPreferences(prefsInitialData);
    final secureStorage = createMockSecureStorage(initialData: secureStorageInitialData);
    final logger = createTestLogger(level: logLevel);

    return TestEnvironment(
      preferences: prefs,
      secureStorage: secureStorage,
      logger: logger,
    );
  }

  // 🧹 Cleanup test resources
  static Future<void> cleanupTestResources() async {
    // Clear secure storage if it exists
    final storage = _testResources['secureStorage'] as TestSecureStorageWrapper?;
    storage?.clearStorage();

    // Clear logger if it exists
    final logger = _testResources['logger'] as TestLogger?;
    logger?.clearLogs();

    // Clear any stored test resources
    _testResources.clear();

    // Reset SharedPreferences with proper type
    SharedPreferences.setMockInitialValues(<String, Object>{});
  }

  // 🎭 Create service with all dependencies mocked
  static Future<T> createServiceWithMocks<T>(
      T Function(TestEnvironment env) factory, {
        Map<String, dynamic>? prefsData,
        Map<String, String>? secureData,
      }) async {
    final env = await setupCompleteTestEnvironment(
      prefsInitialData: prefsData,
      secureStorageInitialData: secureData,
    );
    return factory(env);
  }

  // 🔍 Debug helpers
  static void debugPrintTestState() {
    print('🧪 Test Resources State:');
    _testResources.forEach((key, value) {
      print('  $key: ${value.runtimeType}');
    });
  }

  // ⚡ Performance testing helpers
  static Future<Duration> measureExecutionTime(Future<void> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    await operation();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  // 🎯 Verify execution time is within bounds
  static Future<void> verifyPerformance(
      Future<void> Function() operation,
      Duration maxDuration, {
        String? operationName,
      }) async {
    final duration = await measureExecutionTime(operation);
    final name = operationName ?? 'Operation';

    expect(
      duration,
      lessThan(maxDuration),
      reason: '$name took ${duration.inMilliseconds}ms, expected less than ${maxDuration.inMilliseconds}ms',
    );
  }

  // 🔄 Retry helper for flaky operations
  static Future<T> retryOperation<T>(
      Future<T> Function() operation, {
        int maxAttempts = 3,
        Duration delay = const Duration(milliseconds: 100),
      }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(delay);
      }
    }
    throw StateError('Retry operation failed unexpectedly');
  }

  // 📊 Test data generators
  static Map<String, Object> generateTestConfig({
    String theme = 'neural',
    bool isDarkMode = true,
    Map<String, Object>? additional,
  }) {
    final Map<String, Object> config = {
      'theme': theme,
      'isDarkMode': isDarkMode,
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (additional != null) {
      config.addAll(additional);
    }

    return config;
  }

  // 🎲 Generate test IDs
  static String generateTestId([String prefix = 'test']) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// 🌍 Test environment container
class TestEnvironment {
  final SharedPreferences preferences;
  final TestSecureStorageWrapper secureStorage;
  final TestLogger logger;

  const TestEnvironment({
    required this.preferences,
    required this.secureStorage,
    required this.logger,
  });

  // Convenience methods for secure storage access
  Future<String?> readSecure(String key) => secureStorage.read(key);
  Future<void> writeSecure(String key, String? value) => secureStorage.write(key, value);
  Future<void> deleteSecure(String key) => secureStorage.delete(key);
}

// 🔧 Test configuration builder
class TestConfigBuilder {
  final Map<String, Object> _config = {};

  TestConfigBuilder theme(String theme) {
    _config['theme'] = theme;
    return this;
  }

  TestConfigBuilder darkMode(bool isDark) {
    _config['isDarkMode'] = isDark;
    return this;
  }

  TestConfigBuilder custom(String key, Object value) {
    _config[key] = value;
    return this;
  }

  Map<String, Object> build() => Map.from(_config);
}

// 🎯 Extension methods for common test patterns
extension TestFutureExtensions<T> on Future<T> {
  Future<T> withTimeout([Duration timeout = const Duration(seconds: 5)]) {
    return this.timeout(timeout);
  }

  Future<T> withRetry([int maxAttempts = 3]) {
    return TestHelpers.retryOperation(() => this, maxAttempts: maxAttempts);
  }
}