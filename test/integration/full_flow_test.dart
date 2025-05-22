// test/integration/full_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:multi_ai_flutter/main.dart';
import 'package:multi_ai_flutter/providers/app_state_provider.dart';
import 'package:multi_ai_flutter/providers/theme_provider.dart';
import 'package:multi_ai_flutter/services/api_key_manager.dart';

void main() {
  group('Full App Integration Tests', () {
    testWidgets('should navigate through app flow correctly', (WidgetTester tester) async {
      // Pump the entire app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppStateProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider(false)),
            ChangeNotifierProvider(create: (_) => ApiKeyManager()),
          ],
          child: MultiAiTeamApp(isFirstRun: false),
        ),
      );

      // Should start with splash screen
      expect(find.text('Team AI'), findsOneWidget);

      // Wait for splash screen animation to complete
      await tester.pumpAndSettle(Duration(seconds: 4));

      // Should navigate to main chat screen
      expect(find.text('Inizia una conversazione con il team AI'), findsOneWidget);
    });

    testWidgets('should handle first run setup correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppStateProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider(false)),
            ChangeNotifierProvider(create: (_) => ApiKeyManager()),
          ],
          child: MultiAiTeamApp(isFirstRun: true),
        ),
      );

      // Should show API configuration screen for first run
      expect(find.text('Multi-AI Team'), findsOneWidget);
      expect(find.text('Configura le chiavi API'), findsOneWidget);
    });

    testWidgets('should handle theme switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppStateProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider(false)),
            ChangeNotifierProvider(create: (_) => ApiKeyManager()),
          ],
          child: MultiAiTeamApp(isFirstRun: false),
        ),
      );

      await tester.pumpAndSettle(Duration(seconds: 4));

      // The app should be using light theme initially
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.brightness, equals(Brightness.light));
    });
  });
}