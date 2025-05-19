import 'package:flutter/material.dart';
import 'screens/ai_chat_screen.dart';

void main() {
  runApp(const MultiAiTeamApp());
}

class MultiAiTeamApp extends StatelessWidget {
  const MultiAiTeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-AI Team',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AiChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
