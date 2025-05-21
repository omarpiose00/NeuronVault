// lib/services/mock_responses.dart
import '../models/conversation_mode.dart';
import 'dart:math';

class MockResponses {
  static Map<String, String> getMockResponses(String prompt, ConversationMode mode) {
    // Invece di utilizzare Random, che richiede l'import, usiamo valori fissi
    final responses = {
      'gpt': _generateMockGptResponse(prompt, mode),
      'claude': _generateMockClaudeResponse(prompt, mode),
      'deepseek': _generateMockDeepseekResponse(prompt, mode),
      'gemini': _generateMockGeminiResponse(prompt, mode),
      'mistral': _generateMockMistralResponse(prompt, mode),
    };
    return responses;
  }


  static Map<String, double> getMockWeights() {
    return {
      'gpt': 1.0,
      'claude': 1.0,
      'deepseek': 1.0,
      'gemini': 1.0,
      'mistral': 1.0,
    };
  }

  static String getMockSynthesizedResponse(String prompt, ConversationMode mode) {
    switch (mode) {
      case ConversationMode.chat:
        return "Sintesi della risposta alla tua domanda: \"$prompt\". "
            "Ho combinato le intuizioni di diversi modelli AI per offrirti la risposta più completa. "
            "Spero che questa informazione ti sia utile!";
      case ConversationMode.debate:
        return "Ho analizzato diversi punti di vista sul tema \"$prompt\". "
            "Ci sono prospettive contrastanti che meritano considerazione. "
            "Da un lato... dall'altro... In conclusione, è una questione complessa con validi argomenti da entrambe le parti.";
      case ConversationMode.brainstorm:
        return "Ecco alcune idee creative sul tema \"$prompt\": "
            "1. Un approccio innovativo potrebbe essere... "
            "2. Considerando da una prospettiva diversa... "
            "3. Un'idea non convenzionale sarebbe... "
            "Queste sono solo alcune possibilità da esplorare!";
    }
  }

  static String _generateMockGptResponse(String prompt, ConversationMode mode) {
    return "Risposta di GPT per: \"$prompt\". "
        "Ecco la mia analisi basata sui dati più recenti... "
        "Spero che questa risposta ti fornisca le informazioni che cercavi.";
  }

  static String _generateMockClaudeResponse(String prompt, ConversationMode mode) {
    return "Risposta di Claude per: \"$prompt\". "
        "Permettimi di esplorare questo argomento in modo approfondito... "
        "Considero sempre importante fornire una prospettiva bilanciata e sfumata.";
  }

  static String _generateMockDeepseekResponse(String prompt, ConversationMode mode) {
    return "Risposta di DeepSeek per: \"$prompt\". "
        "Sulla base della mia analisi, posso dirti che... "
        "Le informazioni più aggiornate suggeriscono che...";
  }

  static String _generateMockGeminiResponse(String prompt, ConversationMode mode) {
    return "Risposta di Gemini per: \"$prompt\". "
        "Permettimi di offrire una prospettiva multimodale su questo tema... "
        "Considerando le molteplici dimensioni di questo argomento...";
  }

  static String _generateMockMistralResponse(String prompt, ConversationMode mode) {
    return "Risposta di Mistral per: \"$prompt\". "
        "Ecco la mia risposta concisa e precisa... "
        "La mia analisi suggerisce che...";
  }
}