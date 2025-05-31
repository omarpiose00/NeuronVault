import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:logger/logger.dart';
import '../../../../lib/core/services/mini_llm_analyzer_service.dart';
import '../../../../lib/core/services/ai_service.dart';
import '../../../../lib/core/services/config_service.dart';
import '../../../../lib/core/services/storage_service.dart';
import '../../../unit/helpers/test_helpers.dart';
import '../../../unit/mocks/mock_services.dart';

void main() {
  group('🔍 MiniLLMAnalyzerService Tests', () {
    late MiniLLMAnalyzerService analyzerService;
    late MockAIService mockAIService;
    late MockConfigService mockConfigService;
    late MockStorageService mockStorageService;
    late Logger mockLogger;

    setUp(() {
      mockAIService = MockAIService();
      mockConfigService = MockConfigService();
      mockStorageService = MockStorageService();
      mockLogger = TestHelpers.createTestLogger();

      analyzerService = MiniLLMAnalyzerService(
        aiService: mockAIService,
        configService: mockConfigService,
        storageService: mockStorageService,
        logger: mockLogger,
      );
    });

    group('🚀 Initialization Tests', () {
      test('should initialize service correctly', () {
        expect(analyzerService, isNotNull);
        expect(analyzerService, isA<MiniLLMAnalyzerService>());
      });
    });

    group('🔍 Prompt Analysis Tests', () {
      test('should analyze simple conversational prompt', () async {
        const prompt = 'Hello, how are you?';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.promptText, equals(prompt));
        expect(analysis.primaryCategory, equals(PromptCategory.conversational));
        expect(analysis.complexity, equals(PromptComplexity.simple));
        expect(analysis.confidenceScore, greaterThan(0.5));
        expect(analysis.analysisTime.inMilliseconds, lessThan(500));
      });

      test('should analyze coding prompt correctly', () async {
        const prompt = 'Write a Python function to sort a list of integers using bubble sort algorithm';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.primaryCategory, equals(PromptCategory.coding));
        expect(analysis.complexity, isIn([PromptComplexity.moderate, PromptComplexity.complex]));
        expect(analysis.modelRecommendations.containsKey('deepseek'), isTrue);
        expect(analysis.modelRecommendations['deepseek'], greaterThan(0.8));
      });

      test('should analyze creative prompt correctly', () async {
        const prompt = 'Write a creative story about a magical forest with talking animals';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.primaryCategory, equals(PromptCategory.creative));
        expect(analysis.modelRecommendations.containsKey('gpt'), isTrue);
        expect(analysis.modelRecommendations['gpt'], greaterThan(0.8));
      });

      test('should analyze analytical prompt correctly', () async {
        const prompt = 'Analyze the economic impact of renewable energy adoption in developing countries';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.primaryCategory, equals(PromptCategory.analytical));
        expect(analysis.complexity, isIn([PromptComplexity.complex, PromptComplexity.expert]));
        expect(analysis.modelRecommendations.containsKey('claude'), isTrue);
        expect(analysis.modelRecommendations['claude'], greaterThan(0.8));
      });

      test('should handle complex multi-aspect prompts', () async {
        const prompt = '''Analyze the current trends in artificial intelligence, 
        write a creative story about AI in the future, 
        and provide Python code to demonstrate machine learning concepts.''';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.complexity, equals(PromptComplexity.expert));
        expect(analysis.secondaryCategories.length, greaterThan(1));
        expect(analysis.recommendedStrategy, isIn(['adaptive', 'weighted']));
      });
    });

    group('🎯 Model Recommendation Tests', () {
      test('should recommend appropriate models for coding tasks', () async {
        const prompt = 'Debug this JavaScript function and optimize it for performance';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.modelRecommendations['deepseek'], greaterThan(0.8));
        expect(analysis.modelRecommendations['claude'], greaterThan(0.7));
      });

      test('should recommend appropriate models for creative tasks', () async {
        const prompt = 'Create an imaginative poem about space exploration';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.modelRecommendations['gpt'], greaterThan(0.8));
        expect(analysis.modelRecommendations['gemini'], greaterThan(0.7));
      });

      test('should provide balanced recommendations for general queries', () async {
        const prompt = 'Explain the concept of machine learning';

        final analysis = await analyzerService.analyzePrompt(prompt);

        final recommendations = analysis.modelRecommendations;
        final averageScore = recommendations.values.reduce((a, b) => a + b) / recommendations.length;

        expect(averageScore, greaterThan(0.6));
        expect(recommendations.length, greaterThanOrEqualTo(4));
      });
    });

    group('🎛️ Strategy Selection Tests', () {
      test('should recommend consensus for simple queries', () async {
        const prompt = 'What is the capital of France?';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.recommendedStrategy, equals('consensus'));
      });

      test('should recommend parallel for moderate complexity', () async {
        const prompt = 'Explain how blockchain technology works';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.recommendedStrategy, equals('parallel'));
      });

      test('should recommend weighted for complex queries', () async {
        const prompt = '''Provide a comprehensive analysis of climate change impacts 
        on global economics, including statistical models and policy recommendations''';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.recommendedStrategy, equals('weighted'));
      });

      test('should recommend adaptive for expert queries', () async {
        const prompt = '''Develop a complete machine learning pipeline for 
        predicting stock market trends, including data preprocessing, 
        feature engineering, model selection, and deployment strategies''';

        final analysis = await analyzerService.analyzePrompt(prompt);

        expect(analysis.recommendedStrategy, equals('adaptive'));
      });
    });

    group('📊 Performance Tests', () {
      test('should complete analysis within time target', () async {
        const prompt = 'Test prompt for performance measurement';

        final stopwatch = Stopwatch()..start();
        final analysis = await analyzerService.analyzePrompt(prompt);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        expect(analysis.analysisTime.inMilliseconds, lessThan(300));
      });

      test('should maintain performance under load', () async {
        final futures = <Future<PromptAnalysis>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(analyzerService.analyzePrompt('Test prompt $i'));
        }

        final stopwatch = Stopwatch()..start();
        final results = await Future.wait(futures);
        stopwatch.stop();

        expect(results.length, equals(10));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));

        for (final result in results) {
          expect(result.analysisTime.inMilliseconds, lessThan(300));
        }
      });
    });

    group('📊 Analytics and History Tests', () {
      test('should track analysis statistics', () async {
        await analyzerService.analyzePrompt('Test prompt 1');
        await analyzerService.analyzePrompt('Write a function');
        await analyzerService.analyzePrompt('Create a story');

        final stats = analyzerService.getAnalysisStatistics();

        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('total_analyses'), isTrue);
        expect(stats.containsKey('categories'), isTrue);
        expect(stats['total_analyses'], equals(3));
      });

      test('should provide recent analyses', () async {
        await analyzerService.analyzePrompt('Test prompt 1');
        await analyzerService.analyzePrompt('Test prompt 2');

        final recent = analyzerService.getRecentAnalyses(limit: 5);

        expect(recent.length, equals(2));
        expect(recent.first.promptText, equals('Test prompt 2')); // Most recent first
      });

      test('should clear analysis history', () async {
        await analyzerService.analyzePrompt('Test prompt');

        analyzerService.clearAnalysisHistory();

        final stats = analyzerService.getAnalysisStatistics();
        expect(stats['total_analyses'], equals(0));

        final recent = analyzerService.getRecentAnalyses();
        expect(recent, isEmpty);
      });
    });

    group('🔧 Error Handling Tests', () {
      test('should handle empty prompts gracefully', () async {
        final analysis = await analyzerService.analyzePrompt('');

        expect(analysis, isA<PromptAnalysis>());
        expect(analysis.primaryCategory, equals(PromptCategory.conversational));
        expect(analysis.complexity, equals(PromptComplexity.simple));
      });

      test('should handle very long prompts', () async {
        final longPrompt = 'test ' * 1000; // 5000 characters

        final analysis = await analyzerService.analyzePrompt(longPrompt);

        expect(analysis, isA<PromptAnalysis>());
        expect(analysis.complexity, isIn([PromptComplexity.complex, PromptComplexity.expert]));
      });

      test('should provide fallback analysis on errors', () async {
        // This test simulates internal errors by testing edge cases
        final problematicPrompt = '!@#\$%^&*()_+{}|:"<>?[]\\;\',./' * 10;

        final analysis = await analyzerService.analyzePrompt(problematicPrompt);

        expect(analysis, isA<PromptAnalysis>());
        expect(analysis.promptText, equals(problematicPrompt));
        expect(analysis.modelRecommendations, isNotEmpty);
      });
    });

    group('🧹 Memory Management Tests', () {
      test('should limit analysis history size', () async {
        // Generate many analyses
        for (int i = 0; i < 60; i++) {
          await analyzerService.analyzePrompt('Test prompt $i');
        }

        final recent = analyzerService.getRecentAnalyses();
        expect(recent.length, lessThanOrEqualTo(50));
      });
    });
  });
}