// lib/services/error_handler.dart - Gestione centralizzata errori
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

enum ErrorType {
  network,
  timeout,
  authentication,
  quota,
  validation,
  server,
  unknown,
}

class ErrorInfo {
  final ErrorType type;
  final String title;
  final String message;
  final String? technicalDetails;
  final List<String> suggestions;
  final bool canRetry;

  const ErrorInfo({
    required this.type,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.suggestions = const [],
    this.canRetry = false,
  });
}

class ErrorHandler {
  static ErrorInfo analyzeError(dynamic error) {
    if (error is SocketException) {
      return const ErrorInfo(
        type: ErrorType.network,
        title: 'Problema di Connessione',
        message: 'Impossibile connettersi ai servizi AI. Verifica la tua connessione internet.',
        suggestions: [
          'Controlla la connessione internet',
          'Verifica che non ci siano firewall che bloccano la connessione',
          'Prova a cambiare rete'
        ],
        canRetry: true,
      );
    }

    if (error is TimeoutException) {
      return const ErrorInfo(
        type: ErrorType.timeout,
        title: 'Timeout',
        message: 'La richiesta ha richiesto troppo tempo. Il servizio potrebbe essere sovraccarico.',
        suggestions: [
          'Riprova tra qualche minuto',
          'Prova con una richiesta più semplice',
          'Verifica la stabilità della connessione'
        ],
        canRetry: true,
      );
    }

    if (error is HttpException) {
      return ErrorInfo(
        type: ErrorType.server,
        title: 'Errore del Server',
        message: 'Il server ha restituito un errore. Riprova più tardi.',
        technicalDetails: error.message,
        suggestions: const [
          'Riprova tra qualche minuto',
          'Verifica lo stato dei servizi',
          'Contatta il supporto se il problema persiste'
        ],
        canRetry: true,
      );
    }

    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('api key') || errorMessage.contains('unauthorized')) {
      return const ErrorInfo(
        type: ErrorType.authentication,
        title: 'Problema di Autenticazione',
        message: 'Le chiavi API non sono valide o sono scadute.',
        suggestions: [
          'Verifica le chiavi API nelle impostazioni',
          'Controlla che le chiavi non siano scadute',
          'Rigenera le chiavi se necessario'
        ],
        canRetry: false,
      );
    }

    if (errorMessage.contains('quota') || errorMessage.contains('limit')) {
      return const ErrorInfo(
        type: ErrorType.quota,
        title: 'Limite Raggiunto',
        message: 'Hai raggiunto il limite di utilizzo delle API. Controlla il tuo piano.',
        suggestions: [
          'Verifica i limiti del tuo piano',
          'Attendi il reset del limite',
          'Considera l\'upgrade del piano'
        ],
        canRetry: false,
      );
    }

    if (errorMessage.contains('invalid') || errorMessage.contains('validation')) {
      return ErrorInfo(
        type: ErrorType.validation,
        title: 'Dati Non Validi',
        message: 'I dati inviati non sono validi.',
        technicalDetails: error.toString(),
        suggestions: const [
          'Verifica il formato della richiesta',
          'Prova con parametri diversi'
        ],
        canRetry: false,
      );
    }

    return ErrorInfo(
      type: ErrorType.unknown,
      title: 'Errore Imprevisto',
      message: 'Si è verificato un errore imprevisto.',
      technicalDetails: error.toString(),
      suggestions: const [
        'Riprova l\'operazione',
        'Riavvia l\'app se necessario',
        'Contatta il supporto se il problema persiste'
      ],
      canRetry: true,
    );
  }

  static void showErrorDialog(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
    final errorInfo = analyzeError(error);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          _getErrorIcon(errorInfo.type),
          color: _getErrorColor(errorInfo.type),
          size: 32,
        ),
        title: Text(errorInfo.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorInfo.message),

              if (errorInfo.suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Suggerimenti:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...errorInfo.suggestions.map((suggestion) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(suggestion)),
                        ],
                      ),
                    ),
                ),
              ],

              if (errorInfo.technicalDetails != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('Dettagli Tecnici'),
                  children: [
                    SelectableText(
                      errorInfo.technicalDetails!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
          if (errorInfo.canRetry && onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Riprova'),
            ),
        ],
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, dynamic error, {VoidCallback? onRetry}) {
    final errorInfo = analyzeError(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(errorInfo.type),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorInfo.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(errorInfo.message),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(errorInfo.type),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: errorInfo.canRetry && onRetry != null
            ? SnackBarAction(
          label: 'Riprova',
          onPressed: onRetry,
          textColor: Colors.white,
        )
            : SnackBarAction(
          label: 'OK',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.schedule;
      case ErrorType.authentication:
        return Icons.key_off;
      case ErrorType.quota:
        return Icons.trending_up;
      case ErrorType.validation:
        return Icons.warning;
      case ErrorType.server:
        return Icons.dns;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.timeout:
        return Colors.amber;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.quota:
        return Colors.purple;
      case ErrorType.validation:
        return Colors.yellow.shade700;
      case ErrorType.server:
        return Colors.blue;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  // Log errori per analytics
  static void logError(dynamic error, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorInfo = analyzeError(error);

    // In produzione, qui invieresti gli errori a un servizio di analytics
    debugPrint('🔥 ERROR LOGGED:');
    debugPrint('  Type: ${errorInfo.type}');
    debugPrint('  Title: ${errorInfo.title}');
    debugPrint('  Message: ${errorInfo.message}');
    if (context != null) debugPrint('  Context: $context');
    if (additionalData != null) debugPrint('  Data: $additionalData');
    if (errorInfo.technicalDetails != null) {
      debugPrint('  Technical: ${errorInfo.technicalDetails}');
    }
  }
}