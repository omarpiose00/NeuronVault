// lib/models/conversation_mode.dart
import 'package:flutter/material.dart';

enum ConversationMode {
  /// Modalità di chat standard
  chat,

  /// Modalità dibattito tra AI
  debate,

  /// Modalità brainstorming collaborativo
  brainstorm
}

/// Estensione per ottenere informazioni sulla modalità
extension ConversationModeExtension on ConversationMode {
  /// Restituisce il nome leggibile della modalità
  String get displayName {
    switch (this) {
      case ConversationMode.chat:
        return 'Chat';
      case ConversationMode.debate:
        return 'Dibattito';
      case ConversationMode.brainstorm:
        return 'Brainstorming';
    }
  }

  /// Restituisce la descrizione della modalità
  String get description {
    switch (this) {
      case ConversationMode.chat:
        return 'Le AI rispondono una dopo l\'altra alle tue domande';
      case ConversationMode.debate:
        return 'Le AI discutono il tema proposto, ciascuna offrendo un punto di vista diverso';
      case ConversationMode.brainstorm:
        return 'Le AI collaborano per generare idee creative sul tema proposto';
    }
  }

  /// Restituisce l'icona associata alla modalità
  IconData get icon {
    switch (this) {
      case ConversationMode.chat:
        return Icons.chat_bubble_outline;
      case ConversationMode.debate:
        return Icons.compare_arrows;
      case ConversationMode.brainstorm:
        return Icons.lightbulb_outline;
    }
  }

  /// Restituisce il testo di placeholder per l'input
  String get placeholderText {
    switch (this) {
      case ConversationMode.chat:
        return 'Chiedi qualcosa al team AI...';
      case ConversationMode.debate:
        return 'Inserisci un tema per il dibattito...';
      case ConversationMode.brainstorm:
        return 'Su cosa vuoi fare brainstorming?';
    }
  }

  /// Restituisce il messaggio di benvenuto
  String get welcomeMessage {
    switch (this) {
      case ConversationMode.chat:
        return 'Inizia una conversazione con il team AI';
      case ConversationMode.debate:
        return 'Proponi un tema per un dibattito tra le AI';
      case ConversationMode.brainstorm:
        return 'Avvia una sessione di brainstorming creativo';
    }
  }
}