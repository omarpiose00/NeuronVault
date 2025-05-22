// test/services/api_key_manager_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/services/api_key_manager.dart';

void main() {
  group('ApiKeyManager Tests', () {
    late ApiKeyManager apiKeyManager;

    setUp(() {
      apiKeyManager = ApiKeyManager();
    });

    group('Key Management', () {
      test('should store and retrieve API keys', () async {
        const testKey = 'test-api-key-123';
        await apiKeyManager.setKey('openai', testKey);

        expect(apiKeyManager.getKey('openai'), equals(testKey));
      });

      test('should handle non-existent keys', () {
        expect(apiKeyManager.getKey('nonexistent'), isNull);
      });

      test('should remove keys correctly', () async {
        await apiKeyManager.setKey('test-provider', 'test-key');
        await apiKeyManager.removeKey('test-provider');

        expect(apiKeyManager.getKey('test-provider'), isNull);
      });

      test('should validate supported providers', () {
        expect(
              () async => await apiKeyManager.setKey('invalid-provider', 'key'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Provider State Management', () {
      test('should enable and disable providers', () async {
        await apiKeyManager.setEnabled('openai', true);
        expect(apiKeyManager.isEnabled('openai'), isTrue);

        await apiKeyManager.setEnabled('openai', false);
        expect(apiKeyManager.isEnabled('openai'), isFalse);
      });

      test('should list enabled providers', () async {
        await apiKeyManager.setEnabled('openai', true);
        await apiKeyManager.setEnabled('anthropic', true);
        await apiKeyManager.setEnabled('deepseek', false);

        final enabledProviders = apiKeyManager.enabledProviders;
        expect(enabledProviders, contains('openai'));
        expect(enabledProviders, contains('anthropic'));
        expect(enabledProviders, isNot(contains('deepseek')));
      });
    });

    group('Additional Configurations', () {
      test('should store and retrieve additional configs', () async {
        final testConfig = {
          'executable_path': '/usr/local/bin/llama',
          'model_path': '/models/llama-7b.gguf',
          'temperature': 0.7,
        };

        await apiKeyManager.setAdditionalConfig('llama', testConfig);
        final retrievedConfig = apiKeyManager.getAdditionalConfig('llama');

        expect(retrievedConfig, equals(testConfig));
      });
    });

    group('Backend Configuration', () {
      test('should generate backend config correctly', () async {
        await apiKeyManager.setKey('openai', 'openai-key');
        await apiKeyManager.setKey('anthropic', 'anthropic-key');
        await apiKeyManager.setEnabled('openai', true);
        await apiKeyManager.setEnabled('anthropic', true);

        final config = apiKeyManager.getBackendConfig();

        expect(config['OPENAI_API_KEY'], equals('openai-key'));
        expect(config['ANTHROPIC_API_KEY'], equals('anthropic-key'));
      });
    });

    group('First Run Detection', () {
      test('should detect first run correctly', () async {
        final isFirstRun = await apiKeyManager.isFirstRun();
        expect(isFirstRun, isA<bool>());
      });
    });
  });
}