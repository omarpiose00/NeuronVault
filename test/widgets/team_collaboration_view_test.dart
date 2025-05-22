// test/widgets/team_collaboration_view_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/widgets/team_collaboration_view.dart';

void main() {
  group('TeamCollaborationView Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCollaborationView(
              prompt: 'Test prompt',
              responses: {'gpt': 'Test response'},
              weights: {'gpt': 1.0},
              synthesizedResponse: 'Synthesized response',
              onWeightChanged: (model, weight) {},
              onResetWeights: () {},
              onApplyPreset: (preset) {},
            ),
          ),
        ),
      );

      expect(find.text('Team AI Collaboration'), findsOneWidget);
    });

    testWidgets('should show processing indicator when processing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCollaborationView(
              prompt: 'Test prompt',
              responses: {},
              weights: {},
              synthesizedResponse: '',
              isProcessing: true,
              onWeightChanged: (model, weight) {},
              onResetWeights: () {},
              onApplyPreset: (preset) {},
            ),
          ),
        ),
      );

      expect(find.text('Team working'), findsOneWidget);
    });

    testWidgets('should display prompt when provided', (WidgetTester tester) async {
      const testPrompt = 'What is artificial intelligence?';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCollaborationView(
              prompt: testPrompt,
              responses: {},
              weights: {},
              synthesizedResponse: '',
              onWeightChanged: (model, weight) {},
              onResetWeights: () {},
              onApplyPreset: (preset) {},
            ),
          ),
        ),
      );

      expect(find.text(testPrompt), findsOneWidget);
    });

    testWidgets('should show synthesized response when available', (WidgetTester tester) async {
      const synthesizedResponse = 'This is the synthesized response';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCollaborationView(
              prompt: 'Test',
              responses: {'gpt': 'Response'},
              weights: {'gpt': 1.0},
              synthesizedResponse: synthesizedResponse,
              onWeightChanged: (model, weight) {},
              onResetWeights: () {},
              onApplyPreset: (preset) {},
            ),
          ),
        ),
      );

      expect(find.text(synthesizedResponse), findsOneWidget);
    });

    testWidgets('should toggle weight controller visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCollaborationView(
              prompt: 'Test',
              responses: {'gpt': 'Response'},
              weights: {'gpt': 1.0},
              synthesizedResponse: '',
              onWeightChanged: (model, weight) {},
              onResetWeights: () {},
              onApplyPreset: (preset) {},
            ),
          ),
        ),
      );

      // Find and tap the weights toggle button
      final toggleButton = find.byIcon(Icons.tune_outlined);
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pump();

      // After tapping, the icon should change
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });
  });
}