// lib/widgets/ui/welcome_placeholder.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/conversation_mode.dart';  // Import corretto

class WelcomePlaceholder extends StatelessWidget {
  final ConversationMode mode;
  final VoidCallback? onTap;

  const WelcomePlaceholder({
    Key? key,
    required this.mode,
    this.onTap,
  }) : super(key: key);

  String _getModeTitle() {
    switch (mode) {
      case ConversationMode.chat:
        return 'Inizia una conversazione con il team AI';
      case ConversationMode.debate:
        return 'Proponi un tema per un dibattito tra le AI';
      case ConversationMode.brainstorm:
        return 'Avvia una sessione di brainstorming creativo';
    }
  }

  String _getModeDescription() {
    switch (mode) {
      case ConversationMode.chat:
        return 'Fai una domanda, chiedi consigli o semplicemente chatta con il nostro team di intelligenze artificiali.';
      case ConversationMode.debate:
        return 'Le AI discuteranno un tema da diverse prospettive, offrendo una visione completa dell\'argomento.';
      case ConversationMode.brainstorm:
        return 'Genera idee creative e soluzioni innovative con l\'aiuto delle diverse intelligenze artificiali.';
    }
  }

  IconData _getModeIcon() {
    switch (mode) {
      case ConversationMode.chat:
        return Icons.chat_outlined;
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

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getModeIcon(),
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                _getModeTitle(),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _getModeDescription(),
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scrivi per iniziare',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}