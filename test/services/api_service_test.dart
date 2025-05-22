// test/services/api_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/services/api_service.dart';
import 'package:multi_ai_flutter/models/conversation_mode.dart';

void main() {
  group('ApiService Tests', () {
    setUp(() {
      // Reset to demo mode for testing
      ApiService.useMockData = true;
    });

    group('Mock Data Mode', () {
      test('should return mock response in demo mode', () async {
        final response = await ApiService.askAgents(
          'Test prompt',
          conversationId: 'test-conv',
          mode: ConversationMode.chat,
        );

        expect(response, isA<AiServiceResponse>());
        expect(response.conversation, isNotEmpty);
        expect(response.responses, isNotEmpty);
        expect(response.synthesizedResponse, isNotEmpty);
      });

      test('should handle different conversation modes', () async {
        for (final mode in ConversationMode.values) {
          final response = await ApiService.askAgents(
            'Test prompt for ${mode.name}',
            mode: mode,
          );

          expect(response.conversation, isNotEmpty);
          expect(response.synthesizedResponse, contains(mode.name));
        }
      });

      test('should respect custom weights', () async {
        final customWeights = {
          'gpt': 2.0,
          'claude': 0.5,
          'deepseek': 1.0,
        };

        final response = await ApiService.askAgents(
          'Test with custom weights',
          weights: customWeights,
        );

        expect(response.weights, equals(customWeights));
      });
    });

    group('Real API Mode', () {
      setUp(() {
        ApiService.useMockData = false;
      });

      test('should handle connection errors gracefully', () async {
        expect(
              () async => await ApiService.askAgents('Test prompt'),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle timeout errors', () async {
        expect(
              () async => await ApiService.askAgents(
            'Test prompt',
            options: {'timeout': 1}, // Very short timeout
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('AiConversationMessage', () {
      test('should create from JSON correctly', () {
        final json = {
          'agent': 'gpt',
          'message': 'Test message',
          'timestamp': '2023-01-01T00:00:00.000Z',
          'mediaUrl': 'test-url',
          'mediaType': 'image/jpeg',
          'metadata': {'key': 'value'},
        };

        final message = AiConversationMessage.fromJson(json);

        expect(message.agent, equals('gpt'));
        expect(message.message, equals('Test message'));
        expect(message.mediaUrl, equals('test-url'));
        expect(message.mediaType, equals('image/jpeg'));
        expect(message.metadata, equals({'key': 'value'}));
      });

      test('should convert to correct AiAgent', () {
        final gptMessage = AiConversationMessage(
          agent: 'openai',
          message: 'Test',
        );
        expect(gptMessage.toAiAgent(), equals(AiAgent.gpt));

        final claudeMessage = AiConversationMessage(
          agent: 'anthropic',
          message: 'Test',
        );
        expect(claudeMessage.toAiAgent(), equals(AiAgent.claude));

        final unknownMessage = AiConversationMessage(
          agent: 'unknown',
          message: 'Test',
        );
        expect(unknownMessage.toAiAgent(), isNull);
      });

      test('should format error messages correctly', () {
        final errorMessage = AiConversationMessage(
          agent: 'system',
          message: 'Errore: OpenAI API quota exceeded',
        );

        final formatted = errorMessage.getFormattedMessage();
        expect(formatted, contains('Limite di utilizzo OpenAI superato'));
      });
    });

    group('AiServiceResponse', () {
      test('should create from JSON correctly', () {
        final json = {
          'conversation': [
            {
              'agent': 'user',
              'message': 'Hello',
              'timestamp': '2023-01-01T00:00:00.000Z',
            },
            {
              'agent': 'gpt',
              'message': 'Hi there!',
              'timestamp': '2023-01-01T00:00:01.000Z',
            },
          ],
          'responses': {
            'gpt': 'Hi there!',
            'claude': 'Hello!',
          },
          'weights': {
            'gpt': 1.0,
            'claude': 1.0,
          },
          'synthesized_response': 'Hello! How can I help you?',
          'metadata': {'processingTime': 1.5},
        };

        final response = AiServiceResponse.fromJson(json);

        expect(response.conversation, hasLength(2));
        expect(response.responses, hasLength(2));
        expect(response.weights, hasLength(2));
        expect(response.synthesizedResponse, isNotEmpty);
        expect(response.metadata, isNotNull);
      });

      test('should convert to JSON correctly', () {
        final response = AiServiceResponse(
          conversation: [
            AiConversationMessage(agent: 'user', message: 'Test'),
          ],
          responses: {'gpt': 'Response'},
          weights: {'gpt': 1.0},
          synthesizedResponse: 'Synthesized',
          metadata: {'test': true},
        );

        final json = response.toJson();

        expect(json['conversation'], hasLength(1));
        expect(json['responses'], equals({'gpt': 'Response'}));
        expect(json['weights'], equals({'gpt': 1.0}));
        expect(json['synthesized_response'], equals('Synthesized'));
        expect(json['metadata'], equals({'test': true}));
      });
    });
  });
}