import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:neuronvault/core/services/analytics_service.dart';
import 'package:neuronvault/core/services/storage_service.dart';
import 'package:neuronvault/core/state/state_models.dart';
import 'package:logger/logger.dart';

import '../../../unit/helpers/test_helpers.dart';
import '../../../unit/mocks/mock_services.dart';

void main() {
  group('📊 AnalyticsService Tests', () {
    late AnalyticsService analyticsService;
    late MockStorageService mockStorage;
    late TestLogger testLogger;

    setUp(() {
      mockStorage = MockStorageService();
      testLogger = TestHelpers.createTestLogger(level: Level.debug);

      analyticsService = AnalyticsService(
        storageService: mockStorage,
        logger: testLogger,
      );
    });

    tearDown(() {
      analyticsService.dispose();
    });

    group('Event Tracking', () {
      test('Should track events correctly', () {
        const eventName = 'test_event';
        analyticsService.trackEvent(eventName);

        // Verify through logger instead of report
        expect(testLogger.hasLoggedMessage('📊 Tracking event: $eventName'), true);
      });

      test('Should track event with properties', () {
        const eventName = 'test_event';
        final properties = {'key': 'value'};

        analyticsService.trackEvent(eventName, properties: properties);

        expect(testLogger.hasLoggedMessage('📊 Event properties: $properties'), true);
      });
    });

    group('Performance Tracking', () {
      test('Should track response time', () {
        analyticsService.trackPerformance('response_time', 150.0);

        // Verify through logger instead of report
        expect(testLogger.hasLoggedMessage('📈 Tracking performance: response_time = 150.0'), true);
      });

      test('Should track memory usage', () {
        analyticsService.trackPerformance('memory_usage', 45.3);

        // Verify through logger instead of report
        expect(testLogger.hasLoggedMessage('📈 Tracking performance: memory_usage = 45.3'), true);
      });
    });

    group('Error Tracking', () {
      test('Should track errors', () {
        const errorType = 'network_error';
        analyticsService.trackError(errorType);

        // Verify through logger instead of report
        expect(testLogger.hasLoggedMessage('❌ Tracking error: $errorType'), true);
      });
    });

    group('Model Usage Tracking', () {
      test('Should track model usage', () {
        analyticsService.trackModelUsage(
          AIModel.gpt,
          tokens: 100,
          responseTime: const Duration(milliseconds: 250),
          success: true,
        );

        // Verify through logger
        expect(testLogger.hasLoggedMessage('📊 Tracking event: model_usage'), true);
        expect(testLogger.hasLoggedMessage('📊 Event properties: {model: GPT, tokens: 100, response_time_ms: 250, success: true}'), true);
      });
    });

    group('Session Management', () {
      test('Should start and end sessions', () {
        analyticsService.endSession();

        expect(testLogger.hasLoggedMessage('🏁 Analytics session ended'), true);
        expect(testLogger.hasLoggedMessage('🚀 Analytics session started'), true);
      });
    });

    group('Analytics Reports', () {
      test('Should generate valid reports', () {
        // Populate with test data
        analyticsService.trackEvent('test_event');
        analyticsService.trackPerformance('response_time', 100.0);

        final report = analyticsService.getAnalyticsReport();

        expect(report, isA<Map<String, dynamic>>());
        expect(report['overview'], isNotNull);
        expect(report['performance'], isNotNull);
      });
    });

    group('Extension Methods', () {
      test('Should track user actions', () {
        analyticsService.trackUserAction('login');
        expect(testLogger.hasLoggedMessage('📊 Tracking event: user_login'), true);
      });

      test('Should track UI interactions', () {
        analyticsService.trackUIInteraction('button_click');
        expect(testLogger.hasLoggedMessage('📊 Tracking event: ui_button_click'), true);
      });
    });
  });
}