// lib/models/ai_agent.dart
import 'package:flutter/material.dart';

enum AiAgent { claude, gpt, deepseek }

String agentName(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return 'Claude';
    case AiAgent.gpt:
      return 'GPT-4';
    case AiAgent.deepseek:
      return 'DeepSeek';
  }
}

Widget agentIcon(AiAgent agent, {double size = 40}) {
  switch (agent) {
    case AiAgent.claude:
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB17ACC), Color(0xFF8241BD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB17ACC).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: Text(
            '🧠',
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      );
    case AiAgent.gpt:
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF74D49A), Color(0xFF129D55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF74D49A).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: Text(
            '🤖',
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      );
    case AiAgent.deepseek:
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0D97C), Color(0xFFFFB627)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF0D97C).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: Center(
          child: Text(
            '💻',
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      );
  }
}

Color agentColor(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return const Color(0xFFE0BBE4); // Purple for Claude
    case AiAgent.gpt:
      return const Color(0xFFB2DFDB); // Teal for GPT
    case AiAgent.deepseek:
      return const Color(0xFFFFF59D); // Yellow for DeepSeek
  }
}

Color agentDarkColor(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return const Color(0xFF9C64A6); // Darker Purple for Claude
    case AiAgent.gpt:
      return const Color(0xFF00695C); // Darker Teal for GPT
    case AiAgent.deepseek:
      return const Color(0xFFFFEB3B); // Darker Yellow for DeepSeek
  }
}