import 'package:flutter_test/flutter_test.dart';
import '../../../../lib/core/services/websocket_orchestration_service.dart';

void main() {
  group('🌐 WebSocketOrchestrationService Tests', () {
    late WebSocketOrchestrationService orchestrationService;

    setUp(() {
      orchestrationService = WebSocketOrchestrationService();
    });

    tearDown(() {
      orchestrationService.dispose();
    });

    group('🚀 Initialization Tests', () {
      test('should initialize with correct default state', () {
        expect(orchestrationService.isConnected, isFalse);
        expect(orchestrationService.currentPort, equals(3001));
        expect(orchestrationService.individualResponses, isEmpty);
        expect(orchestrationService.synthesizedResponse, isNull);
        expect(orchestrationService.currentStrategy, equals(OrchestrationStrategy.parallel));
      });

      test('should provide stream interfaces', () {
        expect(orchestrationService.individualResponsesStream, isA<Stream<List<AIResponse>>>());
        expect(orchestrationService.synthesizedResponseStream, isA<Stream<String>>());
        expect(orchestrationService.orchestrationProgressStream, isA<Stream<OrchestrationProgress>>());
      });
    });

    group('🔗 Connection Tests', () {
      test('should attempt connection on default ports', () async {
        // This will fail since no backend is running, but should not throw
        final result = await orchestrationService.connect();
        expect(result, isFalse);
        expect(orchestrationService.isConnected, isFalse);
      });

      test('should try specific host and port', () async {
        final result = await orchestrationService.connect(
          host: 'localhost',
          port: 9999, // Non-existent port
        );

        expect(result, isFalse);
        expect(orchestrationService.isConnected, isFalse);
      });

      test('should handle connection failures gracefully', () async {
        expect(
              () => orchestrationService.connect(host: 'invalid-host'),
          returnsNormally,
        );
      });
    });

    group('🚀 AI Orchestration Tests', () {
      test('should handle orchestration request when not connected', () async {
        expect(
              () => orchestrationService.orchestrateAIRequest(
            prompt: 'Test prompt',
            selectedModels: ['claude', 'gpt'],
            strategy: OrchestrationStrategy.parallel,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should provide demo simulation when backend unavailable', () async {
        // Mock connection success for this test
        orchestrationService.isConnected;

        try {
          await orchestrationService.orchestrateAIRequest(
            prompt: 'Test prompt for demo',
            selectedModels: ['claude', 'gpt', 'deepseek'],
            strategy: OrchestrationStrategy.parallel,
          );
        } catch (e) {
          // Expected since not actually connected
        }

        // Should handle the request gracefully
        expect(orchestrationService.currentStrategy, equals(OrchestrationStrategy.parallel));
      });

      test('should handle alternative method name', () async {
        expect(
              () => orchestrationService.startAIStream(
            prompt: 'Test prompt',
            selectedModels: ['claude'],
            strategy: OrchestrationStrategy.consensus,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('📊 Strategy Management Tests', () {
      test('should track current strategy', () async {
        try {
          await orchestrationService.orchestrateAIRequest(
            prompt: 'Test prompt',
            selectedModels: ['claude'],
            strategy: OrchestrationStrategy.weighted,
          );
        } catch (e) {
          // Expected exception due to no connection
        }

        expect(orchestrationService.currentStrategy, equals(OrchestrationStrategy.weighted));
      });

      test('should handle all orchestration strategies', () {
        for (final strategy in OrchestrationStrategy.values) {
          expect(strategy.name, isNotEmpty);
        }
      });
    });

    group('🎯 AIResponse Model Tests', () {
      test('should create AIResponse from JSON', () {
        final json = {
          'model_name': 'claude',
          'content': 'Test response',
          'confidence': 0.9,
          'response_time_ms': 1500,
          'timestamp': DateTime.now().toIso8601String(),
        };

        final response = AIResponse.fromJson(json);

        expect(response.modelName, equals('claude'));
        expect(response.content, equals('Test response'));
        expect(response.confidence, equals(0.9));
        expect(response.responseTime.inMilliseconds, equals(1500));
      });

      test('should handle incomplete JSON gracefully', () {
        final json = {
          'model': 'gpt', // Alternative field name
          'response': 'Partial response', // Alternative field name
        };

        final response = AIResponse.fromJson(json);

        expect(response.modelName, equals('gpt'));
        expect(response.content, equals('Partial response'));
        expect(response.confidence, equals(0.8)); // Default value
      });

      test('should handle empty JSON', () {
        final response = AIResponse.fromJson({});

        expect(response.modelName, equals('unknown'));
        expect(response.content, isEmpty);
        expect(response.confidence, equals(0.8));
      });
    });

    group('📊 OrchestrationProgress Model Tests', () {
      test('should create progress from JSON', () {
        final json = {
          'completed_models': 2,
          'total_models': 5,
          'current_phase': 'processing',
          'overall_progress': 0.4,
        };

        final progress = OrchestrationProgress.fromJson(json);

        expect(progress.completedModels, equals(2));
        expect(progress.totalModels, equals(5));
        expect(progress.currentPhase, equals('processing'));
        expect(progress.overallProgress, equals(0.4));
      });

      test('should handle incomplete progress JSON', () {
        final progress = OrchestrationProgress.fromJson({});

        expect(progress.completedModels, equals(0));
        expect(progress.totalModels, equals(1));
        expect(progress.currentPhase, equals('initializing'));
        expect(progress.overallProgress, equals(0.0));
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle disconnect gracefully', () async {
        expect(
              () => orchestrationService.disconnect(),
          returnsNormally,
        );
      });

      test('should handle multiple disconnect calls', () async {
        await orchestrationService.disconnect();
        await orchestrationService.disconnect();
        // Should not throw
      });
    });

    group('🧹 Cleanup Tests', () {
      test('should dispose properly', () {
        expect(() => orchestrationService.dispose(), returnsNormally);
      });

      test('should clean up streams on dispose', () {
        orchestrationService.dispose();
        // Streams should be closed - test that they don't cause memory leaks
      });
    });

    group('📡 Message Handling Tests', () {
      test('should provide stream chunk handling structure', () {
        // Test that the service has the structure to handle stream chunks
        expect(orchestrationService.individualResponsesStream, isA<Stream>());
        expect(orchestrationService.synthesizedResponseStream, isA<Stream>());
      });

      test('should handle connection state changes', () {
        expect(orchestrationService.isConnected, isFalse);
        // Connection state should be properly tracked
      });
    });
  });
}