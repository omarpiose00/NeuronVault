// lib/widgets/ui/animated_app_bar.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';  // Percorso corretto (2 livelli su)
import '../../models/conversation_mode.dart';  // Percorso corretto (2 livelli su)

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ConversationMode currentMode;
  final Function(ConversationMode) onModeChanged;
  final VoidCallback onResetChat;
  final bool isScrolled;

  const AnimatedAppBar({
    Key? key,
    required this.title,
    required this.currentMode,
    required this.onModeChanged,
    required this.onResetChat,
    this.isScrolled = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _getModeText(ConversationMode mode) {
    switch (mode) {
      case ConversationMode.chat:
        return 'Chat';
      case ConversationMode.debate:
        return 'Dibattito';
      case ConversationMode.brainstorm:
        return 'Brainstorming';
    }
  }

  IconData _getModeIcon(ConversationMode mode) {
    switch (mode) {
      case ConversationMode.chat:
        return Icons.chat_bubble_outline;
      case ConversationMode.debate:
        return Icons.compare_arrows;
      case ConversationMode.brainstorm:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isScrolled
            ? theme.appBarTheme.backgroundColor
            : theme.appBarTheme.backgroundColor?.withOpacity(0.8),
        boxShadow: isScrolled
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: AppBar(
        title: Row(
          children: [
            Text(title),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getModeIcon(currentMode),
                    size: 12,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getModeText(currentMode),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<ConversationMode>(
            icon: Icon(
              Icons.mode_edit,
              color: theme.colorScheme.primary,
            ),
            onSelected: onModeChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ConversationMode.chat,
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: currentMode == ConversationMode.chat
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Modalità Chat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ConversationMode.debate,
                child: Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      color: currentMode == ConversationMode.debate
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Modalità Dibattito'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ConversationMode.brainstorm,
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: currentMode == ConversationMode.brainstorm
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Modalità Brainstorming'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: theme.colorScheme.primary,
            onPressed: onResetChat,
            tooltip: 'Nuova conversazione',
          ),
        ],
      ),
    );
  }
}