// test/widgets/synthesis_visualizer_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/widgets/synthesis_visualizer.dart';

void main() {
  group('SynthesisVisualizer Tests', () {
    testWidgets('should render with input data', (WidgetTester tester) async {
      final inputTexts = {
        'gpt': 'GPT response text',
        'claude': 'Claude response text',
      };
      final weights = {
        'gpt': 1.0,
        'claude': 0.8,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SynthesisVisualizer(
              inputTexts: inputTexts,
              weights: weights,
              outputText: 'Synthesized output',
            ),
          ),
        ),
      );

      expect(find.text('Processo di Sintesi'), findsOneWidget);
      expect(find.text('Synthesized output'), findsOneWidget);
    });

    testWidgets('should show processing indicator when processing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SynthesisVisualizer(
              inputTexts: {'gpt': 'Test'},
              weights: {'gpt': 1.0},
              outputText: '',
              isProcessing: true,
            ),
          ),
        ),
      );

      expect(find.text('Sintetizzando...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display weight chart with correct proportions', (WidgetTester tester) async {
      final weights = {
        'gpt': 2.0,
        'claude': 1.0,
        'deepseek': 0.5,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SynthesisVisualizer(
              inputTexts: {
                'gpt': 'GPT response',
                'claude': 'Claude response',
                'deepseek': 'DeepSeek response',
              },
              weights: weights,
              outputText: 'Output',
            ),
          ),
        ),
      );

      // The widget should display all three models
      expect(find.text('GPT'), findsOneWidget);
      expect(find.text('Claude'), findsOneWidget);
      expect(find.text('DS'), findsOneWidget); // DeepSeek abbreviated
    });
  });
}

// test/widgets/multimodal_message_bubble_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/widgets/messaging/multimodal_message_bubble.dart';
import 'package:multi_ai_flutter/models/ai_agent.dart';

void main() {
  group('MultimodalMessageBubble Tests', () {
    testWidgets('should render user message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultimodalMessageBubble(
              agent: null, // User message
              text: 'Hello, this is a user message',
            ),
          ),
        ),
      );

      expect(find.text('Hello, this is a user message'), findsOneWidget);
    });

    testWidgets('should render AI agent message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultimodalMessageBubble(
              agent: AiAgent.gpt,
              text: 'Hello, this is a GPT response',
            ),
          ),
        ),
      );

      expect(find.text('GPT-4'), findsOneWidget);
      expect(find.text('Hello, this is a GPT response'), findsOneWidget);
    });

    testWidgets('should show thinking indicator when thinking', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultimodalMessageBubble(
              agent: AiAgent.claude,
              text: '',
              isThinking: true,
            ),
          ),
        ),
      );

      expect(find.text('Sta pensando'), findsOneWidget);
    });

    testWidgets('should format timestamps correctly', (WidgetTester tester) async {
      final recentTimestamp = DateTime.now().subtract(Duration(minutes: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultimodalMessageBubble(
              agent: AiAgent.gpt,
              text: 'Test message',
              timestamp: recentTimestamp,
            ),
          ),
        ),
      );

      expect(find.text('5 min fa'), findsOneWidget);
    });

    testWidgets('should handle error messages appropriately', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultimodalMessageBubble(
              agent: null,
              text: 'Errore: Limite di utilizzo API superato',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}