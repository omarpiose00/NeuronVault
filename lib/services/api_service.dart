import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ai_agent.dart';
import '../models/conversation_mode.dart';
import 'dart:async';

class AiConversationMessage {
  final String agent; // "user", "system", o nome modello (openai, anthropic, etc.)
  final String message;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaType;
  final Map<String, dynamic>? metadata;

  AiConversationMessage({
    required this.agent,
    required this.message,
    this.mediaUrl,
    this.mediaType,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiConversationMessage.fromJson(Map<String, dynamic> json) {
    return AiConversationMessage(
      agent: json['agent'] ?? 'system',
      message: json['message'] ?? '',
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
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
    if (metadata != null) 'metadata': metadata,
  };

  AiAgent? toAiAgent() {
    switch (agent) {
      case "anthropic": return AiAgent.claude;
      case "openai": return AiAgent.gpt;
      case "deepseek": return AiAgent.deepseek;
      case "google": return AiAgent.gemini;
      default: return null;
    }
  }

  String getFormattedMessage() {
    if (agent == 'system' && message.toLowerCase().contains('errore:')) {
      return _formatErrorMessage(message);
    }
    return message;
  }

  String _formatErrorMessage(String errorMsg) {
    try {
      // Estrai il messaggio principale
      final startIndex = errorMsg.indexOf('Errore:');
      if (startIndex != -1) {
        var endIndex = errorMsg.indexOf('http://');
        if (endIndex == -1) endIndex = errorMsg.length;
        errorMsg = errorMsg.substring(startIndex, endIndex).trim();
      }

      // Sostituisci errori specifici
      errorMsg = errorMsg.replaceAll(RegExp(r'{"conversation":\[.*?\]}'), '');

      // Gestisci errori API specifici
      final errorPatterns = {
        'OpenAI': 'Limite di utilizzo OpenAI superato',
        'Anthropic': 'Problema con il servizio Claude',
        'DeepSeek': 'Problema con il servizio DeepSeek',
        'Google': 'Problema con il servizio Gemini',
      };

      for (final entry in errorPatterns.entries) {
        if (errorMsg.contains(entry.key)) {
          return 'Errore: ${entry.value}';
        }
      }

      return errorMsg;
    } catch (e) {
      return 'Si è verificato un errore nel servizio AI. Riprova più tardi.';
    }
  }
}

class AiServiceResponse {
  final List<AiConversationMessage> conversation;
  final Map<String, String> responses;
  final Map<String, double> weights;
  final String synthesizedResponse;
  final Map<String, dynamic>? metadata;

  AiServiceResponse({
    required this.conversation,
    this.responses = const {},
    this.weights = const {},
    this.synthesizedResponse = '',
    this.metadata,
  });

  factory AiServiceResponse.fromJson(Map<String, dynamic> json) {
    // Estrai la conversazione
    final conversation = (json['conversation'] as List)
        .map((msg) => AiConversationMessage.fromJson(msg))
        .toList();

    // Estrai le risposte individuali
    final responses = (json['responses'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value.toString()),
    ) ?? {};

    // Estrai i pesi
    final weights = (json['weights'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
    ) ?? {};

    // Estrai la risposta sintetizzata
    String synthesizedResponse = '';
    if (json.containsKey('synthesized_response')) {
      synthesizedResponse = json['synthesized_response'] ?? '';
    } else if (conversation.isNotEmpty && conversation.last.agent == 'system') {
      synthesizedResponse = conversation.last.message;
    }

    // Estrai metadata aggiuntivi
    final metadata = json['metadata'] as Map<String, dynamic>?;

    return AiServiceResponse(
      conversation: conversation,
      responses: responses,
      weights: weights,
      synthesizedResponse: synthesizedResponse,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'conversation': conversation.map((msg) => msg.toJson()).toList(),
    'responses': responses,
    'weights': weights,
    'synthesized_response': synthesizedResponse,
    if (metadata != null) 'metadata': metadata,
  };
}

class MockResponses {
  static Map<String, String> getMockResponses(String prompt, ConversationMode mode) {
    final responses = {
      'openai': 'OpenAI response to: "$prompt" (${_modeToString(mode)})',
      'anthropic': 'Claude response to: "$prompt" (${_modeToString(mode)})',
      'deepseek': 'DeepSeek response to: "$prompt" (${_modeToString(mode)})',
      'google': 'Gemini response to: "$prompt" (${_modeToString(mode)})',
    };
    return responses;
  }

  static Map<String, double> getMockWeights() {
    return {
      'openai': 0.35,
      'anthropic': 0.25,
      'deepseek': 0.20,
      'google': 0.20,
    };
  }

  static String getMockSynthesizedResponse(String prompt, ConversationMode mode) {
    final modeStr = _modeToString(mode);
    return "This is a synthesized mock response for: \"$prompt\" in $modeStr mode. "
        "The response combines insights from multiple AI agents in a demo environment.";
  }

  static String _modeToString(ConversationMode mode) {
    return mode.toString().split('.').last;
  }
}

class ApiService {
  static const String backendUrl = 'http://localhost:4000';
  static const Duration timeout = Duration(seconds: 30);
  static bool useMockData = true; // Enable demo mode

  static Future<AiServiceResponse> askAgents(
      String prompt, {
        String conversationId = 'default',
        ConversationMode mode = ConversationMode.chat,
        Map<String, double>? weights,
        Map<String, dynamic>? options,
      }) async {

    // Use mock data if in demo mode
    if (useMockData) {
      // Simulate a short delay
      await Future.delayed(const Duration(seconds: 2));

      final responses = MockResponses.getMockResponses(prompt, mode);
      final mockWeights = weights ?? MockResponses.getMockWeights();
      final synthesizedResponse = MockResponses.getMockSynthesizedResponse(prompt, mode);

      final conversation = [
        AiConversationMessage(
          agent: 'user',
          message: prompt,
          timestamp: DateTime.now().subtract(const Duration(seconds: 3)),
        ),
        AiConversationMessage(
          agent: 'system',
          message: synthesizedResponse,
          timestamp: DateTime.now(),
        ),
      ];

      return AiServiceResponse(
        conversation: conversation,
        responses: responses,
        weights: mockWeights,
        synthesizedResponse: synthesizedResponse,
      );
    }

    try {
      final requestData = {
        'prompt': prompt,
        'conversationId': conversationId,
        'mode': _modeToString(mode),
        if (weights != null && weights.isNotEmpty) 'weights': weights,
        if (options != null) 'options': options,
      };

      final response = await http.post(
        Uri.parse('$backendUrl/multi-agent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      ).timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('Errore di connessione: impossibile contattare il server. Verifica la tua connessione internet.');
    } on http.ClientException {
      throw Exception('Errore durante la comunicazione con il server backend.');
    } on TimeoutException {
      throw Exception('Timeout: il server non ha risposto entro il tempo previsto.');
    } catch (e) {
      throw Exception('Errore sconosciuto: ${e.toString()}');
    }
  }

  static Future<AiServiceResponse> uploadImage(
      String prompt,
      File imageFile, {
        String conversationId = 'default',
        Map<String, double>? weights,
        Map<String, dynamic>? options,
      }) async {
    // For image upload, we'll keep it real even in demo mode
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/multi-agent/image'),
      );

      request.fields.addAll({
        'prompt': prompt,
        'conversationId': conversationId,
        if (weights != null) 'weights': jsonEncode(weights),
        if (options != null) 'options': jsonEncode(options),
      });

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('Errore di connessione durante il caricamento dell\'immagine.');
    } on TimeoutException {
      throw Exception('Timeout durante il caricamento dell\'immagine.');
    } catch (e) {
      throw Exception('Errore durante il caricamento dell\'immagine: ${e.toString()}');
    }
  }

  static AiServiceResponse _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return AiServiceResponse.fromJson(jsonDecode(response.body));
    } else {
      final error = _parseError(response.body);
      throw Exception(error);
    }
  }

  static String _parseError(String responseBody) {
    try {
      final errorJson = jsonDecode(responseBody);
      return errorJson['error'] ?? errorJson['message'] ?? 'Errore sconosciuto dal server';
    } catch (e) {
      return responseBody.isNotEmpty
          ? responseBody
          : 'Errore senza messaggio dal server';
    }
  }

  static String _modeToString(ConversationMode mode) {
    return mode.toString().split('.').last;
  }
}