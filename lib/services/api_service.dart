// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ai_agent.dart';

class AiConversationMessage {
  final String agent; // "user", "claude", "gpt", "deepseek", "system"
  final String message;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaType;

  AiConversationMessage({
    required this.agent,
    required this.message,
    this.mediaUrl,
    this.mediaType,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiConversationMessage.fromJson(Map<String, dynamic> json) {
    return AiConversationMessage(
      agent: json['agent'] ?? '',
      message: json['message'] ?? '',
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'agent': agent,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
    if (mediaType != null) 'mediaType': mediaType,
  };

  AiAgent? toAiAgent() {
    switch (agent) {
      case "claude": return AiAgent.claude;
      case "gpt": return AiAgent.gpt;
      case "deepseek": return AiAgent.deepseek;
      default: return null;
    }
  }

  String getFormattedMessage() {
    // Se è un messaggio di errore, formattalo in modo leggibile
    if (agent == 'system' && message.toLowerCase().contains('errore:')) {
      // Estrai il messaggio di errore principale
      String errorMsg = message;

      // Gestisci errori JSON
      if (errorMsg.contains('Exception:')) {
        try {
          // Prova a estrarre il messaggio di errore principale
          final startIndex = errorMsg.indexOf('Errore:');
          if (startIndex != -1) {
            var endIndex = errorMsg.indexOf('https://');
            if (endIndex == -1) endIndex = errorMsg.length;
            errorMsg = errorMsg.substring(startIndex, endIndex).trim();
          }

          // Rimuovi dettagli tecnici eccessivi
          errorMsg = errorMsg.replaceAll(RegExp(r'{"conversation":\[.*?\]}'), '');

          // Gestisci errori API specifici
          if (errorMsg.contains('OpenAI:')) {
            errorMsg = errorMsg.replaceAll(RegExp(r'Errore OpenAI:.*quota'),
                'Errore: Limite di utilizzo OpenAI superato');
          } else if (errorMsg.contains('Claude:')) {
            errorMsg = errorMsg.replaceAll(RegExp(r'Errore Claude:.*'),
                'Errore: Problema con il servizio Claude');
          } else if (errorMsg.contains('DeepSeek:')) {
            errorMsg = errorMsg.replaceAll(RegExp(r'Errore DeepSeek:.*'),
                'Errore: Problema con il servizio DeepSeek');
          }
        } catch (e) {
          // Se non riesci a formattare, restituisci un messaggio generico
          return 'Si è verificato un errore nel servizio AI. Riprova più tardi.';
        }
      }

      return errorMsg;
    }

    // Per i messaggi normali, restituisci il testo originale
    return message;
  }
}

class AiServiceResponse {
  final List<AiConversationMessage> conversation;

  AiServiceResponse({required this.conversation});

  factory AiServiceResponse.fromJson(Map<String, dynamic> json) {
    final conversationJson = json['conversation'] as List;
    return AiServiceResponse(
      conversation: conversationJson
          .map((msgJson) => AiConversationMessage.fromJson(msgJson))
          .toList(),
    );
  }
}

enum ConversationMode {
  chat, debate, brainstorm
}

class ApiService {
  static const String backendUrl = 'http://localhost:4000';

  static Future<AiServiceResponse> askAgents(
      String prompt, {
        String conversationId = 'default',
        ConversationMode mode = ConversationMode.chat
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/multi-agent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'conversationId': conversationId,
          'mode': mode.toString().split('.').last,
        }),
      );

      if (response.statusCode == 200) {
        return AiServiceResponse.fromJson(jsonDecode(response.body));
      } else {
        // Formatta l'errore per renderlo più leggibile
        String errorMessage = 'Errore AI: ${response.body}';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson.containsKey('error')) {
            errorMessage = 'Errore: ${errorJson['error']}';
          }
        } catch (e) {
          // Ignora errori di parsing
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Migliora l'errore per i problemi di connessione
      if (e is SocketException) {
        throw Exception('Errore di connessione: impossibile contattare il server. Verifica la tua connessione internet.');
      }
      rethrow;
    }
  }

  static Future<AiServiceResponse> uploadImage(
      String prompt,
      File imageFile, {
        String conversationId = 'default',
      }) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('$backendUrl/multi-agent/image')
      );

      request.fields['prompt'] = prompt;
      request.fields['conversationId'] = conversationId;
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return AiServiceResponse.fromJson(jsonDecode(response.body));
      } else {
        // Formatta l'errore per renderlo più leggibile
        String errorMessage = 'Errore caricamento immagine: ${response.body}';
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson.containsKey('error')) {
            errorMessage = 'Errore: ${errorJson['error']}';
          }
        } catch (e) {
          // Ignora errori di parsing
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Migliora l'errore per i problemi di connessione
      if (e is SocketException) {
        throw Exception('Errore di connessione: impossibile contattare il server. Verifica la tua connessione internet.');
      }
      rethrow;
    }
  }
}