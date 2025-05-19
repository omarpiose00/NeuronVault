import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorMessageWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.shade900.withOpacity(0.7) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.red.shade800 : Colors.red.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Errore',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getReadableErrorMessage(errorMessage),
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.red.shade800 : Colors.red.shade100,
                  foregroundColor: isDark ? Colors.white : Colors.red.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getReadableErrorMessage(String error) {
    // Elimina il prefisso comune
    String cleanError = error.replaceAll('Errore: ', '');

    // Gestisci messaggi comuni
    if (cleanError.contains('quota') || cleanError.contains('exceeded')) {
      return 'Hai raggiunto il limite di utilizzo dell\'API. Riprova più tardi o controlla il tuo piano.';
    } else if (cleanError.contains('OpenAI')) {
      return 'Il servizio GPT non è disponibile al momento. Riprova più tardi.';
    } else if (cleanError.contains('Claude') || cleanError.contains('Anthropic')) {
      return 'Il servizio Claude non è disponibile al momento. Riprova più tardi.';
    } else if (cleanError.contains('DeepSeek')) {
      return 'Il servizio DeepSeek non è disponibile al momento. Riprova più tardi.';
    } else if (cleanError.contains('API key')) {
      return 'Problema con le chiavi API. Contatta l\'amministratore.';
    }

    // Se nessuna regola specifica corrisponde, pulisci il testo
    cleanError = cleanError.replaceAll(RegExp(r'{".*?"}'), '');

    // Se il messaggio è troppo lungo, tronca
    if (cleanError.length > 150) {
      cleanError = cleanError.substring(0, 150) + '...';
    }

    return cleanError;
  }
}