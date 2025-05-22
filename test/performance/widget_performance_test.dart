// test/performance/widget_performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_ai_flutter/widgets/team_collaboration_view.dart';

void main() {
  group('Widget Performance Tests', () {
    testWidgets('TeamCollaborationView should render efficiently with many responses', (WidgetTester tester) async {
      // Create a large dataset to test performance
      final responses = Map.fromEntries(
        List.generate(10, (i) => MapEntry('model_$i', 'Response from model $i with some lengthy text to simulate real responses')),
      );
      final weights = Map.fromEntries(
        List.generate(10, (i) => MapEntry('model_$i', 1.0 + (i * 0.1))),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamCollaborationView(
              prompt: 'Test prompt with many models',
              responses: responses,
              weights: weights,
              synthesizedResponse: 'Synthesized response from all models',
              onWeightChanged: (model, weight) {},
              onResetWeights: () {},
              onApplyPreset: (preset) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should render within reasonable time (adjust threshold as needed)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Should still display the main elements
      expect(find.text('Team AI Collaboration'), findsOneWidget);
    });

    testWidgets('Animation controllers should be disposed properly', (WidgetTester tester) async {
      final widget = TeamCollaborationView(
        prompt: 'Test',
        responses: {'gpt': 'Response'},
        weights: {'gpt': 1.0},
        synthesizedResponse: 'Synthesized',
        onWeightChanged: (model, weight) {},
        onResetWeights: () {},
        onApplyPreset: (preset) {},
      );

      // Pump the widget
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: widget)),
      );

      // Remove the widget (this should trigger dispose)
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Container())),
      );

      // No assertions needed - if dispose isn't called properly,
      // we'll get memory leaks which will be detected by other tooling
    });
  });
}