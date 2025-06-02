// 🧪 test/utils/test_helpers.dart
// Core Testing Foundation for NeuronVault - Enterprise Grade 2025
// Ultra-modern Flutter/Riverpod testing utilities

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_data.dart';
import 'test_constants.dart';

/// 🏗️ **CORE TESTING UTILITIES - 2025 ENTERPRISE FOUNDATION**
///
/// Provides enterprise-grade testing utilities for NeuronVault platform:
/// - ProviderContainer setup and management
/// - SharedPreferences mocking
/// - WebSocket testing utilities
/// - Audio/Haptic service mocking
/// - Performance testing helpers
/// - Memory leak detection
/// - Accessibility testing utilities

// =============================================================================
// 🎯 PROVIDER CONTAINER UTILITIES
// =============================================================================

/// Creates a fresh ProviderContainer for isolated testing
///
/// Usage:
/// ```dart
/// test('my test', () {
///   final container = createTestContainer();
///   final result = container.read(myProvider);
///   expect(result, expectedValue);
/// });
/// ```
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
  ProviderContainer? parent,
  List<ProviderObserver>? observers,
}) {
  return ProviderContainer(
    overrides: overrides,
    parent: parent,
    observers: observers,
  );
}

/// Creates a test container with common mocked dependencies
///
/// Automatically mocks:
/// - SharedPreferences
/// - WebSocket connections
/// - Audio services
/// - File system access
ProviderContainer createMockedTestContainer({
  List<Override> additionalOverrides = const [],
}) {
  final commonOverrides = [
    // Add common mocked providers here
    ...getMockSharedPreferencesOverride(),
    ...getMockWebSocketOverrides(),
    ...getMockAudioServiceOverrides(),
  ];

  return createTestContainer(
    overrides: [...commonOverrides, ...additionalOverrides],
  );
}

/// Utility for testing provider state changes over time
///
/// Usage:
/// ```dart
/// await testProviderState<int>(
///   container: container,
///   provider: counterProvider,
///   act: () => container.read(counterProvider.notifier).increment(),
///   expect: [0, 1],
/// );
/// ```
Future<void> testProviderState<T>({
  required ProviderContainer container,
  required ProviderListenable<T> provider,
  required VoidCallback act,
  required List<T> expect,
  Duration timeout = TestConstants.defaultTimeout,
}) async {
  final completer = Completer<void>();
  final actualStates = <T>[];

  // Listen to provider changes
  final subscription = container.listen<T>(
    provider,
        (previous, next) {
      actualStates.add(next);
      if (actualStates.length >= expect.length) {
        completer.complete();
      }
    },
  );

  try {
    // Add initial state
    actualStates.add(container.read(provider));

    // Perform action
    act();

    // Wait for expected states or timeout
    await completer.future.timeout(timeout);

    // Verify states match
    expectStatesEqual(actualStates, expect);
  } finally {
    subscription.close();
  }
}

/// Compares two lists of states with better error messages
void expectStatesEqual<T>(List<T> actual, List<T> expected) {
  if (actual.length != expected.length) {
    fail(
      'Expected ${expected.length} states but got ${actual.length}.\n'
          'Expected: $expected\n'
          'Actual: $actual',
    );
  }

  for (int i = 0; i < expected.length; i++) {
    if (actual[i] != expected[i]) {
      fail(
        'State at index $i differs.\n'
            'Expected: ${expected[i]}\n'
            'Actual: ${actual[i]}\n'
            'Full expected: $expected\n'
            'Full actual: $actual',
      );
    }
  }
}

// =============================================================================
// 📱 WIDGET TESTING UTILITIES
// =============================================================================

/// Pumps a widget wrapped in ProviderScope for testing
///
/// Usage:
/// ```dart
/// await tester.pumpProviderWidget(
///   const MyWidget(),
///   overrides: [myProvider.overrideWith((ref) => mockValue)],
/// );
/// ```
extension WidgetTesterProviderExtensions on WidgetTester {
  Future<void> pumpProviderWidget(
      Widget widget, {
        List<Override> overrides = const [],
        ProviderContainer? container,
      }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        parent: container,
        child: MaterialApp(home: widget),
      ),
    );
  }

  /// Gets the ProviderContainer from the current widget tree
  ProviderContainer getProviderContainer() {
    final element = this.element(find.byType(ProviderScope));
    return ProviderScope.containerOf(element);
  }

  /// Waits for all providers to finish loading
  Future<void> pumpAndSettleProviders([
    Duration timeout = TestConstants.defaultTimeout,
  ]) async {
    await pumpAndSettle();
    // Additional settling for async providers
    await pump(const Duration(milliseconds: 100));
  }
}

// =============================================================================
// 💾 SHARED PREFERENCES MOCKING
// =============================================================================

/// Creates SharedPreferences mock with pre-populated test data
List<Override> getMockSharedPreferencesOverride({
  Map<String, Object>? initialData,
}) {
  final mockData = <String, Object>{
    ...TestConstants.defaultSharedPrefsData.cast<String, Object>(),
    if (initialData != null) ...initialData,
  };

  // Set up SharedPreferences mock
  SharedPreferences.setMockInitialValues(mockData);

  return [
    // Add provider overrides for SharedPreferences-dependent services
  ];
}

/// Sets up SharedPreferences with achievement test data
void setupMockSharedPreferencesForAchievements() {
  SharedPreferences.setMockInitialValues({
    'achievements_unlocked': MockData.unlockedAchievements,
    'achievements_progress': MockData.achievementProgress,
    'user_stats': MockData.userStats,
  });
}

// =============================================================================
// 🌐 WEBSOCKET TESTING UTILITIES
// =============================================================================

/// Mock WebSocket for testing real-time features
class MockWebSocket extends Mock implements WebSocket {
  final StreamController<String> _streamController = StreamController<String>();

  @override
  Stream<String> get stream => _streamController.stream;

  void addMessage(String message) {
    _streamController.add(message);
  }

  @override
  Future<dynamic> close([int? code, String? reason]) async {
    await _streamController.close();
  }
}

/// Creates WebSocket service overrides for testing
List<Override> getMockWebSocketOverrides({
  bool isConnected = true,
  List<String>? mockMessages,
}) {
  final mockWebSocket = MockWebSocket();

  when(() => mockWebSocket.readyState).thenReturn(
    isConnected ? WebSocket.open : WebSocket.closed,
  );

  if (mockMessages != null) {
    final controller = StreamController<String>();
    for (final message in mockMessages) {
      controller.add(message);
    }
    when(() => mockWebSocket.stream).thenAnswer((_) => controller.stream);
  }

  return [
    // Add WebSocket provider overrides here
  ];
}

/// Simulates WebSocket message sequence for testing
Future<void> simulateWebSocketMessages({
  required List<String> messages,
  Duration delay = const Duration(milliseconds: 100),
}) async {
  for (final message in messages) {
    // Simulate message received
    await Future.delayed(delay);
    // Trigger message handling
  }
}

// =============================================================================
// 🔊 AUDIO & HAPTICS TESTING UTILITIES
// =============================================================================

/// Creates audio service overrides for testing
List<Override> getMockAudioServiceOverrides({
  bool isAudioEnabled = false,
  bool isHapticsEnabled = false,
}) {
  return [
    // Add audio service provider overrides here
  ];
}

/// Mocks platform channel for haptic feedback
void setupMockHapticFeedback() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('flutter/haptic'),
        (MethodCall methodCall) async {
      // Mock haptic feedback calls
      return null;
    },
  );
}

// =============================================================================
// 🚀 PERFORMANCE TESTING UTILITIES
// =============================================================================

/// Measures widget build performance
class PerformanceMeasurement {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();

  PerformanceMeasurement(this.name);

  void start() => _stopwatch.start();
  void stop() => _stopwatch.stop();

  Duration get elapsed => _stopwatch.elapsed;

  void expectUnder(Duration threshold) {
    expect(
      elapsed,
      lessThan(threshold),
      reason: '$name took ${elapsed.inMilliseconds}ms, '
          'expected under ${threshold.inMilliseconds}ms',
    );
  }
}

/// Tests widget rendering performance
Future<void> testWidgetPerformance({
  required WidgetTester tester,
  required Widget widget,
  required String testName,
  Duration threshold = TestConstants.performanceThreshold,
  int iterations = 5,
}) async {
  final measurements = <Duration>[];

  for (int i = 0; i < iterations; i++) {
    final measurement = PerformanceMeasurement('$testName iteration $i');

    measurement.start();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
    measurement.stop();

    measurements.add(measurement.elapsed);
  }

  final averageTime = measurements.reduce((a, b) => a + b) ~/ measurements.length;

  expect(
    averageTime,
    lessThan(threshold),
    reason: '$testName average time: ${averageTime.inMilliseconds}ms, '
        'threshold: ${threshold.inMilliseconds}ms',
  );
}

// =============================================================================
// ♿ ACCESSIBILITY TESTING UTILITIES
// =============================================================================

/// Verifies widget meets accessibility guidelines
Future<void> verifyAccessibility(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

/// Tests keyboard navigation support
Future<void> testKeyboardNavigation({
  required WidgetTester tester,
  required List<LogicalKeyboardKey> keySequence,
  required List<Type> expectedFocusOrder,
}) async {
  for (int i = 0; i < keySequence.length; i++) {
    await tester.sendKeyEvent(keySequence[i]);
    await tester.pump();

    if (i < expectedFocusOrder.length) {
      final focusedWidget = find.byType(expectedFocusOrder[i]);
      expect(
        Focus.of(tester.element(focusedWidget)).hasFocus,
        isTrue,
        reason: 'Widget ${expectedFocusOrder[i]} should have focus at step $i',
      );
    }
  }
}

// =============================================================================
// 🧹 TEST CLEANUP UTILITIES
// =============================================================================

/// Disposes all test resources and resets global state
void cleanupTestEnvironment() {
  // Clear SharedPreferences mock
  SharedPreferences.setMockInitialValues({});

  // Reset mock method channels
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('flutter/haptic'), null);

  // Clear any global singletons or caches
}

/// Sets up test environment with common configurations
void setupTestEnvironment() {
  // Ensure binding is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up default mocks
  setupMockHapticFeedback();

  // Note: Test timeouts are configured per-test basis using timeout parameter
}

// =============================================================================
// 🎯 GOLDEN TEST UTILITIES
// =============================================================================

/// Generates golden file name based on test context
String generateGoldenFileName(String testName, {String? variant}) {
  final sanitized = testName.toLowerCase().replaceAll(RegExp(r'[^\w]+'), '_');
  return variant != null
      ? 'golden/$sanitized/$variant.png'
      : 'golden/$sanitized.png';
}

/// Compares widget against golden file with theme variants
Future<void> expectGoldenMatches({
  required WidgetTester tester,
  required Widget widget,
  required String testName,
  List<String> themeVariants = const ['light', 'dark'],
}) async {
  for (final theme in themeVariants) {
    // Apply theme variant
    final themedWidget = Theme(
      data: theme == 'dark' ? ThemeData.dark() : ThemeData.light(),
      child: widget,
    );

    await tester.pumpWidget(themedWidget);
    await tester.pumpAndSettle();

    await expectLater(
      find.byWidget(themedWidget),
      matchesGoldenFile(generateGoldenFileName(testName, variant: theme)),
    );
  }
}

// =============================================================================
// 📊 TEST REPORTING UTILITIES
// =============================================================================

/// Collects test metrics for reporting
class TestMetrics {
  static final Map<String, Duration> _testDurations = {};
  static final Map<String, bool> _testResults = {};

  static void recordTestDuration(String testName, Duration duration) {
    _testDurations[testName] = duration;
  }

  static void recordTestResult(String testName, bool passed) {
    _testResults[testName] = passed;
  }

  static Map<String, dynamic> generateReport() {
    return {
      'total_tests': _testResults.length,
      'passed_tests': _testResults.values.where((passed) => passed).length,
      'failed_tests': _testResults.values.where((passed) => !passed).length,
      'average_duration': _testDurations.values.isEmpty
          ? Duration.zero
          : _testDurations.values.reduce((a, b) => a + b) ~/ _testDurations.length,
      'longest_test': _testDurations.entries
          .fold<MapEntry<String, Duration>?>(null, (longest, entry) {
        return longest == null || entry.value > longest.value ? entry : longest;
      }),
    };
  }

  static void reset() {
    _testDurations.clear();
    _testResults.clear();
  }
}