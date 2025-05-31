import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart';
import 'package:neuronvault/core/services/ai_service.dart';
import 'package:neuronvault/core/services/config_service.dart'; // ADDED
import 'package:neuronvault/core/services/storage_service.dart'; // ADDED
import 'package:neuronvault/core/state/state_models.dart';
import '../../../unit/helpers/test_helpers.dart';
import '../../../unit/mocks/mock_services.dart';

void main() {
  group('🤖 AIService Tests', () {
    late AIService aiService;
    late MockConfigService mockConfigService;
    late MockStorageService mockStorageService;
    late Logger mockLogger;

    setUp(() {
      mockConfigService = MockConfigService();
      mockStorageService = MockStorageService();
      mockLogger = TestHelpers.createTestLogger();

      aiService = AIService(
        configService: mockConfigService,
        storageService: mockStorageService,
        logger: mockLogger,
      );
    });

    tearDown(() {
      aiService.dispose();
    });

    group('🔧 Initialization Tests', () {
      test('should initialize HTTP client correctly', () {
        expect(aiService, isNotNull);
        // HTTP client should be initialized internally
      });

      test('should handle dependency injection', () {
        expect(aiService, isA<AIService>());
      });
    });

    group('🧪 Connection Testing', () {
      test('should return false for empty API key', () async {
        final config = ModelConfig(
          name: 'claude-test', // CORREZIONE: Aggiunto parametro name richiesto
          apiKey: '',
          baseUrl: 'https://api.anthropic.com',
          maxTokens: 1000,
          temperature: 0.7,
        );

        final result = await aiService.testConnection(AIModel.claude, config);
        expect(result, isFalse);
      });

      test('should handle network errors gracefully', () async {
        final config = ModelConfig(
          name: 'claude-invalid', // CORREZIONE: Aggiunto parametro name richiesto
          apiKey: 'invalid_key',
          baseUrl: 'https://invalid-url.com',
          maxTokens: 1000,
          temperature: 0.7,
        );

        final result = await aiService.testConnection(AIModel.claude, config);
        expect(result, isFalse);
      });
    });

    group('📡 Streaming Tests', () {
      test('should create streaming response', () {
        const prompt = 'Test prompt';
        const requestId = 'test_request_1';

        final stream = aiService.streamResponse(prompt, requestId);
        expect(stream, isA<Stream<String>>());
      });

      test('should handle stop generation', () async {
        const requestId = 'test_request_1';

        expect(
              () => aiService.stopGeneration(requestId),
          returnsNormally,
        );
      });
    });

    group('📊 Performance Tracking Tests', () {
      test('should track model statistics', () {
        final stats = aiService.getModelStatistics(AIModel.claude);

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('model'), isTrue);
        expect(stats.containsKey('request_count'), isTrue);
        expect(stats.containsKey('error_count'), isTrue);
        expect(stats.containsKey('success_rate'), isTrue);
      });

      test('should get all statistics', () {
        final allStats = aiService.getAllStatistics();

        expect(allStats, isA<Map<String, dynamic>>());
        for (final model in AIModel.values) {
          expect(allStats.containsKey(model.name), isTrue);
        }
      });

      test('should reset statistics', () {
        aiService.resetStatistics(AIModel.claude);

        final stats = aiService.getModelStatistics(AIModel.claude);
        expect(stats['request_count'], equals(0));
        expect(stats['error_count'], equals(0));
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle invalid model configuration', () async {
        final config = ModelConfig(
          name: 'claude-invalid-config', // CORREZIONE: Aggiunto parametro name richiesto
          apiKey: '',
          baseUrl: '',
          maxTokens: -1,
          temperature: 2.0,
        );

        expect(
              () => aiService.testConnection(AIModel.claude, config),
          returnsNormally,
        );
      });
    });

    group('🧹 Cleanup Tests', () {
      test('should dispose properly', () async {
        expect(() => aiService.dispose(), returnsNormally);
      });
    });
  });
}