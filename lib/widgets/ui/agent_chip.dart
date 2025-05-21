// lib/widgets/agent_chip.dart
import 'package:flutter/material.dart';
import '../../models/ai_agent.dart';

class AgentChip extends StatelessWidget {
  final AiAgent agent;
  final bool isActive;
  final VoidCallback? onTap;

  const AgentChip({
    Key? key,
    required this.agent,
    this.isActive = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color chipColor;
    switch (agent) {
      case AiAgent.claude:
        chipColor = theme.brightness == Brightness.dark
            ? const Color(0xFF9C64A6)
            : const Color(0xFFE0BBE4);
        break;
      case AiAgent.gpt:
        chipColor = theme.brightness == Brightness.dark
            ? const Color(0xFF00695C)
            : const Color(0xFFB2DFDB);
        break;
      case AiAgent.deepseek:
        chipColor = theme.brightness == Brightness.dark
            ? const Color(0xFFFFEB3B)
            : const Color(0xFFFFF59D);
        break;
      case AiAgent.gemini:
        chipColor = theme.brightness == Brightness.dark
            ? const Color(0xFF7C4DFF)
            : const Color(0xFFD1C4E9);
        break;
      case AiAgent.mistral:
        chipColor = theme.brightness == Brightness.dark
            ? const Color(0xFFFF7043)
            : const Color(0xFFFFCCBC);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? chipColor : chipColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: chipColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: agentIcon(agent, size: 24),
            ),
            const SizedBox(width: 8),
            Text(
              agentName(agent),
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
